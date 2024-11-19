#!/bin/bash
# Usage example:
# ./generate_dockerFiles.sh "client1" "prod" "base_image_name" "8088" "5555" "output_directory"

# Ensure the correct number of arguments is provided
if [ "$#" -ne 9 ]; then
    echo "Usage: $0 <client_name> <project_or_env> <superset_baseImage> <superset_version> <output_image_tag> <container_port> <celery_flower_port> <arch_type> <output_dir>"
    echo "Usage: $0 "demo_ngo" "prod" "tech4dev/superset:4.0.1" "3 or4" "0.1/latest/0.1-arm" "8088" "5555" "linux/amd64 or linux/arm64"  "../../demo_ngo""
    exit 1
fi

# Assign input parameters to variables
CLIENT_NAME=$1
PROJECT_OR_ENV=$2
BASE_IMAGE=$3
SUPERSET_VERSION=$4
OUTPUT_IMAGE_TAG=$5
CONTAINER_PORT=$6
CELERY_FLOWER_PORT=$7
ARCH_TYPE=$8
OUTPUT_DIR=$9

OUTPUT_BASE_IMAGE="t4d/superset-${CLIENT_NAME}-${PROJECT_OR_ENV}-${SUPERSET_VERSION}:${OUTPUT_IMAGE_TAG}" 

# Function to find the next available port starting from a given port number
find_available_port() {
    local port=$1
    local max_attempts=100 # Maximum number of attempts to find an available port
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        # Check if the port is in use
        if ! ss -tuln | grep -q ":$port\b"; then
            echo $port
            return 0
        fi
        # Increment port and attempt counter
        port=$((port + 1))
        attempt=$((attempt + 1))
    done

    echo "Failed to find an available port after $max_attempts attempts." >&2
    exit 1
}

# Check and find available ports for both CONTAINER_PORT and CELERY_FLOWER_PORT
CONTAINER_PORT=$(find_available_port $CONTAINER_PORT)
CELERY_FLOWER_PORT=$(find_available_port $CELERY_FLOWER_PORT)

# Define a unique container name using the client name and project/environment name
SUPERSET_CONTAINER_NAME="${CLIENT_NAME}-${PROJECT_OR_ENV}-${SUPERSET_VERSION}"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/assets
cp -R assets/. $OUTPUT_DIR/assets
cp -R host_data/. $OUTPUT_DIR/host_data
cp superset.env.example $OUTPUT_DIR/superset.env

# Generate the Dockerfile by replacing placeholders in DockerFile.client.template
sed -e "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" \
    -e "s|{{ARCH_TYPE}}|$ARCH_TYPE|g" \
    Dockerfile.client.template > "$OUTPUT_DIR/Dockerfile"

# Generate the docker-compose.yml by replacing placeholders in docker-compose.yml.template
sed -e "s|{{OUTPUT_BASE_IMAGE}}|$OUTPUT_BASE_IMAGE|g" \
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
IMAGE_NAME=${OUTPUT_BASE_IMAGE}  # Dynamic image name

# Build the Docker image
echo "Building Docker image: \$IMAGE_NAME"
if docker build --tag \$IMAGE_NAME .; then
    echo "Docker image built successfully: \$IMAGE_NAME"
else
    echo "Error: Failed to build Docker image: \$IMAGE_NAME"
    exit 1
fi
EOF

# Make the build script executable
chmod +x $BUILD_SCRIPT_PATH

# Generate the push script
PUSH_SCRIPT_PATH="$OUTPUT_DIR/push.sh"
cat <<EOF > $PUSH_SCRIPT_PATH
#!/bin/bash

# Define variables
IMAGE_NAME=${OUTPUT_BASE_IMAGE}  # Dynamic image name

# Push the Docker image
echo "Pushing Docker image: \$IMAGE_NAME"
if docker push \$IMAGE_NAME; then
    echo "Docker image pushed successfully: \$IMAGE_NAME"
else
    echo "Error: Failed to push Docker image: \$IMAGE_NAME"
    exit 1
fi
EOF

# Make the push script executable
chmod +x $PUSH_SCRIPT_PATH

# Notify the user of successful generation
echo "Generated Dockerfile, docker-compose.yml, setup script, build script, and push script for client $CLIENT_NAME, project $PROJECT_OR_ENV in $OUTPUT_DIR"
echo "Assigned ports: Superset UI - $CONTAINER_PORT, Celery Flower - $CELERY_FLOWER_PORT"
echo "Setup script generated at: $SCRIPT_PATH"
echo "Build script generated at: $BUILD_SCRIPT_PATH"
echo "Push script generated at: $PUSH_SCRIPT_PATH"

exit 0 # Explicitly exit with status 0 to indicate success
