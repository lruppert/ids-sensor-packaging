ifneq ("$(PROGRAMFILES)$(ProgramFiles)","")
OS := Windows
else
OS := $(shell lsb_release --short --id)
endif

ifeq ("$(OS)","Debian")
include debian.mk
endif

ifeq ("$(OS)","Ubuntu")
include debian.mk
endif

# vim: set filetype=make syntax=make noet ts=4 sts=4 sw=4 si:
