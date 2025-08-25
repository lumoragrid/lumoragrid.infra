env       = "uat"
location  = "australiasoutheast"
prefix    = "lumoragrid"
tenant_id = "75569a98-0ea1-45b2-8b41-49b53465e6af" # <-- update with your AAD tenant ID

# Feature flags
enable_private_endpoints = false
enable_diagnostics       = true

# Service Bus
sb_tier      = "Standard"
sb_capacity  = 0
ip_allowlist = [] # e.g., ["203.0.113.10", "198.51.100.0/24"]

# Cosmos
cosmos_serverless       = false
cosmos_enable_free_tier = false

# SQL admin (set via pipeline/secret in real usage)
sql_admin_login = "sqladminuser"

law_sku        = "PerGB2018"  # or "Free"
retention_days = 30           # ignored if law_sku == "Free"
