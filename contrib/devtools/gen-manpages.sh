#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

JattCoinD=${JattCoinD:-$SRCDIR/JattCoind}
JattCoinCLI=${JattCoinCLI:-$SRCDIR/JattCoin-cli}
JattCoinTX=${JattCoinTX:-$SRCDIR/JattCoin-tx}
JattCoinQT=${JattCoinQT:-$SRCDIR/qt/JattCoin-qt}

[ ! -x $JattCoinD ] && echo "$JattCoinD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
JTCVER=($($JattCoinCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$JattCoinD --version | sed -n '1!p' >> footer.h2m

for cmd in $JattCoinD $JattCoinCLI $JattCoinTX $JattCoinQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${JTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${JTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m