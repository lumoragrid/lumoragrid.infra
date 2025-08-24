env      = "prod"
location = "australiaeast"
prefix   = "lg"
tenant_id = "00000000-0000-0000-0000-000000000000"  # <-- update with your AAD tenant ID

# Feature flags
enable_private_endpoints = false
enable_diagnostics       = true

# Service Bus
sb_tier     = "Standard"
sb_capacity = 0
ip_allowlist = []  # e.g., ["203.0.113.10", "198.51.100.0/24"]

# Cosmos
cosmos_serverless       = false
cosmos_enable_free_tier = true

# SQL admin (set via pipeline/secret in real usage)
sql_admin_login    = "sqladminuser"
sql_admin_password = "CHANGE_ME_STRONG_PASSWORD"
