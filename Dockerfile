FROM debian:bookworm-slim

# Create non-root users
RUN useradd --no-create-home --system fastapi_user && \
    useradd --no-create-home --system nginx_user

WORKDIR /app

# Install dependencies
RUN apt update && apt install -y \
    python3 python3-pip python3-venv \
    nginx supervisor \
    libcap2-bin && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set Nginx capabilities
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# Create virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Configure file permissions
RUN chown -R fastapi_user:fastapi_user /app && \
    chown -R nginx_user:nginx_user /var/log/nginx && \
    chmod 755 /app

# Create required directories
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

# Copy configurations
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 8000

CMD ["/usr/bin/supervisord", "-n"]

RUN mkdir -p /var/run/nginx && \
    chown nginx_user:nginx_user /var/run/nginx && \
    chmod 755 /var/run/nginx