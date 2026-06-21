FROM python:3.11-slim
WORKDIR /app
COPY services/organizador/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY services/organizador/relay_server.py .
EXPOSE 8765
CMD ["python", "relay_server.py"]
