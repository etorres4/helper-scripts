#!/usr/bin/python3
"""Obtain a weather forecast."""

import argparse
import requests

WTTR_URI = 'http://wttr.in'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('location')

    args = parser.parse_args()
    location = args.location

    print(requests.get(f"{WTTR_URI}/{location}").text)
