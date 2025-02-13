# Use an official Python runtime as a parent image
FROM debian:latest


# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Install Nginx and Supervisor
RUN apt update && apt install -y python3 python3-pip nginx supervisor

# Copy Nginx and Supervisor configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Expose port 80 for Nginx
EXPOSE 80

# Start Supervisor (which starts Nginx & FastAPI)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
