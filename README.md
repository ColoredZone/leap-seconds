# Verifying leap-seconds list file

The perl script 'leapssha1.pl' is computing the hash (sha1) of the data within a leap-seconds.list file
in order to verify it's integrity.

```sh
set -x
url=https://hpiers.obspm.fr/iers/bul/bulc/ntp/leap-seconds.list
curl -sL $url | tee leaps-obspm.list | perl leapssha1.pl

url=https://www.ietf.org/timezones/data/leap-seconds.list
curl -sL $url | tee leaps-ietf.list | perl leapssha1.pl

url=https://data.iana.org/time-zones/code/leap-seconds.list
curl -sL $url | tee leaps-iana.list | perl leapssha1.pl
```


+Dr IT
