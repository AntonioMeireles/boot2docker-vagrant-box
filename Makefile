VERSION = $(shell docker -v | sed -e 's,.*version ,,' -e 's/,.*//')
UPSTREAM_HOME = https://github.com/boot2docker/boot2docker
UPSTREAM_URL  = $(UPSTREAM_HOME)/releases/download/v$(VERSION)/boot2docker.iso

.PHONY: all parallels virtualbox

all: parallels virtualbox

parallels: boot2docker-${VERSION}-parallels.box
virtualbox: boot2docker-${VERSION}-virtualbox.box

boot2docker-${VERSION}-parallels.box: boot2docker-vagrant-${VERSION}.iso
	packer build -parallel=false -only parallels template.json

boot2docker-${VERSION}-virtualbox.box: boot2docker-vagrant-${VERSION}.iso
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
	#
	docker run -t -i --privileged -e 'VERSION=${VERSION}' -v $$(pwd):/foo fedora:20 /foo/vagrantify.sh
	# cp boot2docker-${VERSION}.iso boot2docker-vagrant-${VERSION}.iso
boot2docker-vagrant-${VERSION}.iso: boot2docker-${VERSION}.iso template.json.tmpl vagrantfile.tpl
	$(eval CHECKSUM := $(shell md5sum ./boot2docker-vagrant-${VERSION}.iso | cut -d " " -f 1))
	@sed -e "s,_VERSION_,${VERSION},g" -e "s,_CHECKSUM_,${CHECKSUM},g" template.json.tmpl > template.json
	@sed -e "s,_VERSION_,${VERSION},g" vagrantfile.tpl > vagrantfile

.PHONY: clean
clean:
	rm -f boot2docker-${VERSION}.iso
	rm -f boot2docker-vagrant-${VERSION}.iso
	rm -f boot2docker-${VERSION}-{parallels,virtualbox}.box
	rm -rf output-*/
	rm -rf packer_cache/

