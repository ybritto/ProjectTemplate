#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

prompt_if_missing() {
  local current_value="$1"
  local prompt_text="$2"
  local result="$current_value"

  if [[ -z "$result" ]]; then
    read -r -p "$prompt_text" result
  fi

  printf '%s' "$result"
}

validate_app_name() {
  local value="$1"

  if [[ ! "$value" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "App name must be lowercase kebab-case, for example: acme or acme-hub" >&2
    exit 1
  fi
}

validate_package_name() {
  local value="$1"

  if [[ ! "$value" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo "Package name must look like a valid Java package, for example: com.ybritto.acme" >&2
    exit 1
  fi
}

to_pascal_case() {
  local value="$1"
  local part
  local result=""
  local old_ifs="$IFS"
  IFS='-'

  for part in $value; do
    result+="$(printf '%s' "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}"
  done

  IFS="$old_ifs"
  printf '%s' "$result"
}

move_if_exists() {
  local source_path="$1"
  local target_path="$2"

  if [[ -e "$source_path" ]]; then
    if [[ -e "$target_path" ]]; then
      if [[ -d "$source_path" ]] && [[ -z "$(find "$source_path" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
        rmdir "$source_path"
        return
      fi

      echo "Refusing to overwrite existing path: $target_path" >&2
      exit 1
    fi

    mkdir -p "$(dirname "$target_path")"
    mv "$source_path" "$target_path"
  fi
}

replace_in_text_files() {
  local search="$1"
  local replace="$2"

  while IFS= read -r -d '' file; do
    if grep -Iq . "$file"; then
      SEARCH="$search" REPLACE="$replace" perl -0pi -e 's/\Q$ENV{SEARCH}\E/$ENV{REPLACE}/g' "$file"
    fi
  done < <(
    find "$repo_root" \
      \( -path "$repo_root/.git" -o -path "$repo_root/.idea" -o -path "$repo_root/node_modules" -o -path "$repo_root/target" \) -prune \
      -o -type f \
      ! -name '.DS_Store' \
      -print0
  )
}

app_name="${1:-}"
package_name="${2:-}"

app_name="$(prompt_if_missing "$app_name" "Application name (kebab-case, e.g. acme): ")"
package_name="$(prompt_if_missing "$package_name" "Java package (e.g. com.ybritto.acme): ")"

validate_app_name "$app_name"
validate_package_name "$package_name"

app_pascal="$(to_pascal_case "$app_name")"
env_prefix="${app_name//-/_}"
env_prefix="$(printf '%s' "$env_prefix" | tr '[:lower:]' '[:upper:]')"
package_path="$(printf '%s' "$package_name" | tr '.' '/')"

old_backend_dir="$repo_root/template-backend"
new_api_dir="$repo_root/${app_name}-api"
new_backend_dir="$repo_root/${app_name}-backend"
new_frontend_dir="$repo_root/${app_name}-frontend"

echo "Initializing template for app: $app_name"
echo "Using Java package: $package_name"

move_if_exists "$repo_root/template-api" "$new_api_dir"
move_if_exists "$repo_root/template-backend" "$new_backend_dir"
move_if_exists "$repo_root/template-frontend" "$new_frontend_dir"

old_main_package_dir="$new_backend_dir/src/main/java/com/ybritto/template"
legacy_main_package_dir="$new_backend_dir/src/main/java/com/ybritto/milestory"
new_main_package_dir="$new_backend_dir/src/main/java/$package_path"
old_test_package_dir="$new_backend_dir/src/test/java/com/ybritto/template"
legacy_test_package_dir="$new_backend_dir/src/test/java/com/ybritto/milestory"
new_test_package_dir="$new_backend_dir/src/test/java/$package_path"

move_if_exists "$old_main_package_dir" "$new_main_package_dir"
move_if_exists "$legacy_main_package_dir" "$new_main_package_dir"
move_if_exists "$old_test_package_dir" "$new_test_package_dir"
move_if_exists "$legacy_test_package_dir" "$new_test_package_dir"

move_if_exists \
  "$new_main_package_dir/TemplateBackendApplication.java" \
  "$new_main_package_dir/${app_pascal}BackendApplication.java"

move_if_exists \
  "$new_test_package_dir/TemplateBackendApplicationTests.java" \
  "$new_test_package_dir/${app_pascal}BackendApplicationTests.java"

replace_in_text_files "template-app" "${app_name}-app"
replace_in_text_files "template-api" "${app_name}-api"
replace_in_text_files "template-backend" "${app_name}-backend"
replace_in_text_files "template-frontend" "${app_name}-frontend"
replace_in_text_files "TemplateBackendApplicationTests" "${app_pascal}BackendApplicationTests"
replace_in_text_files "TemplateBackendApplication" "${app_pascal}BackendApplication"
replace_in_text_files "TemplateFrontend" "${app_pascal}Frontend"
replace_in_text_files "com.ybritto.template" "$package_name"
replace_in_text_files "TEMPLATE_" "${env_prefix}_"
replace_in_text_files "template_test" "${app_name}_test"
replace_in_text_files "template-local" "${app_name}-local"
replace_in_text_files "template-web" "${app_name}-web"
replace_in_text_files "template.jwt" "${app_name}.jwt"
replace_in_text_files "template:" "${app_name}:"
replace_in_text_files "localhost:5432/template" "localhost:5432/${app_name}"
replace_in_text_files "Template - Api" "${app_pascal} - Api"
replace_in_text_files "Template - Backend" "${app_pascal} - Backend"
replace_in_text_files "Template - Frontend" "${app_pascal} - Frontend"
replace_in_text_files "<name>Template</name>" "<name>${app_pascal}</name>"

echo
echo "Bootstrap complete. Checking for remaining placeholders..."

remaining_template_hits="$(rg -n "template-app|template-api|template-backend|template-frontend|com\\.ybritto\\.template|TemplateBackendApplication|TEMPLATE_" "$repo_root" || true)"

if [[ -n "$remaining_template_hits" ]]; then
  echo "Some placeholder references still need manual review:"
  echo "$remaining_template_hits"
else
  echo "No core template placeholders remain."
fi

echo
echo "Suggested follow-up:"
echo "  rg -n \"template|Template\" \"$repo_root\""
echo "  rg -n \"${package_name//./\\.}\" \"$repo_root\""
