#!/bin/sh

SDK_DIR=$(realpath $(dirname "$0")/../../../)
LUA="$SDK_DIR/output/host/usr/bin/lua"

if ! [ -e "$LUA" ]; then
    LUA="lua"
fi

cd $SDK_DIR && $LUA scripts/maintenance/fixup_profile/fixup-profiles.lua "$@"
