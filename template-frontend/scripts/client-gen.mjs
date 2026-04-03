import { existsSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const projectDir = path.resolve(scriptDir, "..");
const specDir = path.resolve(projectDir, "../template-api/rest");
const sourceSpecPath = path.join(specDir, "api-v1.yaml");
const tempSpecPath = path.join(specDir, ".api-v1.client-gen.yaml");
const generatorBinary = path.join(projectDir, "node_modules", ".bin", "openapi-generator-cli");
const openApiToolsConfigPath = path.join(projectDir, "openapitools.json");
const outputDir = path.join(projectDir, "src", "api");

if (!existsSync(sourceSpecPath)) {
  console.error(`OpenAPI spec not found: ${sourceSpecPath}`);
  process.exit(1);
}

if (!existsSync(generatorBinary)) {
  console.error(`Generator binary not found: ${generatorBinary}`);
  process.exit(1);
}

const sourceSpec = readFileSync(sourceSpecPath, "utf8");
const compatibleSpec = sourceSpec.replace(/^openapi:\s*3\.2\.0\s*$/m, "openapi: 3.1.0");

writeFileSync(tempSpecPath, compatibleSpec, "utf8");

const result = spawnSync(
  generatorBinary,
  [
    "generate",
    "--openapitools",
    openApiToolsConfigPath,
    "-i",
    tempSpecPath,
    "-g",
    "typescript-angular",
    "-o",
    outputDir,
    "--type-mappings=string+date=string",
  ],
  {
    cwd: projectDir,
    stdio: "inherit",
  },
);

rmSync(tempSpecPath, { force: true });

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}

process.exit(result.status ?? 1);
