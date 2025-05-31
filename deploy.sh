#!/bin/bash

set -e

# CONFIGURATION
EC2_PUBLIC_IP="13.233.163.151"
DOCKER_IMAGE="${1}"  # Image name passed as the first argument
NGINX_CONF="/etc/nginx/conf.d/app.conf"
HEALTH_CHECK_PATH="/actuator/health"

echo "Checking active port in NGINX config..."
ACTIVE_PORT=$(grep -oP 'proxy_pass http://127.0.0.1:\K[0-9]+' $NGINX_CONF)

if [ "$ACTIVE_PORT" == "8081" ]; then
  NEW_PORT=8082
  NEW_COLOR="green"
  OLD_COLOR="blue"
else
  NEW_PORT=8081
  NEW_COLOR="blue"
  OLD_COLOR="green"
fi

echo "Active: $ACTIVE_PORT | Deploying to $NEW_COLOR:$NEW_PORT"

echo "Pulling Docker image: $DOCKER_IMAGE"
sudo docker pull $DOCKER_IMAGE

echo "Stopping any existing $NEW_COLOR container"
sudo docker stop app_$NEW_COLOR || true
sudo docker rm app_$NEW_COLOR || true

echo "Starting new container on port $NEW_PORT"
sudo docker run -d --name app_$NEW_COLOR -p $NEW_PORT:8080 $DOCKER_IMAGE

echo "Waiting for health check on port $NEW_PORT..."
SUCCESS=false
for i in {1..10}; do
  STATUS=$(curl http://$EC2_PUBLIC_IP:$NEW_PORT | grep '"status":"UP"')
  if [ ! -z "$STATUS" ]; then
    echo "Service is healthy!"
    SUCCESS=true
    break
  fi
  echo "Attempt $i..."
  sleep 5
done

if [ "$SUCCESS" = false ]; then
  echo "Health check failed after 10 attempts. Aborting deployment!"
  exit 1
fi

echo "Switching NGINX to port $NEW_PORT"
sudo sed -i "s/proxy_pass http:\/\/127.0.0.1:[0-9]\+/proxy_pass 127.0.0.1:$NEW_PORT/" $NGINX_CONF
sudo nginx -s reload

echo "Stopping and removing old container: $OLD_COLOR"
sudo docker stop app_$OLD_COLOR || true
sudo docker rm app_$OLD_COLOR || true

echo "Deployment to $NEW_COLOR complete!"
