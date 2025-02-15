# Use a lightweight Debian base image
FROM debian:bookworm-slim

# Create non-root users for security
RUN useradd --no-create-home --system fastapi_user && \
    useradd --no-create-home --system nginx_user

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt update && apt install -y \
    python3 python3-pip python3-venv \
    nginx-extras supervisor \
    libcap2-bin && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set Nginx capabilities to bind low ports (e.g., 80)
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# Create and activate virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copy application files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set correct permissions
RUN chown -R fastapi_user:fastapi_user /app && \
    chown -R nginx_user:nginx_user /var/log/nginx && \
    chmod 755 /app

# Create required directories for Supervisor and Nginx
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d /var/run/nginx && \
    chown nginx_user:nginx_user /var/run/nginx && \
    chmod 755 /var/run/nginx

# Copy configuration files
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Expose required ports
EXPOSE 80 8000

# Start Supervisor to manage Nginx & FastAPI
CMD ["/usr/bin/supervisord", "-n"]
