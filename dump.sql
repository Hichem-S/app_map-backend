--
-- PostgreSQL database dump
--

\restrict QAl32b9UZnGJxLHcoJZ1VaMYBPO4AqdARpmHM82GTEkItWngv4F2bHDcQNHNcW1

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    parent_id uuid,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: chat_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type character varying(10) DEFAULT 'direct'::character varying NOT NULL,
    name character varying(100),
    created_by uuid,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.chat_conversations OWNER TO postgres;

--
-- Name: chat_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_members (
    conversation_id uuid NOT NULL,
    user_id uuid NOT NULL,
    last_read_at timestamp without time zone DEFAULT now(),
    joined_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.chat_members OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid,
    sender_id uuid,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: checkouts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkouts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid,
    user_id uuid,
    approved_by uuid,
    status text DEFAULT 'pending'::text NOT NULL,
    due_date date,
    returned_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.checkouts OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    color character varying(20) DEFAULT '#6366F1'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name character varying(100) NOT NULL,
    device_type character varying(50),
    mqtt_topic character varying(200),
    status character varying(20) DEFAULT 'offline'::character varying,
    last_seen timestamp without time zone,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: email_verification_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_verification_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    token_hash character varying(64) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.email_verification_tokens OWNER TO postgres;

--
-- Name: maintenance_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance_notes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid,
    user_id uuid,
    note text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.maintenance_notes OWNER TO postgres;

--
-- Name: maintenance_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid,
    created_by uuid,
    assigned_to uuid,
    title text NOT NULL,
    description text,
    priority text DEFAULT 'medium'::text NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    scheduled_date date,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    recurrence_interval_days integer
);


ALTER TABLE public.maintenance_tasks OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    device_id uuid,
    topic character varying(200),
    payload jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type character varying(50) DEFAULT 'product_moved'::character varying NOT NULL,
    title character varying(255),
    body text,
    product_id uuid,
    product_name character varying(255),
    from_room character varying(255),
    to_room character varying(255),
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    token_hash character varying(64) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    category_id uuid,
    name character varying(200) NOT NULL,
    sku character varying(100) NOT NULL,
    barcode character varying(100),
    description text,
    tags text[],
    quantity integer DEFAULT 0,
    price numeric(12,2),
    storage_location character varying(200),
    photo_url character varying(500),
    qr_data text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    status character varying(30) DEFAULT 'in_stock'::character varying,
    qr_image_url character varying(500),
    specifications jsonb,
    department character varying(10),
    classroom character varying(150),
    room_id uuid,
    last_moved_by uuid,
    last_moved_at timestamp without time zone,
    tracker_active boolean DEFAULT false,
    tracker_lat numeric(10,7),
    tracker_lng numeric(10,7),
    tracker_battery integer,
    tracker_checked_at timestamp without time zone,
    rfid_tag character varying(128),
    ble_device character varying(50),
    purchase_date date,
    warranty_expiry date,
    end_of_life_date date,
    low_stock_threshold integer DEFAULT 1,
    tracker_hashed_key text
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    token character varying(500) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    department_id uuid,
    name character varying(150) NOT NULL,
    type character varying(20) DEFAULT 'classroom'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    room_code character varying(20),
    bloc character varying(50),
    floor character varying(50),
    capacity integer DEFAULT 30
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: scan_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scan_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    product_id uuid,
    scanned_at timestamp without time zone DEFAULT now(),
    department_code text,
    department_name text,
    action_type text DEFAULT 'scan'::text NOT NULL,
    action_data text
);


ALTER TABLE public.scan_history OWNER TO postgres;

--
-- Name: transfer_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfer_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid,
    requested_by uuid,
    from_room_id uuid,
    to_room_id uuid,
    status text DEFAULT 'pending'::text NOT NULL,
    notes text,
    resolved_by uuid,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.transfer_requests OWNER TO postgres;

--
-- Name: unregistered_scans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unregistered_scans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    uid text NOT NULL,
    scan_type text DEFAULT 'rfid'::text NOT NULL,
    room_id uuid,
    room_name text,
    reader_id text,
    scanned_at timestamp without time zone DEFAULT now(),
    resolved boolean DEFAULT false,
    resolved_by uuid,
    resolved_at timestamp without time zone,
    product_id uuid
);


ALTER TABLE public.unregistered_scans OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password character varying(255),
    role character varying(20) DEFAULT 'user'::character varying,
    avatar character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    phone character varying(30),
    google_id character varying(100),
    email_verified boolean DEFAULT false,
    last_seen timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, parent_id, created_at) FROM stdin;
5e3facda-bc8a-45c0-89f9-a2e9619a8483	Computer	\N	2026-04-29 03:47:05.609986
31e68055-dc19-4443-be27-379bb0ccf415	Server	\N	2026-04-29 03:47:05.611597
cccd9b9f-9c10-4c4f-a2c3-df05dbe501d4	Network Device	\N	2026-04-29 03:47:05.612401
8964a2a7-76cc-4dc7-b528-4e84c1f481f7	Peripheral	\N	2026-04-29 03:47:05.612937
b1a1848c-9cd7-4059-8c46-e3d465004ffd	Printer/Scanner	\N	2026-04-29 03:47:05.613539
ddcf58a3-334e-450a-8b02-94bff92dc805	Display	\N	2026-04-29 03:47:05.614022
893b34c8-6d78-46c3-809f-09b9c6b98ae0	Projector	\N	2026-04-29 03:47:05.614459
db9ec470-34f5-42fe-949e-deea6aa1ad5f	Machine Tool	\N	2026-04-29 03:47:05.614906
\.


--
-- Data for Name: chat_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_conversations (id, type, name, created_by, created_at) FROM stdin;
f496e18d-cc97-4e2a-9c9d-0a026c4f24d5	direct	\N	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 05:45:13.218707
\.


--
-- Data for Name: chat_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_members (conversation_id, user_id, last_read_at, joined_at) FROM stdin;
f496e18d-cc97-4e2a-9c9d-0a026c4f24d5	446964eb-e597-4719-a13a-5cecdfa25567	2026-06-17 05:45:13.220609	2026-06-17 05:45:13.220609
f496e18d-cc97-4e2a-9c9d-0a026c4f24d5	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 05:45:18.137197	2026-06-17 05:45:13.219837
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, conversation_id, sender_id, content, created_at) FROM stdin;
35bd5ae8-61f8-437c-adc9-b57f386aba53	f496e18d-cc97-4e2a-9c9d-0a026c4f24d5	ec047e43-2773-4e39-ba1f-cada9466b508	hello	2026-06-17 05:45:18.134503
\.


--
-- Data for Name: checkouts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkouts (id, product_id, user_id, approved_by, status, due_date, returned_at, notes, created_at) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, code, name, color, created_at) FROM stdin;
284a5d6f-f53e-4db1-a426-a42b44667090	I	Informatique	#3B5BDB	2026-05-01 11:06:14.452204
4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	M	MÃ©canique	#F97316	2026-05-01 11:06:14.452204
d57638f6-9cd2-4a2e-b158-0875d86e0743	G	Gestion	#16A34A	2026-05-01 11:06:14.452204
9200e91b-0130-4491-bdf8-02ea21537b45	E	Ã‰lectrique	#F59E0B	2026-05-01 11:06:14.452204
f3fe9a51-589c-4df7-9360-2be438877be0	TC	Commerce Techniques	#00BFA5	2026-05-03 08:45:19.55534
5e9026cc-cdad-40ea-99a9-2049a728a47e	ADM	Administration GÃ©nÃ©rale	#7B1FA2	2026-05-03 08:45:19.55534
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, user_id, name, device_type, mqtt_topic, status, last_seen, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_verification_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_verification_tokens (id, user_id, token_hash, expires_at, created_at) FROM stdin;
9567998f-42e2-447a-9696-e262a1269113	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	a4f85840ee92f122f1e3779f158a478cf2df9528bdd56195563e5e1b2e4fe162	2026-06-05 07:40:04.577608	2026-06-04 07:40:04.577608
ac38289a-88cd-46f0-b70a-97d595385456	2433723f-63cb-4d0f-8f4e-36b39d806c4b	355e330ce34cf39daa68276762d187f0845abd3c020d99285758a683e0057531	2026-06-08 21:16:54.102764	2026-06-07 21:16:54.102764
\.


--
-- Data for Name: maintenance_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_notes (id, task_id, user_id, note, created_at) FROM stdin;
848a382e-ff7c-4fe1-b3d0-01c4aef13449	6449763b-c5b6-4193-92e8-9ebba133eb44	446964eb-e597-4719-a13a-5cecdfa25567	hichem	2026-06-13 05:48:07.18189
\.


