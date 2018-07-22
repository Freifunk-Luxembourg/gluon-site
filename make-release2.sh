#!/bin/bash
set -e

## This script will compile Gluon for all architectures, create the
## manifest and sign it. For that, you must have clone gluon and have a
## valid site config. Additionally, the signing key must be present in
## ../../ecdsa-key-secret or defined as first argument.
## The second argument defines the branch (stable, beta, experimental).
## The third argument defines the version.
## Call from site directory with the version and branch variables
## properly configured in this script.

VERSION=${2:-"2.1.3~exp$(date '+%Y%m%d')"}
# branch must be set to either experimental, beta or stable
BRANCH=${1:-"experimental"}
# must point to valid ecdsa signing key created by ecdsakeygen, relative to Gluon base directory
SIGNING_KEY=${3:-"../ecdsa-key-secret"}


function run_and_print() {
    echo -e "\n\n\n$@"
    "$@"
}

cd ..
if [ ! -d "site" ]; then
	echo "This script must be called from within the site directory"
	return
fi

rm -rf output
for TARGET in \
	ar71xx-generic ar71xx-mikrotik ar71xx-nand ar71xx-tiny brcm2708-bcm2708 brcm2708-bcm2709 generic ipq806x mpc85xx-generic mvebu ramips-mt7621 ramips-mt7628 ramips-rt305x sunxi x86-64 x86-generic x86-geode
do
	echo "Starting work on target $TARGET"
	# GLUON_BRANCH configures the default autoupdater branch.
	run_and_print make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE="$RELEASE_VERSION" update
	run_and_print make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE="$RELEASE_VERSION" -j8
	echo -e "\n\n\n============================================================\n\n"
done

echo "Compilation complete, creating and signing manifest(s)"

run_and_print make GLUON_BRANCH=experimental GLUON_RELEASE=$RELEASE_VERSION manifest
run_and_print contrib/sign.sh $SIGNING_KEY output/images/sysupgrade/experimental.manifest
echo -e "\n\n\n============================================================\n\n"

if [[ "$RELEASE_BRANCH" == "beta" ]] || [[ "$RELEASE_BRANCH" == "stable" ]]
then
	run_and_print make GLUON_BRANCH=beta GLUON_RELEASE=$RELEASE_VERSION manifest
	run_and_print contrib/sign.sh $SIGNING_KEY output/images/sysupgrade/beta.manifest
	echo -e "\n\n\n============================================================\n\n"
fi

if [[ "$RELEASE_BRANCH" == "stable" ]]
then
	run_and_print make GLUON_BRANCH=stable GLUON_RELEASE=$RELEASE_VERSION GLUON_PRIORITY=1 manifest
	run_and_print contrib/sign.sh $SIGNING_KEY output/images/sysupgrade/stable.manifest
	echo -e "\n\n\n============================================================\n\n"
fi

cd site
echo "Done :)"
