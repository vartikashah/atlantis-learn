output "inventory" {
  value = concat(
      [ for key, item in openstack_compute_instance_v2.nginx:
      {
        "groups"           : "['created_instances']",
        "name"             : "${item.name}",
        "ip"               : "${item.access_ip_v4}",
        "ansible_ssh_user" : "${var.ssh_user}",
        "ssh_args"         : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o 'ProxyCommand ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ${var.ssh_user}@${openstack_compute_floatingip_v2.floatip[0].address}'"
      } ],
  )
}