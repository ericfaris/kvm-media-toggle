#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =============================================================================
; KVM Media Toggle
; Automatically pauses media when KVM switches away (monitors disconnect)
; and resumes playback when you switch back.
; =============================================================================

; --- Configuration -----------------------------------------------------------
POLL_INTERVAL   := 2000   ; How often to check monitor count (ms)
RESUME_DELAY    := 3000   ; Wait for displays to fully initialize before resuming (ms)
EXPECTED_MONITORS := 3    ; Number of monitors when KVM is on this PC
; -----------------------------------------------------------------------------

wasActive := (MonitorGetCount() >= EXPECTED_MONITORS)
wasPaused := false

TraySetIcon("Shell32.dll", 138)
UpdateTray(wasActive, wasPaused)

SetTimer(CheckMonitors, POLL_INTERVAL)

CheckMonitors() {
    global wasActive, wasPaused, EXPECTED_MONITORS, RESUME_DELAY

    currentCount := MonitorGetCount()
    isActive := (currentCount >= EXPECTED_MONITORS)

    if (wasActive && !isActive) {
        ; KVM switched AWAY - pause media
        Send("{Media_Play_Pause}")
        wasPaused := true
        UpdateTray(false, wasPaused)
    }
    else if (!wasActive && isActive && wasPaused) {
        ; KVM switched BACK and we previously paused - resume after delay
        SetTimer(ResumeMedia, -RESUME_DELAY)
        UpdateTray(true, wasPaused)
    }
    else if (!wasActive && isActive && !wasPaused) {
        ; KVM switched back but we didn't pause anything
        UpdateTray(true, wasPaused)
    }

    wasActive := isActive
}

ResumeMedia() {
    global wasPaused
    Send("{Media_Play_Pause}")
    wasPaused := false
    UpdateTray(true, false)
}

UpdateTray(active, paused) {
    status := active ? "Active" : "Switched away"
    media  := paused ? " (media paused)" : ""
    A_IconTip := "KVM Media Toggle`nMonitors: " status media
}
