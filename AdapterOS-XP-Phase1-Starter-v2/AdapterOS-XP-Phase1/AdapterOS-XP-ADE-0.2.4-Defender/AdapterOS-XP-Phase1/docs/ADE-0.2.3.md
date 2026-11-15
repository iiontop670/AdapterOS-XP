# Adapter Desktop Environment 0.2.3

## New applications

### Task Manager
- Refreshable process list (up to 100 rows), sorted by CPU usage.
- Shows process name, PID, CPU percentage and memory percentage.
- End Task asks for confirmation and sends SIGTERM using the ADE user's permissions.
- Refuses PID 1 and the ADE process itself. Permission errors are shown instead of elevating privileges.
- Performance page shows memory totals/availability, memory usage percentage, and kernel load averages.

### Utilities Center
- System Information: OS, hostname, CPU model, architecture, kernel and uptime.
- Disk Usage: root filesystem size, used space, available space and filesystem type.
- Network Status: interfaces from `/sys/class/net`, link state, MAC address and wireless-interface marker.
- Clock and Calendar: live local time/date plus system uptime.

## Terminal commands

- `tasks` or `taskmgr` — open Task Manager.
- `sysinfo` — open System Information.
- `disk` — open Disk Usage.
- `network` — open Network Status.
- `clock` — open Clock and Calendar.
- `utilities` — open Utilities Center.
- `launch <app>` — open a supported ADE application.

The terminal remains a custom command console; it does not execute arbitrary shell text.

## Live Mode notes

System readings describe the running live environment. Disk usage may reflect the live overlay rather than a persistent installation disk. Network Status shows guest-visible interfaces; when VirtualBox uses NAT, the physical Wi-Fi connection remains managed by the host.
