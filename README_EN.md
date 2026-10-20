<p align="center"><img src="docs/images/tgws-ios-cover.svg" width="100%" alt="TGWS-iOS — native iPhone port" /></p>

# TGWS-iOS

**A native iPhone-only port of [TGWS-Android](https://github.com/Kust3r3nk0/TGWS-Android)** by Makarov Lab's 3.0™. It targets Swift 6, SwiftUI and a local MTProto proxy compatible with selected WSS/TCP/relay transports. [Русский README](README.md).

> [!IMPORTANT]
> **Development starter only. Not a working Telegram proxy.** The Swift configuration package, UI skeleton, secure credential storage draft and tests do not establish functional MTProto routing, background execution or iPhone support. No stable release is available.

## Intended architecture

`Telegram for iOS → 127.0.0.1:1443 → TGWSCore (MTProto) → WSS / TCP / optional owned relay → Telegram DC`.

The primary feasibility risk is that ordinary iOS apps can be suspended in the background. The first milestone (F0) must validate genuine Telegram sessions and app lifecycle **on a physical iPhone**. Do not substitute background-audio hacks or an MDM-only app proxy for proof.

## Stack

![Project technology stack](docs/images/tgws-ios-stack.svg)

| Layer | Technology |
| --- | --- |
| Core | Swift 6 / Swift Concurrency |
| UI | SwiftUI (iPhone only) |
| Network | Network.framework, URLSession, TLS |
| Storage | Keychain |
| Build | Xcode, XcodeGen, Swift Package Manager |

## Current roadmap

- [ ] F0: local listener, real handshake, owner-run iPhone Telegram and background tests
- [ ] F1: MTProto, AES-CTR, Fake TLS, framing, protocol vector parity
- [ ] F2: Direct WSS/TCP and Relay-only, fail-closed and bounded retries
- [ ] F3: optional Auto Cloudflare, compatible Workers, HTTP/2 media
- [ ] F4: Premium Minimal iPhone UI, RU/EN, diagnostics and secure settings
- [ ] F5: CI, physical QA, signed TestFlight / App Store distribution

## Build

Requirements: macOS and compatible Xcode, XcodeGen, Swift 6.

```bash
cd Packages/TGWSCore && swift test && cd ../..
xcodegen generate --spec project.yml
xcodebuild -project TGWSiOS.xcodeproj -scheme TGWSiOS \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

These commands are instructions, **not an attestation of a successful iOS build**. See [Codex task](CODEX_TASK.md), [full specification](docs/TECHNICAL_SPEC_RU.md), [feasibility](docs/IOS_FEASIBILITY.md), [port matrix](docs/PORTING_MATRIX.md) and [tests](docs/TEST_MATRIX.md).

## Security, license and attribution

Keep private endpoint URLs and credentials in Keychain, validate TLS certificates and names, bind only loopback, do not replay ambiguously delivered payloads, and never claim device tests that have not happened.

MIT licensed; see [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). Independent project, not affiliated with Telegram, Apple or the upstream maintainers.
