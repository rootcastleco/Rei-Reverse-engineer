# REI Reverse Engineer Desktop

Native Windows desktop fork of Craft Anything, based on upstream commit
`ecbd519c6a4bac713bcd0ad1efa6b042c3c3e7da` (workspace version 0.3.0).
Original repository: https://github.com/storytold/craft-anything.

Rootcastle changes include the product title and application ID
`com.rootcastle.rei`, an original geometric icon, Rootcastle blue/black colors,
an isolated `rootcastle-rei` settings folder and `Documents/REI Reverse Engineer`
project directory. `REI_CONFIG_DIR` overrides the settings location. Internal
crate names and evidence/project formats retain upstream names for compatibility.

Build from the parent repository with `./scripts/build_desktop.ps1`; add
`-Release` for an optimized build. Requires Rust 1.97.0 and Visual Studio C++
build tools / Windows SDK. Run with `./scripts/run_desktop.ps1`.

The native Rust application registers the Python workbench and original REA
as local MCP plugins. The Windows smoke test discovered 248 external tools
and executed Python identification and upstream static entropy analysis through
the desktop engine. Each server retains its own storage; this is a unified tool
interface rather than a merged evidence database. Start with
`../scripts/run_desktop.ps1 -Python <python.exe>` after running upstream setup.
AI builder features require a separately configured coding agent or model.

Keep LICENSE-MIT, LICENSE-APACHE, NOTICE and ATTRIBUTION.md with distributions.
Original copyright and third-party notices remain applicable. Upstream brand
artwork in docs/brand is archival material, not Rootcastle branding; see its
separate license. No upstream endorsement is claimed. ROOTCASTLE-FORK.json
records the exact source revision and modifications.

Windows compilation and native window startup passed. Local Python and Rust
results, upstream pins and dependency advisory limitations are recorded in
[the verification report](../docs/DESKTOP-VERIFICATION.md). Optimized packaging,
signing and release CI remain pending. A local build does not prove every
upstream analyzer's accuracy.
