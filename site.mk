##	gluon site.mk makefile example

##	GLUON_SITE_PACKAGES
#		specify gluon/openwrt packages to include here
#               The gluon-mesh-batman-adv-* package must come first because of the dependency resolution


GLUON_SITE_PACKAGES := \
		gluon-mesh-batman-adv-15 \
		gluon-autoupdater \
		gluon-config-mode-autoupdater \
		gluon-config-mode-hostname \
		gluon-config-mode-mesh-vpn \
		gluon-config-mode-geo-location \
		gluon-config-mode-contact-info \
		gluon-config-mode-core \
		gluon-ebtables-filter-multicast \
		gluon-ebtables-filter-ra-dhcp \
		gluon-web-admin \
		gluon-web-autoupdater \
		gluon-web-wifi-config \
		gluon-web-private-wifi \
		gluon-mesh-vpn-fastd \
		gluon-radvd \
		gluon-respondd \
	        gluon-setup-mode \
		gluon-status-page \
		gluon-ssid-changer \
		respondd-module-airtime \
		iwinfo \
		iptables \
		haveged

##	DEFAULT_GLUON_RELEASE
#		version string to use for images
#		gluon relies on
#			opkg compare-versions "$1" '>>' "$2"
#		to decide if a version is newer or not.
#DEFAULT_GLUON_RELEASE := sid~exp$(shell date '+%Y%m%d')
DEFAULT_GLUON_RELEASE := 2.2.0~exp20190205


##	GLUON_RELEASE
#		call make with custom GLUON_RELEASE flag, to use your own release version scheme.
#		e.g.:
#			$ make images GLUON_RELEASE=23.42+5
#		would generate images named like this:
#			gluon-ff%site_code%-23.42+5-%router_model%.bin

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)

# Default priority for updates.
GLUON_PRIORITY ?= 0
GLUON_BRANCH ?= experimental

# set mesh mode for ath10k to 802.11s
GLUON_ATH10K_MESH ?= 11s

# Languages to include
GLUON_LANGS ?= en

GLUON_REGION := eu

USB_X86_GENERIC_NETWORK_MODULES := \
		kmod-usb-ohci-pci \
		kmod-sky2 \
		kmod-atl2 \
		kmod-igb \
		kmod-3c59x \
		kmod-e100 \
		kmod-e1000 \
		kmod-e1000e \
		kmod-natsemi \
		kmod-ne2k-pci \
		kmod-pcnet32 \
		kmod-8139too \
		kmod-r8169 \
		kmod-sis900 \
		kmod-tg3 \
		kmod-via-rhine \
		kmod-via-velocity \
		kmod-forcedeth \
		kmod-iwlwifi

ifeq ($(GLUON_TARGET),x86-generic)
		GLUON_SITE_PACKAGES += \
	$(USB_X86_GENERIC_NETWORK_MODULES)
endif

ifeq ($(GLUON_TARGET),x86-64)
              GLUON_SITE_PACKAGES += \
       $(USB_X86_GENERIC_NETWORK_MODULES)
endif

