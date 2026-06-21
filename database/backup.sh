#!/bin/bash
# ============================================================
# Hub Master - Backup Unificado do PostgreSQL
# Backup de TODOS os bancos (link-stash, subscriptions, favorites)
# Execute: ./backup.sh
# ============================================================

BACKUP_DIR="/root/hub-master-scaffold/database/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SQL_FILE="${BACKUP_DIR}/hub_master_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo ">>> Criando backup completo do PostgreSQL..."
docker exec hub-postgres pg_dump -U hubmaster -d hub_master > "$SQL_FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$SQL_FILE" | cut -f1)
    echo ">>> Backup criado: $SQL_FILE ($SIZE)"

    # Exportar dados em JSON para cada tabela
    echo ">>> Exportando dados em JSON..."
    for table in links tags folders link_tags profiles users mcp_tokens categories api_keys subscriptions favorites; do
        docker exec hub-postgres psql -U hubmaster -d hub_master -t -c "SELECT row_to_json(t) FROM (SELECT * FROM ${table}) t;" > "${BACKUP_DIR}/${table}.json" 2>/dev/null
        count=$(docker exec hub-postgres psql -U hubmaster -d hub_master -t -c "SELECT COUNT(*) FROM ${table};" 2>/dev/null | xargs)
        echo "    ${table}: ${count} registros"
    done

    # Manter apenas os 10 backups SQL mais recentes
    cd "$BACKUP_DIR"
    ls -t hub_master_*.sql 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
    echo ">>> Backups antigos removidos (mantendo os 10 mais recentes)"
    echo ">>> Backup concluído!"
else
    echo ">>> ERRO ao criar backup!"
    exit 1
fi
