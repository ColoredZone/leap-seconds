---
---
# leap-seconds list on the blockchain

We put the [leap-seconds.list][3] file on the blockchain current file is at

* <https://ipfs.io/ipns/{{site.data.leaps.k5mut}}>
  and
* <http://127.0.0.1:8080/ipfs/{{site.data.leaps.qm}}>,
* <https://dweb.link/ipfs/f01551114{{site.data.leaps.sha1}}>

     sha1: [{{site.data.leaps.sha1}}][1]
<br> qm: [{{site.data.leaps.qmleaps}}][2]

We have also the list in various format

* [leap-seconds-list.txt](src/leap-seconds-list.txt)
* [leap-seconds-list.csv](src/leap-seconds-list.csv)
* [leap-seconds-list.yml](src/leap-seconds-list.yml)
* [leap-seconds-list.json](src/leap-seconds-list.json)
* [leap-seconds-list.js](src/leap-seconds-list.js)
* [leap-seconds-list.dat](src/leap-seconds-list.dat)


 files expire on {{site.data.leaps.ntp_exp | minus: site.data.leaps.ntp_offset | date_to_rfc822 }}


[1]: https://duckduckgo.com/?q={{site.data.leaps.sha1}}
[2]: https://gateway.ipfs.io/ipfs/{{site.data.leaps.qmleaps}}
[3]: leap-seconds.txt

+[Dr IT](https://www.drit.ml/about/)
