# Terraform Openstack example to install nginx

This repository will use Terraform to create some instances (default 3) in Openstack, and then use Ansible to  install nginx and copy some files to it.

## Requirements

To run this code you need to first install some tools into your computer.

1. First, you need ansible to be installed. There are several methods to install Ansible, one of them being `pip`:

	```sh
	pip install ansible
	```

1. Terraform must also be installed by:

	<https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli>

1. Finally, you need to source the OpenRC file corresponding to the project the infrastructure will be deployed to. The file can be downloaded from the [API access](https://pouta.csc.fi/dashboard/project/api_access/) page of the Pouta interface. See [Pouta access through OpenStack APIs](https://docs.csc.fi/cloud/pouta/api-access/) for more reference.

## Explore the repository variables

In `terraform/variables.tfvars` you will see the following variables:

* `vm_image`, image to install in the servers.
* `vm_flavor`, size/flavor of the servers to be created.
* `cidr_ssh`, IP ranges that will be able to connect to port 22/SSH.
* `cidr_http`, IP ranges that will be able to connect to port 80/HTTP.
* `vm_prefix`, prefix for the name of the servers.
* `vm_count`,  number of servers to deploy.
* `ssh_user`, username that the image has configured.

These are the default values.

## Launch the playbook

To launch the playbook:

```sh
ansible-playbook site.yml
```

It will prompt for:

* The key pair name that you will use to SSH to your instance. The keypair name must be already in OpenStack: `openstack keypair list`.
* The network that you will use (Use this command to list the different networks: `openstack network list`)

Another option is to specify the values in the command line:

	```sh
	ansible-playbook \
		-e key_name=xxxxxx-key \
		-e network=project_200xxxx \
		site.yml
	```

After Ansible's run finished, you should have 3 servers running nginx listening in port 80/HTTP (`http://`) serving the same index file as the one in `files/html` of this repository

If you change the variables and rerun `ansible-playbook`, ansible will automatically apply the changes. For example, if your current ip (`curl ifconfig.me` will give you your IP) does not belong to the default range of IPs, you will need to change the range of IPs to include yours. As a side note, it is very recommended to always have a narrow range of IPs that are allowed to connect to the port 22/SSH, it adds a good extra layer of security.

## Destroy the cluster

To destroy the servers, one must simply run:

```sh
ansible-playbook \
	-e key_name=xxxxxx-key \
	-e network=project_200xxxx \
	-e state=absent
	main.yaml
```