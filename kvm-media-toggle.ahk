#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =============================================================================
; KVM Media Toggle
; Automatically pauses media when KVM switches away and resumes playback
; when you switch back.
;
; Switch-away: Detects double RCtrl tap (KVM attention sequence)
; Switch-back: Detects mouse movement after a settle period
; =============================================================================

; --- Configuration -----------------------------------------------------------
DOUBLE_TAP_MS    := 400    ; Max time between RCtrl taps to count as double (ms)
SETTLE_TIME      := 3000   ; Wait after switch-away before watching for return (ms)
RETURN_POLL      := 250    ; How often to check for mouse movement (ms)
RESUME_DELAY     := 500    ; Wait before resuming after detecting return (ms)
; -----------------------------------------------------------------------------

wasPaused := false
lastRCtrl := 0
lastMouseX := 0
lastMouseY := 0

TraySetIcon("Shell32.dll", 138)
UpdateTray(true, false)

; Detect RCtrl taps (~ passes the key through so KVM still works)
~RCtrl::OnRCtrl()

OnRCtrl() {
    global wasPaused, lastRCtrl, DOUBLE_TAP_MS, SETTLE_TIME

    now := A_TickCount
    elapsed := now - lastRCtrl
    lastRCtrl := now

    if (elapsed < DOUBLE_TAP_MS && !wasPaused) {
        ; Double RCtrl detected — user is switching away
        Sleep(100)
        Send("{Media_Play_Pause}")
        wasPaused := true
        UpdateTray(false, true)
        ; Wait for KVM to fully switch, then start watching for return
        SetTimer(StartWatching, -SETTLE_TIME)
    }
}

StartWatching() {
    global lastMouseX, lastMouseY, RETURN_POLL
    ; Capture current mouse position as baseline
    CoordMode("Mouse", "Screen")
    MouseGetPos(&lastMouseX, &lastMouseY)
    SetTimer(CheckMouseMove, RETURN_POLL)
}

CheckMouseMove() {
    global wasPaused, lastMouseX, lastMouseY, RESUME_DELAY

    if (!wasPaused) {
        SetTimer(CheckMouseMove, 0)
        return
    }

    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)

    if (x != lastMouseX || y != lastMouseY) {
        ; Mouse moved — user is back
        SetTimer(CheckMouseMove, 0)
        SetTimer(ResumeMedia, -RESUME_DELAY)
    }
}

ResumeMedia() {
    global wasPaused
    if (wasPaused) {
        Send("{Media_Play_Pause}")
        wasPaused := false
        UpdateTray(true, false)
    }
}

UpdateTray(active, paused) {
    status := active ? "Active" : "Switched away"
    media  := paused ? " (media paused)" : ""
    A_IconTip := "KVM Media Toggle`n" status media
}
