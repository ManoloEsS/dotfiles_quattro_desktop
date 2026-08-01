---
name: scaffold-fullstack
description: Use ONLY when the user asks to scaffold, create, or initialize a new full-stack project from scratch. Triggers on keywords like "scaffold", "create project", "new project", "initialize project", "bootstrap fullstack", "bun project", "bun fullstack", "bun monorepo", "set up bun project". Does NOT trigger for adding features to existing projects.
---

# Scaffold Full-Stack Project

This skill scaffolds a complete full-stack TypeScript project using Bun workspaces, Express, React (Vite), Drizzle ORM, and Zod. It creates all directories, config files, packages, CI, hooks, and DB-specific configuration. The scaffold produces a **working app** with a health check endpoint, database initialization with graceful shutdown, config validation, placeholder tests, and a development guide.

## When to Use

Use this skill when the user wants to create a brand new full-stack project. Do NOT use for modifying existing projects.

## User Prompt

Ask the user these questions before scaffolding:

1. **Project name** — Used as: npm scope (`@<name>/root`), Docker container name (`<name>_postgres`), package prefix, and `<title>` in `index.html`.
2. **Database** — Choose one: `postgresql`, `mysql`, or `sqlite`. If the user says "other", ask for: dialect name, Drizzle driver package, Docker image (if applicable), connection string format, and default port.

## Database Configuration Table

Each database choice changes specific files. All other files are identical across databases.

### PostgreSQL

| Field | Value |
|---|---|
| Drizzle dialect | `postgresql` |
| Driver package | `postgres` (`^3.4.0`) |
| Drizzle ORM | `drizzle-orm` (`^0.33.0`) |
| Docker image | `postgres:18` |
| Docker container | `<name>_postgres` |
| Docker volume | `<name>_pgdata` |
| Docker volume path | `/var/lib/postgresql` |
| Docker env user | `postgres` |
| Docker env password | `postgres` |
| Docker env DB | `<name>` |
| Docker port | `5432` |
| Connection string format | `postgres://postgres:postgres@localhost:5432/<name>` |
| Test DB connection | `postgres://postgres:postgres@localhost:5432/<name>_test` |
| Drizzle config credentials | `url: process.env.DATABASE_URL!` |
| CI service | `postgres:18` with `POSTGRES_DB: <name>_test` |
| Server connection file | Uses `postgres` package: `postgres(connectionString)` |
| Docker start command | `docker start <name>_postgres \|\| docker run -d --name <name>_postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=<name> -v <name>_pgdata:/var/lib/postgresql -p 5432:5432 postgres:18` |
| Create test DB command | `docker exec -it <name>_postgres psql -U postgres -c "CREATE DATABASE <name>_test;"` |

### MySQL

| Field | Value |
|---|---|
| Drizzle dialect | `mysql` |
| Driver package | `mysql2` (`^3.9.0`) |
| Drizzle ORM | `drizzle-orm` (`^0.33.0`) |
| Docker image | `mysql:8` |
| Docker container | `<name>_mysql` |
| Docker volume | `<name>_mysqldata` |
| Docker volume path | `/var/lib/mysql` |
| Docker env user | `root` |
| Docker env password | `mysql` |
| Docker env DB | `<name>` |
| Docker port | `3306` |
| Connection string format | `mysql://root:mysql@localhost:3306/<name>` |
| Test DB connection | `mysql://root:mysql@localhost:3306/<name>_test` |
| Drizzle config credentials | `url: process.env.DATABASE_URL!` |
| CI service | `mysql:8` with `MYSQL_ROOT_PASSWORD: mysql`, `MYSQL_DATABASE: <name>_test` |
| Server connection file | Uses `mysql2/promise` package: `createPool(connectionString)` |
| Docker start command | `docker start <name>_mysql \|\| docker run -d --name <name>_mysql -e MYSQL_ROOT_PASSWORD=mysql -e MYSQL_DATABASE=<name> -v <name>_mysqldata:/var/lib/mysql -p 3306:3306 mysql:8` |
| Create test DB command | `docker exec -it <name>_mysql mysql -uroot -pmysql -e "CREATE DATABASE <name>_test;"` |

### SQLite

