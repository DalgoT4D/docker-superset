# docker-superset
Superset for DDP: docker image build and container startup

sh build.sh
docker compose up
sh start-superset.sh

Row Level Security
- Filter clause is
    `coid =('{{current_blob()}}'::json->>'coid')::integer`

- Apply this filter to the roles specified in the filter definition. We will create a "Community Organizer" role for SNEHA

The base image for Superset 3 is 
- `apache/superset:3.1.0rc3` for x86
- `apache/superset:3.1.0-py310-arm` for ARM

The `Dockerfile` may need to be edited for the architecture you choose
