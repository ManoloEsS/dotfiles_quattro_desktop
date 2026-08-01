# Mise Setup Guide for Omarchy

This guide covers the mise configuration for this dotfiles setup.

## Configuration

See `mise/.config/mise/config.toml` for current settings.

## Node.js (No Global - Per-Project Only)

### Why No Global Node?

- Projects have their own `.nvmrc` files
- Node only available when `.nvmrc` exists
- Prevents accidental use of wrong version

### Per-Project Setup

1. Create `.nvmrc` in project root:
   ```
   22
   ```
   (Use major version number, e.g., `20`, `22`)

2. Install the version:
   ```bash
   mise install
   ```

3. Node automatically activates when you cd into the directory

### Workflow

```bash
cd my-node-project
mise install    # First time only
npm install
npm run dev
```

### Important Notes

- Do NOT use `node` or `latest` in `.nvmrc` - use version numbers like `20`, `22`
- Without `.nvmrc`, Node is NOT available (intentional)

## Python (with uv integration)

### Setup

Python is managed via uv, not mise directly. Use `.python-version` file:

1. Create `.python-version` in project:
   ```
   3.12
   ```

2. Install dependencies:
   ```bash
   uv venv
   uv sync
   ```

### Configuration

The global mise config has:

```toml
[settings]
python.uv_venv_auto = "create|source"

[env]
_.python.venv = { path = ".venv" }
```

This makes virtual environments auto-activate when you cd into a project with `uv.lock`.

## Go (Global)

### Setup

Go is installed globally via mise:

```bash
mise use -g go@latest
```

### Per-Project (Optional)

Create `.go-version` file in project:

```
1.22
```

## Common Commands

```bash
mise ls              # List current versions
mise install         # Install versions from config files
mise install node@22 # Install specific version
mise use -g go@latest # Install global tool
mise settings        # View/manage settings
```

## Idiomadic Version Files Supported

| Language | Files |
|----------|-------|
| Node | `.nvmrc`, `.node-version` |
| Python | `.python-version` |
| Ruby | `.ruby-version` |
| Go | `.go-version` |
| All | `.tool-versions`, `.mise.toml` |
