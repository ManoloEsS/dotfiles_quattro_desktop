# Setup TypeScript Backend Linting

Configure ESLint for a TypeScript backend project with the same rules as the knife_roll/nacl projects.

## What This Skill Does

- Installs required ESLint dependencies
- Creates `eslint.config.mjs` with TypeScript support
- Configures stylistic rules (4 spaces, single quotes, no semicolons)
- Adds `no-unused-vars` rule with underscore prefix exception
- Sets up proper ignores for dist/ directory

## Installation

```bash
npm install -D eslint @eslint/js @stylistic/eslint-plugin typescript-eslint globals
```

## Configuration

Creates `eslint.config.mjs`:

```javascript
import globals from 'globals'
import js from '@eslint/js'
import stylisticJs from '@stylistic/eslint-plugin'
import tseslint from 'typescript-eslint'

export default [
  js.configs.recommended,
  {
    files: ['**/*.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: { ...globals.node },
      ecmaVersion: 'latest',
    },
    plugins: {
      '@stylistic/js': stylisticJs,
    },
    rules: {
      '@stylistic/js/indent': ['error', 2],
      '@stylistic/js/linebreak-style': ['error', 'unix'],
      '@stylistic/js/quotes': ['error', 'single'],
      '@stylistic/js/semi': ['error', 'never'],
      eqeqeq: 'error',
      'no-trailing-spaces': 'error',
      'object-curly-spacing': ['error', 'always'],
      'arrow-spacing': ['error', { before: true, after: true }],
      'no-console': 'off',
    },
  },
  {
    ignores: ['dist/**'],
    files: ['**/*.ts'],
    plugins: {
      ...tseslint.configs.recommended[0].plugins,
      '@stylistic/js': stylisticJs,
    },
    languageOptions: {
      ...tseslint.configs.recommended[0].languageOptions,
      globals: { ...globals.node },
    },
    rules: {
      ...tseslint.configs.recommended[0].rules,
      'no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      '@stylistic/js/indent': ['error', 4],
      '@stylistic/js/linebreak-style': ['error', 'unix'],
      '@stylistic/js/quotes': ['error', 'single'],
      '@stylistic/js/semi': ['error', 'never'],
      eqeqeq: 'error',
      'no-trailing-spaces': 'error',
      'object-curly-spacing': ['error', 'always'],
      'arrow-spacing': ['error', { before: true, after: true }],
      'no-console': 'off',
    },
  },
  {
    ignores: ['dist/**'],
  },
]
```

## Package.json Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

## Rules Summary

| Rule | Setting | Purpose |
|------|---------|---------|
| `indent` | 4 spaces (TS), 2 spaces (JS) | Consistent indentation |
| `quotes` | single | Single quotes for strings |
| `semi` | never | No semicolons |
| `linebreak-style` | unix | LF line endings |
| `eqeqeq` | error | Require === and !== |
| `no-trailing-spaces` | error | No trailing whitespace |
| `object-curly-spacing` | always | Spaces inside object braces |
| `arrow-spacing` | before/after: true | Spaces around arrow => |
| `no-console` | off | Allow console.log |
| `no-unused-vars` | ignore ^_ prefix | Ignore _prefixed variables |

## Usage

```bash
# Run linter
npm run lint

# Auto-fix issues
npm run lint:fix
```

## Underscore Prefix Convention

Variables starting with `_` are ignored for the unused-vars rule:

```typescript
// ✅ Valid - unused parameters with _ prefix
app.use((err, _req, res, _next) => {
  res.status(500).json({ error: err.message })
})

// ✅ Valid - unused variables with _ prefix
const [_unused, used] = someArray

// ❌ Invalid - unused variable without _ prefix
const unused = 'this will cause a lint error'
```

## Files to Ignore

Add to `.gitignore`:

```
# ESLint
.eslintcache
```

Add to `.editorconfig` (optional):

```editorconfig
[*]
indent_style = space
indent_size = 4
end_of_line = lf
trim_trailing_whitespace = true
insert_final_newline = true

[*.js]
indent_size = 2
```

## Notes

- Uses `@stylistic/eslint-plugin` for formatting rules (separated from ESLint core)
- Uses `typescript-eslint` for TypeScript-specific linting
- Configured for Node.js backend projects (CommonJS modules)
- Ignores `dist/` directory (compiled output)
- Allows `console.log` for development logging
