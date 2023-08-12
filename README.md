# docker-superset
Superset for DDP: docker image build and container startup

sh build.sh
docker compose up
sh start-superset.sh

Row Level Security
- Filter clause is
    `coid =('{{current_blob()}}'::json->>'coid')::integer`

- Apply this filter to the roles specified in the filter definition. We will create a "Community Organizer" role for SNEHA
- 