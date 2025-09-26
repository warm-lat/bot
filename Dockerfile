# Use Python 3.11 slim as base image for better performance and smaller size
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Install system dependencies required for the bot
RUN apt-get update && apt-get install -y \
    # Build tools
    gcc \
    g++ \
    make \
    # Audio/Video processing
    ffmpeg \
    libopus-dev \
    libffi-dev \
    libnacl-dev \
    # Image processing (Wand/ImageMagick)
    libmagickwand-dev \
    imagemagick \
    # Web scraping/browser automation
    wget \
    gnupg \
    # Other dependencies
    git \
    curl \
    libssl-dev \
    pkg-config \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers (needed for browser automation)
RUN playwright install-deps
RUN playwright install

# Copy the application code
COPY . .

# Set appropriate permissions
RUN chmod +x /app/main.py

# Expose port if needed (for web interface or API)
EXPOSE 9562

# Health check to ensure the bot is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import psutil; exit(0 if any('python' in p.name().lower() and 'main.py' in ' '.join(p.cmdline()) for p in psutil.process_iter(['pid', 'name', 'cmdline']) if p.info['cmdline']) else 1)" || exit 1

# Run the bot
CMD ["python", "main.py"]