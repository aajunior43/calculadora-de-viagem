"""
Link Stash API - Backend local para o Link Stash
Substitui o Supabase com PostgreSQL local + JWT auth
"""
import os
import json
import time
import hashlib
import secrets
from datetime import datetime, timezone
from typing import Optional, List, Any, Dict

import jwt
import bcrypt
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, HTTPException, Depends, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ============================================================
# Configuração
# ============================================================
DB_HOST = os.environ.get("DB_HOST", "hub-postgres")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "hub_master")
DB_USER = os.environ.get("DB_USER", "hubmaster")
DB_PASS = os.environ.get("DB_PASS", "hubmaster_secret_2026")
JWT_SECRET = os.environ.get("JWT_SECRET", "hub_master_jwt_secret_2026_aajunior")
JWT_ALGO = "HS256"
JWT_EXP_HOURS = 720  # 30 dias

app = FastAPI(title="Link Stash API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# Database
# ============================================================
def get_db():
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS,
    )
    return conn

# ============================================================
# Auth helpers
# ============================================================
def create_token(user_id: str, email: str, full_name: str) -> str:
    payload = {
        "sub": user_id,
        "email": email,
        "full_name": full_name,
        "exp": int(time.time()) + JWT_EXP_HOURS * 3600,
        "iat": int(time.time()),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)

def verify_token(authorization: Optional[str] = Header(None)) -> Dict:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Não autenticado")
    token = authorization.split(" ", 1)[1]
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGO])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")

def get_user_id(auth: Dict = Depends(verify_token)) -> str:
    return auth["sub"]

def get_user(auth: Dict = Depends(verify_token)) -> Dict:
    return auth

# ============================================================
# Pydantic models
# ============================================================
class LoginRequest(BaseModel):
    email: str
    password: str

class SignupRequest(BaseModel):
    email: str
    password: str
    full_name: str = ""

class LinkCreate(BaseModel):
    title: str
    url: str
    description: Optional[str] = None
    category_id: Optional[str] = None
    folder_id: Optional[str] = None
    tag_ids: List[str] = []
    is_favorite: bool = False
    is_pinned: bool = False

class LinkUpdate(BaseModel):
    title: Optional[str] = None
    url: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[str] = None
    folder_id: Optional[str] = None
    tag_ids: Optional[List[str]] = None
    is_favorite: Optional[bool] = None
    is_pinned: Optional[bool] = None
    is_archived: Optional[bool] = None
    deleted_at: Optional[str] = None

class LinkBulkCreate(BaseModel):
    links: List[Dict[str, Any]]

class LinkBulkDelete(BaseModel):
    ids: List[str]

class CategoryCreate(BaseModel):
    name: str
    color: str = "blue"

class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None

class TagCreate(BaseModel):
    name: str
    color: str = "#3B82F6"

class FolderCreate(BaseModel):
    name: str
    color: str = "blue"
    icon: str = "folder"
    parent_id: Optional[str] = None

class McpTokenCreate(BaseModel):
    name: str

# ============================================================
# Auth endpoints
# ============================================================
@app.post("/auth/login")
def login(req: LoginRequest):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, email, password_hash, full_name FROM users WHERE email = %s", (req.email,))
            user = cur.fetchone()
            if not user:
                raise HTTPException(status_code=401, detail="Email ou senha incorretos")
            if not bcrypt.checkpw(req.password.encode(), user["password_hash"].encode()):
                raise HTTPException(status_code=401, detail="Email ou senha incorretos")
            token = create_token(user["id"], user["email"], user["full_name"] or "")
            return {
                "access_token": token,
                "token_type": "bearer",
                "user": {"id": user["id"], "email": user["email"], "full_name": user["full_name"]},
            }
    finally:
        conn.close()

@app.post("/auth/signup")
def signup(req: SignupRequest):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT 1 FROM users WHERE email = %s", (req.email,))
            if cur.fetchone():
                raise HTTPException(status_code=400, detail="Email já cadastrado")
            hashed = bcrypt.hashpw(req.password.encode(), bcrypt.gensalt()).decode()
            cur.execute(
                "INSERT INTO users (email, password_hash, full_name) VALUES (%s, %s, %s) RETURNING id, email, full_name",
                (req.email, hashed, req.full_name),
            )
            user = cur.fetchone()
            conn.commit()
            token = create_token(user["id"], user["email"], user["full_name"] or "")
            return {
                "access_token": token,
                "token_type": "bearer",
                "user": {"id": user["id"], "email": user["email"], "full_name": user["full_name"]},
            }
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.get("/auth/me")
def get_me(auth: Dict = Depends(verify_token)):
    return {"user": {"id": auth["sub"], "email": auth.get("email"), "full_name": auth.get("full_name")}}

