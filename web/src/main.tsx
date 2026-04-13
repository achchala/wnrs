import { render } from "preact";
import { App } from "./App";
import "./styles.css";
import type { QuestionPack } from "./types";

async function main() {
  const res = await fetch(`${import.meta.env.BASE_URL}questions.json`);
  if (!res.ok) {
    throw new Error(
      "Could not load questions.json. From web/, run: npm run sync-questions",
    );
  }
  const pack = (await res.json()) as QuestionPack;
  render(<App pack={pack} />, document.getElementById("app")!);
}

main().catch((e) => {
  document.getElementById("app")!.innerHTML = `<p style="padding:1rem;font-family:sans-serif">${String(e)}</p>`;
});
