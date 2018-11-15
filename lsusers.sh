#!/bin/bash
# List all users on the system

sort --unique <(awk -F ':' '{print $1}' < /etc/passwd)
