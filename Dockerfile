# Use a stable Debian base
FROM debian:latest

# Set working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

# Update package list and install dependencies
RUN apt update && apt install -y python3 python3-pip nginx supervisor && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

# Copy Supervisor and Nginx Configurations
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure correct permissions
RUN chmod 644 /etc/supervisor/conf.d/supervisor.conf

# Expose required ports
EXPOSE 80 8000

# Run Supervisor in foreground mode
CMD ["/usr/bin/supervisord", "-n"]
