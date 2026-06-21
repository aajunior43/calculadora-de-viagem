import json
import os
import uuid
from datetime import datetime
from typing import Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import uvicorn

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DB_HOST = os.environ.get("DB_HOST", "hub-postgres")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "hub_master")
DB_USER = os.environ.get("DB_USER", "hubmaster")
DB_PASS = os.environ.get("DB_PASS", "hubmaster_secret_2026")

def get_db():
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS,
    )
    return conn

def init_db():
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS subscriptions (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                price REAL NOT NULL,
                currency TEXT DEFAULT 'BRL',
                billing_cycle TEXT DEFAULT 'monthly',
                renewal_date TEXT NOT NULL,
                category TEXT DEFAULT 'other',
                color TEXT DEFAULT '#6366f1',
                icon TEXT DEFAULT '',
                is_active BOOLEAN DEFAULT true,
                notes TEXT DEFAULT '',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
    conn.close()

init_db()

class SubscriptionCreate(BaseModel):
    name: str
    price: float
    currency: str = "BRL"
    billing_cycle: str = "monthly"
    renewal_date: str
    category: str = "other"
    color: str = "#6366f1"
    icon: str = ""
    is_active: bool = True
    notes: str = ""

class SubscriptionUpdate(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    currency: Optional[str] = None
    billing_cycle: Optional[str] = None
    renewal_date: Optional[str] = None
    category: Optional[str] = None
    color: Optional[str] = None
    icon: Optional[str] = None
    is_active: Optional[bool] = None
    notes: Optional[str] = None

@app.get("/api/subscriptions")
def list_subscriptions():
    conn = get_db()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM subscriptions ORDER BY renewal_date")
        rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

@app.post("/api/subscriptions")
def create_subscription(data: SubscriptionCreate):
    sid = str(uuid.uuid4())
    conn = get_db()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            INSERT INTO subscriptions (id, name, price, currency, billing_cycle, renewal_date, category, color, icon, is_active, notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *
        """, (sid, data.name, data.price, data.currency, data.billing_cycle, data.renewal_date,
              data.category, data.color, data.icon, data.is_active, data.notes))
        row = cur.fetchone()
    conn.commit()
    conn.close()
    return dict(row)

@app.put("/api/subscriptions/{sid}")
def update_subscription(sid: str, data: SubscriptionUpdate):
    conn = get_db()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM subscriptions WHERE id = %s", (sid,))
        if not cur.fetchone():
            conn.close()
            raise HTTPException(status_code=404, detail="Subscription not found")

        updates = []
        values = []
        for field, value in data.model_dump(exclude_none=True).items():
            updates.append(f"{field} = %s")
            if field == "is_active":
                value = bool(value)
            values.append(value)

        if updates:
            updates.append("updated_at = %s")
            values.append(datetime.now().isoformat())
            values.append(sid)
            cur.execute(f"UPDATE subscriptions SET {', '.join(updates)} WHERE id = %s RETURNING *", values)
            row = cur.fetchone()
        else:
            cur.execute("SELECT * FROM subscriptions WHERE id = %s", (sid,))
            row = cur.fetchone()
    conn.commit()
    conn.close()
    return dict(row)

@app.delete("/api/subscriptions/{sid}")
def delete_subscription(sid: str):
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("DELETE FROM subscriptions WHERE id = %s", (sid,))
    conn.commit()
    conn.close()
    return {"message": "Deleted"}

@app.post("/api/subscriptions/import")
def import_subscriptions(subs: list[SubscriptionCreate]):
    conn = get_db()
    imported = 0
    for sub in subs:
        sid = str(uuid.uuid4())
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO subscriptions (id, name, price, currency, billing_cycle, renewal_date, category, color, icon, is_active, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (sid, sub.name, sub.price, sub.currency, sub.billing_cycle, sub.renewal_date,
                  sub.category, sub.color, sub.icon, sub.is_active, sub.notes))
            imported += 1
    conn.commit()
    conn.close()
    return {"imported": imported}

@app.get("/api/export")
def export_subscriptions():
    conn = get_db()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM subscriptions ORDER BY renewal_date")
        rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8766)