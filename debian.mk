.PHONY: package prepackage sources pkgclean

include config.mk

#
# Debian Packaging
#

RELEASE ?= stable
PACKAGE := ids-sensor-package
DISTDIR := $(PWD)/distdir
DL_DIR := $(PWD)/downloads

PKGDIR := $(DISTDIR)/$(PACKAGE)

PGM_CURL := /usr/bin/curl
PGM_DATE := /bin/date
PGM_LSB_RELEASE := /usr/bin/lsb_release
PGM_DPKG_PARSECHANGELOG := /usr/bin/dpkg-parsechangelog
PGM_DPKG_ARCHITECTURE := /usr/bin/dpkg-architecture
PGM_DCH := /usr/bin/dch
PGM_DEBUILD := /usr/bin/debuild 
PGM_GIT := /usr/bin/git
PGM_TAR = /bin/tar

DATE := $(call get_date)
OSNAME := $(call get_osname)
CODENAME := $(call get_codename)
ARCH := $(call get_arch)

# SIGN details
#
# To sign the package, either include SIGN_KEY_ID, SIGN_FULLNAME, and SIGN_EMAIL in config.mk,
# or call make as follows:
#
# make package SIGN_KEY_ID=FFFFFFFF SIGN_FULLNAME='My signing key full name' SIGN_EMAIL='nobody@example.com'
ifeq ("$(SIGN_KEY_ID)","")
	SIGN_OPT = -us -uc
else
	SIGN_OPT = -k$(SIGN_KEY_ID)
endif

#
# PROXY handling
#
ifneq ("$(HTTP_PROXY)","")
	CURL_PROXY := -x $(HTTP_PROXY)
endif

#SUBPKGS = pf_ring bro suricata
SUBPKGS = pf_ring bro

package: prepackage sources $(SUBPKGS:%=%_debian)

prepackage: $(SUBPKGS:%=%_check_vars) pkgclean
	@echo '=========='
	@echo "Signing options: $(SIGN_OPT)"
	@echo '=========='
	$(PGM_GIT) clone . $(PKGDIR)

sources: $(SUBPKGS:%=%_source)

pkgclean:
	@rm -rf $(DISTDIR)

#
# Support functions
#

# $(call get_date)
get_date = $(shell $(PGM_DATE) +'%Y-%m-%d')

# $(call get_osname)
get_osname = $(shell $(PGM_LSB_RELEASE) --short --id)

# $(call get_codename)
get_codename = $(shell $(PGM_LSB_RELEASE) --short --codename)

# $(call get_arch)
get_arch = $(shell $(PGM_DPKG_ARCHITECTURE) -qDEB_BUILD_ARCH)

# $(call get_pkg)
get_pkg = $(PGM_DPKG_PARSECHANGELOG) --count 0 | awk '/^Source:/ { print $$2 }'

# $(call get_pkg_version)
get_pkg_version = $(PGM_DPKG_PARSECHANGELOG) --count 0 | awk '/^Version:/ { print $$2 }'

# Create a variable name by uppercasing $(1) and appending _DL_URL,
# then indirecting that to get the actual URL
make_dl_url = $(call value_of,$(1),_DL_URL)

make_dl_tarball = $(call value_of,$(1),_TARBALL)

check_var = $(if $(call value_of,$(1),$(2)),,$(error Missing var: $(call append_name,$(1),$2)))

uppercase = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')

append_name = $(call uppercase,$(1)$(2))

value_of = $(value $(call append_name,$(1),$2))

# $(call version_string,PACKAGE,PKG_VERSION,DATE,OSNAME,ARCH)
version_string = $(1) ($(2) $(3)) $(4) $(5)

#
# git support functions
#

get_git_log = $(shell $(PGM_GIT) log --oneline -1)

get_git_hash = $(shell $(PGM_GIT) rev-parse --short HEAD)

get_git_last_commit_date = $(shell $(PGM_GIT) log -1 --format='%cD')

# $(call date_to_utc,DATE)
date_to_utc = $(shell $(PGM_DATE) --date="$(1)" --utc +'%Y%m%d.%H%M%S')

# This template generates a make rule to check for required variables
# $(call check_vars_template,pf_ring|bro|suricata)
define check_vars_template
.PHONY: $(1)_check_vars
$(1)_check_vars:
	$$(call check_var,$(1),_TARBALL)
	$$(call check_var,$(1),_DL_URL)

GIT_LOG := $(call get_git_log)
GIT_HASH := $(call get_git_hash)
GIT_LAST_COMMIT_UTC := $(call date_to_utc,$(call get_git_last_commit_date))
endef

$(foreach prog,$(SUBPKGS),$(eval $(call check_vars_template,$(prog))))

# This template generates a make rule to download the package
# source and expand it into the right place
# $(call get_source_template,pf_ring|bro|suricata)
define get_source_template
 .PHONY: $(1)_source
 $(1)_source:
	mkdir -p $(DL_DIR)
	cd $(DL_DIR) && \
	export dl_tarball=$$(call make_dl_tarball,$(1)) && \
	if ! test -f $$$$dl_tarball; then $(PGM_CURL) $(CURL_PROXY) --fail -O -s "$$(call make_dl_url,$(1))"; fi && \
	$(PGM_TAR) xfz $$$$dl_tarball && \
	export tld=`$(PGM_TAR) tfz $$$$dl_tarball | sed 's@/.*$$$$@@' | uniq` && \
	cp -Rp $$$$tld/* $(PKGDIR)/$(1)/ && \
	rm -rf $$$$tld
endef

$(foreach prog,$(SUBPKGS),$(eval $(call get_source_template,$(prog))))

# $(call build_debian,PROG,BUILD_DIR,RELEASE)
define build_debian
 .PHONY: $(1)_debian
 $(1)_debian:
	cd $(2)/$(1) && \
	export pkg_ver=$$$$($$(call get_pkg_version)) && \
	export pkg=$$$$($$(call get_pkg)) && \
	$(PGM_DCH) --noquery \
		--force-distribution \
		--distribution $(3) \
		-b -v "$$$$pkg_ver.$(GIT_LAST_COMMIT_UTC)~$(GIT_HASH)+$(CODENAME)" \
		"$(GIT_LOG)"
	cd $(2)/$(1) && \
	$(PGM_DEBUILD) --no-lintian \
		-e REVISION="$$$$pkg_ver" \
		-e RELEASE="$(3)" \
		-e VERSIONSTRING="$(call version_string,$$$$pkg,$$$$pkg_ver,$(DATE),$(OSNAME),$(ARCH))" \
		-b -tc \
		$(SIGN_OPT)
endef

$(foreach prog,$(SUBPKGS),$(eval $(call build_debian,$(prog),$(PKGDIR),$(RELEASE))))

# vim: set filetype=make syntax=make noet ts=4 sts=4 sw=4 si:

