#!/bin/bash

# =======================
# Flutter Build Script
# =======================
# This script builds the Flutter app for different environments

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Flutter Pinky Shop Build Script${NC}"
echo ""

# Function to build for development
build_dev() {
  echo -e "${GREEN}🔨 Building for DEVELOPMENT...${NC}"
  flutter build apk --debug \
    --dart-define=ENVIRONMENT=development \
    --dart-define=API_URL=http://192.168.1.100:3000/api \
    --dart-define=API_KEY=dev-api-key-12345
  echo -e "${GREEN}✅ Development build complete!${NC}"
}

# Function to build for staging
build_staging() {
  echo -e "${GREEN}🔨 Building for STAGING...${NC}"
  flutter build apk --release \
    --dart-define=ENVIRONMENT=staging \
    --dart-define=API_URL=https://staging-api.pinkshop.com/api \
    --dart-define=API_KEY=staging-api-key-67890
  echo -e "${GREEN}✅ Staging build complete!${NC}"
}

# Function to build for production
build_prod() {
  echo -e "${GREEN}🔨 Building for PRODUCTION...${NC}"
  flutter build apk --release \
    --dart-define=ENVIRONMENT=production \
    --dart-define=API_URL=https://api.pinkshop.com/api \
    --dart-define=API_KEY=prod-api-key-secret
  echo -e "${GREEN}✅ Production build complete!${NC}"
}

# Check if environment argument is provided
if [ -z "$1" ]; then
  echo "Usage: ./build.sh [dev|staging|prod]"
  echo ""
  echo "Examples:"
  echo "  ./build.sh dev       # Build for development"
  echo "  ./build.sh staging   # Build for staging"
  echo "  ./build.sh prod      # Build for production"
  exit 1
fi

# Build based on argument
case "$1" in
  dev)
    build_dev
    ;;
  staging)
    build_staging
    ;;
  prod)
    build_prod
    ;;
  *)
    echo "Unknown environment: $1"
    echo "Usage: ./build.sh [dev|staging|prod]"
    exit 1
    ;;
esac
