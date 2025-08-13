# Stage 1: Build Stage (install dependencies)
FROM python:3.11-slim as builder

WORKDIR /app

# Install build tools and Python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy only the source code we need
COPY app.py .
COPY templates ./templates
COPY static ./static

# Stage 2: Production Stage (minimal image)
FROM python:3.11-slim

WORKDIR /app

# Copy only installed dependencies and minimal app files
COPY --from=builder /install /usr/local
COPY --from=builder /app .

# Set environment variables for production
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

