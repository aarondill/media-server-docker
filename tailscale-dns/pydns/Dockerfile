from python:3
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ENV HOST_FILE=/hosts/domain.list
ENTRYPOINT ["python", "/app/main.py"]
