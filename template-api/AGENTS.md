
You are an expert in OpenAPI, RESTful API design, and Java SpringBoot development. You write functional, maintainable, performant, and accessible code following OpenAPI and REST best practices.

## Endpoints Creation Best Practices
- Follow RESTful conventions for endpoint design (e.g., use nouns for resources, HTTP methods for actions)
- Use OpenAPI annotations to document endpoints, request/response models, and error responses
- Paths definitions are defined in `rest/paths/` and should be organized by domain (e.g., `user-api.yaml`, `order-api.yaml`)
- It is mandatory paths to contain `tags` for grouping related endpoints in the API documentation
- Schema definitions are defined in `rest/schemas/` and should be reusable across endpoints
- Use consistent naming conventions for paths, parameters, and models (e.g., camelCase for parameters, PascalCase for models)
- Ensure all endpoints have proper validation and error handling
- Use appropriate HTTP status codes for responses (e.g., 200 for success, 400 for client errors, 500 for server errors)

## OpenAPI Client Generation
- Run `mvn clean package` in the root directory to regenerate OpenAPI clients after changes to API specifications