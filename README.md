# Terraform remote state

A project to demonstrate how to use terraform with remote state.

When terraform applies a configuration it stores the resulting infrastructure state. The state can be stored in a local file (default) or remotely.

When several people are working on the same terraform managed infrastructure it is a good idea to store the state remotely. This way it is simpler to access the sate from different workstations and for people not to get in each other's way.

In terraform, how the state is stored/loaded is set by configuring a "backend". By default terraform uses the "local" backend to store the state in a file locally on the machine it is run on. To store the state remotely one of the supported remote backends needs to be configured. Detailed information about terraform backends can be found [here](https://www.terraform.io/docs/backends/index.html).

In Terraform, backends are set in the configuration, in the "terraform" section. For example:

```HCL
terraform {
    backend "backend_name" {
        // specific backend settings
    }
}
```

In this project we use the remote terraform backend "Terraform Enterprise" ( formerly known as "atlas" ) to demonstrate how remote backends work.

## Prerequisites

* Install Terraform - [instructions](https://www.terraform.io/intro/getting-started/install.html#installing-terraform)

Preparing the Terraform Enterprise remote backend:

* Register in Terraform Enterprise from [here](https://app.terraform.io/account/new).
* Create an organization - [instructions](https://www.terraform.io/docs/enterprise/users-teams-organizations/organizations.html#creating-organizations).
* Crete a workspace within the organization - [instructions](https://www.terraform.io/docs/enterprise/workspaces/creating.html#configuring-a-new-workspace) - selecting the "None" source.
* Set up authentication token for Terraform Enterprise according to this [document](https://www.terraform.io/docs/enterprise/users-teams-organizations/users.html#api-tokens).
* Set the token in an environment variable - `export ATLAS_TOKEN=<your_tfe_token>`. This way terraform will use the token to authenticate with the TFE backend.

## Configure Terraform to use the Atlas backend

In `main.tf` file set the address of your workspace in the atlas backend. The address is formed like this - `<tfe_organization_name>\<workspace_name>`

So the configuration block inside `main.tf` should look like:

```HCL
terraform {
  backend "atlas" {
    name = "<tfe_organization_name>\<workspace_name>"
  }
}
```

## Running Terraform

* Initialize terraform - run `terraform init`
* Apply the configuration - run `terraform apply`

Notice that after applying the configuration no `terraform.tfstate` file was created. This is because the state is stored in TFE and not on the local machine running terraform.

You can change the backends for terraform configurations without loosing the existing state. When you change the backend of a configuration that has already been applied terraform will detect it and offer to transfer the existing state to the new backend.

To demonstrate this:

* After applying the configuration using the "atlas" backend, remove the `backend` section from `main.tf`
* Run `terraform init`

Terraform will display a message informing you that it has detected a change in the backend configuration. It will ask you if you want to copy the current state to the new backend.

* confirm with `yes`

After terraform finishes, notice that a local state file `terraform.tfstate` has been created.

If you run `terraform plan` - terraform will generate a plan that will say that no changes are needed as all the resources in the configuration already exist.