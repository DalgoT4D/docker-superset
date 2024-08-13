#!/bin/bash
#eg-> ./generate_dockerFiles.sh "client1" "prod" "apache/superset:3.1.3" "tech4dev/superset3:0.2" "./output/client1-prod"
# Ensure the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <client_name> <project_or_env> <base_image> <superset_image> <output_directory>"
    exit 1
fi

# Assign input parameters to variables
CLIENT_NAME=$1
PROJECT_OR_ENV=$2
BASE_IMAGE=$3
SUPERSET_IMAGE=$4
OUTPUT_DIR=$5

# Define a unique container name using the client name and project/environment name
SUPERSET_CONTAINER_NAME="superset-${CLIENT_NAME}-${PROJECT_OR_ENV}"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Generate the Dockerfile by replacing placeholders in Dockerfile.template
sed "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" Dockerfile.template > $OUTPUT_DIR/Dockerfile

# Customize the Dockerfile to copy the assets directory
echo "COPY assets/ /app/" >> $OUTPUT_DIR/Dockerfile

# Generate the docker-compose.yml by replacing placeholders in docker-compose.yml.template
sed -e "s|{{SUPERSET_IMAGE}}|$SUPERSET_IMAGE|g" \
    -e "s|{{SUPERSET_CONTAINER_NAME}}|$SUPERSET_CONTAINER_NAME|g" \
    docker-compose.yml.template > $OUTPUT_DIR/docker-compose.yml

# Notify the user of successful generation
echo "Generated Dockerfile and docker-compose.yml for client $CLIENT_NAME, project $PROJECT_OR_ENV in $OUTPUT_DIR"
