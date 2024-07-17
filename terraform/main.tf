data "openstack_images_image_v2" "vm_image" {
  name        = "${var.vm_image}" # Name of image to be used
  most_recent = true
}

data "openstack_compute_flavor_v2" "vm_flavor" {
  name = "${var.vm_flavor}" # flavor to be used
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name = "SSH-CSC-${var.vm_prefix}"
  description = "SSH connection from CSC to ${var.vm_prefix}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_22" {
  for_each          = toset(split(",", var.cidr_ssh))
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  security_group_id = "${openstack_networking_secgroup_v2.ssh.id}"
}

resource "openstack_networking_secgroup_v2" "http" {
  name = "HTTP-external-${var.vm_prefix}"
  description = "External traffic to HTTP for ${var.vm_prefix}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_80" {
  for_each          = toset(split(",",var.cidr_http))
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = each.value
  security_group_id = "${openstack_networking_secgroup_v2.http.id}"
}

# Create "instance_count" instances
resource "openstack_compute_instance_v2" "nginx" {
  name            = "${var.vm_prefix}-${count.index}"
  count           = "${var.vm_count}"
  image_id        = data.openstack_images_image_v2.vm_image.id
  #image_id        = "${var.image_backend_id}"
  flavor_id       = data.openstack_compute_flavor_v2.vm_flavor.id
  key_pair        = var.keypair
  security_groups = ["default",
                     "${openstack_networking_secgroup_v2.ssh.name}",
                     "${openstack_networking_secgroup_v2.http.name}"]

  network {
    name = var.network
  }
}

# floating IP here
resource "openstack_compute_floatingip_v2" "floatip" {
  pool = "public"
  count           = "${var.vm_count}"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  for_each = {
    for index, ip in openstack_compute_floatingip_v2.floatip:
    index => ip
  }
  floating_ip = "${each.value.address}"
  instance_id = "${openstack_compute_instance_v2.nginx[each.key].id}"
}