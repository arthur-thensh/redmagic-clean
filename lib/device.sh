#!/usr/bin/env bash

DEVICE_MANUFACTURER=''
DEVICE_BRAND=''
DEVICE_MODEL=''
DEVICE_CODENAME=''

DEVICE_ANDROID=''
DEVICE_SDK=''
DEVICE_SECURITY_PATCH=''

DEVICE_BUILD_ID=''
DEVICE_BUILD_DISPLAY=''
DEVICE_BUILD_INCREMENTAL=''
DEVICE_FINGERPRINT=''

DEVICE_USER_ID=''

_device_require_value() {
    local label="$1"
    local value="$2"

    if [ -z "$value" ]; then
        ui_error "Unable to read required device property: $label"
        return 1
    fi
}

device_collect_info() {
    DEVICE_MANUFACTURER="$(adb_getprop ro.product.manufacturer)"
    DEVICE_BRAND="$(adb_getprop ro.product.brand)"
    DEVICE_MODEL="$(adb_getprop ro.product.model)"
    DEVICE_CODENAME="$(adb_getprop ro.product.device)"
    DEVICE_ANDROID="$(adb_getprop ro.build.version.release)"
    DEVICE_SDK="$(adb_getprop ro.build.version.sdk)"
    DEVICE_SECURITY_PATCH="$(adb_getprop ro.build.version.security_patch)"
    DEVICE_BUILD_ID="$(adb_getprop ro.build.id)"
    DEVICE_BUILD_DISPLAY="$(adb_getprop ro.build.display.id)"
    DEVICE_BUILD_INCREMENTAL="$(adb_getprop ro.build.version.incremental)"
    DEVICE_FINGERPRINT="$(adb_getprop ro.build.fingerprint)"

    DEVICE_USER_ID="$(
        adb_shell am get-current-user |
            tr -d '\r' |
            sed -n '1p'
    )"

    _device_require_value "ro.product.manufacturer" "$DEVICE_MANUFACTURER"
    _device_require_value "ro.product.model" "$DEVICE_MODEL"
    _device_require_value "ro.build.version.release" "$DEVICE_ANDROID"
    _device_require_value "ro.build.version.sdk" "$DEVICE_SDK"

    case "$DEVICE_USER_ID" in
        ''|*[!0-9]*)
            ui_error "Unable to determine the current Android user ID."
            return 1
            ;;
    esac
}

device_report_slug() {
    local source="$DEVICE_MODEL"

    if [ -z "$source" ]; then
        source="$DEVICE_CODENAME"
    fi

    printf '%s' "$source" |
        tr '[:lower:] ' '[:upper:]_' |
        tr -cd '[:alnum:]_.-'
}

device_print_summary() {
    ui_section "Device"

    ui_kv "ADB" "connected"
    ui_kv "Serial" "$ADB_SERIAL"
    ui_kv "User" "$DEVICE_USER_ID"
    ui_kv "Manufacturer" "$DEVICE_MANUFACTURER"
    ui_kv "Brand" "$DEVICE_BRAND"
    ui_kv "Model" "$DEVICE_MODEL"
    ui_kv "Device" "$DEVICE_CODENAME"
    ui_kv "Android" "$DEVICE_ANDROID"
    ui_kv "SDK" "$DEVICE_SDK"
    ui_kv "Security" "${DEVICE_SECURITY_PATCH:-unknown}"
    ui_kv "Build" "${DEVICE_BUILD_DISPLAY:-$DEVICE_BUILD_ID}"
}

device_write_report_files() {
    local report_dir="$1"
    local generated_at="$2"

    cat > "$report_dir/device.txt" <<EOF
RedMagic Clean audit
Generated: $generated_at
ADB serial: $ADB_SERIAL
Android user: $DEVICE_USER_ID

Manufacturer: $DEVICE_MANUFACTURER
Brand: $DEVICE_BRAND
Model: $DEVICE_MODEL
Device: $DEVICE_CODENAME
Android: $DEVICE_ANDROID
SDK: $DEVICE_SDK
Security patch: $DEVICE_SECURITY_PATCH
EOF

    cat > "$report_dir/build.txt" <<EOF
ro.build.id=$DEVICE_BUILD_ID
ro.build.display.id=$DEVICE_BUILD_DISPLAY
ro.build.version.incremental=$DEVICE_BUILD_INCREMENTAL
ro.build.version.release=$DEVICE_ANDROID
ro.build.version.sdk=$DEVICE_SDK
ro.build.version.security_patch=$DEVICE_SECURITY_PATCH
ro.build.fingerprint=$DEVICE_FINGERPRINT
EOF
}
