#!/usr/bin/env bash
# Export a key to a given keyfile

echo -n "Enter the name of the output file: "
read -r keyfileoutput

echo -n "Enter the user ID or email: "
read -r userid

if [[ -z "${keyfileoutput}" || -z "${userid}" ]]; then
    echo "Insufficient info."
else
    gpg --output "${keyfileoutput}" --armor --export "${userid}"
fi
