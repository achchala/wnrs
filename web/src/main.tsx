import { render } from "preact";
import { App } from "./App";
import "./styles.css";
import type { QuestionPack } from "./types";

async function main() {
  const base = import.meta.env.BASE_URL;
  const coreRes = await fetch(`${base}questions.json`);
  if (!coreRes.ok) {
    throw new Error("Could not load questions.json. From web/, run: npm run sync-questions");
  }
  const corePack = (await coreRes.json()) as QuestionPack;

  let datingExpansionPack: QuestionPack | null = null;
  const datingRes = await fetch(`${base}honest-dating.json`);
  if (datingRes.ok) {
    datingExpansionPack = (await datingRes.json()) as QuestionPack;
  }

  render(
    <App corePack={corePack} datingExpansionPack={datingExpansionPack} />,
    document.getElementById("app")!,
  );
}

main().catch((e) => {
  document.getElementById("app")!.innerHTML = `<p style="padding:1rem;font-family:sans-serif">${String(e)}</p>`;
});
