# <host>

<!-- A host descriptor for the hosting-upgrades skill. Save it in the project as
     docs/hosts/<host>.md, where <host> is the SSH short name. It holds only the three sections
     below; the skill probes every other fact (hardware, OS, kernel, engines, models) live. -->

## SSH short name

`<host>`

## Purposes

<!-- One line per model purpose the host serves or is meant to serve, named and described in a
     few words: agent, vision, audio, embedding, or whatever the host serves. Name no model. -->

- **agent**: the main chat and tool-calling model.
- **embedding**: text embeddings for retrieval.

## Watch items

<!-- Optional. Named things every run must check, beside its own scan: an engine feature, a
     backend's support for this hardware, a known regression. Delete the section if there are
     none. -->

- <engine> support for <backend> on <hardware>
