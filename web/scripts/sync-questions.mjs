import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const webRoot = join(here, "..");
const repoRoot = join(webRoot, "..");
const res = join(repoRoot, "wnrs", "Resources");
const destDir = join(webRoot, "public");

const files = ["questions.json", "honest-dating.json"];

mkdirSync(destDir, { recursive: true });
for (const f of files) {
  copyFileSync(join(res, f), join(destDir, f));
}
console.log("synced → web/public/", files.join(", "));
