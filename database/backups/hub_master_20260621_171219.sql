--
-- PostgreSQL database dump
--

\restrict wCyjRMAhrG5ZEpg6VuwdYYG4AJw2d0McDbpCLEn5r7nFw1sGtRlEgJHsXWgND62

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: hubmaster
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.full_name);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO hubmaster;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: hubmaster
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO hubmaster;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    provider text NOT NULL,
    api_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.api_keys OWNER TO hubmaster;

--
-- Name: TABLE api_keys; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.api_keys IS 'Chaves de API dos provedores de IA';


--
-- Name: categories; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.categories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    color text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.categories OWNER TO hubmaster;

--
-- Name: TABLE categories; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.categories IS 'Categorias de links';


--
-- Name: folders; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.folders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    color text DEFAULT 'blue'::text NOT NULL,
    icon text DEFAULT 'folder'::text,
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.folders OWNER TO hubmaster;

--
-- Name: TABLE folders; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.folders IS 'Pastas hierárquicas para organizar links';


--
-- Name: link_tags; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.link_tags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    link_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.link_tags OWNER TO hubmaster;

--
-- Name: TABLE link_tags; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.link_tags IS 'Relacionamento many-to-many entre links e tags';


--
-- Name: links; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.links (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    category_id uuid,
    is_favorite boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    folder_id uuid,
    description text,
    is_archived boolean DEFAULT false NOT NULL,
    is_pinned boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.links OWNER TO hubmaster;

--
-- Name: TABLE links; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.links IS 'Links salvos pelos usuários';


--
-- Name: mcp_tokens; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.mcp_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    token_prefix text NOT NULL,
    token_hash text NOT NULL,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mcp_tokens OWNER TO hubmaster;

--
-- Name: TABLE mcp_tokens; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.mcp_tokens IS 'Tokens MCP para acesso programático';


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text,
    full_name text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.profiles OWNER TO hubmaster;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.profiles IS 'Perfis adicionais dos usuários';


--
-- Name: tags; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.tags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    color text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tags OWNER TO hubmaster;

--
-- Name: TABLE tags; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.tags IS 'Tags de links';


--
-- Name: users; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    full_name text,
    avatar_url text,
    email_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO hubmaster;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: hubmaster
--

COMMENT ON TABLE public.users IS 'Usuários do sistema (substitui auth.users do Supabase)';


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.api_keys (id, user_id, provider, api_key, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.categories (id, user_id, name, color, created_at) FROM stdin;
\.


--
-- Data for Name: folders; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.folders (id, user_id, name, color, icon, parent_id, created_at, updated_at) FROM stdin;
72874b53-6f01-487a-a820-232739c6b586	516358a0-a386-4c69-bb53-83609a79e8e0	IA LLM	pink	folder	\N	2026-01-12 03:28:03.530618+00	2026-02-09 18:53:10.957128+00
f3a12167-a4e8-4524-9a33-2951e64cddaf	516358a0-a386-4c69-bb53-83609a79e8e0	PN	pink	folder	\N	2026-02-20 23:51:51.337507+00	2026-02-20 23:51:51.337507+00
5ac0e746-aeea-458c-89fa-19f153fda925	516358a0-a386-4c69-bb53-83609a79e8e0	FERRAMENTAS	blue	folder	\N	2026-02-23 12:04:02.898903+00	2026-02-23 12:04:02.898903+00
\.


--
-- Data for Name: link_tags; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.link_tags (id, link_id, tag_id) FROM stdin;
b0d5e1fb-55ed-49e0-b28e-1f7c3c2fdb5b	081b67be-7424-4909-b4e5-5a024077fef2	1bc810bf-2a67-41db-aa32-ba10f8d6469a
6da291c3-b698-43d4-ba11-3a0f3c4dcce0	f18618bb-1506-4838-ad06-b8bf0bd2771c	f40c3d10-3d10-4523-a952-37c6fc9e2d79
dbaa6393-c8eb-48c3-b9c5-ec0ae80939be	ca70f634-0811-4795-9826-94708bc2ffac	26071442-4308-407c-b0e1-5ecc823bd744
a88944b8-b254-470d-b4c6-2d869e3b3c3f	deeeaf91-9a2c-4b01-a20d-d8368475d80b	26071442-4308-407c-b0e1-5ecc823bd744
dcc41db9-8be5-4327-8265-d49192eebe15	c567593b-0dbb-4b01-83e9-9ea3c273be8e	8b525e4c-b6e7-44ed-bcd0-8a99fc52ef45
e5f6ad8c-9246-4c3e-8856-8f8af9bcdf19	b828c2a5-07e2-4044-8dc6-0a7a23b5aa14	8b525e4c-b6e7-44ed-bcd0-8a99fc52ef45
b6ec5ca3-4a1b-4e6f-b1f9-8955d126ad13	34010f5c-d89c-4129-9caf-1d2c46b9618d	8b525e4c-b6e7-44ed-bcd0-8a99fc52ef45
0667f0e1-5568-4195-aa94-19a39ed01aa0	57e3b0ad-e45d-45a3-b906-62e8cd3e7b00	1b05dd68-d424-4e12-ac7d-3103aa371823
2db8bb4c-d5e5-42b1-9f42-cb4b8ae136da	ca6ee9a1-621a-4caa-b032-045e78d51126	8b525e4c-b6e7-44ed-bcd0-8a99fc52ef45
\.


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.links (id, user_id, title, url, category_id, is_favorite, created_at, updated_at, folder_id, description, is_archived, is_pinned, deleted_at) FROM stdin;
f18618bb-1506-4838-ad06-b8bf0bd2771c	516358a0-a386-4c69-bb53-83609a79e8e0	Hostinger Webmail	https://mail.hostinger.com/	\N	f	2025-06-15 03:01:40.540562+00	2025-07-06 18:26:15.865+00	\N	\N	f	f	\N
081b67be-7424-4909-b4e5-5a024077fef2	516358a0-a386-4c69-bb53-83609a79e8e0	Meus Prompts	https://aajunior43.notion.site/PROMPTS-PARA-IAS-LLM-c78fe45b321c489f82d7bd4cea58f94b	\N	f	2025-06-15 03:04:23.09498+00	2025-06-15 03:04:23.09498+00	\N	\N	f	f	\N
ca70f634-0811-4795-9826-94708bc2ffac	516358a0-a386-4c69-bb53-83609a79e8e0	Calculadora de Diárias	https://diaria-clock-cruncher.lovable.app/	\N	f	2025-06-15 03:12:05.741021+00	2025-07-06 18:27:08.144+00	\N	\N	f	f	\N
c567593b-0dbb-4b01-83e9-9ea3c273be8e	516358a0-a386-4c69-bb53-83609a79e8e0	OpenRouter: Roteamento de Tráfego de IA para Aplicações em Nuvem	https://openrouter.ai/	\N	f	2025-06-15 03:13:57.210486+00	2025-07-06 18:31:12.413+00	\N	\N	f	f	\N
774f5cb8-0896-4a06-b59f-1617a1ec2c76	516358a0-a386-4c69-bb53-83609a79e8e0	Answer The Public	https://answerthepublic.com/	\N	f	2025-06-15 23:08:06.079506+00	2025-06-15 23:08:06.079506+00	\N	\N	f	f	\N
deeeaf91-9a2c-4b01-a20d-d8368475d80b	516358a0-a386-4c69-bb53-83609a79e8e0	Download de Vídeos do X (ex-Twitter)	https://ssstwitter.com/pt	\N	f	2025-06-15 23:10:46.695207+00	2025-07-06 18:27:45.628+00	\N	\N	f	f	\N
21a0646a-2cd5-42db-8012-08daf864424f	516358a0-a386-4c69-bb53-83609a79e8e0	Inner AI	https://app.innerai.com/	\N	f	2025-06-15 23:13:02.914173+00	2025-06-15 23:13:02.914173+00	\N	\N	f	f	\N
c7ac9854-c42a-484a-80a7-ca149f8a69f5	516358a0-a386-4c69-bb53-83609a79e8e0	Códigos Promocionais de Software	https://dealspotr.com/promo-codes/search/cat=software	\N	f	2025-06-15 23:13:53.304775+00	2025-07-06 18:27:59.343+00	\N	\N	f	f	\N
e93f0dbd-ed34-4cad-b4c0-3b161bad1629	516358a0-a386-4c69-bb53-83609a79e8e0	Concurso TCU: Técnico de Fiscalização da TCU 2025	https://www.cebraspe.org.br/concursos/tcu_25_tefc	\N	f	2025-06-15 23:15:28.754615+00	2025-07-06 15:48:15.005+00	\N	\N	f	f	\N
2bd2df0b-9f9f-4284-850a-61319a0192e6	516358a0-a386-4c69-bb53-83609a79e8e0	Cursor Agents	https://cursor.com/agents	\N	f	2025-07-04 16:52:30.064034+00	2025-07-04 16:52:30.064034+00	\N	\N	f	f	\N
d8acfb6c-ef59-484b-908f-b908170a1b37	516358a0-a386-4c69-bb53-83609a79e8e0	Calculadora de Porcentagem Online	https://app--percent-calc-a89ec7bf.base44.app/	\N	f	2025-07-06 15:40:06.737131+00	2025-07-06 15:48:04.995+00	\N	\N	f	f	\N
28c4b98e-61a1-4107-bf61-fe0425c8a41d	516358a0-a386-4c69-bb53-83609a79e8e0	Google AI Studio	https://aistudio.google.com/	\N	f	2025-07-06 15:48:37.915506+00	2025-07-06 15:48:37.915506+00	\N	\N	f	f	\N
1f23008a-6aaa-481a-b2ae-32258708bc1f	516358a0-a386-4c69-bb53-83609a79e8e0	Leap: Construa seu próprio site com IA	https://leap.new/	\N	f	2025-07-06 16:09:29.816723+00	2025-07-06 16:09:29.816723+00	\N	\N	f	f	\N
e816003a-d422-477e-8dff-e126feb6dc42	516358a0-a386-4c69-bb53-83609a79e8e0	Bolt	https://bolt.new/	\N	f	2025-07-06 16:21:34.611283+00	2025-07-06 16:21:34.611283+00	\N	\N	f	f	\N
b568ec22-804e-4ae5-97bf-3f5590c762db	516358a0-a386-4c69-bb53-83609a79e8e0	Claude: IA Conversacional da Anthropic	https://claude.ai	\N	f	2025-07-06 18:25:59.923157+00	2025-07-06 18:25:59.923157+00	\N	\N	f	f	\N
b828c2a5-07e2-4044-8dc6-0a7a23b5aa14	516358a0-a386-4c69-bb53-83609a79e8e0	Mistral	https://chat.mistral.ai/chat	\N	f	2025-07-08 12:11:59.184229+00	2025-07-08 12:16:19.079+00	\N	\N	f	f	\N
3208e41f-5a19-4ebe-aeb8-10c8bda65882	516358a0-a386-4c69-bb53-83609a79e8e0	Console Amazon	https://sa-east-1.console.aws.amazon.com/console/home?region=sa-east-1	\N	f	2025-07-08 12:14:58.7928+00	2025-07-08 12:14:58.7928+00	\N	\N	f	f	\N
54ba911f-f4a3-4ddf-9dd8-4277338eadd3	516358a0-a386-4c69-bb53-83609a79e8e0	Emergent	https://app.emergent.sh/login	\N	f	2025-07-08 18:34:29.156617+00	2025-07-08 18:34:29.156617+00	\N	\N	f	f	\N
a461681e-ea4a-4588-9dad-71949d115057	516358a0-a386-4c69-bb53-83609a79e8e0	Future tools	https://www.futuretools.io/	\N	f	2025-07-08 18:35:29.529561+00	2025-07-08 18:35:29.529561+00	\N	\N	f	f	\N
7d06d857-d14d-46b9-a79c-4749298cf28a	516358a0-a386-4c69-bb53-83609a79e8e0	Builder	https://www.builder.io/	\N	f	2025-07-12 21:39:44.689682+00	2025-07-12 21:39:44.689682+00	\N	\N	f	f	\N
c580b482-47e1-4cfc-892c-395f330d170a	516358a0-a386-4c69-bb53-83609a79e8e0	Discord	https://discord.com/	\N	f	2025-07-12 22:38:41.916414+00	2025-07-12 22:38:41.916414+00	\N	\N	f	f	\N
fd5107bc-0155-4de8-993b-b917a8b3f2ce	516358a0-a386-4c69-bb53-83609a79e8e0	Tile	https://www.tile.dev/	\N	f	2025-07-12 22:40:28.397487+00	2025-07-12 22:40:28.397487+00	\N	\N	f	f	\N
b898c9ac-723d-4126-8eca-1cc6574b3b04	516358a0-a386-4c69-bb53-83609a79e8e0	Lovart	https://www.lovart.ai/	\N	f	2025-07-12 22:48:20.343924+00	2025-07-12 22:48:20.343924+00	\N	\N	f	f	\N
866b23a6-5ed8-4c86-95fc-f00967f55929	516358a0-a386-4c69-bb53-83609a79e8e0	Browser User	https://cloud.browser-use.com/	\N	f	2025-07-12 22:56:27.881591+00	2025-07-12 22:56:27.881591+00	\N	\N	f	f	\N
9a1bc8b5-6d8b-4f74-9c8b-3227aba38552	516358a0-a386-4c69-bb53-83609a79e8e0	Bolt	https://bolt.new/	\N	f	2025-07-12 22:58:30.735128+00	2025-07-12 22:58:30.735128+00	\N	\N	f	f	\N
9ec8660a-3bb2-4003-8da3-b4910323e684	516358a0-a386-4c69-bb53-83609a79e8e0	Suna	https://suna.so/	\N	f	2025-07-12 23:00:27.997973+00	2025-07-12 23:00:27.997973+00	\N	\N	f	f	\N
494525bf-ec16-4598-8c1a-9266690185d2	516358a0-a386-4c69-bb53-83609a79e8e0	Rosebud	https://rosebud.ai/	\N	f	2025-07-12 23:01:24.061687+00	2025-07-12 23:01:24.061687+00	\N	\N	f	f	\N
1260b85b-d231-45d4-8fb0-c3adf18b95fb	516358a0-a386-4c69-bb53-83609a79e8e0	Readdy	https://readdy.ai	\N	f	2025-07-12 23:02:29.399655+00	2025-07-12 23:02:29.399655+00	\N	\N	f	f	\N
7621dd81-c4e6-491f-a8c4-df5fc5716e73	516358a0-a386-4c69-bb53-83609a79e8e0	Basse44	https://base44.com/	\N	f	2025-07-12 23:03:14.278543+00	2025-07-12 23:03:14.278543+00	\N	\N	f	f	\N
d3715c14-dad2-4a6c-94d4-58ba7b9a20b3	516358a0-a386-4c69-bb53-83609a79e8e0	Kimi	https://www.kimi.com/	\N	f	2025-07-12 23:03:59.831244+00	2025-07-12 23:03:59.831244+00	\N	\N	f	f	\N
ce1795e3-db85-4820-83c3-3590ad7a2d32	516358a0-a386-4c69-bb53-83609a79e8e0	Flux context	https://huggingface.co/spaces/black-forest-labs/FLUX.1-Kontext-Dev	\N	f	2025-07-12 23:07:10.020215+00	2025-07-12 23:07:10.020215+00	\N	\N	f	f	\N
18b36f7b-985d-4398-b765-0958e8c99376	516358a0-a386-4c69-bb53-83609a79e8e0	Gamma	https://gamma.app	\N	f	2025-07-12 23:10:06.427758+00	2025-07-12 23:10:06.427758+00	\N	\N	f	f	\N
66c85bd2-76c9-4828-99bf-f28e0cd75c94	516358a0-a386-4c69-bb53-83609a79e8e0	Magicui	https://magicui.design/	\N	f	2025-07-12 23:14:37.888691+00	2025-07-12 23:14:37.888691+00	\N	\N	f	f	\N
d547884f-ff5d-4de6-81c7-108a70b2aa5a	516358a0-a386-4c69-bb53-83609a79e8e0	Github Biblioteca AI	https://github.com/best-of-ai/ai-directories	\N	f	2025-07-12 23:18:05.729075+00	2025-07-12 23:18:05.729075+00	\N	\N	f	f	\N
38a3b7a8-01df-4c49-a410-74ec506762d3	516358a0-a386-4c69-bb53-83609a79e8e0	Github Biblioteca AI 2	https://github.com/ozgrozer/top-ai-directories	\N	f	2025-07-12 23:26:05.289834+00	2025-07-12 23:26:05.289834+00	\N	\N	f	f	\N
aafeb670-6f58-4edf-a95d-ebb95c078b92	516358a0-a386-4c69-bb53-83609a79e8e0	AdGuard DNS: DNS Público e Gratuito para Privacidade Online	https://adguard-dns.io/pt_br/welcome.html	\N	f	2025-07-12 23:32:03.483736+00	2025-07-14 21:14:35.386+00	\N	\N	f	f	\N
48d5f126-62b9-424c-b9f0-65509e5acbd3	516358a0-a386-4c69-bb53-83609a79e8e0	Stitch	https://stitch.withgoogle.com/?pli=1	\N	f	2025-07-17 19:38:05.518002+00	2025-07-17 19:38:05.518002+00	\N	\N	f	f	\N
40bba8bc-2d79-47bf-8116-876f67eed1cb	516358a0-a386-4c69-bb53-83609a79e8e0	Producthunt	https://www.producthunt.com/	\N	f	2025-07-18 18:46:31.226785+00	2025-07-18 18:46:31.226785+00	\N	\N	f	f	\N
daad6702-2c34-4791-a92e-1be47ccff1ce	516358a0-a386-4c69-bb53-83609a79e8e0	Reddit	https://www.reddit.com/	\N	f	2025-07-20 22:36:39.182945+00	2025-07-20 22:36:39.182945+00	\N	\N	f	f	\N
17d3bf07-7ce3-4c9e-a737-48266a66e57b	516358a0-a386-4c69-bb53-83609a79e8e0	Replit	https://replit.com/	\N	f	2025-07-15 16:22:34.729359+00	2025-07-15 16:22:34.729359+00	\N	\N	f	f	\N
45e2c977-afe6-4d1b-aff4-488589a6be19	516358a0-a386-4c69-bb53-83609a79e8e0	Vercel	https://vercel.com/	\N	f	2025-07-15 16:29:42.222163+00	2025-07-15 16:29:42.222163+00	\N	\N	f	f	\N
ec25ed55-5fcf-4f26-a5cb-0102847fe788	516358a0-a386-4c69-bb53-83609a79e8e0	Deepsite	https://huggingface.co/spaces/enzostvs/deepsite	\N	f	2025-07-16 11:23:40.962007+00	2025-07-16 11:23:40.962007+00	\N	\N	f	f	\N
0c415118-65be-4dd2-95d2-179a2f495de0	516358a0-a386-4c69-bb53-83609a79e8e0	Huggingface Space	https://huggingface.co/spaces	\N	f	2025-07-16 11:25:59.206696+00	2025-07-16 11:25:59.206696+00	\N	\N	f	f	\N
e93e4a07-ce44-4f81-a82b-d5198c394d0f	516358a0-a386-4c69-bb53-83609a79e8e0	Yupp ai	https://yupp.ai/	\N	f	2025-07-21 01:53:38.325772+00	2025-07-21 01:53:38.325772+00	\N	\N	f	f	\N
af8f42ba-3dc8-470e-8c7e-98be3edeebb9	516358a0-a386-4c69-bb53-83609a79e8e0	Promoção ia	https://www.joinsecret.com/	\N	f	2025-07-21 10:52:50.881453+00	2025-07-21 10:52:50.881453+00	\N	\N	f	f	\N
7459698a-aa00-41f0-ba34-c96d94b1a274	516358a0-a386-4c69-bb53-83609a79e8e0	Ia	https://sjinn.ai/	\N	f	2025-07-21 21:25:44.497575+00	2025-07-21 21:25:44.497575+00	\N	\N	f	f	\N
baed6e6d-9563-45bf-923b-d86ca82c13b2	516358a0-a386-4c69-bb53-83609a79e8e0	Re	https://www.remade.ai/	\N	f	2025-07-21 21:26:28.572433+00	2025-07-21 21:26:28.572433+00	\N	\N	f	f	\N
dab1012c-6703-417d-b427-cd234a3f9841	516358a0-a386-4c69-bb53-83609a79e8e0	Qwen Ai	https://chat.qwen.ai/	\N	f	2025-07-23 14:01:51.625921+00	2025-07-23 14:01:51.625921+00	\N	\N	f	f	\N
c03aa05d-1340-4db7-9e6c-4b761889f073	516358a0-a386-4c69-bb53-83609a79e8e0	Blink	https://blink.new/	\N	f	2025-07-23 21:42:21.325909+00	2025-07-23 21:42:21.325909+00	\N	\N	f	f	\N
f6081ebd-8ce0-4378-a787-aa0eec3bb058	516358a0-a386-4c69-bb53-83609a79e8e0	Skywork	https://skywork.ai/	\N	f	2025-07-27 12:47:09.777289+00	2025-07-27 12:47:09.777289+00	\N	\N	f	f	\N
960aefdb-b284-4f27-8710-6f6ba3b57ea1	516358a0-a386-4c69-bb53-83609a79e8e0	Leilões	https://www.jeleiloes.com.br/	\N	f	2025-07-28 10:42:31.443972+00	2025-07-28 10:42:31.443972+00	\N	\N	f	f	\N
27c651f2-0bf0-440e-af52-673c893f684f	516358a0-a386-4c69-bb53-83609a79e8e0	Glif	https://glif.app/glifs	\N	f	2025-07-28 10:43:50.246145+00	2025-07-28 10:43:50.246145+00	\N	\N	f	f	\N
ea5024fd-f395-4bce-a4c6-e933b3d15941	516358a0-a386-4c69-bb53-83609a79e8e0	Criaí Studio	https://criaistudio.com/	\N	f	2025-07-28 10:44:27.451459+00	2025-07-28 10:44:27.451459+00	\N	\N	f	f	\N
020b4285-7fb8-461a-bf70-55b740d54494	516358a0-a386-4c69-bb53-83609a79e8e0	Grok	https://grok.com/	\N	f	2025-07-28 10:45:17.111165+00	2025-07-28 10:45:17.111165+00	\N	\N	f	f	\N
b52209a5-3968-40ad-80af-e87fb9322535	516358a0-a386-4c69-bb53-83609a79e8e0	Trend Google	https://trends.google.com.br/trending?geo=US&hl=pt-BR&status=active	\N	f	2025-07-28 10:46:08.373193+00	2025-07-28 10:46:08.373193+00	\N	\N	f	f	\N
8464b4b1-43f4-450e-95f9-38e726abe471	516358a0-a386-4c69-bb53-83609a79e8e0	Opus Clip	https://clip.opus.pro/dashboard	\N	f	2025-07-28 10:47:00.069169+00	2025-07-28 10:47:00.069169+00	\N	\N	f	f	\N
125f8c4a-f314-4298-a38a-a355ba7054d2	516358a0-a386-4c69-bb53-83609a79e8e0	Remade AI	https://www.remade.ai/	\N	f	2025-07-28 10:47:45.724994+00	2025-07-28 10:47:45.724994+00	\N	\N	f	f	\N
bbad1d75-00a6-4bfb-b513-46e591f62efb	516358a0-a386-4c69-bb53-83609a79e8e0	SJINN AI	https://sjinn.ai/	\N	f	2025-07-28 10:48:22.474124+00	2025-07-28 10:48:22.474124+00	\N	\N	f	f	\N
e792386c-642d-49ca-a952-e0f3006a78b0	516358a0-a386-4c69-bb53-83609a79e8e0	Excalidraw	https://excalidraw.com/	\N	f	2025-07-28 10:49:24.516694+00	2025-07-28 10:49:24.516694+00	\N	\N	f	f	\N
e164ef85-6c4e-4692-8197-698639ec9823	516358a0-a386-4c69-bb53-83609a79e8e0	V0	https://v0.dev/chat	\N	f	2025-07-28 14:25:00.626118+00	2025-07-28 14:25:00.626118+00	\N	\N	f	f	\N
3ff42d5b-4312-467b-9963-02ba500fbac0	516358a0-a386-4c69-bb53-83609a79e8e0	Ponder AI	https://ponder.ing/pt	\N	f	2025-07-30 23:59:49.026621+00	2025-07-30 23:59:49.026621+00	\N	\N	f	f	\N
7186b6be-de02-4f1f-ac13-86f4ea2d7ba5	516358a0-a386-4c69-bb53-83609a79e8e0	My memo	https://mymemo.ai/	\N	f	2025-07-31 00:33:39.738745+00	2025-07-31 00:33:39.738745+00	\N	\N	f	f	\N
0bb7cffb-11c0-4bfb-a72c-535f7d4f2222	516358a0-a386-4c69-bb53-83609a79e8e0	cnpja	https://cnpja.com/	\N	f	2025-08-01 01:13:14.530063+00	2025-08-01 01:13:14.530063+00	\N	\N	f	f	\N
618bdb84-28a6-45df-88ec-655c749a2224	516358a0-a386-4c69-bb53-83609a79e8e0	Zai ai	https://chat.z.ai	\N	f	2025-08-04 15:25:32.501011+00	2025-08-04 15:25:32.501011+00	\N	\N	f	f	\N
2ac8d912-7fb0-43d5-9168-0bb067a30a97	516358a0-a386-4c69-bb53-83609a79e8e0	Google AI Studio	https://aistudio.google.com	\N	f	2025-08-10 21:31:29.230193+00	2025-08-10 21:31:29.230193+00	\N	\N	f	f	\N
a2316c28-0429-4ecf-b967-13fda6f9d7e2	516358a0-a386-4c69-bb53-83609a79e8e0	Google Flow	https://labs.google/fx/pt/tools/flow	\N	f	2025-08-10 21:32:14.599679+00	2025-08-10 21:32:14.599679+00	\N	\N	f	f	\N
34010f5c-d89c-4129-9caf-1d2c46b9618d	516358a0-a386-4c69-bb53-83609a79e8e0	Firebase Studio	https://studio.firebase.google.com	\N	f	2025-08-10 21:33:47.733443+00	2025-08-10 21:33:47.733443+00	\N	\N	f	f	\N
4edb2abb-8bbf-422b-ab23-1cc18e449aca	516358a0-a386-4c69-bb53-83609a79e8e0	Contagem regressiva	https://countdown-sub-sync.lovable.app/	\N	f	2025-08-10 21:35:25.914656+00	2025-08-10 21:35:25.914656+00	\N	\N	f	f	\N
e5b3023a-c2a1-4152-a483-88a8a590ebb2	516358a0-a386-4c69-bb53-83609a79e8e0	Flowith	https://flowith.io/blank	\N	f	2025-08-10 21:39:03.461991+00	2025-08-10 21:39:03.461991+00	\N	\N	f	f	\N
090478db-ab44-41bd-b9bb-1912999444f2	516358a0-a386-4c69-bb53-83609a79e8e0	MagicUI	https://magicui.design/	\N	f	2025-08-10 21:40:24.991009+00	2025-08-10 21:40:24.991009+00	\N	\N	f	f	\N
5cd763bf-0413-4296-a1cd-04d7f761dea8	516358a0-a386-4c69-bb53-83609a79e8e0	Suna	https://www.suna.so/dashboard	\N	f	2025-08-10 21:41:38.168909+00	2025-08-10 21:41:38.168909+00	\N	\N	f	f	\N
8f79a6d2-422b-4578-be4e-470def9955dc	516358a0-a386-4c69-bb53-83609a79e8e0	Youware	https://www.youware.com/	\N	f	2025-08-10 21:43:04.431448+00	2025-08-10 21:43:04.431448+00	\N	\N	f	f	\N
99424fbc-1afc-4c00-8f9a-cd93d17d1cd0	516358a0-a386-4c69-bb53-83609a79e8e0	Readdy AI	https://readdy.ai/home	\N	f	2025-08-10 21:44:48.131819+00	2025-08-10 21:44:48.131819+00	\N	\N	f	f	\N
bc93df1c-e52e-447f-b775-2df16e5b10d2	516358a0-a386-4c69-bb53-83609a79e8e0	Rosebud	https://rosebud.ai/	\N	f	2025-08-10 21:45:41.910576+00	2025-08-10 21:45:41.910576+00	\N	\N	f	f	\N
5558306b-8973-4dfb-b8f1-88d0704c3d77	516358a0-a386-4c69-bb53-83609a79e8e0	Promptessor	https://promptessor.com/	\N	f	2025-07-23 21:49:10.13057+00	2025-08-10 22:08:04.316+00	\N	\N	f	f	\N
46115f9c-2e22-4f02-a72a-0ddfb9067874	516358a0-a386-4c69-bb53-83609a79e8e0	Free models	https://www.freetiermodels.com/	\N	f	2026-04-17 00:47:44.145763+00	2026-04-17 00:47:44.145763+00	\N	\N	f	f	\N
27119961-2d8f-4a93-bd76-a03da450a053	516358a0-a386-4c69-bb53-83609a79e8e0	Escolavirtual	https://www.escolavirtual.gov.br	\N	f	2025-08-11 10:45:53.38446+00	2025-08-11 10:45:53.38446+00	\N	\N	f	f	\N
258316f7-92fb-4c51-9738-40d419634185	516358a0-a386-4c69-bb53-83609a79e8e0	Winsparrow vps	https://winsparrow.com/dr-farfar/	\N	f	2025-08-11 13:45:02.305068+00	2025-08-11 13:45:02.305068+00	\N	\N	f	f	\N
b0b083fb-a2ec-4766-a793-da05d003ab17	516358a0-a386-4c69-bb53-83609a79e8e0	Scispace AI	https://scispace.com/chat	\N	f	2025-08-13 12:59:15.185605+00	2025-08-13 12:59:15.185605+00	\N	\N	f	f	\N
cac4e5bc-5899-480c-810d-a6ccae092289	516358a0-a386-4c69-bb53-83609a79e8e0	Floot	https://floot.com/	\N	f	2025-08-13 14:39:34.313632+00	2025-08-13 14:39:34.313632+00	\N	\N	f	f	\N
13ae3d30-fdfb-4159-ab43-258d231c2032	516358a0-a386-4c69-bb53-83609a79e8e0	Asteroid	https://platform.asteroid.ai/	\N	f	2025-08-13 14:43:29.443079+00	2025-08-13 14:43:29.443079+00	\N	\N	f	f	\N
cf91f64a-2691-4374-9728-fbc55f92e4b5	516358a0-a386-4c69-bb53-83609a79e8e0	Reeroll Videos com ia	https://reeroll.com/	\N	f	2025-08-13 14:51:47.457154+00	2025-08-13 14:51:47.457154+00	\N	\N	f	f	\N
5a9511b8-5755-466a-b5a3-1493af93c307	516358a0-a386-4c69-bb53-83609a79e8e0	Flowith	https://flowith.io/blank	\N	f	2025-08-13 23:59:10.623221+00	2025-08-13 23:59:10.623221+00	\N	\N	f	f	\N
3564e405-36d1-4fd7-aaf8-f84452f66c4c	516358a0-a386-4c69-bb53-83609a79e8e0	ZAI	https://chat.z.ai/	\N	f	2025-08-15 01:07:18.981602+00	2025-08-15 01:07:18.981602+00	\N	\N	f	f	\N
13ad8390-6777-4659-88a6-d93246b1b4a7	516358a0-a386-4c69-bb53-83609a79e8e0	Shotva	https://shotva.com	\N	f	2025-08-15 21:44:28.90856+00	2025-08-15 21:44:28.90856+00	\N	\N	f	f	\N
18c01656-d75d-4ac9-b74a-5ae8f9120a67	516358a0-a386-4c69-bb53-83609a79e8e0	Dualite Alpha	https://alpha.dualite.dev/onboarding	\N	f	2025-08-20 22:18:51.871556+00	2025-08-20 22:18:51.871556+00	\N	\N	f	f	\N
fd13f623-6f82-41fa-a5eb-7f3f56722540	516358a0-a386-4c69-bb53-83609a79e8e0	Scira	https://scira.ai/	\N	f	2025-08-21 01:08:37.924312+00	2025-08-21 01:08:37.924312+00	\N	\N	f	f	\N
cfa9050b-6664-4ee9-b234-e601cf8f6153	516358a0-a386-4c69-bb53-83609a79e8e0	Grid	https://grid.wtf/?twclid=29x4diopvnws1i0grrjr6hc8r	\N	f	2025-08-21 01:11:38.971093+00	2025-08-21 01:11:38.971093+00	\N	\N	f	f	\N
7f2ebbd8-0fd2-4fd7-b89e-380157528bfe	516358a0-a386-4c69-bb53-83609a79e8e0	Mocha	https://getmocha.com	\N	f	2025-09-14 15:26:59.351032+00	2025-09-14 15:26:59.351032+00	\N	\N	f	f	\N
03d1a931-3e50-4b6f-bb21-3bd9ff40a9b3	516358a0-a386-4c69-bb53-83609a79e8e0	Dualite	https://dualite.dev/	\N	f	2025-09-19 20:25:54.584087+00	2025-09-19 20:25:54.584087+00	\N	\N	f	f	\N
ea4291db-64b6-4e93-a9c6-a9bc5546b786	516358a0-a386-4c69-bb53-83609a79e8e0	Browser Lol	https://browser.lol/create	\N	f	2025-10-29 11:31:40.294988+00	2025-10-29 11:31:40.294988+00	\N	\N	f	f	\N
08fb756e-d704-4d08-81ef-204aadacfe1e	516358a0-a386-4c69-bb53-83609a79e8e0	Google Planilhas	https://docs.google.com/spreadsheets/u/0/?hl=pt-br	\N	f	2025-11-03 17:08:50.187955+00	2025-11-15 18:28:53.832+00	\N	\N	f	f	\N
cc61ad04-71f0-4c36-86dc-789b8147da13	516358a0-a386-4c69-bb53-83609a79e8e0	EXCEL	https://excel.cloud.microsoft/?wdOrigin	\N	f	2025-11-03 17:11:11.296752+00	2025-11-03 17:11:11.296752+00	\N	\N	f	f	\N
57b27248-6d19-4226-92a5-4761b9931831	516358a0-a386-4c69-bb53-83609a79e8e0	Dazl	https://dazl.dev/	\N	f	2025-11-06 14:31:06.872599+00	2025-11-06 14:31:06.872599+00	\N	\N	f	f	\N
2099a652-741f-4789-b5e9-93ce074c9b06	516358a0-a386-4c69-bb53-83609a79e8e0	Stepfun AI	https://stepfun.ai/chats/new	\N	f	2026-02-03 00:11:55.634529+00	2026-02-03 00:11:55.634529+00	\N	\N	f	f	\N
d08a5180-1a0a-4e03-a562-653b798f9f02	516358a0-a386-4c69-bb53-83609a79e8e0	Indexxx	https://www.indexxx.com/home	\N	f	2026-02-13 22:28:52.848643+00	2026-02-13 22:28:52.848643+00	\N	\N	f	f	\N
6f13aa68-21e6-47f6-a5da-25ed5b7d3f96	516358a0-a386-4c69-bb53-83609a79e8e0	Name That Porn	https://namethatporn.com/	\N	f	2026-02-13 22:29:39.837467+00	2026-02-13 22:29:39.837467+00	\N	\N	f	f	\N
57e3b0ad-e45d-45a3-b906-62e8cd3e7b00	516358a0-a386-4c69-bb53-83609a79e8e0	Btz - Vale alimentação - Prefeitura	https://app.btzbank.com.br	\N	f	2026-02-15 12:33:35.701103+00	2026-02-15 12:33:35.701103+00	\N	\N	f	f	\N
ca6ee9a1-621a-4caa-b032-045e78d51126	516358a0-a386-4c69-bb53-83609a79e8e0	Kamban - Openclaw	https://kanban-board-api--juniorrocha6.replit.app/	\N	f	2026-02-15 12:35:09.163287+00	2026-02-15 12:35:09.163287+00	\N	\N	f	f	\N
96053a64-6976-449a-8de1-e6a9ec3834ba	516358a0-a386-4c69-bb53-83609a79e8e0	Minimax	https://agent.minimaxi.com/	\N	f	2026-02-15 12:36:10.922187+00	2026-02-15 12:36:10.922187+00	\N	\N	f	f	\N
809459b7-503b-44ae-ab63-f2c84f742d2f	516358a0-a386-4c69-bb53-83609a79e8e0	Playground Black Forest	https://playground.bfl.ai/	\N	f	2026-02-15 12:44:45.189219+00	2026-02-15 12:44:45.189219+00	\N	\N	f	f	\N
61d607ff-3fde-4b52-bb0b-239a18d7bc3e	516358a0-a386-4c69-bb53-83609a79e8e0	Zo Computer	https://jrr.zo.computer/	\N	f	2026-02-20 03:57:52.592818+00	2026-02-20 23:39:12.418+00	72874b53-6f01-487a-a820-232739c6b586	\N	f	f	\N
1a4d77fd-2101-4d26-a0ec-6790ff39ce42	516358a0-a386-4c69-bb53-83609a79e8e0	Zai	https://chat.z.ai	\N	f	2026-02-15 12:45:57.50561+00	2026-02-20 23:39:12.692+00	72874b53-6f01-487a-a820-232739c6b586	\N	f	f	\N
f07ab05c-2894-4973-82ff-e5ee8acc45ed	516358a0-a386-4c69-bb53-83609a79e8e0	Ninja BR	https://ninjabr.top	\N	f	2026-02-15 12:42:39.463811+00	2026-02-23 12:04:01.329+00	5ac0e746-aeea-458c-89fa-19f153fda925	\N	f	f	\N
e6a899d4-dcd9-4e88-b157-10b404130dfb	516358a0-a386-4c69-bb53-83609a79e8e0	Kimi	https://www.kimi.com/	\N	f	2025-11-12 14:00:35.332792+00	2026-02-23 12:04:13.984+00	72874b53-6f01-487a-a820-232739c6b586	\N	f	f	\N
a44e33a2-f894-42e5-aee2-48c8ebff0bc3	516358a0-a386-4c69-bb53-83609a79e8e0	Tokens Minimax	https://platform.minimax.io/user-center/payment/token-plan	\N	f	2026-04-17 00:14:45.295514+00	2026-04-17 00:14:45.295514+00	\N	\N	f	f	\N
6b75bfa9-df29-4daf-872c-78bc2928bb63	516358a0-a386-4c69-bb53-83609a79e8e0	Tavily	https://app.tavily.com/	\N	f	2026-04-17 00:17:35.081147+00	2026-04-17 00:17:35.081147+00	\N	\N	f	f	\N
cde2d7d4-4d74-45a3-ad37-d2d76997eab2	516358a0-a386-4c69-bb53-83609a79e8e0	Cartão de todos	https://adesao.cartaodetodos.com.br/dados-pessoais/	\N	f	2026-04-17 00:18:27.720814+00	2026-04-17 00:18:27.720814+00	\N	\N	f	f	\N
f0611edc-6268-40ba-b2e9-970436c1cdac	516358a0-a386-4c69-bb53-83609a79e8e0	Opencode	https://opencode.ai/docs/pt-br/go/	\N	f	2026-04-17 00:19:26.841869+00	2026-04-17 00:19:26.841869+00	\N	\N	f	f	\N
681f5dab-ddba-49a6-ba8f-f8945b80713b	516358a0-a386-4c69-bb53-83609a79e8e0	Arena ai	https://arena.ai/	\N	f	2026-04-17 00:20:38.506967+00	2026-04-17 00:20:38.506967+00	\N	\N	f	f	\N
58643468-7d87-41e6-9adb-1b5c648d5e74	516358a0-a386-4c69-bb53-83609a79e8e0	Plataforma Openai	https://platform.openai.com/home	\N	f	2026-04-17 00:37:08.702009+00	2026-04-17 00:37:08.702009+00	\N	\N	f	f	\N
606f2e1e-b6bf-48f5-bc50-43c52efa558a	516358a0-a386-4c69-bb53-83609a79e8e0	Caractere invisível	https://www.textreverse.com/br/caractere-invisivel.php	\N	f	2026-04-17 00:45:33.239572+00	2026-04-17 00:45:33.239572+00	\N	\N	f	f	\N
99a09db0-c360-4c10-85ef-bc918fec8bbe	516358a0-a386-4c69-bb53-83609a79e8e0	21st	21sthttps://21st.dev/	\N	f	2026-04-21 15:19:50.588744+00	2026-04-21 15:19:50.588744+00	\N	\N	f	f	\N
67e8f513-ab9b-493d-859d-dbc138ee2ea9	516358a0-a386-4c69-bb53-83609a79e8e0	Jules	https://jules.google.com	\N	f	2026-05-30 23:41:56.114635+00	2026-05-30 23:41:56.114635+00	\N	\N	f	f	\N
df165cd7-8310-4d58-8abe-03e4401bc084	516358a0-a386-4c69-bb53-83609a79e8e0	Radar ON	https://radar.onwav.com.br/	\N	f	2026-05-30 23:44:07.218696+00	2026-05-30 23:44:07.218696+00	\N	\N	f	f	\N
dd7eddae-8c03-473f-ac5e-fd5a288222e5	516358a0-a386-4c69-bb53-83609a79e8e0	Prompts	https://prompts.latechi.com/	\N	f	2026-05-30 23:44:54.140137+00	2026-05-30 23:44:54.140137+00	\N	\N	f	f	\N
2a07645e-d8af-4ba2-b9ca-6ea03b2ccd38	516358a0-a386-4c69-bb53-83609a79e8e0	Command Code	https://commandcode.ai/	\N	f	2026-05-30 23:53:18.653732+00	2026-05-30 23:53:18.653732+00	\N	\N	f	f	\N
7717cee4-4810-44b1-9a63-d25957a78235	516358a0-a386-4c69-bb53-83609a79e8e0	Crof AI API	https://crof.ai/pricing	\N	f	2026-05-30 23:55:40.127295+00	2026-05-30 23:55:40.127295+00	\N	\N	f	f	\N
d3b7a0ea-4ea2-4719-a29b-c1378cbba3cc	516358a0-a386-4c69-bb53-83609a79e8e0	Kanwas IA	https://kanwas.ai	\N	f	2026-05-30 23:58:53.161554+00	2026-05-30 23:58:53.161554+00	\N	\N	f	f	\N
2e6f1dbd-426d-4437-8601-b6cb2acc9824	516358a0-a386-4c69-bb53-83609a79e8e0	Napkin	https://app.napkin.ai/	\N	f	2026-05-31 00:04:04.089484+00	2026-05-31 00:04:04.089484+00	\N	\N	f	f	\N
dbda8bf0-d0b8-4818-9175-c1824b0a7304	516358a0-a386-4c69-bb53-83609a79e8e0	Lucas Premium	https://lucaspremium.com	\N	f	2026-06-17 20:04:14.526289+00	2026-06-17 20:04:14.526289+00	\N	\N	f	f	\N
9216be4b-67f6-46c2-b5f8-91c91ea4afc2	516358a0-a386-4c69-bb53-83609a79e8e0	Clube VIP — Adultos	https://adultos.clubevip.net/	\N	f	2026-06-17 20:16:05.193023+00	2026-06-17 20:16:05.193023+00	\N	\N	f	f	\N
d9d8bb0c-a54b-49ad-84e1-cbab08466798	516358a0-a386-4c69-bb53-83609a79e8e0	Webmail Inajá/PR	https://webmail.inaja.pr.gov.br	\N	t	2026-06-17 20:21:51.05955+00	2026-06-17 20:21:51.05955+00	5ac0e746-aeea-458c-89fa-19f153fda925	Webmail oficial da Prefeitura Municipal de Inajá/PR	f	f	\N
c0e8b0b6-dbb6-44b6-8cda-ce6776382924	516358a0-a386-4c69-bb53-83609a79e8e0	AI Studio Xiaomi	https://aistudio.xiaomimimo.com/#/c	\N	f	2026-06-18 01:10:44.107123+00	2026-06-18 01:10:44.107123+00	\N	AI Studio da Xiaomi (modelo MiMo)	f	f	\N
3f6a8714-b044-4bc7-a23a-a0029b6d5213	516358a0-a386-4c69-bb53-83609a79e8e0	Arena.ai Agent	https://arena.ai/agent	\N	f	2026-06-18 01:10:44.334184+00	2026-06-18 01:10:44.334184+00	\N	Página /agent do Arena.ai	f	f	\N
02ddbab0-7c2d-4b22-810c-0f71a4159375	516358a0-a386-4c69-bb53-83609a79e8e0	Hermes Workspace	https://hermes-workspace-lyah.srv1767486.hstgr.cloud/	\N	f	2026-06-19 17:30:20.953224+00	2026-06-19 17:30:20.953224+00	\N	Workspace Hermes (Hostinger Cloud)	f	f	\N
f57fc82b-6d7c-4f1c-95ab-ae3cb5a3505e	516358a0-a386-4c69-bb53-83609a79e8e0	OpenClaw	https://openclaw-29pr.srv1767486.hstgr.cloud/	\N	f	2026-06-19 17:30:20.960113+00	2026-06-19 17:30:20.960113+00	\N	Workspace OpenClaw (Hostinger Cloud)	f	f	\N
bb44b527-e70e-46da-b966-a10cfd83dbf2	516358a0-a386-4c69-bb53-83609a79e8e0	Odysseus	https://odysseus-maww.srv1767486.hstgr.cloud/	\N	f	2026-06-19 17:30:21.047939+00	2026-06-19 17:30:21.047939+00	\N	Workspace Odysseus (Hostinger Cloud)	f	f	\N
\.


--
-- Data for Name: mcp_tokens; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.mcp_tokens (id, user_id, name, token_prefix, token_hash, last_used_at, created_at, updated_at) FROM stdin;
33398f22-bd81-4e3d-bad9-96a8bfa8c991	516358a0-a386-4c69-bb53-83609a79e8e0	jr	ml_b6a1bb1	e8ca3cf74631e61ced9d1eb95d5e9f7a9414db150953efc8993f143d19e9c266	2026-06-19 17:32:55.209+00	2026-06-17 19:24:13.313865+00	2026-06-19 17:32:55.385768+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.profiles (id, email, full_name, avatar_url, created_at, updated_at) FROM stdin;
516358a0-a386-4c69-bb53-83609a79e8e0	aajunior43@gmail.com	Aleksandro Alves da Rocha Junior	\N	2026-06-21 17:11:57.122111+00	2026-06-21 17:11:57.122111+00
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.tags (id, user_id, name, color, created_at) FROM stdin;
f40c3d10-3d10-4523-a952-37c6fc9e2d79	516358a0-a386-4c69-bb53-83609a79e8e0	Email	#3B82F6	2025-06-15 03:01:37.212362+00
1bc810bf-2a67-41db-aa32-ba10f8d6469a	516358a0-a386-4c69-bb53-83609a79e8e0	Prompts	#3B82F6	2025-06-15 03:04:21.755344+00
26071442-4308-407c-b0e1-5ecc823bd744	516358a0-a386-4c69-bb53-83609a79e8e0	Ferramentas	#06B6D4	2025-06-15 03:12:04.582147+00
8b525e4c-b6e7-44ed-bcd0-8a99fc52ef45	516358a0-a386-4c69-bb53-83609a79e8e0	Ia	#F59E0B	2025-06-15 03:13:56.249171+00
07679edc-938c-4bce-9589-f61fa86a83fc	516358a0-a386-4c69-bb53-83609a79e8e0	login	#6366F1	2025-11-15 18:28:29.045207+00
8c27817a-5b84-4562-9e75-7a864ecf4bd0	516358a0-a386-4c69-bb53-83609a79e8e0	planilhas	#EF4444	2025-11-15 18:28:29.040451+00
22247267-c443-47af-8b94-6524c7731a76	516358a0-a386-4c69-bb53-83609a79e8e0	https	#10B981	2025-11-15 18:28:29.047065+00
1382dde6-85db-463c-8958-fa122df82527	516358a0-a386-4c69-bb53-83609a79e8e0	para	#F59E0B	2025-11-15 18:28:29.042594+00
c9a5ccfe-4b92-4e66-81da-8ba7c147815a	516358a0-a386-4c69-bb53-83609a79e8e0	com	#84CC16	2025-11-15 18:28:29.0546+00
e6b9e980-28a0-4ca0-b841-dcfc18a7eda8	516358a0-a386-4c69-bb53-83609a79e8e0	google	#06B6D4	2025-11-15 18:28:29.058844+00
cf718055-fc0e-455d-9ae7-f1c960296104	516358a0-a386-4c69-bb53-83609a79e8e0	accounts	#8B5CF6	2025-11-15 18:28:29.07752+00
b94b45a1-a42a-42fd-bc0d-b3d7f9cff5d3	516358a0-a386-4c69-bb53-83609a79e8e0	okara	#84CC16	2025-11-15 18:49:48.326232+00
141e7540-e3a5-4cc5-af39-6e17984db126	516358a0-a386-4c69-bb53-83609a79e8e0	image	#EF4444	2025-11-15 18:49:49.083742+00
1b05dd68-d424-4e12-ac7d-3103aa371823	516358a0-a386-4c69-bb53-83609a79e8e0	Prefeitura	#84CC16	2026-02-15 12:33:34.353777+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.users (id, email, password_hash, full_name, avatar_url, email_verified, created_at, updated_at) FROM stdin;
516358a0-a386-4c69-bb53-83609a79e8e0	aajunior43@gmail.com	$2a$10$placeholder_hash_replace_with_real_one	Aleksandro Alves da Rocha Junior	\N	t	2025-06-15 02:36:40.791563+00	2025-06-15 02:36:40.791563+00
\.


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_user_id_provider_key; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_provider_key UNIQUE (user_id, provider);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: link_tags link_tags_link_id_tag_id_key; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.link_tags
    ADD CONSTRAINT link_tags_link_id_tag_id_key UNIQUE (link_id, tag_id);


--
-- Name: link_tags link_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.link_tags
    ADD CONSTRAINT link_tags_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mcp_tokens mcp_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.mcp_tokens
    ADD CONSTRAINT mcp_tokens_pkey PRIMARY KEY (id);


--
-- Name: mcp_tokens mcp_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.mcp_tokens
    ADD CONSTRAINT mcp_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags tags_user_id_name_key; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_user_id_name_key UNIQUE (user_id, name);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_categories_user_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_categories_user_id ON public.categories USING btree (user_id);


--
-- Name: idx_folders_parent_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_folders_parent_id ON public.folders USING btree (parent_id);


--
-- Name: idx_folders_user_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_folders_user_id ON public.folders USING btree (user_id);


--
-- Name: idx_link_tags_link_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_link_tags_link_id ON public.link_tags USING btree (link_id);


--
-- Name: idx_link_tags_tag_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_link_tags_tag_id ON public.link_tags USING btree (tag_id);


--
-- Name: idx_links_category_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_links_category_id ON public.links USING btree (category_id);


--
-- Name: idx_links_folder_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_links_folder_id ON public.links USING btree (folder_id);


--
-- Name: idx_links_user_archived; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_links_user_archived ON public.links USING btree (user_id, is_archived);


--
-- Name: idx_links_user_deleted; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_links_user_deleted ON public.links USING btree (user_id, deleted_at);


--
-- Name: idx_links_user_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_links_user_id ON public.links USING btree (user_id);


--
-- Name: idx_tags_user_id; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_tags_user_id ON public.tags USING btree (user_id);


--
-- Name: users on_user_created; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER on_user_created AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: api_keys update_api_keys_updated_at; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER update_api_keys_updated_at BEFORE UPDATE ON public.api_keys FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: folders update_folders_updated_at; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER update_folders_updated_at BEFORE UPDATE ON public.folders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: links update_links_updated_at; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER update_links_updated_at BEFORE UPDATE ON public.links FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: mcp_tokens update_mcp_tokens_updated_at; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER update_mcp_tokens_updated_at BEFORE UPDATE ON public.mcp_tokens FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: hubmaster
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: folders folders_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- Name: link_tags link_tags_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.link_tags
    ADD CONSTRAINT link_tags_link_id_fkey FOREIGN KEY (link_id) REFERENCES public.links(id) ON DELETE CASCADE;


--
-- Name: link_tags link_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.link_tags
    ADD CONSTRAINT link_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: links links_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: links links_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_folder_id_fkey FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE SET NULL;


--
-- Name: links links_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tags tags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict wCyjRMAhrG5ZEpg6VuwdYYG4AJw2d0McDbpCLEn5r7nFw1sGtRlEgJHsXWgND62

