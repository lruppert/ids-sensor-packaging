#
# pfring sources
#
PF_RING_VERSION ?= 6.0.3
PF_RING_SCHEME := http
PF_RING_HOST := iweb.dl.sourceforge.net
PF_RING_PATH := /project/ntop/PF_RING
PF_RING_TARBALL := PF_RING-$(PF_RING_VERSION).tar.gz
PF_RING_DL_URL := $(PF_RING_SCHEME)://$(PF_RING_HOST)$(PF_RING_PATH)/$(PF_RING_TARBALL)

#
# bro sources
#
BRO_VERSION ?= 2.3.2
BRO_SCHEME := https
BRO_HOST := www.bro.org
BRO_PATH := /downloads/release
BRO_TARBALL := bro-$(BRO_VERSION).tar.gz
BRO_DL_URL := $(BRO_SCHEME)://$(BRO_HOST)$(BRO_PATH)/$(BRO_TARBALL)

#
# suricata sources
#
SURICATA_VERSION ?= 2.0.7
SURICATA_SCHEME := http
SURICATA_HOST := www.openinfosecfoundation.org
SURICATA_PATH := /download
SURICATA_TARBALL := suricata-$(SURICATA_VERSION).tar.gz
SURICATA_DL_URL := $(SURICATA_SCHEME)://$(SURICATA_HOST)$(SURICATA_PATH)/$(SURICATA_TARBALL)

#
# HTTP Proxy
#
# HTTP_PROXY := myproxy.example.com:3128

#
# APT signing key and info
#
# SIGN_KEY_ID ?= FFFFFFFF
# SIGN_FULLNAME ?= My signing info
# SIGN_EMAIL ?= build@example.com
