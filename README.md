# KVM Media Toggle

An AutoHotkey v2 script that automatically pauses and resumes media playback when you switch between computers using a KVM switch.

## The Problem

If you use a KVM switch to share monitors between multiple computers (e.g., work and home), media playing in a web browser (podcasts, music, etc.) keeps playing after you switch away. You come back later to find your podcast has been running for hours, or you've lost your place entirely.

There's no built-in way for the OS or browser to know that *you* are no longer at that computer when a KVM switches the display signal to another machine. High-end KVM switches with EDID and USB emulation make this harder — Windows doesn't even notice the monitors or devices are gone.

## How It Works

**Pause (switch away):** The script detects a double Right-Ctrl tap, which is the attention sequence used by many KVM switches (e.g., ConnectPRO, TESmart, Level1Techs). When detected, it sends the **Media Play/Pause** key to pause playback.

**Resume (switch back):** After pausing, the script waits for the KVM to settle, then watches for mouse movement. When you switch back and move the mouse, it sends **Media Play/Pause** to resume.

The media key approach works universally with any browser or app that responds to hardware media keys (Chrome, Edge, Firefox, Spotify, etc.).

## Requirements

- Windows 10/11
- [AutoHotkey v2](https://www.autohotkey.com/)

## Usage

1. Install AutoHotkey v2
2. Double-click `kvm-media-toggle.ahk`
3. The script runs in the system tray with a status tooltip

## Configuration

Edit the variables at the top of the script:

| Variable | Default | Description |
|---|---|---|
| `DOUBLE_TAP_MS` | `400` | Max time between RCtrl taps to count as double-tap (ms) |
| `SETTLE_TIME` | `3000` | Wait after switch-away before watching for return (ms) |
| `RETURN_POLL` | `250` | How often to check for mouse movement (ms) |
| `RESUME_DELAY` | `500` | Wait before resuming after detecting return (ms) |

## Auto-Start with Windows

1. Press `Win+R`, type `shell:startup`, press Enter
2. Create a shortcut to `kvm-media-toggle.ahk` in that folder
