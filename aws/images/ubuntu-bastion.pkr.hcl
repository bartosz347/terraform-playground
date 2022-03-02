packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }

    proxmox = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-20-04-bastion-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-central-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

  tags = {
    IMAGE_TYPE = "bastion"
  }
}

source "vagrant" "ubuntu" {
  communicator = "ssh"
  source_path  = "generic/ubuntu2004"
  provider     = "Hyper-V"
  add_force    = true
}

source "proxmox" "ubuntu" {
  proxmox_url              = "https://192.168.1.80:8006/api2/json"
  insecure_skip_tls_verify = true
  username                 = "root@pam!packer"
  token                    = "8995435f-1404-4c2f-a465-72716ded2668"

  iso_file     = "local:iso/alpine-standard-3.15.0-x86_64.iso"
  ssh_username = "root"

  os = "l26"


  node = "proxmox"

  # TODO
#  http_bind_address = "0.0.0.0"

  http_directory = "./config"
  boot_command   = [
    "<wait>",
    "root<enter>",
    "<wait>",
    "setup-alpine -f http://{{ .HTTPIP }}:{{ .HTTPPort }}/alpine-answerfile.cfg<enter>"
  ]


  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
  }
  #  "disks" : [
  #    {
  #      "type" : "scsi",
  #      "disk_size" : "5G",
  #      "storage_pool" : "local-lvm",
  #      "storage_pool_type" : "lvm"
  #    }
  #  ],
  #
  #  "http_directory" : "config",
  #  "boot_wait" : "10s",
  #  "boot_command" : [
  #    "<up><tab> ip=dhcp inst.cmdline inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/ks.cfg<enter>"
  #  ],
  #
  #  "ssh_username" : "root",
  #  "ssh_timeout" : "15m",
  #  "ssh_password" : "packer",
  #
  #  "unmount_iso" : true,
  #  "template_name" : "fedora-29",
  #  "template_description" : "Fedora 29-1.2, generated on {{ isotime \"2006-01-02T15:04:05Z\" }}"
}

build {
  name    = "packer-bastion-host"
  sources = [
        "source.amazon-ebs.ubuntu",
    #    "source.vagrant.ubuntu",
#    "source.proxmox.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo 'This image was built with Packer, version ${local.timestamp}' | sudo tee /etc/motd",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get -y install postgresql-client"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ssh-setup.yml"
  }
}
