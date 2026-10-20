# TGWS-iOS Test / Acceptance Matrix

This is a checklist, **not measured test results**. Every report must state platform, commands, commits, fixtures and actual outcomes. Never invent network timings, sessions or device evidence.

## Swift protocol tests
- [ ] Byte-for-byte comparison with pinned Android/Flowseal vectors: AES-CTR directions, SHA256/HMAC, handshake/relay init
- [ ] Local ef, ee, dd modes; invalid/reserved 64-byte headers; supported DC1–5 and 203; signed media DC
- [ ] Packet framing under fragmentation/coalescing, oversize, invalid and incomplete lengths
- [ ] Independent cipher state per session, no key/secret exposure
- [ ] Timeout and cancellation behavior; <=8 active sessions; bounded buffers

## Network integration with controlled fixtures
- [ ] Direct WSS / TCP fallback; TLS/hostname errors fail closed
- [ ] Relay-only error produces **no direct network request**
- [ ] Worker URLs and DC path routing; credential paths remain private
- [ ] Auto-CF candidate limits, retries 1–30s and no payload replay
- [ ] Ping/Pong and high-throughput sends/receives, stalled sockets
- [ ] H2 media only with real compatible ALPN h2 fixture
- [ ] Cleanup after network loss, cancellation, stop and application suspension

## Owner physical iPhone checks
- [ ] Telegram iOS recognizes local tg://proxy link and connects
- [ ] Real text messaging and receiving, voice/media and SD/HD photos
- [ ] TGWS foreground / Telegram foreground, screen lock for 1/5/15 min, force quit and relaunch
- [ ] Wi-Fi, mobile data, interface switch, airplane mode and IPv6/NAT64 when available
- [ ] Memory/battery review; repeated start/stop cycles
- [ ] Keychain values persist across process restart/update, corruption is handled explicitly
- [ ] RU/EN UI, Dynamic Type, VoiceOver, dark/light appearance

## CI
- `cd Packages/TGWSCore && swift test` on Linux/macOS with Swift 6
- XcodeGen generation and unsigned Simulator build on macOS runner
- Physical device verification belongs to owner, never CI
- Stable release forbidden until F0 and subsequent owner sign-off
