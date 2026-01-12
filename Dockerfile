FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    ffmpeg \
    libopus-dev \
    libffi-dev \
    libnacl-dev \
    libmagickwand-dev \
    imagemagick \
    wget \
    gnupg \
    git \
    curl \
    libssl-dev \
    pkg-config \

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN playwright install-deps
RUN playwright install

COPY . .

RUN chmod +x /app/main.py

CMD ["python", "main.py"]