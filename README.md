# Project Template

This repository is a starter workspace for new projects. It is structured as a multi-module application with a shared API contract, a Spring Boot backend, an Angular frontend, and a local PostgreSQL service for development.

The intention is simple:

1. Copy this repository to start a new project.
2. Run the bootstrap script or rename every `template` placeholder to the real application name.
3. Keep this README as the checklist for that rename.

## What is included

- `template-api`: OpenAPI files that define the contract first.
- `template-backend`: Spring Boot backend that consumes the API contract and exposes the server implementation.
- `template-frontend`: Angular frontend, including OpenAPI client generation.
- `compose.yaml`: Local PostgreSQL service for development.
- `pom.xml`: Root Maven aggregator for the full workspace.

## Project structure

```text
.
├── compose.yaml
├── pom.xml
├── template-api/
│   └── rest/
├── template-backend/
│   └── src/
└── template-frontend/
    └── src/
```

## Recommended workflow for a new app

1. Copy this repository into the new project directory.
2. Rename the repository folder itself if needed.
3. Run `./init-template.sh` with your app name and Java package.
4. Review any remaining placeholder hits reported by the script.
5. Start the database and verify backend/frontend startup.
6. Begin shaping the API contract in `<app>-api/rest`.

## Preferred bootstrap path

Use the bootstrap script first. It automates the structural renames that are easy to forget when copying the template by hand.

```bash
./init-template.sh acme com.ybritto.acme
```

If you run it without arguments, it will prompt for the missing values:

```bash
./init-template.sh
```

The script handles:

- module and directory renames
- Maven artifact and module references
- backend Java package and application class renames
- frontend Angular and npm identity updates
- backend environment variable prefix updates
- client generation path updates

After running it, review the remaining search results it prints for any project-specific wording that should be adjusted manually.

## Rename checklist

When turning this template into a real application, replace `template` with your app name consistently across the repository.

If you use `./init-template.sh`, most of this section becomes a verification checklist instead of a manual rename procedure.

Typical example:

- `template-app` -> `acme-app`
- `template-api` -> `acme-api`
- `template-backend` -> `acme-backend`
- `template-frontend` -> `acme-frontend`
- `com.ybritto.template` -> `com.ybritto.acme`

### Rename folders and modules

These names are part of the Maven multi-module structure and should usually be changed first.

- Root `pom.xml`
  - `<artifactId>template-app</artifactId>`
  - `<name>Template</name>`
  - module entries for `template-api`, `template-backend`, and `template-frontend`
- Directory names
  - `template-api/`
  - `template-backend/`
  - `template-frontend/`
- Module POMs
  - artifact ids like `template-api`, `template-backend`, `template-frontend`
  - display names like `Template - Api` and `Template - Backend`

### Rename Java package and backend application class

The backend should also be renamed from the placeholder package to your real package namespace.

Current placeholder examples:

- `com.ybritto.template`
- `TemplateBackendApplication`
- `TemplateBackendApplicationTests`

That usually means:

1. Rename the Java package directory under `src/main/java`.
2. Rename the Java package directory under `src/test/java`.
3. Rename the Spring Boot application class.
4. Update package declarations and any imports.

### Rename backend configuration keys and env vars

The backend config uses `template` as the placeholder prefix. For a real app, update both the property namespace and the environment variable prefix if you want names that match the final project.

Current placeholder examples:

- `template.jwt`
- `TEMPLATE_DB_URL`
- `TEMPLATE_MAIL_HOST`
- `TEMPLATE_JWT_SECRET`
- `template-backend`

Files to check:

- `template-backend/src/main/resources/application.yaml`
- `template-backend/src/main/resources/application-local.yaml`
- `template-backend/src/test/resources/application-test.yaml`

### Rename frontend project identity

Angular keeps the project name in several places.

Files to update:

- `template-frontend/package.json`
- `template-frontend/package-lock.json`
- `template-frontend/angular.json`
- `template-frontend/src/index.html`
- `template-frontend/src/app/app.ts`
- `template-frontend/src/app/app.spec.ts`
- `template-frontend/README.md`

Typical values to replace:

- `template-frontend`
- `TemplateFrontend`

### Rename API integration references

The frontend generator and backend build both reference the API module by name, so these links must stay aligned with the module rename.

Files to verify:

- `template-frontend/scripts/client-gen.mjs`
- `template-backend/pom.xml`
- `template-api/pom.xml`
- root `pom.xml`

### Search before you start coding

Before building the new project, run a repository-wide search to catch any placeholder still left behind.

```bash
rg -n "template|Template"
```

If you also changed the package namespace, run a second search for the original package root.

```bash
rg -n "com\\.ybritto\\.template"
```

## Local development

### Start the database

```bash
docker-compose up -d
```

The PostgreSQL container is defined in `compose.yaml` and uses environment variables for database name, user, password, and host port.

### Backend

Run from the repository root:

```bash
./mvnw -q -pl template-backend spring-boot:run
```

Or run the full Maven test/build lifecycle as needed:

```bash
./mvnw test
```

### Frontend

Run from `template-frontend`:

```bash
npm install
npm start
```

Generate the API client when the OpenAPI contract changes:

```bash
npm run client-gen
```

## Architecture overview

This template follows a contract-first setup.

- The API contract lives in `template-api/rest`.
- The backend consumes that contract and generates Spring interfaces from it.
- The frontend generates a TypeScript Angular client from the same contract.
- PostgreSQL is provided separately through Docker Compose for local development.

This structure helps keep backend and frontend aligned around a single API source of truth.

## Notes for future evolution

This repository works well as a copy/paste project template today. If you later turn it into an initializer, this README can become the basis for:

- automated placeholder replacement
- project/module renaming
- package namespace setup
- environment variable prefix generation
- initial app metadata setup

Until then, treat this file as the manual bootstrap checklist for each new project created from this template.
