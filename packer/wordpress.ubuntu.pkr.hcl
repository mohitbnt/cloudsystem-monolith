packer {
  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "application_artifact" {
  type        = string
  description = "Path to the WordPress application tar.gz artifact."
}

variable "app_version" {
  type        = string
  description = "WordPress application version used for AMI tagging."
}

locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
}

source "amazon-ebs" "golden-ami" {
  ami_name      = "cloudsystem-golden-ami-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
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

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  run_tags = {
    Name        = "cloudsystem-packer-builder"
    Project     = "cloudsystem"
    Application = "wordpress"
    ManagedBy   = "packer"
  }

  tags = {
    Name         = "cloudsystem-golden-ami-${local.timestamp}"
    Project      = "cloudsystem"
    Application  = "wordpress"
    Version      = var.app_version
    OS           = "ubuntu-24.04"
    Architecture = "x86_64"
    ManagedBy    = "packer"
  }
}

build {
  name    = "cloudsystem-golden-ami"
  sources = ["source.amazon-ebs.golden-ami"]

  provisioner "file" {
    source      = var.applictaion_artifact
    destination = "/tmp/wordpress-cloudsystem.tar.gz"
  }

  provisioner "file" {
    source      = "scripts/prepare-ami_name.sh"
    destination = "/tmp/prepare-ami.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/prepare-ami.sh",
      "sudo APPLICATION_ARTIFACT=/tmp/wordpress-cloudsystem.tar.gz /tmp/prepare-ami.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '--- Golden AMI validation ---'",
      "sudo nginx -t",
      "sudo php-fpm8.3 -t",
      "sudo systemctl is-active --quiet nginx",
      "sudo systemctl is-active --quiet php8.3-fpm",
      "sudo test -S /run/php/cloudsystem.sock",
      "sudo test -f /var/www/cloudsystem/wp-settings.php",
      "sudo test -f /var/www/cloudsystem/wp-content/plugins/redis-cache/redis-cache.php",
      "sudo test -d /var/www/cloudsystem/wp-content/plugins/amazon-s3-and-cloudfront",
      "sudo test ! -f /var/www/cloudsystem/wp-config.php",
      "test -z \"$(sudo find /var/www/cloudsystem/wp-content/uploads -mindepth 1 -print -quit)\"",
      "echo 'Golden AMI validation passed.'"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo rm -f /tmp/wordpress-cloudsystem.tar.gz /tmp/prepare-ami.sh"
    ]
  }
}