#!/bin/bash
# Usage: ./generate-make-t4d.sh "apache/superset:3.1.arm" "tech4dev/superset:0.41" "output_folder"

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <base_image> <output_image> <output_folder>"
    exit 1
fi

# Assign arguments to variables
BASE_IMAGE=$1
OUTPUT_IMAGE=$2
OUTPUT_FOLDER=$3
DOCKERFILE_TEMPLATE="Dockerfile.t4d.template"

# Check if the Dockerfile template exists
if [ ! -f "$DOCKERFILE_TEMPLATE" ]; then
    echo "Error: Dockerfile template ($DOCKERFILE_TEMPLATE) not found!"
    exit 1
fi

# Create the output folder if it doesn't exist
mkdir -p $OUTPUT_FOLDER

# Generate the Dockerfile from the template
sed "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" $DOCKERFILE_TEMPLATE > ${OUTPUT_FOLDER}/Dockerfile
echo "Dockerfile generated successfully in $OUTPUT_FOLDER!"

# Generate the build script
cat <<EOF > ${OUTPUT_FOLDER}/build-image.sh
#!/bin/bash
# Build the Docker image
docker build -t $OUTPUT_IMAGE .
echo "Docker image $OUTPUT_IMAGE built successfully!"
EOF

echo "Build script generated successfully in $OUTPUT_FOLDER!"

# Make the build script executable
chmod +x ${OUTPUT_FOLDER}/build-image.sh

# Generate the push script
cat <<EOF > ${OUTPUT_FOLDER}/push-image.sh
#!/bin/bash
# Push the Docker image to the registry
docker push $OUTPUT_IMAGE
echo "Docker image $OUTPUT_IMAGE pushed successfully!"
EOF

echo "Push script generated successfully in $OUTPUT_FOLDER!"

# Make the push script executable
chmod +x ${OUTPUT_FOLDER}/push-image.sh

echo "All files generated successfully in $OUTPUT_FOLDER!"