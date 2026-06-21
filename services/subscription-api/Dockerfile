FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn psycopg2-binary
COPY services/subscription-api/main.py .
EXPOSE 8766
CMD ["python", "main.py"]
