env       = "test"
location  = "australiaeast"
prefix    = "lg"
tenant_id = "75569a98-0ea1-45b2-8b41-49b53465e6af" # <-- update with your AAD tenant ID

# Feature flags
enable_private_endpoints = false
enable_diagnostics       = true

# Service Bus
sb_tier      = "Standard"
sb_capacity  = 0
ip_allowlist = [] # e.g., ["203.0.113.10", "198.51.100.0/24"]

# Cosmos
cosmos_serverless       = true
cosmos_enable_free_tier = true

# SQL admin (set via pipeline/secret in real usage)
sql_admin_login = "sqladminuser"
