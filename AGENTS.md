# Codex repository instructions (mandatory)

Language of developer-facing explanations and docs: **Russian**. Swift identifiers and test names: English. Target: **iPhone only**.

## Mandatory workflow

1. Read `CODEX_TASK.md`, `docs/TECHNICAL_SPEC_RU.md`, `docs/IOS_FEASIBILITY.md`, and `docs/PORTING_MATRIX.md` BEFORE changing runtime code.
2. Read authoritative Android core files, tests, and Flowseal reference; document exact commit SHAs and relevant source paths. Never reimplement by guessing protocol behavior.
3. Proceed in phases with separate reviewable commits or PRs. **Feasibility gate first.** No false release statements.
4. Preserve app icon/name in accordance with assets permissions; the iOS UI should be natively adapted, not recreated with a WebView.
5. Keep `main` green; use `feature/*` branches for risky experiments. Do not alter `Kust3r3nk0/TGWS-Android` or deploy/update Cloudflare infrastructure without explicit approval.
6. Run tests and document exact commands and results. Never claim tests that were not run.
7. Only the owner verifies physical iPhone behavior; request explicit results. Emulator/CI is not a substitute.

## Safety / privacy

- No disabling TLS certificate or hostname validation. No `acceptAll` trust delegate.
- No real secrets/tokens/Worker URLs in source, fixtures, logs, releases, screenshots or crash reports.
- Never persist MTProto secret or credential-bearing relay URL in `UserDefaults` or plaintext files; use Keychain.
- Listener must bind only to loopback; no `0.0.0.0` or LAN exposure.
- Do not use silent background audio, fake VoIP, geolocation or other fabricated background execution modes.
- Do not add `NEAppProxyProvider` as a consumer-iPhone solution; Apple restricts it to managed devices.
- Do not silently switch from Telegram-only proxy to a system-wide VPN/packet tunnel.
- No fake success states, hardcoded latency, fake test reports, fabricated routes/sessions.
- Limit buffer sizes, session counts, timeouts, connection fanout and retries. Never replay payload after uncertain delivery.
- Only explicit user action may reveal or copy a secret-bearing Telegram URL.

## Quality gates

- Swift 6, SwiftUI, native Foundation/Network/Security APIs wherever feasible.
- `swift test` for portable package; XcodeGen project generation and `xcodebuild` on macOS; unit, integration and UI tests.
- Compare protocol vectors byte-for-byte with pinned Android/Flowseal fixtures.
- No iOS release until real-device tests validate connectivity and app lifecycle; report known limitations if unresolved.
- Update `docs/PORTING_MATRIX.md` and README for each completed milestone.