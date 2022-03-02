packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
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

build {
  name = "packer-bastion-host"
  sources = [
    "source.amazon-ebs.ubuntu",
    #    "source.vagrant.ubuntu",
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
