import os
import uuid
import subprocess
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
import uvicorn

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DOWNLOAD_DIR = "/tmp/downloads"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

class DownloadRequest(BaseModel):
    url: str
    format: str = "mp4"

class InfoRequest(BaseModel):
    url: str

@app.post("/api/info")
def get_video_info(data: InfoRequest):
    try:
        command = [
            'yt-dlp',
            '--dump-json',
            '--no-download',
            data.url
        ]
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        
        if result.returncode != 0:
            raise HTTPException(status_code=400, detail="URL inválida ou inacessível")
        
        info = json.loads(result.stdout)
        
        formats = []
        if 'formats' in info:
            for f in info['formats']:
                if f.get('vcodec') != 'none' and f.get('ext') in ['mp4', 'webm', 'mkv']:
                    formats.append({
                        'format_id': f['format_id'],
                        'ext': f['ext'],
                        'resolution': f.get('resolution', 'N/A'),
                        'filesize': f.get('filesize', 0),
                        'format_note': f.get('format_note', '')
                    })
        
        return {
            'title': info.get('title', 'Sem título'),
            'thumbnail': info.get('thumbnail', ''),
            'duration': info.get('duration', 0),
            'uploader': info.get('uploader', 'Desconhecido'),
            'description': info.get('description', '')[:200],
            'formats': formats[:10]
        }
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Timeout ao buscar informações")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/download")
def download_video(data: DownloadRequest):
    try:
        download_id = str(uuid.uuid4())[:8]
        output_template = f"{DOWNLOAD_DIR}/{download_id}.%(ext)s"
        
        command = [
            'yt-dlp',
            '-f', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
            '--merge-output-format', 'mp4',
            '-o', output_template,
            '--no-playlist',
            data.url
        ]
        
        result = subprocess.run(command, capture_output=True, text=True, timeout=300)
        
        if result.returncode != 0:
            error_msg = result.stderr.splitlines()[-1] if result.stderr else "Erro desconhecido"
            raise HTTPException(status_code=400, detail=error_msg)
        
        downloaded_file = None
        for file in os.listdir(DOWNLOAD_DIR):
            if file.startswith(download_id):
                downloaded_file = os.path.join(DOWNLOAD_DIR, file)
                break
        
        if not downloaded_file:
            raise HTTPException(status_code=500, detail="Arquivo não encontrado após download")
        
        filename = os.path.basename(downloaded_file)
        return FileResponse(
            downloaded_file,
            media_type='video/mp4',
            filename=filename,
            background_task=None
        )
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Download timeout - vídeo muito longo")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8767)
