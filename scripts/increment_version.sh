#!/usr/bin/env bash

set -euo pipefail

# ── Helpers ─────────────────────────────────────────────────────────────────────
# Increment image tag by +0.1 (e.g. 1.0 → 1.1)
increment_image_tag() {
  local cur="$1"
  printf "%.1f" "$(echo "$cur + 0.1" | bc)"  # bc for floats :contentReference[oaicite:2]{index=2}
}

# Increment semver patch (e.g. 1.2.3 → 1.2.4)
increment_chart_version() {
  IFS='.' read -r major minor patch <<< "$1"
  patch=$((patch + 1))
  echo "${major}.${minor}.${patch}"
}

# ── File Paths ─────────────────────────────────────────────────────────────────
DEPLOY_YAML="Public1-frontend-helm-chart/templates/deployment.yaml"
CHART_YAML="Public1-frontend-helm-chart/Chart.yaml"

# ── Step 1: Bump Docker image tag in deployment.yaml ───────────────────────────
curTag=$(awk '/image:/ {print $2}' "$DEPLOY_YAML" | cut -d':' -f2)
newTag=$(increment_image_tag "$curTag")
sed -i "s|:${curTag}|:${newTag}|g" "$DEPLOY_YAML"
echo "IMAGE_TAG=${newTag}"

# ── Step 2: Bump Helm chart version in Chart.yaml ──────────────────────────────
curVer=$(grep '^version:' "$CHART_YAML" | awk '{print $2}')
newVer=$(increment_chart_version "$curVer")
sed -i "s|version: ${curVer}|version: ${newVer}|g" "$CHART_YAML"
echo "CHART_VERSION=${newVer}"
