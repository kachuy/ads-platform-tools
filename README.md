# ads-platform-tools

Tools and utilities for the Twitter Ads Platform.

## hash_tailored_audience_file

Sample tools to hash data for tailored audience uploads, in either `Python` or `Perl`. Details on these normalization rules can be found [here (public access)](https://support.twitter.com/articles/20172017-tailored-audiences) or [here](https://dev.twitter.com/ads/audiences/file-data) (restricted access).

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
`./hash_tailored_audience_file.py --type EMAIL --infile /data/source_email_list.txt --outfile /data/hashed_email_list.txt`

Usage (Perl):
`./hash_tailored_audience_file.pl EMAIL /data/source_email_list.txt`

## hash_mact_device

Sample script to debug the HMAC hashing of MACT device_ids. Input is a single, unhashed normalized device_id and output will include both the hashed device id and the hashed extra device id.

Usage (Python):
`./hash_mact_device.py --env prod --value abc123456789`

