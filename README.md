---
---
# Verifying leap-seconds list file

The perl script 'leapssha1.pl' is computing the hash (sha1) of the data within a leap-seconds.list file
in order to verify it's integrity.

We put the list on the blockchain current file is at

 <https://ipfs.io/ipns/{site.data.leaps.k5mut}>
 and
 <http://127.0.0.1:8080/ipfs/{{site.data.leaps.qmleaps}}>
 <https://dweb.link/ipfs/f01551114{{site.data.leaps.sha1}}>

 sha1: [{{site.data.leaps.sha1}}][1]
 qm: [{{site.data.leaps.qmleaps}}][2]


```sh
set -x
url=https://hpiers.obspm.fr/iers/bul/bulc/ntp/leap-seconds.list
curl -sL $url | tee leaps-obspm.list | perl leapssha1.pl

url=https://www.ietf.org/timezones/data/leap-seconds.list
curl -sL $url | tee leaps-ietf.list | perl leapssha1.pl

url=https://data.iana.org/time-zones/code/leap-seconds.list
curl -sL $url | tee leaps-iana.list | perl leapssha1.pl
```


[1]: https://duckduckgo.com/?q={{site.data.leaps.sha1}}
[2]: https://gateway.ipfs.io/ipfs/{{site.data.leaps.qmleaps}}

+[Dr IT](https://www.drit.ml/about/)
