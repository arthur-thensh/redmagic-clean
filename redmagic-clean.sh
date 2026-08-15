#!/usr/bin/env bash
set -euo pipefail

RMC_VERSION="0.1.0"
readonly RMC_VERSION

RMC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly RMC_ROOT

# shellcheck source=lib/ui.sh
source "$RMC_ROOT/lib/ui.sh"

# shellcheck source=lib/adb.sh
source "$RMC_ROOT/lib/adb.sh"

# shellcheck source=lib/device.sh
source "$RMC_ROOT/lib/device.sh"

# shellcheck source=lib/audit.sh
source "$RMC_ROOT/lib/audit.sh"

usage() {
    cat <<EOF
Usage:
  ./redmagic-clean.sh audit
  ./redmagic-clean.sh help
EOF
}

main() {
    local command="${1:-}"

    case "$command" in
        audit)
            if [ "$#" -ne 1 ]; then
                ui_error "The audit command does not accept arguments in v${RMC_VERSION}."
                usage >&2
                return 2
            fi

            audit_run
            ;;

        help|-h|--help)
            usage
            ;;

        "")
            usage
            return 2
            ;;

        *)
            ui_error "Unknown command: $command"
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
