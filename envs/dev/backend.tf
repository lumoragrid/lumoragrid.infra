# Example remote state backend (commented out by default)
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "STATE_RG"
#     storage_account_name = "statestorageacct"
#     container_name       = "tfstate"
#     key                  = "lumoragrid-dev.tfstate"
#   }
# }

terraform {
  backend "azurerm" {}
}

