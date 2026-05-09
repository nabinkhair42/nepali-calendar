// Cloudflare KV client over the REST API. Works from any Node runtime
// (Vercel, local dev, GH Actions) — no wrangler binding required.
//
// Why REST and not the Workers binding: keeps the route portable. If we
// later deploy on Cloudflare Pages with @cloudflare/next-on-pages, we can
// swap to `getRequestContext().env.KV_BINDING` here without touching callers.
//
// Env required:
//   CF_ACCOUNT_ID         — Cloudflare account ID
//   CF_KV_NAMESPACE_ID    — namespace ID (festivals: 1fa06c972daf4a64a77c0575308e0cb2)
//   CF_API_TOKEN          — token with "Workers KV Storage:Edit" on the namespace

import { createHash } from "node:crypto";

const ACCOUNT_ID = process.env.CF_ACCOUNT_ID;
const NAMESPACE_ID = process.env.CF_KV_NAMESPACE_ID;
const API_TOKEN = process.env.CF_API_TOKEN;

export interface KVEntry<T> {
  value: T;
  /** ms since epoch when this entry was written. */
  storedAt: number;
  /** sha256 hash of the canonical content (excludes timestamps so we can detect real changes). */
  hash: string;
}

export const KV_KEYS = {
  festivalsYear: (year: number) => `festivals-${year}`,
} as const;

function endpoint(key: string): string {
  return `https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/storage/kv/namespaces/${NAMESPACE_ID}/values/${encodeURIComponent(key)}`;
}

function authHeaders(): HeadersInit {
  return { Authorization: `Bearer ${API_TOKEN}` };
}

export function isConfigured(): boolean {
  return Boolean(ACCOUNT_ID && NAMESPACE_ID && API_TOKEN);
}

/** Stable SHA-256 of any JSON-serializable value, computed over a key-sorted string. */
export function hashContent(value: unknown): string {
  return createHash("sha256").update(canonicalize(value)).digest("hex");
}

function canonicalize(value: unknown): string {
  if (value === null || typeof value !== "object") return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalize).join(",")}]`;
  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${canonicalize(obj[k])}`).join(",")}}`;
}

/** Read JSON value at key. Returns null on miss / not-configured / network error. */
export async function kvGet<T>(key: string): Promise<KVEntry<T> | null> {
  if (!isConfigured()) return null;
  try {
    const r = await fetch(endpoint(key), {
      headers: authHeaders(),
      // KV is the source of truth; never let upstream fetch caches lie to us.
      cache: "no-store",
    });
    if (r.status === 404) return null;
    if (!r.ok) return null;
    const text = await r.text();
    const parsed = JSON.parse(text) as KVEntry<T>;
    if (typeof parsed?.storedAt !== "number" || typeof parsed?.hash !== "string") {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/**
 * Write value at key. Computes hash from `hashable` (defaults to value).
 * Pass a hashable subset when the value contains volatile fields (timestamps)
 * that shouldn't trigger spurious change detection.
 *
 * Returns:
 *   - 'written'   — value persisted (new key or hash changed)
 *   - 'unchanged' — existing entry has same hash; no write performed
 *   - 'error'     — KV unreachable or auth failed
 */
export async function kvPutIfChanged<T>(
  key: string,
  value: T,
  hashable: unknown = value,
): Promise<{ status: "written" | "unchanged" | "error"; hash: string }> {
  const hash = hashContent(hashable);
  if (!isConfigured()) return { status: "error", hash };

  const existing = await kvGet<T>(key);
  if (existing && existing.hash === hash) {
    return { status: "unchanged", hash };
  }

  try {
    const entry: KVEntry<T> = { value, storedAt: Date.now(), hash };
    const r = await fetch(endpoint(key), {
      method: "PUT",
      headers: { ...authHeaders(), "Content-Type": "application/json" },
      body: JSON.stringify(entry),
    });
    return r.ok ? { status: "written", hash } : { status: "error", hash };
  } catch {
    return { status: "error", hash };
  }
}

/** Unconditional write (used for the meta key, which always has fresh content). */
export async function kvPut<T>(key: string, value: T): Promise<boolean> {
  if (!isConfigured()) return false;
  try {
    const entry: KVEntry<T> = { value, storedAt: Date.now(), hash: hashContent(value) };
    const r = await fetch(endpoint(key), {
      method: "PUT",
      headers: { ...authHeaders(), "Content-Type": "application/json" },
      body: JSON.stringify(entry),
    });
    return r.ok;
  } catch {
    return false;
  }
}
