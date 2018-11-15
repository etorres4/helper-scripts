#!/bin/bash
# List all groups in the system

sort <(awk -F ':' '{print $1}' < /etc/group)
