#!/bin/bash

set -e

[ "$1" == "" ] && { echo "Please set base directory." ; exit 1; }
BASE_DIR=$1
PACKAGE_LIST=$(colcon list --names-only)
PACKAGE_LIST_FULL=$(colcon list)

# Set generated timestamp
if [ $# -eq 6 ]; then
  TIMESTAMP=$(cat $6)
else
  TIMESTAMP=$(date -u '+%Y%m%d_%H%M%S')
fi

[ "$2" == "" ] && { echo "Please set output directory." ; exit 1; }
OUTPUT_DIR=${2}/lizard_result/${TIMESTAMP}

function get_package_path() {
  [ "$1" == "" ] && return 1

  echo "$PACKAGE_LIST_FULL" | grep -w "$1" | awk '{ print $2 }'
  return 0
}

function exec_lizard() {
  [ "$1" == "" ] && return 1

  if [ ! -d ${OUTPUT_DIR}/$1 ]; then
    mkdir -p ${OUTPUT_DIR}/$1
  fi

  PACKAGE_PATH=$(get_package_path "$1")

  python3 lizard/lizard.py -l cpp -l python -x "*test*" -x "*lizard*" \
    --CCN $2 -T nloc=$3 --arguments $4 \
    --html $PACKAGE_PATH > ${OUTPUT_DIR}/$1/index.html || true
}

if [ ! -d "lizard" ]; then
  git clone https://github.com/terryyin/lizard.git
fi

for PACKAGE in $PACKAGE_LIST; do
  exec_lizard $PACKAGE $3 $4 $5
done