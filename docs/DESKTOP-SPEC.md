# REI Reverse Engineer Desktop — initial fork contract

1. Preserve upstream analysis, consent, project and evidence behavior.
2. Launch a native Windows window titled REI Reverse Engineer with application ID
   `com.rootcastle.rei` and an independently drawn Rootcastle icon.
3. Store settings in a separate `rei-reverse-engineer` config directory; new projects
   default to `Documents/REI Reverse Engineer`. Never migrate or overwrite upstream
   configuration automatically.
4. Preserve upstream copyright, MIT/Apache license and third-party attribution.
5. Record the upstream source commit and local modifications explicitly.
6. Build the `rei-reverse-engineer` binary with the existing locked Rust dependency
   graph. The Python CLI/MCP contract remains independently testable.

Verification gates: Windows compilation; native window/title smoke test;
desktop/UI unit tests; Python regression tests; source and license checks.
Unmeasured upstream claims are not verification of this fork.

Implemented: local Python and upstream REA MCP routes and real static-analysis
bridge smoke calls. Follow-up: shared evidence-store interchange, Turkish UI coverage,
optimized portable package and installer, signed release, platform CI and
independent verification of the engines used on representative artifacts.
