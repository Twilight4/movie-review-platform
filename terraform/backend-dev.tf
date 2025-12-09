terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatestorage3214"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
