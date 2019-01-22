#!/usr/bin/python3
"""Obtain a weather forecast."""

import argparse
import requests

# ========== Constants ==========
WTTR_URI = 'http://wttr.in'

# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument('location')

args = parser.parse_args()
location = args.location

print(requests.get(f"{WTTR_URI}/{location}").text)
