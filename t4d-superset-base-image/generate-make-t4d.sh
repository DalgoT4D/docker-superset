#!/bin/bash
# Usage: ./generate-make-t4d.sh "apache/superset:4.0.1" "tech4dev/superset:4.0.1"
# Generates Dockerfile, build-image.sh, and push-image.sh in the current directory

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <base_image> <output_image>"
    echo "Example: $0 apache/superset:4.0.1 tech4dev/superset:4.0.1"
    echo ""
    echo "This script generates:"
    echo "  - Dockerfile (from template)"
    echo "  - build-image.sh (builds and pushes multi-platform image for amd64 and arm64)"
    exit 1
fi

# Assign arguments to variables
BASE_IMAGE=$1
OUTPUT_IMAGE=$2

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE_TEMPLATE="$SCRIPT_DIR/Dockerfile.t4d.template"

# Check if the Dockerfile template exists
if [ ! -f "$DOCKERFILE_TEMPLATE" ]; then
    echo "Error: Dockerfile template ($DOCKERFILE_TEMPLATE) not found!"
    exit 1
fi

# Generate the Dockerfile from the template
sed -e "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" \
    $DOCKERFILE_TEMPLATE > $SCRIPT_DIR/Dockerfile
echo "Dockerfile generated successfully!"

# Generate the build script
cat <<EOF > $SCRIPT_DIR/build-image.sh
#!/bin/bash
# Build multi-platform Docker image for linux/amd64 and linux/arm64
# Note: Multi-platform builds require --push (cannot load to local Docker)
docker buildx build --platform linux/amd64,linux/arm64 -t $OUTPUT_IMAGE --push .
if [ "\$?" -eq 0 ]; then
    echo "Docker image $OUTPUT_IMAGE built and pushed successfully for linux/amd64 and linux/arm64!"
else
    echo "Error: Docker image $OUTPUT_IMAGE failed to build."
    exit 1
fi
EOF

echo "build-image.sh generated successfully!"

# Make the build script executable
chmod +x $SCRIPT_DIR/build-image.sh

echo ""
echo "All files generated successfully in $SCRIPT_DIR"
echo "Next steps:"
echo "  1. cd $SCRIPT_DIR"
echo "  2. ./build-image.sh"
