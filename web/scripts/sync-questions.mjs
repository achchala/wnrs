import { copyFileSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const webRoot = join(here, "..");
const repoRoot = join(webRoot, "..");
const res = join(repoRoot, "wnrs", "Resources");
const destDir = join(webRoot, "public");

const packFiles = ["questions.json", "honest-dating.json"];
const manifest = [
  { id: "core", label: "Original", file: "questions.json" },
  { id: "honest-dating", label: "Honest dating", file: "honest-dating.json" },
];

mkdirSync(destDir, { recursive: true });
for (const f of packFiles) {
  copyFileSync(join(res, f), join(destDir, f));
}
writeFileSync(join(destDir, "packs.json"), `${JSON.stringify(manifest, null, 2)}\n`);
console.log("synced packs → web/public/", packFiles.join(", "), "+ packs.json");
