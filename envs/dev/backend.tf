# envs/dev/backend.tf
# Keep backend-only; values are injected via Azure DevOps variable group using -backend-config

terraform {
  backend "azurerm" {}
}
