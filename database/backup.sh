#!/bin/bash
# ============================================================
# Hub Master - Backup do PostgreSQL
# Execute: ./backup.sh
# ============================================================

BACKUP_DIR="/root/hub-master-scaffold/database/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILE="${BACKUP_DIR}/hub_master_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo ">>> Criando backup do PostgreSQL..."
docker exec hub-postgres pg_dump -U hubmaster -d hub_master > "$FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$FILE" | cut -f1)
    echo ">>> Backup criado: $FILE ($SIZE)"
    
    # Manter apenas os últimos 10 backups
    cd "$BACKUP_DIR"
    ls -t hub_master_*.sql 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
    echo ">>> Backups antigos removidos (mantendo os 10 mais recentes)"
else
    echo ">>> ERRO ao criar backup!"
    exit 1
fi
