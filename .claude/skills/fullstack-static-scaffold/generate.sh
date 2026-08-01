#!/bin/bash

# Fullstack Static Scaffold Generator
# Usage: generate.sh <project_name>

set -e

SKILL_DIR="$HOME/.claude/skills/fullstack-static-scaffold"
TEMPLATES_DIR="$SKILL_DIR/templates"

if [ -z "$1" ]; then
    PROJECT_NAME="app"
else
    PROJECT_NAME="$1"
fi

BACKEND_DIR="${PROJECT_NAME}_backend"
FRONTEND_DIR="${PROJECT_NAME}_frontend"

echo "Creating $PROJECT_NAME fullstack app..."

# Create directories
mkdir -p "$BACKEND_DIR"
mkdir -p "$FRONTEND_DIR"

# Copy and substitute backend templates (skip directories)
for file in "$TEMPLATES_DIR/backend"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        sed "s/PROJECT_NAME/$PROJECT_NAME/g" "$file" > "$BACKEND_DIR/$filename"
    fi
done

# Copy backend src directory
cp -r "$TEMPLATES_DIR/backend/src" "$BACKEND_DIR/"

# Copy and substitute frontend templates (skip directories)
for file in "$TEMPLATES_DIR/frontend"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        sed "s/PROJECT_NAME/$PROJECT_NAME/g" "$file" > "$FRONTEND_DIR/$filename"
    fi
done

# Copy frontend src and public directories
cp -r "$TEMPLATES_DIR/frontend/src" "$FRONTEND_DIR/"
if [ -d "$TEMPLATES_DIR/frontend/public" ]; then
    cp -r "$TEMPLATES_DIR/frontend/public" "$FRONTEND_DIR/"
fi

echo ""
echo "Created:"
echo "  - $BACKEND_DIR/"
echo "  - $FRONTEND_DIR/"
echo ""
echo "To run locally:"
echo "  cd $BACKEND_DIR && npm install && npm run dev"
echo "  cd $FRONTEND_DIR && npm install && npm run dev"
echo ""
echo "To build for production:"
echo "  cd $BACKEND_DIR"
echo "  npm install"
echo "  npm run build"
echo "  npm run build:ui"
echo "  npm run start"