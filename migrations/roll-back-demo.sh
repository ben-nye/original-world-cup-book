#!/bin/bash
set -euo pipefail

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║                                          ║"
echo "║       [db] Rolling Back Demo Data        ║"
echo "║                                          ║"
echo "║  This removes the demo changesets that   ║"
echo "║  ship with the template. Once done,      ║"
echo "║  delete the demo files and start fresh.  ║"
echo "║                                          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 2 changesets in routines (trigger + function) and 1 in schema (users table)
echo "Rolling back demo changesets..."
docker-compose -f docker-compose.yml -f docker-compose.migrate.yml run liquibase \
  --changeLogFile=changelog.xml rollbackCount 3

echo ""
echo "Done. You can now delete the following demo files:"
echo "  • migrations/schema/001_create_users.yml"
echo "  • migrations/routines/001_update_timestamp_fn.yml"
echo "  • migrations/routines/002_add_audit_trigger.yml"
echo ""
echo "Then add your own migrations starting at 001_."