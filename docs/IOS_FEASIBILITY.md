# Gate F0 — iPhone / Telegram / iOS feasibility

**Status: NOT TESTED on physical iPhone.** A TCP listener or valid tg:// link is not proof of a working Telegram proxy.

## Apple references and limits

- Ordinary iOS apps may be suspended in background: https://developer.apple.com/documentation/xcode/configuring-background-execution-modes
- NWListener API: https://developer.apple.com/documentation/network/nwlistener
- Network Extension provider deployment and entitlements: https://developer.apple.com/documentation/technotes/tn3134-network-extension-provider-deployment
- Packet tunnel is a different architecture: https://developer.apple.com/documentation/networkextension/nepackettunnelprovider
- App Review rules: https://developer.apple.com/app-store/review/guidelines/

## Mandatory proof-of-concept

1. Start an NWListener bound exclusively to 127.0.0.1 (initial port 1443) on physical iPhone; prove it is not reachable from LAN.
2. Implement actual MTProto handshake, verified against real protocol fixtures. An accepted TCP connection is insufficient.
3. Generate local tg://proxy link; open Telegram for iOS and demonstrate working messages, media and real transport sessions.
4. Test foreground, Telegram foreground while TGWS in background, locked screen, 1/5/15 minutes, force quit, app restart.
5. Test Wi-Fi and mobile data, network changes, dual stack / NAT64 when available.
6. Document iOS entitlements and background behavior; no bogus audio, geolocation or VoIP background modes.

## Decision

- **PASS:** real Telegram connectivity and acceptable lifecycle on physical iPhone, documented by owner. Continue F1-F5.
- **PARTIAL:** foreground-only or temporary connectivity. Label clearly as experimental; require owner approval.
- **FAIL:** unusable iOS lifecycle. Stop, write report, discuss separately approved remote gateway or another architecture.

Do not silently introduce system-wide VPN, MDM-dependent per-app proxy or packet tunnel.
