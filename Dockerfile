# Stage 1: Build Stage (compile dependencies, collect static files, etc.)
FROM python:3.11-slim as builder

WORKDIR /app

# System dependencies (if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --prefix=/install -r requirements.txt

# Copy app source code
COPY . .

# Stage 2: Production Stage (minimal runtime image)
FROM python:3.11-slim

# Create app directory
WORKDIR /app

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

# Copy only the necessary code
COPY --from=builder /app .

# Set environment variables for production
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 5000

# Start Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

