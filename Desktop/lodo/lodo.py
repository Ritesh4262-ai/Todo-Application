import os
import datetime
from typing import Optional

import jwt
import psycopg2
import psycopg2.extras
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr

# Run with:  uvicorn lodo:app --reload

# --- Database Connection Configuration ---
# NOTE: never hardcode real passwords in source code. Set these as
# environment variables before running, e.g.:
#   set DB_PASSWORD=your_password   (Windows)
#   export DB_PASSWORD=your_password (Mac/Linux)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "Ritesh@#2002")
DB_NAME = os.getenv("DB_NAME", "lodo")
DB_PORT = int(os.getenv("DB_PORT", "5432"))

# --- Auth Configuration ---
# Set a real random secret via env var in production, e.g.:
#   export JWT_SECRET=$(openssl rand -hex 32)
SECRET_KEY = os.getenv("JWT_SECRET", "dev-only-change-this-secret")
ALGORITHM = "HS256"
TOKEN_EXPIRE_HOURS = 24

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_db():
    connection = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        dbname=DB_NAME,
        port=DB_PORT,
        cursor_factory=psycopg2.extras.RealDictCursor,
    )
    try:
        yield connection
    finally:
        connection.close()


app = FastAPI(title="To-Do App API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Pydantic Schemas ---
class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None


# --- Auth helpers ---
def create_token(user_id: int) -> str:
    payload = {
        # PyJWT 2.10+ requires "sub" to be a string
        "sub": str(user_id),
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=TOKEN_EXPIRE_HOURS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def get_current_user_id(authorization: str = Header(None)) -> int:
    """Reads the Bearer token, verifies it, and returns the user_id it belongs to.
    This is what actually enforces data isolation - the frontend can never
    just claim to be a different user_id."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    token = authorization.split(" ", 1)[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return int(payload["sub"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Session expired, please log in again")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid session token")


# ==========================================
# AUTH APIS
# ==========================================

@app.post("/register", status_code=201)
def register(user: UserRegister, db=Depends(get_db)):
    cursor = db.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s", (user.email,))
    if cursor.fetchone():
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed = pwd_context.hash(user.password)
    cursor.execute(
        "INSERT INTO users (name, email, password_hash) VALUES (%s, %s, %s) RETURNING id",
        (user.name, user.email, hashed),
    )
    new_user_id = cursor.fetchone()["id"]
    db.commit()
    token = create_token(new_user_id)
    return {"token": token, "user": {"id": new_user_id, "name": user.name, "email": user.email}}


@app.post("/login")
def login(credentials: UserLogin, db=Depends(get_db)):
    cursor = db.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (credentials.email,))
    user = cursor.fetchone()
    if not user or not pwd_context.verify(credentials.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_token(user["id"])
    return {"token": token, "user": {"id": user["id"], "name": user["name"], "email": user["email"]}}


@app.get("/me")
def get_me(user_id: int = Depends(get_current_user_id), db=Depends(get_db)):
    cursor = db.cursor()
    cursor.execute("SELECT id, name, email FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# ==========================================
# TASKS CRUD APIS
# All of these use the token to find user_id - none of them ever trust
# a user_id sent by the client, so one user can never see or touch
# another user's tasks.
# ==========================================

@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate, user_id: int = Depends(get_current_user_id), db=Depends(get_db)):
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO tasks (title, description, user_id) VALUES (%s, %s, %s) RETURNING id",
        (task.title, task.description, user_id),
    )
    task_id = cursor.fetchone()["id"]
    db.commit()
    return {
        "id": task_id,
        "title": task.title,
        "description": task.description,
        "status": "pending",
        "user_id": user_id,
    }


@app.get("/tasks")
def list_tasks(user_id: int = Depends(get_current_user_id), db=Depends(get_db)):
    cursor = db.cursor()
    cursor.execute("SELECT * FROM tasks WHERE user_id = %s ORDER BY id", (user_id,))
    return cursor.fetchall()


def _get_owned_task(cursor, task_id: int, user_id: int):
    cursor.execute("SELECT * FROM tasks WHERE id = %s", (task_id,))
    task = cursor.fetchone()
    if not task or task["user_id"] != user_id:
        # Same "not found" message whether the task doesn't exist or belongs
        # to someone else - this avoids leaking which task IDs exist.
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@app.put("/tasks/{task_id}")
def update_task(task_id: int, task: TaskUpdate, user_id: int = Depends(get_current_user_id), db=Depends(get_db)):
    cursor = db.cursor()
    existing_task = _get_owned_task(cursor, task_id, user_id)

    new_title = task.title if task.title is not None else existing_task["title"]
    new_desc = task.description if task.description is not None else existing_task["description"]
    new_status = task.status if task.status is not None else existing_task["status"]

    cursor.execute(
        "UPDATE tasks SET title = %s, description = %s, status = %s WHERE id = %s",
        (new_title, new_desc, new_status, task_id),
    )
    db.commit()
    return {"id": task_id, "title": new_title, "description": new_desc, "status": new_status}


@app.delete("/tasks/{task_id}", status_code=204)
def delete_task(task_id: int, user_id: int = Depends(get_current_user_id), db=Depends(get_db)):
    cursor = db.cursor()
    _get_owned_task(cursor, task_id, user_id)
    cursor.execute("DELETE FROM tasks WHERE id = %s", (task_id,))
    db.commit()
    return None
