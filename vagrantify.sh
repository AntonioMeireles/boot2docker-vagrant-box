#!/bin/bash
#
# refactor the upstream boot2docker ISO to inject into it the default vagrant
# insecure public ssh key.
#
set -ex

B2D_ISO="/foo/boot2docker-${VERSION}.iso"

yum install cpio lzma xz genisoimage -y

rm -rf /temp/
mkdir -p /temp/tmp

mount "${B2D_ISO}" /temp/tmp -o loop,ro
cp -a /temp/tmp/boot /temp
mv /temp/boot/initrd.img /temp
umount /temp/tmp

EXTRACT_DIR="/temp/extract"
mkdir -p ${EXTRACT_DIR}

pushd ${EXTRACT_DIR}
    lzma -dc /temp/initrd.img | cpio -i -H newc -d
popd

cat <<EOF > ${EXTRACT_DIR}/etc/rc.d/vagrant
mkdir -p /home/docker/.ssh && chmod 0700 /home/docker/.ssh

cat <<KEY >/home/docker/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
KEY

chmod 0600 /home/docker/.ssh/authorized_keys && chown -R docker:staff /home/docker/.ssh
EOF
chmod +x ${EXTRACT_DIR}/etc/rc.d/vagrant

echo "/etc/rc.d/vagrant" >> ${EXTRACT_DIR}/opt/bootsync.sh

pushd ${EXTRACT_DIR}
 find . | cpio -o -H newc | xz -9 --format=lzma > /temp/initrd.img
popd

pushd /temp
    mv initrd.img boot
    mkdir newiso
    mv boot newiso
popd

mkisofs -l -J -R -V b2d-vagrant -no-emul-boot -boot-load-size 4 \
     -boot-info-table -b boot/isolinux/isolinux.bin \
     -c boot/isolinux/boot.cat -o "/foo/boot2docker-vagrant-${VERSION}.iso" /temp/newiso
rm -rf /temp/newiso
