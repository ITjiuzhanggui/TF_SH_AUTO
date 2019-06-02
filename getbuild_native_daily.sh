#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
WORKDIR=`pwd`
ARTIDIR=$BASEDIR/../images/native/daily

latest=$1

mkdir -p $ARTIDIR

wget https://ubit-artifactory-sh.intel.com/artifactory/clearlinux-sh-local/gp2.0/ --user="${ADUSER}" --password="${ADPASS}" --no-check-certificate -O ${ARTIDIR}/build.index

# pls install html2text
[ "$latest" == "" ] && latest=`html2text ${ARTIDIR}/build.index | head -n -3 | awk '{first = $1} END {print first}'`

if [ -e ${ARTIDIR}/build.latest ] && [ "$latest" == "`cat ${ARTIDIR}/build.latest`" ] ; then
  echo "Latest version: $latest"
  exit
fi

while true
do
  if [ ! -d  ${ARTIDIR}/$latest ] ; then
    mkdir -p ${ARTIDIR}/$latest
    cd ${ARTIDIR}/$latest
    wget --no-check-certificate https://ubit-artifactory-sh.intel.com/artifactory/clearlinux-sh-local/gp2.0/${latest}gordonpeak/native/ -r -l1 -nc -nd -nH -np --user="${ADUSER}" --password="${ADPASS}" --no-check-certificate
    cd ${BASEDIR}
  fi
  if [ -e ${ARTIDIR}/${latest}/native_boot.img ] ; then
    break
  else
    mv ${ARTIDIR}/$latest ${ARTIDIR}/_tmp_${latest}
    cp -a ${ARTIDIR}/build.index ${ARTIDIR}/build.index.0
    cat ${ARTIDIR}/build.index.0 | grep -v "${latest}" > ${ARTIDIR}/build.index
    latest=`html2text ${ARTIDIR}/build.index | head -n -3 | awk '{first = $1} END {print first}'`
  fi
done

echo $latest > ${ARTIDIR}/build.latest

echo "Latest version: $latest"

cd ${WORKDIR}
