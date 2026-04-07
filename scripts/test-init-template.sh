#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

prepare_copy() {
  local work_dir="$1"

  cp -R "$repo_root" "$work_dir"

  rm -rf \
    "$work_dir/.git" \
    "$work_dir/.idea" \
    "$work_dir/template-api/target" \
    "$work_dir/template-frontend/node_modules" \
    "$work_dir/template-backend/target" \
    "$work_dir/template-frontend/target" \
    "$work_dir/template-frontend/dist"

  find "$work_dir" -name '.DS_Store' -delete
}

assert_common_project_state() {
  local work_dir="$1"
  local app_name="$2"
  local package_name="$3"
  local app_pascal="$4"
  local package_path

  package_path="$(printf '%s' "$package_name" | tr '.' '/')"

  test -d "$work_dir/${app_name}-api"
  test -d "$work_dir/${app_name}-backend"
  test -d "$work_dir/${app_name}-frontend"
  test -f "$work_dir/${app_name}-backend/src/main/java/${package_path}/${app_pascal}BackendApplication.java"
  test -f "$work_dir/${app_name}-backend/src/test/java/${package_path}/${app_pascal}BackendApplicationTests.java"

  grep -q "<artifactId>${app_name}-app</artifactId>" "$work_dir/pom.xml"
  grep -q "<module>${app_name}-api</module>" "$work_dir/pom.xml"
  grep -q "package ${package_name};" "$work_dir/${app_name}-backend/src/main/java/${package_path}/${app_pascal}BackendApplication.java"
  grep -q "\"name\": \"${app_name}-frontend\"" "$work_dir/${app_name}-frontend/package.json"
  grep -q "container_name: ${app_name}-postgres" "$work_dir/compose.yaml"
  grep -q "username: \${$(printf '%s' "$app_name" | tr '[:lower:]-' '[:upper:]_')_DB_USERNAME:${app_name}}" "$work_dir/${app_name}-backend/src/main/resources/application.yaml"
  grep -q "\${$(printf '%s' "$app_name" | tr '[:lower:]-' '[:upper:]_')_DB_NAME:${app_name}}" "$work_dir/${app_name}-backend/src/main/resources/application-local.yaml"
  grep -q "${package_name}.generated" "$work_dir/${app_name}-backend/src/main/resources/openapi-processor-mapping.yaml"
  grep -q "# ${app_pascal}" "$work_dir/README.md"
  grep -q "This file was reset by \`./init-template.sh\`" "$work_dir/README.md"
  grep -q "This repository is now an initialized application" "$work_dir/AGENTS.md"
}

assert_no_placeholders() {
  local work_dir="$1"
  local app_name="$2"

  if rg -n \
    "template-app|template-api|template-backend|template-frontend|com\\.ybritto\\.template|TEMPLATE_" \
    "$work_dir/README.md" \
    "$work_dir/AGENTS.md" \
    "$work_dir/pom.xml" \
    "$work_dir/${app_name}-api" \
    "$work_dir/${app_name}-backend" \
    "$work_dir/${app_name}-frontend" >/dev/null 2>&1; then
    echo "Expected no template placeholders after initialization" >&2
    exit 1
  fi
}

work_dir="$tmp_dir/project-acme"
prepare_copy "$work_dir"
"$work_dir/init-template.sh" acme com.ybritto.acme >/dev/null
assert_common_project_state "$work_dir" "acme" "com.ybritto.acme" "Acme"
grep -q 'ACME_DB_URL' "$work_dir/acme-backend/src/main/resources/application.yaml"

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

assert_no_placeholders "$work_dir" "acme"

legacy_work_dir="$tmp_dir/project-milestory"
prepare_copy "$legacy_work_dir"
"$legacy_work_dir/init-template.sh" milestory com.ybritto.milestory >/dev/null
assert_common_project_state "$legacy_work_dir" "milestory" "com.ybritto.milestory" "Milestory"
grep -q '<artifactId>milestory-app</artifactId>' "$legacy_work_dir/pom.xml"
grep -q '<artifactId>milestory-backend</artifactId>' "$legacy_work_dir/milestory-backend/pom.xml"
grep -q '<artifactId>milestory-frontend</artifactId>' "$legacy_work_dir/milestory-frontend/pom.xml"
grep -q 'MILESTORY_DB_URL' "$legacy_work_dir/milestory-backend/src/main/resources/application.yaml"
assert_no_placeholders "$legacy_work_dir" "milestory"

echo "init-template smoke test passed"
