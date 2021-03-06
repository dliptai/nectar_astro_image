# Set some variables
terraform {
  #  backend "remote" {
  #    organization = "adacs"

  #    workspaces {
  #      name = "nectar-images"
  #    }
  #  }

  required_providers {
    openstack = {
      source = "terraform-providers/openstack"
    }
  }
  required_version = ">= 0.13"
}

variable "test_image_name" {
  default = ""
}
variable "test_name" {
  default = ""
}

# Configure the OpenStack Provider
provider "openstack" {}

# Create temporary ssh key pair
resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "adacs-image-testing-key"
}

# Launch VM with image to test
resource "openstack_compute_instance_v2" "test-server" {
  name            = var.test_name
  image_name      = var.test_image_name
  flavor_name     = "m3.xsmall"
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default", "SSH"]

  # Wait for ssh connection
  provisioner "remote-exec" {
    inline = ["echo '===> ssh is now available <==='"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = openstack_compute_keypair_v2.test-keypair.private_key
      host        = openstack_compute_instance_v2.test-server.access_ip_v4
    }
  }
}

# Output varialbes
output "private_key" {
  sensitive = true
  value     = openstack_compute_keypair_v2.test-keypair.private_key
}

output "IP" {
  value = openstack_compute_instance_v2.test-server.access_ip_v4
}
