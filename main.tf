terraform {
  backend "atlas" {
    name = "slavrdorg/terraform-remote-state"
  }
}

resource "null_resource" "helloWorld" {
  provisioner "local-exec" {
    command = "echo hello world"
  }
}
