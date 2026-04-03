#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

work_dir="$tmp_dir/project"
cp -R "$repo_root" "$work_dir"

rm -rf \
  "$work_dir/.git" \
  "$work_dir/.idea" \
  "$work_dir/template-frontend/node_modules" \
  "$work_dir/template-backend/target" \
  "$work_dir/template-frontend/target" \
  "$work_dir/template-frontend/dist"

find "$work_dir" -name '.DS_Store' -delete

"$work_dir/init-template.sh" acme com.ybritto.acme >/dev/null

test -d "$work_dir/acme-api"
test -d "$work_dir/acme-backend"
test -d "$work_dir/acme-frontend"
test -f "$work_dir/acme-backend/src/main/java/com/ybritto/acme/AcmeBackendApplication.java"
test -f "$work_dir/acme-backend/src/test/java/com/ybritto/acme/AcmeBackendApplicationTests.java"

grep -q '<artifactId>acme-app</artifactId>' "$work_dir/pom.xml"
grep -q '<module>acme-api</module>' "$work_dir/pom.xml"
grep -q 'package com.ybritto.acme;' "$work_dir/acme-backend/src/main/java/com/ybritto/acme/AcmeBackendApplication.java"
grep -q 'ACME_DB_URL' "$work_dir/acme-backend/src/main/resources/application.yaml"
grep -q '"name": "acme-frontend"' "$work_dir/acme-frontend/package.json"
grep -q '../acme-api/rest' "$work_dir/acme-frontend/scripts/client-gen.mjs"

if rg -n \
  "milestory|Milestory|com\\.ybritto\\.milestory" \
  "$work_dir/README.md" \
  "$work_dir/AGENTS.md" \
  "$work_dir/pom.xml" \
  "$work_dir/acme-api" \
  "$work_dir/acme-backend" \
  "$work_dir/acme-frontend" >/dev/null 2>&1; then
  echo "Expected no milestory placeholders after initialization" >&2
  exit 1
fi

if rg -n \
  "template-app|template-api|template-backend|template-frontend|com\\.ybritto\\.template|TEMPLATE_" \
  "$work_dir/README.md" \
  "$work_dir/AGENTS.md" \
  "$work_dir/pom.xml" \
  "$work_dir/acme-api" \
  "$work_dir/acme-backend" \
  "$work_dir/acme-frontend" >/dev/null 2>&1; then
  echo "Expected no template placeholders after initialization" >&2
  exit 1
fi

echo "init-template smoke test passed"