| Field | Value |
|---|---|
| Drizzle dialect | `sqlite` |
| Driver package | `better-sqlite3` (`^11.0.0`) + `@types/better-sqlite3` (`^7.6.0`) |
| Drizzle ORM | `drizzle-orm` (`^0.33.0`) |
| Docker image | None (no Docker) |
| Docker container | N/A |
| Connection string format | `./db/<name>.db` (file path) |
| Test DB connection | `./db/<name>_test.db` (file path) |
| Drizzle config credentials | `url: process.env.DATABASE_URL!` (file path) |
| CI service | None (no service needed) |
| Server connection file | Uses `better-sqlite3`: `new Database(connectionString)` |
| Docker start command | N/A — use `mkdir -p db` instead |
| Create test DB | N/A — file is created automatically |

**SQLite-specific changes:**
- Remove Docker scripts (`db:start`, `db:stop`) from root `package.json`
- Replace `db:start` with `mkdir -p db` (creates the db directory)
- Remove `docker` from CI test job — no service container needed
- Remove `docker start ...` from `test` and `test:coverage` scripts
- `DATABASE_URL` is a file path, not a URL
- Server `db/connection.ts` uses `better-sqlite3` instead of `postgres`/`mysql2`
- `@types/better-sqlite3` added as devDependency to server
- `better-sqlite3` is a native module — may need `make` and `python3` in CI
- `db:studio` script removed from server `package.json` (not supported for SQLite)

## Execution Steps

Execute these steps in order. Replace `<name>` with the project name and use the DB configuration from the table above.

### 1. Create directories

```
<name>/
├── .github/workflows/
├── .husky/
├── .vscode/
├── packages/
│   ├── shared/src/
│   ├── server/
│   │   └── src/{db,features,middleware,utils}/
│   └── web/src/{features,components,styles}/
```

### 2. Write root config files

**`package.json`** — Use `@<name>/root` as name. Set `private: true`, `workspaces: ["packages/*"]`. Include ALL scripts from the template below. Adjust DB-specific scripts (docker commands, port, container name, connection strings) per the database table. For SQLite, remove Docker scripts and replace `db:start` with `mkdir -p db`.

**`tsconfig.base.json`** — Copy exactly from template.

**`.gitignore`** — Copy exactly from template.

**`.prettierrc`** — Copy exactly from template.

**`.prettierignore`** — Copy exactly from template.

**`eslint.config.mjs`** — Copy exactly from template. Replace `@<name>` in all `no-restricted-imports` patterns.

**`.husky/pre-commit`** — Contains just `bunx lint-staged`.

**`.vscode/settings.json`** — Copy exactly from template.

**`.vscode/extensions.json`** — Copy exactly from template.

### 3. Write environment files

**`.env.example`** — Template with all required variables and placeholder values. Safe to commit.

**`.env.development`** — Copy of `.env.example` with dev values filled in (Docker credentials for PostgreSQL/MySQL, file paths for SQLite).

**`.env.test`** — Test DB connection string from the DB table, `PORT=3001`, `JWT_SECRET=test-secret`, `NODE_ENV=test`.

### 4. Write shared package

**`packages/shared/package.json`** — Use `@<name>/shared` as name. Include `@types/bun` in devDependencies.

**`packages/shared/tsconfig.json`** — Copy exactly from template.

**`packages/shared/src/index.ts`** — Re-export comment placeholder.

**`packages/shared/src/index.test.ts`** — Placeholder test file.

### 5. Write server package

**`packages/server/package.json`** — Use `@<name>/server` as name. Replace driver dependency with DB-appropriate driver from the table.

**`packages/server/tsconfig.json`** — Server-specific: `declaration: false`, `declarationMap: false`, `sourceMap: false`.

**`packages/server/drizzle.config.ts`** — Set `dialect` from the DB table. For SQLite, `dbCredentials` uses `url` with a file path.

**`packages/server/src/app.ts`** — Express app with JSON parsing, health check, static serving, SPA fallback, and error handler.

**`packages/server/src/index.ts`** — Async `main()` with config validation, DB init, graceful shutdown.

**`packages/server/src/utils/config.ts`** — Config object and `validateConfig()`.

**`packages/server/src/db/connection.ts`** — DB-specific: `initDb()` and `closeDb()`.

