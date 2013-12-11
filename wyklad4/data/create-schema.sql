--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.8
-- Dumped by pg_dump version 9.1.8
-- Started on 2013-03-20 15:47:01 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 167 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1897 (class 0 OID 0)
-- Dependencies: 167
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 166 (class 1259 OID 285390)
-- Dependencies: 6
-- Name: PRACA_DYPLOMOWA; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE "PRACA_DYPLOMOWA" (
    tytul character varying NOT NULL,
    type character varying NOT NULL,
    student_id integer NOT NULL,
    promotor_id integer
);


--
-- TOC entry 162 (class 1259 OID 285357)
-- Dependencies: 6
-- Name: PRACOWNIK; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE "PRACOWNIK" (
    id integer NOT NULL,
    name character varying,
    surname character varying,
    gender smallint,
    tel_no character varying
);


--
-- TOC entry 161 (class 1259 OID 285355)
-- Dependencies: 6 162
-- Name: PRACOWNIK_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "PRACOWNIK_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 1898 (class 0 OID 0)
-- Dependencies: 161
-- Name: PRACOWNIK_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "PRACOWNIK_id_seq" OWNED BY "PRACOWNIK".id;


--
-- TOC entry 165 (class 1259 OID 285376)
-- Dependencies: 6
-- Name: STUDENT; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE "STUDENT" (
    id integer NOT NULL,
    name character varying,
    surname character varying,
    gender smallint,
    status character varying,
    message character varying
);


--
-- TOC entry 164 (class 1259 OID 285374)
-- Dependencies: 165 6
-- Name: STUDENT_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "STUDENT_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 1899 (class 0 OID 0)
-- Dependencies: 164
-- Name: STUDENT_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "STUDENT_id_seq" OWNED BY "STUDENT".id;


--
-- TOC entry 163 (class 1259 OID 285366)
-- Dependencies: 6
-- Name: TAG; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE "TAG" (
    key character varying NOT NULL,
    label character varying
);


--
-- TOC entry 1870 (class 2604 OID 285360)
-- Dependencies: 161 162 162
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PRACOWNIK" ALTER COLUMN id SET DEFAULT nextval('"PRACOWNIK_id_seq"'::regclass);


--
-- TOC entry 1871 (class 2604 OID 285379)
-- Dependencies: 164 165 165
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "STUDENT" ALTER COLUMN id SET DEFAULT nextval('"STUDENT_id_seq"'::regclass);


--
-- TOC entry 1889 (class 0 OID 285390)
-- Dependencies: 166 1890
-- Data for Name: PRACA_DYPLOMOWA; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "TAG" (key, label) FROM stdin;
praca:dr	Praca Doktorska
praca:inz	Praca Inżynierska
praca:mgr	Praca Magisterska
status:absolwent	Absolwent
status:doktorant	Doktorant
status:student	Student
\.


--
-- TOC entry 1879 (class 2606 OID 285397)
-- Dependencies: 166 166 166 1891
-- Name: PRACA_DYPLOMOWA_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY "PRACA_DYPLOMOWA"
    ADD CONSTRAINT "PRACA_DYPLOMOWA_pkey" PRIMARY KEY (type, student_id);


--
-- TOC entry 1873 (class 2606 OID 285365)
-- Dependencies: 162 162 1891
-- Name: PRACOWNIK_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY "PRACOWNIK"
    ADD CONSTRAINT "PRACOWNIK_pkey" PRIMARY KEY (id);


--
-- TOC entry 1877 (class 2606 OID 285384)
-- Dependencies: 165 165 1891
-- Name: STUDENT_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY "STUDENT"
    ADD CONSTRAINT "STUDENT_pkey" PRIMARY KEY (id);


--
-- TOC entry 1875 (class 2606 OID 285373)
-- Dependencies: 163 163 1891
-- Name: TAG_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY "TAG"
    ADD CONSTRAINT "TAG_pkey" PRIMARY KEY (key);


--
-- TOC entry 1883 (class 2606 OID 285408)
-- Dependencies: 166 1872 162 1891
-- Name: PRACA_DYPLOMOWA_promotor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PRACA_DYPLOMOWA"
    ADD CONSTRAINT "PRACA_DYPLOMOWA_promotor_id_fkey" FOREIGN KEY (promotor_id) REFERENCES "PRACOWNIK"(id);


--
-- TOC entry 1882 (class 2606 OID 285403)
-- Dependencies: 166 165 1876 1891
-- Name: PRACA_DYPLOMOWA_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PRACA_DYPLOMOWA"
    ADD CONSTRAINT "PRACA_DYPLOMOWA_student_id_fkey" FOREIGN KEY (student_id) REFERENCES "STUDENT"(id);


--
-- TOC entry 1881 (class 2606 OID 285398)
-- Dependencies: 166 163 1874 1891
-- Name: PRACA_DYPLOMOWA_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PRACA_DYPLOMOWA"
    ADD CONSTRAINT "PRACA_DYPLOMOWA_type_fkey" FOREIGN KEY (type) REFERENCES "TAG"(key);


--
-- TOC entry 1880 (class 2606 OID 285385)
-- Dependencies: 165 163 1874 1891
-- Name: STUDENT_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "STUDENT"
    ADD CONSTRAINT "STUDENT_status_fkey" FOREIGN KEY (status) REFERENCES "TAG"(key);


--
-- TOC entry 1896 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-03-20 15:47:01 CET

--
-- PostgreSQL database dump complete
--

ALTER TABLE "STUDENT"
   ALTER COLUMN name SET NOT NULL;
ALTER TABLE "STUDENT"
   ALTER COLUMN surname SET NOT NULL;
ALTER TABLE "STUDENT"
   ALTER COLUMN message SET NOT NULL;

ALTER TABLE "STUDENT"
  ADD CONSTRAINT "stud_gender_is_ok" CHECK (gender IN (0, 1));

ALTER TABLE "PRACOWNIK"
   ALTER COLUMN name SET NOT NULL;
ALTER TABLE "PRACOWNIK"
   ALTER COLUMN surname SET NOT NULL;
ALTER TABLE "PRACOWNIK"
  ADD CONSTRAINT "prac_gender_is_ok" CHECK (gender IN (0, 1));

ALTER TABLE "PRACOWNIK"
  ADD CONSTRAINT "tel_no_is_ok" CHECK (tel_no SIMILAR TO '22\s+234\-\d\d\-\d\d');

ALTER TABLE "PRACA_DYPLOMOWA" DROP CONSTRAINT "PRACA_DYPLOMOWA_promotor_id_fkey";

ALTER TABLE "PRACA_DYPLOMOWA" DROP CONSTRAINT "PRACA_DYPLOMOWA_student_id_fkey";

ALTER TABLE "PRACA_DYPLOMOWA" ADD FOREIGN KEY (student_id) REFERENCES "STUDENT" (id)
   ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE "PRACA_DYPLOMOWA"
  ADD FOREIGN KEY (promotor_id) REFERENCES "PRACOWNIK" (id)
      ON UPDATE NO ACTION ON DELETE SET NULL;


