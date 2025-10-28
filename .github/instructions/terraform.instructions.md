---
applyTo: "**/*.tf"
description: Terraform 1.13 with Azure-focused infrastructure as code standards
---

# Terraform 1.13 Development Standards with Azure Focus

## Version Requirements
- **Required**: Terraform >= 1.13 (optional attributes, enhanced for expressions)
- **Azure Providers**: AzureRM >= 4.0, AzAPI >= 2.0
- Pin minor versions using `~>` for stability

```hcl
terraform {
  required_version = ">= 1.13"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  use_msi = var.use_managed_identity
}
```

## Modern Terraform 1.13 Features

### Optional Object Attributes
```hcl
variable "network_config" {
  type = object({
    vnet_name     = string
    address_space = list(string)
    dns_servers   = optional(list(string), [])
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
      service_endpoints = optional(list(string), [])
    }))
    enable_ddos_protection = optional(bool, false)
  })
}
```

### Enhanced For Expressions
```hcl
locals {
  # Flatten nested structures
  subnet_nsg_associations = flatten([
    for vnet_key, vnet in var.virtual_networks : [
      for subnet in vnet.subnets : {
        vnet_key    = vnet_key
        subnet_name = subnet.name
        nsg_id      = subnet.network_security_group_id
      } if subnet.network_security_group_id != null
    ]
  ])
}
```

## Azure Best Practices

### Naming Conventions and Locals File

**ALWAYS create a dedicated `locals.tf` file** for naming conventions and common values. This ensures consistency across all resources and makes updates easier.

#### Random String Suffix for Uniqueness
For globally unique resources (Storage Accounts, Key Vaults, Container Registries, etc.), **always append a random string suffix** to ensure uniqueness:

```hcl
# locals.tf - ALWAYS create this file for naming conventions
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  # Common variables
  resource_suffix = random_string.suffix.result
  
  # Naming conventions with random suffix where needed
  naming_convention = {
    # Resource group 
    resource_group = "rg-${var.workload}-${var.environment}-${var.location_short}-${local.resource_suffix}"
    
    # Globally unique resources - ALWAYS use random suffix
    storage_account = lower(replace("st${var.workload}${var.environment}${local.resource_suffix}", "-", ""))
    key_vault       = "kv-${var.workload}-${var.environment}-${local.resource_suffix}"
    container_registry = lower(replace("cr${var.workload}${var.environment}${local.resource_suffix}", "-", ""))
    cosmos_db       = "cosmos-${var.workload}-${var.environment}-${local.resource_suffix}"
    
    # Regional resources - suffix optional but recommended
    vnet            = "vnet-${var.workload}-${var.environment}-${var.location_short}"
    subnet          = "snet-${var.workload}-${var.environment}"
    nsg             = "nsg-${var.workload}-${var.environment}"
    app_service     = "app-${var.workload}-${var.environment}-${local.resource_suffix}"
    function_app    = "func-${var.workload}-${var.environment}-${local.resource_suffix}"
  }
  
  # Common tags - centralize all tagging
  common_tags = {
    Environment = var.environment
    Workload    = var.workload
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}
```

#### When to Use Random Suffix
- **REQUIRED** for globally unique Azure resources:
  - Storage Accounts (`st*`)
  - Key Vaults (`kv-*`)
  - Container Registries (`cr*`)
  - Cosmos DB (`cosmos-*`)
  - App Configuration (`appconfig-*`)
  
- **RECOMMENDED** for resources that may need uniqueness:
  - App Services / Function Apps
  - Container Apps
  - API Management instances
  
- **OPTIONAL** for regional/scoped resources:
  - Resource Groups
  - Virtual Networks
  - Network Security Groups

#### Using Naming Conventions in Resources
```hcl
# main.tf - Reference naming from locals
resource "azurerm_resource_group" "main" {
  name     = local.naming_convention.resource_group
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "main" {
  name                     = local.naming_convention.storage_account
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

resource "azurerm_key_vault" "main" {
  name                = local.naming_convention.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}
```

### Using AzAPI for Preview Features
```hcl
# Use AzAPI for features not yet in AzureRM
resource "azapi_resource" "container_app" {
  type      = "Microsoft.App/managedEnvironments@2024-03-01"
  name      = "cae-${var.workload}-${var.environment}"
  parent_id = azurerm_resource_group.main.id
  location  = azurerm_resource_group.main.location
  
  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "azure-monitor"
      }
    }
  })
  tags = local.common_tags
}
```

