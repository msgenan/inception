# Developer Documentation

This document explains how to set up, build, and maintain the Inception infrastructure from a developer's perspective.

## Setting Up the Environment From Scratch

### Prerequisites
- A virtual machine running Debian 12 "bookworm" (or Alpine, if you adapt the Dockerfiles)
- Docker Engine and the Docker Compose plugin installed
- `make` installed
- Git

### Repository Structure
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/ (git-ignored, created manually)
│ ├── db_password.txt
│ ├── db_root_password.txt
│ └── credentials.txt
└── srcs/
├── docker-compose.yml
├── .env (git-ignored, created manually)
└── requirements/
├── mariadb/
│ ├── Dockerfile
│ ├── conf/my.cnf
│ └── tools/init_db.sh
├── wordpress/
│ ├── Dockerfile
│ └── tools/init_wp.sh
└── nginx/
├── Dockerfile
├── conf/nginx.conf
└── tools/init_nginx.sh

### Configuration Files to Create

Since `secrets/` and `srcs/.env` are excluded from version control (see `.gitignore`), they must be created manually before the first run.

**`srcs/.env`**:
DOMAIN_NAME=mugenan.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
WP_ADMIN_USER=mugenan_boss
WP_ADMIN_EMAIL=mugenan@example.com
WP_USER=mugenan_editor
WP_USER_EMAIL=editor@example.com

**`secrets/db_root_password.txt`**: a single line containing the MariaDB root password.

**`secrets/db_password.txt`**: a single line containing the password for `MYSQL_USER`.

**`secrets/credentials.txt`**:
WP_ADMIN_PASSWORD=<password>
WP_USER_PASSWORD=<password>

Also add `<your_username>.42.fr` to `/etc/hosts` on the machine you'll browse from, pointing to the VM's IP (or `127.0.0.1` if using NAT port forwarding on port 443).

## Building and Launching the Project

From the project root: make

This target creates the host directories for the named volumes (if missing) and runs `docker compose -f srcs/docker-compose.yml up -d --build`, which builds all three custom images (`mariadb:inception`, `wordpress:inception`, `nginx:inception`) and starts the containers.

Each service's Dockerfile builds from `debian:bookworm` and installs only the packages required for that service (no ready-made application images are pulled). Each container's entrypoint script implements a "first run vs. subsequent run" pattern: on first start it initializes its data (database creation, WordPress installation, TLS certificate generation), and on subsequent restarts it skips initialization and directly launches the service in the foreground as PID 1 (`exec mariadbd`, `exec php-fpm8.2 -F`, `exec nginx -g "daemon off;"`), which is required for Docker's `restart: on-failure` policy to work correctly.

## Managing Containers and Volumes

| Command | Purpose |
|---|---|
| `docker compose -f srcs/docker-compose.yml ps` | List container status |
| `docker compose -f srcs/docker-compose.yml logs <service>` | View logs for a specific service |
| `docker exec -it <container> bash` | Open a shell inside a running container |
| `docker volume ls` | List Docker volumes |
| `docker volume inspect srcs_mariadb_data` | Inspect a volume's configuration (mountpoint, bind options) |
| `make down` | Stop and remove containers (volumes persist) |
| `make fclean` | Remove containers and delete all persistent data |

To rebuild a single service after modifying its Dockerfile or scripts:
docker compose -f srcs/docker-compose.yml build <service>
docker compose -f srcs/docker-compose.yml up -d <service>

## Where Project Data Is Stored and How It Persists

Two Docker named volumes are defined in `docker-compose.yml`, each configured with a `local` driver using bind-mount options so that their actual data lives on the host filesystem under `/home/<login>/data`:

- `mariadb_data` → mounted at `/var/lib/mysql` inside the `mariadb` container, physically stored at `/home/mugenan/data/mariadb` on the host.
- `wordpress_data` → mounted at `/var/www/html` inside both the `wordpress` and `nginx` containers, physically stored at `/home/mugenan/data/wordpress` on the host.

Because these are named volumes (not bind mounts declared directly in the container's `volumes:` section as a host path), Docker manages their lifecycle: they survive container removal (`docker compose down`) and are only deleted explicitly (`docker compose down -v`, or `make fclean`, which removes the underlying host directories directly).

Secrets are mounted read-only at runtime under `/run/secrets/<secret_name>` inside each container and are never written to the image or exposed as environment variables.
