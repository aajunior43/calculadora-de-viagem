FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn
COPY services/style-extractor-api/main.py .
EXPOSE 8768
CMD ["python", "main.py"]
