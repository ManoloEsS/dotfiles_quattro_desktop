---
name: fullstack-static-scaffold
description: >
  Scaffolds a full-stack app where the frontend (Vite + React + TypeScript) 
  is built into the backend's dist folder, serving static files from the same 
  Express server. Creates project_name_frontend/ and project_name_backend/ 
  directories with dev and production workflows.
---

# Fullstack Static Scaffold

Scaffolds a full-stack app where the frontend (Vite + React) is built into the backend's `dist` folder, serving static files from the same Express server.

## Usage

```
/fullstack-static-scaffold [project_name]
```

- `project_name`: Name for the project directories (default: "app")
- Creates `project_name_frontend/` and `project_name_backend/` in current directory

## Implementation

Execute: `$HOME/.claude/skills/fullstack-static-scaffold/generate.sh <project_name>`

The generate script:
- Creates `project_name_backend/` and `project_name_frontend/` directories
- Copies templates from `$HOME/.claude/skills/fullstack-static-scaffold/templates/`
- Substitutes `PROJECT_NAME` placeholder with actual project name
- Creates full project structure with TypeScript, React, Express

## What Gets Created

### Backend
- `package.json` - express, mongoose, morgan, typescript, tsx
- `tsconfig.json` - compiles to `./dist`
- `src/index.ts` - Express server with static file serving
- `src/app.ts` - Express app with MongoDB connection
- `src/models/item.ts` - Mongoose model with name and number fields
- `src/controllers/index.ts` - CRUD API routes
- `.env` - MongoDB connection string
- `.gitignore`, `.nvmrc`

### Frontend
- `package.json` - react, vite, axios, typescript
- `vite.config.ts` - builds to `../project_name_backend/dist`, proxy to backend
- `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`
- `src/main.tsx`, `src/App.tsx`, `src/App.css`, `src/index.css`
- `index.html`
- `.gitignore`, `.nvmrc`

## Commands

### Development
```bash
# Terminal 1 - backend
cd project_name_backend && npm run dev

# Terminal 2 - frontend  
cd project_name_frontend && npm run dev
```

Frontend runs on http://localhost:5173 with proxy to backend at http://localhost:3001

### Production Build
```bash
cd project_name_backend
npm run build          # compile TypeScript
npm run build:ui       # build frontend to dist
npm run start          # run server on port 3001
```

## MongoDB / Mongoose

The backend comes with Mongoose pre-configured for MongoDB.

### Setup

1. Create a `.env` file in `project_name_backend/`:
   ```
   PORT=3001
   MONGODB_URI=mongodb://localhost:27017/your_database
   ```

2. Or use MongoDB Atlas (cloud):
   ```
   MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.xxx.mongodb.net/your_database
   ```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/items` | List all items |
| GET | `/api/items/:id` | Get single item |
| POST | `/api/items` | Create item |
| PUT | `/api/items/:id` | Update item |
| DELETE | `/api/items/:id` | Delete item |
| GET | `/info` | Show item count & time |

### Item Schema

```typescript
{
  name: string (required, minLength: 3)
  number: string (optional)
}
```

### Customizing the Model

Edit `src/models/item.ts` to change the schema:
```typescript
const itemSchema = new mongoose.Schema({
    name: { type: String, required: true },
    number: { type: String },
    // Add more fields here
})
```

Then rebuild: `npm run build`