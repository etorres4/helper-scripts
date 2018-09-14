#!/usr/bin/env bash
# Obtain a weather forecast

printHelp() {
cat << EOF
Retrieve the weather of a give location

Usage: getweather [-h|--help] [location]

Options:
    -h  show this help page
EOF
}

while true; do
    case "${1}" in
        "-h"|"--help")
            printHelp
            exit
            ;;
        --)
            shift
            break
            ;;
        -?*)
            echo "Not an option: ${1}" >&2 && exit 1
            exit
            ;;
        *)
            break;
            ;;
    esac
done

[[ -z "${@}" ]] && echo "Please enter a location" >&2 && exit 1

xargs --no-run-if-empty -I {} curl wttr.in/{} <<< "${@}"
