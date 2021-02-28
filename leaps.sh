#
set -x
url=https://hpiers.obspm.fr/iers/bul/bulc/ntp/leap-seconds.list
curl -sL $url | tee leaps-obspm.list | perl leapssha1.pl

url=https://www.ietf.org/timezones/data/leap-seconds.list
curl -sL $url | tee leaps-ietf.list | perl leapssha1.pl

url=https://data.iana.org/time-zones/code/leap-seconds.list
curl -sL $url | tee leaps-iana.list | perl leapssha1.pl
