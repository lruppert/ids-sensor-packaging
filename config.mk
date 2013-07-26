#
# pfring sources
#
PF_RING_VERSION ?= 5.6.0
PF_RING_SCHEME := http
PF_RING_HOST := iweb.dl.sourceforge.net
PF_RING_PATH := /project/ntop/PF_RING
PF_RING_TARBALL := PF_RING-$(PF_RING_VERSION).tar.gz
PF_RING_DL_URL := http://$(PF_RING_HOST)$(PF_RING_PATH)/$(PF_RING_TARBALL)

#
# bro sources
#
BRO_VERSION ?= 2.1
BRO_SCHEME := http
BRO_HOST := www.bro.org
BRO_PATH := /downloads/release
BRO_TARBALL := bro-$(BRO_VERSION).tar.gz
BRO_DL_URL := http://$(BRO_HOST)$(BRO_PATH)/$(BRO_TARBALL)

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
