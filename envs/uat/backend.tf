# envs/uat/backend.tf
# Backend-only; values are injected via Azure DevOps Variable Groups at init time.

terraform {
  backend "azurerm" {}
}
