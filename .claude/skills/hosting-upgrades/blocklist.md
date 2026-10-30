# Blocklist

Sources a run never cites, whatever a search ranks them. Each was met while researching a run and
is listed with what was found and the criterion it fails. When a blocklisted page carries a figure
worth having, the run follows it to the original the page took it from and cites the original, or,
with no original, leaves the figure out.

The criteria:

- **no method**: figures given with no hardware detail, engine version, or workload, so nothing
  can be checked or repeated.
- **content-farmed or AI-aggregated**: pages written or compiled at volume, by AI or from other
  sites' figures, rather than measured.
- **republished, no original**: figures taken from other sources without a link to the original
  measurement, or with the original's settings dropped.

A site on this list can come off it when its pages change; the architect decides, and the change
is proposed in a report under "Proposed changes" like any other.

| Site | Met | What was found | Criterion |
|---|---|---|---|
| codersera.com | 2026-10-29, `/blog/amd-strix-halo-ryzen-ai-max-local-llm-setup-2026/` | No author. Strix Halo throughput figures (gpt-oss-120b near 55 t/s, ROCm "roughly 3x" faster prompt processing at long context) credited only to "community benchmarks", with no link, engine build, ROCm or Mesa version, or workload. The page closes with a pitch for the site's developer-hiring service. | no method; republished, no original |
| localaimaster.com | 2026-10-29, `/blog/amd-rocm-local-llm-setup` | The footer says the content is "partly AI-assisted". Figures cite "internal benchmarks" across several GPUs with no ROCm, Ollama, llama.cpp, or vLLM version; its vLLM example pins `rocm/vllm:latest`. | content-farmed or AI-aggregated; no method |
| presenc.ai | 2026-10-29, `/research/amd-strix-halo-local-llm-benchmarks-2026` | A compilation that states "none of the figures are Presenc AI measurements". It lists third-party figures with no engine versions and mixed settings, and some rows are themselves taken from other compilations (a ServeTheHome figure "via DataHardware"). | republished, no original; AI-aggregated compilation |
| runaihome.com | 2026-10-29, `/blog/ryzen-ai-max-395-strix-halo-local-llm-2026/` | Team byline; "all results come from community testing" with no figure tied to its source, a range of llama.cpp builds (b9049 to b9467) and Mesa versions for the whole table, no prompt length, context, or repetition count, and affiliate links. Some figures have no source at all. | republished, no original; no method |
| toolhalla.ai | 2026-10-30, `/blog/amd-strix-halo-local-llm-guide-2026` | No author. "Benchmarks from community testing on 128GB Strix Halo systems" with no source, engine build, ROCm or Mesa version; Amazon affiliate tags. | no method; republished, no original |
| Model-provided summaries quoted in forum posts | 2026-10-29, a comment on vllm-project/vllm#32180 quoting "5.6Sol says" | A user pasted an AI assistant's explanation of vLLM's slowness on gfx1151 as fact. The rest of such a post can be a lead; the quoted model output is never cited. | content-farmed or AI-aggregated |
