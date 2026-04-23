#!/bin/bash

# =======================
# Flutter Build and Deploy Script
# =======================
# This script builds Flutter artifacts and can deploy web to Firebase Hosting.

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Flutter Pinky Shop Build Script${NC}"
echo ""

# Environment-specific defaults (can be overridden via shell env vars)
DEV_API_URL="${DEV_API_URL:-http://192.168.1.100:3000/api}"
STAGING_API_URL="${STAGING_API_URL:-https://staging-api.pinkshop.com/api}"
PROD_API_URL="${PROD_API_URL:-https://api.pinkshop.com/api}"

DEV_API_KEY="${DEV_API_KEY:-dev-api-key-12345}"
STAGING_API_KEY="${STAGING_API_KEY:-staging-api-key-67890}"
PROD_API_KEY="${PROD_API_KEY:-prod-api-key-secret}"

usage() {
  echo "Usage: ./build.sh [dev|staging|prod] [apk|web|deploy]"
  echo ""
  echo "Examples:"
  echo "  ./build.sh dev               # Build debug APK for development"
  echo "  ./build.sh staging apk       # Build release APK for staging"
  echo "  ./build.sh prod web          # Build production web bundle"
  echo "  ./build.sh prod deploy       # Build + deploy production web to Firebase Hosting"
}

get_env_settings() {
  case "$1" in
    dev)
      ENVIRONMENT="development"
      API_URL="$DEV_API_URL"
      API_KEY="$DEV_API_KEY"
      ;;
    staging)
      ENVIRONMENT="staging"
      API_URL="$STAGING_API_URL"
      API_KEY="$STAGING_API_KEY"
      ;;
    prod)
      ENVIRONMENT="production"
      API_URL="$PROD_API_URL"
      API_KEY="$PROD_API_KEY"
      ;;
    *)
      echo -e "${RED}Unknown environment: $1${NC}"
      usage
      exit 1
      ;;
  esac
}

build_apk() {
  local env_label
  env_label="$(echo "$ENVIRONMENT" | tr '[:lower:]' '[:upper:]')"
  local build_mode="--release"
  if [ "$ENVIRONMENT" = "development" ]; then
    build_mode="--debug"
  fi

  echo -e "${GREEN}🔨 Building APK for ${env_label}...${NC}"
  flutter build apk "$build_mode" \
    --dart-define=ENVIRONMENT="$ENVIRONMENT" \
    --dart-define=API_BASE_URL="$API_URL" \
    --dart-define=API_KEY="$API_KEY"
  echo -e "${GREEN}✅ APK build complete!${NC}"
}

build_web() {
  local env_label
  env_label="$(echo "$ENVIRONMENT" | tr '[:lower:]' '[:upper:]')"

  echo -e "${GREEN}🔨 Building WEB for ${env_label}...${NC}"
  flutter build web --release \
    --dart-define=ENVIRONMENT="$ENVIRONMENT" \
    --dart-define=API_BASE_URL="$API_URL" \
    --dart-define=API_KEY="$API_KEY"
  echo -e "${GREEN}✅ Web build complete!${NC}"
}

deploy_web() {
  if ! command -v firebase >/dev/null 2>&1; then
    echo -e "${RED}Firebase CLI is not installed. Install with: npm i -g firebase-tools${NC}"
    exit 1
  fi

  build_web
  echo -e "${GREEN}🚀 Deploying to Firebase Hosting...${NC}"
  firebase deploy --only hosting
  echo -e "${GREEN}✅ Firebase deployment complete!${NC}"
}

# Validate required args
if [ -z "$1" ]; then
  usage
  exit 1
fi

# Parse inputs
TARGET_ENV="$1"
ACTION="${2:-apk}"

get_env_settings "$TARGET_ENV"

# Dispatch action
case "$ACTION" in
  apk)
    build_apk
    ;;
  web)
    build_web
    ;;
  deploy)
    deploy_web
    ;;
  *)
    echo -e "${RED}Unknown action: $ACTION${NC}"
    usage
    exit 1
    ;;
esac
