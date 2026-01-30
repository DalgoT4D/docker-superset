# docker-superset

Superset for DDP: Docker image build and container startup for Dalgo.

## Project Structure

```
docker-superset/
└── t4d-superset-base-image/
    ├── assets/
    │   └── superset/
    │       ├── jinja_context.py      # Custom Jinja functions (current_blob, etc.)
    │       ├── templates/            # Custom HTML templates
    │       └── daos/                 # Custom data access objects
    ├── Dockerfile.t4d.template       # Docker template file
    └── generate-make-t4d.sh          # Script to generate Dockerfile and build script
```

## Building the T4D Superset Base Image

The `t4d-superset-base-image` folder contains everything needed to build the Tech4Dev Superset base image.

### What the Template Does

The `Dockerfile.t4d.template` takes a base Apache Superset image and:
1. Installs required system packages (chromium-driver, build tools, etc.)
2. Installs Python packages (psycopg2, Authlib, Playwright, etc.)
3. Copies custom assets:
   - `jinja_context.py` - Provides custom Jinja functions like `current_blob()` for Row Level Security
   - `templates/` - Custom HTML templates for UI modifications
   - `daos/` - Custom data access objects

### Generate and Build

```bash
cd t4d-superset-base-image

# Generate Dockerfile and build script
sh generate-make-t4d.sh <base_image> <output_image>

# Example:
sh generate-make-t4d.sh "apache/superset:4.0.1" "tech4dev/superset:4.0.1"
```

This generates:
- `Dockerfile` - Ready-to-build Dockerfile from the template
- `build-image.sh` - Script to build and push the multi-architecture image

### Building Multi-Architecture Images

The `build-image.sh` script uses `docker buildx` to create images for both `linux/amd64` and `linux/arm64` architectures.

**Why multi-arch images must be pushed (cannot be loaded locally):**

Docker buildx creates a manifest list containing images for multiple platforms. This manifest format is only supported in registries - it cannot be loaded into the local Docker daemon because the local daemon can only hold a single-platform image. The `--push` flag is required for multi-platform builds.

**If you need to load the image locally for testing:**

Use the `--load` flag instead and build for your machine's architecture only:

```bash
# For ARM64 (Apple Silicon Macs)
docker buildx build --platform linux/arm64 -t tech4dev/superset:4.0.1 --load .

# For AMD64 (Intel/AMD machines)
docker buildx build --platform linux/amd64 -t tech4dev/superset:4.0.1 --load .
```

## Row Level Security

The custom `jinja_context.py` provides the `current_blob()` function for implementing Row Level Security.

**Filter clause:**
```sql
coid = ('{{current_blob()}}'::json->>'coid')::integer
```

Apply this filter to the roles specified in the filter definition. For example, create a "Community Organizer" role for SNEHA.

## Kubernetes vs Docker Compose

This setup of creating a single base image is designed for our **Kubernetes deployment**. The base image is pushed to a registry and pulled by Kubernetes pods.

**If you want to run Superset using Docker Compose**, see the branch:
[setup-superset-using-docker-compose-pre-kubernetes](https://github.com/DalgoT4D/docker-superset/tree/setup-superset-using-docker-compose-pre-kubernetes)

## Documentation

For detailed documentation on how we are customizing Superset for Dalgo, read:
[Link to the documentation](https://docs.google.com/document/d/1l24tphe8iv1dQkIZ4s4xQIQu1vCB33YLCrjwSvWj5wA/edit?usp=sharing)
