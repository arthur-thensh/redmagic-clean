# RedMagic Clean

RedMagic Clean is a conservative command-line toolkit for auditing and, in later versions, simplifying REDMAGIC smartphones through ADB without root, bootloader unlocking, custom ROMs, or system-partition modification.

## Current status

**Version 0.1.0 — Audit only**

The current version is intentionally read-only. It does not disable, uninstall, install, or modify anything on the connected Android device.

Implemented features:

- verify that `adb` is available;
- require exactly one connected and authorized Android device;
- explicitly select the detected device by serial number;
- detect the active Android user;
- collect manufacturer, brand, model, device codename, Android version, SDK level, security patch and build information;
- collect all, system, third-party and disabled package lists;
- create a timestamped local audit report;
- print a concise terminal summary.

The audit layer is intentionally generic Android infrastructure. REDMAGIC/Nubia-specific package classification will only be added after reviewing audit data from a real device.

## Requirements

- macOS or Linux;
- Bash;
- Android SDK Platform-Tools (`adb`);
- USB debugging enabled on the Android device.

No root access is required.

## Installation

```bash
git clone https://github.com/arthur-thensh/redmagic-clean.git
cd redmagic-clean
chmod +x redmagic-clean.sh
```

## Usage

Run an audit:

```bash
./redmagic-clean.sh audit
```

Show help:

```bash
./redmagic-clean.sh help
```

Show the installed RedMagic Clean version:

```bash
./redmagic-clean.sh version
```

## Audit output

Reports are written locally under:

```text
reports/<DEVICE>/<TIMESTAMP>/
```

Example:

```text
reports/PIXEL_9A/2026-08-15_021850/
├── audit.log
├── build.txt
├── device.txt
├── packages-all.txt
├── packages-system.txt
├── packages-third-party.txt
└── packages-disabled.txt
```

### `device.txt`

Contains the detected device identity, Android user, Android version, SDK level and security patch.

### `build.txt`

Contains the main build properties used to identify the installed firmware.

### Package inventories

Package files contain one normalized package name per line and are sorted to make future comparisons deterministic.

- `packages-all.txt`: all packages visible to the active Android user;
- `packages-system.txt`: system packages;
- `packages-third-party.txt`: third-party packages (`pm list packages -3`);
- `packages-disabled.txt`: currently disabled packages.

### `audit.log`

Records the audit steps and collection counts. It does not contain modification actions because v0.1 performs none.

## Safety model

RedMagic Clean v0.1 does not execute commands such as:

```text
pm disable-user
pm enable
pm uninstall
pm install-existing
settings put
adb install
```

It also does not root the device, unlock the bootloader, flash partitions, remount `/system`, use EDL, or exploit Android security mechanisms.

Future modification features will be designed around reversibility, dry-run support, explicit confirmation and conservative package classification.

## Repository structure

```text
redmagic-clean/
├── redmagic-clean.sh
├── lib/
│   ├── adb.sh
│   ├── audit.sh
│   ├── device.sh
│   └── ui.sh
├── reports/
│   └── .gitkeep
├── README.md
└── .gitignore
```

## Roadmap

- **v0.1** — generic read-only device audit;
- **v0.2** — conservative package classification;
- **v0.3** — dry-run planning;
- **v0.4** — reversible disable/restore;
- **v0.5** — cleaning profiles;
- **v0.6** — post-clean validation tests;
- **v0.7** — OTA audit comparison;
- **v1.0** — stable RedMagic Clean release.

No REDMAGIC package should be classified as safe to disable solely from an arbitrary internet list. Device-specific classification will be based on real audit data and reviewed before any modification workflow is introduced.
