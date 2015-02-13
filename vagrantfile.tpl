# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.require_version ">= 1.6.3"

Vagrant.configure("2") do |config|
  config.ssh.shell = "sh"
  config.ssh.username = "docker"
  config.ssh.password = "tcuser"
  config.ssh.insert_key = true

  # Forward the Docker port
  config.vm.network :forwarded_port, guest: 2376, host: 2376

  # Disable synced folder by default
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Attach the b2d ISO so that it can boot
  config.vm.provider :parallels do |p|
    p.check_guest_tools = false
    p.functional_psf = false
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

end
