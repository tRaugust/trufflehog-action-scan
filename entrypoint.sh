#!/usr/bin/env sh
set -e # Abort script at first error

args="--regex --entropy=False --max_depth=50" # Default trufflehog options

echo "Hello TR Debugging"
echo sa
echo ${INPUT_SCANARGUMENTS}
echo ght
echo ${INPUT_GITHUBTOKEN}
env

if [ -n "${INPUT_SCANARGUMENTS}" ]; then
  args="${INPUT_SCANARGUMENTS}" # Overwrite if new options string is provided
fi

if [ -n "${INPUT_GITHUBTOKEN}" ]; then
  githubRepo="https://$INPUT_GITHUBTOKEN@github.com/$GITHUB_REPOSITORY" # Overwrite for private repository if token provided
else
  githubRepo="https://github.com/$GITHUB_REPOSITORY" # Default target repository
fi

query="$args $githubRepo" # Build args query with repository url
trufflehog $query