--
-- Data for Name: maintenance_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_tasks (id, product_id, created_by, assigned_to, title, description, priority, status, scheduled_date, completed_at, created_at, recurrence_interval_days) FROM stdin;
2cf4c2bd-714a-4d8b-95e4-88cf09d48cab	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Replace battery	\N	medium	done	2026-05-31	2026-05-31 11:14:43.971619	2026-05-31 11:14:35.114248	\N
6449763b-c5b6-4193-92e8-9ebba133eb44	f68c0de2-f37e-4610-90ea-2ddbeeb99476	ec047e43-2773-4e39-ba1f-cada9466b508	\N	replace battery	\N	medium	done	2026-06-02	2026-06-01 06:59:57.922381	2026-06-01 06:59:29.416348	7
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, user_id, device_id, topic, payload, created_at) FROM stdin;
af8eef25-a203-4d7e-bb88-7eb511c7cc4a	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "online", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:16:33.542149
615db1c7-b293-4c63-81a5-6a8ea89dd33f	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:19:10.759536
6cd24390-d38b-4700-b27b-74d03ea3d0fb	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "online", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:25:03.795587
5cbd474c-b3f9-44ee-8785-9813a478a4d6	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:25:12.985817
09acddf7-189a-42cf-8a5e-e208e258dcd7	\N	\N	inventory/rfid	{"uid": "44:7E:D1:E9", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:25:22.63762
818aa341-1a34-4c77-b619-bb0822f03d32	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:25:27.039033
4642c506-add5-4f3b-a50e-8ce8fcbee2b3	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:26:12.810143
36f9ef3b-9ac7-4c38-9ba2-f1879b54ca06	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "online", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:08.414971
615c875b-9485-4c40-8bc5-d5c7dfc1ff3e	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "online", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:27.845317
05d33f18-6254-4b81-a68b-5a701b3e007e	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:30.679108
d2df75b3-22b8-4f29-b9f4-718a165efcfe	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:33.57992
ba888d49-21bc-40aa-9648-ca9059b68c11	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:42.820735
d915e015-6f91-47bd-bc9b-d40013671148	\N	\N	inventory/rfid	{"uid": "44:7E:D1:E9", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:49.068953
eb8ba821-f52a-44d7-8478-d74ea9ee6687	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "paste-room-uuid-here", "reader_id": "esp32_room_I1"}	2026-05-23 16:27:58.794129
fec571a8-f95c-4eb2-bd62-dbbb89839b1a	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:33:15.772939
9ae4308d-c632-4f7a-9520-923400a6eee1	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:33:34.603661
3804afb1-6cf2-4068-b516-f2fb6d78d607	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:34:10.098317
1c377f15-0f2f-4167-90f2-a8930f39b97b	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:34:20.122044
37ac8da9-e488-481c-918b-5d721de88c55	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:34:32.705586
ec937027-6dab-4736-9545-5305baa0e7b8	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:37:01.945877
f06c5efb-0bcf-46bd-9b4e-3b0ff27b6c24	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:38:06.741301
88b02e2d-1cab-47d8-897a-e831cec35fda	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-23 16:40:08.492568
02a99fee-72cd-4e3e-8638-9352c0c3957c	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-23 16:40:15.018994
dd850903-36a5-405f-be71-def1817d32f1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-23 16:41:31.672185
4d449373-9507-46d6-a147-5b75d0df9edf	\N	\N	inventory/devices/esp32_room_I1/status	{"status": "offline", "reader_id": "esp32_room_I1"}	2026-05-23 16:50:18.255669
b55a85eb-de09-46dc-b345-9cb9c1b7d061	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-23 16:50:18.25615
fb8272a2-8796-4330-8397-769f1583a04e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:23:15.560561
76f560af-30ad-4f0b-8d4d-7ddffeaac563	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:23:30.762919
b39048cb-ef4d-410d-8925-72562e2c2793	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:24:15.357114
75b9d972-5aa2-43ae-ac93-8f6f5ddf05cf	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:24:15.382907
45ec2b25-0e20-435e-b157-f619d5deaac3	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:25:54.334753
c17e9ca8-361e-41d5-96e6-bdecf72c29ad	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:46:07.702087
bb09da1e-13fd-465c-ae19-e719322bbb04	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:46:07.72208
74934bbf-91df-49b5-87b3-4913efcf977b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:47:52.863974
76a011d1-5767-40ac-b79f-71b2bf6ec305	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 05:47:58.885171
0bf532d9-34c4-4d36-984f-21409cadedfe	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:30:47.478335
37c77893-9147-4845-9588-ed8a5cc5dc73	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:30:52.416608
fd47e6e4-7613-42dd-9409-8bf6d8a2e0da	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:37:13.919311
1af3f9d8-01c1-4789-8b95-098935b5e3f7	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:37:41.504223
1fdf3a02-0a1d-43e4-8763-1eb4468f938b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:38:23.635231
0a788332-b3b5-4591-af3e-5f5b57784209	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:39:08.245833
ef5195e5-6182-43e5-80ef-4be29a98820d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:39:58.308306
5d0dd97e-a4ae-4f63-9542-d888ba08fa66	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:40:30.30537
8b8adc66-2fc6-4c1a-a57d-1ca5b285ef08	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:49:34.670881
639c5a07-2597-4371-896b-5f00f8105073	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:51:28.963222
36e16f2e-a30a-44e8-a1c6-38fca202b886	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:52:02.064454
b4f5dc73-9966-4baf-b470-67a32aa6928c	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:54:31.694964
696b74ac-1487-46df-9e32-7558dea75e6d	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:54:33.799947
ad78fb7e-bb84-4165-adb5-58eb870908fe	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:54:41.985627
ee549a51-3846-418b-b623-43cdac4f8331	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:54:45.118714
e61eaab1-493e-43c3-987f-9585599b8cf3	\N	\N	inventory/rfid	{"uid": "44:7E:D1:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:55:01.646274
dc37a846-caca-4f0e-85f1-5a8bd32393fd	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 08:55:12.090523
359bb862-f331-4e9a-b317-fc860f19b315	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:11:48.162329
036f99ed-8eb0-4f1e-9fdb-b8a9b9b4f80b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:12:12.463582
23059c5e-2ff7-4009-8487-cd9e887d3372	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:12:20.046235
f0b69eb1-52e3-4cd6-93b3-cdc1effa1ca1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:15:15.680775
5408a210-0479-46ab-a35e-fb9049a9e0b9	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:51:46.031469
a6563fda-7f91-4a7d-b590-a83b48518724	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 09:54:23.850985
60cdf5f5-5577-4204-a842-0b4b5758f6f3	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:12:39.88938
9e29f785-1c53-4f95-b486-aec2b52812ad	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:23:53.782413
c74e4754-c12e-4997-a7e0-a8f59b677b36	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:26:42.770493
31ac8039-cb53-4e92-9ddb-52438a82bb5f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:37:34.377212
0ac6f4aa-4640-4fce-8f52-0eb5a7c2fb14	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:37:39.218976
5c1efdc2-9565-4726-897f-65b159ce4f7c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:37:39.690444
395658a6-fdfc-4665-89a8-2861582160ec	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:51:36.045627
bb16011a-23f1-4077-aac9-1b1057638bd2	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 11:51:54.553272
e8a15cee-4d9a-43c9-89f5-8edb37f6d520	\N	\N	inventory/rfid	{"uid": "49:A2:1C:06", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-24 12:22:49.06563
ef5a370f-8efb-405a-8cc8-44fbe3860e65	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 12:39:10.763364
0f2f4e5f-efa3-4e78-96eb-054cd99da8e7	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 16:40:59.683385
0091a5ed-ef57-4deb-8f0d-d23e7d0cdab5	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-24 16:46:51.422451
bbdfd234-2ed5-4a4f-a506-3444e3f36655	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:30:03.099241
a3156cc2-8c6e-46c3-8a99-de433bd20729	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:40:14.378352
f9849eef-9512-4aeb-8feb-4f0dfca8886d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:41:38.295964
0ba752d3-0041-4b2e-aed2-93e7f9383b4f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:43:48.346582
9f73ac3c-32f4-425e-ba0f-34330f7cbcf9	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:45:08.958628
527aa2a7-d72c-4f12-9915-c2a23ec7eb4c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:47:19.402761
99ae1859-eb17-43a2-ba12-63fed863ed19	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:47:29.351046
5b7ec9e9-e43f-4ba7-9a26-79cd2ec4c3cd	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:47:45.261649
0325e3a8-3f06-4412-9fdf-1e308c1aaa01	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:47:52.346044
b918302f-b3a0-4d7c-a245-fc29a222be22	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:58:10.430105
dfe0a42b-bf38-40de-98b5-cd40122148bf	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:58:15.378011
48b1cb7d-fb1c-41cd-86ea-20967f50b0e6	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:58:52.383697
3753d912-cee1-405f-9ab0-b1ad309c63c1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-05-30 15:59:41.56909
755b0177-81f5-43c2-be9a-f0861bcbcc21	\N	\N	inventory/ble	{"mac": "cf:d5:ff:48:22:5b", "rssi": -76, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-05-30 15:59:53.922897
c0dcf4ea-046d-401f-9b88-75fc62ea0726	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 15:59:54.536262
0438921f-0928-4b9c-b7a7-37948c4b78f4	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:00:07.756023
25b3cf81-7925-4f1a-971b-d34c5f1ca633	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -76, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:00:08.779102
c33f1d2b-2595-458b-96b4-55b9dae1f31f	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:00:22.593986
d58e1583-dfed-4f93-a63b-6690f0924110	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -74, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:00:23.720243
bfafac19-c18d-4dd5-a9a0-5e9cd2ea2e32	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -71, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:00:37.748635
ed8e0a47-1da6-45ab-93c4-a3082fa8164f	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:00:38.6707
d85f0e43-ed27-46ee-975f-b8d4bd454e40	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -55, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:00:53.928451
cd494d94-d2eb-4f24-8a73-5bfc4cdb31dc	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -70, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:00:54.746931
12005248-1f38-4e3a-a439-dc344a89b702	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -74, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:01:08.691923
2a89382c-6eb5-4277-9c16-75df44275a89	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:01:10.834205
974802fe-be0b-46ea-850d-1f73b307959f	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:01:22.907437
8dfc7f74-b4d1-43d0-9bbb-77172fee05be	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -66, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:01:24.758864
fa371654-e7cb-4407-b8f8-4459f5aec3e1	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -66, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:01:38.789345
27554dc7-abaa-4e1c-b21e-e41edcf12231	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:01:52.91811
5979be3d-c12e-4b03-b376-8fe1302ed131	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:01:53.128293
bb157213-17bb-489f-bcab-bcdad60fc6a8	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -63, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:02:11.043457
2093f978-6ac1-4db2-8f3c-ab3f283ad5be	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -80, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:02:22.921646
87df8712-b979-4b93-b436-28b3c17318c0	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -64, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:02:25.071956
98b25b9b-e44c-424d-8f1a-92cafd02fa6b	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -66, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:02:38.418044
77652205-5b5a-46a9-936c-6d50b843be8c	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -68, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:02:38.907159
baa92d0e-2582-47e4-9adc-9fd7e01abb5f	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -64, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:02:53.539896
4d269746-7752-49ae-a88c-0dc8e16c69db	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:02:54.972456
4d82abc0-f7d1-4011-993d-1aeb72592cc5	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -70, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:03:09.001304
7a33a030-e93f-4bce-afa3-768c49e8bd02	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -61, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:03:09.504042
08510ad9-5a95-4845-9df2-9c1b7c4ecc3c	\N	\N	inventory/ble	{"mac": "d1:06:c6:91:f8:b0", "rssi": -76, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C001219001B016B3B9FC60A32E5"}	2026-05-30 16:03:23.029795
c026ce80-b2ce-407b-8a83-c9770b316fb0	\N	\N	inventory/ble	{"mac": "f2:13:63:2e:ae:3d", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020002"}	2026-05-30 16:03:23.541542
e77e862c-fe5c-4fa8-a70a-a1fad4391fdf	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 16:03:46.377061
deb1aa4f-0759-40cd-8d22-b54622f5c7fe	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 19:49:14.133022
2901cdd0-f7d7-4d6e-a496-67ff1673c0cd	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 19:49:48.619636
22e02b61-01b2-4e01-bf67-e51fdfaf3613	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 19:55:22.939846
25440603-80f5-4244-a2aa-6933c08bc5b1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 19:57:23.442873
e39168ff-6c86-46b5-b47b-260622db49f2	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-30 20:00:43.573961
63702f0f-8c82-491f-8dda-f4048cbd6ece	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 11:13:21.368256
1ed833e7-4847-42f6-9793-632588277b9c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 11:44:57.131909
bf898cee-8f20-4b34-9a4f-8fd106a06aad	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 12:52:50.299451
fbc0d453-d169-4e2f-acdc-5aff6961ece8	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 16:38:11.364489
e29ab3e4-a19e-47ef-861d-a43674faaf80	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 17:18:24.143558
ef5a350d-263b-4270-84df-1792132d5731	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 17:22:00.935693
d75dad35-8c29-480c-b85a-13a3e6b4fa11	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 17:58:32.478094
f13caa1b-d231-483c-86d4-013f6116f3f1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:01:54.603255
4c0631cb-85ce-4fa4-9b94-775881ce69d8	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:06:02.536
1ec14154-5470-44c6-9271-2bba7717005a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:09:09.0422
4f361838-e021-4572-9ee4-14c8ed8a615b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:14:25.366573
423bd42a-e4aa-4c87-b704-f68c4ff6f782	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:16:29.095846
089fd722-2b6a-4114-ad9c-9bb8001db3e5	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:19:03.85933
3fb003be-21cc-46c3-9acd-0b77ebc75941	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:19:22.465329
7b97cf7b-e802-41f2-aeac-89c1b9d867fd	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:19:30.162453
ca3d0aee-7a7b-497e-b168-120c075c76ea	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:19:51.670663
1e553ad2-1e04-4d5c-8257-fef45d8b7706	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:21:05.74907
8d2f61c7-018b-43e3-8fb7-744467302e8b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:21:15.018971
34392f43-0c5f-43ac-8d42-41b55f3fe853	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:21:44.210686
3c04a52b-c526-442c-aff9-0137faa39c96	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:22:17.725403
cc10a957-f3e0-4b8e-85b3-095fde0f1866	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:22:44.506773
a6405b99-511a-434b-b5a9-40c4311fd85a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 18:22:55.971843
4826b4d3-ff70-437d-abd9-1e6d1470d308	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 19:24:46.041834
d671b66b-5126-49b6-8316-696b87887fea	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-05-31 21:10:17.410692
def508aa-17b5-448f-a881-bb65429f53e3	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 05:47:24.681537
a2084d26-70ce-43b7-b2cc-6c59e1f3cc55	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 05:58:11.619831
bd4b84c2-42ef-44f6-959c-8dff1ef2bf45	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 05:59:42.838038
bc655f04-30dd-449a-88fd-e572a1d807cd	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 06:30:04.203695
5530246e-73c2-4a60-8198-407ffb658b5b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 06:39:20.290391
c1b874ff-303a-481d-baa2-ffddce7c2263	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 06:51:49.444079
9fe5b32e-2c0c-46bf-ab29-0941dfd41caf	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 06:52:47.475982
8939ad51-6c23-44f6-971e-35519a8ecf36	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 06:52:57.16549
f47507b9-e61e-4bc4-8492-f225bee5a130	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:15:47.581461
67ef20b9-616b-4e94-b486-b6028e7b4979	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:16:17.819072
b220b3a9-a1f0-4319-ba91-8d7ac74f4262	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:16:26.410972
3c255ee7-593a-4551-9478-02341707187f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:16:40.762557
223da211-b35e-4cf5-ba56-15a7d433d563	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:16:53.290465
3143d639-f487-4f01-9795-ac3d8b2d885b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:24:45.098749
3bdaf694-07fa-4db1-8896-cd9c224af4fa	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:24:58.872538
19e95ec9-c465-4141-9d0b-0a16abbe6ac3	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:25:55.71363
f4a48229-bfce-478a-b3cf-813e6d87a3fe	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:26:21.707954
d1a33a3b-1d08-42c7-9bdb-38096983896a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:26:30.250409
c652751e-69e8-461e-903a-1e6d1476db2a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:26:39.565647
93150fc7-57b8-4fa3-ae13-59eee7282555	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 07:43:18.177891
6040a51d-a91a-4688-8192-053d6a74de65	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 08:31:43.760984
b44dc1e3-3492-4507-b6bc-20b5ddeed7e8	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 09:44:21.701737
183e5eaf-b286-4e97-985e-470cb4a7259a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 10:47:41.196245
056502c3-feee-4e3c-a115-a562fb3a296d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 10:58:47.2394
05701e12-e731-4109-9e67-4c0687de81b7	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 11:34:40.614353
30cce48b-5a23-48ff-a029-ac2b27a553a9	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 11:35:01.392181
41955f77-1bf5-416c-9ad1-1c13238ab087	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 11:35:18.816087
32c748ec-883b-4b73-90e5-c0f27821ac9d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:02:00.191988
93fb3ead-0be5-46a8-82a6-be2a7cf149f1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:06:02.945012
43e2f56f-6707-41df-b290-9ab574cb1e78	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:09:00.10157
8d17647f-631d-475b-89d5-cbbe9836c5c6	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:10:36.871495
cbfc6a0e-ee1e-4ebd-a709-5d12609f87bc	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:10:49.457932
02feab02-0888-40ba-8b7b-6cd65e3f7a6c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:13:59.049592
9b807799-4dd1-4cdf-8bf9-45735eabdbe3	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:14:16.723352
abfdddd4-ecd0-418a-a53f-9dbf704967d0	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:14:48.532356
f1999f84-36a3-49c4-8f81-67d34a2e30e7	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:37:47.16547
9069f7d4-da37-4e6e-9589-c548599f78f1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:38:11.619078
df3177ad-86b6-4f8b-9a83-2e303d1c8bcb	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:38:32.463489
c5a6b749-7b94-4b0f-87e3-c979b4e6dd8a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:38:52.1877
1ecdb384-4a8f-4fa3-b114-bd643bb461ab	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 12:46:11.275449
a342beb3-fa00-4d1d-bda6-3ab7501b5f31	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 14:50:25.86151
38788d70-3105-454b-a1c7-cdec27d10375	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 16:55:05.357593
7d218b74-d458-489c-90d1-71ddc844a113	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-01 19:33:38.512413
a9b4fbeb-dd54-4544-9af4-2a682ccbed99	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-02 01:27:49.714909
938714b5-933f-4080-8088-a37fa661e749	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-02 02:08:32.892574
743cd4b6-1027-4916-83a3-b857aeb6e80f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-02 02:22:39.147496
f8b42144-1149-45cd-8459-eb0fb7b95b44	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-02 04:43:30.529404
9737bbcc-343e-4fcc-8a65-370522bc5494	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-04 06:36:50.607645
97ec1a6b-a44c-4d7a-8cbf-6e1bf0a2aad8	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-04 06:39:17.815168
8b78444e-1457-4083-9112-181c43b74fb4	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-04 06:40:15.46731
fdf7b1a2-1dc0-40e6-a705-a9818a0d7556	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-04 06:40:26.994982
4bd33b24-03af-4d68-b67c-524fb979c5a4	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-04 06:45:09.014206
d892e6e2-596d-4e0b-9154-cbf808e15783	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-04 07:53:06.212171
b30da4a4-4002-425b-9cdb-74f3a48fc733	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-05 15:55:22.187021
1179f960-2393-48e0-b658-b224a1d27f53	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-05 16:08:55.921846
c1287ae2-9187-41fb-a032-fd265cb9a6ea	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 04:32:48.967374
488e3db2-0659-4278-84e6-03321737d82d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 04:36:04.017617
f172a4d8-75c2-4e12-8d6c-6b922f654264	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 04:37:26.63177
bce041f7-9814-4ead-9984-52023c30f18b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 07:27:37.855958
aee6c674-99f3-4fe9-bf23-363a6b8ebb21	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 07:59:55.012776
f24dbda5-f73b-4dd6-825e-1d00c4c14837	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 11:53:38.746749
3fb049c3-f0df-4d1b-9a54-62a81bc9e1be	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 11:55:14.585309
580dd489-24aa-4acd-8c0d-41df9cf783d7	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 14:15:03.999635
f56421c1-4405-4461-abf4-3a8f3795c393	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-06 16:44:17.376169
23274072-8afe-4b76-bc76-d3476d5abc14	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 15:42:38.350494
2853607a-fbb4-40ed-9572-081970bf60ef	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 18:38:19.528421
ca55f705-9e52-4899-939d-c7f07af3c318	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 18:58:55.725288
52a4123c-b0ca-45f5-b80d-90c3cc1315b1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 18:59:06.172406
4a687abe-57a7-46aa-ae97-ec9af00452a1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 19:26:07.658919
54f206a8-a68d-44da-a8a5-ba157303c58d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 19:47:36.341996
22656ae7-e193-4515-90aa-24428af16140	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 19:49:20.337695
fd6a21b7-62ff-43f7-9fcc-2eb0a154c53f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 19:49:30.13126
120bd663-9370-4fa4-877d-38ab2a583125	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:06:20.326416
521408b3-6d78-4af8-a978-b341309385ea	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:15.939578
597af1e4-cc82-4364-bc4a-e50c4e9aae83	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:24.623562
95b3a6f4-dfa6-4def-ac0f-2ac04353cec5	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:31.702445
5290ed37-4896-479a-bbf8-d3dc8a9fb4f9	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:44.706227
344eec85-8a97-4e57-a899-e5b6a3450f92	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:50.67894
56ee6c75-4198-4efe-81ef-d7812fa8fcc6	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 20:13:58.209515
903a1dd1-7168-48e4-9562-1b0c7d7536cc	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-07 21:38:57.888164
cdf6d1b5-7c05-46d1-8dad-208ebd2cec6a	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-08 05:04:15.818257
77e02416-1f25-4c40-8b04-87a594a73a9e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-08 05:11:15.7419
4e221025-b898-4d65-975f-e6b55b9a1057	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-08 05:11:30.884472
98013cdc-86d7-4389-99f3-8630cac64185	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-08 05:11:38.566419
e38b853a-41d7-4d58-a219-35c708fea05f	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-08 05:11:47.989601
41d8d961-7d5c-476d-b8a3-365db0be7321	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-08 05:11:54.741108
b65999ac-33ba-47cc-8c10-9344a69a7b4d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-08 05:12:53.554349
0ceb3cae-b17c-45b6-b2e0-bdcf1df4ab14	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-08 06:23:29.917042
39a7ba04-feb2-4329-8d26-1f908d34b3d6	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-08 06:23:29.973794
c95cd0cc-459e-4daa-a84c-19bc926e9a7f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-11 16:53:08.198691
8a408e65-7d22-458c-a230-bfa7d1a48fed	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-11 23:35:32.718337
504f6fe1-161f-4bbb-ae13-35de331f3608	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 04:30:12.234454
fe261370-5970-4222-a34c-88f83a10f737	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 04:30:12.251094
55520a99-c39b-4fa6-b4de-28cd4262df94	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 04:30:12.359915
e449f93e-7471-484f-ac77-c5ea66b891eb	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:30:32.486379
fabed312-f24c-4218-8fc5-6a25786ac873	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:30:32.688072
4ec937a3-3e85-4254-b4ec-c29810a34975	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:31:02.593213
36353233-dba8-4ce9-9f07-694a88a4b3b5	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:31:02.619343
ee57bc20-756f-4e42-8d27-462fd23a257a	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:31:17.640673
8db0bbb1-09ff-453b-a7f6-ab257eeb2967	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:31:32.591076
6dfdbe9f-8a0e-4c18-b0e4-9e4ad8a65bf1	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:31:32.646004
5a43e395-399e-49b1-9d04-8d6a251f201b	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:31:47.650712
31c9017d-6276-4435-9011-2217edd531ec	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:31:47.746705
49fc8bd8-04cd-4c81-9b2b-33cce8683528	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:32:02.607254
a272a789-d64e-40b7-b6dd-aef6ed670cd1	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:32:02.718237
b1513b12-4a88-4850-af9a-32942d25e0ea	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:32:17.629273
726912fa-6025-4ab5-8249-98865279c78f	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:32:32.649201
6c9b4ee0-3865-4b9f-a9ef-eaa0f2e8d2e5	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:32:47.75147
d23de262-0fbc-42a5-8a70-9efbed3bd970	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:32:47.956296
8f80bff8-047b-4709-aa4d-47ef5f16e2e0	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 04:33:05.20501
5cc205d5-c010-4fd2-a70b-391fc3cbbde6	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 04:33:05.207598
e0d0cf77-0690-4626-bbf6-ec0f8881a1e0	\N	\N	inventory/rfid	{"uid": "72:1C:77:5C", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 04:33:10.258282
88169e78-d430-47bc-ba4b-e49a43d06263	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:33:10.323821
43dfada3-b283-4c0d-ac6b-61aac96dcd19	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:33:10.350189
b19df517-0452-455d-9ae4-1b777ae44e36	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 04:33:10.350796
b668f25f-75fe-4cf2-a4e8-a9e629bdcb1b	\N	\N	inventory/rfid	{"uid": "72:1C:77:5C", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 04:33:25.332596
5113d4cd-14ce-4b5c-9afc-fb8da8dc5265	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:33:25.43578
96f21c96-cbd4-4e42-97c1-d67ce15556c3	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:33:25.436191
4f16373e-c6a9-4577-b620-c6e8f1156d0e	\N	\N	inventory/rfid	{"uid": "DC:D4:4E:06", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 04:33:28.681077
1bda35b8-d783-4b8f-a166-a4da75658949	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:33:40.38515
4c92345a-2852-45b8-b7e0-91bc9629ec93	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:33:40.589709
92311e99-215a-43c1-8f72-c21a3a9a36cf	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:33:55.312671
7ab52863-a5b9-49f3-a529-897cac89a503	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:33:55.368351
faf7b40d-5eb5-4438-8028-56eaa67eee7a	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:21:59.364367
e05d2e3f-4651-400b-bca9-fda528784b7b	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:34:10.38835
14524481-8132-4189-9284-081b3b5a5b51	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:34:10.592182
c41a28d8-af25-437d-92ca-e523cda20d3d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:34:25.355547
1550d824-2b1a-498e-af50-22a5d9d3b279	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:34:25.403531
34ef2046-aebe-4379-be0e-c2e6d7660053	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:34:40.381083
22b049ca-e6ee-4b9b-b121-b4d5a7d1df3f	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:34:40.494141
91ddd3ed-b0a3-4c06-bf94-82f2f13c0670	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:34:55.398877
7e703373-b80c-416e-b13d-bb413ba39031	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:34:55.458861
5cd8defd-8b3d-48a8-b52d-d7ad1448e71a	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:35:10.495728
4d6bae07-f2d7-4a80-8041-edfef4ae588b	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:35:10.700694
84441753-094f-4d29-94d5-999e1ddcb9bc	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:35:25.442602
d869712e-f138-4165-9947-13ab0a875e62	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:35:40.459436
d153210e-ce10-440a-973f-00850a7a5a42	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:35:55.480456
d1bcaf9c-7544-47dc-8c77-cda3fb15c630	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:35:55.534883
62addf58-1bef-4df6-bcbc-095b7bc4494f	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:36:10.604011
1d7c0464-02ed-49d3-9720-080933262b3c	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:36:10.808587
8c6b0df7-1497-4c39-8525-f16903c09bd2	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:36:25.55439
c93b585e-4ddc-423d-af4a-abc2c0c65bc2	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:36:25.60759
86270511-02b4-4dca-bf82-b3acfc4a0770	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:36:40.607173
13f1af62-5b5d-4952-9da1-396960864168	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:36:40.710115
e67a628f-1159-4f11-bdc4-192e181bb7f1	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:36:55.566257
bebbcd67-97a6-4225-9b52-622ddb0a8078	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:36:55.664217
083fa2f6-b221-4c6b-a8a1-8cab699db788	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:37:10.609624
04d03379-556b-409e-b9b3-843205f06a4f	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:37:10.664626
9213e847-7011-4acd-9d8f-80d92f305074	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:37:25.609318
7dbec40c-9beb-4c1a-a4cd-59273642b711	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:37:25.665808
b0d6b8f5-86fa-4ec2-950a-f9331c9c9afe	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:37:40.726844
53d70d1d-804e-41a6-95a3-471a2a1ee310	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:37:40.919705
7b3fa226-ec29-4cfc-8956-0b693bcd570d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:37:55.649685
02fab53f-33ea-4036-b178-bd9b452829e3	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:37:55.699999
ef294c9a-586f-485b-9d79-2b236ca3ba31	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:38:10.693376
c0823eb7-305d-47ce-98b3-e013746d251d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:38:10.756134
f3f78416-e41c-4d9e-afc0-b92ca7bd5f89	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:38:25.770559
39edb98e-f3f6-4064-a795-d74303903e6a	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:38:25.975141
081bbd07-1263-4830-ad07-b0edf890374b	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:38:40.712317
32f3463d-5552-4e0a-8ce9-e6ada7b91799	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:38:40.823743
782389f9-09b5-48cf-8a8d-0caa8ab308cd	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:38:55.733032
643b3bf4-f396-4c71-81e0-8558107980c2	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:38:55.78975
f7600967-d7cd-4cb7-93e8-a926e994f632	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:39:10.754366
5b5ccf35-c449-48cd-b97f-ed4aa42d402d	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:39:10.815834
32190d38-c610-478c-a016-e87af540d389	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:39:25.879165
a032f9bc-671b-4af9-b579-c11d9f511f5c	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:39:26.083177
283cad26-5ffd-4d9c-8cc8-4e22a9209935	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:39:40.932198
4b1f08cb-4b0b-4793-9bc0-ea1ebffdbeee	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:39:41.136013
cc136270-4ba0-422f-ae11-9e20e8a5a4e5	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:39:55.88093
49193c55-3f25-483d-9a7e-a3eb950e4960	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:39:56.093068
008d063b-f3b5-4310-b259-120184cef40e	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:40:10.839602
aab67466-5e2e-481e-8412-a37157bfa3bc	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:40:25.884814
0ce46681-8384-4838-b3f6-6bde4ad472b3	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:40:25.939595
2cf295b4-151a-47d6-a743-e146781b9fbb	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:40:40.917413
9270e789-9f8c-40d7-aac1-a6371b1e726a	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:40:41.186038
525ac030-8bb2-431f-85eb-f2c44df284da	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:40:55.912163
3ea5b06a-ac54-4480-8dca-0461da9dbe24	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:41:10.939872
9174c6e4-5fb5-436f-bf38-3046c30e4a79	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:41:10.996093
9412e4b7-b28f-47be-8b53-5d746851e987	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:41:25.992538
88faec17-9e73-4c5d-9e3c-d29cbbb2d750	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:41:26.045459
e1399ba8-334f-4131-a14b-d6c2649bfb68	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:41:40.993961
a5d3f0e1-0723-426e-8c54-328b6a909ae5	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:41:55.995715
a4f8a1de-2ad2-47a2-889b-54663e90688d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:41:56.200035
01fda43a-1b99-41ed-a9e4-b220f0a77834	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:42:11.04836
5442c173-1e19-45c8-8cc2-25b629908c78	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:42:11.100166
274d0e53-2ca6-46cd-9c73-1c74aef26f1a	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:42:26.100558
1622ef86-3329-499c-bc2b-8269a33e5f87	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:42:26.304975
006526bd-067d-4927-bab7-911d0a71bd03	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:42:41.056114
3e86a5f8-a7dd-494d-9a57-100158386d8c	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:42:41.153838
e9bbeb55-1d11-4f6b-93a9-7e55516f3a84	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:42:56.067309
882d7b48-650a-4610-b4cf-2fdcafb0166e	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:42:56.11608
2fd5bef6-9359-42c9-a08f-e3db8527a2be	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:43:11.090275
4a020449-8ba5-4349-b989-f77293cd2f5d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:43:26.150467
5dbae044-7023-484b-8522-c8c3c5c4402d	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:43:26.318011
c4082e78-f051-469f-a04c-dab6fd890c44	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:43:41.363602
f1a86c10-5ede-4215-be1c-95079037f292	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:43:41.569773
e4062131-1d50-4e10-a99a-de24c385c529	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:43:56.153362
237bce43-a3de-4316-923f-4a6ea3515777	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:43:56.206312
a8f3a837-b446-4951-9451-2e92fbcda638	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:44:11.2642
a19ea879-3902-4509-9108-fac3844d6e3b	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:44:11.468508
8b8c1ecc-4f6f-4649-bedc-9db521852d2d	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:44:26.25901
04bcee3f-45b7-406c-914c-557e74d146d8	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:44:41.266912
484c0469-30c6-49a2-8c5d-7cca53f1b397	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:44:41.471925
4d94f548-28d5-4649-a544-3980300e1108	\N	\N	inventory/ble	{"mac": "e5:10:37:b9:d5:f5", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 04:44:56.286158
e6ddbde5-e472-4705-aa6f-de949701c43a	\N	\N	inventory/ble	{"mac": "d3:05:8b:c9:6d:25", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:44:56.595268
da974940-d3b9-4052-ad87-82566295a5c1	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:11.26571
2459f8f0-70dd-4bf0-af86-c2493aa6b6b9	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:11.374012
6b5239a1-d3fb-4f52-ac09-f28c16bb47a4	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:26.274543
ec74e5c6-d200-41a3-91d8-75ebd73e19fd	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:26.337041
77b05f08-f859-4596-8c0a-daea9682d8bd	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:41.381824
196dd299-5827-4214-a666-2d9a471e0a1f	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:41.579476
311d7229-6d23-44f2-a7a7-00aa4e02c4d1	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:56.323836
0afb9dd6-0d30-48f4-af59-f7aa13031387	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:45:56.370912
ac3d8b42-acc2-4a3e-b10d-3d60988b9ceb	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:11.379047
6988569a-4068-498d-abd4-7d54012a660c	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:11.437021
86883480-4ac2-4d3b-921d-b031bf215959	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:41.379022
8c3eaf32-e2ef-4b59-8142-9bd01ff5dc91	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:41.484333
f5cca624-7e90-410d-8339-3a7a5f4ccf41	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:56.399309
2d7e7637-e6b8-47f8-af07-7b7f56c38fbf	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:46:56.450805
0686baf5-002c-4f18-b311-9652247d3a80	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:11.486203
5be51f46-0d2d-4b2e-910a-c0003f073061	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:11.793517
3b112e66-a3eb-45c7-b57a-5c87ddfc11bf	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:26.441858
000aea89-80ed-4da1-b5d9-987564d10107	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:41.462041
e7c562e0-2380-4b3a-b806-1a6d8a8c1f10	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:41.506952
625571f7-89ea-421f-a5a2-9c36bad5cd97	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:56.542738
1a8ac92e-8a34-4e39-80a2-9d0cced49dcd	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:47:56.747339
c5179683-8a67-4288-8d58-3293cd95f5b1	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:11.594648
1733954c-d625-4c29-a5ae-01585b9e7b37	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:11.799333
cb070a4d-a9a8-47d0-8dcb-a1339f4aa2d2	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:26.526349
7af114d5-7fd5-4281-9dae-779498aff05d	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:26.570696
a843d0d2-0775-401e-a230-2c910e70028e	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:41.625423
8d9883a8-196e-4f78-8610-a01cc21db082	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:41.921268
b0e5255f-476c-4f2d-87c0-ed4c63b486aa	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:56.650178
c559570e-936f-475e-b6c5-23fe39e1598c	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:48:56.957158
e85eb047-6d53-4cb4-99d7-74685aa2bc38	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:11.5909
8da1eebe-c4bd-49e1-8266-e1fa88a8f860	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:26.609737
5094c8d8-cabd-4b0a-b56e-55a0e90adf80	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:26.669283
10150a2e-4160-48e4-8a36-f388edae4430	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:41.645781
80b7eba8-6f95-454d-9a47-79c645ba3f49	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:41.909904
b436c8c9-0bf4-409f-9966-2fdb94f828b5	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:56.647595
30e87186-0607-4c9e-ae26-5ffc7ae61304	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:49:56.759653
554bd7a0-4d2a-4680-a619-947e937b5bc9	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:11.709102
020cc485-6b38-4b2c-850d-b4bdd451547b	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:11.769655
3a2b056d-7ca7-4c44-a5d3-0524e8f19c74	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:26.69238
355f025c-c304-42b9-8ae4-e1638b6bf328	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:26.747967
810da6b6-0531-4088-af58-779e52ab0c4d	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:41.814498
b0d462ff-130a-4173-af34-65042958b225	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:42.019071
a6a88662-36f1-4e61-b19a-55b6c608ee75	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:56.733886
3718d571-b018-44c9-acf5-7b95dc63aaf3	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:50:56.783332
c3203f6f-c019-40c8-a554-b4675cb5732b	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:11.817569
3208cfc9-309c-48a2-8962-5e6ba1711e64	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:12.022064
e759c8dd-927d-4df4-9263-638d17686902	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:26.869213
b5ec82f2-a76f-4950-92c1-27d7f9725ca6	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:27.074327
ac0e4dd2-396b-4af5-b7c4-e3e79891a3d7	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:41.819749
0df2a774-228b-4397-9f5f-2d401ebffaf7	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:41.880412
9af4642c-c37f-4689-96ec-16cae2ce0792	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:56.873166
231f5f12-b5ff-4723-acaa-eae5cc9091db	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:51:57.077143
529e1ecf-b29e-42da-b4aa-a521ec4955b2	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:11.848205
5f871dcd-5ea1-47bf-80d3-001f87bbaef0	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:11.926832
226ad310-ded4-4b67-a628-41d48cedd0de	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:26.860142
8fc7ea33-3242-488e-ab2d-e36a6e746ce0	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:41.877645
57662aae-f782-4189-952c-3395ef977444	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:56.980839
9c47c828-f6b0-489f-a4e2-4a79eb6acb6a	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:52:57.288409
945a10a1-45ba-4140-afd2-7f249b461ba4	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:12.033377
30386c35-e3e6-4408-9303-7e6853c47885	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:26.983714
4fe0b2df-3f9e-4f3f-aa5a-2138c9105750	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:27.041393
0ec644ca-e9b4-4e4a-a176-95e55bb3062c	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:42.036336
daa14f8f-b8c6-412f-8f24-6a9513a54e8b	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:42.241043
722e7f41-6ea6-440b-ba5e-22e4dcd1ebc9	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:57.089039
886d03cf-a998-4cd3-bbe4-42a8046ebd46	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:53:57.293857
cae661df-1466-464f-911e-cd9f7aa730d7	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:12.003503
5ef2ab13-0be8-479d-8ea2-aa08148db8a1	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:12.055977
e3c79f92-37e6-4fde-890c-2096b209adf9	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:27.092119
35a2778b-276e-4a6e-b4c4-acf288a6c3f2	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:27.296768
7e72e1bf-3e8a-49fa-bf3e-70f92d65efee	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:42.246722
96f520bb-d7ee-4ceb-b9e7-386b86802dad	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:42.371335
f78a3f30-5949-4764-ae1a-53f35dc555ce	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:57.096709
8bc8a920-f212-4310-9c4b-bb4649bbd067	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:54:57.151573
fe98079f-e62c-42c2-8f3f-c91b25d1a560	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:12.174621
c7f8e098-de1f-4d7e-b09e-8f334c47e1a3	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:27.10661
be46e539-c767-407c-b4a0-f7c39028f26f	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:27.302502
6b715df5-ccb5-461e-b813-5a110fba752a	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:42.151161
12214ad2-29e1-4aa4-85dc-1beeb8483ec8	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:42.217485
f203b8b0-a588-416f-bb93-45d2258b8600	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:57.150566
7948f23e-35a0-4310-98dd-a21e71c4c000	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:55:57.199244
763e24f4-8b48-41f6-80b6-92ff9244ba4f	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:12.16843
c0e8fa9a-2cd5-48aa-9ce0-369cc4d5a31e	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:12.256258
4521c23e-7262-4650-a720-372c8d04713e	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:27.22484
2cf8c07c-5ae2-45e5-a3d8-50a4c7df2a06	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:27.507944
458f8c78-5ee5-4e12-9c87-d21526261021	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:42.258636
d082b7c0-351f-4981-9d8c-75e98baef888	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:57.229147
bac7c2a9-f343-4c16-bc10-7422927cd8eb	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:56:57.278567
e92c5956-976e-43d9-b476-dd15a00394c7	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:12.363974
d6d3a51c-10b7-40fc-adf4-2246debedc14	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:27.269584
260240c6-58bf-4d26-9214-df7064d1199d	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:42.366534
775153dc-9226-4d25-b719-48562ccf9ec4	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:42.571523
90fbabb3-7e0a-4323-a546-73465832c345	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:57.419425
c0196b36-f45f-4944-ba3a-711640edf10f	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:57:57.588732
0dbe4028-533b-4421-aaf6-0a90221cdd3b	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:12.370652
18df82f6-69d9-46a3-9ad8-bdd6cde8bf80	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:12.428512
ce29a30e-a2e0-4d49-a6cf-746aa118ca52	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:27.389459
c42c92ac-244d-4b00-8514-fbf723cbbc41	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:27.455521
d6be2a75-a4df-405a-bb88-11c766c269de	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:42.372274
063ff1bf-ec4a-4992-95e3-48c39dbda003	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:42.423276
9df59513-d64a-4054-a3c5-63833e71819b	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:58:57.425654
5918d8ee-79d1-4cb2-875e-f87ce3d2af12	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:12.413225
2ec0fffb-2e84-4a28-bb6b-423eaac1f545	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:27.530714
ceec455b-afad-4384-97af-31a787e7db83	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:27.735761
6a9b7493-76a5-4562-a93e-14c4eefa33a3	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:42.45303
d3c7d499-4afa-4da6-9faf-64f76a750f56	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:42.500884
8794d245-2491-4767-9011-675800e16dfc	\N	\N	inventory/ble	{"mac": "cd:b4:d8:75:fd:c1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:57.533191
408c8bbe-1a19-4e0e-aba5-5e10b95c1884	\N	\N	inventory/ble	{"mac": "c6:13:5c:d7:03:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 04:59:57.653681
0724d8cc-52b4-4ebf-8114-959c5d83e526	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:12.586345
ab006c15-9def-4674-a218-01d0d23807c2	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:12.79056
a3c7b644-0ac8-4ac0-96cf-a72fa6e822a8	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:27.51571
c834e8d9-2642-4783-bd69-2f619a1d12bb	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:27.563203
524a9da6-5ba3-4796-a63c-464c1209663b	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:42.58893
f585d471-82a5-4692-93f0-bb733a99718a	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:42.641213
607d58ec-c389-4363-84e4-d9907b929c20	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:57.641715
484a90fb-57cd-42cd-a5ae-2a794919b698	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:00:57.745212
580b2c83-d40b-40db-8b8c-9d3d860beb2d	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:12.582516
a46af684-369e-48d2-8cd0-75df60212d5e	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:12.854851
383e7b5b-d0d6-49c1-8e49-389997116b54	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:27.644429
b53c9ea7-318e-4f03-abfd-cb4fd4f8cff0	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:27.854773
c7e0454d-52d5-4b1a-93dc-408efc00d81d	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:42.697568
b97a7eb3-ecad-417e-a206-15332abbcf1a	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:42.901686
7a955284-8ced-48b3-8fdb-9bac4b941847	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:57.642361
86eaa1c4-52f9-4067-9e6b-c07373d60b82	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:01:57.692674
a7e96359-16ca-4adf-91c4-7e02bd530f2e	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:12.81716
81fb31d2-89ff-4ab4-996a-440ac36b0428	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:13.081913
722e5adf-2398-4fc2-879f-39e4db079b3c	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:27.681685
87f9abce-66c4-4419-a095-f5c43db6466c	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:27.729679
c56c31d4-f37b-48a3-b3d7-e9edf8dfc804	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:42.805398
6dd2d958-1e97-441c-bb5d-44c0c0f9f4bf	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:43.010177
fef6e267-f584-49f8-b9bb-e5a2e56ee3dd	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:57.723512
61ee0b10-d1d0-4ba7-a923-65c653907da4	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:02:57.784432
3e398d1c-91f0-41e0-80c3-437d7c5aaa4c	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:12.746313
55f52d27-f320-4c34-92ec-651fee94e5d1	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:12.797242
d65c6cb7-2983-4a6f-9faf-853459a8f151	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:27.76638
8310e62c-e90c-4501-8110-6456b7f3df81	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:27.861515
6206b25a-fe96-4ec4-8887-4446cf8e94e8	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:42.787619
a9cfbb9f-ab43-42cc-a5b4-864905f4b50c	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:42.834354
7ec06184-0beb-4f55-a4b4-a3fd5b940fd5	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:57.818716
d9ac80a5-1f30-40b3-b4e6-c68f95e92b43	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:03:57.883696
d3d42b12-462f-4193-bf3b-47aaa40790d1	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:12.829897
4f71d12f-ef4e-4e9d-b6cc-f0171b093544	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:12.88014
fbe53bda-77b1-4a16-974a-87463c8a039f	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:27.863069
7bece646-ede8-41d1-900e-4afdafcf774e	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:42.92033
d31b1228-58f6-47b3-97fa-7f5824b54552	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:43.123796
e04a80c2-5a61-4e84-936b-a859547d7cd1	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:58.12637
aba5343e-ad80-4357-b899-a3d309251d82	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:04:58.152169
b48f3cec-7d46-4bb2-940b-344a493cecc0	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:12.922521
01cc1746-950f-4b9b-bc8b-51628187ff28	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:27.990372
e8b54dbe-8e5c-46c9-9e8e-11f5b125363f	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -38, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:28.179396
0db0c942-2cdf-4815-b848-eec3f149238e	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:43.027611
3121f1c1-a4d7-4855-b12d-93e7a527df21	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:57.979311
d6543237-295c-4a54-ac98-a79d8a57e6a4	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:05:58.029681
266616a5-b5a5-49d3-b594-6fb5876a8c92	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:12.985351
7efaa9ce-3981-4d11-ba32-c4b35ae49d39	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:13.217167
76234d54-1dd5-476e-a607-b7b408a56345	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:28.083232
eaac3027-b13f-4f30-8ec3-6a8faa7b4589	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:28.288363
73ec3a9b-685f-47a6-8021-6262f57f23ca	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:43.178294
5dbd066f-f267-4cdc-a61a-7276a69f903f	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:43.244361
2539df43-479e-454f-ba38-8164c90a5f24	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:58.086465
71e85abb-893d-415b-9804-b02a27df7336	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:06:58.138988
2fb09af2-0dd2-4925-8eeb-7405deaf0909	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:07:28.090762
3df934a8-8ee7-4e24-9700-6ab7cd178b0c	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:07:43.140931
6b677c0d-f769-43ac-8278-ffac3c44c8d6	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:07:58.127972
eb519c49-f2cc-4f37-97db-5888ff03df05	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:07:58.178477
6f824fd6-3df3-4b70-ac09-a29365817d44	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:13.149158
cd4764bd-c85f-4bde-877b-7ee9430df42a	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:13.247194
1f15bf54-d675-4168-8a7f-655d95b92a08	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:28.198604
77853e63-2d11-4375-9efb-b0a3659311f1	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:43.250081
613cabc4-d11c-4b30-9aba-fd6a59053ef0	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:43.454073
49eebaad-b35b-4e85-9d24-70611684c573	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:58.302146
cc26b006-af4a-4739-b9a1-cdfa54316ed8	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:08:58.507888
b03d2f29-cd82-41c0-8866-a4e99fc70f86	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:13.229424
a98be6c9-6d6f-4c19-82c8-201876390a0b	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:13.289462
8897914a-0202-4f25-8794-57c96f8ac4de	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:28.25548
0d52b9f4-30c0-4749-a89e-d1c778d00b73	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:28.313
14c6b24d-e50a-43d1-8b42-013c247e3f83	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:43.357745
35988ef4-6eb6-4e60-b83f-1d94eafac105	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:43.562766
8af8f44f-7c3c-4397-addc-568d54dbb3cd	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:58.410667
222228ad-4245-4a2e-9eb9-7312c2577f48	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:09:58.717726
5fcf507d-1bf8-4d03-9ff5-b76821b9ce10	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:10:13.312749
7602922b-2ca1-4090-a03a-e4b37f34df60	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:10:13.363965
976bcc50-a2c9-4328-9c16-2844645413b7	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 05:10:38.38178
277ddfa1-fb80-4a0e-8c18-a83e4ef028b2	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 05:10:40.083054
ea674b98-0b7c-4cff-ab97-bc950c0925f9	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 05:10:40.085007
09a6d21b-a692-4552-bbe1-9696d92afb10	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 05:10:45.441557
43b4fb81-6ee9-4f62-b9f5-c4a118aacef3	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:10:45.624557
30392554-1588-4b40-adbb-0a0b8f1c68b9	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:00.469629
a9cb7749-01ed-484a-9604-6145ec37daef	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:15.532981
4f88c61f-d7e1-417b-ae8e-f1508beb15ad	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:15.730804
1d6000a2-e0bf-42ae-ae9d-2d2f4019d9f1	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:30.467045
355ae6f6-7136-461f-a170-854b978fe7fe	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:30.525213
2e7aec25-1474-4419-a36b-b89136c59e1d	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:45.52658
c204e1a4-93f4-4735-9566-10a347963ac0	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:11:45.789392
99443ae5-74a1-4c38-8248-7e21ed737eab	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:00.573046
46c553f0-9963-4022-ae2e-93a10d673650	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:15.506744
9d64a117-e431-4897-b6b8-3a5aa1cbeff3	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:15.802105
c951f322-b7ae-4ab1-abd8-d17200cb2a4d	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:30.575798
c76b7623-c548-45bd-8bdf-cfcf42675fd3	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:30.871219
b7e683b9-d51f-49ae-979e-1ffd79902445	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:45.737048
aedb2eb2-378e-46d9-84f2-1081c0f80e5d	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:12:46.130838
ff95b7e9-ae46-4461-a83e-f9ed5dfd0a67	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:00.569001
9004fe40-bed3-4fc6-a27b-e9f6a1ea7a12	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:00.681968
e166836e-f2b5-4e2b-85bb-d55ec632369e	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:15.630656
2a00ab60-b52a-40b6-ad0b-18f417f3e212	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:15.694918
107aa81e-fd86-4c2f-aea8-e4ec687502c7	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:30.612373
f980e3b5-5b07-42a6-9f51-881e2dce62f5	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:30.666537
0a84ad02-0988-4cc8-80d2-059e7fd0935c	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:13:45.634215
9569bac9-866f-4737-b095-865208fcaa16	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:00.68558
14a29ff7-ca69-454e-ae27-94fe0b8348a8	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:15.738371
86edef06-9ce7-44c9-9288-99d848723f6a	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:15.943042
8b6f433a-a150-4e21-a07a-37ca045ba055	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:30.695516
87030067-a79e-45e0-bfe5-5fe2861d0798	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:30.791478
60a2d979-9678-48f9-953f-32aba9182f80	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:45.741735
9db527ba-8983-4f5e-941a-b1fa33b7593e	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:14:45.806943
5c506229-0650-48e4-be9e-e55f549ebc6b	\N	\N	inventory/ble	{"mac": "ce:c9:0b:bc:32:46", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:00.794008
82de65ac-c386-42a9-8034-7ba066650bf9	\N	\N	inventory/ble	{"mac": "ed:f5:00:9b:a9:2b", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:01.10083
8deb2e84-82f1-4a67-818a-8f1b8afae802	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:01.128698
d7c27a1e-9088-48ce-8a14-33771dd0993e	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:15:15.846611
078f13d1-6f44-4195-9208-ab0d556913a2	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:16.256076
e1033168-3f1f-4813-9de5-40629ba4331a	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:15:30.798066
eaff3190-4634-4664-a095-1a085fd416ee	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:31.01819
6a76916e-d44a-428c-9c55-96e019c26336	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:15:45.805596
417003fa-083d-40ee-b3f7-fb279bb2b043	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:15:45.854709
9c2cce52-a83e-41ca-8108-372985934119	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:16:00.902352
1a5ecf68-3903-42c0-9e98-a3f24e8ff582	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:16:01.106869
cd51161f-a9fc-406e-bba1-1a7484322190	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:16:15.847322
fcc2d43e-82bb-481b-b8ac-dc7794c2a33d	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:16:15.955707
3cb67860-6778-43ac-a1be-252af1d17266	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:16:30.868552
e084aa9b-d027-4ae4-9ee8-9425789d4f9c	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:16:30.929641
7adc30cf-5868-4862-b649-108550c2bcd4	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:16:45.957554
f9286150-cc02-4b13-9a6f-722f82ce6d96	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:16:46.060629
0618a5f3-9f02-4ca9-b22a-34d0a7647450	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:17:00.912086
845182d0-acba-4efd-866f-d7402faf62df	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:17:01.112993
4d322a34-1d31-4670-9f4f-162ee62b0228	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:17:15.940458
43d01895-c68e-4b4e-a469-ea4a754c70c7	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -75, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:17:16.235391
7f74c28f-a648-472b-8263-90c3a47cd3e0	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:17:30.95442
daa96c49-dc14-466f-beda-f666b53c4319	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:17:31.009339
48b720e9-0acd-4c9f-b54d-ae43acd66945	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:17:46.065617
aa980c43-33c0-4228-8dcd-1b2fc3487b4d	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:17:46.270262
a5945520-6320-4256-aa9d-9092a95dfa62	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:18:01.015891
59c0badc-5c16-42c0-ac5c-9e5d882d7ac3	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:18:01.073172
d587a568-2336-4666-950d-1e3cdd038d0a	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:18:16.068354
c6c05d1e-9f5b-4323-bc6a-ad4e20d399f9	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:18:16.273332
94ff8e8a-710a-4868-9c1c-2e6e3fff771f	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:18:31.041398
39c26879-85e9-46d0-9dfa-d3c36764a91e	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:18:46.062458
adef31c1-1232-458f-a758-069417774e24	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:18:46.173961
ff286c7a-0bf2-49b2-a011-df78b2e55411	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:19:01.124023
2d4a3720-df49-4614-bb86-8b174fe91d8c	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:19:01.177928
614164db-b2ab-4157-8c5e-dd3cb173ea82	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:19:16.109196
cbf74fea-b1ab-4740-a998-ef1de415a2b3	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:19:31.126233
c603a26e-40f9-4df2-a5a3-c04f9f1c3a09	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:19:46.14512
fb9b9b31-7170-4149-8cf1-c7cd1039fdc6	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:20:01.221861
76ca3c09-ce74-444e-ac4a-26f799d24c96	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:20:01.515832
c5c60fb1-0977-4b65-a16d-3f0c7b8dae69	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:20:16.187573
facc9d2a-61a7-4c59-a628-3d4f36368a79	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:20:31.237338
80763962-e9c1-4a28-adbb-7dc2853fbae2	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:20:46.264502
f4f603cd-ab6b-4265-9c7a-7da6a0f5acec	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:21:01.243105
14968789-ef6b-4183-b985-874c2e9cc8a4	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:21:01.34093
ef202e4b-57dc-41e0-86bb-c7cdcb98d0ba	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:21:16.290493
5c91d34b-7626-4cdf-9788-dc9dcbd2caf7	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:21:16.356795
e32bfb43-a9b5-4f96-b8a4-f555394bcbfd	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:21:31.34376
88d64beb-638c-4191-9a2f-7465db90b743	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:21:31.548287
19a979f1-b0d6-45c8-8562-4dee057bfde0	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:21:46.395871
ecf98f0b-f6ea-48c2-ac71-bc7d5907241c	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:21:46.600341
7e48b9b8-6a0d-455a-b5c8-8a1eb3b6eef7	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:22:01.345982
8c391b5a-a275-4979-851d-9acdc6fe3498	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:22:01.41146
74d549ca-02d4-4dc1-b866-dc511003fcf6	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:22:16.398545
3eeaceee-b0c3-4e1a-a4b4-e2ecc2d84f66	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:22:31.369743
50231a7a-8e18-4e30-827e-13f743d395c9	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:22:46.392571
c52ee306-2831-46a4-92de-e58461c94d50	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:22:46.504245
dbb98842-a568-4718-b563-ac7819f4a51b	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:23:01.45389
ba3b01f8-7a49-45ff-97cb-04768657b008	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:23:01.514703
feaa523f-169b-4d31-9e59-4c63f8083d24	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:23:16.430398
7d0643bc-e998-4624-b22f-57d5ab40f4a0	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:23:16.507359
4c6486b7-2eb5-4b0c-857e-5bb05f43f013	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:23:16.532249
ff7124ef-da92-4cc3-971c-05b9b5411ab2	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:23:31.559784
c06e5eef-5b18-4968-acb0-5166f93c3a71	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:23:31.763828
e9b978cd-9280-4831-875f-b089d312150b	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:23:46.475839
2c5e3bc6-6bdd-4080-8297-8ea75496dc26	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:23:46.532925
8c2f4294-2826-42a9-9712-d26684ac1331	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:23:46.564187
0d51e242-8eb3-4248-9a5a-8280102aefb2	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:24:01.498342
0587db0e-7361-4d7d-adf5-9d8f6a652e13	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -75, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:24:01.544315
7d673618-2cec-4d8f-9687-4e31f5298280	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:24:01.544656
d3f5aa18-4423-461a-8a98-096abd940b41	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:24:16.520643
5c07f2c6-3379-4494-8c63-994d2f9e7e1e	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:24:16.572132
f5ab6839-488e-47ff-93b0-56e1af81a257	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:24:16.572473
44f96281-355f-4c96-885c-caeeda02386d	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:24:31.541954
3237e1ef-eb06-432b-a759-9c0bdf5fcfe2	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:24:31.594159
4e3b7b79-0e58-4383-8f82-8b0e2cd38a33	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:24:31.594356
f30a00f2-c06e-4eb5-ab0c-149750c47369	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:24:46.5639
49b4516f-7c12-4a1d-919d-99963f709861	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:24:46.619887
3e7d088c-811e-4c8d-a24b-3479d12c3608	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:24:46.620223
a620ab0e-f7ad-480e-8211-96a52e88c915	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -93, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:25:01.670705
bd5e744d-3787-4bde-adbd-a58f81d49232	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:25:01.875587
c68d4a5c-740a-4936-8f87-af114b96f84b	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:25:01.875949
ab8f7475-a769-493c-ad4c-5f692d9b8a9a	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:25:16.620734
834ec1b1-d267-419a-ba60-20a7f74b0f2c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -90, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C001219000B56605016560D0472"}	2026-06-17 05:25:16.927474
7fc2f874-9b71-40b5-9e68-83d31a668073	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:25:31.697502
0df62d1e-66bb-4db6-83c0-9aa0a40c4547	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:25:31.777666
c9d43c5d-05b7-49b1-aeb3-da3c1ce9de24	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:25:46.727227
4c57a3ae-3313-4eca-8344-019593a98855	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:25:46.93737
2b4a6e2a-f0f7-4b6b-af96-3627b4281bf8	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -92, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:25:47.02053
eb02442a-4b0c-434c-954c-178077e96140	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:26:01.778681
1e0a599b-8128-4370-9da5-410b8c25ef36	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:21:59.364858
81a3d0a1-6945-41f3-b38f-003411d81152	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:01.983127
f902debb-8d3e-4c3d-aea8-3c71f522dd0a	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:16.729013
b7e1d368-8076-4ba0-a605-6940f4051b2b	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:16.781295
527e563c-5a5d-4fbd-a166-514791b96fba	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:31.781931
d0af3d66-451c-4dfc-803a-8d1a9cd7f1e7	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:26:32.002755
ddc4e7f3-6ce6-4d49-9ad0-88e58a90035d	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:32.034881
574d60c5-6c05-4b4e-87c6-092c7b754e05	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:46.83442
b90aa104-be05-4226-8a75-96f86254f753	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:26:47.038642
e400fbc8-a5a4-4225-9ee3-2fe667367696	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:26:47.03892
fb34476a-0ea7-4103-a9b5-947aaab3ebdb	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:01.764343
5af1c2db-8f59-4a94-a008-6b0c319c1f36	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:01.816002
5fe4c2c9-3d96-4543-9314-71ae9aedcff3	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:27:01.816374
24907918-e1d4-4640-aa31-72b75ec61755	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:16.787909
4bf2bff0-89cc-4fbe-beb0-df0bf170671c	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:27:16.836876
3a128abf-9a64-46b9-a600-2391b2ade1e1	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:16.837174
eea3af04-8bfd-4adc-84e5-2aa58a77cda6	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:31.812613
7baed2d7-2d7d-407a-8243-2d8199a469e5	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:31.89036
b869c01c-e75f-43d7-ae5b-99790dac6aed	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:27:31.890642
65b0695d-967f-40be-ad7c-1e0969eb610c	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:46.835306
4f678914-b87b-4778-918e-ade3da2cf65d	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:27:46.943213
64fc3f9f-dcbf-42b6-9cff-f2b53b2547c7	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:27:46.94352
176a66e7-6116-428e-80aa-aedcb2fbc956	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:01.892721
4ddadc81-ab5e-45ff-b493-a4f9375e5010	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:01.953986
2aadbf4e-fd14-4943-99eb-58626e5b0947	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:16.945071
8ca753e2-1525-4873-a977-5fa863ea9753	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:28:17.149791
f53f65fb-d6b8-4127-9099-be1b3f6d3ccb	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:31.984243
873c7abb-6aad-4eca-95c3-83cc2fbb4cdd	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:32.407384
b9375d08-a8ed-4525-b2a2-27cd303586ad	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:46.948105
0a17eceb-0709-4804-92be-4bf83229ea4e	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:28:47.010592
3af7ad15-dbd2-4ebe-a504-f42429d2a560	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:29:01.941766
8db32bda-1137-4caa-9db5-eadee35644c7	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:02.001734
7dd1dc49-128e-400c-8ee7-3b40edebd2df	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:02.026436
1c9c0d3d-f0f9-43aa-a9ce-8210aac2dfde	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:16.96323
4d18724c-fb95-40f5-ab69-6da175c7600d	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:29:17.055393
35c0d993-e41d-4f5d-9bf6-9411140df427	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:51:48.624085
899058d5-5614-4734-a54f-aae6eaf7d03c	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:51:48.690054
e2a51074-8fc3-4bf1-bdfc-f42358184dd7	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:52:03.66705
880f0f40-124f-4421-853c-fb0836311aea	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:52:03.816601
f5f9c2ce-cb3a-493a-b2d0-edc143672272	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:52:18.661531
0822c7a2-52f2-427f-8769-7b1eb75eedde	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:52:18.866468
06423208-7c6c-4789-b171-17c61593a6e5	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:52:33.667497
84fd5ea5-4393-4e43-ac06-6a17711be4a4	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:52:33.717929
2050781d-81f2-4d1e-a998-361cb48fd6ee	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:52:48.766329
ef862755-6766-404e-be2c-669a22bf5091	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:52:48.970908
c8db80bb-d323-4bfd-ad5b-1aaea7880140	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:53:03.819218
76bb99c8-7f80-4b46-86c0-8501997782e1	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:53:04.024568
11dc6826-1732-49f1-b274-0661128e213e	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:53:18.769388
b4063f58-a788-4aad-acc6-20bf26d74fa9	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:53:18.823926
9c2c4cfb-22b3-48a4-bd96-a6b5156d70ce	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:23:31.02089
126442eb-8554-41a6-88a9-cd7a5f9b2d41	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:37.701504
800fd4b0-ec65-4d61-bec5-cdbdc90369d0	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:18.00238
b37ded71-97f1-489d-840d-2cb12ef5595c	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:23.019189
218071d6-aff7-4d90-83aa-c4a9f703ea58	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -46, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:34.078941
8eeeb95d-717e-4ebd-a74f-619fd73d1691	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:37.970088
ecf3b161-8d23-4a50-a843-0ff807a49e67	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -49, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:48.107589
eb0d3b5f-ffcb-4055-bf64-efda2f7e05e9	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:52.966631
e168d15c-4e93-4a10-80ed-54077ff47e80	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -39, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:02.238479
0a625df7-a3bd-4ec2-9612-407e1350e19a	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:08.075553
91f9f081-7488-400c-b468-32c3f6289229	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -40, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:18.111637
1f66059e-c65e-43b5-ab45-d12bc8d7e803	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:22.996291
51122cd4-7954-4bd0-ae2d-f518b8f8f264	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -39, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:32.152749
23663282-f2d3-4dfa-aec4-f78195c414bd	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:38.078673
222e69c7-f4c5-4e9a-91ae-7a7b6a1d29c8	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -61, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:48.216741
af3b429b-5a26-4d29-8ade-09aa6bd159f8	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:36:53.035399
71007c01-5ed8-4a79-afcb-0dd7383eb6df	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:44:44.372125
090f9ee4-b2c2-4a93-ab66-45f70ca59c15	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:17.055658
6dc098be-935a-45b4-ab76-f707082d37b2	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:32.003915
5c2a41c0-e0cc-4d07-a463-88fd7027f958	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:47.056609
1948d7ad-4507-4ae1-8c71-c31849291a33	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:29:47.260805
4a72e67f-e930-47a3-9942-4a281cd68de3	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:29:47.291736
70b691ee-4ff8-4cfc-85f0-7e0faba74f3f	\N	\N	inventory/ble	{"mac": "d3:01:f7:46:de:fe", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:30:02.108993
d3849e23-232e-4c5f-a29e-37f77a0e858f	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:02.380999
fc3853e8-6b34-404e-b432-80eaefb7576e	\N	\N	inventory/ble	{"mac": "ea:ed:63:9b:3c:58", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:02.381287
c58bcb62-e521-4632-b9bf-cb08e73585b4	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:30:02.408036
04830214-c717-4da4-8945-378c98341b83	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:17.061829
37af6a11-3de5-4ed0-957d-f84bfe79db89	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:17.265344
560b72a5-5851-413d-b0ef-c8fb2348551d	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:30:17.265617
3de2d102-9d0b-41ad-bbb6-90fa54f41034	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:30:32.11206
dbda3560-9e18-486c-8b5e-0ec96eb335d3	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:32.317015
0107eb62-07dd-4ff1-8545-ab9f9fc71b87	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:47.093798
f88bcf64-ee67-459f-b918-1588c64909b2	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:30:47.165249
88145350-dd5c-4cda-9f81-524b930dcf17	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:30:47.165509
f6a50ca8-edf0-4fcf-bc34-e48deaab6c8a	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:02.217496
992a6def-8577-4025-b7e6-829dcb60dffc	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:02.422194
2fbd6017-3308-4284-9c56-dfa7b08283cb	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:31:02.422427
7076b219-2676-4d76-a06d-7712ee4befa5	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:17.167536
368663ce-cf8e-49de-8dba-a43163558f04	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:31:17.220748
14ce89b3-8cb4-4a3a-806b-02be99c05716	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:32.156851
fd6d42d1-2409-402b-87c3-cf0a9949fa24	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:32.328048
0b15015e-2e01-4534-9e68-6e344ed20e2d	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:47.178327
59f7fbda-ba4e-432f-a60a-e989e3f104ac	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:31:47.225817
20893e81-6f4a-46f2-b4a4-dc89b011f78e	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:31:47.251239
e6a9dcaf-e9b2-4c4b-836f-ada21f672d3d	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:02.278631
e6c464db-f91c-445b-aaa8-f90d352c5371	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:32:02.429101
9a4da31c-94b1-45a3-bb73-06253e8c14d0	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -92, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:02.429447
051866f8-6584-493d-abe0-a85d0be53c60	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:17.245408
4246bb5f-42e9-4f54-b691-f440d2366165	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:32:32.309385
bfb911bd-13a5-428d-b3d5-f8ddb96ee4bb	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:32.590546
e36fc026-f8ea-461c-a4d3-20edae8bb8c1	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:32.614459
b2f3baa5-bc65-46d2-bc77-e8e1fb6b86c0	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:47.380794
1bb454f2-9e2e-4336-8fb2-000bc3246d5f	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:32:47.688157
dc446305-de75-4a00-baef-68214e46be5b	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:32:47.688393
e04c2631-8431-4f5b-bb4f-d704e09695aa	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:02.337839
0e097f54-94e4-4bef-96fc-53dc10fbc6db	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:33:02.338085
5516e168-ad05-47bf-b960-dd530297ff9c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:02.364047
0b4d6121-88b1-4f0d-a08e-16c815a88e93	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:33:17.38362
5db5ea44-128e-4818-9019-23d9a0a5cf37	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:17.589804
dfe670b8-85fe-4607-88eb-21ba89684902	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:17.590105
57c76b41-f002-4b43-8206-e4552f8af622	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:32.436612
4841740c-7f70-4f3e-8012-a2ca0d603b63	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:32.641781
feacfbf2-25d9-4ec3-ab50-73ded817fe48	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:33:32.641998
01240e92-9c6e-4820-9d83-9aa95e33376c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:47.387387
63d4aa78-0c15-4a27-a318-73a8b080d166	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:33:47.439758
3422628a-b7fe-4ec5-b0e9-586316d964d7	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:33:47.440055
cb4d8bef-cece-47a5-b465-74e1b4dee3ff	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:02.542946
b7fe62ba-4cd5-43ed-8dfb-6fa009a773e2	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:34:02.747572
6875de2d-6a56-4a2b-aeb8-8c8bf116c1e5	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:02.747772
eaa5d84c-b4d7-4c2a-a60f-1027c2a1e748	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -94, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:17.492185
c57984e0-eaa2-48e6-8911-6bb1c88881d8	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:17.595357
888fcb5f-2d15-4070-85bf-2eedf8b8aff7	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:34:17.595729
96e4c749-a98f-4765-a87a-3227d1de6ade	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:32.415146
124f2771-e7b5-4398-b891-405e9aa3d095	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:32.468351
107597a8-230b-4d01-9bbc-2340d107d335	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:34:32.468756
2040fb26-6c76-40e4-ab3a-176eba39ee57	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -88, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:47.438047
6a69f8f8-2ab5-4e40-8f32-44e0fc47ed3b	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:34:47.496129
e74e15b7-cff6-4b50-aa23-95098307e061	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:35:02.547746
5964e37f-b460-4695-a269-5f23d5b57904	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:02.752812
f233435b-f536-48ac-88b3-916575f564e4	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:02.777337
8a6c5015-6161-4977-ab8d-021a8de59880	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:17.480818
89d7c0c5-fa72-4acb-95f6-966c0fc28dfb	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:35:17.526898
c2822d78-88d2-4547-bcfe-f6fb4831ddc4	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:32.550349
4bc6163b-f1ee-4f1e-80f0-80a1a34c4e69	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:32.605361
bbc8b413-5fb3-4708-8aff-c57beeb1ee15	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:53:30.261753
f6709324-d042-4fa8-8e97-07581658359e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:23:31.021384
8e792aab-6349-40b1-9a3e-c781f00b6394	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -51, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:47.774106
b55b2a21-5c39-4a4d-832f-4720c95ca8a2	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:52.801248
19f028a2-6a0b-471b-9e83-45b0dae67ba5	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:02.244635
423ae461-9ef4-4eab-b2df-f24874bb5a28	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:08.081345
723bde06-d913-4c27-bed5-b1e500c9420c	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:18.218847
27f727a5-d6c5-4c8a-9286-58e2c22479a9	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:23.074871
dfc23426-db5e-4d8c-927f-de98460f2cf6	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -45, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:32.341978
002eaee9-7af8-472b-90bf-9a815272935f	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:38.18597
fe8d1544-198f-4606-b5f7-0f0da3ffb32d	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:48.325549
b0a394f0-1961-4047-a91e-cad952888cdd	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:37:53.137025
e96368f4-9f41-43b6-a8ce-84378bf5ca22	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -45, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:02.354924
ad99c983-2061-43f8-80c6-d49183a75506	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:08.189511
679149e9-2a80-4c6c-8533-fe363b8e5a09	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -45, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:18.429297
c16227bb-52cb-4e08-b3a2-5ff926b9eb02	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:23.165433
23561ff7-89b9-4288-a359-4dec62a9e9aa	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -49, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:32.561211
64ec42bc-4ca2-4c24-a63f-2765701ac3ea	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:38.183141
9ecb20fa-d5f8-4e02-8a70-655a31439986	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:48.535761
712429d9-1bbc-4418-8d38-64d572e679c7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:38:53.200137
c33ec66b-eebd-4295-8a0b-7e5d213854cc	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -49, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:02.563746
3cdcbff8-a12b-4869-a81c-1207c2b40bc6	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:08.286942
f887faf5-967a-4a47-a7a0-a72094525f6a	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -49, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:18.640247
6cbc8b18-e8e6-4e02-bcb1-e22a80a14c82	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:23.248212
99ed57f3-0bd3-4593-ba80-f315c8acbcfe	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:32.689795
12e545d5-c664-4268-a79d-2f3ca4b979b9	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:38.257874
beb57e75-63d7-480a-8238-18fe22504b8c	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:39:53.353712
069ae469-d3c6-4d1d-9720-b4bb85394af7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:38.523875
4b3cc167-18c6-400c-8d20-3cb06899d206	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:53.522945
6954d20f-1fe0-43db-b302-befc02068b03	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:05.086975
fb6afbbb-ec72-4920-8488-45062a85bf33	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:17.527093
e4a03691-5d14-45b3-b68e-a8c92ff51597	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:35:32.605625
eb5d3ff8-c176-4ccd-bcd6-d0cc34ec1642	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:47.603963
572bf2de-f1f6-4938-bd98-fc986cd31096	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:35:47.910864
42d16803-8c42-47a6-ab34-90cbb0c203cd	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:35:47.911215
06227d37-f334-4645-acc2-47b6c9827938	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:36:02.765654
a4d77dcd-4ea1-46a3-8a66-9f2f0378b98c	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:36:02.963261
7f2f56d0-95bd-4097-b352-32342099ee69	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:36:02.963569
c9f4e2bd-b5dc-42d3-92f9-90553bee965a	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:36:17.606431
054a36af-c820-4376-86ba-424de8a4fb2c	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:36:17.663116
87a40f3c-5fac-4cab-83e8-43039fc6f94e	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:36:32.659157
6426b324-73e6-4f63-84a9-a76b1fd21853	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -88, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:36:32.762931
c7fdab1c-0e9e-445a-b687-648968acf874	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:36:32.763148
9e29a49f-e504-46ee-b49f-7c1c50124783	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 05:36:56.391569
d4daed5c-821b-42bd-a779-697900778176	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 05:37:26.892169
46795c27-3d5d-4ddb-a651-4cc719fbf108	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 05:37:26.907149
45bb376d-ee9a-4eeb-bf3d-3782ddd27eb8	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 05:37:27.187091
6204f5ec-c037-4dbf-a475-86de1b21b603	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:37:44.445957
bed29077-f35f-4434-9b65-7714042d9d31	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:37:44.472693
94844d77-36a5-40be-9f50-f77f011d366c	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:37:44.571142
baaef6f6-0e36-4949-b68f-e0435a3f3916	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:37:59.426045
e6ced6f5-a523-4548-a11b-7f9e76205d60	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:37:59.476369
16b5ee75-fd78-4fa7-9d81-c590cc9ed204	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:37:59.476561
017c0a3e-65cc-4bd6-9f2e-4f40deb3c651	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:14.546016
875d46e1-9e93-49eb-b9b1-af40c604db35	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:14.750423
139031e9-2c73-42c1-b824-2775dc702f98	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:38:14.750729
62074800-16da-4ed0-adb3-f464c5e602ad	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:29.496897
23d40635-04ea-4e38-b294-eff8941289b4	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:38:29.70161
13d9a6cf-df0b-4466-bd86-a072bf87dc97	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:44.548925
df218383-aa1b-4201-b488-0719aac8a9ac	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:44.753893
e03b69e7-e8e9-464a-a28c-15930e81c1d9	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:38:44.754135
83ca706d-e22d-40fc-8c29-3bd0546ae13c	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:59.513352
d711f926-3826-4d96-b80d-e874f25be51e	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:38:59.602094
8a3aa66a-9813-4061-9488-d58f729a818f	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -94, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:38:59.602283
85f7c178-c431-4ed5-968a-4537cb0a2de5	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:14.767118
74b640c3-c295-49ac-a207-9572a167f6ec	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:39:29.604302
288b96a3-dff0-45c8-be5d-97131128d173	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:44.663962
11c936a8-546d-43c1-b478-6ac19ed09176	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:44.760039
282f491e-262d-4ba6-b21c-837baf1b38e9	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:40:14.679517
cdb5e2e6-e5e3-4bba-92ce-b8e20fab74c3	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:40:29.713122
c6e7bbd7-7565-469d-8696-ebd89a150a7b	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:29.917727
0ccc0866-681a-4dd6-be2f-d13e46ecda84	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:44.664924
4a01699f-a5a6-4ff9-89e6-92221c833a96	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:40:44.867624
879e1aa9-6f25-42ed-bdfa-22e0e75fde01	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:14.774723
59f785fb-4754-4092-89df-976b50878225	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:53:30.262209
b701055d-966e-420f-827b-f5f8f44e3b31	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:53:33.822406
bb857d0e-437f-445f-8a9d-8a7800f96347	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:53:33.995905
e73f0c23-167c-4229-aa31-be8dbd943f54	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:53:48.875728
80b6ef00-74af-4706-ac01-80a0347bfc60	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:54:03.797916
d2e267ec-0048-48b3-8f57-d5323dc53e17	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:54:03.863996
f5fc8beb-9e04-452c-94e9-9f7b8512106a	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:23:47.229445
90cd6c16-ca8b-40a6-a69e-eab18806850a	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:01.81194
a810bc45-bd01-4f72-8108-d704f0f288f5	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:39:54.307886
5fbbd30a-8c37-4ec2-a9ff-15677cf9c147	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:39:54.307438
b80e5b63-0e24-480e-8dee-334512adc73b	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:39:54.329471
a37c2227-b6c0-47aa-baf8-05f2835695df	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:39:54.329922
bacba0d2-7526-4a71-b9e0-a4c2eb0802d3	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:39:54.399205
4c9555d6-f380-4ee8-887f-a7c0fce1638b	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:39:54.480141
3a1ea088-a512-4cfd-a4c2-177806c57386	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -43, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:04.630551
425654a8-d667-47c6-a8be-4613c920c690	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:08.406255
ab43ecbf-76dc-4fc6-b041-06fef410d05c	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -43, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:18.749087
f06140d7-3708-432b-a894-69a25d93b3db	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:23.331328
1a76ff17-e8a2-47e7-8442-f5fa75e8f2dd	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:32.777245
5793849b-a6be-4e32-9a48-1e74f077dcd0	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:38.415316
b95064c3-42ab-4eaa-aaac-5a9b74f2a2aa	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -50, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:48.854117
61790cf7-bdb7-41e5-92bb-f3f38d1f4cc9	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:08.582418
873d4163-25b9-4f1f-99d6-ed7448b7b432	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:44:19.592584
cbeee065-fc30-4b24-8681-391ee8bbae2c	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:44:19.604451
53e33c6f-53fc-4aaa-8775-73f48e2e3216	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:14.551824
b8f284a9-8016-4dcb-beec-4a3dca1ac6c1	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:39:14.76688
e5c12613-8989-4d9f-96c1-9c879f73f83b	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:29.557012
c56a6ee8-f2c2-4012-94f1-248e21b2fa74	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:29.60408
01e7092e-5dd6-4bc3-be61-8fff3dc728e9	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:39:44.760297
403b8fe6-a321-4bae-a5c2-9701a2c4a394	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:39:59.710132
1d6b1ac3-5251-4c87-b690-b49f87968893	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:39:59.843437
5fc9c54e-daa9-4c14-bb79-4d1fd421c9d3	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:14.623381
23f94761-028d-428c-a2c0-5ae1b9c14b77	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:14.679177
a2e88aa0-f070-46b6-a322-377c53512d64	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:44.899665
a9312663-a532-4cd0-9f22-ef8ff403918a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -88, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:40:59.818573
d7a173ea-f247-43bf-b21f-0acd8c647abf	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:00.259485
58fa26c2-2a91-4a75-8603-2d1f27159be0	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:14.724096
e474a62f-0562-4847-ba8d-5442050d1f11	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:41:14.774182
9ced3d3c-a993-484d-a8f3-a020baa78e47	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:41:29.768913
c8798c11-e445-411a-9b83-ca1ee23144b3	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:29.866824
b944f7ac-5a57-4cc7-9034-6465e63c3cb1	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -99, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:44.934692
fbb69cf4-972f-4940-bee2-49ca04454810	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:41:44.948631
95a0d4da-30f1-496e-a1c8-4695bf2bc7ec	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:41:45.333485
5d780e01-5046-477a-9316-a06f031df3ab	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -93, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:00.00264
d7d62b18-7b38-4e9a-b7f2-da6e57382cf8	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:00.136548
c5940b69-58f3-463c-b236-fc26329ea3e9	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:42:00.164948
e52f747d-d643-464a-bf11-f734d0c5b361	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:14.794549
91f8be0d-fd35-4f34-b3ea-2a6c5e90888a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:15.920124
aa0f6a5d-0bd7-46a0-8974-373e62cdb641	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:42:15.964428
80afd2f1-0bde-4c99-b9cd-dec5deb907f3	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:29.92982
7a46b6f1-b73e-4bd4-b0db-6517640afdd5	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:30.133714
d4c99a49-20eb-439f-8e8c-ca4c549f4c76	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:42:30.133984
212f8a4d-ad67-4c12-b4db-b1cfc11b63cc	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:44.879252
6c894e5e-ec6f-417f-bdff-682a54e05f52	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:42:44.936014
fef61e02-1175-4d96-bcc3-3ab1f07452e5	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:42:44.936275
d0e6b388-2c42-4e1d-b87b-3b28f02d6e3f	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:42:59.932285
4db77ecf-c4bc-466b-9497-075a633fbb6a	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:00.239857
44d5b614-9772-4107-9185-a69aaa1e8dd0	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:43:14.932342
4df38f05-141f-4445-8802-7853c93de1a8	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:29.904362
63e934e8-4c3f-4733-9bfa-104465f841c9	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:43:29.956169
f65bf80c-adfa-4f77-a186-120bb8e6f4a2	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:54:18.878919
ed7223e4-787d-4893-b1a8-fa01bf910542	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:54:19.083298
8f2d5929-0e5c-4813-9d80-907f1faee5e2	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:23:47.22992
14c0d974-9443-4b15-aef0-12ec7dcb89d7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:07.741736
4eb10c06-51f5-410e-a26a-310d704b34f6	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:17.675304
7693882e-335d-494b-80e3-c1965b3f41cb	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:22.762411
df60b50f-78ce-42c9-9576-729494af2047	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:31.814193
79cfe8c6-5ab7-42af-93d7-36fb91912cb4	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:40:53.369445
b30bc2d1-40b4-4186-a111-515c39281dbf	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -40, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:02.807273
4d72dc2c-8281-4ff6-bf61-63c46fde78e8	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:08.390458
ab2a3be3-88c7-4a9c-881e-b45722e80b01	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -45, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:20.904927
31ef553f-275c-47b9-bde8-4bcdf2543a2a	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:23.436153
701842c5-6757-4e4c-adbd-7ede67e0a566	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -39, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:32.963971
8822eb02-be52-405b-8d98-34b684514148	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:19.176499
adb8c1af-b26a-4fa0-aaa6-8f717b17767e	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:23.569085
df8bbdaf-86d0-4a8d-99c4-1b468aac1d61	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -47, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:33.204463
e678164b-e47d-4a7a-bacd-54eb0ef973ea	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:38.632985
bd0ecb95-494e-4d37-810c-379b7a7537ea	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:44:19.59301
2b208ac0-0fec-4c62-953a-26b8130bfa26	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:44:19.604048
847d3321-aa0c-4fc5-9909-5963f72d0514	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -41, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:49.389908
db52560e-644c-4af3-b381-350c1b1bf810	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:53.895476
023c2342-9b50-412f-8e59-58288057e527	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -61, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:45:07.413097
fd6cfb01-ff6e-4731-8f2e-8038f544208b	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:45:08.743041
d066ffb5-f450-48ad-97c4-5dc1809a6be2	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:45:36.5283
07b74088-89db-43bd-aff6-365529e04646	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:45:36.53918
f5fb2008-c710-4dce-9628-e475d0f95299	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:45:38.849758
10dd4f10-cd13-4d0b-9380-d3d4a6ff40b7	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:45:48.567754
f1967bc4-9531-4e58-8548-3fcc41ddb251	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:45:53.751481
59b06910-f9f2-477b-82dd-8015b9f38ffc	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:04.65328
61f598cc-7773-4414-b7cc-40c32db0561b	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:00.240079
08db074a-16d4-4f27-9525-25df06ea36ef	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:14.881208
f005fb4d-e401-4e85-a2f5-50558d8341f1	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:14.932018
68f10fb2-a7df-4773-b281-9732fa358f46	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:29.95639
ee156241-c90a-439a-9d29-3207e5d745bd	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:54:33.838865
f8e7e001-0190-4655-9ed1-5c9eb76693d3	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:54:34.032459
84d278ba-9338-4a96-9bc3-bb1031bafec5	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:54:48.982768
d307deff-f8b5-4460-b8c5-ac0f1a8719d4	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:54:49.187593
e2adcc84-938a-4824-ba25-d6ddb8ec0670	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:55:11.389908
307bd98f-785a-4055-87b3-e744b53da0e1	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:24:28.295632
d7bdb6ff-6e25-4bbd-8203-4636cbb3d843	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:37.781649
26cc2bb0-1b15-4af6-b524-7a6004bc135e	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -39, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:47.780283
6979a911-2c35-42db-bdf2-c1f4c1bbc411	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:33:52.908739
ad8e9e83-6903-4b90-996a-c83169d1f889	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -34, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:03.764832
bc70dafc-1664-484f-b948-6cefbbf309f7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:07.858864
ee7000b4-5c6d-4e5c-8491-4836a54d7e40	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:17.884792
9af5c893-077a-4b91-b613-5a3709e0fa7f	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:22.83941
b89d741f-16f5-49ff-a518-f83341639abc	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -34, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:33.931654
8989c13e-8033-4166-bc08-440419fd7960	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:37.868403
e37567a6-c7f4-4b38-8211-aa07b8ecf30b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:41:46.587119
2b3d8026-4af9-4ab0-889a-dad93cfb9d90	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:41:46.598966
eaf39754-e23e-4b13-8008-219defc79f0c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:41:46.715515
e2a310b4-fdca-44da-a992-329105519a25	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:41:46.750324
a6fb85db-e21a-4db9-b6da-3badc757a0a1	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -41, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:48.969435
c742c22d-6c80-4db4-a040-d32b8220864c	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:41:53.433442
b9878efd-8d70-4ff0-86d3-16b6d52f51e5	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -46, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:49.18051
5775bc3e-5df8-4a8f-aa18-c55db5163caa	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:43:53.598726
e27d414a-7082-42f3-9503-59c21529c584	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:44:22.505204
ab33de74-e95a-473c-9792-1f3d7f265e38	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:44:23.648879
de9d8124-3f54-4599-ab65-b8a4cf525632	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:23.706087
41b24b2c-d737-47b1-8404-73c7c0e98669	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -63, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:33.795896
db74b702-5aee-449a-ac6d-641a871e9ac1	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:45:36.527875
e2af7a05-182f-4d56-bcf1-6c9183c48ae5	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:45:36.539705
7b46343c-be65-4de3-b74e-b82002718661	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:45:37.626761
f1945fcf-7b92-459c-a652-3da0477b575e	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:45:38.741078
fd26ec1a-d250-4396-82d2-672d9945efee	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:43:44.942526
dc593808-670c-4961-ad83-09693f352b58	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:45.001259
7f7f0889-c825-44ed-ad0d-e968996cb36a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:43:45.001562
c19cb618-bada-4563-869f-4550e670952f	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:00.04008
41da5d5a-7f8c-4b63-88c4-00c71f72f2a2	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:44:00.217515
5aa98fc8-3df0-465c-a0bc-5c6165df5754	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:00.217732
8102c325-fbe3-4cb2-bc5f-0a43f76068e4	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:44:14.990168
12896c4b-4247-4451-8d1b-4fba07acc0d9	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:15.041468
0e6be01c-a371-4e49-82a4-4a9e33473353	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:15.041824
ce855b5e-d106-4fcb-bfac-7b54150081e2	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:30.043284
a484a73c-cf96-4b76-8164-755657c2b581	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:30.247213
de1fc265-3b01-45d2-9210-7d63f427b464	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:44:30.272519
26b130e6-ff20-43dc-b7f8-2baa4bdc1550	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:45.095707
17603553-6d97-4471-aa4d-3bf1f55648c2	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:44:45.300546
ef86aa32-b5ea-4836-9a71-49cf038396ab	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:44:45.300772
4902e28b-c8ea-405a-8a61-166e75a24d36	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:00.095326
7c3449fb-df0c-4bf2-a0d1-8059970d8f4b	\N	\N	inventory/ble	{"mac": "dd:74:b5:17:c9:52", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 05:45:00.25323
c4e3eccf-4187-401d-a8ee-778950836b8d	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:00.253636
411dee94-b2e3-4016-8846-67756bacfe7f	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:45:00.2539
5a300c16-6e6d-4c72-92f6-55aef974fdad	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:45:15.098465
f4b3047b-3b76-4f15-b8f3-ea7965c3e24a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:15.302777
d2063e38-e937-4e94-8b56-fd1baaac1130	\N	\N	inventory/ble	{"mac": "c8:c2:f7:62:8e:c3", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:15.303025
eac7c230-1023-4878-a5aa-26e4959c9abf	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:45:15.303241
03873db3-f371-495f-89cc-df7ccac9285e	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:45:30.07931
65b232dc-db40-4b29-bd27-73e1aae7286b	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:45:30.138841
ade1917f-48bc-4a47-866f-511932fe1fc9	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:30.139105
a0f7a13f-8180-421a-b5be-4552602672c5	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:45:45.099977
b3234c65-76bc-42d1-a9b5-f66e0a33182e	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:45:45.20456
636945e7-cc58-440e-8856-166d282a9a76	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:45:45.204949
39085300-cdc5-4e05-8770-47a9ec10cddc	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:46:00.123701
f19d6078-64d3-48e3-83dd-492c7b1cedb6	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:46:00.395771
e6b34513-5475-4373-b3ed-e4a0892618ed	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:46:15.145488
1b7e0658-c793-4cfb-a0b1-86e7c2646723	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:46:15.201368
1487e996-7b61-480e-b6aa-8d393ef5f2a7	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:46:30.165566
969dc39f-156f-41d3-92b1-ec58f6bc0a1a	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:46:30.259916
8f1c91f9-ad95-44e5-89f4-da59b664d8d6	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:46:45.209845
f9611f4d-a622-4329-a6b1-afd5b7276283	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:46:45.275007
30a2522d-d8d3-4d76-b3a0-44bdc31b8606	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:47:00.215885
c989a7d6-1d50-49c8-a153-b1a183fe8c42	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -38, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:47:00.269828
2cdc187a-c944-4f58-bc67-555c2abf3e59	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:47:15.230593
623fca3b-ec58-4e40-b85d-f8f97223d29d	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:47:15.316983
8e8347a0-067b-41ae-8491-242d54451a8c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:47:30.255269
8508390b-2980-4d42-8b18-1963bde32ba7	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:47:30.368547
a1f4abe3-45d5-4fc2-9a9f-13dd54f708be	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:47:45.317808
197075e5-4a2f-4f26-8a21-28be881bc44c	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:47:45.498076
0108cf92-48b1-431e-b997-c1a4a5eb3096	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -90, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:48:00.293561
deb89731-ad6c-4e9c-8513-6e8ec00df998	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:48:00.516264
ef236ab7-9e6e-47ad-93a6-367e01cd126e	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -88, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:48:15.424971
8202a01b-9a74-4b63-a060-4aa189cddb8c	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:48:15.530086
89896034-8782-441d-b640-d3566f3338ea	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:48:30.476372
672b06c5-8f80-4ac8-94f9-6ffdb48d0b59	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:48:30.49646
4c32c99c-e85e-4ae6-9b56-d1d29093aeba	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:48:45.406266
a0199680-783d-459b-9b68-ad386f80bec6	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:49:00.38604
53b52e5a-86e6-47f5-80b8-d77c13766bee	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:49:00.479448
77ffb526-34c9-44ea-b3f3-bdd906982ea1	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:49:15.444897
f88fdc70-a9e1-42ed-b35d-687149a88215	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:49:30.482354
e2e009c3-6ada-4f7d-864c-05eda79f2553	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -89, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:49:30.558857
c76b8942-3d64-4d9c-b385-b0d50c2750c8	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:49:45.446961
57500036-a92f-498f-a15e-a2a2bc33b970	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:50:00.463611
7b11ac1f-9151-49b6-90e2-359c1700b306	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:50:15.485712
adc99f9f-a37d-4eec-b2dd-954a09ea0b1a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -96, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:50:15.64062
4e32752d-3242-4df4-8d73-101cddc716f3	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:50:15.66963
71c25fd8-a493-48d3-9f72-1cf073f6e98d	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:50:30.511161
f7b4d5cf-f56b-4494-a635-d240a76ca130	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:50:30.793643
8451a10b-0180-4e41-b0b9-d10e1165ade5	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:50:45.530064
679797a8-1ff8-40d9-8da3-a458d015b59f	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:50:45.64319
67491a47-7e03-4bea-bda4-0baf389369fa	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:51:00.592901
93fbcf85-0d96-4046-9a10-f52294b3ed8b	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:51:00.796402
f41dbd2e-b878-4b25-99fe-e3e59981daaf	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:51:15.644502
d6679afb-3df9-4472-ace7-2adc478782b7	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:51:15.849435
e890bd2d-7f1c-48a1-bbb5-2fc65a610aa1	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:51:30.593179
662d932c-3b77-4969-b85b-99e00d41bf74	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:51:30.647819
3838fbf1-5805-4c2d-8ee9-7d29d3dd984c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -98, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:51:45.647714
57b0bfaf-a008-4cb0-8dd1-c754bb98d6ca	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:51:45.708761
b8d6613e-e154-4a88-83e5-a462b9d8f43e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:51:45.7332
f87259a8-be45-4ae5-87be-97e1ca9f8e9b	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:52:00.700276
191d0b8d-4a6a-4fc2-842f-95935f6ef3e4	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:52:15.671497
a96eb7c0-2e5d-47b3-9688-dc91e9d84738	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:52:15.811153
e0bc2379-f441-404c-9101-9bf6c02be948	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -92, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:52:15.844308
c0c343dd-b1d5-4ac8-b560-0cbe5e5159b3	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:52:30.678944
a757f5cf-3d53-4130-8b60-96682eadfc54	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:52:30.729872
8a65c85a-8ddd-4491-a314-80cfb0fee0db	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:52:45.700577
6bf726dd-f7f8-4822-9215-98aa5f2ac031	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:52:45.755092
f1c2d6e9-f337-4085-b3a9-81ff36bd604c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -88, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:52:45.755354
4ae50777-6e74-4448-b48b-9610e606e33e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:53:00.808246
59f088fc-0d43-43f2-bc59-054926fcde48	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:53:01.013
74854f63-b8a7-4527-b617-a6990c0a817e	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -90, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:53:01.013342
83da6129-47c3-4c38-9f5d-f8dcaa391ccc	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:53:15.758745
5d423d70-3174-47f3-aa2e-c38bdc5f919e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:53:15.96301
38083c4b-3e8b-4def-9ef5-2c7b9e43969a	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:53:30.811222
2c11d98e-326a-449e-9a25-a3bd02b8863c	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:53:30.865863
ebe7e7c6-8e7c-4d74-af9f-b4c939516b8e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:53:30.866138
46dc33ca-5cd6-45dd-a93e-58032dd558b3	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:53:45.86366
c00d0f54-565d-48ec-abd8-f9ce0df9a092	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:53:46.068315
78cdf922-4a48-4305-89fe-20cfb8eade7e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:54:00.813868
f391de78-3824-4667-a868-b6b0c18b4ac8	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:54:01.018502
6810d5af-3e95-4314-9bb0-88bc13a2a518	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:54:01.018806
6ac4b6d7-6fd0-4f30-b21f-474bd6fc0095	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:54:15.9691
3b6b9f77-2d56-4727-bbe7-f5b88500866c	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:54:16.173576
eebb7b01-be37-4303-b96c-927b8cda0343	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:54:30.918833
48e51af3-cb1d-4080-ac3d-2b26b3a1c009	\N	\N	inventory/ble	{"mac": "da:6e:43:12:f2:a4", "rssi": -95, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 05:54:31.124174
e2e8a7e6-ebee-4f2d-9b50-4f86ace29534	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:54:45.872039
aad41ac8-98fc-4db2-82ef-acde133a3845	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:55:00.893283
a472acaf-fdd4-4e10-8fc3-4f9a35317bdd	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:55:00.945571
60d7a629-3369-4dc1-911e-324cc464a6b6	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:55:15.975279
53874ac0-4672-49ad-8d07-9d191f334a8a	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:55:16.077892
977b9cdf-1b2a-49c7-bf2c-f63728f4b127	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:55:31.02756
734552f5-5ee5-4901-809c-c9b0ff4774f1	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:55:31.160617
19ba32e8-5f8d-4f11-973d-e99d4c5f91cc	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:55:45.977803
f47f07f3-4d73-416d-93d2-7c9c7617b059	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:55:46.037203
c16ec9b8-0437-43da-b5dc-a0e2f3087aea	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:56:01.031344
92e4ef8e-0e34-40f4-913d-5fd0fe49bd22	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:56:01.235247
dfbe7253-23fe-40de-b44a-3b4e4f66a23c	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:56:16.004179
1f37a791-cf55-4d79-b9c0-b988ce65d4e1	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:56:16.083633
b03fc980-e05c-4f9a-aa0d-3c1dd9e4777d	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:56:31.13631
f0148e0a-bf30-4c4e-864a-96117b4fa930	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -42, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:56:31.340014
38514cec-bc48-4cd1-a692-d06e9fdb7c60	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:56:46.053526
8eb762c6-b1d1-4a93-8699-41207ab5d95b	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:57:01.069766
13c0eac5-acef-4cf2-b042-5b36634b7a2c	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:57:01.247616
66efebfc-007b-4146-b867-bfe308c552ea	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:57:16.092449
46b45e46-9d10-481c-a9d9-415f6175feef	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:57:16.154008
c55e2769-9b6c-4138-a5c3-a6d27a31c8ad	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:57:31.176109
c4ab1c4a-f9eb-44b3-b76e-d6ab4d3aaf8e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:57:46.19443
71b85508-1401-4b22-bca7-e3fa6c5f09d3	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -41, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:57:46.33532
ce60ff6f-7785-4cc1-aab7-0cdb8f192115	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:58:01.451765
69027645-47dd-4535-acca-8f33276e1434	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:56:33.139658
0ba083c9-c371-4b19-acf5-217e484ce873	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:56:33.140045
0f1b1de0-b7b6-462f-919a-2694de7c347c	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:24:28.397914
e9462590-51f2-46f5-bad7-90d95a056f22	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:34:52.914107
27391a7d-4f02-475c-8c94-2f98bdd49db2	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:54:31.124437
e6b5baf9-58e4-4f11-8929-dd8fbdea82e7	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:58:01.476934
f6cb4d05-f25a-4218-8423-a1f789012816	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:58:16.17234
d354de36-e13e-475d-a6c8-54c9089b7165	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:58:16.232258
aa1a2438-215f-4368-b124-e915c4a4a92b	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:58:31.244702
73393de2-4082-4ed1-be5d-aa102f00b0bd	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:58:31.365366
eec75846-86d6-4b3f-b5d2-fb757483aa95	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:58:46.215291
88078381-e05f-4165-a596-304f91af68fd	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:58:46.30383
1cb593e0-522e-401f-9fe6-9e7a6e92dad0	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:59:01.278553
c41c69eb-c891-4183-8942-225cda50583e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:59:01.458084
e8f8f638-bc07-4b77-bca8-c519354c58fa	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:59:16.306586
e0b7a245-f7f5-41ca-a7af-3223316cdbf3	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:59:31.27596
9045f28b-de97-4507-83af-e0f75529dc9e	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:59:31.326604
fed2c2fa-74e8-4010-a0ab-0557be04b1ae	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 05:59:46.411157
b64e861c-ece9-4fd8-861d-f5b6fe5088d8	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 05:59:46.615417
a128c084-d2e9-409e-9d62-3ee57d27634c	\N	\N	inventory/ble	{"mac": "cd:dd:88:77:ee:e6", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020002"}	2026-06-17 06:00:01.361018
c3c315fa-56ea-4f32-a6cf-2be3ae7d1ffb	\N	\N	inventory/ble	{"mac": "d1:10:cb:8f:3b:23", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:00:01.408431
1a5ad9df-9ac5-4e65-af59-c50152ef3efe	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:00:01.43724
9450007e-5231-4d84-b352-208d5b22ef74	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:00:16.340652
efc246ac-a23a-49cf-b5fa-110d61b8df02	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:00:16.389669
b572e810-6635-4153-80c3-e0033d7f887c	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:00:31.429554
f2412a50-62ee-4783-8a84-4e8bc4f4cad3	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:00:31.569405
938aa8f6-8789-4655-bdfb-2b042424b434	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:00:46.394021
ae4463d5-6163-4b65-9970-a3c8d938655d	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:00:46.444845
2f1d3792-8314-4b42-b0ec-6ca7e1ad6b4f	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:01:01.410022
e48f2bbf-01bb-4138-8dd8-d5605750c46d	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:01:01.485056
4d097bd7-9c5a-4c6f-9820-20d388e31145	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:01:16.52134
430ebbb4-fe9a-4aaa-b045-d3575418e11d	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:01:16.731417
42fe10a5-a294-4c60-8436-8f24c36fa946	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -44, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:01:31.449984
e8c870af-208b-4e00-9aba-3b1a47952111	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:01:46.470192
2dc65aaa-a9e6-4342-83c5-59c13b2fc796	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:01:46.527171
31525851-1199-46dc-a9d5-cf57c18f57ad	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:02:01.584014
931d8ff2-fe39-4caf-87f4-cc0480d5e501	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:02:16.516696
0b2f7835-727e-4c8b-8d37-371dbc86ffa1	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:02:16.571025
d82a942a-1764-42c3-86d0-8e5b8c3b0809	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:02:31.580618
a7a01a13-ce8f-4938-a7c0-8129a91fa845	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -39, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:02:46.55044
e0810847-ca52-44eb-9e19-14023cb8072a	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:02:46.633716
b2dc79b2-5f29-40f8-9b88-e95ee221d4d6	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:03:01.582497
6b792473-b606-4564-b97f-4ec20af8a947	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:03:01.787243
ae1e7a71-bdee-4c9e-b523-f7a4275814be	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -40, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:03:16.635418
e23be0dc-4273-4ca0-a475-4a4c4f76f996	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:03:16.693382
2032bd5c-fb22-45bc-9e0d-77a0aaca65b6	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:03:31.670454
144c5c99-e3ca-467c-b9d7-d811fd9575d8	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:03:46.843436
015cfc6a-8abd-42ea-a33b-8ea5364d38a3	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:04:01.690736
874a445f-ab98-49bc-8fdd-a1cd3c383270	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:04:01.748291
da75019d-625d-42bf-9d87-431d3e824c19	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -47, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:04:16.745932
96860425-7155-4cef-9f58-9f484bf91df7	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:04:16.948116
bc3f9ac2-ecc9-49ec-a3b6-5171c6eb88ab	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:04:31.795908
abaa8111-4c7d-49d4-bb9d-8915576336f6	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:04:31.966556
7baf59f8-60b9-4b37-8b8a-a1c6c2695bc2	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -46, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:04:46.746378
58ce3391-d7dc-4f2a-8252-27e396dac630	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:04:46.807433
16c2ff12-ba8a-4101-b43f-617639ab3026	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:05:01.798546
77ee4365-283f-4796-a466-11f59e972809	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:05:16.881479
998babfb-8961-4eda-9596-d175f742e09a	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -45, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:05:17.165167
e7d1e781-fb97-44b7-9d21-26df8d3956b7	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -43, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:05:31.801863
c02a279f-3b1d-45e6-823b-a5cb8c0b225e	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:05:31.86835
73de6a67-08ca-4bef-9457-6fb786b15a41	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:05:46.956849
8b692e2f-a405-4de3-9222-e21c3ad7ddb2	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:05:47.263948
eafcedcb-10f4-4cae-8ee9-9dac83b9fdb3	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:06:01.826357
cbf7945d-b09f-45fa-aacf-a0b48015718c	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:06:01.876785
cc53f4a1-2a26-442b-b2d4-631668844735	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:06:16.84891
e3616ae9-d2a0-4c53-b3ff-f346613d8bf9	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:06:16.959913
02e20efe-67cd-4066-a2cb-b8545c36dac0	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:06:31.90101
ddd4610f-3578-43b3-b0cf-f239049d3a34	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:06:46.889035
a584207f-57f9-4f5b-9bca-04b78cbb0748	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:06:46.963282
fc5c6835-8bb5-47bf-8d23-57bff21cee67	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:07:02.015752
d4afa680-f071-4627-a0ea-be1a0290c295	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:07:02.220143
2ad1bf8a-d5ad-4be1-9b2d-150a71c5fa30	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:07:16.9658
d39f73b5-30ad-4295-be7b-9c8931f26dff	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:07:32.362084
49ba8555-411d-4e61-bbc9-293df5863b23	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:07:32.428055
af90f9aa-da69-45be-94d1-8c0f9327e6f6	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:07:46.97214
31bd24f4-66c4-4bc0-98c8-c347bdd4b2e4	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:07:47.072002
f3b68028-9c6b-42cf-8bc5-f651a37a4dab	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:08:02.021361
224ec02f-0f0f-49a9-bd58-e202d4d33c7e	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:08:02.08182
b2822d1d-9d81-4936-aa18-8151b018aa93	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:08:17.073779
366e9909-dbb3-4cd9-970d-cfeb3e63d95b	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:08:17.380676
886fb2e7-5ac8-44c9-b89d-5d11161839ba	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:08:32.037646
5a3c3306-f26d-4b07-b3bb-87f2ebde1642	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:08:32.087878
47b44ef2-dedb-4c45-b7db-fbd149978d55	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:08:47.058908
ad6eca15-03b5-466b-aa6c-aec3b327fe97	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:09:02.078738
4d38b46c-7f06-4373-afc1-6b31f062f0b7	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:09:17.182206
efc0cd2b-5729-43fd-a30b-fb94958bf27c	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:09:17.387031
22babdef-feb7-4010-adb5-a6df87b1bce7	\N	\N	inventory/ble	{"mac": "df:c7:24:fc:66:c5", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:09:32.128399
69fd605d-0840-4524-960d-b5e4c0e16d85	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:09:32.244353
91b6995e-2836-4fe8-bc56-0d48a61bb07c	\N	\N	inventory/ble	{"mac": "ca:8e:61:b6:cb:60", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:09:47.157368
4460cc6b-d27f-4c9b-8e7b-ca6ade9d7daa	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:10:13.382114
71c9ca6b-e330-4734-a2fc-131b18f73c18	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 06:22:06.63451
8e558d1c-6f78-4b7a-a80d-b450bc2a03fd	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 06:22:06.651245
83982217-bcc5-4e82-85c5-45189cba96c7	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 06:22:07.208507
609266de-1757-4a27-8877-aa9fa2696d23	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:22:22.180002
407383fd-9571-4165-a1be-d7ea3ff02b1c	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:22:23.309635
b4b2586f-9c20-452d-b488-aafbd9abe898	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:22:37.170935
b129d2be-eb7d-4117-bb90-186968e7b4a8	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:22:52.278338
3c4b1d7e-11c9-4589-8b8e-b77ef8be9634	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:22:53.405041
03f7d639-e1f5-4c79-8ebe-808a5e7f70fd	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:07.228976
885334c5-92f9-497c-842f-8de00ce034b9	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:08.354448
8d9c3ef4-3ff0-41fb-83f9-2036ffab5d2a	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -75, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:22.383522
62032959-7bec-4090-a0a3-acd599985c46	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:23.304861
8278e4ba-2671-49d6-b109-867b98456649	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:37.290279
2247d9c3-1a74-40b0-986d-2786433860f4	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:38.361198
4a30d48a-3b71-4d01-a952-118ddc541d64	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:52.283533
db5cc1c7-51bf-48eb-88c3-225536090834	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:23:53.307929
e9780f38-5a5a-44a1-a1b7-d272bdcf9721	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:07.336353
b0c0a1c2-6da8-4de1-a338-a7057968b0aa	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:07.400165
9dc46f95-73ae-4eed-85e4-eb9818d1f5d2	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:22.317069
2b0cfa8f-71a4-4756-96f3-12cbbd33058d	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:37.337148
e8f34ede-9ce2-49d2-9444-e545946db09e	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:38.793693
01c9d9b2-4c35-4ac2-accc-0985d7c02a49	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:52.444008
dfaa1b7a-358a-4872-8bb0-1f8308314604	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:24:53.792927
4a517ca9-e6e6-41e0-825d-5f50f741f0e2	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:07.377601
6bcbd881-19cb-45d8-b51f-a2cf0329ca2f	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:07.430711
e02f5443-4fca-4114-9afd-b6240853c4b0	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 06:25:15.021925
98d59cf0-8165-4fe9-8afc-98cd398f6b38	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 06:25:15.024047
a418e810-573a-4c8e-9b08-3e07c884c0cc	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:25:15.029696
96e673c8-6f8c-4d71-b125-c228c82ab62b	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 06:25:15.329639
cd7df599-828c-45e9-9366-8b930d1d647b	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:31.002559
314eb503-3832-4431-9952-c43b4823adaf	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:31.028541
4aad90d5-1188-41b1-aa8e-971a4d589992	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:46.049471
217a4085-b1aa-40a1-a610-cc9fa24c9f84	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:25:46.254185
3c5b6954-7971-4cff-ab3c-b64522db428e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 06:25:54.547961
4290eadf-1e03-4f0b-bb43-75f3a517d42e	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 06:25:54.550426
3658f1ae-e3b3-4f71-95c8-662010fac69e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 06:25:54.856093
0286a61d-f246-415a-b564-f233ce606b40	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:01.10269
f6adad47-7cd3-4b07-9f9c-823a88f42b02	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:01.212148
d0ad03d6-ae28-4c9e-a58f-f6eff42f4912	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -77, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:06.529814
67d50894-84d8-4015-910f-c3fcd321e507	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -59, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:10.20739
0f538576-a200-474a-9af4-0742c7d6ffaa	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:16.051832
9f99c679-916d-4694-be80-6696f7b53456	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:16.256344
2dc693a4-8547-4138-99c4-2005bbaff241	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:26:16.461365
4a089b0a-a428-415d-9ffe-2579e40fa2bf	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -66, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:21.982118
05294d57-35d9-4414-b6dc-5b8c530a5cca	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:22.298867
3bcea167-2538-4edf-97da-0ae18e92eb2c	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:31.064832
a45d717b-ac8c-4b93-96cf-27b153a752dc	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -48, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:31.120478
1f84f6ab-586d-4fca-b5cc-a62db8e8a9fc	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -87, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:36.533321
6951b182-a593-4426-8b0a-5325ababb765	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -65, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:38.280302
adafd403-b9c2-40d0-ab32-60e49e64e8b5	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:26:44.407963
bc040c0b-9d65-4da9-b3d5-5464c4c3d331	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:46.086762
6f98caef-88a5-4fff-b340-bea5789ab6cf	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:46.136373
25236f33-95fa-4157-b147-08d783625e4c	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -81, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:52.302723
d5d175d7-6de0-4215-a46c-b8dd8a03b98f	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -59, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:26:53.316538
6f9aee83-3d51-42b4-bed4-2bb8a847c894	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:01.106146
278d0429-fe28-4253-95a2-1559a356158c	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:01.157191
e8f041a3-fc97-4fd3-a5cf-c070af1ed046	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -55, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:08.369076
33dd856a-701d-4c9b-b720-23d6f77e77ff	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -63, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:08.665885
672a5f5e-38dd-48e9-8900-f13a79af8b40	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:16.160644
b710efe7-c872-44fe-b0a8-c2a7068c1555	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:16.224246
be1a9836-bee9-4fdf-99e5-fb348fb2b43e	\N	\N	inventory/rfid	{"uid": "44:7E:D1:E9", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:27:18.924949
a300fee1-857f-4157-8637-ef71e4bb7e98	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -67, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:23.737956
525d6c40-0a41-45d5-a9be-f6c8ede6e9b6	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:24.55674
d72442f8-ec8a-4f6c-a3a2-20062556a0d1	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:31.213792
d6f1f43f-86e2-4285-8803-26aa7708a5b4	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:31.417331
9ab30c73-1912-4185-ae15-1376c9811ae5	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -94, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:38.27905
ec6279ad-b53b-46ef-ad84-5f1e6f01f97d	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:38.585779
01b8a9b5-92a1-42ee-b40b-ad3d87812a0b	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:46.17747
4836f71a-207b-470f-9340-338a15b56254	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -54, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:27:52.614297
e56281ec-4f9c-432f-8e87-428a10e67a93	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:01.215995
ff935933-7d1a-4716-a1bc-2eed0deec4c1	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:07.667187
2af031e1-72c0-4e52-ac27-f930eb3fd93a	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -69, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:10.538031
46685d58-df67-4416-a683-8a7ea52c1e43	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:16.238953
fcaf39db-9bd6-4d0d-8bf9-f1d18c291f62	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:16.37031
b0a98798-90b8-4d9b-8cf1-5a9de5c3b5c4	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -70, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:21.789531
cfe54e15-54b0-4ca1-8787-a5c03f00d80b	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:23.632074
a772f6f1-ecb8-4086-a1c9-255775ce22cd	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:31.249738
67190753-4f24-4397-97f9-fd660ee81177	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 07:17:35.720247
f1422365-34a0-4b4c-99b7-110b81816d92	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:31.323771
3cae7d4e-bfdc-4cdd-b723-e3c4a7965eb4	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:46.261657
9652508a-91fb-40f1-a497-cab2ef96bfe3	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:28:46.374624
e634b0aa-2666-4069-8740-c46892595f5e	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:28:49.366137
3521837a-92e8-424f-bea4-e3bddda36e2c	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -92, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:01.324328
6b0b397c-1a04-411b-8b1b-931a38a63344	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:01.528676
28c15b89-380f-45cc-aac7-1b258583ccf7	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:16.339449
d1451c50-bb58-4eaa-aa7d-9066d2159102	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:16.581615
9fa091be-0bb7-4276-a8b5-aaa9ebe677ff	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:31.430554
ca39ab7c-7857-42b9-afb3-ea8913a6694c	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:31.634247
8d2f654d-93c8-4dc8-8395-dc1a5a0efe8b	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:46.343714
c9e727bc-3d4d-44ad-ad07-1d301faee2cc	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -93, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:29:46.391458
47be1633-11ac-4eb7-ae3a-ffd631a4378d	\N	\N	inventory/ble	{"mac": "ff:e5:08:12:71:9e", "rssi": -92, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:30:01.402173
ad6683f5-3143-47d5-8d87-3a0afbecfc5e	\N	\N	inventory/ble	{"mac": "de:0a:61:aa:b2:d1", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020000"}	2026-06-17 06:30:01.46727
af8de41e-0373-4288-912a-eb8569fe7c60	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:16.451366
707b0039-ea0a-4db6-8c59-024bdb832cb1	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -75, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:16.689612
fc5923ab-cded-412b-937b-08ded302035a	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -50, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:31.40751
bdd813b6-3fba-4560-a340-252ad874b1fc	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:31.457245
f053020b-6c31-4399-ae16-2905a3f6acfc	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -49, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:46.439655
3913b8b1-d174-4dc9-90cb-ad51a78a2e65	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:30:46.494844
028de815-eca7-4ccb-9829-2161a0405eb3	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:01.451749
7ac95b98-1fa3-4565-a510-997b02f7db9c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:01.541782
0cd588ad-295a-49f2-9466-c5376ac91e64	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:16.472916
a5dab5ce-a10b-4a0c-ac06-78714d8db3eb	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:16.532875
40207db8-9611-4cef-8f18-87c9b1a2ca93	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:31.4946
8e1530e7-dfd0-48f1-b765-75e756d68b0f	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:31.554767
0be8e148-7451-4c28-a639-e6287a3bc42c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:46.516155
cbac18a6-3b53-43db-a202-289a363ad537	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:31:46.565983
de5b6677-249a-45ad-abd8-8a3d4a157618	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:01.602866
be6fe8c6-9c56-468a-a6ad-1fbe1d9ec2eb	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:01.751506
5377d23d-f109-4d97-b779-979bb9560181	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:16.599604
3c75ddec-3db2-4ce0-a7e3-4ae8af4a1c91	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:16.662017
17323cca-0245-4a44-bfb1-9865f7f4e489	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 07:17:35.72066
b416bbc3-1369-4f90-a87f-47d740712f5f	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:31.652531
e91ea060-484c-4b9a-ae9d-0c15a7b6a87c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:31.85625
043ee7e4-5ebf-4a9b-877f-3de7cce1642c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:46.715549
0adeb84b-9c3d-4440-8d5b-163331719d99	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:32:46.807123
ba5357b0-a7c7-4444-b772-2b51753ca43c	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:01.654494
30c1cb86-d47d-49b9-8d14-c0bab7e4fa61	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:01.704988
311ed5f5-e4f2-42e6-8fa5-78fe5be90886	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:16.644977
2c5317db-41bb-480e-929f-60bd93cc60a0	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:16.701592
86f42412-edf8-405d-8ac7-deec11f7dd3c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:31.66582
6c28f72a-15e6-4974-b6b3-08ac3790a77a	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:31.862003
af692db4-0003-4eb2-811a-f28921e67107	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:46.687274
09ed5766-ce38-42ec-a8c3-be9ccd1dea50	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:33:46.73802
6b66c63a-98bd-43a1-b3bc-9201c9bbc8ce	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:01.707551
05dae7cb-229d-4177-8cb4-eb0155ed4b0a	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:16.727525
26284fa1-0a27-447f-88ac-619959e8d2b5	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:16.773502
0851fb0c-12b7-4259-bb1d-f20d35617b5a	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:31.765704
a9d75287-1550-41e0-a38d-d58fd09f9f30	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:31.825274
e8819022-5236-4aad-bc45-fc3ebf54ac21	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:46.770381
fd496cae-0846-45e6-b7f6-7b032ef6632f	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:34:46.818185
270f2c33-56ba-44f2-ad2a-97c3723d34af	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:35:01.870857
84951240-4544-471f-920d-10047b3e4a9e	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:35:02.0757
5d98e2ed-9004-4728-9922-84cff0a5cd23	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 06:35:16.250156
99d8d46d-7448-45f3-b219-2ceeac4a7426	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 06:35:16.252891
d2ef47ed-8055-425b-83f5-e9b9355c04f3	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:35:16.259102
13c4dc52-40e1-49b3-9439-850941883b60	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 06:35:16.571387
a59d3eeb-2e40-4d51-a0c7-d327fbf01579	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:35:32.255615
68b4c39f-3c5a-4520-9ba3-ec3724627a04	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:35:47.23278
bbf5f08a-0b95-4652-8f0c-f93c79fa6b98	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:35:47.279532
0ba3a5ff-c9b7-4a2c-a53b-0c224863390e	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:02.255226
25d6efde-9877-4ee9-8f5f-6b258adf76ef	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:02.313918
bf99d120-163c-4f70-805d-2a7ea5bba531	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:17.278027
a935bccc-e97b-4ac2-a647-c0793e829688	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:17.334989
6480a010-3538-4d63-a23c-0369cc8c03f7	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -87, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:32.299394
b1487095-48fc-411d-b99d-2784c3fd85ad	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:32.351507
a9bd3eb0-8e41-4151-933e-84e7f841ca40	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:47.342091
ecba8927-4271-4aad-bdd6-8bbc04babb96	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:36:47.406839
7a72e3ea-d315-47f9-baf0-a55da04cd709	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:02.394811
5879fcf3-ae5b-47de-b517-ca0f5d1484b3	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:02.599255
b759242e-78dc-4417-a95c-e5d7f518bd68	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:17.447384
d23aaf1e-f8e6-4338-bae8-ba65838a1b2e	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:17.659378
7ce18a45-78af-4577-8cc5-8c445c5a2673	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:32.433097
e3600e90-f887-494d-b272-e12b54e648b2	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:32.602978
83a670f4-9b0c-46fe-b38b-79a2ed5742e9	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:47.409212
232efd42-69f7-450e-80ea-7cf89839a462	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -51, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:37:47.476341
4dec3fd8-3fa6-4a95-bab8-88f1d9aa1c5b	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:02.44195
45b4808a-513b-4cea-9fde-60c10d976e26	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:02.607195
6097ac07-7bda-4fac-a35a-33965cd1a2c1	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:17.56652
a24977c3-dd85-4fd4-a714-dd9f34013c01	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:17.809307
24209067-12e0-4000-a3f7-66ae868a2342	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:32.614941
4060d02a-62ca-4a14-9318-f4ce25980082	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:32.812965
ebf3bb3b-08ce-4b77-9e0a-dfd8177bb27f	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:47.492312
d24c80b7-0236-42ca-9b25-a10bfafa10b9	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:38:47.661127
93eb152d-0ffc-4c1a-bb30-a5df53d2dcb6	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:02.514962
dbbf6a3e-8129-48b2-8e2c-e87f7f49d673	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:02.612316
274c656e-128c-4d73-903a-7ae060fe6e2a	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:17.535956
37fc9fc7-a836-463e-b1d8-4832df5c25c3	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:17.593312
6f19bc22-5932-4d5b-bdce-8ccdf31a10fa	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:32.558774
d56000f1-d7a4-4a4b-85d9-a9de382e716c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:32.618901
cc65330e-f4d3-4850-b812-366d00966036	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:47.666363
e0b1abb8-8720-469f-8aa5-1c4162146eb4	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:39:47.872183
71efcd7b-2d4c-4e37-884c-3e167d21f7aa	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:02.616681
bddcd0e1-f342-4fd6-9098-605d0a2e9025	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:02.676843
f75aafa2-0538-4f05-b833-567627ab8dae	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:17.671484
199c7478-c154-44e8-9d71-9efcd890d9f6	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:17.78878
ed3dfa93-6860-4a47-a9f1-ae77c4407e32	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:32.642391
fc1e426e-4535-4da8-ac17-510e1f625035	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -73, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:32.695602
78feafd3-4691-48b4-acd1-147ee4b8e39c	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:47.663421
8c7a9397-6a4c-47f2-92a5-c22dda30835f	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:12:24.647248
c585edb0-6e14-421e-847e-6190b88fcc6b	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:12:24.647869
37f338ed-1353-47d0-ab3e-300e0d6ed931	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:29:47.125564
4a9825b2-a5ee-42da-9725-056265dc9f90	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:29:47.135051
954518f2-b1ee-4ec9-84e8-d10db14807ff	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:29:52.526797
f537e2a2-8a0b-4cbe-bf97-855544047063	\N	\N	inventory/ble	{"mac": "d8:f7:6b:4c:e2:23", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:29:52.681298
ae0d2898-52a0-43e3-9fac-3b3695db1ceb	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:30:07.613624
a78f35cd-86da-427d-be30-f8c5abf74bdb	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:30:22.58103
3677066d-baa6-4b97-8a08-df60d23b07f6	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -80, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:30:37.537668
22a42e8e-b54c-46f4-9c49-9b613b4380c1	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -72, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:30:52.557104
984cb38f-f8a5-4a6a-a14d-d3907220a9dc	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:31:07.576857
61d40709-6943-4a5d-8a65-a7740d1bd43d	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:31:22.596111
2b41fb8b-5c49-4fce-8da2-c377f7c489ce	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:31:37.615682
609b51a6-5d61-40c2-8202-5d17db067c61	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:31:49.107716
f0453b32-2746-42b7-ba0e-20e3182820c7	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:31:49.109675
156f1a86-bf8d-45ad-bed7-d4e44248b06b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:31:49.415031
20d320c2-1f5e-44bc-b949-bc2b410a9349	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:31:52.691973
b3714fb2-e059-43ba-8482-63571e67d9b4	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -42, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:02.028171
43916335-4f24-4655-ad64-21ed330b6fa7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:35:07.92423
4776161b-dfd6-469b-a626-fba390ff428a	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:41:46.587597
4a676a66-c2a3-4cb6-a547-03c4028d6f3a	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:41:46.598419
54e1ae7d-1f38-428b-8060-3644f42be976	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -40, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:02.98291
c401de72-b149-489e-8bf9-cd1a6e4fdea7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:08.52996
1a61b9f3-76df-4475-b23d-860809b8b891	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:42:09.090092
73c50fe8-2e97-4054-86bd-7cc0be318b2e	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:42:13.026468
f9d1f6d5-e40c-4cca-9295-8734fea3263b	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -43, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:19.068895
60b571e6-1cdd-49d3-8221-243b438c1004	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:42:23.470931
6d768de2-d353-471a-8878-e1a25df92587	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:23.675243
4bc5ad6a-b377-4655-ba1e-26836f7b3266	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:42:26.236104
41d6db30-f287-47d7-9b4c-8154f9f1d61e	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -45, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:42:32.995905
56e811a6-4dee-410e-ba96-2e91d2922cb2	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -54, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:03.310271
0d2f2c92-5035-4b76-9bdb-bbfd067c9c0e	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:08.635359
087af5a2-eb96-4919-ac98-3f0593795c89	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:44:38.74081
7f06eada-6488-4f7e-babb-9d12c2f4094e	\N	\N	inventory/rfid	{"uid": "44:DE:DB:E9", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:44:42.185031
05985fad-568b-4013-869f-fb66f2cd85f5	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:40:47.712548
27abf98c-3737-4679-93c9-a0df86f6c7a7	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:02.6855
95c9a1b1-b7fb-4d1a-9a50-eb6554e63d04	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:02.741013
c7d095de-6127-4445-b257-0623d61a64f5	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -94, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:17.78021
b2b66540-8092-4ee8-a25e-9d92345b97db	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:17.982569
4908f2d6-ef9c-42f0-b2b7-ac8906cdc77f	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -76, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:32.728676
5c996045-f91b-482e-a174-bfe096e49035	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:32.932165
02ee3aec-828b-42c6-9ff0-58533d5b08d6	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:47.781504
95e5f005-e45d-4967-8cd7-a8b0986926f0	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:41:47.846489
35f6f26a-1eba-49a5-875a-56aa1877fbe9	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -62, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:02.832803
365feb62-8672-4936-ad6b-0a9a8243e4c4	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:03.088389
b2f19116-31e7-45a4-a4cb-c9861692dd06	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:17.88906
9a65ba22-3cf2-4767-b1bc-8c43b518ff8d	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:18.091646
08c4a929-5618-4991-b2de-f62f9074fcad	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -83, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:32.814586
e917ea44-4e1a-4836-8073-8ced7fd4b17d	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -55, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:32.868348
056fe58f-46c9-4ef3-a50a-531daa6a3851	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:47.858464
393a09d6-2ff0-4ae1-a044-c1296305c205	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:42:47.90416
ebefd922-5dab-4dfb-b392-0c9809e222fd	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -74, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:02.941189
a3a55615-21fa-48e9-9d0b-6cdc30f1a227	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:03.14618
008ee36b-f4e8-42aa-b3a4-fd5f2456f5f2	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:17.971944
d9e7326d-ad8f-4a3a-9684-cf5801d8b577	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:18.264945
2c8804fd-c012-4f79-9673-17968cf1f1da	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:32.944934
eb763bf6-3218-43a4-a263-9c66124cc280	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:33.149239
7c16ec47-c606-4e8d-bbd7-c57feb93bd66	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:48.015036
a7cf6729-a8f1-45da-bf8f-1434b720dda8	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:43:48.201956
9112d3aa-c09c-4df6-af75-8875aab8d645	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -81, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:03.050171
6aaffe1a-cc2b-4101-82f9-7b994f48818e	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:03.25454
df037f5e-7753-4ee5-afca-7e90a5adffe0	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:18.000043
1f72b984-9e91-4a4e-9c60-ac9a4ee7e95a	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:18.062785
8b0ede1d-2244-4aca-8a32-7c7359969590	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:32.98656
cb16e56a-d44d-4e39-ba76-ccfb13989e27	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:33.040809
150aa778-2651-4113-8599-affe72059f46	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:48.007101
13762711-3e96-41dc-b1f0-bde6136fc559	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:44:48.106883
2ae1f6fc-e25a-4f78-9b85-49f4d98b0dc7	\N	\N	inventory/ble	{"mac": "dd:3c:d6:65:0e:35", "rssi": -77, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:03.061951
848d3337-06b3-45aa-ab27-9828a076e8b3	\N	\N	inventory/ble	{"mac": "da:6b:bc:26:64:85", "rssi": -91, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:03.451419
d34409e2-f599-485b-bbe8-732c65ec8416	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:03.47596
7d3e071b-11ac-4cb5-9a18-ac383e424aff	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:18.108129
6c6a4c83-87d3-4f94-8aae-7d56579faa9c	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:45:18.313056
878492e3-9504-47be-a5fb-926fd29330dc	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:33.091674
ebd36678-6c2e-438b-8d0b-67164374b9d5	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:45:33.263646
2c238458-e913-423c-9646-c07cbb6d90cd	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:45:48.092903
d5f67671-6c7d-4cf2-957c-7ac6b90b7ddc	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:45:48.151996
6d91d55c-b694-4a66-9988-4e4fbaefdce8	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:46:03.1647
1a3560df-ad90-4a22-a217-8edf5eafd90c	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -75, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:46:03.369521
874a8b83-6703-4599-836a-b5dd77f03a33	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -70, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:46:18.135882
118d3ed0-adc6-4b9d-a064-1650aaf689f0	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:46:18.217782
3ebaab8b-2927-48e8-bd27-c285e7ca5e55	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:46:33.26939
0a786ade-4d54-4c1f-a38a-097b03fd3ced	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -68, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:46:33.473978
83e99225-6f9a-4a4b-962a-47f43ef49ed9	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:46:36.319458
471b1f0f-b686-4a4c-ba3c-958fbaab3165	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:46:36.318822
be1fef94-e018-4760-8c3f-ffeea011db97	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -71, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:46:48.219977
d087154c-36d3-4424-992c-9023f8e03506	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -67, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:46:48.277625
9b448b1a-4228-4e32-9a69-96c9ff8dc886	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:46:53.062263
fc7df8a5-ab22-44fe-bb8f-8a72368441e4	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:46:53.062938
e0bf0896-bda0-4ce9-b17a-bb9510dff2fd	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:47:03.279001
8ada2097-bfcd-486e-a1b8-9de473b0ecf9	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:47:03.511169
d34f06e7-9008-4db8-9cad-05c319e66e36	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:47:18.325957
decf0cef-ae09-4b87-9bac-723905e12321	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -66, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:47:18.436832
3425fcfc-5e05-4cfc-a9d1-ecff91dc05c5	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:47:33.242512
7a7397c1-5acd-4156-99b5-05c9b8a3fb41	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:47:33.302267
b211e1c1-89e6-483d-b3b4-ab55e77d714c	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:47:48.264885
8af26f08-5871-49bf-aacb-e7008a6b113d	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -86, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:47:48.325029
456a535c-1158-4765-a402-63b540fe64e9	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -84, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:48:03.285192
4b7c0557-c632-4d94-8fe0-64e4a2edcdb8	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -52, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:48:03.336276
f14f72d7-e2f0-4483-bd9e-9a0c5238a06e	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:48:10.892616
2389a3cc-3283-49c3-8484-2118b9042795	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:48:10.893478
086f759c-e894-4f92-89d4-6959a82aad59	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:12:45.649033
4d360db1-32d7-4276-a34d-a924218c7f0a	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:48:18.33141
339321aa-40f3-46a1-8b73-dc16a46c5a53	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:48:18.401361
b6fde4c5-8b77-4b79-949b-5d277dc3b6a8	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:48:33.386355
20aef673-3f2d-489b-b8a8-02110f9c1878	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -79, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:48:33.588494
ee5d8e4b-716a-45c5-970a-24bc97007993	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:48:48.356931
60bbb033-f11c-40f8-b984-2b8aa64b82e9	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -65, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:48:48.44642
fe17ad3a-c9ee-46f0-a073-867f13ee3117	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:49:03.387469
22f75f02-1789-4180-bdb1-c63453359e4b	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:49:03.591048
8c32c963-f4cf-41f6-a52e-6fa45bea63e6	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -85, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:49:18.393141
0ffd7d90-84b9-4c81-a470-bd98791b5995	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:49:18.441813
4d8c9275-1fa9-4eed-8145-d4ae0452957c	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:49:33.49296
0e488403-351c-4004-82ac-120547b80e2f	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:49:33.670854
7d983eb7-0a0e-4f8d-a016-9eb7f282e200	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:49:48.482718
4413f920-1ad7-426f-a0fb-e50c118f2b39	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:49:48.646655
59656f14-645e-4d97-8daf-3752864e3ab7	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:50:03.456489
cfdb8ce6-9a17-4a70-9860-007708e3267a	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -63, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:50:03.512245
f7b060b5-27c1-43e0-b58d-1e99b8a504f1	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 06:50:39.994746
f897a418-f4ca-49ac-a2a8-a95fba975f1d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "offline", "reader_id": "esp32_labo_iot1"}	2026-06-17 06:50:40.093176
1b0be340-fea3-4a8a-8eaf-096b489180e3	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -78, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:50:48.556596
fadf6355-178f-4c8c-b8e4-55faeb855a0c	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:50:48.799724
7f686e49-10b9-4e6d-9307-5f9b162f2e21	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:51:03.603294
f59d6bfc-7035-493f-9324-24d96d5d27d7	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -57, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:51:03.705237
a1d7cd10-f40a-4f68-9d0f-b5a778557cef	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -64, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:51:18.654851
0f5423e0-0ca9-4733-acb3-a654bc9921bc	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -82, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:51:18.860381
cae8cf97-7964-49a1-9058-a0ab32f11d85	\N	\N	inventory/ble	{"mac": "f5:8c:72:79:03:86", "rssi": -69, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 06:51:33.605859
eced2ee7-69ed-4f80-9304-7efb1ed836c3	\N	\N	inventory/ble	{"mac": "e8:33:7f:d1:22:3c", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 06:51:33.661746
0fe16043-c469-4ed9-b755-333291126f4f	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "offline", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:12:45.649634
5a30eee3-226f-4812-b70d-738e802f9833	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -44, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:01.703138
76da521a-8f71-4a7d-a10b-75990c94ba1f	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -60, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:07.74471
db12650d-6a4f-40e2-8dab-dedfee447cb7	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -55, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:17.677525
6eb8b51a-a788-4b88-bd57-58ecf325ef4f	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1"}	2026-06-17 12:32:21.569281
d7205ca4-ef62-4117-8230-5e24ab9e734f	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -56, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:22.695123
a97e3c4e-b2f7-48ce-b280-80e8a82d1fd5	\N	\N	inventory/rfid	{"uid": "B4:18:FA:05", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2"}	2026-06-17 12:32:27.342862
e0a9d2fd-20e2-48d7-a54a-f96f472c0815	\N	\N	inventory/ble	{"mac": "ea:14:5b:e6:42:c3", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020001"}	2026-06-17 12:32:31.70809
f8228ef5-38fb-445a-b049-f86d204a5bfe	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:08.851461
4680af04-3101-4c15-9f6d-d531a725e2ec	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:18.582095
b0fe4f22-fec8-42d8-a1b9-c59fbc7c5e85	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -61, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:23.792229
1ad44af7-75eb-4cdf-9461-c273eb4f0e65	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -38, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:34.658392
95096827-ab94-407c-9dec-09350845b253	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -53, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:38.813249
32ca7be8-9218-40d2-8d37-0036cf3d250a	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -43, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:46:48.686509
b237609f-5d7e-4096-b2dc-9e6d3d98ee0b	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "online", "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "ble_mac_count": 0}	2026-06-17 12:47:06.664813
b6f403ea-b96b-4078-b0e8-efd483a5290c	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "online", "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "ble_mac_count": 0}	2026-06-17 12:47:06.665294
e43d666b-e76a-4be1-ad14-27c657f56a10	\N	\N	inventory/devices/esp32_labo_iot1/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:47:06.676246
2b029f8d-11f7-435f-9c47-fb282be9ae22	\N	\N	inventory/devices/esp32_labo_iot2/config	{"ble_macs": ["findmy:4c0012020002"]}	2026-06-17 12:47:06.676624
5bf09cfd-9ffa-4609-8f80-1054516f7d83	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -39, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:06.809812
a5ae24e4-97f7-4844-9e7e-e33eb426ae9d	\N	\N	inventory/devices/esp32_labo_iot1/status	{"status": "config_applied", "reader_id": "esp32_labo_iot1", "ble_mac_count": 1}	2026-06-17 12:47:07.833561
c660dbaf-d045-458a-87cc-efbd24e92055	\N	\N	inventory/devices/esp32_labo_iot2/status	{"status": "config_applied", "reader_id": "esp32_labo_iot2", "ble_mac_count": 1}	2026-06-17 12:47:08.847641
d0478a62-41c0-483c-ad39-1f974a066032	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -58, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:08.895834
250ade63-2b31-42cd-a17c-dd52440e65bc	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -35, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:22.774851
d029463f-2ef9-4c57-8542-f04edb993486	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -59, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:23.914689
fc4668cb-9abe-4d00-94e5-a7a59237e6fb	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -54, "room_id": "2cef73e3-e196-4f76-b04b-eb642eeb01ea", "reader_id": "esp32_labo_iot2", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:38.933922
09fcea3e-9c84-432e-96e0-8a4f6675dd37	\N	\N	inventory/ble	{"mac": "d0:0f:a0:c7:a6:0e", "rssi": -40, "room_id": "e88f0c40-f527-4e8c-9bb8-9819c02a70b8", "reader_id": "esp32_labo_iot1", "fingerprint": "FINDMY:4C0012020003"}	2026-06-17 12:47:48.895157
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, title, body, product_id, product_name, from_room, to_room, is_read, created_at) FROM stdin;
a434c663-9506-413e-87e2-2f9e6c7d7709	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	Asus Tuf A15 â†’ Salle G3	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle E3	Salle G3	f	2026-05-09 15:37:18.110234-07
a0bd2f4d-4b27-4df0-8285-b2bcc141b59a	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	Dell latitude moved from Salle G4 to Salle E1 by Technicien ISET	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Salle G4	Salle E1	f	2026-05-09 16:00:42.625731-07
5ee7a168-3066-4697-83a5-e30b056343bc	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	By Technicien ISET	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Salle E1	Salle I1	f	2026-05-09 16:04:20.963522-07
3c009810-ae3b-40da-8935-76ff83c61411	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	By Technicien ISET	d62e9fc1-1631-475f-a4c4-6a5e58f94df0	asus tuf a15	Salle I5	Salle E2	f	2026-05-09 16:07:13.818588-07
2f9ee9c6-0a92-44c2-b01b-505c56c524d2	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	By Technicien ISET	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle TC3	Salle M3	f	2026-05-09 16:49:10.629907-07
aaf86be1-8bcc-41ec-bcaf-4a9c4041f609	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	d62e9fc1-1631-475f-a4c4-6a5e58f94df0	asus tuf a15	Salle E2	Salle G2	f	2026-05-10 12:15:49.337999-07
8e3daa38-0ade-4ac2-bfe2-5669d0afcfd1	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Salle I1	Salle ADM1	f	2026-05-18 08:33:48.587496-07
b9baf287-e612-4630-b6c5-94dd6b77eca3	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Salle ADM1	Salle E2	f	2026-05-19 06:58:39.99807-07
c92fc089-0fea-480e-ac29-657e29999b7a	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Salle E2	Salle ADM2	f	2026-05-19 06:59:06.627566-07
4b92e679-56c4-491a-ba4e-51bda74f05d9	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_retired	Ã‰quipement rÃ©formÃ©	dell a Ã©tÃ© marquÃ© comme rÃ©formÃ©.	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	\N	\N	f	2026-05-19 14:31:58.889276-07
aba3ae30-9e5a-4796-9d4f-ef6a46c54f79	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	By Technicien ISET	\N	Test Photo Product	\N	Salle E1	f	2026-05-19 07:25:32.791306-07
f51e33f7-4381-4bfd-9784-a362262bc3ff	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Stock	Salle E3	f	2026-05-23 14:53:54.432475-07
52be1178-36cd-4e1c-8654-6cb274bed0e6	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Stock	Salle E3	f	2026-05-23 14:53:54.435892-07
143faa60-98a3-4af7-a460-bf624483d8b7	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Salle I1	f	2026-05-24 05:25:36.414054-07
62872325-3511-4d1f-a681-f01b8028471c	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Salle I1	f	2026-05-24 05:25:36.417838-07
6a0c9b41-4936-4e29-87a4-5a5c7734588f	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	asus found in Labo IoT 1 (was in Salle I1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Salle I1	Labo IoT 1	f	2026-05-24 05:25:54.338897-07
adf26fb3-b170-4b49-808f-2cd8007af1b8	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	asus found in Labo IoT 1 (was in Salle I1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Salle I1	Labo IoT 1	f	2026-05-24 05:25:54.339688-07
29991ad9-e785-4790-b388-b11c8c042168	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	asus found in Labo IoT 1 (was in Salle I1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Salle I1	Labo IoT 1	f	2026-05-24 05:25:54.341755-07
61cc56c0-9ba9-4208-9810-532395cf9599	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Stock	Salle E2	f	2026-05-25 09:28:58.282868-07
4c281282-8846-421a-961f-1cb3403d852f	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Stock	Salle E2	f	2026-05-25 09:28:58.293332-07
208a64e1-349f-42d9-b85d-b7e225e170ae	ec047e43-2773-4e39-ba1f-cada9466b508	product_critical	Critical Issue Detected	asus (ISET-PC-20260519-0003) has been marked as critical issue.	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	\N	\N	f	2026-06-02 02:42:44.325934-07
57550e59-c967-49bc-b59e-9a4540b7bcb4	9e891a68-effb-43b6-878b-a348575af2d6	product_critical	Critical Issue Detected	asus (ISET-PC-20260519-0003) has been marked as critical issue.	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	\N	\N	f	2026-06-02 02:42:44.327124-07
808cf74b-054c-40c6-a8a5-3717dff83b17	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle G2	f	2026-06-07 17:36:14.321898-07
02e01075-e184-4092-aab7-0f8ecb88062a	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle G2	f	2026-06-07 17:36:14.332239-07
8466079c-ba28-48bd-ae0c-48075195d869	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle G2	f	2026-06-07 17:36:14.332753-07
f4295784-2a5a-4cdb-9039-01feb623ea4a	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle G2	f	2026-06-07 17:36:14.333268-07
15f302a6-7808-4688-97dc-b41e4df748b0	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	DÃ©placement effectuÃ©	By hichem	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Stock	Salle E2	f	2026-06-13 05:55:15.836412-07
05df2ead-f098-4354-989c-5b52fff5fb1b	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Item Relocated	By hichem	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Stock	Salle E2	f	2026-06-13 05:55:15.860494-07
ae05cff4-a5a8-4657-9ee0-c9efb63b6b08	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By hichem	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Stock	Salle E2	f	2026-06-13 05:55:15.861564-07
e93899bd-d0cd-4edf-a3d0-5823e82b1821	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Item Relocated	By hichem	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Stock	Salle E2	f	2026-06-13 05:55:15.862707-07
38832a25-bac5-45ed-bc6d-27f5f9e35087	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Item Relocated	By hichem	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Stock	Salle E2	f	2026-06-13 05:55:15.863864-07
14609995-3473-454a-a138-1fff46994e34	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle G2	Salle E2	f	2026-06-15 15:31:15.062484-07
d3baccbe-6110-4e22-b659-c1c9a10b1115	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle G2	Salle E2	f	2026-06-15 15:31:15.079276-07
62bc3b96-00b7-4cf4-8908-24cb8206a9ca	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle G2	Salle E2	f	2026-06-15 15:31:15.080218-07
d686450d-31e0-4016-be4e-a2673d790c4a	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle G2	Salle E2	f	2026-06-15 15:31:15.081189-07
73d71dbf-d114-41fb-b629-a2c3a4abf07d	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle G2	Salle E2	f	2026-06-15 15:31:15.082154-07
91bc51bc-c190-44b7-83cd-106469454546	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_retired	Ã‰quipement rÃ©formÃ©	asus a Ã©tÃ© marquÃ© comme rÃ©formÃ©.	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	\N	\N	f	2026-06-15 16:02:54.349138-07
9e9f0610-58ee-4805-ba90-29cefacc2290	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.49855-07
cba21d04-1c6b-4575-9c87-71b39971810b	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.50573-07
313e26ad-051a-4c44-88d6-c370321ad841	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.506325-07
a0c6bad5-6f06-4974-9f55-2ada2afb7b5b	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.506921-07
aad3e830-490e-4f5c-bc41-16ec2886f68a	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.50747-07
ad34ded6-4901-4e1a-93f1-42247d10d23c	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 04:30:32.507946-07
0b9c9c9e-d310-4ba8-98ad-869773e4c725	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.307833-07
a4335d47-ab72-4d4b-bb97-f48469df8e93	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.317172-07
3c03d045-c5bd-40b7-bb0c-61357eedcb94	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.317621-07
7d6a830d-81e3-4d25-9d82-d04520b13c90	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.317992-07
4095ec2b-c3fa-4db8-8e99-c0ea9dafff3c	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.31836-07
a6a2162c-3254-437d-880a-89c836d31c4f	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	asus found in Labo IoT 2 (was in Labo IoT 1)	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	asus	Labo IoT 1	Labo IoT 2	f	2026-06-17 05:45:15.318783-07
ce8fdf76-64c7-4d30-a75c-cce9a4839989	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.472641-07
f05492e8-c88a-462c-a594-a0bf1e4ffb5c	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.474325-07
4377567e-71d2-4832-af85-40d72fb4ad0c	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.474815-07
2429e997-71e1-45c0-afed-2b591b95d47a	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.475356-07
e6287922-3829-4be7-ac04-633ab5c36c21	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.475873-07
d89137f0-6e97-42f8-9445-24410cde4c9a	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Salle M3)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Salle M3	Labo IoT 2	f	2026-06-17 06:26:16.476278-07
cf4fc59f-4656-48d0-86bb-09d99d26b7eb	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.410282-07
c6715aa0-80a2-4026-8322-84ddcfb45263	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.410587-07
3c653cd2-dab8-4060-9e96-3b0c43ccfec7	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.410837-07
68bcc825-179d-454c-af5e-5ed366ee760a	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.411778-07
157cce7f-cc3e-4c19-a883-3fe9b46fc1aa	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.41202-07
36fdf6e0-cb25-433e-9180-dcc0063d0341	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 06:26:44.412287-07
947eeaf8-d365-4b14-b042-310f09597832	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.926883-07
062d2c77-27f1-478f-b1fa-2cee95bb6691	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.92776-07
c29bfc11-84a8-4a7a-9dde-6326536fb317	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.928008-07
23308a0e-2604-4fbc-937f-a82507ba47f2	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.928247-07
1f5c8f27-c360-44e9-8964-e4a3e685f2e5	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.928506-07
e0febaf1-b7a1-447d-aeb8-674cc7a1c5b4	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product RFID Detected	Dell latitude found in Labo IoT 2 (was in Labo IoT 1)	10e89ade-6882-47d9-91dc-fc3ef4568077	Dell latitude	Labo IoT 1	Labo IoT 2	f	2026-06-17 06:27:18.928745-07
d48faeb5-cb2c-4298-a0d5-32c11be4822f	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.346675-07
1fb6cc9b-0b7f-479c-887f-df8e53018646	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.355234-07
58941b94-d18a-482b-9b23-ebf5527a6f95	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.355799-07
291cf3bb-5928-4633-8de5-e3e8abbfb54c	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.356271-07
25229ded-4368-464e-a7a2-9ec79bda6caf	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.356704-07
5a8d147a-cbe6-4ed5-bd56-1efe7e4ac9e5	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 2 (was in Labo IoT 1)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:32:27.357145-07
3b63aa7a-e15f-4adf-bcdd-e99cbcf4346d	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.030465-07
4249d136-d4ee-4606-980f-f590f4d10c98	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.031615-07
d2098549-a307-40d4-ba44-a731839e8142	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.032019-07
24da2745-9f68-4b83-aa20-bad1b9508f64	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.032398-07
8cfd7992-fd53-4d03-aa1c-950ac35ce296	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.032764-07
aca1c01e-f8fc-4bcb-81a4-5614568d886b	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product RFID Detected	Asus Tuf A15 found in Labo IoT 1 (was in Labo IoT 2)	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	Asus Tuf A15	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:42:13.033124-07
b65283bb-a45d-40a7-98bd-af2669cf37fb	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Salle E2	Salle ADM2	f	2026-06-17 12:43:53.654756-07
71dfd1ad-360b-4024-b208-cfb8a67514d8	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Item Relocated	By Admin ISET	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Salle E2	Salle ADM2	f	2026-06-17 12:43:53.656691-07
432022e3-79f2-4188-b501-1be11b042bbe	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Item Relocated	By Admin ISET	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Salle E2	Salle ADM2	f	2026-06-17 12:43:53.657243-07
bed89f11-98ca-449c-a0a8-fcc3f9707862	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Salle E2	Salle ADM2	f	2026-06-17 12:43:53.657936-07
94c9fb3c-b30e-4910-a603-6ccfd76596d1	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Item Relocated	By Admin ISET	f68c0de2-f37e-4610-90ea-2ddbeeb99476	hp	Salle E2	Salle ADM2	f	2026-06-17 12:43:53.658672-07
283b9503-3519-4f62-abc6-3219d9f2b8e9	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	DÃ©placement effectuÃ©	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle E4	f	2026-06-17 12:43:55.550056-07
33d9f9fb-c18c-4602-b940-b44cbb340ef6	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle E4	f	2026-06-17 12:43:55.551034-07
f5dde1f1-d0ff-4b63-916e-29c67f43768e	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle E4	f	2026-06-17 12:43:55.55153-07
71bfa0ee-1c86-47da-8b67-e333ecf0ff75	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle E4	f	2026-06-17 12:43:55.552065-07
2e4108ec-85dd-4f91-8202-b063b9b502f5	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Item Relocated	By Admin ISET	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	dell	Salle E2	Salle E4	f	2026-06-17 12:43:55.552499-07
c64f6507-40ad-4755-94cc-6f8bc8ae6cc5	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.572305-07
eee0e156-91d4-41ae-bbb9-cd7b8793ac91	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.573348-07
8920daa5-64a0-4b4a-9713-8e687f416d04	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.573739-07
1446a550-0e6f-4572-a7ea-5ff64b5fc1a5	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.574246-07
e4f56d9a-b5b7-41b6-8684-45aa7bfe9bbe	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.574881-07
a7d7f2f9-ab38-4d05-9370-97d653c76a93	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:45:48.575728-07
4c342888-5f1c-48bf-9ffd-d513386234ed	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.753901-07
6ae4e85b-21c3-4e29-be37-3088f294b6e6	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.754238-07
5a10b911-6e4d-4885-9ea2-fa2a0bd585b7	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.754635-07
c648fcde-9509-4ea9-ac4b-92d1aafeb099	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.754973-07
8e852dbd-c4d9-4ef4-8775-01e2b033ac63	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.755417-07
ba396f06-5f2a-419d-be93-03923190845c	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:45:53.755712-07
6ca97860-62ff-4e41-9ce5-1166aa312d33	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.656296-07
953600c0-b0ce-482b-9984-6967b46b7576	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.656683-07
51d7b8ae-c9d4-45c4-b0f8-7285c4d2bf5a	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.657041-07
0f64e0af-694f-4235-b36f-22ff751d6694	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.657384-07
d8a356e3-6da2-44fc-b16b-cb497808c18c	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.657727-07
391d863b-2173-41fa-b8e8-a1b781778746	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:04.658084-07
45345467-c0d0-4c43-90b4-bf8328188e26	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.853944-07
3b8b6f8b-caa4-4205-b323-3b1d9ac75e8c	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.854261-07
b0de2dbf-9bdd-499d-a905-577f7902b9b7	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.854553-07
9b117db6-02e3-45e8-9153-b4a4e8be0287	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.854997-07
6c83cf98-bb15-4fd9-a1c9-bccb3551d937	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.855362-07
5a4f39aa-4ab1-48fe-a911-10cd4ed9d141	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:08.855667-07
62a55fef-fd47-4751-a4ec-1be11aaeb81e	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.587769-07
80a9a4af-e4ab-4970-b6ba-0d570674f6d0	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.588646-07
33230cb3-6d41-48b1-8c53-25a5e0445fa5	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.589416-07
2d477ac0-a74f-48ef-b39e-37ba847b5345	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.590147-07
27224825-a49c-4688-b381-fddb8317b101	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.590957-07
93ac68f4-e7c2-49d7-b8b1-9cc5d471d170	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:18.592035-07
de3c434c-5b61-44bf-a034-5e8db32b3c2b	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.794964-07
5e80e7bc-9f96-40e8-9af9-c6bb1427127c	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.795404-07
961770e0-e0c3-46e2-9c7d-09ba0b4b6de3	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.795824-07
c448d131-ffe8-4d15-98b6-d43281f65783	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.796242-07
f3d5c35d-a706-468a-8bc0-9b153909f85b	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.796587-07
6b2e21cd-c0b4-48ff-b940-d1b94280d8aa	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:23.796941-07
e335c09c-f787-4198-94ef-5d6137b86985	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.660556-07
ea977f2d-79f1-4519-8950-7ece77918c7d	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.66085-07
36f67854-872b-41b8-a84b-0e9704de4932	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.661138-07
bf0018b4-651d-4144-946b-71d013fb70d7	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.661409-07
ce1a5de5-fa36-47fd-a5d2-443ab91d3f50	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.661687-07
6721d234-4e22-43cf-86f8-aa1b17012ef3	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:34.661965-07
684af417-e695-4a9d-9000-d0a7850abe02	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.817013-07
6513a080-5373-4510-bc8c-9dcd9e21640b	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.817391-07
3325f30d-8b17-44f0-9854-eb40fdd7558a	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.81775-07
9420f78a-2589-4bf4-ba78-12998fe7f43b	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.818094-07
e9a1105b-2dd6-4465-9183-a392fe7f7c79	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.818402-07
86e6eade-6028-458f-bbc7-835870e22a1b	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:46:38.81869-07
06a468c7-a109-46b9-b034-3d3b25cbe2b3	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.689156-07
7d5d98cb-ca49-4e04-95fa-0ff621d43e93	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.690146-07
48470aaa-fcc5-4b8c-84ef-a581772e0306	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.690452-07
b831a526-3cdb-4306-86f2-248fe765bccd	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.690739-07
8aab72ad-21cc-495b-83ba-afdc22dec39e	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.691015-07
19ed85c4-af61-4aad-8083-ae722b6fee84	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:46:48.69131-07
727bb36f-12bf-4f4a-b09c-762f118bd577	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.901069-07
1e08c8ac-cb31-463d-93be-2ce2deb02860	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.902269-07
9764db16-703f-4ce0-82f9-52888a62be97	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.902847-07
d20573d8-3516-4de5-9e16-a1816e243319	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.903284-07
3477dd91-62a9-48a4-882a-7a939eb3b7b4	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.903689-07
891e146a-214f-469a-a050-33bb30dec198	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:08.904146-07
5145c6c3-fb35-49e5-93ec-ff65b416a9e4	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.77766-07
540e0396-e3cd-431b-af91-6bb3512a7ed0	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.778016-07
6e7a5791-f0d7-458c-a631-7c94ea80d155	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.778316-07
5b5f0954-76fd-4f55-8967-d99b6b447c4d	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.778608-07
ffa1f4c1-f09d-476d-a353-cf2fff9b14fb	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.778975-07
1db51531-2f72-41b9-b4b8-ab82f5c27780	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:22.779348-07
cd7e83e9-3d79-4ecb-9bf0-ecf6db7ace73	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.916874-07
241bcaba-18ff-4167-92b1-a5cd221c683a	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.917189-07
c33eb8a3-a44b-4819-85b8-e5b003063e7b	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.917472-07
5da5c6ea-dbdd-4e47-bf90-0d5fa10f04e9	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.917753-07
e466a304-95b8-4947-81b2-900f876ee472	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.918036-07
71e7fdcd-5783-4a6c-b61d-cb1e18864d8f	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 2 (was in Labo IoT 1)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 1	Labo IoT 2	f	2026-06-17 12:47:23.91832-07
aaddc184-49ed-44d0-a79f-c1e24efcf600	446964eb-e597-4719-a13a-5cecdfa25567	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.89739-07
c15610aa-1745-416e-b421-ee8efe76c375	2433723f-63cb-4d0f-8f4e-36b39d806c4b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.897689-07
7a2d8492-3d71-4e76-b374-1562caee1203	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.897973-07
56cd1342-3d3c-434a-9415-f7afd5739f55	ec047e43-2773-4e39-ba1f-cada9466b508	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.898246-07
0c21d14e-bc54-49c8-9048-e18cd348031d	9e891a68-effb-43b6-878b-a348575af2d6	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.898519-07
a29609c2-0d43-4e57-b0ac-12ac9e8bd8c7	f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	product_moved	Product BLE Detected	wireless mouse found in Labo IoT 1 (was in Labo IoT 2)	f704853e-9a67-4bc1-8625-b0c74805bf62	wireless mouse	Labo IoT 2	Labo IoT 1	f	2026-06-17 12:47:48.898788-07
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (id, user_id, token_hash, expires_at, used, created_at) FROM stdin;
aeff7b51-fff5-4f8d-9413-045cd0c09683	446964eb-e597-4719-a13a-5cecdfa25567	c21c0233c8ec5b572bc5fc1b51f3c1b77c82e7e719e43e17179c0d6dec76c54e	2026-06-07 16:02:27.318509	f	2026-06-07 15:47:27.318509
e3fc28d8-3591-4bae-822e-2f42f950188b	2433723f-63cb-4d0f-8f4e-36b39d806c4b	a2042b3757cb4cf7c2d25f35a5a1894bd9bbf445339d35a4194570037445436a	2026-06-13 06:00:45.678477	f	2026-06-13 05:45:45.678477
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, user_id, category_id, name, sku, barcode, description, tags, quantity, price, storage_location, photo_url, qr_data, created_at, updated_at, status, qr_image_url, specifications, department, classroom, room_id, last_moved_by, last_moved_at, tracker_active, tracker_lat, tracker_lng, tracker_battery, tracker_checked_at, rfid_tag, ble_device, purchase_date, warranty_expiry, end_of_life_date, low_stock_threshold, tracker_hashed_key) FROM stdin;
bc32e7b3-7931-428b-a8ef-05b8b7bd5737	\N	5e3facda-bc8a-45c0-89f9-a2e9619a8483	Asus Tuf A15	ISET-PC-20260503-0002	MDL-7307E29E71	\N	{office}	1	3200.00	Zone D â€“ Salle i5	/uploads/1b483b93-8f3c-48eb-8c56-610c7a1df788.jpg	http://localhost:3000/api/products/scan?id=bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-05-03 07:48:27.979127	2026-06-17 12:42:13.028268	in_stock	/uploads/qr/bc32e7b3-7931-428b-a8ef-05b8b7bd5737.png	{"os": "Windows Pro 11", "cpu": "Ryzen7", "color": "Black", "ram_gb": "32", "storage_gb": "512", "screen_inch": "15.6"}	\N	\N	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	\N	2026-06-17 12:42:13.028268	f	\N	\N	\N	\N	B4:18:FA:05	\N	\N	\N	\N	1	\N
f704853e-9a67-4bc1-8625-b0c74805bf62	\N	\N	wireless mouse	ISET-GEN-20260429-0001	\N	\N	\N	1	20.00	Zone E	\N	http://localhost:3000/api/products/scan?id=f704853e-9a67-4bc1-8625-b0c74805bf62	2026-04-29 01:38:04.215371	2026-06-17 12:47:48.89678	retired	\N	\N	\N	\N	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	\N	2026-06-17 12:47:48.89678	f	\N	\N	\N	\N	DC:D4:4E:06	FINDMY:4C0012020003	\N	\N	\N	1	\N
5dbc9893-123c-481f-8dc4-becf10f22db4	\N	\N	computer asus	ISET-INFO-20260428-0001	1233654789	\N	{office}	1	0.00	Zone B	/uploads/5d153328-e9fb-4b5b-be9b-c0577d6caba9.jpg	http://localhost:3000/api/products/scan?id=5dbc9893-123c-481f-8dc4-becf10f22db4	2026-04-28 16:30:18.017223	2026-04-28 16:30:18.017223	in_stock	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
23801f7c-69bf-4022-91f6-80359ed7edac	\N	\N	wireless mouse	ISET-GEN-20260428-0001	\N	\N	\N	14	200.00	Zone F	\N	http://localhost:3000/api/products/scan?id=23801f7c-69bf-4022-91f6-80359ed7edac	2026-04-28 16:41:35.126231	2026-04-30 06:03:45.904486	critical_issue	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
bf783522-2a08-4c21-a48c-ddce8e7251d9	\N	\N	wireless mouse	ISET-ELEC-20260428-0001	\N	\N	\N	1	12.00	Zone E	/uploads/2dca252b-3a45-4ecb-a30b-8259ada8403b.jpeg	http://localhost:3000/api/products/scan?id=bf783522-2a08-4c21-a48c-ddce8e7251d9	2026-04-28 16:34:14.678654	2026-04-30 06:04:46.059449	retired	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
7cc9dc3f-3a9d-430b-9881-e3164d3052cb	\N	\N	samir	ISET-ELEC-20260429-0001	\N	\N	\N	1	200.00	Zone E	/uploads/d6b69224-72bf-4909-9210-adfe614b7c5c.jpeg	http://localhost:3000/api/products/scan?id=7cc9dc3f-3a9d-430b-9881-e3164d3052cb	2026-04-29 01:28:47.298437	2026-04-30 06:14:28.802582	in_stock	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
a8d3b8fb-9470-4490-b3b3-4c0763cf7551	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	5e3facda-bc8a-45c0-89f9-a2e9619a8483	dell	ISET-PC-20260519-0002	MDL-C79D8A5ABE	\N	\N	1	1222.00	\N	\N	http://localhost:3000/api/products/scan?id=a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-05-19 10:36:13.559186	2026-06-17 12:43:55.548799	in_stock	/uploads/qr/a8d3b8fb-9470-4490-b3b3-4c0763cf7551.png	{"os": "windows 10", "cpu": "i7", "color": "black", "ram_gb": "16", "storage_gb": "512", "screen_inch": "15.6"}	\N	\N	87de6ab5-c139-4366-a3f5-343bbdfd85b1	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 12:43:55.548799	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	5e3facda-bc8a-45c0-89f9-a2e9619a8483	asus	ISET-PC-20260519-0003	MDL-C79D8A5ABE	\N	{}	1	1333.00	\N	\N	http://localhost:3000/api/products/scan?id=dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-19 14:57:07.419753	2026-06-17 06:19:12.230133	retired	/uploads/qr/dbee2896-bfe3-4bf6-b47d-a9d0588b37b3.png	{"os": "windows 10", "cpu": "i7", "color": "black", "ram_gb": "16", "storage_gb": "512", "screen_inch": "15.6"}	\N	\N	2cef73e3-e196-4f76-b04b-eb642eeb01ea	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 05:45:15.304816	t	35.5228385	11.0321025	\N	2026-06-17 13:58:44.118651	72:1C:77:5C	FINDMY:4C0012020002	\N	\N	\N	1	wBlC0PBslYc1JY3ZG9Vt5I3jE4G7vM7R8pq/9KkunAk=
d62e9fc1-1631-475f-a4c4-6a5e58f94df0	\N	5e3facda-bc8a-45c0-89f9-a2e9619a8483	asus tuf a15	ISET-PC-20260503-0001	MDL-B4858A2A40	\N	{office}	1	3800.00	Zone A â€“ Salle i5	/uploads/e67df4bb-cb83-4d1c-a133-3f2b72ffc58f.jpg	http://localhost:3000/api/products/scan?id=d62e9fc1-1631-475f-a4c4-6a5e58f94df0	2026-05-03 07:40:55.938984	2026-05-24 04:34:48.49666	in_stock	/uploads/qr/d62e9fc1-1631-475f-a4c4-6a5e58f94df0.png	{"os": "Windows 11 Pro", "cpu": "ryzen7", "color": "Black", "ram_gb": "32", "storage_gb": "512", "screen_inch": "15.6"}	\N	\N	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-10 12:15:49.3261	f	\N	\N	\N	\N	49:A2:1C:06	\N	\N	\N	\N	1	\N
10e89ade-6882-47d9-91dc-fc3ef4568077	\N	5e3facda-bc8a-45c0-89f9-a2e9619a8483	Dell latitude	ISET-PC-20260430-0002	MDL-B479F6C3F2	\N	\N	1	1200.00	Zone D â€“ Salle i5	\N	http://localhost:3000/api/products/scan?id=10e89ade-6882-47d9-91dc-fc3ef4568077	2026-04-30 11:43:12.700082	2026-06-17 06:27:18.926346	in_stock	/uploads/qr/10e89ade-6882-47d9-91dc-fc3ef4568077.png	{"os": "Windows 11 Pro", "cpu": "i7-12700", "color": "Silver", "ram_gb": "16", "storage_gb": "512", "screen_inch": "15.6"}	GI	Lab Informatique 1	2cef73e3-e196-4f76-b04b-eb642eeb01ea	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 06:27:18.926346	f	\N	\N	\N	\N	44:7E:D1:E9	FINDMY:4C001219001B016B3B9FC60A32E5	\N	\N	\N	1	\N
f68c0de2-f37e-4610-90ea-2ddbeeb99476	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	5e3facda-bc8a-45c0-89f9-a2e9619a8483	hp	ISET-PC-20260601-0001	MDL-1558896DAC	\N	\N	1	1000.00	\N	\N	http://localhost:3000/api/products/scan?id=f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-01 06:44:10.184054	2026-06-17 12:43:53.652896	in_stock	/uploads/qr/f68c0de2-f37e-4610-90ea-2ddbeeb99476.png	{"os": "ubuntu", "cpu": "i7", "color": "black", "ram_gb": "16", "storage_gb": "512", "screen_inch": "15.6"}	\N	\N	cd29ab5d-75cb-4fae-ba2a-83514aa2a610	ec047e43-2773-4e39-ba1f-cada9466b508	2026-06-17 12:43:53.652896	f	\N	\N	\N	\N	\N	\N	2026-06-01	2029-06-01	2029-06-01	1	\N
f243f9f8-4d0c-438f-8fcc-e67b5a294985	\N	5e3facda-bc8a-45c0-89f9-a2e9619a8483	dell	ISET-PC-20260430-0001	\N	\N	\N	1	1200.00	Zone A â€“ Room 204	\N	http://localhost:3000/api/products/scan?id=f243f9f8-4d0c-438f-8fcc-e67b5a294985	2026-04-30 08:29:26.614178	2026-05-24 04:34:48.49666	in_stock	/uploads/qr/f243f9f8-4d0c-438f-8fcc-e67b5a294985.png	{"os": "Windows 11 Pro", "cpu": "i5", "color": "Silver", "ram_gb": "16", "storage_gb": "521", "screen_inch": "15.6"}	\N	\N	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N
a0bb9e91-259e-47a6-ae56-1ec0917cb96a	ec047e43-2773-4e39-ba1f-cada9466b508	\N	UPS APC 1500VA	UPS-001	8901234567890	1500VA 865W rack-mount UPS	\N	3	280.00	\N	\N	http://localhost:3000/api/products/scan?id=a0bb9e91-259e-47a6-ae56-1ec0917cb96a	2026-06-15 16:33:53.920387	2026-06-15 16:33:53.920387	in_stock	/uploads/qr/a0bb9e91-259e-47a6-ae56-1ec0917cb96a.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2023-05-18	2026-05-18	2030-05-18	1	\N
e29ea1c8-6d81-4153-aee1-181934646434	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Dell Latitude 5520	LAP-001	1234567890123	Intel Core i5 11th Gen 16GB RAM 512GB SSD	\N	3	1200.00	\N	\N	http://localhost:3000/api/products/scan?id=e29ea1c8-6d81-4153-aee1-181934646434	2026-06-15 16:33:53.679895	2026-06-15 16:33:53.679895	operational	/uploads/qr/e29ea1c8-6d81-4153-aee1-181934646434.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2023-01-15	2026-01-15	2029-01-15	1	\N
bc24d29b-9de9-4c44-94d3-f471490e0296	ec047e43-2773-4e39-ba1f-cada9466b508	\N	HP LaserJet Pro M404	PRN-001	2345678901234	Monochrome laser printer 38ppm	\N	2	450.00	\N	\N	http://localhost:3000/api/products/scan?id=bc24d29b-9de9-4c44-94d3-f471490e0296	2026-06-15 16:33:53.788582	2026-06-15 16:33:53.788582	in_stock	/uploads/qr/bc24d29b-9de9-4c44-94d3-f471490e0296.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2023-03-10	2025-03-10	2028-03-10	1	\N
a17d59a7-d5b6-4f8b-ae10-1b219fbd9570	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Cisco Catalyst 2960	SWT-001	3456789012345	24-port managed switch	\N	1	890.00	\N	\N	http://localhost:3000/api/products/scan?id=a17d59a7-d5b6-4f8b-ae10-1b219fbd9570	2026-06-15 16:33:53.813635	2026-06-15 16:33:53.813635	operational	/uploads/qr/a17d59a7-d5b6-4f8b-ae10-1b219fbd9570.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2022-06-01	2025-06-01	2027-06-01	1	\N
d57dfe53-c628-49e2-8b72-85232c38cd84	ec047e43-2773-4e39-ba1f-cada9466b508	\N	LG 27 Monitor	MON-001	4567890123456	27 inch IPS Full HD 75Hz	\N	5	320.00	\N	\N	http://localhost:3000/api/products/scan?id=d57dfe53-c628-49e2-8b72-85232c38cd84	2026-06-15 16:33:53.835082	2026-06-15 16:33:53.835082	in_stock	/uploads/qr/d57dfe53-c628-49e2-8b72-85232c38cd84.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2023-07-20	2026-07-20	2030-07-20	1	\N
2bec7224-cc29-4f27-be68-8d66b7c71e61	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Logitech MX Keys	KBD-001	5678901234567	Wireless keyboard backlit	\N	8	110.00	\N	\N	http://localhost:3000/api/products/scan?id=2bec7224-cc29-4f27-be68-8d66b7c71e61	2026-06-15 16:33:53.854787	2026-06-15 16:33:53.854787	in_stock	/uploads/qr/2bec7224-cc29-4f27-be68-8d66b7c71e61.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2024-01-05	2026-01-05	2028-01-05	1	\N
5c01b600-e09f-4cf1-b56e-773b8cfe7251	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Epson EB-X51	PRJ-001	6789012345678	XGA 3800 lumens projector	\N	2	650.00	\N	\N	http://localhost:3000/api/products/scan?id=5c01b600-e09f-4cf1-b56e-773b8cfe7251	2026-06-15 16:33:53.876302	2026-06-15 16:33:53.876302	operational	/uploads/qr/5c01b600-e09f-4cf1-b56e-773b8cfe7251.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2022-11-12	2025-11-12	2028-11-12	1	\N
faccc63d-f575-4cba-81e7-fba42426f3a0	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Lenovo ThinkPad X1	LAP-002	7890123456789	Core i7 16GB 512GB NVMe	\N	2	1800.00	\N	\N	http://localhost:3000/api/products/scan?id=faccc63d-f575-4cba-81e7-fba42426f3a0	2026-06-15 16:33:53.897845	2026-06-15 16:33:53.897845	in_maintenance	/uploads/qr/faccc63d-f575-4cba-81e7-fba42426f3a0.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2021-09-01	2024-09-01	2027-09-01	1	\N
24cbda3b-bb63-4ac3-b461-658ecb15509a	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Canon EOS M50	CAM-001	9012345678901	Mirrorless 24MP 4K video	\N	1	750.00	\N	\N	http://localhost:3000/api/products/scan?id=24cbda3b-bb63-4ac3-b461-658ecb15509a	2026-06-15 16:33:53.947022	2026-06-15 16:33:53.947022	operational	/uploads/qr/24cbda3b-bb63-4ac3-b461-658ecb15509a.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2022-08-30	2025-08-30	2028-08-30	1	\N
19c1b9de-6a43-4e40-b2bb-5a10fc759d7d	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Raspberry Pi 4B	IOT-001	1122334455667	4GB RAM single board computer	\N	4	85.00	\N	\N	http://localhost:3000/api/products/scan?id=19c1b9de-6a43-4e40-b2bb-5a10fc759d7d	2026-06-15 16:33:53.973107	2026-06-15 16:33:53.973107	in_stock	/uploads/qr/19c1b9de-6a43-4e40-b2bb-5a10fc759d7d.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2024-02-14	2026-02-14	2028-02-14	1	\N
1c38b1a0-c806-4b6e-9844-ab2ea445b50e	ec047e43-2773-4e39-ba1f-cada9466b508	\N	Brother MFC-L2750	PRN-002	2233445566778	Multifunction laser printer	\N	1	380.00	\N	\N	http://localhost:3000/api/products/scan?id=1c38b1a0-c806-4b6e-9844-ab2ea445b50e	2026-06-15 16:33:53.99613	2026-06-15 16:33:53.99613	critical_issue	/uploads/qr/1c38b1a0-c806-4b6e-9844-ab2ea445b50e.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2021-04-22	2024-04-22	2027-04-22	1	\N
1a5c3b87-1ee1-4e0e-8ebe-d154a0b1569f	ec047e43-2773-4e39-ba1f-cada9466b508	\N	TP-Link Archer AX50	NET-001	3344556677889	WiFi 6 AX3000 dual-band router	\N	3	120.00	\N	\N	http://localhost:3000/api/products/scan?id=1a5c3b87-1ee1-4e0e-8ebe-d154a0b1569f	2026-06-15 16:33:54.01954	2026-06-15 16:33:54.01954	operational	/uploads/qr/1a5c3b87-1ee1-4e0e-8ebe-d154a0b1569f.png	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	2023-10-01	2026-10-01	2029-10-01	1	\N
6f21e44c-f042-4c39-9d79-889524e825a1	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	5e3facda-bc8a-45c0-89f9-a2e9619a8483	hp	ISET-PC-20260617-0001	MDL-CB1BEE1E48	\N	{peripherals}	1	1200.00	\N	\N	http://localhost:3000/api/products/scan?id=6f21e44c-f042-4c39-9d79-889524e825a1	2026-06-17 11:50:12.714887	2026-06-17 11:50:12.714887	in_stock	/uploads/qr/6f21e44c-f042-4c39-9d79-889524e825a1.png	{"os": "windows 11", "cpu": "i7", "color": "silver", "ram_gb": "8", "storage_gb": "256", "screen_inch": "15.6"}	\N	\N	00123347-ff8d-4943-a216-aaee0cb429a8	\N	\N	f	\N	\N	\N	\N	\N	\N	2026-06-17	2026-06-17	2026-06-17	1	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, user_id, token, expires_at, created_at) FROM stdin;
9ab4c3a0-1183-42e5-8a87-376fca6e898b	ec047e43-2773-4e39-ba1f-cada9466b508	a46ab0637e33b4f403e1e560f439afffed13eace20a17321b3465324a8229df3	2026-07-15 16:20:53.434309	2026-06-15 16:20:53.434309
a26d32b9-dc41-4c76-8c54-28a99cb452e8	ec047e43-2773-4e39-ba1f-cada9466b508	409402072cbfe02b60a182dc65913ff6e30b86f59c1deb587592846a42fc0c0c	2026-07-15 17:19:38.458451	2026-06-15 17:19:38.458451
639114ba-07ff-4cdc-88f9-36794cc4a541	ec047e43-2773-4e39-ba1f-cada9466b508	e55d9d2f7c025999219bbba81f14c09dfc02dd300d2c5abc9db1dd14e3d8b8ae	2026-07-17 04:41:29.962588	2026-06-17 04:41:29.962588
abe37084-35a1-4dbd-80fd-fb3744afe484	ec047e43-2773-4e39-ba1f-cada9466b508	77b0eaf0a17d4e6772bbcfeae36f3b051b453086fb438c26ae056e76613f6d05	2026-06-06 09:42:09.369065	2026-05-07 09:42:09.369065
c1a546d4-b0e2-4b78-9447-6b3c02475ebd	ec047e43-2773-4e39-ba1f-cada9466b508	9307d0bbc736840ac0b7e4fb208e949ab78966a25383e981acf35e4e844a810c	2026-06-06 09:42:19.878152	2026-05-07 09:42:19.878152
5d8ce485-1d49-40e7-891c-f9723491cc91	ec047e43-2773-4e39-ba1f-cada9466b508	d963c42b2dda53e507a257bd1f36dd563f1ad42c681d8429aae5d504b6ca7cd0	2026-06-06 09:42:45.248415	2026-05-07 09:42:45.248415
0d38a964-21a8-44fe-bdee-d482158b4c0b	ec047e43-2773-4e39-ba1f-cada9466b508	83a0bfdaa3022655245e6b7a2c047ee7541f4c6e0ef5c17a15baa0bc04d408bd	2026-06-06 09:43:01.707453	2026-05-07 09:43:01.707453
8fcff508-60bd-4fdc-ab7a-94ea14859d1d	ec047e43-2773-4e39-ba1f-cada9466b508	62eb7c14fcb859d742152475533053f7195cf6db548e05a1ad27af28533e5acf	2026-06-06 09:48:06.0674	2026-05-07 09:48:06.0674
0c20e9de-b041-4eb2-a766-b947c10d7daf	ec047e43-2773-4e39-ba1f-cada9466b508	258b9f254f3efae11745d803dd783870ca71c4055807a02c8e08ef4b10e85a33	2026-06-06 09:57:08.994174	2026-05-07 09:57:08.994174
41b8ece3-9728-46f8-a28c-6548f5823241	ec047e43-2773-4e39-ba1f-cada9466b508	7a38de3ec2e5f5d006712df798ed0b91911d5340213bc2d10a65aebcbc46c831	2026-06-06 09:57:19.234762	2026-05-07 09:57:19.234762
77399df9-ec53-4f39-b027-1a2a19e2385b	ec047e43-2773-4e39-ba1f-cada9466b508	17b23ea648b72b0852e57cee75264f987bcb88e5b4c18b8fc2e694f218ecd04c	2026-07-17 04:42:06.71426	2026-06-17 04:42:06.71426
5dc1ca81-6811-490e-872b-6246e6636d0d	ec047e43-2773-4e39-ba1f-cada9466b508	8bf0aa226758e2e1ce5d8778c69102480a4211e42934662640904283e6625ce0	2026-07-17 04:42:14.522168	2026-06-17 04:42:14.522168
a278a095-00dd-4089-a33b-f85ba886758b	ec047e43-2773-4e39-ba1f-cada9466b508	3c1a7cf364dd00e5886f986b8737b127ae9f4ecd1904e55a73bc499b569a8115	2026-07-17 04:42:20.359868	2026-06-17 04:42:20.359868
fe04de15-6793-4897-a8e8-e64e1d657d8d	ec047e43-2773-4e39-ba1f-cada9466b508	2a0cc434b9c39e42f8a94fcd16a8bfa4db4d879c5c00b6a30dafaaf7a3f42ffb	2026-07-17 04:42:28.004553	2026-06-17 04:42:28.004553
4fcb4901-e40a-4a2b-9586-8e44ff06943a	ec047e43-2773-4e39-ba1f-cada9466b508	6d36930cc9275c5e4ac9a3fec919c4eae44209c0017b41e557ed1c9e32255668	2026-06-07 04:31:12.279862	2026-05-08 04:31:12.279862
f08fe578-f43b-4956-871d-ed1e663a2bcc	ec047e43-2773-4e39-ba1f-cada9466b508	2bc1d43fbf55d9fb8744c9f238b05a3dbd4b7842d8fb1602620c67e9c98b9abe	2026-06-07 04:45:48.489345	2026-05-08 04:45:48.489345
8984a3cf-a84b-48cd-9536-02af90c62c48	ec047e43-2773-4e39-ba1f-cada9466b508	9396923c88009e06bff499e284bd69d1dce0387c538fee18ae788ee104b4b86e	2026-07-17 04:42:34.880382	2026-06-17 04:42:34.880382
4da0a529-19f2-4eae-b286-9ddb0fb4b3f9	ec047e43-2773-4e39-ba1f-cada9466b508	916c1761d53eef621a0c631a9ccd7d48fa22ebbf6107d3187ca3e8a7eff01de7	2026-07-17 04:42:40.892965	2026-06-17 04:42:40.892965
48c0c6e6-d6fa-4f9c-8338-b1229b32aea7	ec047e43-2773-4e39-ba1f-cada9466b508	05a6232364578a54cb60a69c808e5017e7cc46c98ae05d8db5c3e1bfe14b8175	2026-07-17 05:20:56.130502	2026-06-17 05:20:56.130502
ad4e693f-ae1c-4188-9512-473bc0babdac	ec047e43-2773-4e39-ba1f-cada9466b508	5bf9910f7fc4aa0c83cc885ec0071fed8dd817089aebdf7eefc8cf5420ba116f	2026-07-17 05:50:21.368674	2026-06-17 05:50:21.368674
59a5e628-ea27-48c9-a2a7-ede5128425a8	ec047e43-2773-4e39-ba1f-cada9466b508	2e2c73a6ae58c4b63f00646cbdbebf05e211611d1274c5c695e57d694cee1c2a	2026-06-08 15:25:35.127468	2026-05-09 15:25:35.127468
975f1705-0d76-478f-8140-a6d574328b7a	ec047e43-2773-4e39-ba1f-cada9466b508	6ba3788747aeaa52a8e4e44a699ebbd9dc69e5c1c084523e6b47d84cd2550845	2026-06-08 17:13:32.076939	2026-05-09 17:13:32.076939
8bfa3a3b-56db-41d4-b07e-1e1a69b1030a	ec047e43-2773-4e39-ba1f-cada9466b508	2314c609e9a891fdb8bd1b59b994203e157f4464417c38402a0f7d4f4b2f4c7f	2026-06-08 17:16:55.181595	2026-05-09 17:16:55.181595
727e0302-abd6-4bb3-bb4a-032d7b9b2dcd	ec047e43-2773-4e39-ba1f-cada9466b508	b226851b5c514e4a9aaed60d85ab3c5dc3d9d195416cbd8dd0b2ff72d135975a	2026-06-09 12:15:01.873755	2026-05-10 12:15:01.873755
7b2d6118-f642-4fb5-a1f3-3a920dd15e40	ec047e43-2773-4e39-ba1f-cada9466b508	7f455a2bd64cf0dba1da1276263f37c45f869b3c5b31619e74e6aaf3c0945600	2026-06-09 12:55:21.225547	2026-05-10 12:55:21.225547
5ea59722-0d61-45bf-ad0e-50c2fdbdce9f	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	56a67379a018423131cce99cc711b18508d6d6a41512f2bfe67c17dcdf8fd042	2026-06-09 15:22:50.510816	2026-05-10 15:22:50.510816
a795eaca-a943-4710-8f12-e4ed80d817da	ec047e43-2773-4e39-ba1f-cada9466b508	3d79a7a7af17392e1f601a52c135e6090160e71ce1c804d40628cb8bf46201c2	2026-06-17 08:32:43.284443	2026-05-18 08:32:43.284443
b188cb5e-804f-452a-83d4-dbe35fb50e13	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	ffc1e91a0f21c79114c9b2c6d2088d936821b02d389197d062956cd22de9e489	2026-06-18 07:27:30.856156	2026-05-19 07:27:30.856156
c0aeaba9-1219-4aef-95fe-51aa7639c223	ec047e43-2773-4e39-ba1f-cada9466b508	cf67a0a3cd7c671b14e3342d2af6531ad6d2ed75edd9bd6f91210f2456aee8d0	2026-06-18 09:43:47.915653	2026-05-19 09:43:47.915653
b2a57909-0afe-4272-b003-6e7a8fd3b521	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	468a5107fac0d30188b6026e65b08069b469f3de6904f70c78cb47fb6cead28f	2026-06-18 10:18:00.192317	2026-05-19 10:18:00.192317
4596b495-28c7-4bc8-abbf-3119af34d79b	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	2612889c3fd1c7052b4335bfa8a4749bbe87e233318f5fceea58e16334b6dd00	2026-06-18 10:33:11.96579	2026-05-19 10:33:11.96579
7ede7367-bd2d-4932-ac6b-aab9d67916de	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	dc630fe21e0f2be552e045749b49f4cd8e6df85a6564a47463e3a89c505b8031	2026-06-18 14:32:23.442235	2026-05-19 14:32:23.442235
9e680e7f-5833-4df5-a55b-9cd0a502577d	ec047e43-2773-4e39-ba1f-cada9466b508	9999bf84b7a6cb6190a1c0a80970b47f6dcf18b728748fa34b2618a76b828bcb	2026-06-06 08:34:22.979676	2026-05-07 08:34:22.979676
47ab1039-4b0c-4a2a-bc44-abbfda13f3a2	ec047e43-2773-4e39-ba1f-cada9466b508	f27d5ce950e7fa4313d6b329b048b7ef57c7931d3ad4778b7235ed8aa90ab44f	2026-06-18 15:20:42.640563	2026-05-19 15:20:42.640563
10d8cfdd-d0cf-4b79-8612-cb7ff92135d4	ec047e43-2773-4e39-ba1f-cada9466b508	36c53e165ad98ab8ce1286fe9c839ff3ca7c9fe711feef3eba666930077062f4	2026-06-18 17:52:22.09493	2026-05-19 17:52:22.09493
a8fefe95-c88d-4465-a5d1-61b3831bb785	ec047e43-2773-4e39-ba1f-cada9466b508	fbf35d9590c1346f77dc0d7c6da5f7c0bdd1c9afd2c8d83eccf093dac17eec1c	2026-06-19 07:52:20.698759	2026-05-20 07:52:20.698759
f504c164-3c67-42ef-bc5d-72c32b28e212	ec047e43-2773-4e39-ba1f-cada9466b508	93e194c8379a7c67dbaf8409b1618e694178da2d5157017ea50b4a452c9fb1ea	2026-06-19 07:56:59.344482	2026-05-20 07:56:59.344482
5fa46de8-6cfc-4acc-8aa0-fcb8b95988da	ec047e43-2773-4e39-ba1f-cada9466b508	efb5bfb3f829d4a16f6e848705479adab9c2f68ba87a10d8f82f02720a5a2667	2026-06-19 08:08:16.53705	2026-05-20 08:08:16.53705
7e1bef68-4609-4d4b-ae56-f184f4b03207	ec047e43-2773-4e39-ba1f-cada9466b508	5ca3dc337784bda631eb1a349695eb381b17ffe01dd56d932495895003bd8398	2026-06-20 12:37:11.951615	2026-05-21 12:37:11.951615
cba382fa-f35a-44d0-ada5-a01bd1fae8a1	ec047e43-2773-4e39-ba1f-cada9466b508	0c8766f3d700cf9de6565d34246a8b052e08ed778abd757d9fa176334ca34e5a	2026-06-20 13:17:52.689193	2026-05-21 13:17:52.689193
42e25981-7d84-4766-9980-aab979a4bc94	ec047e43-2773-4e39-ba1f-cada9466b508	2f0d909f07ed86ed79e9f0c7e7eddc741c984f76fb5ec06ff7a2e915200305cd	2026-06-20 15:49:41.41259	2026-05-21 15:49:41.41259
35e67109-9e1b-4038-8f0d-058090882e7d	ec047e43-2773-4e39-ba1f-cada9466b508	ca3b004ae5bb5d5f5b50b7801ca60ade9c446735f13ba9cacaa83f8b26af13c3	2026-06-20 18:57:22.368372	2026-05-21 18:57:22.368372
9f357b33-4e23-4c32-bc1f-1b2dccc096d1	ec047e43-2773-4e39-ba1f-cada9466b508	c9dc71f2ea546205db7a654038b8d63c2519503d1c7d54e439759ebcfe8d9998	2026-06-20 19:11:55.802964	2026-05-21 19:11:55.802964
3fea0776-9fee-41ae-b2db-bb20bdd0f6b0	ec047e43-2773-4e39-ba1f-cada9466b508	8c45ca9ddff22a384db31f470e08b98d086498610fa967986e6bb6b0b5a4e8dd	2026-06-20 19:24:20.972217	2026-05-21 19:24:20.972217
cd820939-e591-43d8-af6f-56828a63c9bb	ec047e43-2773-4e39-ba1f-cada9466b508	234d958f40e7f99f30999f703845f441dec57601d859f5e74f9cf241e09c68d6	2026-06-20 19:29:13.577192	2026-05-21 19:29:13.577192
5a022828-d7a7-41d5-8bf0-2a1e8fbd8747	ec047e43-2773-4e39-ba1f-cada9466b508	c3b26f615e6969c4f2b99aa7088e8440be65d05e47cedfa809aad9ca48f8ee7a	2026-06-21 07:20:21.900803	2026-05-22 07:20:21.900803
e73723d1-f464-4e70-8acf-ae6374369e99	ec047e43-2773-4e39-ba1f-cada9466b508	5ed72aeeb936280cf1a667f0d93a71a66e3a28e0db93c76e90c3ac64da66ba8b	2026-06-21 07:27:37.875838	2026-05-22 07:27:37.875838
fa859709-fa9e-450b-ae10-1ae37a502780	ec047e43-2773-4e39-ba1f-cada9466b508	c3689923c552b9862b800fef8eb15bc1eca8a1ee46d16bbfb4b26ba0695a3747	2026-06-21 07:28:32.731587	2026-05-22 07:28:32.731587
ccce2b3e-6143-40bc-a5c2-304e2b13eb59	ec047e43-2773-4e39-ba1f-cada9466b508	fac90e29bb8c84f9fea33331d8f5e82f21ef392916809fbf6113b3416016e570	2026-06-21 07:33:59.857779	2026-05-22 07:33:59.857779
b5cd422c-9aed-4f90-9f24-111375958813	ec047e43-2773-4e39-ba1f-cada9466b508	3527db26983e27a546213d89821dbd07af6cfc844c7a229c7eb1edcb8fe0200b	2026-06-21 07:49:19.935769	2026-05-22 07:49:19.935769
c0d19836-80c7-48cd-ab37-9d0b90f39da7	ec047e43-2773-4e39-ba1f-cada9466b508	8d506a8096236d89921e469e13a9c7b3fe7190d1ec935fd6366bc3dd3bce8e7a	2026-06-21 10:10:14.084511	2026-05-22 10:10:14.084511
d4240363-de65-4846-877f-b3edc96a09a5	ec047e43-2773-4e39-ba1f-cada9466b508	1dfba7d4b6f196b80f92f51429efedbf5f403fe5a56e041dc2fe229be4183406	2026-06-22 14:33:25.85128	2026-05-23 14:33:25.85128
d1467ad7-0a82-4809-b1a6-45bb260ecba2	ec047e43-2773-4e39-ba1f-cada9466b508	53f1a7e5624da7f50d8b4940846e12ae806f170694e4ee2f2b355329e56388fa	2026-06-22 14:43:33.071331	2026-05-23 14:43:33.071331
50b2fbc7-6dcf-42f1-92f9-0872ce453093	ec047e43-2773-4e39-ba1f-cada9466b508	8dcfea2de86e4d0b9229a42189756ddef411f1321ff27929ac5d6260936e5b1c	2026-06-22 14:52:19.794199	2026-05-23 14:52:19.794199
06883018-d7f8-4b22-893d-0674502c5556	ec047e43-2773-4e39-ba1f-cada9466b508	b5c8ad0eb757937bab8e61108b3164f5d78d814d442d0918457b741b119b6303	2026-06-22 14:56:29.892434	2026-05-23 14:56:29.892434
9a585a56-b4ea-434b-92a9-69516bc5ea9d	ec047e43-2773-4e39-ba1f-cada9466b508	8e81935962b6df51636a8531c575c775eca81dd26ed62fbb8eb3f72b7e8a49ac	2026-06-22 15:18:10.065224	2026-05-23 15:18:10.065224
5d5c8339-3714-48ea-a642-55d881cec602	ec047e43-2773-4e39-ba1f-cada9466b508	c907a228b0264017bb34425d7eef18b8a324d752003bb75b5a42c500f6fe36f5	2026-06-22 15:41:42.556465	2026-05-23 15:41:42.556465
3cb6a15a-5f13-4c45-b9b6-f292d90b3ff3	ec047e43-2773-4e39-ba1f-cada9466b508	3f1b50525c471d505a87b12dda1081e5c18af888c5a8ddc2b2f9a6e93c65204b	2026-06-22 15:52:22.929193	2026-05-23 15:52:22.929193
b6a62d96-6220-42aa-9f5f-fb4f4aa9f2e7	ec047e43-2773-4e39-ba1f-cada9466b508	5628a78260eea461df61155a498b6a57c3bcabe376a1c616493bd416a568dd0b	2026-06-22 16:44:03.48593	2026-05-23 16:44:03.48593
4736b828-2f8a-4203-9dc3-c27357122c71	ec047e43-2773-4e39-ba1f-cada9466b508	7bacf5dab17f088a06b32f9bac03728d0af8ecd482dc7dd13ead24341fc9187a	2026-06-23 04:28:02.744035	2026-05-24 04:28:02.744035
757d0c57-2e41-4a74-92a6-84e4e4a58892	ec047e43-2773-4e39-ba1f-cada9466b508	73cd2adbd40eb26253cd4537163a6940594c06116c925572af4b07e2420163dc	2026-06-23 05:19:01.683324	2026-05-24 05:19:01.683324
e87e7ab2-4046-42d2-b14b-48c28cde2fcc	ec047e43-2773-4e39-ba1f-cada9466b508	df22532e22123d9d2a7209611851669f0b39afc165d4920f8b00461c16c4ed48	2026-06-23 08:51:11.029621	2026-05-24 08:51:11.029621
dca315d5-7f13-4d67-8400-e08111af17da	ec047e43-2773-4e39-ba1f-cada9466b508	6ece68045413b28f77144781bc0efaf9573ec3b7d6f2e45a0a261a981d883814	2026-06-23 09:54:28.036397	2026-05-24 09:54:28.036397
05819ce9-7eeb-4233-830f-468d6a5740f2	ec047e43-2773-4e39-ba1f-cada9466b508	07e73f1576d6a9a03390f6550848653d092adb007c5d50a2040f216b8fe03bf6	2026-06-23 10:22:23.637167	2026-05-24 10:22:23.637167
91922dea-3435-422d-8a79-fcbf84bfe7c3	ec047e43-2773-4e39-ba1f-cada9466b508	c226de724cc6e474e12a1ea0db340800d7933ff760f761b4cff8d8fdcea87a10	2026-06-23 10:27:11.894144	2026-05-24 10:27:11.894144
705d9fdc-d090-4549-a692-9a6a223edad2	ec047e43-2773-4e39-ba1f-cada9466b508	0e018b42e3f18b66c064ad57193f7b84142ebe91dda03dbeba80d9f1304167f4	2026-06-23 10:32:33.218708	2026-05-24 10:32:33.218708
f3044f8b-6878-4a71-b50d-81e61ef0b502	ec047e43-2773-4e39-ba1f-cada9466b508	3a86b882b8e8f2f1c8e4bc9a84897b4462b13a73a432d18eaa80f2f6a09adf62	2026-06-23 10:54:49.113144	2026-05-24 10:54:49.113144
58314801-f268-46d4-906f-8f15495b9d1a	ec047e43-2773-4e39-ba1f-cada9466b508	01ea8cbea624c72740f37d8c85615a61666aa0780f8640b03eb158bebd849650	2026-06-23 11:31:08.436772	2026-05-24 11:31:08.436772
814d5869-fa64-4071-9852-73a2e3b74f98	ec047e43-2773-4e39-ba1f-cada9466b508	0c6770752e249ff925548961c3407e40a4d7b9439b7923286429b959d46a6e37	2026-06-23 11:53:03.492438	2026-05-24 11:53:03.492438
b9bdc93c-ef9c-4aca-af7c-94fbea5671b8	ec047e43-2773-4e39-ba1f-cada9466b508	2cf894dbc409850e5f075aec830a2dd036233b0029ee1f7e353367272baf8b8d	2026-06-23 11:54:24.87995	2026-05-24 11:54:24.87995
5ed75767-79cf-470b-ac55-c6fcf9c560e1	ec047e43-2773-4e39-ba1f-cada9466b508	c9ec09c6fe59434a3ac17b66b3ae1606fb846ccef212e84915f8e18c316fa2fb	2026-06-23 12:36:23.83041	2026-05-24 12:36:23.83041
a6d5f92b-8bf3-417a-a3fb-d84e1762f741	ec047e43-2773-4e39-ba1f-cada9466b508	7c16486b6dc1d652e4d4e38ce03bf16c60d468c3a88afdc0d27bcbc6d9c28a45	2026-06-24 09:27:04.923152	2026-05-25 09:27:04.923152
6dbda1e1-46fc-43ba-a992-ef85dc829e2b	ec047e43-2773-4e39-ba1f-cada9466b508	a899e414a1960f8ee5d487bae26e5694fcf588b6ee246dc11081609c76d724ff	2026-06-29 12:07:08.915509	2026-05-30 12:07:08.915509
5823bab2-2995-4265-bb8f-4a8fa0897740	ec047e43-2773-4e39-ba1f-cada9466b508	7a8ec05ff3fed363d3b3ff7d0d20f03ec8a5fb95f0186993d0e46efaaa628a33	2026-07-15 16:07:59.964907	2026-06-15 16:07:59.964907
82385100-9ab3-4727-81e8-2ac704589d20	ec047e43-2773-4e39-ba1f-cada9466b508	71df5697e1c06995bca87c67b539c65781d1ac8a1fe780e04939872ffe12ce01	2026-07-15 16:33:28.948399	2026-06-15 16:33:28.948399
28ecb273-4987-46dd-81bc-cfa30a1e847d	ec047e43-2773-4e39-ba1f-cada9466b508	c12393be62bde848f91a1504a4307a94b428e6fd49265c0b3c0f9ab30925a9be	2026-06-29 13:33:00.362479	2026-05-30 13:33:00.362479
026b411a-bdd6-46e6-9b6e-07d640baa4cb	ec047e43-2773-4e39-ba1f-cada9466b508	8afe8b4d630cd9797d5d791d2e9b5773cdf672c987dd4e35e97f3630eafbf3f1	2026-07-17 04:18:39.337834	2026-06-17 04:18:39.337834
159e9b74-2abf-41b3-817d-3bddca02c55a	ec047e43-2773-4e39-ba1f-cada9466b508	233726ff81963ca7a6808e21e78cebdecf8490553df3cb9bc2493289b6a36d58	2026-06-29 15:21:05.546011	2026-05-30 15:21:05.546011
d7cdf543-680d-46ff-baf2-5d46d4f2791d	ec047e43-2773-4e39-ba1f-cada9466b508	1fb7a422459ce7de2b5ae46d171ced8fcf5940c1eab44f9abed68919a6fe7018	2026-06-29 15:27:00.008961	2026-05-30 15:27:00.008961
5a4f29df-914a-4a68-9abe-2319fa42bfc7	ec047e43-2773-4e39-ba1f-cada9466b508	a07056ba9c59f3e97687dc643118a3e9b4ed1af39987d580b408d740e40ae55f	2026-06-29 19:03:16.840483	2026-05-30 19:03:16.840483
8aac7b17-4430-4b6a-81fa-43c4f9109ddf	ec047e43-2773-4e39-ba1f-cada9466b508	008007114444dd632bca03f8427fa4493f633ffe1728535fc3dd3f63bbbc3fbd	2026-06-29 19:46:54.302724	2026-05-30 19:46:54.302724
e467706e-3bd8-4b12-a1e3-4632f577acc1	ec047e43-2773-4e39-ba1f-cada9466b508	e7e478201211ce29233b139778a51bfadb8c9b6edca9f38857cee85818dfbd9b	2026-06-30 11:13:27.679977	2026-05-31 11:13:27.679977
63d30a48-c00e-4d73-b74e-2154bdeeee6e	ec047e43-2773-4e39-ba1f-cada9466b508	fd325ae5329beacc33c0422aa7793fee3927c1b42e5a092438fa86015e65ab2f	2026-06-30 16:40:11.808604	2026-05-31 16:40:11.808604
b3400550-74a1-4b3e-b203-df5b296ae300	ec047e43-2773-4e39-ba1f-cada9466b508	b2aa7c32a7c9010ee0c688f174a6e434e207795c19b486a2b9bf940af7cd4498	2026-06-30 19:28:40.764359	2026-05-31 19:28:40.764359
8a1e896a-7575-449f-bbc3-335c13ef646f	ec047e43-2773-4e39-ba1f-cada9466b508	676d6b10abbc8a3fb230b7b65b6bcac26a8a62b8e2b3df6310d5e0e5668b569a	2026-07-17 04:53:11.636056	2026-06-17 04:53:11.636056
dac48e21-bb78-45d1-868b-c2845ed0dd01	ec047e43-2773-4e39-ba1f-cada9466b508	805da3a1f567628e44721e0ed59caf7959593fe33f6732831fc178bfdc01a238	2026-07-17 05:31:08.886497	2026-06-17 05:31:08.886497
9d2c32e8-16e2-420d-9b43-193c43531c64	ec047e43-2773-4e39-ba1f-cada9466b508	6658ccf0524bdd2b36a39ef33f91d3ee351a40128fce692f7702e79167955116	2026-07-17 05:52:38.109849	2026-06-17 05:52:38.109849
a2c7f2a6-72e6-4232-b031-6bd9aa8aa879	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	fd4892f7557dae24cc47423983bd8382ca242d6ea1af94d167eb974f96dfb0bf	2026-07-01 06:10:22.080775	2026-06-01 06:10:22.080775
4572c9f6-64dd-4726-a32b-ba29400dffb1	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	52a4974203a19f6b04d44fcf4090489ca98c33a3b40c263f5af57aa9b5c51bee	2026-07-01 06:35:53.970226	2026-06-01 06:35:53.970226
e5d8da1b-e38d-453b-8416-2d0821c13b5f	ec047e43-2773-4e39-ba1f-cada9466b508	3ea74cb0132be992194a5fe9a6861b5164d99a1fcb4499349f3a12e7bf5517aa	2026-07-17 06:11:08.231011	2026-06-17 06:11:08.231011
959ccc27-c4e0-45bf-ab72-78b77b3a502b	ec047e43-2773-4e39-ba1f-cada9466b508	fd525d718ded586a718b765e58688bcf8524786fec566e7dd1a2eb313c15fc58	2026-07-01 06:58:56.281656	2026-06-01 06:58:56.281656
996b6c95-76b9-4fdf-9953-95a6ae40b3ba	ec047e43-2773-4e39-ba1f-cada9466b508	920eb9218410ed5ea010ae6f4da8890b0e8aefef7e85119e0eeafabb0f94ee47	2026-07-01 09:50:14.567715	2026-06-01 09:50:14.567715
390ae247-77de-44ca-86b7-b0032eba3ce1	ec047e43-2773-4e39-ba1f-cada9466b508	c7180f39119d79638f2215846b6e4725cb16692adbef2cc6a5806ddf0379316f	2026-07-01 12:25:13.673796	2026-06-01 12:25:13.673796
fdeb52df-e710-4a5d-8d22-e4d06bd53974	ec047e43-2773-4e39-ba1f-cada9466b508	c2c7ae476df64054b46e19a668c310da99dc69e49f6396f8d38b6bdf72aa1a00	2026-07-02 01:43:49.264195	2026-06-02 01:43:49.264195
c742e68e-e5fc-4a7a-b7e8-59a390d75e72	ec047e43-2773-4e39-ba1f-cada9466b508	c3f4d2a41f2245d9a087a2dbf1ee7f7c7d15281c7c1c5bdeb025b479dc0d39f7	2026-07-02 02:38:12.899813	2026-06-02 02:38:12.899813
3e243b1f-cd3d-4b48-b9ed-8ef93601bee6	ec047e43-2773-4e39-ba1f-cada9466b508	3d5eb455f7d287cf27473fdfaaf489ca102edccceccea7f07e7c87e5be1c89db	2026-07-04 06:55:58.862292	2026-06-04 06:55:58.862292
3bc7ef5f-eaeb-47e6-ad69-2a8512d645e4	ec047e43-2773-4e39-ba1f-cada9466b508	f408d82ed3d938a2922b5ceefc66fa6cb19002940aea3c0551c8a94ec71d9644	2026-07-04 07:44:10.749802	2026-06-04 07:44:10.749802
9750fbaa-ad63-422c-b391-a418b3cd4dac	ec047e43-2773-4e39-ba1f-cada9466b508	562b197d9ec1acdbb870c13e868c20b7a5a0f5c610e408b7dc5a6c51a1c5be8b	2026-07-06 04:37:35.917714	2026-06-06 04:37:35.917714
6357ac31-4f84-4843-8f8e-585645469699	ec047e43-2773-4e39-ba1f-cada9466b508	1868565709eb762c0d647329f897f74c4c8aa494e285305fc2749d35cb41052d	2026-07-06 05:01:58.56155	2026-06-06 05:01:58.56155
56ab8106-8562-45de-bf7a-65544f0e2571	ec047e43-2773-4e39-ba1f-cada9466b508	689cd2fe84be807ed60b4d32a63d56c4c5a7a99b44a9387c3f9de0ca8a5a59b0	2026-07-06 15:17:52.267197	2026-06-06 15:17:52.267197
672b4c78-e96c-4599-b0d0-817ab55d4512	ec047e43-2773-4e39-ba1f-cada9466b508	33177b1d62a62d9b080052d47b5498e87065588e4310834050d21b609330ae92	2026-07-07 16:54:54.521522	2026-06-07 16:54:54.521522
9af7252f-b300-4e8e-8a87-019d2ff81bac	ec047e43-2773-4e39-ba1f-cada9466b508	9e2137cb0e739c164559a40211c8b7272dc490044eb850154c44d9ee9980f605	2026-07-07 19:22:19.911589	2026-06-07 19:22:19.911589
531d46ba-112f-4286-990f-d2af8d516514	ec047e43-2773-4e39-ba1f-cada9466b508	ef3200eaeef2b6e75faa45f81ee54214eaff4bf09dd475b3cf47510ad73ae7c2	2026-07-07 19:57:07.563498	2026-06-07 19:57:07.563498
8cb239c3-de99-4b95-8f70-a6d9f385b4fd	ec047e43-2773-4e39-ba1f-cada9466b508	a8dd91e07b43c8a2bb031f4fc5e73f211a37c7e853d4e664d59a173eaac88637	2026-07-07 19:59:55.989803	2026-06-07 19:59:55.989803
c2cb82ec-8b98-4450-a4a2-8c5c3f52c78e	ec047e43-2773-4e39-ba1f-cada9466b508	b14b562456334297240c7f5e4399436376416bb7debb61690946271ef348cc79	2026-07-07 20:08:03.533134	2026-06-07 20:08:03.533134
cfaa1ae3-8eaa-4cf1-96b5-72f890b49600	ec047e43-2773-4e39-ba1f-cada9466b508	6eab7e16a6bf9d1f11373053037f2d250f42f3bd10aacd63888ef98aa99aa27c	2026-07-07 20:17:05.844857	2026-06-07 20:17:05.844857
6e3e6443-9d42-41c5-9403-dd1f606cdf64	ec047e43-2773-4e39-ba1f-cada9466b508	12df12b793b6594aed7d83e096724ab7b408591fa4bef4cf7a12a29fb7b35b18	2026-07-07 20:20:28.333645	2026-06-07 20:20:28.333645
6f63bbe7-4ee7-4de3-bc15-258d9b5c9935	ec047e43-2773-4e39-ba1f-cada9466b508	746536e1c4caa50f68897ab0c7e8afab81efacfbf8eb7c58b8ba4fd2f5fe6c01	2026-07-07 20:34:43.586991	2026-06-07 20:34:43.586991
399d5c04-554f-467c-ae4d-3f84c39e3c2a	ec047e43-2773-4e39-ba1f-cada9466b508	690409162eb9c5221a26ed3d92700a3e484078aed883565df5540edf2b42ea2e	2026-07-15 16:14:45.265072	2026-06-15 16:14:45.265072
2a693ff2-3dda-4f22-b00f-02c96ad1fc06	ec047e43-2773-4e39-ba1f-cada9466b508	190f6f0361e13b8751f1116fcaaa4ebf77de7998018c948090f607ccd15c913a	2026-07-07 21:26:48.797641	2026-06-07 21:26:48.797641
f7c12a53-5ff1-4f6c-a52b-8b99f9693677	ec047e43-2773-4e39-ba1f-cada9466b508	20c9ded0841918489f170c909887e26ba7a31a50f3824a8f8f06a2326426513d	2026-07-08 05:12:12.033098	2026-06-08 05:12:12.033098
98ca89b2-a348-488c-90ca-80bc9b45c7f2	ec047e43-2773-4e39-ba1f-cada9466b508	a265e966acddc42e1702cca9f844df7c218da90d0d1c14257db6c68e177f3bc1	2026-07-08 05:39:32.292041	2026-06-08 05:39:32.292041
634f4252-4dfb-4be3-8d09-3daeb28a605f	ec047e43-2773-4e39-ba1f-cada9466b508	a80af042aa95e1e519c1a5c7afb3d3e09ca1fe4a408d88ac08a68bc4d52b9e3d	2026-07-08 05:48:48.907243	2026-06-08 05:48:48.907243
32ea2ddc-1e44-45e4-9f9c-15226aaa8507	ec047e43-2773-4e39-ba1f-cada9466b508	3e60388b003b5d2f7a1dac3ffb1c08d9a07b29c8729fb89b9a8447d618f8bb81	2026-07-08 05:50:11.629669	2026-06-08 05:50:11.629669
b07d9c87-879f-4644-a728-4589dd1be911	ec047e43-2773-4e39-ba1f-cada9466b508	702e0f9a757267abb54e65b301677d15e980f7dcd6d59dcdfeff7b18c6371a77	2026-07-08 05:52:20.625566	2026-06-08 05:52:20.625566
c937462c-ce99-4f34-b682-30de476c2299	ec047e43-2773-4e39-ba1f-cada9466b508	94931c408b886e936b947715d5221a532a173b6faafa10b2be537d7add9f4279	2026-07-08 06:03:17.936381	2026-06-08 06:03:17.936381
3a3df57a-8bbb-43b0-9a6a-28b26e7ab205	ec047e43-2773-4e39-ba1f-cada9466b508	411c47c57063c21c80f1b14b173622871309276668d5cee98f015bc3cfa23ed3	2026-07-08 06:06:59.407729	2026-06-08 06:06:59.407729
46eb0ec2-0f45-4082-a4e2-063aa5efe976	ec047e43-2773-4e39-ba1f-cada9466b508	1caf72fb11bf90c16856e952241db5c4fb4760ace417e43932295d4a34a52e53	2026-07-11 16:55:09.71426	2026-06-11 16:55:09.71426
64d39c44-1f3e-4269-aeb9-0cf6fdff34e8	ec047e43-2773-4e39-ba1f-cada9466b508	16e20cdbd1cba9f3f18104bdb9ff0ed3a2d08322fa47587e6ab8419b8c083e9e	2026-07-11 17:04:38.814655	2026-06-11 17:04:38.814655
29d7b165-4eb4-4a65-89bb-be7ab45689a1	ec047e43-2773-4e39-ba1f-cada9466b508	17de4f231b110c8102e0608c588e3692275010b7796dad987c8deb1adf25284b	2026-07-13 05:23:15.789021	2026-06-13 05:23:15.789021
cde25b34-320e-498f-965f-ca6ef7e890ca	ec047e43-2773-4e39-ba1f-cada9466b508	a4d0f91f4d22602416ef91f64a9b58a85f3b579c8e8e5431cfd8b0f4f7d4fa58	2026-07-15 16:47:34.040473	2026-06-15 16:47:34.040473
adc32191-9627-4859-836d-e01d51d6cd3d	ec047e43-2773-4e39-ba1f-cada9466b508	1552f02a25fb28370ea270b44d1460a3137019d213a04ad49d10e3b0789c4a4e	2026-07-17 04:37:51.838084	2026-06-17 04:37:51.838084
41c755c0-3126-4653-9d0d-736b5f541ccb	446964eb-e597-4719-a13a-5cecdfa25567	3a8bc45be9d1e8210fbab5063cc5de2fb60d2d15e5485707c10eea8adeba3ae0	2026-07-13 05:46:48.758922	2026-06-13 05:46:48.758922
04755117-5dc4-4109-9fb8-a77f9b382d56	ec047e43-2773-4e39-ba1f-cada9466b508	65191b99df9e8044d1d7efd0c7f257768236811ff178cd4232f32fc39e88c678	2026-07-15 15:30:50.556201	2026-06-15 15:30:50.556201
ddbfd177-8339-4bd7-8539-9b5b6a25c20e	ec047e43-2773-4e39-ba1f-cada9466b508	996b256292aba69a4ef128786c6d4efa99a83ae4677d56c5758becbedafc1727	2026-07-15 15:42:04.642687	2026-06-15 15:42:04.642687
97ab92e4-852b-497d-a80a-0a757fe4ea3e	ec047e43-2773-4e39-ba1f-cada9466b508	46173b4832b54916efa7e27b78caea56fc63bf1779bd9be31c00423b671a775d	2026-07-15 15:50:09.430928	2026-06-15 15:50:09.430928
08474656-af69-4551-a1cd-095ace6a60f2	ec047e43-2773-4e39-ba1f-cada9466b508	594848cd3a798d2ead0df5f0686a645b046fe221cb7178060a6fd761a148a933	2026-07-15 15:55:55.49775	2026-06-15 15:55:55.49775
458d6126-f1f0-4cd2-bc8d-d75b5a8fddd4	ec047e43-2773-4e39-ba1f-cada9466b508	787e39832894043a4f9683eb24671b7aa13c85e1ecb4684c4d94972fcf187c0a	2026-07-17 05:11:54.402559	2026-06-17 05:11:54.402559
e847e9c8-4de1-48cf-8831-955124c6b69f	ec047e43-2773-4e39-ba1f-cada9466b508	9d4d3f197cd0b5a91cb3b426cdd96e20c4d8b5cf2415b83e2850cd604fdbc419	2026-07-17 05:43:31.002947	2026-06-17 05:43:31.002947
717b368a-0140-48ad-9f80-c8b93e077de6	ec047e43-2773-4e39-ba1f-cada9466b508	5c87546a9882b587d8d1d014179fb31db0ac268f2dc022860500ce7fe58378d6	2026-07-15 16:03:50.713124	2026-06-15 16:03:50.713124
cabf6c89-038f-4e40-a58e-081226cc5e57	ec047e43-2773-4e39-ba1f-cada9466b508	d798064ca7ddc65b1579e937c3dfcc05e24f539856b8dc3b53c9e3cee84eeabb	2026-07-17 06:02:54.957624	2026-06-17 06:02:54.957624
a733b900-6dd3-46b5-a2e8-4d12be79d4d2	ec047e43-2773-4e39-ba1f-cada9466b508	c9b01fa1848f0eb9b715194b8598c476c84f3bcf1b38950b905d1b9c0a2c5602	2026-07-17 06:12:57.593288	2026-06-17 06:12:57.593288
96b6c4c6-2792-449a-a521-1a45f99ee6e0	ec047e43-2773-4e39-ba1f-cada9466b508	12ded1184d3509078295e53ce32e41ea76fb1eebc15e9bcfc3a908caa5f0a4c0	2026-07-17 06:16:31.333485	2026-06-17 06:16:31.333485
9482ebce-c5fb-4f81-811e-59bd5cee2c2e	ec047e43-2773-4e39-ba1f-cada9466b508	14c7be201cdc2d455a13d642520a3f0ec028180ff56bad4e1158c687d46776d4	2026-07-17 06:16:46.325894	2026-06-17 06:16:46.325894
0ef0986e-69ef-442c-ac44-3f20d11ff521	ec047e43-2773-4e39-ba1f-cada9466b508	02764db6cefb03fdbce81c138ea705a8ba9d46d255ccd2c0f8cea74896b159eb	2026-07-17 06:38:47.415832	2026-06-17 06:38:47.415832
7bbecd30-cb76-4c94-a40f-a8278f56cbee	ec047e43-2773-4e39-ba1f-cada9466b508	784931ab09e90bfeab7710d3fd8bace68c262e78ad742b56ef7a40508e2cd036	2026-07-17 06:51:21.968762	2026-06-17 06:51:21.968762
0dacad31-f29f-40b5-8c11-955eb91b45ae	ec047e43-2773-4e39-ba1f-cada9466b508	871b45d8491bfac4cf7a355bd94f15384ad9ff01f1fdbadb68744afe2bb54020	2026-07-17 06:54:08.981309	2026-06-17 06:54:08.981309
5c874a1c-951b-4581-af7f-5ef7a2c20f2f	ec047e43-2773-4e39-ba1f-cada9466b508	1ba5fc6cdb82e31c1b17eef2d1f9b7e86746816956d85b48a9b102e8e4e134a2	2026-07-17 11:59:00.37507	2026-06-17 11:59:00.37507
59080da1-1b51-4c42-b3ed-bc2f7c006e56	ec047e43-2773-4e39-ba1f-cada9466b508	565140aaabea3341685368140b3a2c56ab9a4bcfb67cec9ddddbd31d8fb586fc	2026-07-17 12:13:33.654916	2026-06-17 12:13:33.654916
df84e3be-6ec0-4989-a408-5da59eb04bff	ec047e43-2773-4e39-ba1f-cada9466b508	6550783d808ff90e01610af547f7cbdbb095c08e1c4cc29666f8235c877d7e53	2026-07-17 12:31:58.149916	2026-06-17 12:31:58.149916
8c6b48e7-aeed-4394-883b-ae1efae50d3f	ec047e43-2773-4e39-ba1f-cada9466b508	d49ea6470a45e5d843e3829c9a6f39fb80d03feefa1c1559ffe57f3bc827f29f	2026-07-17 12:34:51.907572	2026-06-17 12:34:51.907572
99b66586-5688-40b3-85e0-e8ae7466e657	ec047e43-2773-4e39-ba1f-cada9466b508	10343ccece4cfd705c1a2921b5320e2752c47aad596d4220c1cc51edb1beb17d	2026-07-17 13:01:28.479804	2026-06-17 13:01:28.479804
e5c9d724-0b1d-4e2f-8576-8132cabe3812	ec047e43-2773-4e39-ba1f-cada9466b508	bb03f637bdd510f93af76d30de334671213e44058d786adf2b2da2c60d25fa41	2026-07-17 13:23:05.005469	2026-06-17 13:23:05.005469
ac50b3df-311c-49d5-805d-a380ff0be1a3	189af10f-6365-4350-99ec-8df0f946e292	95bcf659d54f9ca00ae757747e7c155226db84b37f5ddf1f15cbdb3214e94403	2026-07-17 13:31:30.259597	2026-06-17 13:31:30.259597
fbc54a7a-a5d6-4960-baca-d1bf9480ace8	189af10f-6365-4350-99ec-8df0f946e292	459fe8d29974fb9b2fed1eaa868bf90bbc4e82cb436253cf9f976b8e02ef1c14	2026-07-17 13:35:44.856217	2026-06-17 13:35:44.856217
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, department_id, name, type, created_at, room_code, bloc, floor, capacity) FROM stdin;
b1078103-ec20-45be-8279-6f1e204d525f	284a5d6f-f53e-4db1-a426-a42b44667090	Salle I5	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
eae9562e-735f-403d-ad43-d39fb93be77c	284a5d6f-f53e-4db1-a426-a42b44667090	Salle I4	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
856bb230-a04e-4a17-835d-637a9de42172	284a5d6f-f53e-4db1-a426-a42b44667090	Salle I3	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
f901130f-ea03-4601-8036-cceb2241b139	284a5d6f-f53e-4db1-a426-a42b44667090	Salle I2	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
4e51e397-8cad-4a37-9332-d211a767b962	284a5d6f-f53e-4db1-a426-a42b44667090	Salle I1	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
ba1ec37e-a000-4816-9df3-a68a95655383	4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	Salle M5	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
7d5c6a15-111d-468c-9958-1757f140faf1	4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	Salle M4	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
a9c4f351-f4d1-40e8-ade8-c6ad6e88691b	4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	Salle M3	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
faa0f437-ec7c-4fb0-aa7c-9af4fc3437e3	4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	Salle M2	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
9894e7aa-19c4-45f6-9991-adf300befb16	4a86d8f5-2b3c-43c8-8e07-9ac55346c17d	Salle M1	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
31620990-07d6-4155-beef-97cd69ce6fcb	d57638f6-9cd2-4a2e-b158-0875d86e0743	Salle G5	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
00aea3e5-9a07-4710-95c9-061d3dd2f94a	d57638f6-9cd2-4a2e-b158-0875d86e0743	Salle G4	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
7ece5797-61cc-47cd-a72d-c53096775b0b	d57638f6-9cd2-4a2e-b158-0875d86e0743	Salle G3	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
8cafc544-87b5-4010-89ae-6fc095a78205	d57638f6-9cd2-4a2e-b158-0875d86e0743	Salle G2	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
753a5d9a-9b28-40c8-9012-6c0e7b41f196	d57638f6-9cd2-4a2e-b158-0875d86e0743	Salle G1	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
15ce451a-fda6-472b-aeb6-48e4982b0d0a	9200e91b-0130-4491-bdf8-02ea21537b45	Salle E5	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
87de6ab5-c139-4366-a3f5-343bbdfd85b1	9200e91b-0130-4491-bdf8-02ea21537b45	Salle E4	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
847db72d-5c6e-412f-83b8-8953bf060d9f	9200e91b-0130-4491-bdf8-02ea21537b45	Salle E3	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
e9db3d2f-7958-4e35-8c00-6052eac74dc6	9200e91b-0130-4491-bdf8-02ea21537b45	Salle E2	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
00ab4ba8-89cb-478a-902e-f338ef7a329f	9200e91b-0130-4491-bdf8-02ea21537b45	Salle E1	classroom	2026-05-01 11:06:14.460201	\N	\N	\N	30
171c4d53-1e28-4a17-95ac-b6d30f90a7d0	f3fe9a51-589c-4df7-9360-2be438877be0	Salle TC5	classroom	2026-05-03 08:45:19.558614	\N	\N	\N	30
3253c91f-71ce-47a6-9ac7-96cd624bdc53	f3fe9a51-589c-4df7-9360-2be438877be0	Salle TC4	classroom	2026-05-03 08:45:19.558614	\N	\N	\N	30
0e9b52eb-efd0-4232-83a2-ab33b971ea76	f3fe9a51-589c-4df7-9360-2be438877be0	Salle TC3	classroom	2026-05-03 08:45:19.558614	\N	\N	\N	30
b6b034c2-2a53-45e4-a757-cc675a86ae3e	f3fe9a51-589c-4df7-9360-2be438877be0	Salle TC2	classroom	2026-05-03 08:45:19.558614	\N	\N	\N	30
ef70cc52-17f7-4a99-859f-7cd84858f478	f3fe9a51-589c-4df7-9360-2be438877be0	Salle TC1	classroom	2026-05-03 08:45:19.558614	\N	\N	\N	30
cd29ab5d-75cb-4fae-ba2a-83514aa2a610	5e9026cc-cdad-40ea-99a9-2049a728a47e	Salle ADM2	office	2026-05-03 08:45:19.558614	\N	\N	\N	30
50204d3a-71dd-4169-a096-6d1026820327	5e9026cc-cdad-40ea-99a9-2049a728a47e	Salle ADM1	office	2026-05-03 08:45:19.558614	\N	\N	\N	30
00123347-ff8d-4943-a216-aaee0cb429a8	5e9026cc-cdad-40ea-99a9-2049a728a47e	Stock	storage	2026-05-19 10:24:01.212593	\N	\N	\N	30
e88f0c40-f527-4e8c-9bb8-9819c02a70b8	284a5d6f-f53e-4db1-a426-a42b44667090	Labo IoT 1	laboratory	2026-05-23 16:36:24.980347	LIOT1	\N	\N	20
2cef73e3-e196-4f76-b04b-eb642eeb01ea	284a5d6f-f53e-4db1-a426-a42b44667090	Labo IoT 2	laboratory	2026-05-23 16:36:24.980347	LIOT2	\N	\N	20
\.


--
-- Data for Name: scan_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scan_history (id, user_id, product_id, scanned_at, department_code, department_name, action_type, action_data) FROM stdin;
d4526c0a-2a55-42c0-8c50-06469a77f824	\N	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-06-17 12:32:21.570675	\N	\N	iot_scan	{"scan_type":"rfid","identifier":"B4:18:FA:05","rssi":null,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 1","moved":false}
b0c797c5-1dcd-45a2-a664-53d3be908734	\N	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-06-17 12:32:27.344822	\N	\N	iot_scan	{"scan_type":"rfid","identifier":"B4:18:FA:05","rssi":null,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
fdbcc139-3af6-48c3-979a-b440539b46cd	ec047e43-2773-4e39-ba1f-cada9466b508	5dbc9893-123c-481f-8dc4-becf10f22db4	2026-04-28 16:30:18.017	\N	\N	product_added	\N
ad3157e4-7be6-4718-9281-e4789e32b9be	ec047e43-2773-4e39-ba1f-cada9466b508	bf783522-2a08-4c21-a48c-ddce8e7251d9	2026-04-28 16:34:14.678	\N	\N	product_added	\N
49d63ae4-ee95-41ea-83ce-da6b85364ad6	ec047e43-2773-4e39-ba1f-cada9466b508	23801f7c-69bf-4022-91f6-80359ed7edac	2026-04-28 16:41:35.126	\N	\N	product_added	\N
3fdb66c9-e2e3-4b76-9956-d0a2f3608d93	ec047e43-2773-4e39-ba1f-cada9466b508	7cc9dc3f-3a9d-430b-9881-e3164d3052cb	2026-04-29 01:28:47.298	\N	\N	product_added	\N
55fde149-2afa-4d90-8697-d48ab59046e3	ec047e43-2773-4e39-ba1f-cada9466b508	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-04-29 01:38:04.215	\N	\N	product_added	\N
c9e122bf-0027-42cc-bcfa-0d830dd3f603	ec047e43-2773-4e39-ba1f-cada9466b508	f243f9f8-4d0c-438f-8fcc-e67b5a294985	2026-04-30 08:29:26.614	\N	\N	product_added	\N
f88da31c-6288-4aaa-9879-461090062c6f	ec047e43-2773-4e39-ba1f-cada9466b508	10e89ade-6882-47d9-91dc-fc3ef4568077	2026-04-30 11:43:12.7	\N	\N	product_added	\N
bc135104-2075-451d-b0a9-1cffee1f56b8	ec047e43-2773-4e39-ba1f-cada9466b508	d62e9fc1-1631-475f-a4c4-6a5e58f94df0	2026-05-03 07:40:55.938	\N	\N	product_added	\N
cafdad96-b403-4e0e-b1f7-c399b2aa84c9	ec047e43-2773-4e39-ba1f-cada9466b508	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-05-03 07:48:27.979	\N	\N	product_added	\N
5af7c007-d76d-4d7e-bf70-dd675f0c738f	ec047e43-2773-4e39-ba1f-cada9466b508	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-05-09 15:37:18.114245	\N	\N	moved	{"from_room":"Salle E3","to_room":"Salle G3"}
6273eaa0-adbf-4285-9c7a-d11c11bf7170	ec047e43-2773-4e39-ba1f-cada9466b508	d62e9fc1-1631-475f-a4c4-6a5e58f94df0	2026-05-10 12:15:49.343415	\N	\N	moved	{"from_room":"Salle E2","to_room":"Salle G2"}
8a4c345d-aef3-4ca5-a3bd-a71d8c3bdd4f	ec047e43-2773-4e39-ba1f-cada9466b508	10e89ade-6882-47d9-91dc-fc3ef4568077	2026-05-18 08:33:48.591491	\N	\N	moved	{"from_room":"Salle I1","to_room":"Salle ADM1"}
a2417545-02e7-4e78-b3e5-943dcaad78f6	ec047e43-2773-4e39-ba1f-cada9466b508	10e89ade-6882-47d9-91dc-fc3ef4568077	2026-05-19 06:58:40.004044	\N	\N	moved	{"from_room":"Salle ADM1","to_room":"Salle E2"}
dc52aea1-7b31-44c2-8d8e-d4cf288cc1ae	ec047e43-2773-4e39-ba1f-cada9466b508	10e89ade-6882-47d9-91dc-fc3ef4568077	2026-05-19 06:59:06.632713	\N	\N	moved	{"from_room":"Salle E2","to_room":"Salle ADM2"}
14e01d90-8bc2-4e28-88e3-ee3458481f30	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-05-19 10:36:13.605275	\N	\N	product_added	\N
4ac501d5-985f-4bb8-84f0-5c211e0410df	ec047e43-2773-4e39-ba1f-cada9466b508	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-05-19 14:31:58.886307	\N	\N	status_changed	{"old_status":"in_stock","new_status":"retired"}
a7c7f864-eb6b-4c88-899e-12bd0fe198bc	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-19 14:57:07.497181	\N	\N	product_added	\N
71b0fc3e-0388-442a-b319-79ff1fdd79c5	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-19 15:22:14.196756	\N	\N	scan	\N
8aa5babf-daac-47d5-8ddd-06115af431fb	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-19 15:59:02.077741	\N	\N	scan	\N
f99715e1-c2d3-452e-88f7-50976822962a	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-19 17:52:58.445918	\N	\N	scan	\N
1849da2c-1ce4-4739-b279-743f1c869fab	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-20 07:53:33.564787	\N	\N	scan	\N
bcbe6059-caf9-4636-8215-2e45318b928d	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-20 08:08:32.312426	\N	\N	scan	\N
1cc90899-5757-44a3-bdfb-6bea34311b85	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 07:20:43.560413	\N	\N	scan	\N
13e2ce80-3a4f-4fcd-8f56-3fcb6704a96b	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 07:32:29.142273	\N	\N	scan	\N
c93e7a91-1928-4dc5-a5f3-80292621e403	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 07:32:55.130133	\N	\N	scan	\N
e8c17299-bccf-4aff-83a1-42da7f982af6	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 07:47:08.058131	\N	\N	scan	\N
b92f5ce4-027c-430e-b7d1-023b39b38930	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 07:49:42.583313	\N	\N	scan	\N
f4468ebd-4922-4c3d-a8b7-f8bd69a1f5dc	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-22 10:59:04.595076	\N	\N	scan	\N
d94bf2e2-f99e-438e-a912-a49add8e67bb	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-23 14:53:54.436417	\N	\N	moved	{"from_room":"Stock","to_room":"Salle E3"}
5ca908b2-da11-4a16-a16a-a04f6ff7c29d	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-23 15:54:30.498079	\N	\N	scan	\N
c9cd6171-0d2c-4e9a-9f1e-f1d01899578f	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-23 15:56:46.724811	\N	\N	scan	\N
a040bca4-cf2f-4cbb-a962-0c1d4e459eb8	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-23 16:44:30.607541	\N	\N	scan	\N
b1b061dc-0e0a-4402-818b-d935977916b3	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-24 04:28:57.735404	\N	\N	scan	\N
2affde4f-7a5f-48c2-9074-963b784164ff	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-24 05:25:36.418377	\N	\N	moved	{"from_room":"Labo IoT 1","to_room":"Salle I1"}
0b8b7797-e38d-4dce-8d8b-6d21ff2bd5c7	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-24 10:52:45.135549	\N	\N	status_changed	{"old_status":"in_stock","new_status":"operational"}
4de18ec8-f626-482a-ae92-00ff3209e7dd	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-05-25 09:28:04.293092	\N	\N	scan	\N
cbca1410-cd92-416b-9e23-1faddbc8e5a4	ec047e43-2773-4e39-ba1f-cada9466b508	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-05-25 09:28:58.293816	\N	\N	moved	{"from_room":"Stock","to_room":"Salle E2"}
8acbc6db-a2ae-4b0d-9897-393ce842192a	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-01 06:44:10.301383	\N	\N	product_added	\N
002b8b85-71e0-490a-bb07-e56b30a4000e	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-01 12:30:29.105664	\N	\N	scan	\N
d48c4d57-af2b-45ba-b8ad-b99907ec50de	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:40:06.702665	\N	\N	scan	\N
182208bd-20d6-4656-ba2e-64d0eb3782f3	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:41:06.037529	\N	\N	scan	\N
4a095643-a81d-4a40-a006-c4dcf3b1b9f6	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:42:41.892305	\N	\N	scan	\N
3044e791-02c2-4304-ac7c-2d9b0afde5cb	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:42:44.307813	\N	\N	status_changed	{"old_status":"operational","new_status":"critical_issue"}
830da8bc-f157-49ce-9a2a-5d7f04380ad7	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:42:50.7913	\N	\N	scan	\N
dcaf81fb-f6d1-4a52-bda6-219881ed4577	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:42:55.846079	\N	\N	scan	\N
8c0c2b10-dd94-42fc-a666-5a8c0eabac3c	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-02 02:43:56.627187	\N	\N	scan	\N
56a1193e-797a-4ad8-9a86-40891dbb530b	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-07 16:43:47.359938	\N	\N	scan	\N
b507e948-1e7c-4522-b210-20c63cb47679	ec047e43-2773-4e39-ba1f-cada9466b508	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-07 17:30:34.993861	\N	\N	scan	\N
a84abf9e-49ff-4e62-907c-546b35e92a75	ec047e43-2773-4e39-ba1f-cada9466b508	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-06-07 17:36:14.33378	\N	\N	moved	{"from_room":"Salle E2","to_room":"Salle G2"}
bf67569d-f351-4a46-8d29-c4034dc6cacb	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-07 19:24:16.929682	\N	\N	scan	\N
dad24c17-50f0-4139-9b8e-3486575d005e	\N	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-06-17 12:42:09.09147	\N	\N	iot_scan	{"scan_type":"rfid","identifier":"B4:18:FA:05","rssi":null,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 2","moved":false}
c8314e66-6aad-4b9d-82d5-5806994f28eb	\N	bc32e7b3-7931-428b-a8ef-05b8b7bd5737	2026-06-17 12:42:13.027861	\N	\N	iot_scan	{"scan_type":"rfid","identifier":"B4:18:FA:05","rssi":null,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
3ddeccde-600c-4029-b7f7-0037b13b4966	446964eb-e597-4719-a13a-5cecdfa25567	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-13 05:53:35.874312	\N	\N	scan	\N
bf8b659a-63d6-4626-a52d-f6848503ed11	446964eb-e597-4719-a13a-5cecdfa25567	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-13 05:54:06.305313	\N	\N	scan	\N
f8f64617-8cfb-4dcc-858d-c1989d23b8f9	446964eb-e597-4719-a13a-5cecdfa25567	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-13 05:55:15.864869	\N	\N	moved	{"from_room":"Stock","to_room":"Salle E2"}
95b819b5-ffc7-4071-804c-f575304618c4	ec047e43-2773-4e39-ba1f-cada9466b508	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-06-15 15:31:15.083745	\N	\N	moved	{"from_room":"Salle G2","to_room":"Salle E2"}
af54df67-6055-4be1-bf42-192e0e9c9ce8	ec047e43-2773-4e39-ba1f-cada9466b508	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3	2026-06-15 16:02:54.345998	\N	\N	status_changed	{"old_status":"critical_issue","new_status":"retired"}
0488ac50-a574-48ca-8986-e8c9a4c40fa3	ec047e43-2773-4e39-ba1f-cada9466b508	f68c0de2-f37e-4610-90ea-2ddbeeb99476	2026-06-17 12:43:53.65922	\N	\N	moved	{"from_room":"Salle E2","to_room":"Salle ADM2"}
7fd9a2c8-b05b-4380-bc7d-7ea83be0ea81	ec047e43-2773-4e39-ba1f-cada9466b508	a8d3b8fb-9470-4490-b3b3-4c0763cf7551	2026-06-17 12:43:55.552898	\N	\N	moved	{"from_room":"Salle E2","to_room":"Salle E4"}
a7c96325-0bf3-4e01-9cee-3b20b6ba90c4	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:45:38.853384	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-58,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 2","moved":false}
d349319c-7ceb-45b2-b152-36a0cd3be0c8	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:45:48.569605	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-38,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
7fb85496-3657-44d9-9682-398008b42396	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:45:53.752752	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-57,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
3876ffed-c816-4cd4-87b8-4fd8453e5a6f	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:04.655015	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-44,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
699c894d-cecb-4352-ba52-c1c674ad4c0f	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:08.852917	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-59,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
f3d750b0-8211-4266-ab3e-137530822f0a	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:18.584523	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-38,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
6eb3d885-1e15-4b13-9c44-74f548b15bb8	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:23.793727	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-61,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
87465cac-8af6-4620-acba-64c6521c4b7a	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:34.659698	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-38,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
5c7d5b36-74fc-40ee-bfeb-fff1641fcab0	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:38.814741	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-53,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
4a2fce0f-2494-433d-83aa-0e33e8fc3e22	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:46:48.688181	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-43,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
042bae1e-53ac-411a-925e-adfa82760f12	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:06.814653	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-39,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 1","moved":false}
56580680-a35d-4290-8510-1fb387594562	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:08.897517	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-58,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
0291201d-9d08-439c-a48d-5872bc6bab17	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:22.776424	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-35,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
7ba2e880-9cf3-4e6e-9ef0-16fec60515e0	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:23.915899	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-59,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 1","moved":true}
cb1d2c41-147f-4989-9cdc-cc3fa84fbef6	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:38.93551	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-54,"reader_id":"esp32_labo_iot2","room_id":"2cef73e3-e196-4f76-b04b-eb642eeb01ea","room_name":"Labo IoT 2","from_room":"Labo IoT 2","moved":false}
f9cf64a7-7911-4df0-adc2-7a237947ad7a	\N	f704853e-9a67-4bc1-8625-b0c74805bf62	2026-06-17 12:47:48.896392	\N	\N	iot_scan	{"scan_type":"ble","identifier":"FINDMY:4C0012020003","rssi":-40,"reader_id":"esp32_labo_iot1","room_id":"e88f0c40-f527-4e8c-9bb8-9819c02a70b8","room_name":"Labo IoT 1","from_room":"Labo IoT 2","moved":true}
7e2401dc-1c63-4ea0-998a-b1be67834ddf	6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	6f21e44c-f042-4c39-9d79-889524e825a1	2026-06-17 11:50:12.763874	\N	\N	product_added	\N
\.


--
-- Data for Name: transfer_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transfer_requests (id, product_id, requested_by, from_room_id, to_room_id, status, notes, resolved_by, resolved_at, created_at) FROM stdin;
\.


--
-- Data for Name: unregistered_scans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unregistered_scans (id, uid, scan_type, room_id, room_name, reader_id, scanned_at, resolved, resolved_by, resolved_at, product_id) FROM stdin;
318f10ea-87cc-4512-8627-7951a9ce052b	44:DE:DB:E9	rfid	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-24 08:55:12.091857	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-24 08:55:29.786614	f704853e-9a67-4bc1-8625-b0c74805bf62
61126176-b2ac-4006-86b2-c0a862613862	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:07.757742	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
03b30f9e-f63e-4b08-a452-60d74549a4db	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:23.721616	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
4530fdc2-b288-4914-94d6-6020cfb0f9a2	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:37.750113	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
0f377159-7271-4362-b759-b526ef44d826	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:53.929906	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
13d323db-a0c6-4a0c-870d-4a9f2a13dfb5	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:10.835776	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
af8a9fc5-9cea-4387-b327-17c5886fdc1f	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:22.90895	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
34b6acef-8958-4113-a210-06e76b76a879	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:53.12989	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
7610366d-dbb2-42b4-a7d9-2ff6889fda96	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:11.045336	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
33ecde18-2d91-4a2b-83b4-390c8984eca9	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:25.073409	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
1429ca75-84a2-4044-bc28-33d01fea0e9b	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:38.41959	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
10ecac3b-3953-4a9f-ae87-e2aa466e834b	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:53.541425	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
af98705f-1393-48ac-af77-e0e4816a2981	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:03:09.505751	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
f3af795c-8c68-4c20-9407-aa56ff14d291	FINDMY:4C0012020002	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:03:23.542965	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:28.075838	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
b92cf2aa-2242-432b-8c7b-a688c039e674	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 15:59:54.537974	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
7cf66a93-c2b1-4d47-86dd-ef3b1051c6d8	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:08.780613	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
f62f2bba-c762-4185-b745-acdb2db092d1	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:22.595469	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
b10a0f7d-eb2a-4a2b-8bd6-66a22bd137aa	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:38.672911	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
781c5066-7ff7-440c-b03b-393250da941c	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:00:54.748373	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
6e2c582e-b1a6-4166-88db-3ff3cf9a3bf3	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:08.693427	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
0fb3285e-1fd6-498a-9991-4c5c94b39b22	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:24.760196	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
1c30c093-2453-45d2-abef-07daa48d4cb4	FINDMY:4C0012020003	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 15:59:53.933016	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:32.872289	f704853e-9a67-4bc1-8625-b0c74805bf62
8c277958-454a-4499-9ece-6f804b9db562	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:38.790856	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
6f237566-6ed0-4a5d-8c8c-ef102d8c8d2f	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:01:52.919736	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
1eb90471-6f4b-414b-bcbe-0d5d1f15aa87	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:22.923016	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
f10ee86c-103a-4842-b156-cc4608eba191	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:38.908595	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
9f5a6716-3e6b-4b2e-b86e-500df4921eb4	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:02:54.974177	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
fff9d087-8e1b-41cb-abfa-f4d348b43611	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:03:09.003047	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
f8625050-a856-4cb6-8d4d-8dbb5c5df245	FINDMY:4C001219001B016B3B9FC60A32E5	ble	e88f0c40-f527-4e8c-9bb8-9819c02a70b8	Labo IoT 1	esp32_labo_iot1	2026-05-30 16:03:23.031171	t	ec047e43-2773-4e39-ba1f-cada9466b508	2026-05-30 19:03:30.529159	10e89ade-6882-47d9-91dc-fc3ef4568077
16569b60-81de-4190-bf27-52e1c153235c	FINDMY:4C0012020000	ble	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 04:30:32.691454	f	\N	\N	\N
b3663c6a-d40c-47d6-ade7-35dd689f9562	FINDMY:4C0012020001	ble	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 05:00:12.589113	f	\N	\N	\N
8f085040-4ac7-43cc-a425-520e547424b6	FINDMY:4C001219000B56605016560D0472	ble	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 05:23:16.508957	f	\N	\N	\N
05da95c1-7126-4415-817c-1955447a0e2c	72:1C:77:5C	rfid	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 04:33:10.259793	t	\N	2026-06-17 12:12:52.915467	dbee2896-bfe3-4bf6-b47d-a9d0588b37b3
339bd1cd-a149-4673-86c3-e6c0c6ca20d6	DC:D4:4E:06	rfid	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 04:33:28.684245	t	\N	2026-06-17 12:12:52.915467	f704853e-9a67-4bc1-8625-b0c74805bf62
37b13850-a661-4dc5-85f6-6d1ed52b55cd	44:DE:DB:E9	rfid	2cef73e3-e196-4f76-b04b-eb642eeb01ea	Labo IoT 2	esp32_labo_iot2	2026-06-17 12:42:23.472402	f	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, role, avatar, is_active, created_at, updated_at, phone, google_id, email_verified, last_seen) FROM stdin;
446964eb-e597-4719-a13a-5cecdfa25567	hichem	raadbouattour1@gmail.com	$2a$12$BWpZqdLQcCeyMnSsanuaCuYStI9TU3.d1q5iuoeq79.EkrrmK.bjK	technicien	\N	t	2026-06-07 15:43:33.490066	2026-06-07 15:46:16.078431	\N	\N	t	2026-06-13 06:01:01.981412
ec047e43-2773-4e39-ba1f-cada9466b508	Admin ISET	hichemsakhraoui9@gmail.com	$2a$12$GUZM9PnDwGscLcEl9vf8auDyhokzz6QcJgqCAex10gtUNCXzFZiY.	admin	/uploads/e47d5463-91df-44e5-a951-e64c2266bdbb	t	2026-05-07 07:20:04.194281	2026-06-07 15:51:07.606864	\N	\N	t	2026-06-17 13:30:31.174882
2433723f-63cb-4d0f-8f4e-36b39d806c4b	hichem	hichemsakhraoui12@gmail.com	$2a$12$Oykh6eO/Ug3F/w2o5I2okufEqJHfp4GBt4VjDutOJZGZQNhP3q35y	technicien	\N	t	2026-06-07 21:16:54.09862	2026-06-07 21:16:54.09862	\N	\N	f	\N
6b5b798b-4bae-4ea2-8bd3-31e04ba6104b	Magazinier ISET	magazinier@iset.tn	$2a$12$BWpZqdLQcCeyMnSsanuaCuYStI9TU3.d1q5iuoeq79.EkrrmK.bjK	magazinier	\N	t	2026-05-07 07:20:04.618807	2026-05-18 09:23:19.383803	\N	\N	t	2026-06-17 11:50:50.791985
9e891a68-effb-43b6-878b-a348575af2d6	hichem	hichemsakhroui0@gmail.com	$2a$12$DIsUP5uEeuFDwBReai5pGePhzMagUomxQQSlpbD1wRvJEtAa48j1y	technicien	\N	t	2026-05-19 08:48:12.196068	2026-05-19 08:48:42.953475	\N	\N	t	\N
f8ea6be4-c25d-41f7-a0b9-c06f9acfa0ce	hichem	ihuhhh619@gmail.com	$2a$12$v9SoQ5SBH.Oqjy6Vcb4mBeigcNUlG/XKKy5NzPcrP2Sn6bI1bMmvC	technicien	\N	t	2026-06-04 07:40:04.571624	2026-06-04 07:40:04.571624	\N	\N	f	\N
189af10f-6365-4350-99ec-8df0f946e292	safwen	safwensakhraoui7@gmail.com	$2a$12$.mQ0e7O69DDctkTF283p2O5WtZH0nB5KoIcWnNVeWSyGP9HSNEYum	technicien	\N	t	2026-06-17 13:22:29.474021	2026-06-17 13:23:08.073801	\N	\N	t	\N
\.


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: chat_conversations chat_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_pkey PRIMARY KEY (id);


--
-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_pkey PRIMARY KEY (conversation_id, user_id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: checkouts checkouts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_pkey PRIMARY KEY (id);


--
-- Name: departments departments_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_code_key UNIQUE (code);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: maintenance_notes maintenance_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_notes
    ADD CONSTRAINT maintenance_notes_pkey PRIMARY KEY (id);


--
-- Name: maintenance_tasks maintenance_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_tasks
    ADD CONSTRAINT maintenance_tasks_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_rfid_tag_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_rfid_tag_key UNIQUE (rfid_tag);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_department_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_department_id_name_key UNIQUE (department_id, name);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: scan_history scan_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scan_history
    ADD CONSTRAINT scan_history_pkey PRIMARY KEY (id);


--
-- Name: transfer_requests transfer_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_pkey PRIMARY KEY (id);


--
-- Name: unregistered_scans unregistered_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unregistered_scans
    ADD CONSTRAINT unregistered_scans_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_categories_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_categories_name ON public.categories USING btree (name);


--
-- Name: idx_chat_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_members_user ON public.chat_members USING btree (user_id);


--
-- Name: idx_chat_msgs_conv; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_msgs_conv ON public.chat_messages USING btree (conversation_id, created_at DESC);


--
-- Name: idx_checkouts_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_checkouts_product ON public.checkouts USING btree (product_id);


--
-- Name: idx_checkouts_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_checkouts_user ON public.checkouts USING btree (user_id);


--
-- Name: idx_evt_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_evt_token ON public.email_verification_tokens USING btree (token_hash);


--
-- Name: idx_evt_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_evt_user ON public.email_verification_tokens USING btree (user_id);


--
-- Name: idx_maint_assigned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maint_assigned ON public.maintenance_tasks USING btree (assigned_to);


--
-- Name: idx_maint_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maint_product ON public.maintenance_tasks USING btree (product_id);


--
-- Name: idx_messages_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_topic ON public.messages USING btree (topic);


--
-- Name: idx_notes_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notes_task ON public.maintenance_notes USING btree (task_id);


--
-- Name: idx_notifications_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_unread ON public.notifications USING btree (user_id, is_read);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);


--
-- Name: idx_products_ble; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_ble ON public.products USING btree (ble_device) WHERE (ble_device IS NOT NULL);


--
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_category ON public.products USING btree (category_id);


--
-- Name: idx_products_classroom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_classroom ON public.products USING btree (classroom);


--
-- Name: idx_products_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_department ON public.products USING btree (department);


--
-- Name: idx_products_last_moved_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_last_moved_by ON public.products USING btree (last_moved_by);


--
-- Name: idx_products_rfid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_rfid ON public.products USING btree (rfid_tag) WHERE (rfid_tag IS NOT NULL);


--
-- Name: idx_products_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_room ON public.products USING btree (room_id);


--
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_sku ON public.products USING btree (sku);


--
-- Name: idx_products_tracker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_tracker ON public.products USING btree (tracker_active) WHERE (tracker_active = true);


--
-- Name: idx_products_tracker_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_products_tracker_key ON public.products USING btree (tracker_hashed_key) WHERE (tracker_hashed_key IS NOT NULL);


--
-- Name: idx_products_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_user ON public.products USING btree (user_id);


--
-- Name: idx_prt_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prt_token ON public.password_reset_tokens USING btree (token_hash);


--
-- Name: idx_prt_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prt_user ON public.password_reset_tokens USING btree (user_id);


--
-- Name: idx_refresh_tokens_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_token ON public.refresh_tokens USING btree (token);


--
-- Name: idx_refresh_tokens_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_user ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_rooms_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_department ON public.rooms USING btree (department_id);


--
-- Name: idx_scan_history_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scan_history_product ON public.scan_history USING btree (product_id);


--
-- Name: idx_scan_history_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scan_history_user ON public.scan_history USING btree (user_id);


--
-- Name: idx_transfer_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_product ON public.transfer_requests USING btree (product_id);


--
-- Name: idx_transfer_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_user ON public.transfer_requests USING btree (requested_by);


--
-- Name: idx_unreg_resolved; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unreg_resolved ON public.unregistered_scans USING btree (resolved);


--
-- Name: idx_unreg_uid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unreg_uid ON public.unregistered_scans USING btree (uid);


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: chat_conversations chat_conversations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: chat_members chat_members_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id) ON DELETE CASCADE;


--
-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: checkouts checkouts_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: checkouts checkouts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: checkouts checkouts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: devices devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: email_verification_tokens email_verification_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: maintenance_notes maintenance_notes_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_notes
    ADD CONSTRAINT maintenance_notes_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.maintenance_tasks(id) ON DELETE CASCADE;


--
-- Name: maintenance_notes maintenance_notes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_notes
    ADD CONSTRAINT maintenance_notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: maintenance_tasks maintenance_tasks_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_tasks
    ADD CONSTRAINT maintenance_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: maintenance_tasks maintenance_tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_tasks
    ADD CONSTRAINT maintenance_tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: maintenance_tasks maintenance_tasks_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_tasks
    ADD CONSTRAINT maintenance_tasks_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: messages messages_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE SET NULL;


--
-- Name: messages messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: products products_last_moved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_last_moved_by_fkey FOREIGN KEY (last_moved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products products_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- Name: products products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: scan_history scan_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scan_history
    ADD CONSTRAINT scan_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: scan_history scan_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scan_history
    ADD CONSTRAINT scan_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transfer_requests transfer_requests_from_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_from_room_id_fkey FOREIGN KEY (from_room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- Name: transfer_requests transfer_requests_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: transfer_requests transfer_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: transfer_requests transfer_requests_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: transfer_requests transfer_requests_to_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer_requests
    ADD CONSTRAINT transfer_requests_to_room_id_fkey FOREIGN KEY (to_room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- Name: unregistered_scans unregistered_scans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unregistered_scans
    ADD CONSTRAINT unregistered_scans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: unregistered_scans unregistered_scans_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unregistered_scans
    ADD CONSTRAINT unregistered_scans_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: unregistered_scans unregistered_scans_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unregistered_scans
    ADD CONSTRAINT unregistered_scans_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict QAl32b9UZnGJxLHcoJZ1VaMYBPO4AqdARpmHM82GTEkItWngv4F2bHDcQNHNcW1

