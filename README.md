# docker-superset
Superset for DDP: docker image build and container startup

```
sh build.sh
docker compose up
sh start-superset.sh
```

### Row Level Security
- Filter clause is
    `coid =('{{current_blob()}}'::json->>'coid')::integer`

- Apply this filter to the roles specified in the filter definition. We will create a "Community Organizer" role for SNEHA

### Docker image
The base image for Superset 3 is 
- `apache/superset:3.1.0rc3` for x86
- `apache/superset:3.1.0-py310-arm` for ARM

The `Dockerfile` may need to be edited for the architecture you choose

### Static assets
Superset will serve static assets at `https://<superset_url>/static/path/to/file`

if the `file` is available at `/app/superset/static/path/to/file` within the Docker container.

### GENERATE SUPERSET FOR CLIENTS USING TEMPLATES
- Inside gensuperset there are two folders
   a. make-t4d
   b. make-client

 # A. make-t4d 
 # Note: This scirpt will only be used once or when we update the docker image. Once the image is pushed to dockerhub, then the dockerfile in make-client will fetch this image and we can create different supersets for different clients. 
- The make-t4d contains the the script to make dockerfile, build.sh and push.sh script.
- This Dockerfile pull the base apache/supserst:<version> image, and install the required python packages, and creates a docker image which will be the base image for the client specific Dockerfile in make-client folder.
  
-  command: sh generate-make-t4d.sh "apache/superset:<version><architecture>" "<output_base_image>" "<output_folder>"

#  B. make-client
- Here the generate script will generate a full fleged superset folder that is customised specifically to the client.
- The dockerfile uses the base image created and pushed to docker hub in the above step.
- The build.sh script creates a new image that will remain on the system, and will be used by docker-compose.yml file to run the container.

- command:  sh generate-make-client.sh <client_name> <project_or_env> <base_image> <container_port> <celery_flower_port> <output_dir>

For detail documentation on how we are customizing superset for Dalgo-> read 
[Link_to_the_documentation](https://docs.google.com/document/d/1l24tphe8iv1dQkIZ4s4xQIQu1vCB33YLCrjwSvWj5wA/edit?usp=sharing)
