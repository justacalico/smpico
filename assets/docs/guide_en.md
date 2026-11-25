# EZPico guide

EZPico installs games and apps on PICO headsets from a PC: it extracts archives, prepares the APK, installs it and moves the game cache. It also has an app manager, a file manager, a headset screen stream and the PicoLand game catalog.

> **Tooltips.** Hover over any button or icon for a second to see what it does.

## 1. Preparing the headset

1. Enable **developer mode**: *Settings → General → About*, tap "Software version" several times.
2. In *Developer*, enable **USB debugging**.
3. Connect the headset with a data USB cable.

The headset appears in EZPico by itself. With several headsets, pick one in the selector on the **Device** tab.

## 2. Device

Model, firmware, battery, storage and the **PUI Matrix** version. Matrix is the PICO license check service: version **9.9.9** (green with a check mark) means the headset is cracked and PICO protection is removed — good. Buttons: **Screenshot**, **Wi-Fi** (switch to wireless — PC and headset must be on the same network), **Reboot**, **Shutdown**. **ADB console** — manual `adb shell` commands, which can be saved.

## 3. Installation

Drop files onto the tab or use "Choose files…" / "Choose folder…". Supported: `.apk`, `.zip / .rar / .7z` (multi-volume too) and game folders.

- **Auto** mode (recommended) — EZPico picks the method itself. With **PUI Matrix 9.9.9** on the headset (protection removed) games are installed **clean**: nothing renamed or stripped from the APK.
- **Manual** mode — you choose:
  - **Repack** — decompile, add a package suffix, strip metadata, rebuild and sign. Main method for cracked games from the PICO store.
  - **Direct** — the APK is installed unchanged.
  - **Overport** — re-sign with a new key, no repack (games ported from Quest via OVRport).
  - Options: package suffix (installs next to the original), new signing key, keep SDK metadata, store installer (`-i com.picovr.store`), game cache (OBB) folder.

Each install is a card with stages and a detailed log; it can be cancelled any time. **Installed** keeps the history.

## 4. App manager

All headset apps: launch, uninstall, save APK to PC, back up / restore game saves, permissions. Wrong icons — *Settings → Files → App icons cache → Clear*.

## 5. File manager

Browse headset storage, copy to/from the PC (drag and drop), create, rename, delete. "Heaviest files" shows what takes space. F5 — refresh, Alt+←/→ — back/forward.

## 6. Stream

Headset screen on the PC (scrcpy): eye, resolution, frame rate, bitrate, codec, sound, recording to video.

## 7. PicoLand catalog

Search, genres, covers, descriptions. Filters: language, type (OVRport / FNAL), **size** (< 1 GB / 1–5 GB / 5+ GB by the full archive; unknown sizes are hidden when a range is selected), sorting, "Downloadable". On a game page:

- **← Back to catalog** or **Esc**;
- **▶** — trailer, **Telegram** icon — the original post;
- link dot: green — available, red — removed, grey — not checked;
- **Download and install** — EZPico downloads and installs the game;
- cloud / Telegram icon — open the link, chain icon — copy it.

Catalog installs use **auto mode** by default; post hints (cache target and folder name) are applied automatically. The **gear** icon next to "Download and install" or on a download row opens full install settings (method, suffix, SDK, signing key, store installer, cache) — before, during or after the download, or "download only". The "From the post" block is the post author's text as is.

## 8. Telegram sign-in

Some PicoLand games live in Telegram channels: *Settings → Telegram → Sign in with QR*.

- QR code only, like "Link desktop device" in Telegram. No phone number.
- A 2FA password, if any, goes straight to Telegram and is never stored.
- By default the session is kept in memory only and is logged out when EZPico closes.
- **Remember me** stores it encrypted with Windows DPAPI in `%LOCALAPPDATA%\EZPico\telegram.session`.
- **Sign out** ends the session and deletes the file. Telegram data never gets into reports, logs or settings.

## 9. Settings

Interface, Device, Files, PicoLand catalog, Telegram, **Help and reset** (this guide, welcome screen, **reset all settings**), Support (**Create report** — headset info, packages, install history and logs, no passwords or Telegram data), Developer (debug console, tools folder).

**Reset all settings** returns EZPico to its first-launch state. Installed games, saves, screenshots and the Telegram sign-in are not touched.

## 10. Stored data

Everything stays on your PC: settings — `HKCU\Software\EZPico`; work files, history, backups, screenshots, recordings, reports — `C:\ProgramData\ezpico_workspace`; tools — `C:\ProgramData\ezpico\tools`; Telegram session (only with "Remember me") — `%LOCALAPPDATA%\EZPico\telegram.session`.

## 11. Support the project

EZPico is free and made by one person — **Cka3ka** ([@Cka3kaTG](https://t.me/Cka3kaTG)). See the **Support** tab. Thank you!
