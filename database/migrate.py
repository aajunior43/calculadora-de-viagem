#!/usr/bin/env python3
"""
Migração de dados do Supabase para PostgreSQL local.
Lê os arquivos JSON exportados e insere no banco local.
"""

import json
import os
import sys
import psycopg2
from psycopg2.extras import execute_batch

BACKUP_DIR = os.path.join(os.path.dirname(__file__), "backups")
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "hub_master")
DB_USER = os.environ.get("DB_USER", "hubmaster")
DB_PASS = os.environ.get("DB_PASS", "hubmaster_secret_2026")

# Dados do usuário extraídos do Supabase
USER_ID = "516358a0-a386-4c69-bb53-83609a79e8e0"
USER_EMAIL = "aajunior43@gmail.com"
USER_FULL_NAME = "Aleksandro Alves da Rocha Junior"
USER_PASSWORD_HASH = "$2a$10$placeholder_hash_replace_with_real_one"


def load_json(name):
    path = os.path.join(BACKUP_DIR, f"{name}.json")
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def connect():
    print(f"Conectando ao PostgreSQL: {DB_HOST}:{DB_PORT}/{DB_NAME}")
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS,
    )
    conn.autocommit = False
    return conn


def migrate_user(conn):
    """Cria o usuário local com o mesmo ID do Supabase."""
    profiles = load_json("profiles")
    profile = profiles[0] if profiles else {}

    with conn.cursor() as cur:
        cur.execute("SELECT 1 FROM users WHERE id = %s", (USER_ID,))
        if cur.fetchone():
            print(f"  [skip] Usuário já existe: {USER_EMAIL}")
            return

        cur.execute("""
            INSERT INTO users (id, email, password_hash, full_name, avatar_url, email_verified, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, true, %s, %s)
        """, (
            USER_ID,
            USER_EMAIL,
            USER_PASSWORD_HASH,
            profile.get("full_name", USER_FULL_NAME),
            profile.get("avatar_url"),
            profile.get("created_at"),
            profile.get("updated_at"),
        ))
        print(f"  [ok] Usuário criado: {USER_EMAIL}")

        # O trigger handle_new_user cria o profile automaticamente,
        # mas garantimos os dados completos
        cur.execute("""
            INSERT INTO profiles (id, email, full_name, avatar_url, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
                email = EXCLUDED.email,
                full_name = EXCLUDED.full_name,
                avatar_url = EXCLUDED.avatar_url
        """, (
            USER_ID,
            profile.get("email", USER_EMAIL),
            profile.get("full_name", USER_FULL_NAME),
            profile.get("avatar_url"),
            profile.get("created_at"),
            profile.get("updated_at"),
        ))
        print(f"  [ok] Profile criado/atualizado")


def migrate_categories(conn):
    categories = load_json("categories")
    if not categories:
        print("  [skip] Nenhuma categoria para migrar")
        return
    rows = [(c["id"], c["user_id"], c["name"], c["color"], c["created_at"]) for c in categories]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO categories (id, user_id, name, color, created_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} categorias migradas")


def migrate_tags(conn):
    tags = load_json("tags")
    if not tags:
        print("  [skip] Nenhuma tag para migrar")
        return
    rows = [(t["id"], t["user_id"], t["name"], t["color"], t["created_at"]) for t in tags]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO tags (id, user_id, name, color, created_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} tags migradas")


def migrate_folders(conn):
    folders = load_json("folders")
    if not folders:
        print("  [skip] Nenhuma pasta para migrar")
        return
    # Ordenar: pastas sem parent_id primeiro (para evitar FK violation)
    folders_sorted = sorted(folders, key=lambda f: (f.get("parent_id") is not None, f.get("parent_id") or ""))
    rows = [
        (f["id"], f["user_id"], f["name"], f.get("color", "blue"),
         f.get("icon", "folder"), f.get("parent_id"), f["created_at"], f["updated_at"])
        for f in folders_sorted
    ]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO folders (id, user_id, name, color, icon, parent_id, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} pastas migradas")


def migrate_links(conn):
    links = load_json("links")
    if not links:
        print("  [skip] Nenhum link para migrar")
        return
    rows = [
        (l["id"], l["user_id"], l["title"], l["url"], l.get("category_id"),
         l.get("is_favorite", False), l["created_at"], l["updated_at"],
         l.get("folder_id"), l.get("description"), l.get("is_archived", False),
         l.get("is_pinned", False), l.get("deleted_at"))
        for l in links
    ]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO links (id, user_id, title, url, category_id, is_favorite,
                             created_at, updated_at, folder_id, description,
                             is_archived, is_pinned, deleted_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} links migrados")


def migrate_link_tags(conn):
    link_tags = load_json("link_tags")
    if not link_tags:
        print("  [skip] Nenhuma relação link_tag para migrar")
        return
    rows = [(lt["id"], lt["link_id"], lt["tag_id"]) for lt in link_tags]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO link_tags (id, link_id, tag_id)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} relações link_tag migradas")


def migrate_api_keys(conn):
    api_keys = load_json("api_keys")
    if not api_keys:
        print("  [skip] Nenhuma API key para migrar")
        return
    rows = [
        (ak["id"], ak["user_id"], ak["provider"], ak["api_key"],
         ak["created_at"], ak["updated_at"])
        for ak in api_keys
    ]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO api_keys (id, user_id, provider, api_key, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} API keys migradas")


def migrate_mcp_tokens(conn):
    tokens = load_json("mcp_tokens")
    if not tokens:
        print("  [skip] Nenhum MCP token para migrar")
        return
    rows = [
        (t["id"], t["user_id"], t["name"], t["token_prefix"], t["token_hash"],
         t.get("last_used_at"), t["created_at"], t["updated_at"])
        for t in tokens
    ]
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO mcp_tokens (id, user_id, name, token_prefix, token_hash,
                                   last_used_at, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, rows)
    print(f"  [ok] {len(rows)} MCP tokens migrados")


def verify(conn):
    tables = ["users", "profiles", "categories", "tags", "folders", "links", "link_tags", "api_keys", "mcp_tokens"]
    print("\n" + "=" * 50)
    print("VERIFICAÇÃO DE DADOS MIGRADOS")
    print("=" * 50)
    with conn.cursor() as cur:
        for table in tables:
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            count = cur.fetchone()[0]
            status = "OK" if count > 0 or table in ("categories", "api_keys") else "VAZIO"
            print(f"  {table:15s} -> {count:5d} registros  [{status}]")
    print("=" * 50)


def main():
    try:
        conn = connect()
    except Exception as e:
        print(f"ERRO ao conectar: {e}")
        sys.exit(1)

    try:
        print("\n>>> Migrando usuário e profile...")
        migrate_user(conn)
        conn.commit()

        print("\n>>> Migrando categorias...")
        migrate_categories(conn)
        conn.commit()

        print("\n>>> Migrando tags...")
        migrate_tags(conn)
        conn.commit()

        print("\n>>> Migrando pastas...")
        migrate_folders(conn)
        conn.commit()

        print("\n>>> Migrando links...")
        migrate_links(conn)
        conn.commit()

        print("\n>>> Migrando link_tags...")
        migrate_link_tags(conn)
        conn.commit()

        print("\n>>> Migrando api_keys...")
        migrate_api_keys(conn)
        conn.commit()

        print("\n>>> Migrando mcp_tokens...")
        migrate_mcp_tokens(conn)
        conn.commit()

        verify(conn)
        print("\nMigração concluída com sucesso!")

    except Exception as e:
        conn.rollback()
        print(f"\nERRO durante migração: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
