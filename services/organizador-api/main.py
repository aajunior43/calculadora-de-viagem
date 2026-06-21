import os
import re
import json
from datetime import datetime
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import uvicorn

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

UPLOAD_DIR = "/tmp/organizer"
os.makedirs(UPLOAD_DIR, exist_ok=True)

MONTH_MAP = {
    'jan': 1, 'fev': 2, 'mar': 3, 'abr': 4, 'mai': 5, 'jun': 6,
    'jul': 7, 'ago': 8, 'set': 9, 'out': 10, 'nov': 11, 'dez': 12,
    'janeiro': 1, 'fevereiro': 2, 'marco': 3, 'abril': 4, 'maio': 5, 'junho': 6,
    'julho': 7, 'agosto': 8, 'setembro': 9, 'outubro': 10, 'novembro': 11, 'dezembro': 12
}

def extract_date(filename):
    patterns = [
        r'(\d{2})[-/](\d{4})',
        r'(\d{2})[-/](\d{2})[-/](\d{4})',
        r'(\w+)[-_](\d{4})',
        r'(\d{4})',
    ]
    for pattern in patterns:
        match = re.search(pattern, filename, re.IGNORECASE)
        if match:
            groups = match.groups()
            if len(groups) == 2:
                if groups[0].lower() in MONTH_MAP:
                    return {'month': MONTH_MAP[groups[0].lower()], 'year': int(groups[1])}
                elif groups[1].lower() in MONTH_MAP:
                    return {'month': MONTH_MAP[groups[1].lower()], 'year': int(groups[0])}
                else:
                    try:
                        m, y = int(groups[0]), int(groups[1])
                        if 1 <= m <= 12 and 1900 <= y <= 2100:
                            return {'month': m, 'year': y}
                    except:
                        pass
            elif len(groups) == 3:
                try:
                    d, m, y = int(groups[0]), int(groups[1]), int(groups[2])
                    if 1 <= m <= 12 and 1900 <= y <= 2100:
                        return {'month': m, 'year': y}
                except:
                    pass
    return None

@app.post("/api/upload")
async def upload_files(files: list[UploadFile] = File(...)):
    results = []
    for file in files:
        content = await file.read()
        filepath = os.path.join(UPLOAD_DIR, file.filename)
        with open(filepath, 'wb') as f:
            f.write(content)
        
        date_info = extract_date(file.filename)
        suggested_name = file.filename
        if date_info:
            month_names = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez']
            suggested_name = f"extrato_{month_names[date_info['month']-1]}_{date_info['year']}.pdf"
        
        results.append({
            'original': file.filename,
            'suggested': suggested_name,
            'size': len(content),
            'date': date_info,
            'path': filepath
        })
    return {'files': results, 'count': len(results)}

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8769)
