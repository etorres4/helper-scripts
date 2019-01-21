#!/usr/bin/python3
"""Check the temperature of a drive.
Functions:
    verify_device_node(query)
        - Check if query is a device node
    retrieve_smart_temp(device_node)
        - Retrieve specified drive temperature in mKelvin
    convert_to_celsius(mkel_temp)
        - Given mkel_temp, convert it into °C
"""

import argparse
import pathlib
import subprocess

# ========== Constants ==========
DUMP_CMD = ['skdump', '--temperature']


# ========== Functions ==========
def verify_device_node(query):
    """Check if query is a device node.
    :param query: input that refers to a device
    :type query: a path-like object
    :returns: True if query is a device node, False if otherwise
    :rtype: bool
    """
    return pathlib.Path(query).is_block_device()


def retrieve_smart_temp(device_node):
    """Retrieve specified drive's temperature.
    :param device_node: device to retrieve temperature for
    :type device_node: str
    :returns: output of skdump in mKelvin
    :rtype: float
    """
    temp = subprocess.run(DUMP_CMD + device_node,
                          capture_output=True,
                          text=True).stdout
    return float(temp)


def convert_to_celsius(mkel_temp):
    """Given mkel_temp, convert it into °C.
    :param mkel_temp: the temperature in mKelvin
    :type mkel_temp: str
    :returns: temperature converted into degrees celsius
    :rtype: str
    """
    return (mkel_temp/1000) - 273.15


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('device', help='device node to retrieve\
                        the temperature for', metavar='dev')
    args = parser.parse_args()

    dev = args.device

    if verify_device_node(dev):
        mkel = retrieve_smart_temp(dev)
        print(f"{dev}: {convert_to_celsius(mkel)}°C")
    else:
        print("Not a device node.")
        exit(1)
