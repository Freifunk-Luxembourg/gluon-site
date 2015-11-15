#!/bin/bash

## This script will compile Gluon for all architectures, create the
## manifest and sign it. For that, you must have clone gluon and have a
## valid site config. Additionally, the signing key must be present in
## ../../ecdsa-key-secret.
## Call from site directory with the version and branch variables
## properly configured in this script.

# if version is unset, will use the default experimental version from site.mk
VERSION=1.0~exp20151115
# branch must be set to either experimental, beta or stable
BRANCH=experimental

cd ..
if [ ! -d "site" ]; then
	echo "This script must be called from within the site directory"
	return
fi

rm build.log
rm -r images
for TARGET in  ar71xx-generic ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709 mpc85xx-generic sunxi x86-64 x86-generic x86-kvm_guest x86-xen_domu
do
	if [ -z "$VERSION" ]
	then
		echo "Starting work on target $TARGET" | tee -a build.log
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable update" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable update >> build.log 2>&1
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable clean" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable clean >> build.log 2>&1
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable -j9" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable -j9 >> build.log 2>&1
		echo -e "\n\n\n============================================================\n\n" >> build.log
	else
		echo "Starting work on target $TARGET" | tee -a build.log
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION update" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION update >> build.log 2>&1
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION clean" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION clean >> build.log 2>&1
		echo -e "\n\n\nmake GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION -j9" >> build.log
		make GLUON_TARGET=$TARGET GLUON_BRANCH=stable GLUON_RELEASE=$VERSION -j9 >> build.log 2>&1
		echo -e "\n\n\n============================================================\n\n" >> build.log
	fi
done
echo "Compilation complete, creating manifest(s)" | tee -a build.log

echo -e "make GLUON_BRANCH=experimental manifest" >> build.log
make GLUON_BRANCH=experimental manifest >> build.log 2>&1
echo -e "\n\n\n============================================================\n\n" >> build.log

if [[ "$BRANCH" == "beta" ]] || [[ "$BRANCH" == "stable" ]]
then
	echo -e "make GLUON_BRANCH=beta manifest" >> build.log
	make GLUON_BRANCH=beta manifest >> build.log 2>&1
	echo -e "\n\n\n============================================================\n\n" >> build.log
fi

if [[ "$BRANCH" == "stable" ]]
then
	echo -e "make GLUON_BRANCH=stable manifest" >> build.log
	make GLUON_BRANCH=stable manifest >> build.log 2>&1
	echo -e "\n\n\n============================================================\n\n" >> build.log
fi

echo "Manifest creation complete, signing manifest"

echo -e "contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/experimental.manifest" >> build.log
contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/experimental.manifest >> build.log 2>&1

if [[ "$BRANCH" == "beta" ]] || [[ "$BRANCH" == "stable" ]]
then
	echo -e "contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/beta.manifest" >> build.log
	contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/beta.manifest >> build.log 2>&1
fi

if [[ "$BRANCH" == "stable" ]]
then
	echo -e "contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/stable.manifest" >> build.log
	contrib/sign.sh ../ecdsa-key-secret images/sysupgrade/stable.manifest >> build.log 2>&1
fi

echo "Done :)"
