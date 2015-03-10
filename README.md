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
 ```sh
 vagrant init AntonioMeireles/boot2docker-vagrant-box
 ```
#### power up
```sh
vagrant up
```
next, we need to populate a few environment vars in the running shell, so that our local docker client knows what we are up to.

We have two options:

- the *manual* way...

  ```sh

  source .env
  ```
- the *automated* way

  adding in your shell an hook to check if the **boot2docker** VM is up, and if so, populate the *env* vars automatically.

  In my case as i use **[zsh](http://www.zsh.org/)** (and **[zprezto](https://github.com/sorin-ionescu/prezto)**) i
  have the follwing bits in **~/.zshrc** *(context code added for clarity)* ...

  ```sh
  function setDockerEnvVars {
      local target="/Users/am/Vagrant/boot2docker/.env"
      if [[ -a ${target} ]]; then
          source ${target}
      else
          unset DOCKER_TLS_VERIFY
          unset DOCKER_HOST
          unset DOCKER_CERT_PATH
      fi
  }

  # tweak title bar
  function precmd {
      # vcs_info
      # Put the string "hostname::/full/directory/path" in the title bar:
      echo -ne "\e]2;$(hostname -s)::$PWD\a"
      # Put the parentdir/currentdir in the tab
      echo -ne "\e]1;$PWD:h:t/$PWD:t\a"
  }

  function set_running_app {
      printf "\e]1; $PWD:t:$(history $HISTCMD | cut -b7- ) \a"
  }

  function preexec {
      setDockerEnvVars
      set_running_app
  }

  function postexec {
      set_running_app
  }

  function startDocker {
      (cd ~am/Vagrant/boot2docker ; vagrant up 1>/dev/null)
      setDockerEnvVars
  }

  function stopDocker {
      (cd ~am/Vagrant/boot2docker ; vagrant halt )
  }

  function docker {
      [ ! -n "${DOCKER_TLS_VERIFY+x}" ] && startDocker
      /usr/local/bin/docker "$@"
  }
```
    > achieving the same goal with **bash** is left as an exercise to the reader.

then *just* do whatever you want to with docker :smile:

#### allocated resources

By default this **boot2docker** box will run with 1 CPU and 1024MB of memory
allocated to it. You can change the number of running CPUs via the `B2D_CPUS`
environment variable and the memory allocated to it (in MB) via the `B2D_MEM`
environment variable.

Ence `B2D_CPUS=2 B2D_MEM=2048 vagrant up` would start **boot2docker** with
2GB of memory and 2 virtual CPUS allocated to it.

#### updates and data persistence

To update to a newer version of this **boot2docker** box, and per
[general vagrant behavior](http://docs.vagrantup.com/v2/boxes/versioning.html),
you'll need to run `vagrant destroy`, `vagrant box update` and  `vagrant up`. When destroying the existing box boot2docker persistent data will be saved
inside `.boot2docker` in the Vagrantfile directory and later restored into the newly provisioned up-to-date box.

## TODO
*(in no particular order)*

- add **Parallel Tools** support (will be simpler ence [this](https://github.com/boot2docker/boot2docker/issues/755) upstream *issue* gets fixed) for *native* shared folder support.

## (re)building or modifying the box locally
### pre-requisites
  * **[Packer](http://www.packer.io)** (at least version 0.6.1 for Parallels)
  * **[Parallels Desktop](http://www.parallels.com/products/desktop/)** and **[SDK](http://www.parallels.com/download/pvsdk/)**.

```sh
make
```

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


