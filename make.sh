#!/bin/bash

case $1 in
    build)
        cat src/main/*.sh > dist/cismail
        ;;
    local_install)
        bindir=$HOME/.local/bin
        install -m755 "dist/cismail" "$bindir/cismail"
        ;;
    ''|all)
        bash "$0" build
        bash "$0" local_install
        ;;
esac