# ============================================================
# Links endpoints
# ============================================================
@app.get("/links")
def list_links(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT l.*, COALESCE(
                    (SELECT json_agg(lt.tag_id) FROM link_tags lt WHERE lt.link_id = l.id),
                    '[]'::json
                ) as tag_ids
                FROM links l
                WHERE l.user_id = %s AND l.deleted_at IS NULL
                ORDER BY l.created_at DESC
            """, (user_id,))
            rows = cur.fetchall()
            for r in rows:
                r["tag_ids"] = r["tag_ids"] if r["tag_ids"] else []
            return rows
    finally:
        conn.close()

@app.post("/links")
def create_link(req: LinkCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO links (user_id, title, url, description, category_id, folder_id, is_favorite, is_pinned)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING *
            """, (user_id, req.title, req.url, req.description, req.category_id, req.folder_id, req.is_favorite, req.is_pinned))
            link = cur.fetchone()
            if req.tag_ids:
                for tid in req.tag_ids:
                    cur.execute("INSERT INTO link_tags (link_id, tag_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (link["id"], tid))
            conn.commit()
            link["tag_ids"] = req.tag_ids
            return link
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.put("/links/{link_id}")
def update_link(link_id: str, req: LinkUpdate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT 1 FROM links WHERE id = %s AND user_id = %s", (link_id, user_id))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Link não encontrado")

            updates = {}
            for field in ["title", "url", "description", "category_id", "folder_id", "is_favorite", "is_pinned", "is_archived", "deleted_at"]:
                val = getattr(req, field)
                if val is not None:
                    updates[field] = val

            if updates:
                set_clause = ", ".join([f"{k} = %s" for k in updates])
                values = list(updates.values()) + [datetime.now(timezone.utc).isoformat(), link_id]
                cur.execute(f"UPDATE links SET {set_clause}, updated_at = %s WHERE id = %s RETURNING *", values)
                link = cur.fetchone()
            else:
                cur.execute("SELECT * FROM links WHERE id = %s", (link_id,))
                link = cur.fetchone()

            if req.tag_ids is not None:
                cur.execute("DELETE FROM link_tags WHERE link_id = %s", (link_id,))
                for tid in req.tag_ids:
                    cur.execute("INSERT INTO link_tags (link_id, tag_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (link_id, tid))
                link["tag_ids"] = req.tag_ids
            else:
                cur.execute("SELECT json_agg(tag_id) as tags FROM link_tags WHERE link_id = %s", (link_id,))
                t = cur.fetchone()
                link["tag_ids"] = t["tags"] or []

            conn.commit()
            return link
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.delete("/links/{link_id}")
def delete_link(link_id: str, permanent: bool = Query(False), user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM links WHERE id = %s AND user_id = %s", (link_id, user_id))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Link não encontrado")
            if permanent:
                cur.execute("DELETE FROM links WHERE id = %s", (link_id,))
            else:
                cur.execute("UPDATE links SET deleted_at = %s WHERE id = %s", (datetime.now(timezone.utc).isoformat(), link_id))
            conn.commit()
            return {"success": True}
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.post("/links/bulk")
def bulk_create_links(req: LinkBulkCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            results = []
            for l in req.links:
                cur.execute("""
                    INSERT INTO links (user_id, title, url, description, category_id, folder_id)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING *
                """, (user_id, l.get("title"), l.get("url"), l.get("description"),
                      l.get("category_id"), l.get("folder_id")))
                results.append(cur.fetchone())
            conn.commit()
            return results
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.post("/links/bulk-delete")
def bulk_delete_links(req: LinkBulkDelete, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            if not req.ids:
                return {"success": True, "deleted": 0}
            placeholders = ",".join(["%s"] * len(req.ids))
            cur.execute(f"DELETE FROM links WHERE id IN ({placeholders}) AND user_id = %s", req.ids + [user_id])
            deleted = cur.rowcount
            conn.commit()
            return {"success": True, "deleted": deleted}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.get("/links/trash")
def list_trash(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT * FROM links WHERE user_id = %s AND deleted_at IS NOT NULL
                ORDER BY deleted_at DESC
            """, (user_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/links/{link_id}/restore")
def restore_link(link_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("UPDATE links SET deleted_at = NULL WHERE id = %s AND user_id = %s RETURNING *", (link_id, user_id))
            link = cur.fetchone()
            if not link:
                raise HTTPException(status_code=404, detail="Link não encontrado")
            conn.commit()
            return link
    except HTTPException:
        raise
    finally:
        conn.close()

@app.post("/links/{link_id}/favorite")
def toggle_favorite(link_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT is_favorite FROM links WHERE id = %s AND user_id = %s", (link_id, user_id))
            row = cur.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Link não encontrado")
            new_val = not row["is_favorite"]
            cur.execute("UPDATE links SET is_favorite = %s WHERE id = %s RETURNING *", (new_val, link_id))
            conn.commit()
            return cur.fetchone()
    except HTTPException:
        raise
    finally:
        conn.close()

# ============================================================
# Categories endpoints
# ============================================================
@app.get("/categories")
def list_categories(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM categories WHERE user_id = %s ORDER BY created_at ASC", (user_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/categories")
def create_category(req: CategoryCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("INSERT INTO categories (user_id, name, color) VALUES (%s, %s, %s) RETURNING *", (user_id, req.name, req.color))
            conn.commit()
            return cur.fetchone()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.put("/categories/{cat_id}")
def update_category(cat_id: str, req: CategoryUpdate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            updates = {}
            if req.name is not None:
                updates["name"] = req.name
            if req.color is not None:
                updates["color"] = req.color
            if not updates:
                raise HTTPException(status_code=400, detail="Nada para atualizar")
            set_clause = ", ".join([f"{k} = %s" for k in updates])
            cur.execute(f"UPDATE categories SET {set_clause} WHERE id = %s AND user_id = %s RETURNING *",
                        list(updates.values()) + [cat_id, user_id])
            row = cur.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Categoria não encontrada")
            conn.commit()
            return row
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.delete("/categories/{cat_id}")
def delete_category(cat_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM categories WHERE id = %s AND user_id = %s", (cat_id, user_id))
            conn.commit()
            return {"success": True}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# ============================================================
# Tags endpoints
# ============================================================
@app.get("/tags")
def list_tags(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM tags WHERE user_id = %s ORDER BY created_at ASC", (user_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/tags")
def create_tag(req: TagCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("INSERT INTO tags (user_id, name, color) VALUES (%s, %s, %s) RETURNING *", (user_id, req.name, req.color))
            conn.commit()
            return cur.fetchone()
    except psycopg2.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=409, detail="Tag já existe")
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.delete("/tags/{tag_id}")
def delete_tag(tag_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM tags WHERE id = %s AND user_id = %s", (tag_id, user_id))
            conn.commit()
            return {"success": True}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# ============================================================
# Folders endpoints
# ============================================================
@app.get("/folders")
def list_folders(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM folders WHERE user_id = %s ORDER BY created_at ASC", (user_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/folders")
def create_folder(req: FolderCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO folders (user_id, name, color, icon, parent_id)
                VALUES (%s, %s, %s, %s, %s) RETURNING *
            """, (user_id, req.name, req.color, req.icon, req.parent_id))
            conn.commit()
            return cur.fetchone()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.delete("/folders/{folder_id}")
def delete_folder(folder_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM folders WHERE id = %s AND user_id = %s", (folder_id, user_id))
            conn.commit()
            return {"success": True}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# ============================================================
# MCP Tokens endpoints
# ============================================================
@app.get("/mcp-tokens")
def list_mcp_tokens(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, token_prefix, created_at, last_used_at
                FROM mcp_tokens WHERE user_id = %s ORDER BY created_at DESC
            """, (user_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/mcp-tokens")
def create_mcp_token(req: McpTokenCreate, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            raw_token = "ml_" + secrets.token_hex(16)
            token_prefix = raw_token[:10]
            token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
            cur.execute("""
                INSERT INTO mcp_tokens (user_id, name, token_prefix, token_hash)
                VALUES (%s, %s, %s, %s) RETURNING id, name, token_prefix, created_at
            """, (user_id, req.name.strip(), token_prefix, token_hash))
            row = cur.fetchone()
            conn.commit()
            row["token"] = raw_token
            return row
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.delete("/mcp-tokens/{token_id}")
def delete_mcp_token(token_id: str, user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM mcp_tokens WHERE id = %s AND user_id = %s", (token_id, user_id))
            conn.commit()
            return {"success": True}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# ============================================================
# Profile endpoints
# ============================================================
@app.get("/profile")
def get_profile(user_id: str = Depends(get_user_id)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM profiles WHERE id = %s", (user_id,))
            return cur.fetchone()
    finally:
        conn.close()

# ============================================================
# Health
# ============================================================
@app.get("/health")
def health():
    return {"status": "ok", "service": "link-stash-api"}

# ============================================================
# Init: garantir que o usuário tenha hash de senha válido
# ============================================================
@app.on_event("startup")
def ensure_password_hash():
    """Atualiza o password_hash do usuário migrado se ainda for placeholder."""
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT id FROM users WHERE password_hash LIKE '$2a$10$placeholder%'")
            row = cur.fetchone()
            if row:
                hashed = bcrypt.hashpw("Jr19991020.".encode(), bcrypt.gensalt()).decode()
                cur.execute("UPDATE users SET password_hash = %s WHERE id = %s", (hashed, row[0]))
                conn.commit()
                print(f"[startup] Password hash atualizado para user {row[0]}")
    except Exception as e:
        print(f"[startup] Erro ao atualizar hash: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8770)
