all: boot2docker-parallels.box

parallels: boot2docker-parallels.box

boot2docker-parallels.box: boot2docker.iso template.json vagrantfile.tpl
	packer build -only parallels template.json

boot2docker.iso:
	curl -LO https://github.com/boot2docker/boot2docker/releases/download/v1.5.0/boot2docker.iso

clean:
	rm -f boot2docker.iso
	rm -f boot2docker-parallels.box
	rm -rf output-*/

.PHONY: test clean

