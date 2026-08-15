#!/usr/bin/env bash

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    UI_BOLD='\033[1m'
    UI_GREEN='\033[32m'
    UI_YELLOW='\033[33m'
    UI_RED='\033[31m'
    UI_RESET='\033[0m'
else
    UI_BOLD=''
    UI_GREEN=''
    UI_YELLOW=''
    UI_RED=''
    UI_RESET=''
fi

ui_header() {
    printf '%b\n' "${UI_BOLD}========================================${UI_RESET}"
    printf '%b\n' "${UI_BOLD}        REDMAGIC CLEAN v${RMC_VERSION}${UI_RESET}"
    printf '%b\n\n' "${UI_BOLD}========================================${UI_RESET}"
}

ui_section() {
    printf '%b\n' "${UI_BOLD}$1${UI_RESET}"
    printf '%s\n' '----------------------------------------'
}

ui_ok() {
    printf '%b\n' "${UI_GREEN}OK${UI_RESET}: $*"
}

ui_warn() {
    printf '%b\n' "${UI_YELLOW}WARN${UI_RESET}: $*" >&2
}

ui_error() {
    printf '%b\n' "${UI_RED}ERROR${UI_RESET}: $*" >&2
}

ui_kv() {
    printf '%-14s %s\n' "$1" "$2"
}
