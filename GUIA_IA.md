# Guia para IAs - Hub Master

## Regra Importante

**TODA alteração feita em qualquer app deve ser enviada para DOIS repositórios:**

1. **Repositório Original** - O repo de origem do app (ex: `aajunior43/calculadora-de-tempestade`)
2. **Repositório do Hub** - `aajunior43/HUB-MASTER`

### Fluxo de Trabalho

```
1. Editar o arquivo em /root/hub-master-scaffold/apps/{nome-app}/
2. Git commit e push para o repo original do app
3. Git commit e push para o repo HUB-MASTER
4. Rebuild e restart dos containers Docker
```

### Comandos Padrão

```bash
# Push para o repo original
cd /root/hub-master-scaffold/apps/{nome-app}
git add -A && git commit -m "Descrição da alteração"
git push origin main

# Push para o hub
cd /root/hub-master-scaffold
git add -A && git commit -m "Descrição da alteração"
git push origin main

# Rebuild e restart
cd /root/hub-master-scaffold
docker compose build hub-master
docker compose up -d hub-master
```

---

## Lista de Todos os Projetos

| # | App | Rota no Hub | Repo Original | Tipo |
|---|-----|-------------|---------------|------|
| 1 | Calculadora de Tempestade | `/calculadora-de-tempestade/` | [aajunior43/calculadora-de-tempestade](https://github.com/aajunior43/calculadora-de-tempestade) | HTML |
| 2 | Contador de Caracteres | `/contador-de-caracteres/` | HTML | Hub |
| 3 | Regra de Três | `/regra-de-3/` | HTML | Hub |
| 4 | Gerador de Variações | `/gerador-de-variacoes/` | HTML | Hub |
| 5 | Extrair Links de Grupos | `/extrair-links-de-grupos/` | HTML | Hub |
| 6 | Gerador de Números Aleatórios | `/gerador-de-numeros-aleatorios/` | HTML | Hub |
| 7 | Consumo Ideal de Água | `/calculadora-consumo-ideal-agua/` | HTML | Hub |
| 8 | Extrator de Texto PDF | `/pdf-extrator/` | HTML | Hub |
| 9 | Relógio | `/relogio/` | HTML | Hub |
| 10 | Google Dorks | `/google-dorks/` | HTML | Hub |
| 11 | Calculadora Juros Parcelamento | `/calculadora-juros-parcelamento/` | HTML | Hub |
| 12 | Contagem Regressiva Datas | `/contagem-regressiva-datas/` | HTML | Hub |
| 13 | Calculadora Segurança Tomada | `/calculadora-seguranca-tomada/` | HTML | Hub |
| 14 | Salvar Prompt | `/salvar-prompt/` | HTML | Hub |
| 15 | Calculadora Conciliação | `/calculadora-conciliacao/` | HTML | Hub |
| 16 | Calculadora Regra de 3 | `/calculadora-regra-de-3/` | HTML | Hub |
| 17 | Formatador Mensagem WhatsApp | `/formatador-mensagem-whatsapp/` | HTML | Hub |
| 18 | Marca D'Água | `/marca-dagua/` | HTML | Hub |
| 19 | Buscador Grupos WhatsApp Telegram | `/buscador-grupos-whatsapp-telegram/` | HTML | Hub |
| 20 | Mermaid Fluxograma | `/mermaid-fluxograma/` | HTML | Hub |
| 21 | Markify Creator | `/markify-creator/` | [aajunior43/markify-creator](https://github.com/aajunior43/markify-creator) | Vite/React |
| 22 | Prompt Palace AI Hub | `/prompt-palace-ai-hub/` | [aajunior43/prompt-palace-ai-hub](https://github.com/aajunior43/prompt-palace-ai-hub) | Vite/React |
| 23 | Tidy Tasks Bloom | `/tidy-tasks-bloom/` | [aajunior43/tidy-tasks-bloom](https://github.com/aajunior43/tidy-tasks-bloom) | Vite/React |
| 24 | Matrix | `/matrix/` | HTML | Hub |
| 25 | Inajá Fornecimento Digital | `/inaja-fornecimento-digital/` | [aajunior43/inaja-fornecimento-digital](https://github.com/aajunior43/inaja-fornecimento-digital) | Vite/React |
| 26 | Calculadora de Diferença | `/calculadoradediferenca/` | [aajunior43/calculadoradediferenca](https://github.com/aajunior43/calculadoradediferenca) | Vite/React |
| 27 | Organizador Web | `/organizador/` | Hub | HTML |
| 28 | YouTube Transcriber | `/youtube-transcriber/` | [aajunior43/Youtuber-transcriber](https://github.com/aajunior43/Youtuber-transcriber) | HTML |
| 29 | Color Gemini Canvas | `/color-gemini-canvas/` | [aajunior43/color-gemini-canvas](https://github.com/aajunior43/color-gemini-canvas) | Vite/React |
| 30 | Bloco de Notas Markdown | `/bloco-de-notas-markdown/` | HTML | Hub |
| 31 | Meus Repositórios GitHub | `/meus-repositorios-github/` | HTML | Hub |
| 32 | Calculadora de Porcentagem | `/calculadora-percent/` | [aajunior43/calculadora-percent](https://github.com/aajunior43/calculadora-percent) | Next.js |
| 33 | Reinado | `/reinado/` | HTML | Hub |
| 34 | Contagem de Assinaturas | `/countdown-sub-sync/` | [aajunior43/countdown-sub-sync](https://github.com/aajunior43/countdown-sub-sync) | Vite/React |
| 35 | Baixar Vídeos | `/baixar-videos/` | [aajunior43/bottelegramvideo](https://github.com/aajunior43/bottelegramvideo) | API Python |
| 36 | Extrator de Estilo | `/extrator-designer/` | [aajunior43/extensao-extrator-designer](https://github.com/aajunior43/extensao-extrator-designer) | API Python |
| 37 | Calculadora de Viagem | `/calculadora-de-viagem/` | [aajunior43/calculadora-de-viagem](https://github.com/aajunior43/calculadora-de-viagem) | HTML |
| 38 | Área de Trabalho | `/area-de-trabalho/` | [aajunior43/area-de-trabalho](https://github.com/aajunior43/area-de-trabalho) | HTML |
| 39 | Gerador de Status | `/gerador-de-status/` | [aajunior43/GERADOR-DE-STATUS](https://github.com/aajunior43/GERADOR-DE-STATUS) | Next.js |
| 40 | Friendly Lobster Run | `/friendly-lobster-run/` | [aajunior43/friendly-lobster-run](https://github.com/aajunior43/friendly-lobster-run) | Vite/React |
| 41 | Cyber Clock Background | `/cyberclock-background/` | [aajunior43/cyberclock-background](https://github.com/aajunior43/cyberclock-background) | Vite/React |
| 42 | Art Narrator | `/art-narrator/` | [aajunior43/art-narrator](https://github.com/aajunior43/art-narrator) | Vite/React |
| 43 | Afazeres | `/afazeres/` | [aajunior43/afazeres](https://github.com/aajunior43/afazeres) | Vite/React |
| 44 | Google Dorks | `/dorks/` | [aajunior43/dorks](https://github.com/aajunior43/dorks) | Vite/React |
| 45 | PDFMaster Pro | `/pdfmaster-pro/` | [aajunior43/PDFMaster-Pro](https://github.com/aajunior43/PDFMaster-Pro) | Next.js |
| 46 | Meu Site | `/meu-site/` | [aajunior43/meu-site](https://github.com/aajunior43/meu-site) | HTML |
| 47 | Quick Notes AI | `/quick-notes-ai/` | [aajunior43/extensao-navegador-bloco-de-nota-ia](https://github.com/aajunior43/extensao-navegador-bloco-de-nota-ia) | HTML |
| 48 | Gemini PDF Rename | `/gemini-pdf-rename-magic/` | [aajunior43/gemini-pdf-rename-magic](https://github.com/aajunior43/gemini-pdf-rename-magic) | Vite/React |
| 49 | Organizador de Extratos | `/organizador-extratos/` | [aajunior43/organizador](https://github.com/aajunior43/organizador) | API Python |
| 50 | Hub Design Studio | `/hub-design-studio/` | [aajunior43/hub-design-studio](https://github.com/aajunior43/hub-design-studio) | Vite/React |
| 51 | Analisador de Nota Fiscal | `/analisador-nota-fiscal/` | [aajunior43/Analisador-de-Nota-Fiscal-com-IA](https://github.com/aajunior43/Analisador-de-Nota-Fiscal-com-IA) | Vite/React |
| 52 | AI Image Prompt Generator | `/ai-image-prompt/` | [aajunior43/AI-Image-Prompt-Generator](https://github.com/aajunior43/AI-Image-Prompt-Generator) | Vite/React |
| 53 | Gerador de Memes IA | `/gerador-memes/` | [aajunior43/Gerador-de-Memes-IA](https://github.com/aajunior43/Gerador-de-Memes-IA) | Vite/React |
| 54 | Corretor Ortográfico IA | `/corretor-ortografico/` | [aajunior43/Corretor-Ortogr-fico-com-IA](https://github.com/aajunior43/Corretor-Ortogr-fico-com-IA) | Vite/React |
| 55 | Social Media Design | `/social-media-design/` | [aajunior43/Social-Media-Design-Assistant](https://github.com/aajunior43/Social-Media-Design-Assistant) | Vite/React |
| 56 | Gerador de Dorks IA | `/gerador-dorks-ia/` | [aajunior43/Gerador-de-Google-Dorks-com-IA](https://github.com/aajunior43/Gerador-de-Google-Dorks-com-IA) | Vite/React |
| 57 | Plano de Estudo IA | `/plano-estudo/` | [aajunior43/Expert-Study-Plan-Generator](https://github.com/aajunior43/Expert-Study-Plan-Generator) | Vite/React |
| 58 | Sherlock | `/sherlock/` | [aajunior43/Sherlock-](https://github.com/aajunior43/Sherlock-) | Vite/React |
| 59 | Melhorador de Prompt | `/melhorador-prompt/` | [aajunior43/MELHORADOR-DE-PROMPT](https://github.com/aajunior43/MELHORADOR-DE-PROMPT) | Vite/React |
| 60 | Dicionário IA | `/dicionario-ia/` | [aajunior43/dicionario-ia](https://github.com/aajunior43/dicionario-ia) | Vite/React |
| 61 | Fluxograma com IA | `/fluxograma-ia/` | [aajunior43/fluxograma-com-ia](https://github.com/aajunior43/fluxograma-com-ia) | Vite/React |
| 62 | Agenda IA | `/agenda-ia/` | [aajunior43/AGENDAIA](https://github.com/aajunior43/AGENDAIA) | Vite/React |
| 63 | Prompt Spark | `/prompt-spark/` | [aajunior43/prompt-spark-keeper](https://github.com/aajunior43/prompt-spark-keeper) | Vite/React |
| 64 | Diária Clock | `/diaria-clock/` | [aajunior43/diaria-clock-cruncher](https://github.com/aajunior43/diaria-clock-cruncher) | Vite/React |
| 65 | HTML Visualizer | `/html-visualizer/` | [aajunior43/Html-visualizer](https://github.com/aajunior43/Html-visualizer) | HTML/JS |
| 66 | Gerador de Status (novo) | `/gerador-status-novo/` | [aajunior43/gerador-status](https://github.com/aajunior43/gerador-status) | Vite/React |
| 67 | Prompt Foto | `/promptfoto/` | [aajunior43/promptfoto](https://github.com/aajunior43/promptfoto) | Vite/React |
| 68 | Link Stash | `/link-stash/` | [aajunior43/link-stash-backup-buddy](https://github.com/aajunior43/link-stash-backup-buddy) | Vite/React |
| 69 | Buscador de Grupos | `/buscador-grupos/` | [aajunior43/buscador-grupos](https://github.com/aajunior43/buscador-grupos) | HTML |
| 70 | Buscador de Processos | `/buscador-processos/` | [aajunior43/buscador-processos](https://github.com/aajunior43/buscador-processos) | HTML |

---

## Serviços Backend

| Serviço | Porta | Função |
|---------|-------|--------|
| subscription-api | 8766 | API de assinaturas (SQLite) |
| video-download-api | 8767 | Download de vídeos (yt-dlp) |
| style-extractor-api | 8768 | Extração de estilos CSS |
| organizador-api | 8769 | Organização de extratos |
| organizador-relay | 8765 | WebSocket relay |
| favoritos | 80 | PHP - Sistema de favoritos |

---

## Credenciais

- **GitHub Token:** Definido no ambiente (não expor em repositórios públicos)
- **FAVORITES_PASSWORD:** Definido no arquivo `.env`

---

## Estrutura do Projeto

```
/root/hub-master-scaffold/
├── Dockerfile              # Nginx principal
├── docker-compose.yml      # Todos os serviços
├── nginx/default.conf      # Configuração nginx
├── public/index.html       # Página principal do hub
├── apps/                   # Todos os apps
│   ├── {nome-app}/        # Código fonte original
│   └── {nome-app}-dist/   # Build pronto (copy de dist)
├── services/               # APIs backend
│   ├── subscription-api/
│   ├── video-download-api/
│   ├── style-extractor-api/
│   ├── organizador-api/
│   ├── organizador/
│   └── favoritos/
└── .env                    # Variáveis de ambiente
```