### Key Vault Integration
```hcl
resource "azurerm_key_vault" "main" {
  name                = local.naming_convention.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  enable_rbac_authorization  = true
  purge_protection_enabled   = var.environment == "prod"
  soft_delete_retention_days = 90
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  tags = local.common_tags
}

# Reference secrets
data "azurerm_key_vault_secret" "db_connection" {
  name         = "db-connection-string"
  key_vault_id = azurerm_key_vault.main.id
}
```

### Private Endpoints
```hcl
module "private_endpoint" {
  source   = "./modules/private_endpoint"
  for_each = var.private_endpoint_configs
  
  name                = "pe-${each.key}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private.id
  
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names
}

resource "azurerm_private_dns_zone" "main" {
  for_each            = toset(var.private_dns_zones)
  name                = each.value
  resource_group_name = azurerm_resource_group.main.name
}
```

## Security & Compliance

### Managed Identity
```hcl
resource "azurerm_user_assigned_identity" "main" {
  name                = "id-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# RBAC with least privilege
resource "azurerm_role_assignment" "kv_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}
```

### Azure Policy
```hcl
resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-tags"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  
  parameters = jsonencode({
    tagName = { value = "Environment" }
  })
}
```

## State Management - Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-prod"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "${var.environment}/${var.workload}.tfstate"
    use_azuread_auth     = true
    use_msi              = true
  }
}

# State storage with security
resource "azurerm_storage_account" "tfstate" {
  name                     = "stterraformstate"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }
}
```

## Module Development

```hcl
# modules/app_service/variables.tf
variable "app_config" {
  type = object({
    name     = string
    sku_size = optional(string, "B1")
    
    site_config = optional(object({
      always_on           = optional(bool, true)
      minimum_tls_version = optional(string, "1.2")
    }))
  })
}

# modules/app_service/main.tf
resource "azurerm_service_plan" "main" {
  name                = "${var.app_config.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_config.sku_size
}

resource "azurerm_linux_web_app" "main" {
  name                = var.app_config.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  
  site_config {
    always_on           = try(var.app_config.site_config.always_on, true)
    minimum_tls_version = try(var.app_config.site_config.minimum_tls_version, "1.2")
  }
}
```

## Testing & Validation

```hcl
# tests/app_service.tftest.hcl
run "valid_config" {
  command = plan
  
  variables {
    app_config = {
      name = "app-test-001"
      site_config = { always_on = true }
    }
  }
  
  assert {
    condition     = azurerm_linux_web_app.main.https_only == true
    error_message = "HTTPS must be enforced"
  }
}

# Validation rules
variable "location" {
  type = string
  
  validation {
    condition = contains([
      "eastus", "westus", "westeurope"
    ], var.location)
    error_message = "Invalid Azure region"
  }
}
```

## Best Practices

### File Organization
- **ALWAYS create `locals.tf`** for naming conventions, random suffixes, and common tags
- Keep `variables.tf` for input variables
- Keep `outputs.tf` for output values
- Use `main.tf` for primary resources
- Separate complex modules into their own directories

### Naming and Tagging
```hcl
# locals.tf - Central location for ALL naming and tagging
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  resource_suffix = random_string.suffix.result
  
  naming_convention = {
    # Use suffix for globally unique resources
    storage_account = "st${var.workload}${var.environment}${local.resource_suffix}"
    key_vault       = "kv-${var.workload}-${var.environment}-${local.resource_suffix}"
  }
  
  common_tags = merge(var.additional_tags, {
    Environment = var.environment
    Workload    = var.workload
    ManagedBy   = "Terraform"
  })
}
```

### Resource Creation
```hcl
# Use variables and locals
resource "azurerm_resource_group" "main" {
  name = local.naming_convention.resource_group
  tags = local.common_tags
}

# for_each for multiple resources
resource "azurerm_storage_account" "main" {
  for_each = var.accounts
  name     = "st${each.key}${local.resource_suffix}"
  tags     = local.common_tags
}

# Dynamic blocks for repetition
dynamic "ip_restriction" {
  for_each = var.restrictions
  content {
    name = ip_restriction.value.name
  }
}
```
