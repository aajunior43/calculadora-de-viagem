--
-- PostgreSQL database dump
--

\restrict miT0lFBFGo93KDPE2fGT1DySkT8AKQuBADTL8LW5Hgjyp9sZ1dp64UAgo2ngYlk

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
-- Name: favorites; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.favorites (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.favorites OWNER TO hubmaster;

--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: hubmaster
--

CREATE SEQUENCE public.favorites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.favorites_id_seq OWNER TO hubmaster;

--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hubmaster
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


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
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: hubmaster
--

CREATE TABLE public.subscriptions (
    id text NOT NULL,
    name text NOT NULL,
    price real NOT NULL,
    currency text DEFAULT 'BRL'::text,
    billing_cycle text DEFAULT 'monthly'::text,
    renewal_date text NOT NULL,
    category text DEFAULT 'other'::text,
    color text DEFAULT '#6366f1'::text,
    icon text DEFAULT ''::text,
    is_active boolean DEFAULT true,
    notes text DEFAULT ''::text,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    updated_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.subscriptions OWNER TO hubmaster;

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
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


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
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.favorites (id, name, url, created_at) FROM stdin;
1	Gmail	https://mail.google.com/mail/u/0/h	2026-06-21 17:40:39.93803+00
2	Google Alerts - Envia alerta de noticias pelo email	https://www.google.com.br/alerts	2026-06-21 17:40:39.942312+00
3	Google Trends - Coisas mais pesquisadas no momento	https://trends.google.com.br/trends/?geo=BR	2026-06-21 17:40:39.942957+00
4	Google Feud - Jogo	https://www.html-et-caetera.com/google-feud/pt/	2026-06-21 17:40:39.94397+00
5	What's Came First? - Jogo	https://artsandculture.google.com/experiment/what-came-first/ZQGBUPErEE3bVg	2026-06-21 17:40:39.944343+00
6	Rápido, desenhe! -Jogo	https://quickdraw.withgoogle.com/	2026-06-21 17:40:39.945209+00
7	DALL-E mini - Gerador de imagem	https://www.craiyon.com/	2026-06-21 17:40:39.947006+00
8	Site confiável	https://www.siteconfiavel.com.br/	2026-06-21 17:40:39.947331+00
9	Chess.com - Jogo	https://www.chess.com/	2026-06-21 17:40:39.947638+00
10	Lichess - Jogo	https://lichess.org/	2026-06-21 17:40:39.948976+00
11	Artigo - Jogo	https://artigo.app/	2026-06-21 17:40:39.950069+00
12	Geoguessr - Jogo	http://www.geoguessr.com/	2026-06-21 17:40:39.950963+00
13	Yandex Imagens - Melhor buscados de imagens	https://yandex.com/images/	2026-06-21 17:40:39.951248+00
14	Lampions Bet - Site de apostas	https://www.lampions.bet/	2026-06-21 17:40:39.951671+00
15	SteamDB - Promoção de jogos	https://steamdb.info/	2026-06-21 17:40:39.952905+00
16	Fast - Teste de velocidade da internet	https://fast.com/pt/	2026-06-21 17:40:39.953186+00
17	Virus Total - Checar arquivos	https://www.virustotal.com/gui/home/upload	2026-06-21 17:40:39.953486+00
18	Let's Enhance - Upscaler de imagens	https://letsenhance.io/	2026-06-21 17:40:39.953918+00
19	DreamStudio - Gerador de imagem	https://stabilityai.us.auth0.com/u/login	2026-06-21 17:40:39.955081+00
20	Videoder - App de baixar videos	https://www.videoder.com/pt	2026-06-21 17:40:39.955425+00
21	Extrator de Imagens - Baixar todas imagens de um site	https://pt.rakko.tools/tools/56/	2026-06-21 17:40:39.955948+00
22	Bitly 0 Encurtador de URL	https://bityli.com/	2026-06-21 17:40:39.957923+00
23	BotoStore - Melhores bots	https://botostore.com/	2026-06-21 17:40:39.95917+00
24	Just Delete Me - Como deletar contas de diversos sites	https://backgroundchecks.org/justdeleteme/	2026-06-21 17:40:39.961216+00
25	Wayback Machine - Arquivos de sites	https://web.archive.org/	2026-06-21 17:40:39.96149+00
26	Deepl Translator - Melhor tradutor	https://www.deepl.com/pt-BR/translator	2026-06-21 17:40:39.961794+00
27	Hunter - Procurar emails de empresas	https://hunter.io/	2026-06-21 17:40:39.962922+00
28	Dólar Hoje - Cotação do dolar	https://dolarhoje.com/	2026-06-21 17:40:39.963208+00
29	Globe - Jogo	https://globle-game.com/	2026-06-21 17:40:39.963519+00
30	Letreco - Jogo	https://www.gabtoschi.com/letreco/	2026-06-21 17:40:39.964189+00
31	Contexto - Jogo	https://contexto.me/	2026-06-21 17:40:39.965005+00
32	Pgsharp - Hack Pokemon GO	https://www.pgsharp.com/	2026-06-21 17:40:39.965314+00
33	Termo - Jogo	https://term.ooo/	2026-06-21 17:40:39.965971+00
34	Ipogo - Hack Pokemon GO	https://ipogo.app/	2026-06-21 17:40:39.966971+00
35	Wikirota - Calcular distância e custos de viagem	https://www.wikirota.com/	2026-06-21 17:40:39.967289+00
36	Taggo - Meu cartão virtual	https://taggo.one/aleksandroalves	2026-06-21 17:40:39.9676+00
37	Stripchat	https://pt.stripchat.com/	2026-06-21 17:40:39.968201+00
38	Copy AI - AI para criar copy	https://app.copy.ai/	2026-06-21 17:40:39.968666+00
39	Palavra do dia - Jogo	https://palavra-do-dia.pt/	2026-06-21 17:40:39.969991+00
40	Eternal Box - IA que transforma uma musica infinita	https://eternalbox.dev/jukebox_index.html	2026-06-21 17:40:39.970301+00
41	Blaze IPTV	http://blaze.koffice.site/login/	2026-06-21 17:40:39.970612+00
42	Loja Blaze	https://www.lojablaze.online/	2026-06-21 17:40:39.970923+00
43	FakeYou - Sintetizador de voz	https://fakeyou.com/	2026-06-21 17:40:39.972086+00
44	Palavres	https://palavr.es/	2026-06-21 17:40:39.972607+00
45	Moviedle	https://likewisetv.com/arcade/moviedle	2026-06-21 17:40:39.972961+00
46	Posterdle	https://likewisetv.com/arcade/posterdle	2026-06-21 17:40:39.973462+00
47	Doctranslator	https://www.onlinedoctranslator.com/pt/translationform	2026-06-21 17:40:39.97412+00
48	Gerador de Gmail	https://generator.email/blog/gmail-generator	2026-06-21 17:40:39.97519+00
49	Gerador de Gmail 2	https://tools.electronicbub.com/pt/gerador-de-e-mail-do-gmail/	2026-06-21 17:40:39.97543+00
50	Pré-pós SEO	https://www.prepostseo.com/	2026-06-21 17:40:39.975753+00
51	TokBoard	https://tokboard.com/	2026-06-21 17:40:39.977+00
52	Picwish	https://picwish.com/	2026-06-21 17:40:39.977281+00
53	Trendingtopics	https://trendingtopics.com.br/brasil#	2026-06-21 17:40:39.977578+00
54	Fuso Horario Mundial	https://fusohorariomundial.com.br/tabela	2026-06-21 17:40:39.977857+00
55	PVPOKE	https://pt-br.pvpoke-re.com/battle/	2026-06-21 17:40:39.97907+00
56	Pogo Stat	https://pogostat.com/	2026-06-21 17:40:39.979383+00
57	IMG2GO	https://www.img2go.com/pt	2026-06-21 17:40:39.979653+00
58	MidJourney	https://www.midjourney.com/	2026-06-21 17:40:39.980966+00
59	Playground AI	https://playgroundai.com/	2026-06-21 17:40:39.981302+00
60	Mage Space	https://www.mage.space/	2026-06-21 17:40:39.981567+00
61	CLIP Interrogator	https://huggingface.co/spaces/pharma/CLIP-Interrogator	2026-06-21 17:40:39.981873+00
62	Pxhere	https://pxhere.com/pt	2026-06-21 17:40:39.983071+00
63	Stable Diffusion Prompt Generator	https://huggingface.co/spaces/Gustavosta/MagicPrompt-Stable-Diffusion	2026-06-21 17:40:39.983389+00
64	Tempmail	https://temp-mail.org/pt/	2026-06-21 17:40:39.983634+00
65	Photopea	https://www.photopea.com/	2026-06-21 17:40:39.985007+00
66	Buscapé	https://www.buscape.com.br/	2026-06-21 17:40:39.985345+00
67	Copy Google Drive	https://script.google.com/macros/s/AKfycbxbGNGajrxv-HbX2sVY2OTu7yj9VvxlOMOeQblZFuq7rYm7uyo/exec	2026-06-21 17:40:39.985717+00
68	Investing	https://br.investing.com/equities/	2026-06-21 17:40:39.986049+00
69	Passei Direto	https://www.passeidireto.com/	2026-06-21 17:40:39.987012+00
70	GGMax	https://ggmax.com.br/	2026-06-21 17:40:39.987926+00
71	Ulist	https://guihkx.github.io/ulist/	2026-06-21 17:40:39.988231+00
72	MyFonts	https://www.myfonts.com/pages/whatthefont	2026-06-21 17:40:39.989261+00
73	Whatfontis	https://www.whatfontis.com/	2026-06-21 17:40:39.990015+00
74	Extract	https://extract.me/pt/	2026-06-21 17:40:39.990339+00
75	Toffee Share	https://toffeeshare.com/	2026-06-21 17:40:39.991075+00
76	Yandex Images	https://yandex.com/images/	2026-06-21 17:40:39.991485+00
77	Tome	https://beta.tome.app/	2026-06-21 17:40:39.992081+00
78	Speed test Cloudflare	https://speed.cloudflare.com/	2026-06-21 17:40:39.993161+00
79	Visualizador De Imagens	https://andersonmak.com/scripts/visualizador-imagens.html	2026-06-21 17:40:39.993971+00
80	Birme Redimensionar imagem	https://www.birme.net/	2026-06-21 17:40:39.994249+00
81	Emailondeck	https://www.emailondeck.com/pt/	2026-06-21 17:40:39.994987+00
82	Pixabay	https://pixabay.com/pt/	2026-06-21 17:40:39.995974+00
83	Upscale	https://www.upscale.media/pt	2026-06-21 17:40:39.996292+00
84	Imgupscaler	https://imgupscaler.com/	2026-06-21 17:40:39.996575+00
85	Pexels	https://www.pexels.com/pt-br/	2026-06-21 17:40:39.997964+00
86	Smart Upscaler	https://icons8.com.br/upscaler	2026-06-21 17:40:39.999012+00
87	Maximum Diffusion	https://huggingface.co/spaces/Nickhilearla135095/maximum_diffusion	2026-06-21 17:40:39.999942+00
88	Upscaler	https://www.upscale.media/pt/upload	2026-06-21 17:40:40.000203+00
89	Watermark Remover	https://www.watermarkremover.io/pt/upload	2026-06-21 17:40:40.001133+00
90	Remover Fundo	https://www.erase.bg/pt/upload	2026-06-21 17:40:40.001442+00
91	Restaurar Face	https://arc.tencent.com/en/ai-demos/faceRestoration	2026-06-21 17:40:40.001993+00
92	Jogos Online	https://poki.com.br/	2026-06-21 17:40:40.00306+00
93	Tempmailo	https://tempmailo.com/	2026-06-21 17:40:40.003964+00
94	Mail Temp	https://mail.tm/pt/	2026-06-21 17:40:40.004277+00
95	Wetransfer	https://wetransfer.com/	2026-06-21 17:40:40.004706+00
96	ChatSonic	https://app.writesonic.com/pt-pt/login	2026-06-21 17:40:40.006007+00
97	Download Imagens	https://products.aspose.app/html/pt/image-downloader	2026-06-21 17:40:40.006955+00
98	Ytscribe	https://ytscribe.com/	2026-06-21 17:40:40.007319+00
99	Stable Diffusion Colab	https://colab.research.google.com/github/camenduru/stable-diffusion-webui-colab/blob/main/stable_diffusion_v2_webui_colab.ipynb	2026-06-21 17:40:40.007634+00
100	Magic Eraser	https://magicstudio.com/magiceraser	2026-06-21 17:40:40.008207+00
101	Stable Diffusion 2 - Colab	https://colab.research.google.com/github/camenduru/stable-diffusion-webui-colab/blob/main/stable_diffusion_1_5_webui_colab.ipynb	2026-06-21 17:40:40.009239+00
102	Reference Pictures	https://reference.pictures/	2026-06-21 17:40:40.009524+00
103	Unsplash	https://unsplash.com/pt-br	2026-06-21 17:40:40.010005+00
104	Remove BG	https://www.remove.bg/pt-br	2026-06-21 17:40:40.010611+00
105	Instant Username	https://instantusername.com/#/	2026-06-21 17:40:40.011036+00
106	Lufi Upload	https://upload.disroot.org/	2026-06-21 17:40:40.012512+00
107	Civit AI	https://civitai.com/	2026-06-21 17:40:40.013946+00
108	SD 1111	https://colab.research.google.com/github/TheLastBen/fast-stable-diffusion/blob/main/fast_stable_diffusion_AUTOMATIC1111.ipynb#scrollTo=Y9EBc437WDOs	2026-06-21 17:40:40.014992+00
109	Pirate Bay	https://pirate-bays.net/torrent-search	2026-06-21 17:40:40.015317+00
110	BT Met Utorrent	https://btmet.com/	2026-06-21 17:40:40.015928+00
111	Btdig	https://btdig.com/	2026-06-21 17:40:40.016991+00
112	PromptHero	https://prompthero.com/	2026-06-21 17:40:40.01732+00
113	Umbler Email	https://mail.umbler.com/	2026-06-21 17:40:40.017619+00
114	Meu Pastebin	https://pastebin.com/u/aajunior43	2026-06-21 17:40:40.017984+00
115	YouTube Scribe	https://ytscribe.com/	2026-06-21 17:40:40.018669+00
116	Chatsonic	https://app.writesonic.com/pt-pt/login	2026-06-21 17:40:40.019999+00
117	Mail Temp	https://mail.tm/pt/	2026-06-21 17:40:40.020921+00
118	GPT Zero	https://gptzero.me/	2026-06-21 17:40:40.021235+00
119	Prompt Hunt	https://www.prompthunt.com/	2026-06-21 17:40:40.021509+00
120	Wonder Dynamics	https://app.wonderdynamics.com/	2026-06-21 17:40:40.022988+00
121	Open Art	https://openart.ai/	2026-06-21 17:40:40.023366+00
122	Cat Bird AI	https://www.catbird.ai/	2026-06-21 17:40:40.024181+00
123	Midjourney Showcase	https://www.midjourney.com/showcase/recent/	2026-06-21 17:40:40.024454+00
124	Getimg	https://getimg.ai/	2026-06-21 17:40:40.025102+00
125	´Prodia Ai	https://app.prodia.com/	2026-06-21 17:40:40.025841+00
126	Futurepedia	https://www.futurepedia.io/	2026-06-21 17:40:40.026182+00
127	DreamStudio	https://dreamstudio.ai/generate	2026-06-21 17:40:40.026497+00
128	Graviti	https://webui.graviti.com/	2026-06-21 17:40:40.02693+00
129	Copy Generator	https://app.copygenerator.ai/	2026-06-21 17:40:40.027889+00
130	AgentGPT	https://agentgpt.reworkd.ai/	2026-06-21 17:40:40.028218+00
131	Picso	https://picso.ai/	2026-06-21 17:40:40.02882+00
132	Character AI	https://beta.character.ai/	2026-06-21 17:40:40.029355+00
133	Open Assistant	https://open-assistant.io/chat	2026-06-21 17:40:40.03008+00
134	Colab55	https://www.colab55.com/me	2026-06-21 17:40:40.030747+00
135	Seek Art	https://seek.art/	2026-06-21 17:40:40.031071+00
136	Future Tools	https://www.futuretools.io/	2026-06-21 17:40:40.031992+00
137	Plazmapunk	https://www.plazmapunk.com/app	2026-06-21 17:40:40.032305+00
138	AICA	https://aica.vercel.app/	2026-06-21 17:40:40.032991+00
139	RunDiffusion	https://app.rundiffusion.com/	2026-06-21 17:40:40.033319+00
140	Replicate	https://replicate.com/	2026-06-21 17:40:40.034222+00
141	God Mode	https://godmode.space/	2026-06-21 17:40:40.034502+00
142	Cri.ai Prompts	https://prompt.criai.net.br/	2026-06-21 17:40:40.035059+00
143	CLIP Interrogator	https://huggingface.co/spaces/pharma/CLIP-Interrogator	2026-06-21 17:40:40.036067+00
144	Perplexity	https://www.perplexity.ai/	2026-06-21 17:40:40.036422+00
145	Gigapixel AI	https://www.topazlabs.com/gigapixel-ai	2026-06-21 17:40:40.036997+00
146	Clipdrop Relight	https://clipdrop.co/relight	2026-06-21 17:40:40.038062+00
147	Pixelbin IO	https://console.pixelbin.io/organization/292159/dashboard	2026-06-21 17:40:40.038377+00
148	Mlabs	https://accounts.mlabs.io/	2026-06-21 17:40:40.038652+00
149	Leonardo AI	https://app.leonardo.ai/auth/login	2026-06-21 17:40:40.039988+00
150	Kaiber	https://www.kaiber.ai/	2026-06-21 17:40:40.04101+00
151	Mage Space	https://www.mage.space/	2026-06-21 17:40:40.041318+00
152	Playground AI	https://playgroundai.com/	2026-06-21 17:40:40.041585+00
153	Getimg AI	https://getimg.ai/	2026-06-21 17:40:40.042999+00
154	Dream Like	https://dreamlike.art/	2026-06-21 17:40:40.043681+00
155	Dream Studio	https://beta.dreamstudio.ai/generate	2026-06-21 17:40:40.043995+00
156	Magic Prompt	https://huggingface.co/spaces/Gustavosta/MagicPrompt-Stable-Diffusion	2026-06-21 17:40:40.045073+00
157	Leia PIX	https://convert.leiapix.com/	2026-06-21 17:40:40.045392+00
158	You	https://you.com/search?q=who+are+you&tbm=youchat&cfr=chat	2026-06-21 17:40:40.045801+00
159	Witeboard	https://witeboard.com/028e2350-df0a-11ed-b429-73a650fc22c7	2026-06-21 17:40:40.046831+00
160	Kleki	https://kleki.com/	2026-06-21 17:40:40.047174+00
161	Coolors	https://coolors.co/palettes/trending	2026-06-21 17:40:40.047512+00
162	Pelando	https://www.pelando.com.br/	2026-06-21 17:40:40.048103+00
163	Alternative	https://alternativeto.net/	2026-06-21 17:40:40.048803+00
164	Nperf	https://www.nperf.com/pt/	2026-06-21 17:40:40.050013+00
165	Leonardo AI	https://app.leonardo.ai/ai-generations	2026-06-21 17:40:40.050308+00
166	Picfinder	https://picfinder.ai/	2026-06-21 17:40:40.050601+00
167	Instant Art	https://instantart.io/	2026-06-21 17:40:40.050865+00
168	Blaze IPTV	https://blaze.koffice.site/login/	2026-06-21 17:40:40.053058+00
169	Check list Pokémon GO	https://9db.jp/pokemongo/data/6406	2026-06-21 17:40:40.05417+00
170	Check list Pokémon GO II	https://leekduck.com/shiny/	2026-06-21 17:40:40.054505+00
171	Ihit	https://ihit.com.br/loja/	2026-06-21 17:40:40.054982+00
172	Adobe Enhancer	https://podcast.adobe.com/enhance	2026-06-21 17:40:40.057035+00
173	Taggo One	https://taggo.one/	2026-06-21 17:40:40.05737+00
174	Lexica	https://lexica.art/	2026-06-21 17:40:40.057684+00
175	Reference Picture	https://reference.pictures/figure-drawing-rachel/	2026-06-21 17:40:40.058967+00
176	Color Adobe	https://color.adobe.com/pt/create/color-wheel	2026-06-21 17:40:40.059296+00
177	Kaiber	https://app.kaiber.ai/	2026-06-21 17:40:40.059581+00
178	Site Confiável	https://www.siteconfiavel.com.br/site/promptstacks-com	2026-06-21 17:40:40.061003+00
179	Check list Pokémon GO III	https://rplus.github.io/Pokemon-shiny/	2026-06-21 17:40:40.061339+00
180	PNG Tree	https://pt.pngtree.com/	2026-06-21 17:40:40.061622+00
181	Caractere Invisível	https://fabricioventura.com/caractere	2026-06-21 17:40:40.06294+00
182	Archive ORG	https://web.archive.org/	2026-06-21 17:40:40.063376+00
183	Pastebin	https://pastebin.com/	2026-06-21 17:40:40.063984+00
184	Seedr	https://www.seedr.cc/	2026-06-21 17:40:40.065058+00
185	Envato elements	https://elements.envato.com/pt-br/	2026-06-21 17:40:40.065349+00
186	The Pirate Bay	https://pirate-bays.net/	2026-06-21 17:40:40.065654+00
187	Cursos Top	https://downloadcursos.top/	2026-06-21 17:40:40.066987+00
188	Geforce Now	https://abya.com/gfn/pt-BR	2026-06-21 17:40:40.067317+00
189	Vector Magic	https://pt.vectormagic.com/	2026-06-21 17:40:40.067604+00
190	Color Hunt	https://colorhunt.com/	2026-06-21 17:40:40.06793+00
191	Ferramentas	https://www.negociosemmente.com.br/ferramentas	2026-06-21 17:40:40.069035+00
192	Prompt Base	https://promptbase.com/	2026-06-21 17:40:40.069312+00
193	D-ID	https://studio.d-id.com/	2026-06-21 17:40:40.070013+00
194	Prompts GPT Pago	https://comprechat.circle.so/c/inicie-aqui	2026-06-21 17:40:40.070348+00
195	Prompts GPT Pago II	https://ideiaschatgpt.com.br/prompts/	2026-06-21 17:40:40.071097+00
196	Estilos Midjourney	https://github.com/willwulfken/MidJourney-Styles-and-Keywords-Reference/blob/main/README.md	2026-06-21 17:40:40.072068+00
197	Remover marca d'água de video	https://online-video-cutter.com/pt/remove-logo	2026-06-21 17:40:40.072651+00
198	Estilos Midjourney	https://www.midlibrary.io/	2026-06-21 17:40:40.074214+00
199	Varias ferramentas Premium em uma só	https://tuconjunta.com/	2026-06-21 17:40:40.074532+00
200	10 Min email temporário	https://10minemail.com/pt/	2026-06-21 17:40:40.075203+00
201	Prompts pagos GPT	https://chatgpt-lucrativo.notion.site/chatgpt-lucrativo/Marketing-Copie-e-Cole-500-Comandos-Secretos-para-ChatGPT-99-prompts-para-otimizar-tarefas-9faaa2f9fb5f45bea41f7c763917ce23	2026-06-21 17:40:40.076007+00
202	Designi	https://www.designi.com.br/	2026-06-21 17:40:40.076363+00
203	Freepik	https://br.freepik.com/	2026-06-21 17:40:40.076875+00
204	Prompts pagos GPT	https://comprechat.circle.so/c/diversos/	2026-06-21 17:40:40.077854+00
205	Vectorizer IO	https://www.vectorizer.io/	2026-06-21 17:40:40.078184+00
206	IMI Prompt	https://www.imiprompt.com/	2026-06-21 17:40:40.078452+00
207	Essa pessoa não existe	https://this-person-does-not-exist.com/pt	2026-06-21 17:40:40.079091+00
208	Future Lab	https://www.futureailab.com/	2026-06-21 17:40:40.079965+00
209	GPT Open Source	https://chat.lmsys.org/	2026-06-21 17:40:40.080289+00
210	AI Fusion	https://aifusionapp.com/	2026-06-21 17:40:40.081042+00
211	Adobe Animate	https://express.adobe.com/express-apps/animate-from-audio/	2026-06-21 17:40:40.081339+00
212	Stadio AI	https://stadio.ai/	2026-06-21 17:40:40.082096+00
213	Dream Like	https://dreamlike.art/	2026-06-21 17:40:40.082509+00
214	Run Diffusion	https://app.rundiffusion.com/	2026-06-21 17:40:40.083058+00
215	Plasma Punk	https://www.plazmapunk.com/	2026-06-21 17:40:40.083966+00
216	ART Station	https://www.artstation.com/	2026-06-21 17:40:40.084265+00
217	Estilos Midjourney	https://rentry.org/artists_sd-v1-4_iv	2026-06-21 17:40:40.084678+00
218	Microsoft Designer	https://designer.microsoft.com/	2026-06-21 17:40:40.085602+00
219	Open Assistent GPT	https://open-assistant.io/pt-BR/chat/	2026-06-21 17:40:40.086022+00
220	Scenario	https://app.scenario.com/login	2026-06-21 17:40:40.087086+00
221	Pixai Art	https://pixai.art/	2026-06-21 17:40:40.089018+00
222	Discord	https://discord.com/login	2026-06-21 17:40:40.089314+00
223	Prodia IA	https://app.prodia.com/	2026-06-21 17:40:40.089622+00
224	Graviti	https://webui.graviti.com/?__theme=dark	2026-06-21 17:40:40.090964+00
225	InvokeAI Colab	https://colab.research.google.com/github/peaashmeter/invoke-ai-gui-colab/blob/main/invoke_ai_gui_colab.ipynb	2026-06-21 17:40:40.091253+00
226	Camenduru	https://github.com/camenduru/stable-diffusion-webui-colab	2026-06-21 17:40:40.09178+00
227	Nightcafe	https://nightcafe.studio/	2026-06-21 17:40:40.09308+00
228	DreamBooth	https://colab.research.google.com/github/TheLastBen/fast-stable-diffusion/blob/main/fast-DreamBooth.ipynb	2026-06-21 17:40:40.093983+00
229	Wirestock - Vender imagens em varios banco de imagens de uma vez	https://wirestock.io/	2026-06-21 17:40:40.094297+00
230	Pimeyes - Buscador de rostos na internet	https://pimeyes.com/en	2026-06-21 17:40:40.094621+00
231	Hero - Varios prompts para chatGPT	https://hero.page/	2026-06-21 17:40:40.095278+00
232	AItools - Varias ferramentas de IA	https://aitools.lol/	2026-06-21 17:40:40.096074+00
233	Gumroad - Vender produtos digitais	https://app.gumroad.com	2026-06-21 17:40:40.09638+00
234	Library - Varias ferramentas de IA	https://library.phygital.plus/	2026-06-21 17:40:40.097066+00
235	AutoGPT	https://autogpt.thesamur.ai/agi	2026-06-21 17:40:40.097948+00
236	CamelAGI	https://camelagi.thesamur.ai/	2026-06-21 17:40:40.098222+00
237	Alternativa do Chat GPT	https://chatbot.theb.ai/#/chat/1002	2026-06-21 17:40:40.098514+00
238	GFPGAN - Upscale de imagens no google colab	https://colab.research.google.com/drive/1k2Zod6kSHEvraybHl50Lys0LerhyTMCo?usp=sharing	2026-06-21 17:40:40.099436+00
239	Copy Folder - Transferir arquivos compartilhados para o Google Drive	https://workspacetips.io/tools/copy-folder/	2026-06-21 17:40:40.099962+00
240	Pornpen AI - PN	https://pornpen.ai/	2026-06-21 17:40:40.10088+00
241	Made Porn - PN	https://made.porn	2026-06-21 17:40:40.102332+00
242	AI Hentai - PN	https://ai-hentai.net	2026-06-21 17:40:40.102999+00
243	Pornpen Art - PN	https://pornpen.art	2026-06-21 17:40:40.104065+00
244	AI Pornjourney - PN	https://aipornjourney.com	2026-06-21 17:40:40.10438+00
245	Deviantart	https://www.deviantart.com	2026-06-21 17:40:40.104681+00
246	Adobe Firefly	https://firefly.adobe.com	2026-06-21 17:40:40.105986+00
247	Artstation	https://www.artstation.com	2026-06-21 17:40:40.106311+00
248	Hotpot AI	https://hotpot.ai/art-generator	2026-06-21 17:40:40.106615+00
249	Face Restoration - IA restaurar face	https://arc.tencent.com/en/ai-demos/faceRestoration	2026-06-21 17:40:40.106932+00
250	ESRGAN - Upscaler	https://replicate.com/xinntao/realesrgan	2026-06-21 17:40:40.108103+00
251	Convert DPI - Converter imagens para Banco de imagens	https://convert-dpi.com/br/	2026-06-21 17:40:40.108402+00
252	Calculadora de regra de 3	https://www.4devs.com.br/calculadora_regra_tres_simples	2026-06-21 17:40:40.108712+00
253	Bing Creator - IA de criar imagem	https://www.bing.com/images/create	2026-06-21 17:40:40.109051+00
254	Adobe Firefly - IA	https://firefly.adobe.com/generate	2026-06-21 17:40:40.109918+00
255	CRIAI - Ferramenta de gerar prompts de Imagem	https://prompt.criai.net.br/	2026-06-21 17:40:40.110294+00
256	Sinkin AI	https://sinkin.ai/	2026-06-21 17:40:40.110987+00
257	Patience. AI	https://www.patience.ai	2026-06-21 17:40:40.111433+00
258	Snack Prompt - Rede social de prompts para GPT	https://snackprompt.com/	2026-06-21 17:40:40.111999+00
259	Eleven Labs - Ia Sintetiza texto e clona voz	https://beta.elevenlabs.io	2026-06-21 17:40:40.112837+00
260	Theresanaiforthat - Biblioteca de IAS	https://theresanaiforthat.com/	2026-06-21 17:40:40.114005+00
261	Prompt Vibes - Biblioteca de Prompts	https://www.promptvibes.com/	2026-06-21 17:40:40.114281+00
262	MidJourney-Styles-and-Keywords-Reference	https://github.com/willwulfken/MidJourney-Styles-and-Keywords-Reference	2026-06-21 17:40:40.114711+00
263	Chatabc	https://aajunior43.chatabc.ai	2026-06-21 17:40:40.115999+00
264	PIC Enhancer - Upscale	https://picsenhancer.com/upload	2026-06-21 17:40:40.116316+00
265	Phygital - Varias ferramentas SD	https://app.phygital.plus/	2026-06-21 17:40:40.116637+00
266	Aitech Viral - Biblioteca de IA	https://aitechviral.com/	2026-06-21 17:40:40.117964+00
267	Onlyfans ai	https://onlyfansai.net/	2026-06-21 17:40:40.119006+00
268	Heuristica	https://www.heuristi.ca/	2026-06-21 17:40:40.119327+00
269	Promptden	https://promptden.com/	2026-06-21 17:40:40.119646+00
270	Runpod	https://runpod.io	2026-06-21 17:40:40.12068+00
271	Arthub	https://arthub.ai	2026-06-21 17:40:40.121004+00
272	Artifylabs	https://artifylabs.io/restore	2026-06-21 17:40:40.121317+00
273	FlowGPT	https://flowgpt.com/	2026-06-21 17:40:40.122008+00
274	Pornderful	https://pornderful.ai/	2026-06-21 17:40:40.122823+00
275	Pornjoy	https://pornjoy.ai/	2026-06-21 17:40:40.123217+00
276	Onlyfakes	https://onlyfakes.app/	2026-06-21 17:40:40.123568+00
277	Pornshow	https://pornshow.ai/home	2026-06-21 17:40:40.124256+00
278	Hero	https://hero.page/	2026-06-21 17:40:40.125076+00
279	Etsy - Comprer e vender Prompts	https://www.etsy.com/	2026-06-21 17:40:40.125379+00
280	SCISPACE - IA para estudos cientificos	https://typeset.io/	2026-06-21 17:40:40.127003+00
281	Seaart AI - Gerar imagens	https://www.seaart.ai/	2026-06-21 17:40:40.128067+00
282	ChatPDF - ChaatGPT para PDF	https://www.chatpdf.com/	2026-06-21 17:40:40.128405+00
283	cohesive	https://cohesive.so/	2026-06-21 17:40:40.128736+00
284	Calculadora de AR	https://calculateaspectratio.com/	2026-06-21 17:40:40.129965+00
285	Umbler - Email	https://mail.umbler.com/	2026-06-21 17:40:40.130268+00
286	Heygen	https://www.heygen.com/	2026-06-21 17:40:40.13057+00
287	Flowgpt	https://flowgpt.com/	2026-06-21 17:40:40.130881+00
288	DR. Far Far	https://www.dr-farfar.com/	2026-06-21 17:40:40.132963+00
289	Addmefast - Trocar seguidores	https://addmefast.com/	2026-06-21 17:40:40.133278+00
290	Woxo - Ia de criar vídeo	https://woxo.tech/	2026-06-21 17:40:40.133608+00
291	Fornecedor do Brasil - Painel de seguidores	https://fornecedorbrasil.com/	2026-06-21 17:40:40.13497+00
292	Turbo Leads - Comprar contas para extração	https://turboleads.mycartpanda.com/	2026-06-21 17:40:40.136+00
293	Matconte - Bots top para telegram	https://matheusconte.com.br/	2026-06-21 17:40:40.136308+00
294	SMS Virtual - Comprar chip	https://smsvirtual.com.br/	2026-06-21 17:40:40.136548+00
295	ZapCloud - Disparos em massa	https://zapcloud.com.br/	2026-06-21 17:40:40.13718+00
296	Maya IA	https://www.mayaai.net/	2026-06-21 17:40:40.138092+00
297	Thinkdiffusion	https://www.thinkdiffusion.com/	2026-06-21 17:40:40.138378+00
298	Scribd Downloader - Baixar arquivos do Scribd	https://docdownloader.com/	2026-06-21 17:40:40.13892+00
299	Imgnai	https://app.imgnai.com/generate	2026-06-21 17:40:40.139867+00
300	Archive	https://archive.org/	2026-06-21 17:40:40.140294+00
301	Ifind - Consulta ilegal	https://i-find.org/	2026-06-21 17:40:40.140772+00
302	Uploud de PDF para o GPT ler	https://aipdf.app/	2026-06-21 17:40:40.14212+00
303	Vercel - Hospedar repositório do Github	https://vercel.com/	2026-06-21 17:40:40.142424+00
304	Unicórnio Shop - Comprar contas premium	https://unicornshop.cc/	2026-06-21 17:40:40.142784+00
305	HG Store 98 - Loja de uniforme de futebol	https://hgstore98.com/	2026-06-21 17:40:40.143987+00
306	Pronto Mail - E-mail criptografado	https://mail.proton.me/	2026-06-21 17:40:40.144319+00
307	Hispy - Ferramenta de espionagem	https://www.hispy.io/	2026-06-21 17:40:40.144596+00
308	Exploit DB - Termos de Google Dorks	https://www.exploit-db.com/google-hacking-database	2026-06-21 17:40:40.144972+00
309	Voice Clone - Dankicode	https://voiceclone.dankicode.ai/login.php	2026-06-21 17:40:40.146209+00
310	Adarsus - Remover metadados	https://www.adarsus.com/en/remove-metadata-online-document-image-video	2026-06-21 17:40:40.146513+00
311	Egirls - Onlyfans criados por IA	https://egirls.wtf/	2026-06-21 17:40:40.146801+00
312	Painel Blaze IPTV - novo	https://painel.blaze.tv.br/index.php	2026-06-21 17:40:40.147261+00
313	POE - Várias IAs	https://poe.com/chat/2nkam00wubbc92bnuz8	2026-06-21 17:40:40.148182+00
314	Face Swapper	https://faceswapper.ai/swapper	2026-06-21 17:40:40.148429+00
315	LensGO AI	https://lensgo.ai/	2026-06-21 17:40:40.148834+00
316	Estica - Loja para vender camisetas	https://estica.com.br/	2026-06-21 17:40:40.150069+00
317	Dólar Hoje	https://dolarhoje.com/	2026-06-21 17:40:40.150377+00
318	Ideogram AI	https://ideogram.ai/t/trending	2026-06-21 17:40:40.150642+00
319	G Prompter - Gerar Prompts	https://www.g-prompter.com/en/prompt/photo	2026-06-21 17:40:40.151203+00
320	Heylink - Árvore de link	https://heylink.me/	2026-06-21 17:40:40.152077+00
321	Vibx - Comprar e vender pelo telegram	https://www.marketplace.vibx.com.br/	2026-06-21 17:40:40.152414+00
322	PI IA	https://pi.ai/talk	2026-06-21 17:40:40.152936+00
323	Dispara Ai - Enviar mensagem em massa	https://app.dispara.ai/	2026-06-21 17:40:40.154241+00
324	GOVIP - Ótimo site para Designer	https://govip.com.br/login	2026-06-21 17:40:40.154547+00
325	PasteFo	https://paste.fo/	2026-06-21 17:40:40.154922+00
326	Porn Store	https://pornstore.org/	2026-06-21 17:40:40.155347+00
327	User Drive - Upload	https://usersdrive.com/	2026-06-21 17:40:40.156192+00
328	Dditor de imagem com IA	https://avc.ai/	2026-06-21 17:40:40.156449+00
329	Placeit - Mockups Online	https://placeit.net/	2026-06-21 17:40:40.157061+00
330	Modyfy IA	https://www.modyfi.com/	2026-06-21 17:40:40.158067+00
331	Simples Scrapre GPT	https://simplescraper.io/scrapetoai/	2026-06-21 17:40:40.158345+00
332	Topai - Melhores IAs	https://topai.tools/	2026-06-21 17:40:40.158761+00
333	Agenda Hero - Adiciona seus afazeres no Google Agenda	https://agendahero.com/magic?utm_source=topai.tools&utm_medium=website_topai&utm_campaign=topai.tools	2026-06-21 17:40:40.159525+00
334	Kreai	https://www.krea.ai/home	2026-06-21 17:40:40.159959+00
335	Palavras Chave	https://keywordsheeter.com/	2026-06-21 17:40:40.161066+00
336	DPI de imagens	https://convert-dpi.com/br/	2026-06-21 17:40:40.161506+00
337	Nbox Ai - Varias LLMs	https://chat.nbox.ai	2026-06-21 17:40:40.161794+00
338	Educafit - Curso de educação física	https://educafit.com.br/	2026-06-21 17:40:40.162506+00
339	ChatGOT	https://start.chatgot.io/	2026-06-21 17:40:40.16308+00
340	Theb Ai	https://beta.theb.ai/home	2026-06-21 17:40:40.164071+00
341	Cg Dream	https://cgdream.ai/	2026-06-21 17:40:40.164367+00
342	Pandora Box	https://www.pandorasbox.ai/nsfw	2026-06-21 17:40:40.164688+00
343	Product Hunt	https://www.producthunt.com/	2026-06-21 17:40:40.167005+00
344	Pixio	https://pixio.myapps.ai/	2026-06-21 17:40:40.167304+00
345	Mylens	https://mylens.ai/	2026-06-21 17:40:40.167609+00
346	Squaad Ai	https://squaadai.com/	2026-06-21 17:40:40.168+00
347	Guinness	https://www.guinnessworldrecords.com.br/	2026-06-21 17:40:40.169034+00
348	Download videos Youtube	https://www.downloadbazar.com/	2026-06-21 17:40:40.169379+00
349	TTS Openai	https://huggingface.co/spaces/ysharma/OpenAI_TTS_New	2026-06-21 17:40:40.169688+00
350	Suno AI	https://www.suno.ai/	2026-06-21 17:40:40.170273+00
351	Midjourney Stats	https://midjourneystats.com/	2026-06-21 17:40:40.171083+00
352	Aitoptools	https://aitoptools.com/	2026-06-21 17:40:40.171345+00
353	Producthunt	https://www.producthunt.com/	2026-06-21 17:40:40.17198+00
354	Shakker ai	https://www.shakker.ai/	2026-06-21 17:40:40.173065+00
355	Glif	https://glif.app/glifs	2026-06-21 17:40:40.173494+00
356	Claude AI	https://claude.ai/chats	2026-06-21 17:40:40.173884+00
357	Pikaso	https://www.freepik.com/pikaso	2026-06-21 17:40:40.174971+00
358	Estante virtual	https://www.estantevirtual.com.br/	2026-06-21 17:40:40.175292+00
359	Biblioteca PN	https://www.tblop.com/	2026-06-21 17:40:40.176084+00
360	Prompt Midjourney	https://artificin.com/prompt-builder	2026-06-21 17:40:40.176407+00
361	Grupos discord	https://disboard.org/pt-pt	2026-06-21 17:40:40.177088+00
362	Erome PN	https://www.erome.com/	2026-06-21 17:40:40.178016+00
363	Papelaria Unicornio	https://papelariaunicornio.com.br/	2026-06-21 17:40:40.178307+00
364	Traduzir PDF	https://translate.google.com/?sl=en&tl=pt&op=docs	2026-06-21 17:40:40.178624+00
365	Love PDF	https://www.ilovepdf.com/pt	2026-06-21 17:40:40.179759+00
366	Portion	https://portions-b809c128e647.herokuapp.com/	2026-06-21 17:40:40.180036+00
367	Videohighlight	https://videohighlight.com/	2026-06-21 17:40:40.181126+00
368	Programiz	https://www.programiz.com/html/online-compiler/	2026-06-21 17:40:40.181413+00
369	Jornal o regional	https://www2.oregionaljornal.com.br/	2026-06-21 17:40:40.181664+00
370	Typingmind	https://www.typingmind.com/	2026-06-21 17:40:40.182252+00
371	Gpte	https://gpte.ai/	2026-06-21 17:40:40.183067+00
372	Loja PN vibx	https://marketplace.vibx.com.br/	2026-06-21 17:40:40.183376+00
373	Baixar Scribd	https://scribd.vpdfs.com/	2026-06-21 17:40:40.184138+00
374	Pocket	https://getpocket.com/pt/saves	2026-06-21 17:40:40.184548+00
375	Extensão Top	https://fastforward.team/	2026-06-21 17:40:40.185092+00
376	Consensus	https://consensus.app/	2026-06-21 17:40:40.186066+00
377	Typeset	https://typeset.io/	2026-06-21 17:40:40.186364+00
378	Groq	https://groq.com/	2026-06-21 17:40:40.186938+00
379	Agents	https://agents.rolemodel.ai/login	2026-06-21 17:40:40.187964+00
380	Criador de prompt	https://seu.design/	2026-06-21 17:40:40.188279+00
381	Docs estilo midjournet	https://docs.google.com/spreadsheets/u/0/d/1h6H2CqjLdZMbLjlz6EHwemfO4fkIzAfWtjRAMSa2KHE/htmlview?pli=1&utm	2026-06-21 17:40:40.188582+00
382	Prompt Helper Midjourney	https://midjourney-prompt-helper.netlify.app/	2026-06-21 17:40:40.18906+00
383	Arthub	https://arthub.ai/	2026-06-21 17:40:40.190026+00
384	Midjourney Style	https://github.com/willwulfken/MidJourney-Styles-and-Keywords-Reference/blob/main/Pages/MJ_V4/Style_Pages/Just_The_Style/Design_Styles.md	2026-06-21 17:40:40.190335+00
385	Tune Chat	https://chat.tune.app/	2026-06-21 17:40:40.191075+00
386	Biblioteca de GPTs	https://gptsdex.com/	2026-06-21 17:40:40.192016+00
387	Stable diffusion CheatSheet	https://supagruen.github.io/StableDiffusion-CheatSheet/	2026-06-21 17:40:40.192314+00
388	Mistral	https://auth.mistral.ai/ui/login	2026-06-21 17:40:40.1926+00
389	Caça style	https://glif.app/@fab1an/glifs/clska7jpn002u132h3zjl0m9v	2026-06-21 17:40:40.193199+00
390	Printwhatyoulike	https://www.printwhatyoulike.com/home/index	2026-06-21 17:40:40.194182+00
391	Glbgpt	https://glbgpt.com/mChatGpt	2026-06-21 17:40:40.194491+00
392	Oksuro	https://oksuro.com/	2026-06-21 17:40:40.195003+00
393	Gov assinatura eletronica	https://www.gov.br/governodigital/pt-br/identidade/assinatura-eletronica	2026-06-21 17:40:40.196072+00
394	Apob	https://beta.apob.ai/	2026-06-21 17:40:40.196355+00
395	You IA	https://you.com/	2026-06-21 17:40:40.196787+00
396	Stylar	https://www.stylar.ai/	2026-06-21 17:40:40.198092+00
397	Status Midjourney	https://status.midjourney.com/	2026-06-21 17:40:40.198412+00
398	Prompts Ideas	https://promptsideas.com/	2026-06-21 17:40:40.199024+00
399	Turbo Scribe AI	https://turboscribe.ai/dashboard	2026-06-21 17:40:40.199975+00
400	Downdetector	https://downdetector.com.br/	2026-06-21 17:40:40.200982+00
401	TopGG	https://top.gg/	2026-06-21 17:40:40.201272+00
402	Promptlibrary	https://promptlibrary.org/	2026-06-21 17:40:40.201694+00
403	Promeai	https://www.promeai.pro/	2026-06-21 17:40:40.203006+00
404	Reka	https://chat.reka.ai/auth/login	2026-06-21 17:40:40.203339+00
405	Lummi	https://www.lummi.ai/	2026-06-21 17:40:40.20362+00
406	Ytscribe	https://ytscribe.com/	2026-06-21 17:40:40.203887+00
407	Caractere invisível	https://fabricioventura.com/caractere?utm_source=pocket_saves	2026-06-21 17:40:40.205042+00
408	Aistudio	https://aistudio.google.com/	2026-06-21 17:40:40.205323+00
409	Mallow	https://mallow.ai/	2026-06-21 17:40:40.20572+00
410	Udio	https://www.udio.com/	2026-06-21 17:40:40.20696+00
411	Mymemo	https://app.mymemo.ai/	2026-06-21 17:40:40.207441+00
412	Midgenai	https://www.midgenai.com/	2026-06-21 17:40:40.208084+00
413	Recraft	https://www.recraft.ai/	2026-06-21 17:40:40.209076+00
414	Breakerfollow	https://www.breakerfollow.com/	2026-06-21 17:40:40.209349+00
415	Zero-gpu-s	https://huggingface.co/spaces/enzostvs/zero-gpu-spaces?utm_source=pocket_saves	2026-06-21 17:40:40.20971+00
416	Abacus AI	https://apps.abacus.ai/	2026-06-21 17:40:40.211013+00
417	Status invest	https://statusinvest.com.br/	2026-06-21 17:40:40.211299+00
418	Investidor 10	https://investidor10.com.br/	2026-06-21 17:40:40.211578+00
419	Topinvest simulados	https://simulados.topinvest.com.br/	2026-06-21 17:40:40.21186+00
420	Whimsical	https://whimsical.com	2026-06-21 17:40:40.213011+00
421	Markmap	https://markmap.js.org/repl	2026-06-21 17:40:40.213385+00
422	Phind	https://www.phind.com	2026-06-21 17:40:40.21399+00
423	Make	https://www.make.com	2026-06-21 17:40:40.214812+00
424	Zapier	https://zapier.com	2026-06-21 17:40:40.215237+00
425	Labs perplexity	https://labs.perplexity.ai/	2026-06-21 17:40:40.216091+00
426	Git Mind	https://gitmind.com/pt/	2026-06-21 17:40:40.216395+00
427	Lmsys Arena Chatbot	https://chat.lmsys.org/	2026-06-21 17:40:40.216976+00
428	Invideo AI	https://invideo.io/ai/	2026-06-21 17:40:40.217991+00
429	Mapify	https://mapify.so/	2026-06-21 17:40:40.218309+00
430	Tost	https://tost.ai/	2026-06-21 17:40:40.218628+00
431	Role model	https://chat.rolemodel.ai/c/new	2026-06-21 17:40:40.219869+00
432	Llama coder	https://llamacoder.together.ai/	2026-06-21 17:40:40.220193+00
433	Giz AI	https://app.giz.ai/	2026-06-21 17:40:40.220496+00
434	Openai TSS	https://platform.openai.com/playground/tts?utm_source=pocket_saves	2026-06-21 17:40:40.221+00
435	Style Midjourney	https://github.com/willwulfken/MidJourney-Styles-and-Keywords-Reference?utm_source=pocket_shared	2026-06-21 17:40:40.222087+00
436	Pix Verse	https://app.pixverse.ai/	2026-06-21 17:40:40.22241+00
437	Scribd download	https://scribd.vpdfs.com/	2026-06-21 17:40:40.222699+00
438	Similar sites	https://www.similarsites.com/	2026-06-21 17:40:40.223923+00
439	Lovable	https://lovable.dev/login?redirect=%2Fprojects%2F95b6cf99-6386-4ef2-ae14-ed6598a55145	2026-06-21 17:40:40.224288+00
440	Artflow	https://app.artflow.ai/	2026-06-21 17:40:40.224676+00
441	Deepseek	https://chat.deepseek.com/	2026-06-21 17:40:40.226014+00
442	Mistral	https://auth.mistral.ai/	2026-06-21 17:40:40.226343+00
443	Liquid AI	https://playground.liquid.ai/login	2026-06-21 17:40:40.226647+00
444	Inner AI	https://platform.innerai.com/	2026-06-21 17:40:40.226912+00
445	Dzine	https://www.dzine.ai/	2026-06-21 17:40:40.227992+00
446	Fliki	https://fliki.ai/	2026-06-21 17:40:40.228314+00
447	Piclumen	https://www.piclumen.com/	2026-06-21 17:40:40.22861+00
448	Meta AI	https://www.meta.ai/	2026-06-21 17:40:40.229981+00
449	Nvidia nemotron	https://build.nvidia.com/nvidia/llama-3_1-nemotron-70b-instruct?utm_source=pocket_saves	2026-06-21 17:40:40.230326+00
450	Superporn	https://www.superporn.com/pornstars?	2026-06-21 17:40:40.230639+00
451	Tubepornstars	https://www.tubepornstars.com/pt-br/	2026-06-21 17:40:40.230916+00
452	Pornstars	https://pornstars.tube/	2026-06-21 17:40:40.231976+00
453	Hailuoai	https://hailuoai.video/	2026-06-21 17:40:40.2323+00
454	Adapta	https://adapta.org/	2026-06-21 17:40:40.232604+00
455	Assoass	https://www.assoass.com/pt-br/category/anal	2026-06-21 17:40:40.234005+00
456	Toppornsites	https://toppornsites.com/	2026-06-21 17:40:40.234334+00
457	Findtubes	https://www.findtubes.com/pt-br/category/anal	2026-06-21 17:40:40.234651+00
458	Adobe - Comprimir PDF	https://www.adobe.com/br/acrobat/online/compress-pdf.html	2026-06-21 17:40:40.234987+00
459	Promptperfect	https://promptperfect.jina.ai/	2026-06-21 17:40:40.236108+00
460	Hotshot	https://hotshot.co/	2026-06-21 17:40:40.236434+00
461	Profundo	https://www.profundo.app/	2026-06-21 17:40:40.236728+00
462	Gofretes	https://gofretes.com.br/	2026-06-21 17:40:40.237991+00
463	Ai music	https://aimusic.so/	2026-06-21 17:40:40.238305+00
464	Freeflo	https://freeflo.ai/	2026-06-21 17:40:40.2386+00
465	Prompter	https://prompter.fofr.a	2026-06-21 17:40:40.238917+00
466	Felo AI	https://felo.ai/search	2026-06-21 17:40:40.240102+00
467	Basedlabs	https://www.basedlabs.ai/generate	2026-06-21 17:40:40.241071+00
468	Together AI	https://api.together.ai/signin	2026-06-21 17:40:40.241374+00
469	Color IO	https://app.color.io/	2026-06-21 17:40:40.241886+00
470	LM Arena	https://lmarena.ai/	2026-06-21 17:40:40.243023+00
471	Notebook LM	https://notebooklm.google.com/	2026-06-21 17:40:40.243346+00
472	Name that pornstar	https://namethatpornstar.com/	2026-06-21 17:40:40.243675+00
473	Fap folder	https://fapfolder.club/	2026-06-21 17:40:40.244119+00
474	Telegra	https://telegra.ph/	2026-06-21 17:40:40.244988+00
475	EGP TCE	https://egp.tce.pr.gov.br/	2026-06-21 17:40:40.246078+00
476	Instituto Federal do Rio Grande do Sul - Cursos	https://moodle.ifrs.edu.br/	2026-06-21 17:40:40.246975+00
477	Ttsopenai	https://ttsopenai.com/	2026-06-21 17:40:40.247282+00
478	TCE ENTIDADE	https://servicos.tce.pr.gov.br/tcepr/tribunal/relacon/Entidade	2026-06-21 17:40:40.247546+00
479	SENADO Cursos	https://saberes.senado.leg.br/	2026-06-21 17:40:40.248979+00
480	Websim	https://websim.ai/	2026-06-21 17:40:40.250081+00
481	Pornpics	https://www.pornpics.com/	2026-06-21 17:40:40.250936+00
482	Findtubes	https://www.findtubes.com/pt-br/	2026-06-21 17:40:40.251234+00
483	Vidu	https://www.vidu.studio/	2026-06-21 17:40:40.251504+00
484	Lumalabs	https://lumalabs.ai/	2026-06-21 17:40:40.252047+00
485	arxiv	https://arxiv.org/	2026-06-21 17:40:40.25299+00
486	Pomodoro timer	https://app.pomodorotimer.online/pt	2026-06-21 17:40:40.253327+00
487	V0	https://v0.dev/	2026-06-21 17:40:40.254012+00
488	Tool finder	https://toolfinder.co/	2026-06-21 17:40:40.2544+00
489	Deep swapper	https://www.deepswapper.com/	2026-06-21 17:40:40.255171+00
490	Face swapper	https://faceswapper.ai	2026-06-21 17:40:40.255543+00
491	Teradownloader	https://teradownloader.com	2026-06-21 17:40:40.256131+00
492	Hailuoai	https://hailuoai.com/	2026-06-21 17:40:40.257182+00
493	Markdown to pdf	https://www.markdowntopdf.com/	2026-06-21 17:40:40.257455+00
494	Preciso imprimir	https://precisoimprimir.com.br/	2026-06-21 17:40:40.257783+00
495	Raidrive	https://www.raidrive.com/	2026-06-21 17:40:40.259071+00
496	Chatplayground	https://app.chatplayground.ai/	2026-06-21 17:40:40.259994+00
497	Omnigpt	https://app.omnigpt.co/	2026-06-21 17:40:40.26027+00
498	Recraft	https://www.recraft.ai/	2026-06-21 17:40:40.260577+00
499	Promptlibrary	https://promptlibrary.org/	2026-06-21 17:40:40.261496+00
500	Vizard	https://vizard.ai/	2026-06-21 17:40:40.262962+00
501	Download Terabox	https://terabox.hnn.workers.dev/	2026-06-21 17:40:40.263409+00
502	DNS Adguard	https://auth.adguard.com/login.html	2026-06-21 17:40:40.26423+00
503	Poppop AI	https://poppop.ai/	2026-06-21 17:40:40.265012+00
504	Komo AI	https://komo.ai/	2026-06-21 17:40:40.265346+00
505	Promptsideas	https://promptsideas.com/	2026-06-21 17:40:40.265995+00
506	Mymemo	https://app.mymemo.ai/	2026-06-21 17:40:40.266995+00
507	Reka AI	https://chat.reka.ai/chat	2026-06-21 17:40:40.26734+00
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
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: hubmaster
--

COPY public.subscriptions (id, name, price, currency, billing_cycle, renewal_date, category, color, icon, is_active, notes, created_at, updated_at) FROM stdin;
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
516358a0-a386-4c69-bb53-83609a79e8e0	aajunior43@gmail.com	$2b$12$AjI2/Bcbv27vJGOYxAVdPOfxnBaHq4ohNzM0YlHa6lfEkMdBzUJx6	Aleksandro Alves da Rocha Junior	\N	t	2025-06-15 02:36:40.791563+00	2026-06-21 17:17:58.587296+00
\.


--
-- Name: favorites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hubmaster
--

SELECT pg_catalog.setval('public.favorites_id_seq', 507, true);


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
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


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
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: hubmaster
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


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
-- Name: idx_favorites_name; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_favorites_name ON public.favorites USING btree (name);


--
-- Name: idx_favorites_url; Type: INDEX; Schema: public; Owner: hubmaster
--

CREATE INDEX idx_favorites_url ON public.favorites USING btree (url);


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

\unrestrict miT0lFBFGo93KDPE2fGT1DySkT8AKQuBADTL8LW5Hgjyp9sZ1dp64UAgo2ngYlk

