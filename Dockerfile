# Use a Debian-based Python image with necessary dependencies
FROM python:3.10-slim

# Set non-interactive mode for APT to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt update && apt install -y \
    nginx \
    supervisor \
    python3-venv \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install project dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY --chown=root:root . /app

# Copy and configure Nginx & Supervisor
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Expose ports
EXPOSE 80

# Start Supervisor (which starts Nginx & FastAPI)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
