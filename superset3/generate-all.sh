#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <base_image> <output_image>"
    exit 1
fi

# Assign arguments to variables
BASE_IMAGE=$1
OUTPUT_IMAGE=$2

# Generate the Dockerfile
cat <<EOF > Dockerfile
# Starting with the base image
FROM $BASE_IMAGE

# Switching to root to install the required packages
USER root

# Upgrade pip
RUN pip install --upgrade pip

# Install the necessary Python packages
RUN pip install --no-cache gevent psycopg2-binary redis celery flower pytz
RUN pip install --upgrade urllib3 requests botocore boto3 authlib python-dotenv
RUN pip install --upgrade sqlalchemy-bigquery pandas_gbq google-auth

# Switching back to using the 'superset' user
USER superset
EOF

echo "Dockerfile generated successfully!"

# Generate the build script
cat <<EOF > build-image.sh
#!/bin/bash

# Build the Docker image
docker build -t $OUTPUT_IMAGE .

echo "Docker image $OUTPUT_IMAGE built successfully!"
EOF

echo "Build script generated successfully!"

# Make the build script executable
chmod +x build-image.sh

# Generate the push script
cat <<EOF > push-image.sh
#!/bin/bash

# Push the Docker image to the registry
docker push $OUTPUT_IMAGE

echo "Docker image $OUTPUT_IMAGE pushed successfully!"
EOF

echo "Push script generated successfully!"

# Make the push script executable
chmod +x push-image.sh

echo "All files generated successfully!"
