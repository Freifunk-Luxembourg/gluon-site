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

SIGNING_KEY=$(readlink -e "$1")

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
	ar71xx-generic ar71xx-tiny ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709 mpc85xx-generic ramips-mt7621 x86-generic x86-geode x86-64
do
	echo "Starting work on target $TARGET"
	# GLUON_BRANCH configures the default autoupdater branch.
        run_and_print make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE="$RELEASE_VERSION" update
	run_and_print make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE="$RELEASE_VERSION" -j 9
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
	run_and_print make GLUON_BRANCH=stable GLUON_RELEASE=$RELEASE_VERSION GLUON_PRIORITY=4 manifest
	run_and_print contrib/sign.sh $SIGNING_KEY output/images/sysupgrade/stable.manifest
	echo -e "\n\n\n============================================================\n\n"
fi

cd site
echo "Done :)"
