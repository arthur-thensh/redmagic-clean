#!/usr/bin/env bash

ADB_SERIAL=''
ADB_STATE=''

adb_require() {
    if ! command -v adb >/dev/null 2>&1; then
        ui_error "adb was not found in PATH. Install Android SDK Platform-Tools first."
        return 1
    fi
}

adb_select_single_device() {
    local output
    local rows
    local count

    if ! output="$(adb devices)"; then
        ui_error "Unable to execute 'adb devices'."
        return 1
    fi

    rows="$(
        printf '%s\n' "$output" |
            awk 'NR > 1 && NF >= 2 { print $1 "\t" $2 }'
    )"

    count="$(
        printf '%s\n' "$rows" |
            awk 'NF { n++ } END { print n + 0 }'
    )"

    if [ "$count" -eq 0 ]; then
        ui_error "No Android device detected."
        return 1
    fi

    if [ "$count" -gt 1 ]; then
        ui_error "Multiple Android devices detected. Refusing to choose one automatically."
        printf '%s\n' "$rows" >&2
        return 1
    fi

    ADB_SERIAL="$(
        printf '%s\n' "$rows" |
            awk 'NF { print $1; exit }'
    )"

    ADB_STATE="$(
        printf '%s\n' "$rows" |
            awk 'NF { print $2; exit }'
    )"

    if [ "$ADB_STATE" != "device" ]; then
        ui_error "Device '$ADB_SERIAL' is not ready (state: $ADB_STATE)."

        if [ "$ADB_STATE" = "unauthorized" ]; then
            ui_error "Unlock the phone and approve the USB debugging authorization prompt."
        fi

        return 1
    fi

    if [ "$(adb -s "$ADB_SERIAL" get-state 2>/dev/null || true)" != "device" ]; then
        ui_error "Device '$ADB_SERIAL' stopped responding through adb."
        return 1
    fi
}

adb_exec() {
    adb -s "$ADB_SERIAL" "$@"
}

adb_shell() {
    adb_exec shell "$@"
}

adb_getprop() {
    local key="$1"

    adb_shell getprop "$key" |
        tr -d '\r' |
        sed -n '1p'
}
