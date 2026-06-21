#!/usr/bin/env python3
"""
Organizador de Arquivos - Agente Local
Conecta ao servidor relay via WebSocket e executa comandos de organização.
"""

import asyncio
import json
import os
import shutil
import uuid
from datetime import datetime
from pathlib import Path

try:
    import websockets
except ImportError:
    print("Instale as dependências: pip install websockets")
    exit(1)

RELAY_SERVER = "ws://hub.srv1767486.hstgr.cloud:8765/ws/agent"
AGENT_ID = f"agent-{uuid.uuid4().hex[:8]}"

FILE_CATEGORIES = {
    "Imagens": [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".webp", ".tiff", ".ico", ".raw"],
    "Documentos": [".pdf", ".doc", ".docx", ".txt", ".rtf", ".odt", ".xls", ".xlsx", ".ppt", ".pptx", ".csv"],
    "Videos": [".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm", ".m4v", ".3gp"],
    "Audio": [".mp3", ".wav", ".flac", ".aac", ".ogg", ".wma", ".m4a", ".opus", ".aiff"],
    "Compactados": [".zip", ".rar", ".7z", ".tar", ".gz", ".bz2", ".xz"],
    "Executaveis": [".exe", ".msi", ".deb", ".rpm", ".dmg", ".app"],
    "Codigo": [".py", ".js", ".html", ".css", ".java", ".cpp", ".c", ".php", ".go", ".rs", ".ts"],
}


def get_category(filename: str) -> str:
    ext = Path(filename).suffix.lower()
    for cat, exts in FILE_CATEGORIES.items():
        if ext in exts:
            return cat
    return "Outros"


def format_size(size_bytes: int) -> str:
    for unit in ["B", "KB", "MB", "GB"]:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"


def analyze_folder(path: str, mode: str) -> dict:
    folder = Path(path)
    if not folder.exists():
        return {"error": f"Pasta nao encontrada: {path}"}

    files = []
    for f in folder.iterdir():
        if f.is_file():
            stat = f.stat()
            files.append({
                "name": f.name,
                "path": str(f),
                "size": format_size(stat.st_size),
                "size_bytes": stat.st_size,
                "modified": datetime.fromtimestamp(stat.st_mtime).isoformat(),
                "category": get_category(f.name),
                "extension": f.suffix.lower(),
            })

    groups = {}
    for f in files:
        if mode == "type":
            key = f["category"]
        elif mode == "date":
            key = datetime.fromisoformat(f["modified"]).strftime("%Y-%m")
        elif mode == "name":
            key = f["name"][0].upper() if f["name"][0].isalpha() else "#"
        else:
            key = "Geral"
        groups.setdefault(key, []).append(f)

    return {
        "type": "analyze_result",
        "total_files": len(files),
        "total_size": format_size(sum(f["size_bytes"] for f in files)),
        "groups": {k: len(v) for k, v in groups.items()},
        "files": files,
    }


def organize_folder(path: str, mode: str, files: list) -> dict:
    folder = Path(path)
    backup_dir = folder / "_backup_" + datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir.mkdir(exist_ok=True)
    moved = 0
    errors = 0

    for f_info in files:
        src = Path(f_info["path"])
        if not src.exists():
            continue

        if mode == "type":
            dest_dir = folder / f_info["category"]
        elif mode == "date":
            dest_dir = folder / datetime.fromisoformat(f_info["modified"]).strftime("%Y-%m")
        elif mode == "name":
            letter = f_info["name"][0].upper() if f_info["name"][0].isalpha() else "#"
            dest_dir = folder / letter
        else:
            dest_dir = folder / "Organizado"

        try:
            backup_src = backup_dir / src.name
            shutil.copy2(str(src), str(backup_src))

            dest_dir.mkdir(exist_ok=True)
            dest = dest_dir / src.name
            if dest.exists():
                base = src.stem
                ext = src.suffix
                dest = dest_dir / f"{base}_{uuid.uuid4().hex[:6]}{ext}"
            shutil.move(str(src), str(dest))
            moved += 1
        except Exception as e:
            errors += 1

    return {
        "type": "organize_result",
        "moved": moved,
        "errors": errors,
        "backup_path": str(backup_dir),
    }


async def send_result(ws, cmd_id: str, result: dict):
    result["command_id"] = cmd_id
    await ws.send(json.dumps(result))


async def agent_loop():
    url = f"{RELAY_SERVER}/{AGENT_ID}"
    print(f"Agente: {AGENT_ID}")
    print(f"Conectando ao servidor...")

    while True:
        try:
            async with websockets.connect(url) as ws:
                print("Conectado ao servidor!")
                async for message in ws:
                    msg = json.loads(message)
                    if msg.get("type") == "command":
                        cmd_id = msg.get("command_id")
                        command = msg.get("command")
                        params = msg.get("params", {})

                        if command == "analyze":
                            result = analyze_folder(params.get("path", ""), params.get("mode", "type"))
                            await send_result(ws, cmd_id, result)
                        elif command == "organize":
                            result = organize_folder(
                                params.get("path", ""),
                                params.get("mode", "type"),
                                params.get("files", []),
                            )
                            await send_result(ws, cmd_id, result)
        except websockets.exceptions.ConnectionClosed:
            print("Conexao perdida. Reconectando em 3s...")
            await asyncio.sleep(3)
        except Exception as e:
            print(f"Erro: {e}. Reconectando em 3s...")
            await asyncio.sleep(3)


if __name__ == "__main__":
    print("=" * 50)
    print("  Organizador de Arquivos - Agente Local")
    print("=" * 50)
    print(f"  ID do agente: {AGENT_ID}")
    print(f"  Servidor: {RELAY_SERVER}")
    print("=" * 50)
    asyncio.run(agent_loop())
