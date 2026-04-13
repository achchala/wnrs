import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const webRoot = join(here, "..");
const repoRoot = join(webRoot, "..");
const src = join(repoRoot, "wnrs", "Resources", "questions.json");
const destDir = join(webRoot, "public");
const dest = join(destDir, "questions.json");

mkdirSync(destDir, { recursive: true });
copyFileSync(src, dest);
console.log("synced questions.json → web/public/questions.json");
