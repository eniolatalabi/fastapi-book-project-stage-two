# Use a lightweight Debian-based image
FROM debian:bookworm-slim

# Create system users for security
RUN useradd --no-create-home --system fastapi_user && \
    useradd --no-create-home --system nginx_user

# Ensure required directories exist
RUN mkdir -p /app /var/log/nginx /var/run/nginx /etc/nginx && \
    chown -R nginx_user:nginx_user /var/log/nginx /var/run/nginx /etc/nginx

WORKDIR /app

# Install dependencies
RUN apt update && apt install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    nginx supervisor gettext \
    libcap2-bin curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set Nginx capabilities (allow binding to port <1024)
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# Create virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Configure file permissions
RUN chown -R fastapi_user:fastapi_user /app && chmod 755 /app

# Copy configuration files
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Ensure correct permissions for FastAPI and Nginx
RUN chmod 755 /var/run/nginx

# Set Render's dynamic port as an environment variable
ENV PORT=10000  

# Expose the correct port
EXPOSE 10000 

# Start Nginx and FastAPI using Supervisor
CMD envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisor.conf
