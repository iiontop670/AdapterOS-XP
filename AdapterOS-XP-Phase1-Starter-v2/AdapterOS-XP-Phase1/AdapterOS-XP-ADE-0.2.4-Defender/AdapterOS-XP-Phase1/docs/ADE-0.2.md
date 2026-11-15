# ADE 0.2 implementation notes

## Architecture

- `adapter-desktop` is a Qt 6 / QML fullscreen desktop shell application.
- KWin remains the Wayland compositor and window manager.
- An XDG autostart entry launches ADE after the KDE session starts and stops `plasmashell` so the Plasma panel does not compete with the ADE taskbar.
- ADE's C++ `AdeBackend` exposes a small allow-listed command interpreter to QML. It deliberately does not invoke a shell or execute arbitrary commands.
- Snake is a self-contained QML component using a Canvas, timer and keyboard input.
- Original WAV sound effects are embedded as Qt resources.

## Adding a new ADE command

Add a command branch to `AdeBackend::executeCommand()` in `ade/src/main.cpp`. For actions, return one of the known `@ACTION:` values and handle it in `Main.qml`'s `handleCommand()`. Keep commands allow-listed and do not pass terminal text into a shell process.

## Adding a built-in QML app

1. Add a QML component under `ade/qml/`.
2. Add it to `ade/resources.qrc` if it is loaded as a separate resource.
3. Add an application key/title/icon to `Main.qml`'s app helpers.
4. Add a page to the app `StackLayout` and a Start menu / desktop shortcut entry.
5. If the application adds a QML import, add its matching Debian runtime package to the ADE QML runtime section of the package list.

## Build integration

`scripts/configure-iso.sh` stages the ADE tree under `config/includes.chroot`. The live-build chroot hook compiles it after packages and includes have been configured. The hook installs the executable under `/usr/local/bin` and then removes build-only development packages. The XDG autostart desktop file and helper script are copied into the live filesystem through `config/includes.chroot`.

The implementation is an early milestone and should be boot-tested before treating the desktop startup integration as stable.