**`packages/server/src/db/schema.ts`** — Placeholder `users` table with comments.

**`packages/server/src/middleware/error-handler.ts`** — Express error handler middleware.

**`packages/server/src/index.test.ts`** — Placeholder test file.

### 6. Write web package

**`packages/web/package.json`** — Use `@<name>/web` as name. Include `"type": "module"` and `@types/bun` in devDependencies.

**`packages/web/tsconfig.json`** — Copy exactly from template.

**`packages/web/vite.config.ts`** — Uses `import.meta.url` + `fileURLToPath` for `__dirname` (ESM). Replace `@<name>` references.

**`packages/web/index.html`** — Set `<title>` to the project name.

**`packages/web/src/index.tsx`** — Copy exactly from template.

**`packages/web/src/App.tsx`** — Copy exactly from template.

**`packages/web/src/components/Layout.tsx`** — Copy exactly from template. Change `<h1>` text to the project name.

**`packages/web/src/components/Layout.css`** — Copy exactly from template.

**`packages/web/src/styles/global.css`** — Copy exactly from template.

**`packages/web/src/index.test.ts`** — Placeholder test file.

### 7. Write CI

**`.github/workflows/ci.yml`** — Copy from template. Adjust the `test` job's service container per the DB table. For SQLite, remove the `services` block entirely and the "Run migrations" step.

### 8. Write development guide

**`DEVELOPMENT.md`** — Copy from template. Replace all `<name>` placeholders.

### 9. Install and initialize

```bash
bun install
git init
```

### 10. Initialize Husky

```bash
bunx husky init
```

Write `.husky/pre-commit` with content `bunx lint-staged`.

### 11. Create test database

For PostgreSQL:
```bash
docker exec -it <name>_postgres psql -U postgres -c "CREATE DATABASE <name>_test;"
```

For MySQL:
```bash
docker exec -it <name>_mysql mysql -uroot -pmysql -e "CREATE DATABASE <name>_test;"
```

For SQLite: No action needed — the database file is created automatically.

### 12. Verify and generate initial migration

```bash
bun run format
bun run lint
bun run typecheck
bun run db:generate <name>_create_users_table
bun run db:migrate
```

If all pass, inform the user the project is ready.

## File Templates

Below are the EXACT file contents to write. Replace `<name>` with the project name. DB-specific sections are marked with `<!-- DB: ... -->` comments — use the correct variant from the database table.

---

### Root `package.json`

```json
{
  "name": "@<name>/root",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "dev": "bun --env-file=.env.development run --filter './packages/*' dev",
    "build": "bun run build:web && bun run build:server",
    "build:web": "bun run --filter @<name>/web build",
    "build:server": "bun run --filter @<name>/server build",
    "test": "<DB_TEST_SCRIPT>",
    "test:coverage": "<DB_TEST_COVERAGE_SCRIPT>",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "typecheck": "bun run --filter './packages/*' typecheck",
    "db:start": "<DB_START_SCRIPT>",
    "db:stop": "<DB_STOP_SCRIPT>",
    "db:generate": "bun --env-file=.env.development run --filter @<name>/server db:generate --",
    "db:migrate": "bun --env-file=.env.development run --filter @<name>/server db:migrate",
    "db:migrate:test": "bun --env-file=.env.test run --filter @<name>/server db:migrate",
    "db:push": "bun --env-file=.env.development run --filter @<name>/server db:push",
    "db:push:test": "bun --env-file=.env.test run --filter @<name>/server db:push",
    "db:studio": "bun --env-file=.env.development run --filter @<name>/server db:studio",
    "dev:full": "bun run db:start && bun run db:migrate && bun --env-file=.env.development run --filter './packages/*' dev",
    "start": "bun run --filter @<name>/server start",
    "prepare": "husky",
    "clean": "bun run --filter './packages/*' clean"
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,css,yml}": [
      "prettier --write"
    ]
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "@typescript-eslint/parser": "^8.0.0",
    "eslint": "^9.0.0",
    "eslint-plugin-react": "^7.35.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "globals": "^17.0.0",
    "husky": "^9.1.7",
    "lint-staged": "^17.0.7",
    "prettier": "^3.3.0"
  }
}
```

**DB-specific script values:**

