##############################################################################
# Run:
#    make
#    make start
#
# Go to:
#
#     http://localhost:8080
#
# Create a new Plone Site (admin:admin)
#
##############################################################################
# SETUP MAKE
#
## Defensive settings for make: https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
# for Makefile debugging purposes add -x to the .SHELLFLAGS
.SHELLFLAGS:=-eu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

# Colors
# OK=Green, warn=yellow, error=red
ifeq ($(TERM),)
# no colors if not in terminal
	MARK_COLOR=
	OK_COLOR=
	WARN_COLOR=
	ERROR_COLOR=
	NO_COLOR=
else
	MARK_COLOR=`tput setaf 6`
	OK_COLOR=`tput setaf 2`
	WARN_COLOR=`tput setaf 3`
	ERROR_COLOR=`tput setaf 1`
	NO_COLOR=`tput sgr0`
endif

##############################################################################
# SETTINGS AND VARIABLE

PLONE_VERSION=`docker run -i --rm eeacms/plone-backend env | grep PLONE_VERSION | sed "s/PLONE_VERSION=//g"`
PIP_PARAMS=		#`docker run -i --rm eeacms/plone-backend env | grep PIP_PARAMS | sed "s/PIP_PARAMS=//g"`

# Top-level targets
.PHONY: all
all: bootstrap develop install

.PHONY: bootstrap
bootstrap:		## Bootstrap python environment
	python3 -m venv .
	bin/pip install --upgrade pip mxdev

.PHONY: develop
develop:		## Develop source.ini add-ons using mxdev
	bin/mxdev -c sources.ini

.PHONY: install
install:		## Install Plone and develop add-ons
	bin/pip install Plone plone.volto -c https://dist.plone.org/release/$(PLONE_VERSION)/constraints.txt $(PIP_PARAMS)
	bin/pip install -r requirements-mxdev.txt $(PIP_PARAMS)
	bin/mkwsgiinstance -d . -u admin:admin

.PHONY: start
start:			## Start Plone backend
	bin/runwsgi -v etc/zope.ini

.PHONY: help
help:			## Show this help.
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"
	head -n 12 Makefile
