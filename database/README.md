# Hub Master - Banco de Dados Unificado

## Visão Geral

Todos os bancos de dados de todos os serviços ficam nesta única pasta, usando um único PostgreSQL (`hub-postgres`).

## Estrutura

```
database/
├── init/                           # Scripts SQL executados na inicialização
│   ├── 01_schema.sql              # Schema do Link Stash (users, links, tags, etc.)
│   ├── 02_migrate_data.sql        # Dados migrados do Supabase (128 links)
│   └── 03_other_services.sql      # Schema + dados de subscriptions e favorites
├── backups/                        # Backups
│   ├── hub_master_*.sql           # Backups completos do PostgreSQL (automáticos)
│   ├── links.json                 # Backup JSON dos links
│   ├── tags.json                  # Backup JSON das tags
│   ├── folders.json               # Backup JSON das pastas
│   ├── favorites.txt              # Backup original dos favoritos (507 entradas)
│   └── subscriptions.db           # Backup original do SQLite (vazio)
├── backup.sh                       # Script de backup unificado
├── migrate.py                      # Script de migração (Supabase -> PostgreSQL)
└── README.md                       # Este arquivo
```

## Serviços e suas tabelas

| Serviço | Tabelas | Origem dos dados | Registros |
|---------|---------|------------------|-----------|
| Link Stash | users, profiles, links, tags, folders, link_tags, categories, api_keys, mcp_tokens | Supabase (migrado) | 128 links, 14 tags, 3 pastas |
| Subscription API | subscriptions | SQLite (migrado) | 0 (vazio) |
| Favoritos | favorites | Arquivo txt (migrado) | 507 entradas |

## Configuração

### Variáveis de ambiente (.env)

```
DB_NAME=hub_master
DB_USER=hubmaster
DB_PASS=hubmaster_secret_2026
```

### Container Docker

O PostgreSQL roda como container `hub-postgres`:

- **Imagem:** postgres:16-alpine
- **Porta:** 5432 (interno, não exposta)
- **Volume:** postgres-data (dados persistentes)
- **Init scripts:** `./database/init/` montados em `/docker-entrypoint-initdb.d`
- **Healthcheck:** pg_isready a cada 10s

## Comandos úteis

### Acessar o banco
```bash
docker exec -it hub-postgres psql -U hubmaster -d hub_master
```

### Backup completo
```bash
./database/backup.sh
```

### Restaurar backup
```bash
docker exec -i hub-postgres psql -U hubmaster -d hub_master < database/backups/hub_master_YYYYMMDD_HHMMSS.sql
```

### Ver todas as tabelas
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "\dt"
```

### Ver contagem de registros por tabela
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "
SELECT relname as tabela, n_live_tup as registros
FROM pg_stat_user_tables
ORDER BY relname;
"
```

### Ver links do Link Stash
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "SELECT title, url FROM links ORDER BY created_at DESC LIMIT 10;"
```

### Ver favoritos
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "SELECT name, url FROM favorites LIMIT 10;"
```

### Ver subscriptions
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "SELECT * FROM subscriptions;"
```

## Origem dos dados

| Banco | Origem | Data da migração |
|-------|--------|------------------|
| Link Stash | Supabase: `qywjbutxdklmhihscahy.supabase.co` | 2026-06-21 |
| Subscriptions | SQLite: `/data/subscriptions.db` (container) | 2026-06-21 |
| Favorites | Arquivo txt: `/var/www/html/data/favorites.txt` (container) | 2026-06-21 |
