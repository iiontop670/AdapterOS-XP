# Architecture — Phase 1

## Current boot path

UEFI/BIOS → GRUB → Linux kernel + initramfs → systemd → SDDM → Plasma Wayland session.

KWin is the Wayland compositor/window manager. Plasma currently provides the desktop shell. ADE is a separate Qt Quick prototype application.

## Planned transition

1. Stabilize the Debian live image.
2. Add AdapterOS branding and SDDM theme.
3. Build ADE panel, launcher, desktop and notification components.
4. Integrate ADE into a dedicated Wayland session.
5. Retain KWin for compositing/window management until a custom compositor is genuinely required.

## Design rules

- Use system D-Bus and documented Linux interfaces.
- Use Polkit for privileged actions; never run the whole desktop as root.
- Use NetworkManager for networking and PipeWire/WirePlumber for audio.
- Use APT/dpkg for packages.
- Keep a recoverable Plasma session until ADE is stable.
