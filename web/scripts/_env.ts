// Side-effect module: loads .env.local then .env into process.env at import
// time. Must be imported BEFORE any module that reads process.env at its
// own module-load time (e.g. ../src/lib/kv).
//
// Why a separate file: ESM hoists `import` statements but evaluates body
// statements (like `config()`) only after all imports are resolved. If the
// dotenv call lives in the script body, it runs too late.

import { config } from "dotenv";

// Order matters when override:false (default): the first file to set a key
// wins. .env.local trumps .env, matching Next.js' precedence rules.
config({ path: ".env.local" });
config({ path: ".env" });
