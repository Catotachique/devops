#!/bin/bash

# Target base directory
base_dir="/home/ubuntu/Downloads/devops/cloud-native-1"

# List of folders to create inside the base directory
folders=("scripts" "manifests" "helm-charts" "helm-releases" ".github" "app" "config")

# Create each folder
for folder in "${folders[@]}"; do
  mkdir -p "$base_dir/$folder"
  echo "Created: $base_dir/$folder"
done

