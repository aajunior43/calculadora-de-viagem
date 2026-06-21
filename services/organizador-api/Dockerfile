FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn python-multipart
RUN mkdir -p /tmp/organizer
COPY services/organizador-api/main.py .
EXPOSE 8769
CMD ["python", "main.py"]
