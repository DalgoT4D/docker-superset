#!/bin/bash
# Usage example:
# ./generate_dockerFiles.sh "client1" "prod" "base_image_name" "8088" "5555" "output_directory"

# Ensure the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <client_name> <project_or_env> <base_image> <container_port> <celery_flower_port> <output_dir>"
    exit 1
fi

# Assign input parameters to variables
CLIENT_NAME=$1
PROJECT_OR_ENV=$2
BASE_IMAGE=$3
CONTAINER_PORT=$4
CELERY_FLOWER_PORT=$5
OUTPUT_DIR=$6

# Function to find the next available port starting from a given port number
find_available_port() {
    local port=$1
    local max_attempts=100 # Maximum number of attempts to find an available port
    local attempt=0
    while lsof -i :$port -sTCP:LISTEN >/dev/null 2>&1; do
        port=$((port + 1))
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
            echo "Failed to find an available port after $max_attempts attempts." >&2
            exit 1
        fi
    done
    echo $port
}

# Check and find available ports for both CONTAINER_PORT and CELERY_FLOWER_PORT
CONTAINER_PORT=$(find_available_port $CONTAINER_PORT)
CELERY_FLOWER_PORT=$(find_available_port $CELERY_FLOWER_PORT)

# Define a unique container name using the client name and project/environment name
SUPERSET_CONTAINER_NAME="${CLIENT_NAME}-${PROJECT_OR_ENV}"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/assets
cp -R assets/. $OUTPUT_DIR/assets
cp -R host_data/. $OUTPUT_DIR/host_data
cp superset.env.example $OUTPUT_DIR/superset.env

# Generate the Dockerfile by replacing placeholders in DockerFile.client.template
sed "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" Dockerfile.client.template > $OUTPUT_DIR/Dockerfile

# Generate the docker-compose.yml by replacing placeholders in docker-compose.yml.template
sed -e "s|{{SUPERSET_IMAGE}}|$BASE_IMAGE|g" \
    -e "s|{{SUPERSET_CONTAINER_NAME}}|$SUPERSET_CONTAINER_NAME|g" \
    -e "s|{{CONTAINER_PORT}}|$CONTAINER_PORT|g" \
    -e "s|{{CELERY_FLOWER_PORT}}|$CELERY_FLOWER_PORT|g" \
    docker-compose.yml.template > $OUTPUT_DIR/docker-compose.yml

# Generate the shell script with the required commands
SCRIPT_PATH="$OUTPUT_DIR/start-superset.sh"
cat <<EOF > $SCRIPT_PATH
#!/bin/sh

set -o allexport
source superset.env
set +o allexport

docker exec -it superset-${SUPERSET_CONTAINER_NAME} superset db upgrade
docker exec -it superset-${SUPERSET_CONTAINER_NAME} superset fab create-admin --username \${SUPERSET_ADMIN_USERNAME} --password \${SUPERSET_ADMIN_PASSWORD} --firstname Superset --lastname Admin --email \${SUPERSET_ADMIN_EMAIL}
docker exec -it superset-${SUPERSET_CONTAINER_NAME} superset init
EOF

# Make the script executable
chmod +x $SCRIPT_PATH

# Generate the build script
BUILD_SCRIPT_PATH="$OUTPUT_DIR/build.sh"
cat <<EOF > $BUILD_SCRIPT_PATH
#!/bin/bash

# Ensure the script stops if any command fails
set -e

# Define variables
IMAGE_NAME="t4d-${CLIENT_NAME}-${PROJECT_OR_ENV}"  # Dynamic image name

# Build the Docker image
echo "Building Docker image: \$IMAGE_NAME"
docker build --tag \$IMAGE_NAME .

echo "Docker image built successfully: \$IMAGE_NAME"
EOF

# Make the build script executable
chmod +x $BUILD_SCRIPT_PATH

# Notify the user of successful generation
echo "Generated Dockerfile, docker-compose.yml, setup script, and build script for client $CLIENT_NAME, project $PROJECT_OR_ENV in $OUTPUT_DIR"
echo "Assigned ports: Superset UI - $CONTAINER_PORT, Celery Flower - $CELERY_FLOWER_PORT"
echo "Setup script generated at: $SCRIPT_PATH"
echo "Build script generated at: $BUILD_SCRIPT_PATH"

exit 0 # Explicitly exit with status 0 to indicate success
