import re
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import urllib.request
import urllib.error
from html.parser import HTMLParser

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class ExtractRequest(BaseModel):
    url: str
    api_key: str

class StyleExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.styles = {
            'colors': set(),
            'bg_colors': set(),
            'fonts': set(),
            'font_sizes': set(),
            'border_radius': set(),
            'shadows': set(),
            'paddings': set(),
            'margins': set(),
            'text_colors': set(),
        }
        self.in_style = False
        self.style_content = []
        
    def handle_starttag(self, tag, attrs):
        if tag == 'style':
            self.in_style = True
        for name, value in attrs:
            if name == 'style' and value:
                self._extract_inline_styles(value)
    
    def handle_data(self, data):
        if self.in_style:
            self.style_content.append(data)
    
    def handle_endtag(self, tag):
        if tag == 'style':
            self.in_style = False
            self._extract_css_rules(''.join(self.style_content))
    
    def _extract_inline_styles(self, style):
        self._extract_css_rules(style)
    
    def _extract_css_rules(self, css):
        colors = re.findall(r'(?:color|background-color|border-color|border-\w+-color)\s*:\s*([^;}{]+)', css, re.I)
        for c in colors:
            c = c.strip()
            if c and c != 'transparent' and c != 'inherit':
                self.styles['colors'].add(c)
        
        fonts = re.findall(r'font-family\s*:\s*([^;}{]+)', css, re.I)
        for f in fonts:
            self.styles['fonts'].add(f.strip().split(',')[0].strip().strip('"\''))
        
        font_sizes = re.findall(r'font-size\s*:\s*(\d+(?:\.\d+)?(?:px|rem|em|pt))', css, re.I)
        self.styles['font_sizes'].update(font_sizes[:10])
        
        radii = re.findall(r'border-radius\s*:\s*([^;}{]+)', css, re.I)
        for r in radii:
            if '0' not in r.strip():
                self.styles['border_radius'].add(r.strip())
        
        shadows = re.findall(r'box-shadow\s*:\s*([^;}{]+)', css, re.I)
        for s in shadows:
            if s.strip() != 'none':
                self.styles['shadows'].add(s.strip()[:100])

def fetch_page(url):
    if not url.startswith(('http://', 'https://')):
        url = 'https://' + url
    
    req = urllib.request.Request(url, headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    })
    
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            return response.read().decode('utf-8', errors='ignore')
    except urllib.error.URLError as e:
        raise HTTPException(status_code=400, detail=f"Não foi possível acessar a URL: {str(e)}")

def extract_styles_from_html(html):
    extractor = StyleExtractor()
    try:
        extractor.feed(html[:50000])
    except:
        pass
    
    return {
        'colors': list(extractor.styles['colors'])[:20],
        'fonts': list(extractor.styles['fonts'])[:10],
        'font_sizes': list(extractor.styles['font_sizes'])[:10],
        'border_radius': list(extractor.styles['border_radius'])[:8],
        'shadows': list(extractor.styles['shadows'])[:5],
    }

async def call_gemini(api_key, data, url):
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    
    instruction = f"""Você é um especialista em design. Com base nos DADOS EXTRAÍDOS do site "{url}", gere um PROMPT detalhado em português descrevendo o estilo visual.

Estruture nas seções:
1) Identidade Visual
2) Tipografia
3) Paleta de Cores
4) Espaçamentos e Grid
5) Bordas e Raios
6) Sombras e Profundidade
7) Componentes
8) Estados e Motion
9) Variáveis/CSS Tokens

DADOS EXTRAÍDOS:
{json.dumps(data, indent=2, ensure_ascii=False)}

Gere o PROMPT detalhado."""
    
    body = json.dumps({
        "contents": [{"role": "user", "parts": [{"text": instruction}]}]
    }).encode('utf-8')
    
    req = urllib.request.Request(endpoint, data=body, headers={'Content-Type': 'application/json'})
    
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            result = json.loads(response.read().decode('utf-8'))
            text = result.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', '')
            if not text:
                raise Exception('Resposta vazia do Gemini')
            return text
    except urllib.error.URLError as e:
        raise HTTPException(status_code=500, detail=f"Erro na API Gemini: {str(e)}")

@app.post("/api/extract")
async def extract_style(data: ExtractRequest):
    html = fetch_page(data.url)
    styles = extract_styles_from_html(html)
    prompt = await call_gemini(data.api_key, styles, data.url)
    return {"prompt": prompt, "extracted": styles}

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8768)
