# <host>

<!-- A host descriptor for the hosting-upgrades skill. Save it in the project as
     docs/hosts/<host>.md, where <host> is the SSH short name. It holds only the sections
     below; the skill probes every other fact (hardware, OS, kernel, engines, models) live. -->

## SSH short name

`<host>`

## Purposes

<!-- One entry per model purpose the host serves today, named and described in a few words:
     agent, vision, audio, embedding, or whatever the host serves. Name no model, and list no
     purpose the host doesn't serve. Each carries its load target: the concurrent sessions (for
     the agent purpose) or concurrent requests (for any other) it is sized for, and the context
     each reaches, with the source each figure is taken from (the served preset section and its
     keys, or the measure record that read it back). The skill judges configuration, engine fit,
     capacity, and memory against these targets, and pauses on a purpose with none. -->

- **agent**: the main chat and tool-calling model. Load target: <N> concurrent sessions of
  <context> tokens each. From <the section or record, and its keys>.
- **embedding**: text embeddings for retrieval. Load target: <N> concurrent requests of
  <context> tokens each. From <the section or record, and its keys>.

## Run noise

<!-- Two spreads, each the widest relative spread, (highest - lowest) / lowest, between readings
     of one cell on one engine build and one kernel, with the readings each comes from cited
     (the records and their cells). The within-session spread bounds every comparison within one
     run (the engine and keep rules); the across-days spread bounds a cell against an earlier
     session's reading of it. A spread with too few readings is marked provisional, and the next
     measure that repeats cells sets it (the skill's rules.md, "Figures", "Run noise"). -->

- **Within-session**: <x.x>%. From <the record, its cells, and their readings>.
- **Across-days**: <x.x>%. From <the records, the cell, and its readings on each day>.

## Watch items

<!-- Optional. Named things every run must check, beside its own scan, of any kind: hardware
     (a kernel's known faults on this system, a firmware or BIOS setting), system (the package
     channel's snapshot, a unit), or engine (an engine feature, a backend's support for this
     hardware, a known regression). A survey answers each by name in the report section of
     its kind. Delete the section if there are none. -->

- <engine> support for <backend> on <hardware>
- <a known fault> on <hardware> with the running <component>

## Measurements

<!-- Optional. The workspace's own dated findings measured on this host, which a run counts as
     attributed benchmarks on it. Give each as the repository's reference name plus its path, not
     a machine path, so the line holds on every checkout. A run compares only cells from one
     session. Write "None." or delete the section if there are none. -->

- <reference name> `<path to a dated finding>`

## Pool

<!-- Optional. Another spike's model pool document, whose rows the skill's survey gates as
     candidates for this host's class: the repository's reference name plus its path, as
     Measurements gives a finding. Delete the section if the host has no pool. -->

- <reference name> `<path to the pool document>`
