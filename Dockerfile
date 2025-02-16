# Use a lightweight base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Ensure Nginx permissions
RUN chmod -R 755 /var/run/nginx /var/log/nginx

# Expose dynamic port
EXPOSE ${PORT}

# Run envsubst to replace $PORT in Nginx config at runtime
CMD envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
    nginx -g 'daemon off;'
