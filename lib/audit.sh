#!/usr/bin/env bash

AUDIT_REPORT_DIR=''
AUDIT_LOG=''

_audit_log() {
    local message="$*"

    printf '[%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$message" \
        >> "$AUDIT_LOG"
}

_audit_package_count() {
    wc -l < "$1" |
        tr -d '[:space:]'
}

_audit_capture_packages() {
    local output_file="$1"
    local label="$2"

    shift 2

    _audit_log "Collecting $label"

    if ! adb_shell pm list packages "$@" \
        --user "$DEVICE_USER_ID" |
        tr -d '\r' |
        sed -n 's/^package://p' |
        LC_ALL=C sort \
        > "$output_file"
    then
        rm -f "$output_file"
        _audit_log "ERROR: failed to collect $label"
        ui_error "Failed to collect $label."
        return 1
    fi

    _audit_log "Collected $label: $(_audit_package_count "$output_file") packages"
}

_audit_prepare_report_dir() {
    local timestamp
    local slug
    local base_dir
    local suffix

    timestamp="$(date '+%Y-%m-%d_%H%M%S')"
    slug="$(device_report_slug)"

    if [ -z "$slug" ]; then
        slug="ANDROID_DEVICE"
    fi

    base_dir="$RMC_ROOT/reports/$slug/$timestamp"
    AUDIT_REPORT_DIR="$base_dir"
    suffix=1

    while [ -e "$AUDIT_REPORT_DIR" ]; do
        AUDIT_REPORT_DIR="${base_dir}_${suffix}"
        suffix=$((suffix + 1))
    done

    AUDIT_LOG="$AUDIT_REPORT_DIR/audit.log"

    mkdir -p "$AUDIT_REPORT_DIR"
    : > "$AUDIT_LOG"
}

_audit_print_result() {
    local all_count
    local system_count
    local third_party_count
    local disabled_count

    all_count="$(_audit_package_count "$AUDIT_REPORT_DIR/packages-all.txt")"
    system_count="$(_audit_package_count "$AUDIT_REPORT_DIR/packages-system.txt")"
    third_party_count="$(_audit_package_count "$AUDIT_REPORT_DIR/packages-third-party.txt")"
    disabled_count="$(_audit_package_count "$AUDIT_REPORT_DIR/packages-disabled.txt")"

    printf '\n'
    ui_section "Audit"

    ui_kv "All packages" "$all_count"
    ui_kv "System" "$system_count"
    ui_kv "Third-party" "$third_party_count"
    ui_kv "Disabled" "$disabled_count"
    ui_kv "Report" "$AUDIT_REPORT_DIR"

    printf '\n'
    ui_ok "Audit completed. No modification was made on the device."
}

audit_run() {
    local generated_at

    ui_header

    adb_require
    ui_ok "adb found"

    adb_select_single_device
    ui_ok "one authorized Android device detected"

    device_collect_info
    device_print_summary

    _audit_prepare_report_dir
    generated_at="$(date '+%Y-%m-%d %H:%M:%S %z')"

    _audit_log "RedMagic Clean v$RMC_VERSION audit started"
    _audit_log "ADB serial: $ADB_SERIAL"
    _audit_log "Android user: $DEVICE_USER_ID"

    device_write_report_files "$AUDIT_REPORT_DIR" "$generated_at"
    _audit_log "Wrote device.txt and build.txt"

    _audit_capture_packages \
        "$AUDIT_REPORT_DIR/packages-all.txt" \
        "all packages"

    _audit_capture_packages \
        "$AUDIT_REPORT_DIR/packages-system.txt" \
        "system packages" \
        -s

    _audit_capture_packages \
        "$AUDIT_REPORT_DIR/packages-third-party.txt" \
        "third-party packages" \
        -3

    _audit_capture_packages \
        "$AUDIT_REPORT_DIR/packages-disabled.txt" \
        "disabled packages" \
        -d

    _audit_log "Audit completed successfully"
    _audit_print_result
}
