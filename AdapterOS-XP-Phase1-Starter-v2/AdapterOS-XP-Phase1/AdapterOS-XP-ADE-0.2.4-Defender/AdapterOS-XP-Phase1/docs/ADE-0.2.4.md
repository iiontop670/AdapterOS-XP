# AdapterOS XP ADE 0.2.4 — Defender foundation

## AdapterOS Defender

- Adds a native Luna-styled Defender page to ADE, Start menu and desktop.
- Uses Debian 13's ClamAV CLI (`clamscan`) and FreshClam signature updater.
- Uses signature-first conservative scan arguments: PUA detection is not enabled and heuristic alerts are explicitly disabled in the default profile to reduce noisy detections. This reduces some detection coverage; it is not a claim of zero false positives.
- Scans only regular files/folders inside the current user's home directory. The default target is `~/Downloads` when present, otherwise the home folder.
- Uses recursive scans with archive/file/time limits to reduce resource exhaustion and avoid crossing filesystem boundaries. Some large or deeply nested content can be skipped; the UI explains that a scan is not a guarantee of cleanliness.
- Does not run `clamav-daemon` or `clamonacc` by default. The `clamscan` process loads signatures only when a user starts a scan and exits when done, trading scan-start time for lower idle memory use.
- Enables the `clamav-freshclam` systemd updater service where available. Database freshness and service state are displayed. Initial signature downloads require network access.
- Never auto-deletes or auto-quarantines. Each detection is shown for review; quarantine requires confirmation, moves the file to a user-private directory, records restore metadata and a SHA-256 hash, and restore also requires confirmation.
- Quarantine/restore only supports scanned files under the user's home directory. It refuses symlinks and verifies copies on cross-filesystem moves.

## False-positive policy

ClamAV detections are indicators, not infallible proof. Potentially unwanted application (PUA) detection is deliberately left off because ClamAV warns that PUA alerts can be aggressive. Heuristic alerts are also disabled in the default scan profile. This improves precision for the default experience but can miss threats that would only be identified by those heuristics or PUA signatures. Files are never deleted automatically, and users can restore quarantined files.

## Lightweight design

- No permanently resident `clamd` scanner or on-access scanner is started.
- Manual scans use one ClamAV process and bounded archive/file/time settings.
- FreshClam performs periodic database checks independently.

## Build and test status

This is a first integration milestone. Run `scripts/check-ade-source.sh`, build the ISO in GitHub Actions, then test in VirtualBox. Do not describe Defender as fully tested or as complete endpoint protection until scanning, database updates, quarantine/restore, and failure cases have been tested in the built ISO.


## What this version does not claim

- It is not real-time/on-access protection; there is no continuously running file monitor.
- It is not a complete endpoint security suite and does not yet provide a Defender firewall-management page or network intrusion detection.
- It does not scan outside the signed-in user's home directory from the ADE UI.
- The Live ISO does not assume fresh virus definitions are bundled. The FreshClam service must obtain them over a working network connection; until a database is present, the Scan button remains disabled.
- Disabling PUA and heuristic alerts can reduce false-positive noise but also misses detections that rely only on those signals. A clean result is not proof that a system is malware-free.
