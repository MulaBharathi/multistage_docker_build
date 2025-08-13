# Stage 1: Build Stage (install dependencies)
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build tools (only in builder stage)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install Python dependencies without cache
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy only your application code
COPY app.py .

# Stage 2: Production Stage (minimal image)
FROM python:3.11-slim

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy application code from builder
COPY --from=builder /app .

# Environment variables
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Expose Flask port
EXPOSE 5000

# Start the Flask app with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

