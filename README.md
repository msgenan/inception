*This project has been created as part of the 42 curriculum by mugenan.*

# Inception

## Description

Inception is a system administration project that sets up a small, secure web infrastructure using Docker and Docker Compose. The goal is to deploy a WordPress website backed by MariaDB, served through NGINX over TLS, with each service running in its own dedicated container built from a custom Dockerfile — no pre-built images from Docker Hub (aside from the Alpine/Debian base).

The infrastructure consists of:
- **NGINX** — the only entrypoint to the infrastructure, exposed on port 443 with TLSv1.2/TLSv1.3.
- **WordPress + PHP-FPM** — the application layer, automatically installed and configured via WP-CLI.
- **MariaDB** — the database layer, storing WordPress data.

Data persistence is handled through Docker named volumes stored on the host under `/home/mugenan/data`, and all services communicate over a dedicated Docker bridge network.

## Instructions

### Requirements
- A Linux virtual machine (Debian 12 "bookworm" recommended)
- Docker and Docker Compose plugin installed
- `make` installed

### Setup
1. Clone this repository onto your VM.
2. Create the `secrets/` folder at the project root with the following files (git-ignored, not included in the repo):
   - `db_password.txt`
   - `db_root_password.txt`
   - `credentials.txt` (containing `WP_ADMIN_PASSWORD=...` and `WP_USER_PASSWORD=...`)
3. Create `srcs/.env` with the required variables (domain name, database name/user, WordPress usernames/emails).
4. Add `127.0.0.1 mugenan.42.fr` (or your VM's IP) to your host machine's `/etc/hosts` file.
5. Run: make
6. Visit `https://mugenan.42.fr` in your browser.

See `USER_DOC.md` and `DEV_DOC.md` for detailed usage and development instructions.

## Project Description & Design Choices

### Virtual Machines vs Docker
A virtual machine virtualizes an entire hardware stack, including its own kernel, which makes it heavier to run and slower to start. Docker containers share the host's kernel and only isolate the process, filesystem, and network at the OS level, making them much lighter and faster to start and stop. This project uses one VM to host Docker itself (as required by the subject), and Docker to isolate each service (NGINX, WordPress, MariaDB) without the overhead of running three separate full virtual machines.

### Secrets vs Environment Variables
Environment variables passed through `.env` are visible via `docker inspect` and can leak into logs or crash reports, so they are only used for non-sensitive configuration (domain name, database name, usernames). Docker secrets, on the other hand, mount sensitive values (passwords) as read-only files inside `/run/secrets/` at runtime, without ever exposing them as inspectable environment variables. This project stores all passwords as Docker secrets and reads them from disk inside each initialization script.

### Docker Network vs Host Network
Using `network: host` would remove all network isolation between the container and the host machine, exposing every port a service opens directly to the host and bypassing Docker's internal DNS resolution between containers. Instead, this project defines a custom bridge network (`inception_network`) where each container can reach the others by service name (e.g., WordPress connects to `mariadb:3306`), and only NGINX's port 443 is published to the host.

### Docker Volumes vs Bind Mounts
Bind mounts tie a container directly to a specific path on the host filesystem, which is fragile across environments and depends on host-specific permissions. Named volumes are managed by Docker itself and are more portable. This project uses named volumes (`mariadb_data`, `wordpress_data`) configured with a local bind-mount driver option so that their data physically lives under `/home/mugenan/data`, satisfying both the "named volume" requirement and the "data must be visible on the host" requirement.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WP-CLI documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage
AI (Claude) was used throughout this project as a learning and debugging assistant:
- Explaining Docker concepts (PID 1, named volumes vs bind mounts, secrets vs environment variables) before implementation.
- Reviewing and debugging Dockerfiles and initialization scripts (e.g., diagnosing why MariaDB's data directory was pre-populated at build time, and why PHP-FPM required a TCP listener instead of a Unix socket).
- Assisting with VirtualBox/VM networking troubleshooting (bridged adapter instability, NAT + port forwarding setup).
- Reviewing the Makefile structure and the docker-compose.yml configuration.

All AI-suggested code was tested, understood, and manually verified (via container logs, database queries, and browser testing) before being committed.
