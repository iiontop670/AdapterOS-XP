# AdapterOS XP architecture — ADE 0.2

## Current boot path

UEFI/BIOS → GRUB → Linux kernel + initramfs → systemd → SDDM → Plasma Wayland session → KWin → ADE fullscreen desktop shell.

KWin remains the Wayland compositor and window manager. The XDG autostart helper stops the visible `plasmashell` process and launches `/usr/local/bin/adapter-desktop`, which supplies the desktop surface, shortcuts, Start menu and taskbar. This is an incremental shell integration; ADE is not a compositor or a standalone session manager yet.

## ADE components

- `ade/src/main.cpp`: Qt application entry point and allow-listed custom command backend.
- `ade/qml/Main.qml`: desktop surface, Start menu, taskbar, app frame, settings, files landing page, Notepad and Calculator.
- `ade/qml/SnakeGame.qml`: self-contained Snake game.
- `ade/sounds/`: original startup and UI sound effects embedded in Qt resources.
- `config/hooks/live/9990-build-ade.hook.chroot`: compiles ADE inside the Debian Trixie live chroot.
- `config/includes.chroot/etc/xdg/autostart/`: launches the ADE shell after the KDE session starts.

## Planned transition

1. Stabilize the ADE fullscreen shell and autostart behavior.
2. Implement real file browsing, desktop context menus and draggable windows.
3. Add more built-in games and native utilities.
4. Add application-level crash recovery and diagnostic reporting.
5. Build a dedicated ADE login/session path with KWin underneath, then remove the remaining Plasma session dependencies when it is reliable.

## Design rules

- Use system D-Bus and documented Linux interfaces.
- Use Polkit for privileged actions; never run the desktop as root.
- Use NetworkManager for networking and PipeWire/WirePlumber for audio.
- Use APT/dpkg for packages.
- Keep ADE terminal commands allow-listed; do not execute untrusted terminal input through a shell.
- Keep a recoverable fallback until ADE session startup and application integration are stable.
- Create original artwork and sounds; do not redistribute proprietary Windows XP assets.


### AdapterOS Defender 0.2.4

A low-idle-memory, user-initiated ClamAV scanner. It deliberately avoids the resident clamd/on-access services in the default VM/live configuration. Signature updates use FreshClam. PUA and heuristic alerts are disabled in the default scan profile for lower false-positive noise, with the corresponding coverage trade-off disclosed in the UI and release notes. Quarantine/restore is manual and scoped to the user's home directory. This is a first integration, not a complete endpoint security product.
