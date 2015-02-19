# -*- mode: ruby -*-
# # vi: set ft=ruby :


Vagrant.require_version ">= 1.6.3"

Vagrant.configure("2") do |config|
    config.ssh.shell = "sh"
    config.ssh.username = "docker"
    config.ssh.password = "tcuser"
    config.ssh.insert_key = true

    # Forward the Docker port
    #config.vm.network :forwarded_port, guest: 2376, host: 2376

    # Synced folder by default
    config.vm.synced_folder ".", Dir.pwd, type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

    # Attach the b2d ISO so that it can boot
    config.vm.provider :parallels do |p|
        p.optimize_power_consumption = false
        p.check_guest_tools          = false
        p.update_guest_tools         = false
        p.functional_psf             = false
        p.customize "pre-boot", [
            "set", :id,
            "--device-set", "cdrom0",
            "--image", File.expand_path("../boot2docker.iso", __FILE__),
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
    end

    config.trigger.after [:up, :resume] do
        info "Building Docker communication environment variables."
        system <<-EOT.prepend("\n\n") + "\n"
            docker_host_ip="$(vagrant ssh-config | sed -n 's/[ ]*HostName[ ]*//gp')"
            [[ -z "$docker_host_ip" ]] && exit 1

            echo > .env
            echo export DOCKER_TLS_VERIFY=1 >> .env
            echo export DOCKER_HOST="tcp://${docker_host_ip}:2376" >> .env
            echo export DOCKER_CERT_PATH="`pwd`/.docker" >> .env
        EOT
    end

    config.trigger.after [:up, :resume] do
        info "Adjusting datetime after suspend and resume."
        run_remote <<-EOT.prepend("\n\n") + "\n"
            timeout -t 5 sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
            date
        EOT
    end
end