PostgreSQL:
- `test`: `"docker start <name>_postgres || true && bun --env-file=.env.test run --filter @<name>/server db:migrate && bun --env-file=.env.test run --filter './packages/*' test"`
- `test:coverage`: Same as `test` but append `--coverage` to the last command
- `db:start`: `"docker start <name>_postgres || docker run -d --name <name>_postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=<name> -v <name>_pgdata:/var/lib/postgresql -p 5432:5432 postgres:18"`
- `db:stop`: `"docker stop <name>_postgres"`

MySQL:
- `test`: `"docker start <name>_mysql || true && bun --env-file=.env.test run --filter @<name>/server db:migrate && bun --env-file=.env.test run --filter './packages/*' test"`
- `test:coverage`: Same pattern with `--coverage`
- `db:start`: `"docker start <name>_mysql || docker run -d --name <name>_mysql -e MYSQL_ROOT_PASSWORD=mysql -e MYSQL_DATABASE=<name> -v <name>_mysqldata:/var/lib/mysql -p 3306:3306 mysql:8"`
- `db:stop`: `"docker stop <name>_mysql"`

SQLite:
- `test`: `"bun --env-file=.env.test run --filter @<name>/server db:migrate && bun --env-file=.env.test run --filter './packages/*' test"` (no docker start)
- `test:coverage`: Same pattern with `--coverage`
- `db:start`: `"mkdir -p db"` (no Docker needed)
- `db:stop`: Remove this script entirely for SQLite

---

### `tsconfig.base.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "isolatedModules": true,
    "noImplicitOverride": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

---

### `.gitignore`

```
node_modules/
dist/
.env
.env.development
.env.test
!.env.example
*.db
.DS_Store
.eslintcache
coverage/
```

---

### `.prettierrc`

```json
{
  "singleQuote": true,
  "semi": true,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

---

### `.prettierignore`

```
node_modules
dist
coverage
bun.lock
drizzle
```

---

### `.husky/pre-commit`

```
bunx lint-staged
```

---

### `.vscode/settings.json`

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit"
  },
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

---

### `.vscode/extensions.json`

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "drizzle-team.drizzle-vscode"
  ]
}
```

---

### `eslint.config.mjs`

```js
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import globals from 'globals';

export default [
  {
    ignores: ['**/dist/**', '**/drizzle/**', '**/node_modules/**'],
  },
  js.configs.recommended,
  {
    files: ['packages/server/**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
      globals: {
        ...globals.node,
        ...globals.bun,
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_' },
      ],
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@<name>/web'],
              message: 'Do not import from @<name>/web in the server package.',
            },
          ],
        },
      ],
    },
  },
  {
    files: ['packages/web/**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
      react,
      'react-hooks': reactHooks,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_' },
      ],
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@<name>/server'],
              message: 'Do not import from @<name>/server in the web package.',
            },
          ],
        },
      ],
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
  },
  {
    files: ['packages/shared/**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_' },
      ],
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@<name>/server'],
              message:
                'Do not import from @<name>/server in the shared package.',
            },
            {
              group: ['@<name>/web'],
              message: 'Do not import from @<name>/web in the shared package.',
            },
          ],
        },
      ],
    },
  },
];
```

---

### `.env.example`

PostgreSQL:
```
# Copy this file to .env.development and .env.test
# then fill in the values for your environment.

DATABASE_URL=postgres://postgres:postgres@localhost:5432/<name>
JWT_SECRET=change-me-in-production
PORT=3000
NODE_ENV=development
```

MySQL:
```
# Copy this file to .env.development and .env.test
# then fill in the values for your environment.

DATABASE_URL=mysql://root:mysql@localhost:3306/<name>
JWT_SECRET=change-me-in-production
PORT=3000
NODE_ENV=development
```

SQLite:
```
# Copy this file to .env.development and .env.test
# then fill in the values for your environment.

DATABASE_URL=./db/<name>.db
JWT_SECRET=change-me-in-production
PORT=3000
NODE_ENV=development
```

---

### `.env.development`

