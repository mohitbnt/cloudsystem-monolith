packer {
  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "medusa-ubuntu" {
  ami_name      = "medusa-golden-image-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  ssh_username  = "ubuntu"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

  build {
    sources = ["source.amazon-ebs.medusa-ubuntu"]

    provisioner "shell" {
      script = [
        "scripts/setup-deps.sh"
      ]    
    }
  }