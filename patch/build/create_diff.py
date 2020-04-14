#!/usr/bin/env python
from argparse import ArgumentParser
from struct import pack, unpack
import sys

class Patch:

    IpsRecordLimit = 0xFFFF
    IpsHeader = b'PATCH'
    IpsFooter = b'EOF'
    IpsMagic = unpack('>L', b'\x00EOF')[0]

    def __init__(self, format):
        self.format = format
        self.records = []

    def parse(self, a, b):
        a = read_binary(a)
        b = read_binary(b)

        records = []
        record = None
        for i in range(min(len(a), len(b))):
            if not record:
                if a[i] == b[i]:
                    # The number $454F46 coincide with the ASCII for "EOF" but
                    # with an inter diff the prior byte is undefined, so we are
                    # forced to make a data assertion.
                    if self.format == 'ips' and i == self.IpsMagic:
                        raise AssertionError('Record started at the IPS "magical" EOF number')

                    record = bytearray()
                    record.append(a[i])
            else:
                if a[i] == b[i]:
                    record.append(a[i])
                else:
                    records.append((i-len(record), record))
                    record = None
        # Trailing record that reach the end of the rom
        if record:
            records.append((i+1-len(record), record))

        self.records = records

    def write(self, o):
        patch = bytearray()
        ips = self.format == 'ips'

        if ips:
            for index, record in self.records:
                while len(record) > 0:
                    # IPS record length is limited to 2^16-1, and must avoid the IPS magic EOF offset
                    limit = self.IpsRecordLimit
                    if index + limit == self.IpsMagic:
                        limit -= 1
                    chunk = record[:limit]
                    record = record[limit:]

                    length = len(chunk)
                    patch += dl_be(index)
                    patch += dw_be(length)
                    patch += chunk
                    index += length
        else:
            for index, record in self.records:
                patch += dd_le(index)
                patch += dd_le(len(record))
                patch += record

        if ips:
            write_binary(o, self.IpsHeader + patch + self.IpsFooter)
        else:
            write_binary(o, patch)

def read_binary(name):
    with open(name, 'rb') as file:
        return file.read()

def write_binary(name, data):
    with open(name, 'wb') as file:
        file.write(data)

def dw_be(value):
    return pack('>H', value)

def dl_be(value):
    return pack('>L', value)[-3:]

def dd_le(value):
    return pack('<L', value)

if __name__ == '__main__':
    p = ArgumentParser(description='produce the commonality between two rom files as a patch')
    p.add_argument('-f', '--format', choices=['ips','bin'], default='ips',
        help='output format, IPS or binary little-endian dd prefixed records (defaults to ips)')
    p.add_argument('input', nargs=2, help='input file path')
    p.add_argument('output', help='output file path')

    args = p.parse_args()

    patch = Patch(args.format)
    patch.parse(*args.input)
    patch.write(args.output)
