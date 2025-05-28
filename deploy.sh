#!/bin/bash

set -e

# CONFIGURATION
EC2_USER="ubuntu"
EC2_HOST="3.110.121.131"
DOCKER_IMAGE="${1}"  # Pass image name as first argument
NGINX_CONF="/etc/nginx/conf.d/app.conf"
HEALTH_CHECK_PATH="/actuator/health"
APP_DIR="/home/ubuntu/your-app-directory"

echo "Checking active port..."
ACTIVE_PORT=$(grep -oP 'proxy_pass 127.0.0.1:\K[0-9]+' $NGINX_CONF)

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

ssh $EC2_USER@$EC2_HOST << EOF
  set -e

  echo "Pulling Docker image: $DOCKER_IMAGE"
  docker pull $DOCKER_IMAGE

  echo "Stopping any existing $NEW_COLOR container"
  docker stop app_$NEW_COLOR || true
  docker rm app_$NEW_COLOR || true

  echo "Starting new container on port $NEW_PORT"
  docker run -d --name app_$NEW_COLOR -p $NEW_PORT:8080 $DOCKER_IMAGE

  echo "Waiting for health check..."
  SUCCESS=false
  for i in {1..10}; do
    STATUS=\$(curl -s http://localhost:$NEW_PORT$HEALTH_CHECK_PATH | grep '"status":"UP"')
    if [ ! -z "\$STATUS" ]; then
      echo "Service is healthy!"
      break
    fi
    echo "Attempt \$i..."
    sleep 5
  done

  if [ "$SUCCESS" = false ]; then
    echo "Health check failed after 10 attempts. Aborting deployment!"
    exit 1
  fi

  echo "Switching NGINX to port $NEW_PORT"
  sudo sed -i "s/proxy_pass 127.0.0.1:[0-9]\+/proxy_pass 127.0.0.1:$NEW_PORT/" $NGINX_CONF
  sudo nginx -s reload

  echo "Stopping and removing old container: $OLD_COLOR"
  docker stop app_$OLD_COLOR || true
  docker rm app_$OLD_COLOR || true
EOF
