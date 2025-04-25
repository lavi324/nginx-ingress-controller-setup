#!/usr/bin/env bash
set -e

frontend_yaml="public1-frontend-helm-chart/templates/frontend-app.yaml"
chart_yaml="public1-frontend-helm-chart/Chart.yaml"

# 1) bump Docker image tag by 0.1
current_tag=$(awk '/image:/ {print $2}' "$frontend_yaml" | cut -d':' -f2)
# split on dot and compute new value
new_tag=$(awk -v tag="$current_tag" 'BEGIN {
  split(tag,a,".")
  v = a[1] + (a[2] + 1) / 10
  printf("%.1f", v)
}')
sed -i "s|image: lavi324/public1-frontend:$current_tag|image: lavi324/public1-frontend:$new_tag|" "$frontend_yaml"
echo "Image tag updated from $current_tag to $new_tag in $frontend_yaml."

# 2) bump Helm chart patch version
current_chart=$(awk '/version:/ {print $2}' "$chart_yaml")
new_chart=$(awk -v v="$current_chart" 'BEGIN {
  split(v,a,".")
  printf("%d.%d.%d", a[1], a[2], a[3]+1)
}')
sed -i "s|version: $current_chart|version: $new_chart|" "$chart_yaml"
echo "Helm chart version updated from $current_chart to $new_chart in $chart_yaml."
