#!/usr/bin/env bash
# Obtain a weather forecast

echo "${@}" | xargs --no-run-if-empty -I {} curl wttr.in/{}
