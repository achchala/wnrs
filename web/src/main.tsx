import { render } from "preact";
import { App } from "./App";
import "./styles.css";
import type { PackOption, QuestionPack } from "./types";

type PackMeta = { id: string; label: string; file: string };

async function main() {
  const base = import.meta.env.BASE_URL;
  const packsRes = await fetch(`${base}packs.json`);
  if (!packsRes.ok) {
    throw new Error(
      "Could not load packs.json. From web/, run: npm run sync-questions (or npm run build)",
    );
  }
  const metas = (await packsRes.json()) as PackMeta[];
  const options: PackOption[] = await Promise.all(
    metas.map(async (m) => {
      const r = await fetch(`${base}${m.file}`);
      if (!r.ok) {
        throw new Error(`Could not load ${m.file}. Run npm run sync-questions from web/.`);
      }
      const pack = (await r.json()) as QuestionPack;
      return { id: m.id, label: m.label, pack };
    }),
  );
  render(<App packOptions={options} />, document.getElementById("app")!);
}

main().catch((e) => {
  document.getElementById("app")!.innerHTML = `<p style="padding:1rem;font-family:sans-serif">${String(e)}</p>`;
});
