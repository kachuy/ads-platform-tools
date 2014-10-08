# ads-platform-tools

Tools and utilities for the Twitter Ads Platform.

## hash_file

Sample tools to hash data for tailored audience uploads, in either `Python` or `Perl`.

Data types supported:
 - MOBILEDEVICEID
 - IDFA
 - ADID
 - ANDROID
 - EMAIL
 - PHONE
 - TWITTERID
 - TWITTERSCREENNAME


Usage (Python):
`./hash_file.py --file EMAIL --infile /data/source_email_list.txt --outfile /data/hashed_email_list.txt`

Usage (Perl):
`./hash_file.pl EMAIL /data/source_email_list.txt`

