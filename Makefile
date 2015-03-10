VERSION = $(shell docker -v | sed -e 's,.*version ,,' -e 's/,.*//')
DATE = $(shell date -u '+%Y%m%d%H%M')
COMMIT = $(shell git describe --abbrev=7 --always)

UPSTREAM_HOME = https://github.com/boot2docker/boot2docker
UPSTREAM_URL  = $(UPSTREAM_HOME)/releases/download/v$(VERSION)/boot2docker.iso

.PHONY: all parallels virtualbox

all: clean parallels virtualbox

parallels: boot2docker-${VERSION}-${DATE}-${COMMIT}-parallels.box
virtualbox: boot2docker-${VERSION}-${DATE}-${COMMIT}-virtualbox.box

boot2docker-${VERSION}-${DATE}-${COMMIT}-parallels.box: boot2docker-vagrant-${VERSION}.iso
	packer build -parallel=false -only parallels template.json

boot2docker-${VERSION}-${DATE}-${COMMIT}-virtualbox.box: boot2docker-vagrant-${VERSION}.iso
	packer build -parallel=false -only virtualbox template.json

check:
	@which -s docker || ( \
	  echo "ERROR: docker not installed locally, so unable to spot matching "; \
	  echo "       boot2docker version. Install docker first and try again." &&\
	  exit 1 )

boot2docker-${VERSION}.iso: check
	@if [ ! -f boot2docker-${VERSION}.iso ]; then \
		curl -Ls ${UPSTREAM_URL} -o boot2docker-${VERSION}.iso ;\
	fi
	@if [ ! -f boot2docker-vagrant-${VERSION}.iso ]; then \
		docker run -ti --privileged -e "VERSION=${VERSION}" \
			-v $$(pwd):/foo fedora:20 /foo/vagrantify.sh; \
	fi

boot2docker-vagrant-${VERSION}.iso: boot2docker-${VERSION}.iso template.json.tmpl vagrantfile.tpl
	$(eval CHECKSUM := $(shell md5sum ./boot2docker-vagrant-${VERSION}.iso | cut -d " " -f 1))
	@sed -e "s,_VERSION_,${VERSION},g" \
		 -e "s,_CHECKSUM_,${CHECKSUM},g" \
		 -e "s,_DATE_,${DATE},g" \
		 -e "s,_COMMIT_,${COMMIT},g" \
			template.json.tmpl > template.json
	@sed -e "s,_VERSION_,${VERSION},g" \
		 -e "s,_DATE_,${DATE},g" \
		 -e "s,_COMMIT_,${COMMIT},g" \
		 	vagrantfile.tpl > vagrantfile

.PHONY: clean
clean:
	rm -rf output-*/
	rm -rf packer_cache/

