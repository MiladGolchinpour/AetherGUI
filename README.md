# AetherGUI

macOS GUI wrapper for [Aether](https://github.com/CluvexStudio/Aether), bringing its terminal functionality to a light native desktop app.

![AetherGUI](docs/screenshot.png)

## Features

- Automatic endpoint discovery, with end-to-end data-plane validation so a gateway is only trusted once it actually passes traffic, not just once it answers the handshake
- MASQUE (HTTP/3 & HTTP/2), with optional TLS ClientHello fragmentation on HTTP/2
- WireGuard support
- Nested WireGuard mode (`gool`)
- Traffic obfuscation
- Automatic reconnection, and quick-reconnect to your last known-good gateway to skip rescanning
- Local SOCKS5 proxy

## Download & Usage

| Platform | Download |
|----------|---------|
| macOS Apple Silicon | [AetherGUI-macOS-arm64.dmg](https://github.com/MiladGolchinpour/AetherGUI/releases/download/v0.1.0/AetherGUI-macOS-arm64.dmg) |
| macOS Intel | [AetherGUI-macOS-x86_64.dmg](https://github.com/MiladGolchinpour/AetherGUI/releases/download/v0.1.0/AetherGUI-macOS-x86_64.dmg) |

- **DMG (.dmg)** — Open the disk image and drag **AetherGUI.app** into the **Applications** folder.

If Gatekeeper blocks the app, open **Terminal** and run:

```bash

xattr -dr com.apple.quarantine /Applications/AetherGUI.app

```

## Supported Protocols

### MASQUE (Recommended)

Encapsulates traffic over HTTP/3 (QUIC) or HTTP/2 (TLS), making it resemble ordinary HTTPS traffic.

### WireGuard

Fast and lightweight transport for networks with less aggressive inspection.

### Nested WireGuard (`gool`)

A WireGuard tunnel running inside another WireGuard tunnel, providing an additional encryption layer.

## Credits

Aether Core Developed by [**CluvexStudio**](https://github.com/CluvexStudio). :))
MASQUE support is built on top of Cloudflare's **Quiche** library.

## More Information
 - AetherGUI v0.1.0 uses Aether Core v1.2.0 (2026 Jul 16)