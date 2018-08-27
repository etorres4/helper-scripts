#!/usr/bin/env python
""" Check the temperature of the drive
Functions:
    verify_device_node(query)
        - Check if query is a device node
    retrieve_smart_temp(device_node)
        - Retrieve specified drive temperature in mKelvin
    calculate_temp(mkel_temp)
        - Given mkel_temp, convert it into °C
"""

import argparse
import pathlib

from plumbum.cmd import sudo


def verify_device_node(query):
    """ Check if query is a device node
    Return True or False
    """
    return pathlib.Path(query).is_block_device()


def retrieve_smart_temp(device_node):
    """ Retrieve specified drive temperature in mKelvin
    device_node: the device to retrieve a temperature for
    Returns the output of skdump
    """
    dump_cmd = sudo['skdump', '--temperature', device_node]
    output = dump_cmd()
    return output


def calculate_temp(mkel_temp):
    """ Given mkel_temp, convert it into °C
    mkel_temp: the temperature in mKelvin
    Returns the temperature converted into degrees celsius
    """
    return (float(mkel_temp)/1000) - 273.15


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('device', help='device node to retrieve\
                        the temperature for', metavar='dev')
    args = parser.parse_args()

    dev = args.device
 
    if verify_device_node(dev):
        mkel = retrieve_smart_temp(dev)
        print(f"{dev}: {calculate_temp(mkel)}°C")
    else:
        print("Not a device node.")
        exit(1)
