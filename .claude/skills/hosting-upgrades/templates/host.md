# <host>

<!-- A host descriptor for the hosting-upgrades skill. Save it in the project as
     docs/hosts/<host>.md, where <host> is the SSH short name. It holds only the sections
     below; the skill probes every other fact (hardware, OS, kernel, engines, models) live. -->

## SSH short name

`<host>`

## Purposes

<!-- One line per model purpose the host serves or is meant to serve, named and described in a
     few words: agent, vision, audio, embedding, or whatever the host serves. Name no model. -->

- **agent**: the main chat and tool-calling model.
- **embedding**: text embeddings for retrieval.

## Watch items

<!-- Optional. Named things every run must check, beside its own scan, of any kind: hardware
     (a kernel's known faults on this system, a firmware or BIOS setting), system (the package
     channel's snapshot, a unit), or engine (an engine feature, a backend's support for this
     hardware, a known regression). A run answers each by name in the report section of its
     kind. Delete the section if there are none. -->

- <engine> support for <backend> on <hardware>
- <a known fault> on <hardware> with the running <component>

## Measurements

<!-- Optional. The workspace's own dated findings measured on this host, which a run counts as
     attributed benchmarks on it. Give each as the repository's reference name plus its path, not
     a machine path, so the line holds on every checkout. A run compares only cells from one
     session. Write "None." or delete the section if there are none. -->

- <reference name> `<path to a dated finding>`
