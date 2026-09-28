--
-- PostgreSQL database dump
--

\restrict Guhvq4klkLRYah2JFJs3VRXhEQTwaiFqBSClbn2ZMEHHdLjMmtRRoTAb0cHc7VB

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-09-28 22:32:06

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16818)
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50) DEFAULT 'pending'::character varying,
    user_id integer NOT NULL
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16817)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 221
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- TOC entry 220 (class 1259 OID 16805)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16804)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4862 (class 2604 OID 16821)
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- TOC entry 4861 (class 2604 OID 16808)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5021 (class 0 OID 16818)
-- Dependencies: 222
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, title, description, status, user_id) FROM stdin;
2	Milk	Milk Lana hai	pending	1
1	Apple	Apple Lana hai Market se	done	1
3	Vegitable	Vegetable lana hai market se	pending	2
4	java	All java topic padhna hai	pending	2
5	Mango	Market se Mango lana hai	pending	3
6	Review yesterday's lecture notes.	Spend 10 minutes scanning through the formulas, circuit diagrams, or algorithms from the previous day's classes to move the data into long-term memory.	pending	4
7	Code for 20 minutes.	Solve one simple problem on LeetCode or HackerRank, or write a few lines of code for a personal side project to keep programming logic sharp.	done	5
8	Review yesterday's lecture notes.	Spend 10 minutes scanning through the formulas, circuit diagrams, or algorithms from the previous day's classes to move the data into long-term memory.	pending	5
10	Sunlight & Movement	Spend 10 minutes outside walking or stretching. Early morning natural light resets your circadian rhythm for energy.	pending	6
\.


--
-- TOC entry 5019 (class 0 OID 16805)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password_hash) FROM stdin;
1	ritesh	ritesh@gmail.com	$2b$12$DZs5VW/HyIKgAXEgsRBzb.h0.xHAGwp0dB5Jqar1uiTeI1PmqW9VW
2	rohit	rohit@gmail.com	$2b$12$/Mf722GEBqcfgL203oLIBe7FkRAAeKEkMe/cXSkw9Y7zV6RlSjCLW
3	Ad	ad@gmail.com	$2b$12$iHR/YsnK.2WSjjIWQ8v27um5UfLkR.wpy7SR1PkgKj5ogM6YfEGOe
4	CK	ck@gmail.com	$2b$12$..8cOlVapTROQC.oKmQ30.no.IMTXARD5gaFo5XUtPHCbZlJyNA6a
5	DK	dk@gmail.com	$2b$12$0v1bvZ8wtG8cjYy2hayiYeS7.AtLS1AafLDugrIxp3toJ8sAy9WAm
6	Parth	parth@gmail.com	$2b$12$Ft0rHD9i9z/1DbzXPlJxaOvIuSUmibZFHfsdBpO7SzpxkxVKign1q
\.


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 221
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 10, true);


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- TOC entry 4869 (class 2606 OID 16829)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 4865 (class 2606 OID 16816)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4867 (class 2606 OID 16814)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4870 (class 2606 OID 16830)
-- Name: tasks tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-09-28 22:32:07

--
-- PostgreSQL database dump complete
--

\unrestrict Guhvq4klkLRYah2JFJs3VRXhEQTwaiFqBSClbn2ZMEHHdLjMmtRRoTAb0cHc7VB

