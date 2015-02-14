# boot2docker Vagrant Box - Parallels

This is a more-frequently-updated version of
[Parallels/boot2docker-vagrant-box](https://github.com/Parallels/boot2docker-vagrant-box/issues/7)
with support for Parallels only.


## Using this box as a base

    $ vagrant plugin install vagrant-parallels
    $ vagrant plugin install vagrant-triggers

    $ curl -LO https://github.com/wearableintelligence/boot2docker-vagrant-box/releases/download/docker%2Fv1.5.0/boot2docker-parallels.box
    $ vagrant box add --name wearableintelligence/boot2docker-parallels boot2docker-parallels.box
    $ rm boot2docker-parallels.box

    $ mkdir ~/my_new_project && cd ~/my_new_project
    $ vagrant init wearableintelligence/boot2docker-parallels
    $ vagrant up

    $ source .env
    $ docker ps


## Building the box

  * [Packer](http://www.packer.io) (at least version 0.5.2, 0.6.1 for Parallels)
  * [Parallels Desktop](http://www.parallels.com/products/desktop/)

Run `make`. The resulting box will be named `boot2docker-parallels.box`.


## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

- [boot2docker](http://boot2docker.io/) is under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).
- [Vagrant](http://www.vagrantup.com/): Copyright (c) 2010-2014 Mitchell Hashimoto, under the [MIT License](https://github.com/mitchellh/vagrant/blob/master/LICENSE)

