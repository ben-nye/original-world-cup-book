# Postgres Setup

This module runs a Postgres database via Docker Compose, with data persisted locally so it survives container restarts and rebuilds.

## Files

- `docker-compose.yml` — defines the Postgres service
- `.env.example` — template for required environment variables
- `.env` — your actual credentials (not committed, see `.gitignore`)
- `pgdata/` — local folder where Postgres stores its data (auto-created, not committed)

## Setup

1. Copy `.env.example` to `.env`:
   ```
   cp .env.example .env
   ```
2. Edit `.env` and set your own values for `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB`.
3. Start the database:
   ```
   docker-compose up -d
   ```
4. Postgres will be available on `localhost:5432`.

## Notes

- Data is stored in `./pgdata` on your machine. Deleting this folder wipes the database.
- Postgres only runs its initial setup (creating the user/db from `.env`) the first time `pgdata/` is empty. If you change credentials later, delete `pgdata/` and restart to reinitialize.
- To stop the database: `docker-compose down`