PostgreSQL:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/<name>
PORT=3000
JWT_SECRET=development-secret
NODE_ENV=development
```

MySQL:
```
DATABASE_URL=mysql://root:mysql@localhost:3306/<name>
PORT=3000
JWT_SECRET=development-secret
NODE_ENV=development
```

SQLite:
```
DATABASE_URL=./db/<name>.db
PORT=3000
JWT_SECRET=development-secret
NODE_ENV=development
```

---

### `.env.test`

PostgreSQL:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/<name>_test
PORT=3001
JWT_SECRET=test-secret
NODE_ENV=test
```

MySQL:
```
DATABASE_URL=mysql://root:mysql@localhost:3306/<name>_test
PORT=3001
JWT_SECRET=test-secret
NODE_ENV=test
```

SQLite:
```
DATABASE_URL=./db/<name>_test.db
PORT=3001
JWT_SECRET=test-secret
NODE_ENV=test
```

---

### `packages/shared/package.json`

```json
{
  "name": "@<name>/shared",
  "version": "0.0.1",
  "private": true,
  "main": "src/index.ts",
  "types": "src/index.ts",
  "scripts": {
    "typecheck": "tsc --noEmit",
    "test": "bun test",
    "test:coverage": "bun test --coverage",
    "lint": "echo lint",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/bun": "^1.1.0",
    "typescript": "^5.6.0"
  }
}
```

---

### `packages/shared/tsconfig.json`

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}
```

---

### `packages/shared/src/index.ts`

```ts
// Re-export schemas and types as they are created
// e.g. export * from "./schemas/user.schema";
```

---

### `packages/shared/src/index.test.ts`

```ts
import { describe, expect, test } from 'bun:test';

describe('<name>', () => {
  test('placeholder', () => {
    expect(true).toBe(true);
  });
});
```

---

### `packages/server/package.json`

PostgreSQL:
```json
{
  "name": "@<name>/server",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "bun run --hot src/index.ts",
    "build": "bun build src/index.ts --outdir dist --target bun",
    "start": "bun run dist/index.js",
    "test": "bun test",
    "test:coverage": "bun test --coverage",
    "typecheck": "tsc --noEmit",
    "lint": "echo lint",
    "db:generate": "drizzle-kit generate --name",
    "db:migrate": "drizzle-kit migrate",
    "db:push": "drizzle-kit push",
    "db:studio": "drizzle-kit studio",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "@<name>/shared": "workspace:*",
    "express": "^4.21.0",
    "drizzle-orm": "^0.33.0",
    "postgres": "^3.4.0",
    "zod": "^3.23.0",
    "dotenv": "^16.4.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/bun": "^1.1.0",
    "drizzle-kit": "^0.24.0",
    "typescript": "^5.6.0"
  }
}
```

MySQL — same but replace `"postgres": "^3.4.0"` with `"mysql2": "^3.9.0"`.

SQLite — replace `"postgres": "^3.4.0"` with `"better-sqlite3": "^11.0.0"`, add `"@types/better-sqlite3": "^7.6.0"` to devDependencies. Remove `db:studio` from scripts (not supported for SQLite).

---

### `packages/server/tsconfig.json`

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": false,
    "declarationMap": false,
    "sourceMap": false,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

---

### `packages/server/drizzle.config.ts`

PostgreSQL:
```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  verbose: true,
  strict: true,
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

MySQL:
```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'mysql',
  verbose: true,
  strict: true,
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

SQLite:
```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'sqlite',
  verbose: true,
  strict: true,
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

---

### `packages/server/src/app.ts`

<!-- DB: PostgreSQL / MySQL -->
```ts
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import { errorHandler } from './middleware/error-handler';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const app = express();
app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok' });
});

const webDist = path.resolve(__dirname, '../../web/dist');
app.use(express.static(webDist));
app.get('*', (_req, res) => {
  res.sendFile(path.join(webDist, 'index.html'));
});

app.use(errorHandler);
```

<!-- DB: SQLite — same as above -->

---

### `packages/server/src/index.ts`

<!-- DB: PostgreSQL -->
```ts
import dotenv from 'dotenv';
dotenv.config();

import { app } from './app';
import { config, validateConfig } from './utils/config';
import { initDb, closeDb } from './db/connection';

async function main() {
  validateConfig();
  console.log('Configuration validated successfully');

  await initDb(config.DATABASE_URL!);

  const server = app.listen(config.PORT, () => {
    console.log(`Server running on port ${config.PORT}`);
  });

  const shutdown = async () => {
    await closeDb();
    server.close();
    process.exit(0);
  };

  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

main().catch((err) => {
  console.error('Server startup failed:', err);
  setTimeout(() => process.exit(1), 100);
});
```

