#!/usr/bin/env bash

ROOT=$(pwd)
DEPS_LOCATION=_build/deps
OS=$(uname -s)
KERNEL=$(echo $(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 | awk '{print $1;}') | awk '{print $1;}')

# https://github.com/facebook/zstd.git

ZSTD_DESTINATION=zstd
ZSTD_REPO=https://github.com/facebook/zstd.git
ZSTD_BRANCH=master
ZSTD_REV=10f0e6993f9d2f682da6d04aa2385b7d53cbb4ee
ZSTD_SUCCESS=lib/libzstd.a

fail_check()
{
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi
}

CheckoutLib()
{
    if [ -f "$DEPS_LOCATION/$4/$5" ]; then
        echo "$4 fork already exist. delete $DEPS_LOCATION/$4 for a fresh checkout ..."
    else
        #repo rev branch destination

        echo "repo=$1 rev=$2 branch=$3"

        mkdir -p $DEPS_LOCATION
        pushd $DEPS_LOCATION

        if [ ! -d "$4" ]; then
            fail_check git clone -b $3 $1 $4
        fi

        pushd $4
        fail_check git checkout $2
        BuildLibrary $4
        popd
        popd


    fi
}

BuildLibrary()
{
    fail_check cmake build/cmake/
    fail_check make -j 12
}

CheckoutLib $ZSTD_REPO $ZSTD_REV $ZSTD_BRANCH $ZSTD_DESTINATION $ZSTD_SUCCESS
