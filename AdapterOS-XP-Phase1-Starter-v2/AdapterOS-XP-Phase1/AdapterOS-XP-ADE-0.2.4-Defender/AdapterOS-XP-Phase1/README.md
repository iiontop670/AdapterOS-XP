# AdapterOS XP — ADE 0.2.4 Luna desktop and Defender

AdapterOS XP is a Debian 13 (Trixie) amd64 live-system project with a Windows XP Luna-inspired desktop experience. ADE (Adapter Desktop Environment) is built with C++17, Qt 6 and QML.

## ADE 0.2.4 visual update and existing ADE features

- Full-screen Luna-inspired desktop with a bundled high-resolution original rolling-green-hills and blue-sky wallpaper, embedded in the Qt resources for offline Live Mode.
- Refined Start menu, glossy green Start button with four-colour emblem, XP-blue taskbar, compact Quick Launch shortcuts, clock/tray area and two-column desktop shortcut layout.
- ADE custom command console (not an unrestricted shell).
- Built-in Snake game.
- Control Panel with Luna, Silver, Olive and Classic color themes.
- Basic My Computer landing page, Notepad and Calculator.
- ADE Task Manager with process list, PID, CPU/memory percentages, confirmed SIGTERM End Task action and memory/load overview.
- Utilities Center with System Information, Disk Usage, Network Status and Clock/Calendar.
- Original short startup, click and error sounds.
- Live-build hook compiles the ADE binary inside the Debian Trixie chroot.
- XP-era blue glass title bars, improved desktop icon selection feedback and refined taskbar bevel/highlight. KDE Plasma's panel process is stopped after login; KWin remains the compositor/window manager.

This is an early desktop-shell milestone, not a finished Windows-like operating system. The Files page is currently a navigation foundation rather than a full file manager. The custom terminal intentionally accepts only ADE commands; it does not run arbitrary Linux shell commands.

## Build the ISO

Use Debian 13 amd64 or GitHub Actions with the configured workflow. Required host tools include `live-build`, `debootstrap`, `squashfs-tools`, `xorriso`, GRUB utilities and `dosfstools`.

From the project root:

```bash
chmod +x scripts/*.sh
./scripts/configure-iso.sh
./scripts/build-iso.sh
```

The configure script:

1. Configures Debian Trixie live-build.
2. Uses the correct `trixie-security` APT suite.
3. Stages the ADE source under `config/includes.chroot/usr/src/adapteros/ade`.
4. Adds the ADE compile hook.

During `lb build`, `config/hooks/live/9990-build-ade.hook.chroot` compiles and installs `/usr/local/bin/adapter-desktop` inside the live chroot. It then removes the build-only CMake/compiler/Qt development packages where no longer required.

## Live desktop startup

The image includes `/etc/xdg/autostart/adapteros-ade.desktop`. After the KDE session and KWin start, the helper stops the visible Plasma shell and launches the ADE fullscreen desktop application. KWin remains responsible for Wayland compositing and window management. This is a practical first shell integration step; ADE is not yet an independent Wayland compositor or a complete standalone session manager.

## Custom ADE terminal commands

Open ADE Terminal from the Start menu or desktop shortcut. Supported commands include:

```text
help
about
version
games
launch snake
launch calculator
launch notepad
launch files
launch settings
launch taskmgr
launch utilities
launch sysinfo
launch disk
launch network
launch clock
sysinfo
tasks
disk
network
clock
theme luna
theme silver
theme olive
theme classic
whoami
date
time
echo hello
sound test
clear
exit
```

`exit` closes the terminal application window, not the desktop. `Ctrl+Alt+T` opens ADE Terminal; `Ctrl+Alt+S` toggles the Start menu.

## Building ADE separately

On a Debian 13 development machine:

```bash
sudo apt update
sudo apt install -y build-essential cmake ninja-build qt6-base-dev qt6-declarative-dev qml6-module-qtmultimedia
cmake -S ade -B ade/build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build ade/build
./ade/build/adapter-desktop
```

Qt Multimedia's QML module is used only for playback of the bundled original WAV sound effects. QML module runtime packages are listed in `config/package-lists/adapteros-xp.list.chroot`.

## VirtualBox test settings

Start with 2 virtual CPUs, 4–8 GiB RAM, VMSVGA and 128 MiB video memory. Keep 3D acceleration disabled for the first test; enable it later only if Guest Additions and the host graphics driver behave correctly. The live session is temporary: changes made inside it are not retained after shutdown unless a persistence or installation path is added.

## Current limitations

- The ADE desktop is a fullscreen shell application launched inside the KDE/KWin session; KWin still manages the Wayland session.
- My Computer currently provides a navigation landing page; complete file browsing and file operations are not implemented yet.
- Notepad contents are session-local and disappear on shutdown.
- Snake is the first complete game; additional games are future work.
- Sound playback depends on the guest's audio device being available.
- Crash handling currently covers ADE application-level diagnostics as a future milestone; kernel panic handling is not provided by this GUI.
- Task Manager process rows are limited to the 100 highest-CPU entries. End Task sends SIGTERM without privilege escalation; protected or other-user processes may refuse termination.
- Always test the ISO in a virtual machine before using physical hardware.


## AdapterOS Defender 0.2.4

ADE includes a lightweight on-demand ClamAV interface. It intentionally uses no persistent `clamd` daemon or on-access scanner in the default Live image, to keep idle memory use lower in small VMs. `clamav-freshclam` is enabled for signature updates when networking is available. The default scan profile leaves PUA detection and heuristic alerts disabled to reduce false positives; this trades away some detection coverage and is explained in the Defender UI. Scanning is on-demand only (no always-running file monitor), and the first signature database download requires a working network connection. Detections are never deleted automatically. Users must confirm quarantine and can restore quarantined items. Scanning and quarantine are restricted to regular files under the current user's home directory. See `docs/ADE-0.2.4.md`.
