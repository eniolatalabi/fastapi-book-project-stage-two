# Use a stable Debian base
FROM debian:latest

# Set working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

# Install dependencies
RUN apt update && apt install -y python3 python3-pip nginx supervisor

# Ensure Nginx and Supervisor start correctly
RUN mkdir -p /var/log/supervisor

# Copy configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Ensure permissions
RUN chmod 644 /etc/supervisor/conf.d/supervisor.conf

# Expose ports
EXPOSE 80

# Start Supervisor (which starts Nginx & FastAPI)
CMD ["supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
