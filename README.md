# EZPico

Desktop companion for Pico VR headsets. Installs games and apps over ADB,
manages the headset's packages and files, streams the view through scrcpy,
and pulls games from the PicoLand catalog.

Runs on Windows, macOS and Linux. Built with Flutter.

## Tabs

- **Device** — model, firmware, battery and storage at a glance; screenshot,
  Wi-Fi, reboot/shutdown and a raw ADB console
- **Install** — drop an `.apk`, `.zip`, `.rar` or `.7z` (multi-volume works);
  Auto picks the install method, Manual lets you choose Repack / Direct /
  Overport with signing and package options
- **App Manager** — launch, uninstall, extract APKs, back up and restore
  save data, edit permissions
- **File Manager** — browse the headset's storage, drag-and-drop copy,
  find the heaviest files
- **Stream** — scrcpy with per-eye cropping, resolution, fps, bitrate,
  codec and recording controls
- **PicoLand** — the community game catalog with covers, genre filters and
  one-click download & install from Yandex Disk, Google Drive and SberDisk
- **Settings** — language (EN/RU), accent color, folders, catalog updates,
  help and reset

## Building

```
flutter pub get
flutter build linux      # or: windows / macos
```

External tools (adb, unrar, scrcpy, apktool, apksigner, overport-cli, JRE)
are expected under the tools folder; the app looks for them next to the
binary and in `C:\ProgramData\ezpico\tools` / `~/.local/share/ezpico/tools`.

## License

GNU AGPL v3 — see [LICENSE](LICENSE).
