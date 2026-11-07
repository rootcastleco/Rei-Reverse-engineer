# AI connections — API keys and provider accounts

In Settings → AI, Experiential Labs is offered as a hosted API preset with
`https://api.experientiallabs.ai/v1`. Paste the `xpl_...` key into the masked
field or set `EXPLABS_API_KEY` before starting REI. Keys use the existing OS
keychain/fallback-store mechanism and are not written into project settings.
The preset does not reuse `OPENAI_API_KEY` or `OPENROUTER_API_KEY`.

After adding the preset, use Change next to Model to retrieve its live model
catalog. Streaming and tool calls use the existing OpenAI-compatible adapter;
the initially suggested slug is configurable and does not restrict the catalog.
Model availability, credits and provider access are account-specific.

## Account sign-in without an API key

Settings → AI has a separate account section:

- **Sign in with ChatGPT** invokes the installed official `codex login`.
- **Sign in with Google (Antigravity)** invokes the installed official `agy login`.
- **Open Codex Cloud in browser** opens the official web workspace. This link
  does not claim to attach a browser/cloud chat to REI's local engine.

These two login commands run off the UI thread with cancellation and a five-minute
deadline. The provider opens the browser and stores its own credentials. REI
does not scrape cookies, read provider auth caches or retain login output. When
the official CLI exits successfully, REI registers that CLI as an Agent backend.
If a CLI requires terminal interaction, complete login in a terminal and use
Detect/Add for the already signed-in agent. Missing CLIs have setup links and
disabled login buttons. Signing in may require a paid plan or other entitlement;
"no API key" does not mean unlimited or free access.

Antigravity's official README documents starting `agy` to open browser onboarding.
The dedicated `agy login` command is also documented in Google's support forum;
its availability is version-dependent. If it is unavailable in the installed
version, start `agy` in a terminal and finish onboarding there before Detect/Add.

Codex Cloud remains a browser surface. Local work uses Codex CLI with the same
ChatGPT sign-in entitlement. Antigravity operations use the existing `agy`
adapter; version/flag checks and normal runtime consent remain in force.

## Verification boundaries

Local tests cover the preset, credential routing, fixed login command whitelist,
OpenAI-compatible streaming and model listing against a loopback HTTP fixture.
The combined AI/UI/CLI test run passed 352 tests on Windows with Rust 1.97.0;
the Python suite passed 64 tests with one optional-tool skip. The updated native
executable built successfully. The installed Codex CLI advertises `login`;
Antigravity CLI was not installed on the verification machine.
No live account sign-in or paid provider request was performed by the agent.
Those are user-controlled final steps, not implied by a passing mock test.

Sources checked 2026-11-02:

- [Experiential API quickstart](https://platform.experientiallabs.ai/docs/quickstart)
- [Codex authentication](https://learn.chatgpt.com/docs/auth?surface=cli)
- [Antigravity authentication](https://antigravity.google/docs/install?tab=cli)
- [Official Antigravity CLI authentication overview](https://github.com/google-antigravity/antigravity-cli#authentication)
- [Google support guidance for agy login](https://discuss.ai.google.dev/t/support-request-verification-required-error-in-antigravity-ide-pro-plan/184909/3)
