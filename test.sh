#!/bin/bash

DIRNAME="$(cd "$(dirname "$0")";pwd -P)"
FILES=${1:-*}'.vader'

TZ=UTC vim -Nu <(cat << EOF
set rtp+=$DIRNAME
set rtp+=$DIRNAME/vader.vim
EOF) "+Vader! test/**/$FILES"
