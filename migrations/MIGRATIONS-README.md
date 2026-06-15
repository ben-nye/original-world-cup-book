# Database Migrations

This project uses [Liquibase](https://www.liquibase.org/) to manage database schema changes. Migrations are run manually via Docker Compose and tracked in the database so they never run twice.

---

## How It Works

Liquibase keeps a `DATABASECHANGELOG` table in your database. Every time you run migrations, it checks this table and only runs changesets it hasn't seen before. This means you can safely run migrations multiple times without duplicating changes.

---

## Folder Structure

```
migrations/
├── changelog.xml        ← Master file. Points Liquibase at schema/ and routines/.
├── schema/              ← Structural changes. Tables, indexes, constraints.
│   └── 001_*.yml        Run once. Never rerun.
└── routines/            ← Mutable objects. Functions, triggers, views.
    └── 001_*.yml        Rerun automatically when the file changes (runOnChange: true).
```

### Why two folders?

**Schema** changes are permanent and destructive — dropping a table loses data. Liquibase runs these once and never touches them again.

**Routines** are redefinable — a stored function or trigger can be replaced safely. Liquibase reruns these whenever the file changes, so you can update a function by just editing its file.

---

## Naming Convention

Files are prefixed with a zero-padded number to control run order:

```
001_create_users.yml
002_add_orders.yml
```

Always increment — never reuse or reorder existing numbers.

---

## Changeset Author

The `author` field in each changeset pulls from `TEAM_NAME` in your `.env`. This is used by Liquibase to uniquely identify each changeset alongside its `id`.

---

## Running Migrations

Make sure your database is running first:

```bash
docker-compose up -d
```

Then run migrations:

```bash
docker-compose -f docker-compose.yml -f docker-compose.migrate.yml up liquibase
```

---

## Rolling Back

Each changeset includes a `rollback` block. To roll back the last migration:

```bash
docker-compose -f docker-compose.yml -f docker-compose.migrate.yml run liquibase \
  --changeLogFile=changelog.xml rollbackCount 1
```

---

## Adding a New Migration

1. Create a new `.yml` file in `schema/` or `routines/` with the next number in sequence.
2. Follow the existing changeset format — include `id`, `author`, `comment`, `changes`, and `rollback`.
3. Run migrations as above. Liquibase will pick up the new file automatically.