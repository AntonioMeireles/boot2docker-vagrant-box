# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.3"

required_plugins = %w(vagrant-triggers vagrant-reload)
required_plugins.each do |plugin|
  need_restart = false
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
  exec "vagrant #{ARGV.join(' ')}" if need_restart
end

MEM = ENV['B2D_MEM'] || 1024
CPUS = ENV['B2D_CPUS'] || 1
EXTRA_ARGS = ENV['B2D_EXTRA_ARGS'] || ''

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box_version = ">= _VERSION_._DATE_._COMMIT_"
    config.ssh.shell = "sh"
    config.ssh.username = "docker"
    # config.ssh.password = "tcuser"
    config.ssh.insert_key = false

    # do it, provider specific
    config.vm.synced_folder ".", "/vagrant", :disabled => true

    # Attach the b2d ISO so that it can boot
    config.vm.provider "virtualbox" do |v, override|
         # Synced folder by default,
        override.vm.synced_folder ENV['HOME'], ENV['HOME']
        # Forward the Docker port
        override.vm.network :forwarded_port, guest: 2376, host: 2376

        v.check_guest_additions = true
        v.functional_vboxsf     = true
        v.customize "pre-boot", [
            "storageattach", :id,
            "--storagectl", "IDE Controller",
            "--port", "0",
            "--device", "1",
            "--type", "dvddrive",
            "--medium",
                File.expand_path("../boot2docker-vagrant-_VERSION_.iso",
                    __FILE__),
        ]
    end

    ["parallels", "virtualbox"].each do |h|
        config.vm.provider h do |n|
            n.memory = MEM
            n.cpus = CPUS
        end
    end

    ["vmware_fusion", "vmware_workstation"].each do |vmware, override|
        config.vm.provider vmware do |v|
            v.vmx["bios.bootOrder"]    = "CDROM,hdd"
            v.vmx["ide1:0.present"]    = "TRUE"
            v.vmx["ide1:0.fileName"]   = File.expand_path("../boot2docker-vagrant-_VERSION_.iso", __FILE__)
            v.vmx["ide1:0.deviceType"] = "cdrom-image"
        end
    end

    config.vm.provider :parallels do |p, override|
        override.vm.synced_folder ENV['HOME'], ENV['HOME'],
            type: "nfs",
            mount_options: ["nolock", "vers=3", "udp"]

        p.optimize_power_consumption = false
        p.check_guest_tools          = false
        p.update_guest_tools         = false
        p.functional_psf             = false
        p.customize "pre-boot", [
            "set", :id,
            "--device-set", "cdrom0",
            "--image",
                File.expand_path("../boot2docker-vagrant-_VERSION_.iso",
                    __FILE__),
            "--enable", "--connect"
        ]
        p.customize "pre-boot", [
            "set", :id,
            "--device-bootorder", "cdrom0 hdd0"
        ]
    end

    config.trigger.after [:destroy, :suspend, :halt] do
        run "rm -rf .docker .env"
    end

    config.trigger.after [:up, :resume] do
        info "Making the Docker TLS certs available to the host."
        run_remote <<-EOT.prepend("\n\n") + "\n"
            DOCKER_PID=/var/run/docker.pid
            if [ ! -f "$DOCKER_PID" ]; then
                echo "---> Waiting for for Docker daemon to spin up."
                while [ ! -f "$DOCKER_PID" ]; do
                    echo .
                    sleep 1
                done
            fi
            cp -r /home/docker/.docker #{Dir.pwd}
        EOT

        info "getting #{ENV['USER']} as owner of #{Dir.pwd}/.docker"
        system <<-EOT.prepend("\n\n") + "\n"
            sudo chown -R #{ENV['USER']} "#{Dir.pwd}/.docker"
            sudo chmod -R 755 "#{Dir.pwd}/.docker"
        EOT

        if ! EXTRA_ARGS.empty?
          info "restarting the docker daemon with #{EXTRA_ARGS}..."
          run_remote <<-EOT.prepend("\n\n") + "\n"
            sudo /etc/init.d/docker stop
            echo "#{EXTRA_ARGS}" > /var/lib/boot2docker/profile
            sudo /etc/init.d/docker start
          EOT
        end

        info "Building Docker communication environment variables."
        system <<-EOT.prepend("\n\n") + "\n"
            docker_host_ip="$(vagrant ssh-config | \
                sed -n 's/[ ]*HostName[ ]*//gp')"
            [[ -z "$docker_host_ip" ]] && exit 1

            echo > .env
            echo export DOCKER_TLS_VERIFY=1 >> .env
            echo export DOCKER_HOST="tcp://${docker_host_ip}:2376" >> .env
            echo export DOCKER_CERT_PATH="`pwd`/.docker" >> .env
        EOT

        info "Adjusting date and time after suspend and resume."
        run_remote <<-EOT.prepend("\n\n") + "\n"
            timeout -t 5 sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
            date
        EOT

        info "============================================================================="
        info ""
        info "  please don't forget to run 'source .env' after boot before calling docker  "
        info "                                                                             "
        info "  see the docs at http://github.com/AntonioMeireles/boot2docker-vagrant-box  "
        info ""
        info "============================================================================="
    end
    # data persistence
    config.vm.provision "trigger" do |trigger|
      trigger.fire do
        if File.exist?("#{Dir.pwd}/.boot2docker/persistent.data")
          info "============================================================================="
          info "  [INFO] restoring persistent data ..."
          info "   ... from #{Dir.pwd}/.boot2docker/persistent.data ..."
          run_remote <<-EOT.prepend("\n\n") + "\n"
            sudo /etc/init.d/docker stop
            [ -f  "#{Dir.pwd}/.boot2docker/persistent.data" ] && \
              sudo tar xjf "#{Dir.pwd}/.boot2docker/persistent.data" -C /
            sudo /etc/init.d/docker start
          EOT
          info  "============================================================================="
          config.vm.provision :reload
        end
      end
    end
    config.trigger.before :destroy do
      info "============================================================================="
      info "  [INFO] preserving persistent data..."
      run_remote <<-EOT.prepend("\n\n") + "\n"
        sudo /etc/init.d/docker stop &>/dev/null
        [ -d "#{Dir.pwd}/.boot2docker" ] || mkdir -p "#{Dir.pwd}/.boot2docker"
        sudo tar cjf "#{Dir.pwd}/.boot2docker/persistent.data" \
          /home/docker/ /var/lib/boot2docker/* /var/lib/docker/* &>/dev/null
      EOT
      info " persistent data saved in #{Dir.pwd}/.boot2docker/persistent.data"
      info "============================================================================="
    end
end
