# TGWS-iOS | iPhone-only native port (starter)

**Makarov Lab's 3.0™ — native Swift / SwiftUI project baseline.**

> [!WARNING]
> This repository is a DEVELOPMENT STARTER, not a working MTProto proxy. It includes an iPhone UI skeleton, Keychain-backed credentials, configuration models and tested local Telegram-link construction. It does **not** contain an active listener, MTProto cipher bridge, remote transports, VPN or background service. Do not publish it as a release.

## Goal

Port [TGWS-Android](https://github.com/Kust3r3nk0/TGWS-Android) (0.4.0 Premium Minimal) to iPhone while retaining behavior of [Flowseal/tg-ws-proxy](https://github.com/Flowseal/tg-ws-proxy) and its pinned v1.11.2 reference. The original Android project remains independent and unchanged.

## Build

**Requirements:** macOS, Xcode with Swift 6 toolchain, XcodeGen, iOS Simulator. Use a personal/team signing profile for device and TestFlight builds.

```bash
xcodegen generate --spec project.yml
xcodebuild -project TGWSiOS.xcodeproj -scheme TGWSiOS -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
cd Packages/TGWSCore && swift test
```

Swift core models/tests also build on Linux. `xcodebuild` and physical iPhone validation have **not** been run in this preparation environment; the Xcode target has not been independently verified. The attached GitHub Actions macOS workflow is intended to perform the first real iOS build.

**Bundle identifier:** `io.github.kust3r3nk0.tgwsios` (change if reserved elsewhere). **Minimum target:** iOS 17.0. **Targeted device family:** iPhone (`1`), not iPad. The exact supported iPhones and lowest iOS version should be finalized after device testing.

## Start with these documents

1. [`CODEX_TASK.md`](CODEX_TASK.md) — direct instructions for Codex.
2. [`docs/TECHNICAL_SPEC_RU.md`](docs/TECHNICAL_SPEC_RU.md) — detailed specification / acceptance criteria.
3. [`docs/IOS_FEASIBILITY.md`](docs/IOS_FEASIBILITY.md) — mandatory feasibility gate for Telegram + iOS lifecycle.
4. [`docs/PORTING_MATRIX.md`](docs/PORTING_MATRIX.md) — source component mapping.
5. [`docs/TEST_MATRIX.md`](docs/TEST_MATRIX.md) — integration and device QA.
6. [`AGENTS.md`](AGENTS.md) — non-negotiable developer standards.

## Status

| Component | Starter status |
| --- | --- |
| TGWSCore Swift Package | Compiles; 7 Swift tests passed on Linux (Swift 6.2.1) |
| MTProto handshake/crypto | NOT IMPLEMENTED |
| Loopback listener | NOT IMPLEMENTED |
| WSS/TCP/Worker/HTTP2 | NOT IMPLEMENTED |
| iPhone SwiftUI screen skeleton | Written; iOS build not yet verified |
| Secret storage | Keychain implementation written; device behavior not verified |
| Background operation | BLOCKED pending technical feasibility |
| App icon | Placeholder catalog; import original licensed artwork |
| Distribution | NOT CONFIGURED |

## Licensing

MIT; retain original project attribution on ported code and protocol fixtures. Review images/assets separately. See [NOTICE.md](NOTICE.md).