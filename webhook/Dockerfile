# Use official PHP image
FROM php:8.2-cli

LABEL MAINTAINER="Amit" \
      "GitHub Link"="https://github.com/amiteshwarp"

# Install required dependencies
RUN apt-get update && apt-get install -y unzip curl && rm -rf /var/lib/apt/lists/*

# Download and install the latest ngrok version
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list \
    && apt-get update && apt-get install -y ngrok

# Set working directory
WORKDIR /var/www/html

# Create ngrok.yml dynamically with the auth token
COPY <<-'EOF' /root/.config/ngrok/ngrok.yml
version: 3
tunnels:
  web:
    addr: host.docker.internal:81
    proto: http
  api:
    addr: localhost:5000
    proto: http
EOF

# Put command to start php and ngrok
COPY <<-'EOF' /start.sh
#!/bin/bash
# Start PHP Built-in Server in the background
php -S 0.0.0.0:5000 -t /var/www/html &
# Start ngrok to expose the local server
ngrok authtoken $NGROK_AUTH_TOKEN && ngrok start --all --config /root/.config/ngrok/ngrok.yml > /var/www/html/ngrok.log 2>&1 &
# Wait to ensure ngrok starts properly
sleep 5
# Print ngrok logs for debugging
cat /var/www/html/ngrok.log
# Keep container running
tail -f /dev/null
EOF

RUN chmod +x /start.sh

# Expose ports (for PHP and ngrok)
EXPOSE 5000 4040

# Run the start script
CMD ["bash", "/start.sh"]