<!-- DB: MySQL — same structure, but `initDb`/`closeDb` use mysql2 pool -->

<!-- DB: SQLite — same structure, but `initDb` is synchronous (no await needed) and `closeDb` calls `sqliteDb.close()` -->

---

### `packages/server/src/utils/config.ts`

```ts
export const config = {
  PORT: Number(process.env.PORT) || 3000,
  DATABASE_URL: process.env.DATABASE_URL,
  JWT_SECRET: process.env.JWT_SECRET,
  NODE_ENV: process.env.NODE_ENV ?? 'development',
};

export function validateConfig() {
  const missing: string[] = [];
  if (!config.DATABASE_URL) missing.push('DATABASE_URL');
  if (!config.JWT_SECRET) missing.push('JWT_SECRET');
  if (missing.length > 0) {
    throw new Error(`Missing environment variables: ${missing.join(', ')}`);
  }
}
```

---

### `packages/server/src/db/connection.ts`

<!-- DB: PostgreSQL -->
```ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

let client: ReturnType<typeof postgres>;
export let db: ReturnType<typeof drizzle>;

export async function initDb(url: string) {
  console.log('Connecting to PostgreSQL database...');

  try {
    client = postgres(url);
    db = drizzle(client, { schema });
    await client`SELECT 1 as connected`;
    console.log('Successfully connected to PostgreSQL database');
  } catch (err) {
    console.error('Failed to connect to database', err);
    throw err;
  }
}

export async function closeDb() {
  if (client) {
    await client.end();
  }
}
```

<!-- DB: MySQL -->
```ts
import { drizzle } from 'drizzle-orm/mysql2';
import mysql from 'mysql2/promise';
import * as schema from './schema';

let pool: mysql.Pool;
export let db: ReturnType<typeof drizzle>;

export async function initDb(url: string) {
  console.log('Connecting to MySQL database...');

  try {
    pool = mysql.createPool(url);
    db = drizzle(pool, { schema, mode: 'default' });
    await pool.execute('SELECT 1 as connected');
    console.log('Successfully connected to MySQL database');
  } catch (err) {
    console.error('Failed to connect to database', err);
    throw err;
  }
}

export async function closeDb() {
  if (pool) {
    await pool.end();
  }
}
```

<!-- DB: SQLite -->
```ts
import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';

let sqliteDb: Database.Database;
export let db: ReturnType<typeof drizzle>;

export function initDb(path: string) {
  console.log('Connecting to SQLite database...');

  sqliteDb = new Database(path);
  db = drizzle(sqliteDb, { schema });
  console.log('Successfully connected to SQLite database');
}

export function closeDb() {
  if (sqliteDb) {
    sqliteDb.close();
  }
}
```

---

### `packages/server/src/db/schema.ts`

<!-- DB: PostgreSQL -->
```ts
// Placeholder table — replace or extend with your actual schema.
// This table exists to verify the database connection and migration pipeline.
// Feel free to modify or remove it once you define your real schema.
import { pgTable, uuid } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
});
```

<!-- DB: MySQL -->
```ts
// Placeholder table — replace or extend with your actual schema.
// This table exists to verify the database connection and migration pipeline.
// Feel free to modify or remove it once you define your real schema.
import { mysqlTable, varchar } from 'drizzle-orm/mysql-core';

export const users = mysqlTable('users', {
  id: varchar('id', { length: 36 }).primaryKey(),
});
```

<!-- DB: SQLite -->
```ts
// Placeholder table — replace or extend with your actual schema.
// This table exists to verify the database connection and migration pipeline.
// Feel free to modify or remove it once you define your real schema.
import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
});
```

---

### `packages/server/src/middleware/error-handler.ts`

```ts
import type { NextFunction, Request, Response } from 'express';

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
}
```

---

### `packages/server/src/index.test.ts`

```ts
import { describe, expect, test } from 'bun:test';

describe('server', () => {
  test('placeholder', () => {
    expect(true).toBe(true);
  });
});
```

---

### `packages/web/package.json`

