provider "google"{
    credentials = "${file("../qhill-gcp-1316-5c31b84d6f70.json")}"
    project = "qhill-gcp-1316"
    region = "us-west1"
}
provider "aws"{
    region = "us-east-1"
}
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
    tenant_id = "${var.tenant_id}"
}
provider "oci"{
    tenancy_ocid = "${var.tenancy_ocid}"
    fingerprint = "${var.fingerprint}"
    private_key_path = "${var.private_key_path}"
   private_key_password = "${var.private_key_password}"
    region = "${var.region}"
    disable_auto_retries = "true"
}