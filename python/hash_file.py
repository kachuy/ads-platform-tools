#!/usr/bin/env python

import argparse
import csv
import re
import hashlib
import sys


debug = False

parser = argparse.ArgumentParser(description='Hash the contents of a file for TA upload.')

parser.add_argument('--type', required=True, metavar='TWITTERID', help='source data type.',
    choices=['MOBILEDEVICEID', 'IDFA', 'ADID', 'ANDROID', 'EMAIL', 'PHONE', 'TWITTERID', 'TWITTERSCREENNAME'])

parser.add_argument('--infile', required=True, type=argparse.FileType('rU'), metavar='/path/to/source.txt', help='input file to parse.')

parser.add_argument('--outfile', required=True, type=argparse.FileType('w'), metavar='/path/to/output.txt', help='file to write output.')

args = parser.parse_args()

flags = {'uppercase': False, 'dropleadingzeros': False, 'dropleadingat': False }

if args.type == 'MOBILEDEVICEID':
    # mobile device IDs can be a mixture of IDFA, ADID and ANDROID in a single file
    flags['regex'] = re.compile('^[a-z0-9][a-z0-9\-]+[a-z0-9]$')
elif args.type == 'IDFA':
    # flags['uppercase'] = True
    flags['regex'] = re.compile('^[a-z0-9][a-z0-9\-]+[a-z0-9]$')
elif args.type == 'ADID':
    flags['regex'] = re.compile('^[a-z0-9][a-z0-9\-]+[a-z0-9]$')
elif args.type == 'ANDROID':
    flags['regex'] = re.compile('^[a-z0-9]+$')
elif args.type == 'EMAIL':
    flags['regex'] = re.compile('^[a-z0-9][a-z0-9_\-\.\+]+\@[a-z0-9][a-z0-9\.]+[a-z]$')
elif args.type == 'PHONE' or args.type == 'TWITTERID':
    flags['dropleadingzeros'] = True
    flags['regex'] = re.compile('^\d+$')
elif args.type == 'TWITTERSCREENNAME':
    flags['dropleadingat'] = True
    flags['regex'] = re.compile('^[a-z0-9_]+$')
else:
    print ("ERROR: invalid type")
    sys.exit()

skipped = 0
written = 0

if args.infile.name.endswith(".csv"):
    csv_file = True
    reader = csv.reader(args.infile, dialect='excel')
else:
    csv_file = False
    reader = args.infile

for text in reader:
    if not csv_file:
        text = [text]

    for line in text:

        if not line: break

        line = line.rstrip()

        # Remove whitespace
        line = ''.join(line.split())

        # Set case
        if flags['uppercase']:
            line = line.upper()
        else:
            line = line.lower()

        # Drop leading '@'
        if flags['dropleadingat']:
            line = line.lstrip('@')

        # Drop leading zeros
        if flags['dropleadingzeros']:
            line = line.lstrip('0')

        if flags['regex'].match(line) is None:
            skipped += 1
            continue

        if debug:
            print ("\t" + line)

        hashed = hashlib.sha256(line).hexdigest()
        args.outfile.write(hashed + "\n")
        written += 1

args.infile.close()
args.outfile.close()

print ("Written:\t" + str(written))
print ("Skipped:\t" + str(skipped))

sys.exit()