```json
{
  "name": "@<name>/web",
  "version": "0.0.1",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview",
    "test": "bun test",
    "test:coverage": "bun test --coverage",
    "typecheck": "tsc --noEmit",
    "lint": "echo lint",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "@<name>/shared": "workspace:*",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/bun": "^1.1.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.0",
    "typescript": "^5.6.0",
    "vite": "^5.4.0"
  }
}
```

---

### `packages/web/tsconfig.json`

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "jsx": "react-jsx",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

---

### `packages/web/vite.config.ts`

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@<name>/shared': path.resolve(__dirname, '../shared/src'),
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
});
```

---

### `packages/web/index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><name></title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/index.tsx"></script>
  </body>
</html>
```

---

### `packages/web/src/index.tsx`

```tsx
import { createRoot } from 'react-dom/client';
import { App } from './App';
import './styles/global.css';

const root = createRoot(document.getElementById('root')!);
root.render(<App />);
```

---

### `packages/web/src/App.tsx`

```tsx
import { Layout } from './components/Layout';

export function App() {
  return <Layout>{null}</Layout>;
}
```

---

### `packages/web/src/components/Layout.tsx`

```tsx
import type { ReactNode } from 'react';
import './Layout.css';

export function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="layout">
      <header className="layout-header">
        <h1><name></h1>
      </header>
      <main className="layout-main">{children}</main>
    </div>
  );
}
```

---

### `packages/web/src/components/Layout.css`

```css
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.layout-header {
  padding: 1rem;
}

.layout-main {
  flex: 1;
  padding: 1rem;
}
```

---

### `packages/web/src/styles/global.css`

```css
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  line-height: 1.5;
}
```

---

### `packages/web/src/index.test.ts`

```ts
import { describe, expect, test } from 'bun:test';

describe('web', () => {
  test('placeholder', () => {
    expect(true).toBe(true);
  });
});
```

---

### `.github/workflows/ci.yml`

PostgreSQL:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-and-format:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-bun-${{ hashFiles('bun.lock') }}
      - run: bun install
      - name: Check formatting
        run: bun run format:check
      - name: Lint
        run: bun run lint

  typecheck:
    name: TypeCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-bun-${{ hashFiles('bun.lock') }}
      - run: bun install
      - name: TypeCheck
        run: bun run typecheck

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-bun-${{ hashFiles('bun.lock') }}
      - run: bun install
      - name: Build
        run: bun run build

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:18
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: <name>_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-bun-${{ hashFiles('bun.lock') }}
      - run: bun install
      - name: Run migrations
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/<name>_test
        run: bun run --filter @<name>/server db:migrate
      - name: Run tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/<name>_test
          JWT_SECRET: test-secret
          PORT: 3001
          NODE_ENV: test
        run: bun run --filter './packages/*' test
```

MySQL: Same structure but replace the `services` block with:
```yaml
    services:
      mysql:
        image: mysql:8
        env:
          MYSQL_ROOT_PASSWORD: mysql
          MYSQL_DATABASE: <name>_test
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h 127.0.0.1"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
```
And update `DATABASE_URL` to `mysql://root:mysql@localhost:3306/<name>_test`.

SQLite: Remove the `services` block entirely. Remove the "Run migrations" step. `DATABASE_URL` becomes `./db/<name>_test.db`.

---

### `DEVELOPMENT.md`

