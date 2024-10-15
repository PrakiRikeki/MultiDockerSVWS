#!/bin/bash

# Docker Image Name
IMAGE_NAME="svwsnrw/svws-server:latest"

# Update the Docker image
echo "Updating Docker image..."
docker pull $IMAGE_NAME

# Find all running containers using the specific image
CONTAINER_IDS=$(docker ps -q --filter ancestor=$IMAGE_NAME)

# Stop and remove each container
for id in $CONTAINER_IDS; do
    # Retrieve the current port mapping and container name
    PORT=$(docker port $id 8443/tcp | sed 's/.*://')
    NAME=$(docker inspect --format='{{.Name}}' $id | sed 's/\///')

    echo "Stopping and removing container $NAME..."
    docker stop $id
    docker rm $id

    # Start a new container with the same port mapping and name
    echo "Starting new container $NAME on port $PORT..."
    docker run -d --name $NAME -p $PORT:8443 $IMAGE_NAME
done

echo "All containers have been updated."