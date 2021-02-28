#

set -e
find . -name '*~1' -delete
tic=$(date +%s);
ntp_now=$(expr $tic + 2208992400)
echo tic: $tic
perl bin/mkleaps.pl test/obspm.txt
ipfs add -w --raw-leaves --hash sha1 --cid-base base16 --pin=true src/leap-seconds*.dat src/leap-seconds*.txt

ntp_exp=$(grep -e '^#@ ' src/leap-seconds.list | cut -d' ' -f2)
qmleap=$(ipfs add -w src/leap-seconds.list -Q)
list=$(cat src/leap-seconds.dat)
sha1=$(echo $list | openssl sha1 -r | cut -d' ' -f1)
echo qmleap: $qmleap
echo sha1: $sha1

qm=$(ipfs add -r . -Q)
echo qm: $qm
key=$(ipfs key list -l | grep -w leap-seconds-list | cut -d' ' -f1)
echo key: $key
ipfs name publish --key=$key /ipfs/$qm --allow-offline &
mv _data/leaps.yml data.yml
sed -e "s/qm: .*/qm: $qm/" -e "s/ntp_now: .*/ntp_now: $ntp_now/" \
    -e "s/k5mut: .*/k5mut: $key/" \
    -e "s/qmleap: .*/qmleap: $qmleap/" \
    -e "s/ntp_exp: .*/ntp_exp: $ntp_exp/" \
    -e "s/sha1: .*/sha1: '$sha1'/" \
    -e "s/list: .*/list: '$list'/" data.yml > _data/leaps.yml
rm data.yml
echo $ntp_exp: $qm >> qm.log
jekyll build
date=$(date +%D)
branch=$(git rev-parse --abbrev-ref HEAD)

if git commit -a ; then
gitid=$(git rev-parse HEAD)
git tag -f -a $ntp_exp -m "tagging $gitid on $date"
#echo gitid: ${gitid:0:9} # this is bash!
echo gitid: $gitid | cut -b 1-14
if test -e revs.log; then
echo $tic: $gitid >> revs.log
fi

# test if tag $ntp_exp exist ...
remote=$(git rev-parse --abbrev-ref @{upstream} |cut -d/ -f 1)
if git ls-remote --tags | grep "$ntp_exp"; then
git push --delete $remote "$ntp_exp"
fi
fi
echo "git push : "
git push --follow-tags $remote $branch
echo .

