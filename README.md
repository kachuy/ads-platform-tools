# ads-platform-tools

Tools and utilities for the Twitter Ads Platform. 

Also useful, see https://github.com/twitterdev/ton-upload for using the TON API.

Before using any of the Python tools/utilities be sure to do:

```bash
pip install -r python/requirements.pip
```

## hash_tailored_audience_file

Sample tools to hash data for tailored audience uploads, in either `Python` or `Perl`. Details on these normalization rules can be found [here](https://support.twitter.com/articles/20172017-tailored-audiences) or [here](https://dev.twitter.com/ads/audiences/file-data).

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

## fetch_stats

Sample script implementing [best practices](https://dev.twitter.com/ads/campaigns/analytics-best-practices) for pulling ads analytics for an advertiser account.

Usage (Python):
`./fetch_stats.py -a abc1`

Params:

```
-a abc1   # the :account_id to run the stats fetcher on
-s        # pull segmented stats
-v        # output avg query costs
-vv       # output stats API calls made
```

Sample output:

```
./fetch_stats.py -a abc1
Best practices stats check for :account_id abc1
-----------------------------------------------
Current time:   2015-04-16 02:32:16.815510
Start time:     2015-04-09 02:00:00
End time:       2015-04-16 01:59:59
-----------------------------------------------
Pre-filtered data:          2
Funding instruments:        1
Pre-filtered data:          15381
Campaigns:                  67
Pre-filtered data:          14768
Line items:                 37
Pre-filtered data:          11518
Promoted Tweets:            33
    fetching stats for 37 line items
    fetching stats for 33 promoted tweets
-----------------------------------------------
Total Stats Queries:        4
Total Stats Request Cost:   2780
Queries Rate Limited:       0
-----------------------------------------------
Time elapsed:           11.44861
```
