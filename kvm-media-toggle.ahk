#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =============================================================================
; KVM Media Toggle
; Automatically pauses media when KVM switches away and resumes playback
; when you switch back.
;
; Switch-away: Detects double RCtrl tap (KVM attention sequence)
; Switch-back: Detects mouse movement after a settle period, refreshes
;              the PocketCasts PWA so playback state syncs from the server
; =============================================================================

; --- Configuration -----------------------------------------------------------
DOUBLE_TAP_MS    := 400    ; Max time between RCtrl taps to count as double (ms)
SETTLE_TIME      := 3000   ; Wait after switch-away before watching for return (ms)
RETURN_POLL      := 250    ; How often to check for mouse movement (ms)
RESUME_DELAY     := 500    ; Wait before refreshing after detecting return (ms)
REFRESH_TITLE    := "Pocket Casts"  ; Window title fragment for the PocketCasts tab
REFRESH_WAIT     := 2500   ; Wait after page refresh before resuming playback (ms)
; -----------------------------------------------------------------------------

SetTitleMatchMode(2)  ; Allow partial window title matching

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
        SetTimer(RefreshAndResume, -RESUME_DELAY)
    }
}

RefreshAndResume() {
    global wasPaused, REFRESH_TITLE, REFRESH_WAIT

    if (!wasPaused)
        return

    hwnd := WinExist(REFRESH_TITLE)
    if (hwnd) {
        ; Save whatever window is currently active so we can restore focus
        prevHwnd := WinExist("A")
        WinActivate(hwnd)
        WinWaitActive(hwnd, , 2)
        Send("^r")  ; Ctrl+R — refresh the PocketCasts tab
        ; Restore previous window focus if it wasn't already PocketCasts
        if (prevHwnd && prevHwnd != hwnd)
            WinActivate(prevHwnd)
        ; Wait for the page to finish loading, then resume playback
        SetTimer(ResumeMedia, -REFRESH_WAIT)
    } else {
        ; PocketCasts tab not found — fall back to plain resume
        ResumeMedia()
    }
}

ResumeMedia() {
    global wasPaused, REFRESH_TITLE
    if (!wasPaused)
        return

    hwnd := WinExist(REFRESH_TITLE)
    if (hwnd) {
        prevHwnd := WinExist("A")
        WinActivate(hwnd)
        WinWaitActive(hwnd, , 2)
        Send("{Space}")  ; Spacebar plays/pauses within the PocketCasts PWA
        if (prevHwnd && prevHwnd != hwnd)
            WinActivate(prevHwnd)
    } else {
        Send("{Media_Play_Pause}")  ; Fallback if tab isn't found
    }

    wasPaused := false
    UpdateTray(true, false)
}

UpdateTray(active, paused) {
    status := active ? "Active" : "Switched away"
    media  := paused ? " (media paused)" : ""
    A_IconTip := "KVM Media Toggle`n" status media
}
