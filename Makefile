#!/usr/bin/make -f


.PHONY: all
all: parallels
	date


.PHONY: parallels
parallels: boot2docker-parallels.box


boot2docker-parallels.box: boot2docker.iso template.json vagrantfile.tpl
	time packer build -only parallels template.json


boot2docker.iso:
	curl -LO https://github.com/boot2docker/boot2docker/releases/download/v1.5.0/boot2docker.iso


.PHONY: clean
clean:
	rm -f boot2docker.iso
	rm -f boot2docker-parallels.box
	rm -rf output-*/
	rm -rf packer_cache/

