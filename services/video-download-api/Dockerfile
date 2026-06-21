FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    yt-dlp \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn
RUN mkdir -p /tmp/downloads
COPY services/video-download-api/main.py .
EXPOSE 8767
CMD ["python", "main.py"]