```markdown
# Development Guide

## Prerequisites

- [Bun](https://bun.sh/) (v1.3+)
- [Docker](https://www.docker.com/) (for PostgreSQL 18)

<!-- DB: SQLite — Replace the Docker line with: No external database required -->

## Initial Setup

```bash
bun install
```

## Environment Variables

Environment files are gitignored and must be created locally. Copy `.env.example` to create them.

| Variable | Description |
|---|---|
| `DATABASE_URL` | Database connection string |
| `PORT` | Server port (3000 dev, 3001 test) |
| `JWT_SECRET` | Secret for signing JWT tokens |
| `NODE_ENV` | `development`, `test`, or `production` |

The server validates required variables on startup and exits if any are missing.

## Database

The project uses PostgreSQL 18 running in Docker, managed through bun scripts.

<!-- DB: MySQL — Replace "PostgreSQL 18" with "MySQL 8" -->
<!-- DB: SQLite — Replace the Database section with: The project uses SQLite. No Docker is needed. The database file is created automatically. -->

```bash
bun run db:start      # Start the database container (or create it if it doesn't exist)
bun run db:stop       # Stop the container
bun run db:migrate    # Apply pending migrations (uses .env.development)
bun run db:studio     # Open Drizzle Studio to browse data (PostgreSQL/MySQL only)
```

<!-- DB: SQLite — Remove db:stop and db:studio from the list above. Change db:start to: `mkdir -p db` (creates the db directory) -->

The container mounts a Docker volume so data persists across restarts.

<!-- DB: SQLite — Remove the container/volume sentence -->

## Development

```bash
bun run dev:full
```

This one command starts the database, applies migrations, and runs both the frontend and backend in dev mode.

Or run the steps individually:

```bash
bun run db:start
bun run db:migrate
bun run dev
```

- **Frontend**: http://localhost:5173 (Vite with HMR, proxies `/api` to :3000)
- **Backend**: http://localhost:3000 (Bun with hot reload)

## Schema Changes and Migrations

After editing `packages/server/src/db/schema.ts`:

1. **Generate a migration file (name is required):**
   ```bash
   bun run db:generate <descriptive_name>
   ```
   For example: `bun run db:generate create_users_table`

   This creates a new SQL file in `packages/server/drizzle/`.

2. **Apply the migration:**
   ```bash
   bun run db:migrate
   ```

3. **(Alternative) Push schema directly without a migration file** (dev only):
   ```bash
   bun run db:push
   ```

Always generate and commit migration files for schema changes that will be deployed. Use `db:push` only for local experimentation.

## Quality Checks

```bash
bun run typecheck       # TypeScript type checking
bun run lint            # Check for lint errors
bun run lint:fix        # Auto-fix lint errors
bun run format          # Format all files with Prettier
bun run format:check    # Check formatting without writing
```

Pre-commit hooks (Husky + lint-staged) automatically run `eslint --fix` and `prettier --write` on staged files.

## Testing

```bash
bun run test            # Run all tests (uses .env.test)
bun run test:coverage   # Run tests with coverage report
```

<!-- DB: PostgreSQL/MySQL — Tests run against the `<name>_test` database. The test script will start the Docker container and apply migrations automatically. -->
<!-- DB: SQLite — Tests run using the `<name>_test.db` file. The test script will apply migrations automatically. -->

## Production Build

```bash
bun run build           # Build web then server
bun run start           # Run the built server
```

## Project Structure

```
packages/
├── server/             # Express API (Bun runtime)
│   ├── src/
│   │   ├── db/
│   │   │   ├── schema.ts      # Drizzle schema definitions
│   │   │   └── connection.ts  # Database client and Drizzle instance
│   │   ├── features/          # Route handlers and business logic
│   │   ├── middleware/
│   │   │   └── error-handler.ts
│   │   ├── utils/
│   │   │   └── config.ts      # Config validation
│   │   ├── app.ts             # Express app setup
│   │   └── index.ts           # Entry point (init, listen, shutdown)
│   └── drizzle.config.ts
├── web/                # React frontend (Vite)
│   └── src/
│       ├── components/
│       ├── features/
│       └── styles/
└── shared/             # Shared types and schemas
    └── src/
```
```

---

## Post-Scaffold

After all files are created and `bun install` + `git init` complete:

1. Run `bunx husky init` and overwrite `.husky/pre-commit` with `bunx lint-staged`
2. Run `bun run format` to format all files
3. Run `bun run lint` to verify ESLint passes
4. Run `bun run typecheck` to verify TypeScript passes
5. For PostgreSQL/MySQL: run `bun run db:start` to start the database container, then create the test database using the command from the DB table
6. Generate the initial migration: `bun run db:generate <name>_create_users_table && bun run db:migrate`
7. Tell the user the project is ready and provide the dev workflow:

   ```bash
   bun install              # Install dependencies (already done)
   bun run db:start         # Start database (PostgreSQL/MySQL only)
   bun run dev:full         # Start DB, migrate, and run dev servers
   ```

   <!-- DB: SQLite — Replace the db:start line with: `mkdir -p db` (creates the db directory) -->