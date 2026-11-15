# AdapterOS XP — ADE desktop foundation and visual updates

## Added

- Luna-inspired fullscreen desktop surface and custom landscape wallpaper.
- ADE Start menu, taskbar, desktop shortcuts and clock/tray area.
- Custom allow-listed ADE terminal commands.
- Snake game with keyboard controls, score, pause and sound effects.
- Control Panel theme switching: Luna Blue, Silver, Olive and Classic.
- Basic My Computer landing page, Notepad, Calculator and About screen.
- Original bundled startup, click and error sounds.
- Live-build chroot hook that compiles ADE against the Debian Trixie Qt libraries.
- XDG autostart helper that launches ADE and hides the visible Plasma shell while leaving KWin as the compositor/window manager.

## Not yet included

- Full file manager operations and file associations.
- Multiple independently movable application windows.
- More built-in games.
- Persistent settings and Notepad documents in Live Mode.
- Real crash supervision and kernel panic recovery UI.
- Standalone ADE Wayland session and installer.

## Validation status

Shell scripts pass `bash -n` / `sh -n`. The Qt resource manifest parses as XML and bundled WAV files are valid mono 44.1 kHz PCM. The project has not been compiled with Qt or boot-tested in VirtualBox in this environment; the next GitHub Actions build and VM boot test are required to validate the full integration.

## 0.2.1 Wi-Fi firmware update

This maintenance update adds Debian 13 firmware packages for common Intel, Realtek,
Qualcomm/Atheros, Broadcom/Cypress, MediaTek/Ralink, Marvell/NXP and selected USB
wireless adapters. It also includes WPA supplicant support, the Linux wireless
regulatory database, `iw`, and `rfkill`. Kernel driver modules continue to come from
the standard Debian live-build kernel for amd64.

Wi-Fi hardware support depends on the exact adapter chipset and its support in the
Debian kernel. In VirtualBox, the default virtual network adapter is presented to the
guest as Ethernet; the host handles its own Wi-Fi connection. A guest needs a USB
Wi-Fi adapter passed through to it to see a physical wireless interface directly.


## 0.2.2 Luna visual polish

- Added a bundled, original high-resolution rolling-green-hills wallpaper with vivid blue sky, designed for the XP-era desktop aesthetic.
- Reworked the desktop shortcut layout into a single left-side column with clearer selection feedback.
- Refined the Luna-style Start button with a four-colour pane emblem, gloss highlight and more XP-like proportions.
- Improved taskbar bevel/highlight, notification tray spacing, Start menu sizing and blue glass title-bar gradients.
- Wallpaper is embedded into the Qt resource bundle, so it works offline in Live Mode.
- The exact Microsoft Windows XP Bliss photograph is not included; the bundled landscape is original artwork.


## 0.2.3 Task Manager and utilities

- Added an ADE Task Manager with a refreshable process list, PID, command name, CPU percentage and memory percentage.
- Added a confirmed End Task action that sends SIGTERM as the current live-session user; protected core and ADE process IDs are refused.
- Added a Performance view showing memory totals/availability and Linux load averages.
- Added a Utilities Center with System Information, Disk Usage, Network Status and Clock/Calendar pages.
- Added custom terminal shortcuts: `tasks`, `taskmgr`, `sysinfo`, `disk`, `network`, `clock`, `utilities`, and corresponding `launch` commands.
- Added Task Manager and Utilities shortcuts to the desktop and Start menu.
- System readings are obtained from `/proc`, `/sys` and Qt's `QStorageInfo`; no extra runtime package is required beyond the existing `procps` package.
- Process termination is a normal-user SIGTERM request only. It does not use sudo, force-kill processes, or claim to stop protected system services.
