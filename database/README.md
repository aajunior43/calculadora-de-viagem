# Hub Master - Banco de Dados Local

## Estrutura

```
database/
├── init/
│   ├── 01_schema.sql         # Schema completo (tabelas, índices, triggers)
│   └── 02_migrate_data.sql   # Dados migrados do Supabase
├── backups/
│   ├── links.json            # Backup JSON dos links (Supabase)
│   ├── tags.json             # Backup JSON das tags
│   ├── folders.json          # Backup JSON das pastas
│   ├── link_tags.json        # Backup JSON das relações
│   ├── profiles.json         # Backup JSON dos perfis
│   ├── mcp_tokens.json       # Backup JSON dos tokens MCP
│   ├── categories.json       # Backup JSON das categorias (vazio)
│   ├── api_keys.json         # Backup JSON das API keys (vazio)
│   └── hub_master_*.sql      # Backups do PostgreSQL (automáticos)
├── migrate.py                # Script Python de migração (alternativo)
├── backup.sh                 # Script de backup do PostgreSQL
└── README.md                 # Este arquivo
```

## Configuração

### Variáveis de ambiente (.env)

```
DB_NAME=hub_master
DB_USER=hubmaster
DB_PASS=hubmaster_secret_2026
```

### Container Docker

O PostgreSQL roda como container `hub-postgres` na rede `traefik-public`.

- **Imagem:** postgres:16-alpine
- **Porta:** 5432 (expose interno)
- **Volume:** postgres-data (dados persistentes)
- **Healthcheck:** pg_isready a cada 10s

## Tabelas

| Tabela | Descrição | Registros migrados |
|--------|-----------|-------------------|
| users | Usuários (substitui auth.users do Supabase) | 1 |
| profiles | Perfis dos usuários | 1 |
| categories | Categorias de links | 0 |
| tags | Tags de links | 14 |
| folders | Pastas hierárquicas | 3 |
| links | Links salvos | 128 |
| link_tags | Relacionamento links↔tags | 9 |
| api_keys | Chaves de API | 0 |
| mcp_tokens | Tokens MCP | 1 |

## Comandos úteis

### Acessar o banco
```bash
docker exec -it hub-postgres psql -U hubmaster -d hub_master
```

### Backup manual
```bash
./database/backup.sh
```

### Restaurar backup
```bash
docker exec -i hub-postgres psql -U hubmaster -d hub_master < database/backups/hub_master_YYYYMMDD_HHMMSS.sql
```

### Ver tabelas
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "\dt"
```

### Ver links
```bash
docker exec hub-postgres psql -U hubmaster -d hub_master -c "SELECT title, url FROM links ORDER BY created_at DESC LIMIT 10;"
```

## Origem dos dados

Migrado do Supabase: `qywjbutxdklmhihscahy.supabase.co`
- Usuário: aajunior43@gmail.com
- User ID: 516358a0-a386-4c69-bb53-83609a79e8e0
- Data da migração: 2026-06-21
