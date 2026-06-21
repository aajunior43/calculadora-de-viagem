FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn psycopg2-binary PyJWT bcrypt pydantic
COPY services/link-stash-api/main.py .
EXPOSE 8770
CMD ["python", "main.py"]
