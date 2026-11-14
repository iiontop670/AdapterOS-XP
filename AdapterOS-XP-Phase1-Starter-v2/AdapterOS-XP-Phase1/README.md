# AdapterOS XP — Phase 1 starter

Debian 13 (Trixie), amd64, live-build, Wayland/KWin foundation, and a tiny Qt 6/QML ADE prototype.

## Important scope

This is a development starter, not a finished operating system or installer. The ISO built here is a live image. Disk installation, a custom login theme, a replacement desktop shell, and the full ADE applications are later milestones.

The first image uses Debian's KDE Plasma/KWin components as reliable Wayland infrastructure. ADE is currently a standalone prototype application, not yet the session shell.

## Build the ISO

Use a Debian 13 amd64 machine or VM. Suggested VM allocation: 4 CPU cores, 8–12 GiB RAM, and 60 GiB disk.

Install build tools:

```bash
sudo apt update
sudo apt install -y live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools git
```

From this directory:

```bash
chmod +x scripts/*.sh
./scripts/configure-iso.sh
./scripts/build-iso.sh
```

The output should be `live-image-amd64.hybrid.iso` in this directory. The first build downloads Debian packages and can take a while.

If the build fails because a package name is unavailable, check it with:

```bash
apt-cache policy PACKAGE_NAME
```

Do not switch the base to Debian Testing to work around a missing package. Fix the package list against Debian 13/Trixie instead.

Clean generated build state:

```bash
./scripts/clean-iso.sh
```

## Test in VirtualBox

Create a new Linux/Debian 64-bit VM, attach the ISO as an optical disk, enable EFI, give it 4 CPUs and 8 GiB RAM, then boot. Test live mode only. Do not install it over your main computer.

## Build the ADE prototype

Install Qt 6 development dependencies on a Debian 13 development machine:

```bash
sudo apt install -y build-essential cmake ninja-build qt6-base-dev \
  qt6-declarative-dev qt6-wayland-dev
```

Build:

```bash
cmake -S ade -B ade/build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build ade/build
./ade/build/adapter-desktop
```

The prototype is an ordinary Qt Quick application. It does not yet manage windows, replace Plasma, or act as a Wayland compositor.

## Repository layout

- `config/package-lists/`: packages included in the live image
- `scripts/`: repeatable ISO build commands
- `ade/`: Qt 6/C++ desktop-shell prototype
- `branding/`: initial text branding and asset notes
- `docs/`: architecture and milestone notes

## Reproducibility and safety

- Build as a normal user; the scripts request sudo only for `live-build`.
- Keep source control clean and commit changes before major build changes.
- Test in a VM before writing an ISO to removable media.
- This starter does not repartition disks or run an installer.


## Optional: build the ISO with GitHub Actions

The repository includes `.github/workflows/build-iso.yml`. Push the project to a GitHub repository, then open **Actions → Build AdapterOS XP ISO → Run workflow**. The workflow uses a Debian Trixie hosted job container, installs the ISO tooling, builds the live image, and uploads `AdapterOS-XP-0.1-amd64` as a downloadable workflow artifact. This route requires GitHub Actions to be enabled for the repository.
