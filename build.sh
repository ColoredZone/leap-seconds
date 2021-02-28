#

set -e
find . -name '*~1' -delete
tic=$(date +%s);
ntp=$(expr $tic + 2208992400)
echo tic: $tic
perl bin/mkleaps.pl test/obspm.txt
ipfs add -w --raw-leaves --hash sha1 --cid-base base16 --pin=true src/leap-seconds*.dat src/leap-seconds*.txt
qmleap=$(ipfs add src/leap-seconds-list.txt -Q)
echo qmleap: $qmleap
qm=$(ipfs add -w -r . -Q)
echo qm: $qm
key=$(ipfs key list -l | grep -w leap-seconds-list | cut -d' ' -f1)
echo key: $key
ipfs name publish --key=$key /ipfs/$qm
list=$(cat src/leap-seconds.dat)
sha1=$(echo $list | openssl sha1 -r | cut -d' ' -f1)
echo sha1: $sha1
mv _data/leaps.yml data.yml
sed -e "s/qm: .*/qm: $qm/" -e "s/ntp_now: .*/ntp_now: $ntp/" \
    -e "s/k5mut: .*/k5mut: $key/" \
    -e "s/qmleap: .*/qmleap: $qmleap/" \
    -e "s/sha1: .*/sha1: '$sha1'/" \
    -e "s/list: .*/list: '$list'/" data.yml > _data/leaps.yml
rm data.yml
#echo $ntp: $qm >> qm.log
jekyll build
git commit -a

