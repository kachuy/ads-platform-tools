# ads-platform-tools

Tools and utilities for the Twitter Ads Platform. 

Also useful, see https://github.com/twitterdev/ton-upload for using the TON API.

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
./fetch_stats.py -a abc1 -s
Best practices stats check for :account_id abc1
-----------------------------------------------
Current time:   2015-04-16 01:27:44.136085
Start time: 2015-04-09 01:00:00
End time:   2015-04-16 00:59:59
-----------------------------------------------
Pre-filtered data:          22
Funding instruments:        2
Pre-filtered data:          1710
Campaigns:                  171
Pre-filtered data:          1631
Line items:                 169
Pre-filtered data:          1870
Promoted Tweets:            169
    fetching stats for 169 line items
    fetching stats for 169 promoted tweets
    fetching segmentation stats for 169 line items
    fetching segmentation stats for 169 promoted tweets
-----------------------------------------------
Non-Seg Stats Req Cost:     12160
Segmented Stats Req Cost:   62500
-----------------------------------------------
Total Stats Queries:        108
Total Stats Request Cost:   74660
Queries Rate Limited:       0
-----------------------------------------------
Time elapsed:           20.583211
```
