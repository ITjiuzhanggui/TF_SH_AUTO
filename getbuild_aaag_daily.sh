#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
WORKDIR=`pwd`
ARTIDIR=$BASEDIR/../images/aaag/daily

latest=$1

mkdir -p $ARTIDIR

wget https://mcg-depot.intel.com/artifactory/cactus-absp-jf/master-latest/ --user="${ADUSER}" --password="${ADPASS}" --no-check-certificate -O ${ARTIDIR}/build.index

# pls install html2text
[ "$latest" == "" ] && latest=`html2text ${ARTIDIR}/build.index | head -n -2 | tail -n +5 | awk '{print $1}' | sed 's/->//g' | sed 's/.$//' | awk -v max=0 '{if($1>max){want=$1; max=$1}}END{print want"/"}'`

if [ -e ${ARTIDIR}/build.latest ] && [ "$latest" == "`cat ${ARTIDIR}/build.latest`" ] ; then
  echo "Latest version: $latest"
  exit
fi

while true
do
  if [ ! -d  ${ARTIDIR}/$latest ] ; then
    mkdir -p ${ARTIDIR}/$latest
    cd ${ARTIDIR}/$latest
    wget https://mcg-depot.intel.com/artifactory/cactus-absp-jf/master-latest/${latest}gordon_peak_acrn/userdebug/ -r --no-parent -A 'gordon_peak_acrn-flashfiles-P*.zip' -nc -nd -nH -np --user="${ADUSER}" --password="${ADPASS}" --no-check-certificate
    unzip ${ARTIDIR}/$latest/gordon_peak_acrn-flashfiles-P*.zip
    cd ${BASEDIR}
  fi
  if [ -e ${ARTIDIR}/${latest}/sos_boot.img ] ; then
    break
  else
    mv ${ARTIDIR}/$latest ${ARTIDIR}/_tmp_${latest}
    cp -a ${ARTIDIR}/build.index ${ARTIDIR}/build.index.0
    cat ${ARTIDIR}/build.index.0 | grep -v "${latest}" > ${ARTIDIR}/build.index
    latest=`html2text ${ARTIDIR}/build.index | head -n -2 | tail -n +5 | awk '{print $1}' | sed 's/->//g' | sed 's/.$//' | awk -v max=0 '{if($1>max){want=$1; max=$1}}END{print want"/"}'`
  fi
done

echo $latest > ${ARTIDIR}/build.latest

echo "Latest version: $latest"

cd ${WORKDIR}
