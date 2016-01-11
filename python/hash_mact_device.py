#!/usr/bin/env python

import sys
import argparse
import hmac
import hashlib
import base64
import yaml

__version__ = "0.2"

KEY_FILE = "mact_keys.yml"
# KEY_FILE is a YAML file with two keys at the top level: production_base64 and development_base64.
# each represents the base64 encoded HMAC key used for that environment


def parse_input():
    "Parse user input"

    parser = argparse.ArgumentParser(description='Test HMAC hashing for Twitter MACT')

    parser.add_argument('--env', choices=['prod', 'dev'], default='prod',
                        help='Set the environment for which secrets will be used')

    parser.add_argument('--value', required=True, help='The raw device identifier to hash')

    args = parser.parse_args()

    return args


def fetch_hmac_key(environment):
    "Fetch HMAC key from secrets file"

    if environment == 'prod':
        key_environment = 'production_base64'
    elif environment == 'dev':
        key_environment = 'development_base64'
    else:
        return

    try:
        f = file(KEY_FILE, 'r')
    except IOError:
        print ("ERROR: could not open secrets file")
        return

    data = yaml.load(f)
    f.close()

    if key_environment in data:
        key_base64 = data[key_environment]

        if key_base64:
            return base64.b64decode(key_base64)

    return


def hash_sha256(key, value):
    "SHA256 hash they value provided using the key passed"

    hmac_obj = hmac.new(key, msg=value, digestmod=hashlib.sha256)
    hashed_value = hmac_obj.digest()

    return base64.b64encode(hashed_value)


def main():

    args = parse_input()

    key = fetch_hmac_key(args.env)

    if key is None:
        print "ERROR: no HMAC key found"
        sys.exit(1)

    device_id = args.value

    base64_device_id = hash_sha256(key, device_id)
    base64_extra_device_id = hash_sha256(key, hashlib.sha1(device_id).hexdigest())

    print device_id
    print "device_id\t" + base64_device_id
    print "extra_device_id\t" + base64_extra_device_id

    sys.exit(0)

if __name__ == "__main__":
    main()
