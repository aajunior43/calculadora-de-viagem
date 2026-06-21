import sqlite3
import json
from datetime import datetime
from typing import Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DB_PATH = "/data/subscriptions.db"

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    conn.execute("""
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
            is_active INTEGER DEFAULT 1,
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
    rows = conn.execute("SELECT * FROM subscriptions ORDER BY renewal_date").fetchall()
    conn.close()
    return [dict(r) for r in rows]

@app.post("/api/subscriptions")
def create_subscription(data: SubscriptionCreate):
    import uuid
    conn = get_db()
    sid = str(uuid.uuid4())
    conn.execute("""
        INSERT INTO subscriptions (id, name, price, currency, billing_cycle, renewal_date, category, color, icon, is_active, notes)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (sid, data.name, data.price, data.currency, data.billing_cycle, data.renewal_date, data.category, data.color, data.icon, int(data.is_active), data.notes))
    conn.commit()
    row = conn.execute("SELECT * FROM subscriptions WHERE id=?", (sid,)).fetchone()
    conn.close()
    return dict(row)

@app.put("/api/subscriptions/{sid}")
def update_subscription(sid: str, data: SubscriptionUpdate):
    conn = get_db()
    existing = conn.execute("SELECT * FROM subscriptions WHERE id=?", (sid,)).fetchone()
    if not existing:
        conn.close()
        raise HTTPException(status_code=404, detail="Subscription not found")
    
    updates = []
    values = []
    for field, value in data.model_dump(exclude_none=True).items():
        if field == "is_active":
            value = int(value)
        updates.append(f"{field}=?")
        values.append(value)
    
    if updates:
        updates.append("updated_at=?")
        values.append(datetime.now().isoformat())
        values.append(sid)
        conn.execute(f"UPDATE subscriptions SET {', '.join(updates)} WHERE id=?", values)
        conn.commit()
    
    row = conn.execute("SELECT * FROM subscriptions WHERE id=?", (sid,)).fetchone()
    conn.close()
    return dict(row)

@app.delete("/api/subscriptions/{sid}")
def delete_subscription(sid: str):
    conn = get_db()
    conn.execute("DELETE FROM subscriptions WHERE id=?", (sid,))
    conn.commit()
    conn.close()
    return {"message": "Deleted"}

@app.post("/api/subscriptions/import")
def import_subscriptions(subs: list[SubscriptionCreate]):
    import uuid
    conn = get_db()
    imported = []
    for sub in subs:
        sid = str(uuid.uuid4())
        conn.execute("""
            INSERT INTO subscriptions (id, name, price, currency, billing_cycle, renewal_date, category, color, icon, is_active, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (sid, sub.name, sub.price, sub.currency, sub.billing_cycle, sub.renewal_date, sub.category, sub.color, sub.icon, int(sub.is_active), sub.notes))
        imported.append(sid)
    conn.commit()
    conn.close()
    return {"imported": len(imported)}

@app.get("/api/export")
def export_subscriptions():
    conn = get_db()
    rows = conn.execute("SELECT * FROM subscriptions").fetchall()
    conn.close()
    return [dict(r) for r in rows]

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8766)
