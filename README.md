# KVM Media Toggle

An AutoHotkey v2 script that automatically pauses and resumes media playback when you switch between computers using a KVM switch.

## The Problem

If you use a KVM switch to share monitors between multiple computers (e.g., work and home), media playing in a web browser (podcasts, music, etc.) keeps playing after you switch away. You come back later to find your podcast has been running for hours, or you've lost your place entirely.

There's no built-in way for the OS or browser to know that *you* are no longer at that computer when a KVM switches the display signal to another machine.

## How It Works

When a KVM switch changes inputs, the monitors **disconnect** from the source PC — Windows sees the monitor count drop. This script exploits that:

1. Polls the monitor count every 2 seconds
2. When monitors disappear (KVM switched away), sends the **Media Play/Pause** key to pause playback
3. When monitors reappear (KVM switched back), waits for displays to initialize, then sends **Media Play/Pause** to resume
4. Only resumes if *it* was the one that paused — won't interfere if you manually paused before switching

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
| `POLL_INTERVAL` | `2000` | How often to check monitor count (ms) |
| `RESUME_DELAY` | `3000` | Delay before resuming after switch-back, giving displays time to initialize (ms) |
| `EXPECTED_MONITORS` | `3` | Number of monitors when KVM is active on this PC |

## Auto-Start with Windows

1. Press `Win+R`, type `shell:startup`, press Enter
2. Create a shortcut to `kvm-media-toggle.ahk` in that folder
