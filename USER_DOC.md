# User Documentation

This document explains how to use the Inception infrastructure as an end user or administrator, without going into the technical implementation details (see `DEV_DOC.md` for that).

## What Services Does This Stack Provide?

- **A WordPress website**, reachable at `https://mugenan.42.fr`
- **A WordPress admin panel**, reachable at `https://mugenan.42.fr/wp-admin`
- **A MariaDB database**, storing all WordPress content (not directly accessible from outside the infrastructure)

## Starting and Stopping the Project

From the project root directory:

| Command | Effect |
|---|---|
| `make` | Builds (if needed) and starts all containers in the background |
| `make stop` | Stops all containers without deleting them |
| `make start` | Restarts previously stopped containers |
| `make down` | Stops and removes all containers and the network (data is preserved) |
| `make restart` | Equivalent to `make down` followed by `make` |
| `make clean` | Stops everything and removes unused Docker images/cache |
| `make fclean` | `make clean` plus deletion of all persistent data (database and WordPress files) |
| `make re` | `make fclean` followed by `make` — a full reset |

## Accessing the Website and the Admin Panel

1. Make sure your machine's `/etc/hosts` file (or equivalent) resolves `mugenan.42.fr` to the correct IP address (`127.0.0.1` if using port forwarding, or the VM's direct IP if using a bridged network).
2. Open a browser and visit `https://mugenan.42.fr`.
3. Your browser will show a security warning because the site uses a self-signed TLS certificate — this is expected. Click "Advanced" and proceed to the site.
4. To access the admin panel, visit `https://mugenan.42.fr/wp-admin` and log in with the administrator credentials (see below).

## Locating and Managing Credentials

All credentials are stored outside of the Git repository, under the `secrets/` folder at the project root:

- `secrets/db_root_password.txt` — MariaDB root password
- `secrets/db_password.txt` — password for the WordPress database user
- `secrets/credentials.txt` — WordPress admin and secondary user passwords

Non-sensitive configuration (domain name, database name, usernames, emails) is stored in `srcs/.env`.

To change a password, edit the relevant file in `secrets/` and run `make re` to rebuild the infrastructure from scratch with the new values.

## Checking That Services Are Running Correctly

From the project root: