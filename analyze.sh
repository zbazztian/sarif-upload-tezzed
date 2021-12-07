#!/bin/sh
set -eu

export GITHUB_TOKEN="$(cat .ghtoken)"
export PATH="$(pwd)/codeql/:$PATH"
CSLANG="$1"
REPO="$2"

# check out repository
git clone --depth 1 "git@github.com:${REPO}" checkout

# extraction
codeql \
  database create \
  --language "$CSLANG"  \
  --source-root checkout \
  --codescanning-config codeql-config.yml \
  codeql-database
#  --command "mvn clean install -DskipTests"

# analysis
codeql \
  database analyze \
  --format sarif-latest \
  --output results.sarif \
  --sarif-category "$CSLANG" \
  codeql-database

# upload
codeql \
  github upload-results \
  --github-url "https://github.com" \
  --sarif results.sarif \
  --repository "$REPO" \
  --ref refs/heads/main \
  --commit $(git --git-dir checkout/.git rev-parse HEAD) \
