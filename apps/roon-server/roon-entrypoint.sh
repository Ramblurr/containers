#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

export DOTNET_ROOT="$ROOTPATH/RoonDotnet"
export PATH=$DOTNET_ROOT:"$PATH"
#export LD_LIBRARY_PATH="$DOTNET_ROOT/lib:$LD_LIBRARY_PATH"
export FONTCONFIG_PATH=$DOTNET_ROOT/etc/fonts
#export MONO_DEBUG=no-gdb-backtrace
#export MONO_GC_PARAMS=major=marksweep-conc,nursery-size=16m
#export MONO_TLS_PROVIDER=btls
#export MONO_ENABLE_BLOCKING_TRANSITION=1
cd ${ROOTPATH}
exec ${DOTNET_ROOT}/dotnet ${ROOTPATH}/Server/RoonServer.dll "$@"
