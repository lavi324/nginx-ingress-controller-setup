#!/bin/bash

# Increment image tag
increment_image_tag() {
    local current_tag="$1"
    local incremented_tag=$(echo "$current_tag + 0.1" | bc)
    printf "%.1f" "$incremented_tag"
}

# Increment helm chart version
increment_helm_chart_version() {
    local current_version="$1"
    local major=$(echo "$current_version" | cut -d '.' -f 1)
    local minor=$(echo "$current_version" | cut -d '.' -f 2)
    local patch=$(echo "$current_version" | cut -d '.' -f 3)
    ((patch++))
    echo "$major.$minor.$patch"
}

# Paths
frontend_yaml_path="public1-frontend-helm-chart/templates/frontend-app.yaml"
chart_yaml_path="public1-frontend-helm-chart/Chart.yaml"

# Step 1: Increment image tag in frontend-app.yaml
current_tag=$(awk '/image:/ {print $2}' "$frontend_yaml_path" | cut -d ':' -f 2)
new_tag=$(increment_image_tag "$current_tag")
sed -i "s|image: lavi324/public1-frontend:$current_tag|image: lavi324/public1-frontend:$new_tag|" "$frontend_yaml_path"
echo "Image tag updated from $current_tag to $new_tag in frontend-app.yaml."

# Step 2: Increment Helm chart version in Chart.yaml
current_chart_version=$(awk '/version:/ {print $2}' "$chart_yaml_path")
new_chart_version=$(increment_helm_chart_version "$current_chart_version")
sed -i "s|version: $current_chart_version|version: $new_chart_version|" "$chart_yaml_path"
echo "Helm chart version updated from $current_chart_version to $new_chart_version in Chart.yaml."
