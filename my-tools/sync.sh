#!/bin/bash

__FILE__="$0"
REAL_FILE=`readlink "${__FILE__}"`
if [ ! -z "${REAL_FILE}" ]; then
    __FILE__="${REAL_FILE}"
fi

__DIR__=`cd "$(dirname "${__FILE__}")"; pwd`

. "${__DIR__}/sync.config"

if [ -z "${remoteAddr}" ] || [ -z "${targetPath}" ]; then
    echo 'configuration error!'
    exit
fi

sourcefolder="${__DIR__}/../"

BIN="${__DIR__}/.bin"
if [ ! -d "${BIN}" ]; then
    mkdir "${BIN}"
fi
rm -rf "${BIN}"/*

rsync -av \
	--exclude "$(basename "${__DIR__}")" \
	--exclude ".git" \
    --exclude ".DS_Store" \
    --exclude ".idea" \
	"${sourcefolder}" "${BIN}" 

TMP_FILE="./tmp.web.tgz"

tar -czf "${TMP_FILE}" -C ${BIN} .

ssh ${remoteAddr} "rm -rf ${targetPath}.old; mv ${targetPath} ${targetPath}.old; mkdir ${targetPath}"
scp "${TMP_FILE}" "${remoteAddr}:${targetPath}"
ssh ${remoteAddr} "cd ${targetPath}; tar -xzf tmp.web.tgz; rm tmp.web.tgz"

rm "${TMP_FILE}"

echo "Succeeded."

