# Use a stable Debian base
FROM debian:latest

# Set working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

# Update package list and install required system dependencies
RUN apt update && apt install -y \
    python3 python3-pip python3-venv nginx supervisor \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment (fix for PEP 668)
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install project dependencies inside the virtual environment
RUN pip install --no-cache-dir -r requirements.txt

# Create necessary directories before copying config files
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

# Copy Supervisor and Nginx Configurations
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure correct permissions AFTER copying files
RUN chmod 644 /etc/supervisor/conf.d/supervisor.conf

# Expose required ports
EXPOSE 80 8000

# Start Supervisor (which manages FastAPI & Nginx)
CMD ["/usr/bin/supervisord", "-n"]
