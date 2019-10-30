resource "google_compute_network" "our_development_network"{
    name = "devnetwork"
    auto_create_subnetworks = true
}

resource "aws_vpc" "environment-example-two" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true 
    enable_dns_support = true
    tags = {
        Name = "terraform-aws-vpc-example-two"
    }
}

resource "aws_subnet" "subnet1" {
    cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block, 3,1)}"
    vpc_id = "${aws_vpc.environment-example-two.id}"
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
    cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block, 2,2)}"
    vpc_id = "${aws_vpc.environment-example-two.id}"
    availability_zone = "us-east-1b"
}

resource "aws_security_group" "subnetsecuritygroup"{
    vpc_id = "${aws_vpc.environment-example-two.id}"
    ingress{
        cidr_blocks = [
            "${aws_vpc.environment-example-two.cidr_block}"
        ]
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
}

resource "oci_core_virtual_network" "ExampleVCN" {
  cidr_block = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name = "TFExampleVCN"
  dns_label = "tfexamplevcn"
}
resource "oci_core_subnet" "ExampleSubnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block = "10.1.20.0/24"
  display_name = "TFExampleSubnet"
  dns_label = "tfexamplesubnet"
  security_list_ids = ["${oci_core_virtual_network.ExampleVCN.default_security_list_id}"]
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.ExampleVCN.id}"
  route_table_id = "${oci_core_route_table.ExampleRT.id}"
  dhcp_options_id = "${oci_core_virtual_network.ExampleVCN.default_dhcp_options_id}"
}

resource "oci_core_internet_gateway" "ExampleIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "TFExampleIG"
  vcn_id = "${oci_core_virtual_network.ExampleVCN.id}"
}

resource "oci_core_route_table" "ExampleRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.ExampleVCN.id}"
  display_name = "TFExampleRouteTable"
  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.ExampleIG.id}"
  }
}

resource "azurerm_resource_group" "azy_network"{
    location = "West US"
    name = "devresgrp"
}

resource "azurerm_virtual_network" "blue_virtual_network" {
    address_space = ["10.0.0.0/16"]
    location = "West US"
    name = "bluevirtnetwork"
    resource_group_name = "${azurerm_resource_group.azy_network.name}"
    dns_servers = ["10.0.0.4","10.0.0.5"]
    subnet{
        name = "subnet1"
        address_prefix = "10.0.1.0/24"
    }
    subnet{
        name = "subnet2"
        address_prefix = "10.0.2.0/24"
    }
    tags = {
        environment = "blue-world-finder"
    }
}