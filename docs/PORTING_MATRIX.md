# Porting matrix: TGWS-Android 0.4.0 → TGWS-iOS

Reference: https://github.com/Kust3r3nk0/TGWS-Android (pin exact SHA in PR).
Original: https://github.com/Flowseal/tg-ws-proxy v1.11.2, Android-documented SHA `307a384ab7f522e34bb1a045884d0bd90f40bee5`.

| Android module | Target Swift module | Requirement |
| --- | --- | --- |
| MtprotoCrypto.kt | TGWSCore/Protocol/MTProtoCrypto.swift | Verified SHA-256/AES-CTR vectors and direction/state parity |
| FakeTls.kt | TGWSCore/Protocol/FakeTLS.swift | dd/ee and HMAC validation |
| PacketSplitter.kt | TGWSCore/Protocol/PacketFramer.swift | Bounded frames, arbitrary fragmentation/coalescing |
| MtprotoServer.kt | TGWSCore/Proxy/LoopbackMTProtoServer.swift | 127.0.0.1 only, handshake, Telegram DC/media, bounded sessions |
| RawWebSocket.kt | TGWSCore/Transport/WebSocketTransport.swift | Binary RFC6455, TLS/hostname validation, ping/pong, cancellation |
| TransportSettings.kt | TGWSCore/Configuration/TransportSettings.swift | Direct/Relay-only/Auto-CF parity |
| RouteBackoff.kt | TGWSCore/Routing/RetryBudget.swift | Finite attempts and 1–30s backoff |
| SetupTimings.kt | TGWSCore/Diagnostics/SetupTimings.swift | Only actual measured phases |
| ProxyService.kt | TGWSApp/Runtime/RuntimeController.swift | iOS lifecycle; no fake background service |
| AndroidNetworkMonitor | TGWSCore/Network/PathMonitor.swift | NWPathMonitor and real path transitions |
| SettingsStore.kt | TGWSApp/Security/KeychainStore.swift | Credential confidentiality and explicit errors |
| MainActivity.kt / Compose | SwiftUI | iPhone Home, Diagnostics, Settings, Premium Minimal |
| UpdateWorker.kt / UpdateInstaller.kt | UpdateCenter | TestFlight / App Store, no APK and no silent IPA install |
| cloudflare-worker / relay | Server side unchanged | Compatibility testing only; no deployments without approval |

## Protocol parity

- MTProto Obfuscated2 initial header is 64 bytes. Support valid local tags ef/ee/dd, verify invalid/reserved prefixes and DC 1–5/203 including signed media DC.
- Telegram local link uses 127.0.0.1 and `dd + 32-HEX secret`; Fake TLS uses `ee + secret + HEX(domain)`.
- Direct: WSS and bounded TCP fallback. Relay-only: **never** silently dial direct. Auto Cloudflare: explicit authorized Worker/compatible CF routes, bounded attempts, fallback only as specified by Android.
- Verify TLS chain and hostname, never disable validation or implement arbitrary fronting.
- HTTP/2 media support is a separate stage: only when server supports /api and ALPN h2. Never fake H2 results.
- Existing Worker limitation 16 MiB/session may interrupt HD media; client UI must not claim to fix this.
- IPv4/IPv6/DNS64/NAT64 and connectivity transitions require tests, not guessed routing.
- Never replay payloads if delivery to upstream is ambiguous; put upper bounds on buffers, retries and sessions.

All entries are TARGETS. Only configuration models, link generation, UI skeleton and Keychain code are in the starter. MTProto engine and transport are NOT implemented.
