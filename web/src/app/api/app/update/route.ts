// GET /api/app/update?currentVersion=0.1.2&currentBuild=3
//
// Update manifest endpoint consumed by the macOS app's UpdateChecker.
// Reads the same `latest.json` produced by `app/release.sh` and adds an
// `updateAvailable` flag computed against the caller's current version.
//
// Callers can omit the query params to just fetch the raw manifest.

import { NextRequest, NextResponse } from "next/server";
import { readFile } from "node:fs/promises";
import path from "node:path";

export const runtime = "nodejs";
export const revalidate = 60;

type Manifest = {
  name: string;
  version: string;
  build: string;
  artifact: string;
  downloadUrl: string;
  githubReleaseUrl: string;
  sha256: string;
  sizeBytes: number;
  createdAt: string;
};

type UpdateResponse = Manifest & {
  updateAvailable: boolean;
  currentVersion: string | null;
  currentBuild: string | null;
};

function compareSemver(a: string, b: string): number {
  const pa = a.split(".").map((n) => parseInt(n, 10) || 0);
  const pb = b.split(".").map((n) => parseInt(n, 10) || 0);
  const len = Math.max(pa.length, pb.length);
  for (let i = 0; i < len; i++) {
    const da = pa[i] ?? 0;
    const db = pb[i] ?? 0;
    if (da !== db) return da < db ? -1 : 1;
  }
  return 0;
}

export async function GET(req: NextRequest): Promise<NextResponse> {
  const manifestPath = path.join(
    process.cwd(),
    "public",
    "downloads",
    "latest.json",
  );

  let manifest: Manifest;
  try {
    const raw = await readFile(manifestPath, "utf8");
    manifest = JSON.parse(raw) as Manifest;
  } catch {
    return NextResponse.json(
      { error: "no release manifest published yet" },
      { status: 404 },
    );
  }

  const currentVersion = req.nextUrl.searchParams.get("currentVersion");
  const currentBuild = req.nextUrl.searchParams.get("currentBuild");

  let updateAvailable = false;
  if (currentVersion) {
    const cmp = compareSemver(currentVersion, manifest.version);
    if (cmp < 0) {
      updateAvailable = true;
    } else if (cmp === 0 && currentBuild) {
      const cb = parseInt(currentBuild, 10) || 0;
      const lb = parseInt(manifest.build, 10) || 0;
      updateAvailable = cb < lb;
    }
  }

  const body: UpdateResponse = {
    ...manifest,
    updateAvailable,
    currentVersion,
    currentBuild,
  };

  return NextResponse.json(body, {
    headers: {
      "Cache-Control": "public, s-maxage=60, stale-while-revalidate=300",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
