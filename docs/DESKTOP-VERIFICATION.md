# REI Reverse Engineer — desktop preview evidence

Environment: Windows 11 x64, Rust 1.97.0, Python 3.14.7, Node 24.22.1.
Date: 2026-11-02. This is an unsigned local development preview.

## Source identity

- Craft Anything source: `ecbd519c6a4bac713bcd0ad1efa6b042c3c3e7da`,
  MIT OR Apache-2.0, retained NOTICE/ATTRIBUTION and license files.
- Original REA submodule: `f72638f6b1f1a41851bf321472569c3265556961`.
- Matching `rea-agents@6.8.0` Windows native module restored using upstream's
  documented source-checkout recovery method. Artifact SHA-256:
  `6a015bfefee7fafb6cbafab659f040170848a45425bbcef6caf962fd39b6ff7b`.
- npm tarball SHA-256:
  `8d542ec76a9cb350584b60a6c9c088706ff812d5bb5b094c20c95b6dc25698bb`.

## Functional integration

The native application uses its original Rust engine and registers external
MCP tools in that same engine. The local Python server contributes 14 tools;
the upstream REA server contributes 234 tools. The actual refresh registered
248 external routes. Counts describe this pinned revision, not an architectural
capacity limit or proof of every operation.

The `rei-bridge-check` executable refreshed both real servers, installed their
routes using the desktop's own plugin API and called these two tools on an
eight-byte synthetic WASM file:

- `rei_rei_rea_inspect`: Python full-file SHA-256 and format identification.
- `upstream_rea_inspect_byte_entropy`: upstream static entropy evidence.

Artifact SHA-256: `93a44bbb96c751218e4c00d479e4c14358122a389acca16205b1e4d0dc5f9476`.
Both calls returned through the desktop engine as evidence. No target code was
executed. The two servers retain their own evidence stores; this is functional
tool/evidence routing, not a merged database or cross-domain graph.

Use upstream's documented compact output-schema profile for discovery. Full
upstream schemas exceed the inherited desktop process-line budget and timed out
during the first integration attempt. Compact mode preserves canonical
server-side validation and complete results; no tool names are removed.

## Checks and limits

The Windows desktop executable built and returned `rei-reverse-engineer 0.3.0`.
Its real native window was opened and inspected. The README screenshot is an
unaltered capture of the running application with a private-data-free profile.
The final desktop/UI suite passed 127 tests. The Python suite ran 65 tests:
64 passed, one skipped because the optional `file` executable is absent.
All 12 Python-workbench skills validated. Formatting, Clippy with warnings
denied, layer checks, lock checks (351 files) and the source secret scan passed.
Remote CI status is recorded in the PR.

The upstream npm installation reported 11 moderate dependency advisories. No
automatic dependency upgrades were applied. Review the pinned dependency audit
before a stable release. Ghidra, mobile/device operations, hardware accuracy,
all 234 upstream operations and AI-generated rebuild quality are NOT VERIFIED
by the bridge smoke test. API-backed features require the user's own provider
configuration. No signed installer or public binary release is claimed.
