# boot2docker Vagrant Box - Parallels

This is basically a more-frequently-updated version of
Parallels/boot2docker-vagrant-box#7 with support for Parallels only.


## Usage

Check the
[releases page](https://github.com/wearableintelligence/boot2docker-parallels-vagrant-box/releases)
and `vagrant up` as usual!

    $ vagrant plugin install vagrant-parallels.
    $ mkdir -p ~/src/wi/new-proj && cd ~/src/wi/new-proj
    $ mv ~/Downloads/boot2docker-parallels.box ../
    $ vagrant init ../boot2docker-parallels.box
    $ vagrant up
    $ export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2376"
    $ export DOCKER_TLS_VERIFY=1
    $ export DOCKER_CERT_PATH="`pwd`/.docker"
    $ docker ps


## Building the Box

  * [Packer](http://www.packer.io) (at least version 0.5.2, 0.6.1 for Parallels)
  * [Parallels Desktop](http://www.parallels.com/products/desktop/)

Then, just run `make`. The resulting box will be named `boot2docker-parallels.box`.
The entire process to make the box takes about 20 seconds.


## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

- [boot2docker](http://boot2docker.io/) is under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).
- [Vagrant](http://www.vagrantup.com/): Copyright (c) 2010-2014 Mitchell Hashimoto, under the [MIT License](https://github.com/mitchellh/vagrant/blob/master/LICENSE)

