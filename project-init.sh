#!/bin/bash
set -euo pipefail

echo "╔══════════════════════════════════════════╗"
echo "║                                          ║"
echo "║          [db] DB Project Setup           ║"
echo "║                                          ║"
echo "║    Clone → Configure → Push. Let's go.  ║"
echo "║                                          ║"
echo "╚══════════════════════════════════════════╝"
echo "You'll need:"
echo "  • A project name"
echo "  • A GitHub repo URL"
echo "  • A superuser password"
echo "  • An app database user password"
echo ""

# Gather inputs
read -p "Project name (snake_case e.g. my_project): " PROJECT_NAME
read -p "New GitHub repo URL: " REPO_URL
read -sp "Postgres superuser password (the all-powerful one, keep it safe): " POSTGRES_PASSWORD
echo
read -sp "App user password (the everyday one your app will use): " DB_PASSWORD
echo
echo ""

# Seed .env from .env.example, substituting project name and passwords
echo "Seeding your .env — no more placeholder values..."
sed "s/world_cup_book/${PROJECT_NAME}/g" .env.example > .env

# Inject passwords into .env
sed -i '' "s/supersecretpassword/${POSTGRES_PASSWORD}/g" .env
sed -i '' "s/apppassword/${DB_PASSWORD}/g" .env

echo ".env is ready. Don't commit it — that's what .gitignore is for."
echo ""

# Reset git history — fresh start, no baggage
echo "Wiping git history. The past is gone, the future is yours..."
rm -rf .git
git init
git add .
git commit -m "Initial commit from postgres template"

# Point to new remote and push
echo "Pushing to your new repo..."
git remote add origin $REPO_URL
git branch -M main
git push -u origin main

echo ""
echo "All done! '${PROJECT_NAME}' is live on GitHub and ready to build."