# [boot2docker](https://github.com/boot2docker/boot2docker) Vagrant box, done right

## motivation
The upstream [boot2docker](https://github.com/boot2docker/boot2docker) only supports VirtualBox 
and *imho* its setup is a bit more convoluted than it could be. So this project was born with the
aim of supporting additional hypervisors (starting with Parallels) and simplify the installation
and usage process by having it distributable as a plain simple Vagrant box.
### check [Vagrant's Atlas](https://atlas.hashicorp.com/AntonioMeireles/boxes/boot2docker-vagrant-box) for box release details. 

## usage
### pre-requisites
 - **[Vagrant](https://www.vagrantup.com)**
 - the **[vagrant-triggers](https://github.com/emyl/vagrant-triggers)** Vagrant plugin, as the box will refuse to start without it installed. install it by invoking ```vagrant plugin install vagrant-triggers```.  
 - a supported Vagrant hypervisor
   - **[Virtualbox](https://www.virtualbox.org)**
   - **[Parallels Desktop](http://www.parallels.com/eu/products/desktop/)**

### notes about hypervisors
 - if you are using **VirtualBox** you don't need to do anything *extra* as it is the default Vagrant hypervisor.
 - If you are using **Parallels Desktop** you need to have installed the **[vagrant-parallels](http://parallels.github.io/vagrant-parallels/docs/)** provider which you can do by just doing ```vagrant plugin install vagrant-parallels```.
Then just add ```--provider parallels``` to the ```vagrant up``` invocations bellow.

### running
#### 1st time only
 ```
 $ vagrant init AntonioMeireles/boot2docker-vagrant-box
 ```
#### power up  
```
$ vagrant up
$ source .env
```
then just do whatever you want to with docker :smile:

## (re)building or modifyig the box locally
### pre-requisites
  * **[Packer](http://www.packer.io)** (at least version 0.6.1 for Parallels)
  * **[Parallels Desktop](http://www.parallels.com/products/desktop/)** and **[SDK](http://www.parallels.com/download/pvsdk/)**.

just run ```make```

## Thanks
###projects without those this wouldn't possible

- **[boot2docker](http://boot2docker.io/)**
- the *original*, out of date, **[boot2docker-vagrant-box](https://github.com/mitchellh/boot2docker-vagrant-box)**
- **[this](https://github.com/dduportal/boot2docker-vagrant-box)** **boot2docker-vagrant-box** *fork*.
- and **[this](https://github.com/Parallels/boot2docker-vagrant-box/)** one.
- and yet **[this](https://github.com/wearableintelligence/boot2docker-vagrant-box)** one too. 

## Licensing

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.


