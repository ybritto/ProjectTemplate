This repository is a reusable project template, not a finished product. Treat `template` as the canonical placeholder name until the user chooses the real application identity.

## First-run behavior

When working in a fresh copy of this repository, proactively check whether the project is still in template state before doing substantial feature work.

Typical indicators of template state include placeholder values such as:

- `template-app`
- `template-api`
- `template-backend`
- `template-frontend`
- `com.ybritto.template`
- `TemplateBackendApplication`
- `template.jwt`
- `TEMPLATE_*`

If those placeholders are still present, proactively offer a rename and bootstrap checklist before proceeding with normal implementation work.

Do not silently choose final application naming when the decision has lasting consequences. Recommend a reasonable default, but confirm the application name and package namespace with the user before making broad rename changes.

## Bootstrap checklist

When the repository is still in template state, guide or execute the following in this order:

1. Choose the real application name.
2. Rename root Maven coordinates such as `template-app`.
3. Rename module names and directories such as `template-api`, `template-backend`, and `template-frontend`.
4. Rename Java package names and Spring Boot application class names derived from `com.ybritto.template`.
5. Rename backend configuration prefixes and environment variables derived from `template` or `TEMPLATE_`.
6. Rename frontend project identity in Angular and npm metadata.
7. Verify backend and frontend references to the API module still match after renaming.
8. Run repository-wide searches to catch leftovers.

Recommended verification searches:

```bash
rg -n "template|Template"
rg -n "com\\.ybritto\\.template"
```

## Naming expectations

- Keep naming consistent across Maven, Java packages, Angular project names, npm package names, config keys, environment variables, and visible application titles.
- Prefer replacing placeholders before building new features.
- If the user wants to defer the rename, continue the requested work, but make that tradeoff explicit.

## Relationship with module instructions

This root file governs template bootstrap and rename behavior for the repository as a whole.

After bootstrap is complete, also follow the more specific instructions in:

- `template-api/AGENTS.md`
- `template-backend/AGENTS.md`
- `template-frontend/AGENTS.md`

If a module is renamed, apply the same guidance from the corresponding renamed module location.
