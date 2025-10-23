---
applyTo: "**/*.tf"
description: Terraform 1.13 with Azure-focused infrastructure as code standards
---

# Terraform 1.13 Development Standards with Azure Focus

## Version Requirements
- **Required**: Terraform >= 1.13 (leverage optional attributes, enhanced for expressions)
- **Azure Providers**: AzureRM >= 4.0, AzAPI >= 2.0 for latest features
- Pin minor versions using `~>` for stability
- Document provider feature flags explicitly

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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

# Provider configuration with feature flags
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults  = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown               = true
      skip_shutdown_and_force_delete  = false
    }
    cognitive_account {
      purge_soft_delete_on_destroy = false
    }
  }
  
  # Use managed identity for authentication in production
  use_msi                    = var.use_managed_identity
  subscription_id            = var.subscription_id
  skip_provider_registration = false
}

provider "azapi" {
  # Inherits authentication from azurerm provider
  subscription_id = var.subscription_id
}
```

## Modern Terraform 1.13 Features

### Optional Object Attributes
```hcl
variable "network_config" {
  description = "Network configuration with optional attributes"
  type = object({
    vnet_name     = string
    address_space = list(string)
    dns_servers   = optional(list(string), [])
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
      service_endpoints = optional(list(string), [])
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = optional(list(string), [])
        })
      }))
    }))
    enable_ddos_protection = optional(bool, false)
    tags                   = optional(map(string), {})
  })
}
```

### Enhanced For Expressions
```hcl
locals {
  # Flatten subnets with NSG associations
  subnet_nsg_associations = flatten([
    for vnet_key, vnet in var.virtual_networks : [
      for subnet in vnet.subnets : {
        vnet_key    = vnet_key
        subnet_name = subnet.name
        nsg_id      = subnet.network_security_group_id
      } if subnet.network_security_group_id != null
    ]
  ])
  
  # Transform map with conditional logic
  processed_resources = {
    for k, v in var.resources : k => merge(
      v,
      {
        environment_tag = var.environment
        managed_by      = "terraform"
      }
    ) if v.enabled == true
  }
}
```

## Azure-Specific Best Practices

### Resource Naming Convention
```hcl
locals {
  # Consistent naming across all resources
  naming_convention = {
    resource_group  = "rg-${var.workload}-${var.environment}-${var.location_short}"
    storage_account = lower(replace("st${var.workload}${var.environment}${random_string.storage.result}", "-", ""))
    key_vault       = "kv-${var.workload}-${var.environment}-${random_string.kv.result}"
    vnet            = "vnet-${var.workload}-${var.environment}-${var.location_short}"
    subnet          = "snet-${var.workload}-${var.environment}"
    nsg             = "nsg-${var.workload}-${var.environment}"
    app_service     = "app-${var.workload}-${var.environment}-${var.location_short}"
    function_app    = "func-${var.workload}-${var.environment}-${var.location_short}"
  }
  
  # Common tags applied to all resources
  common_tags = {
    Environment     = var.environment
    Workload        = var.workload
    ManagedBy       = "Terraform"
    LastModified    = timestamp()
    CostCenter      = var.cost_center
    Owner           = var.owner_email
    DataClassification = var.data_classification
  }
}

resource "azurerm_resource_group" "main" {
  name     = local.naming_convention.resource_group
  location = var.location
  tags     = local.common_tags
}
```

### Using AzAPI for Preview Features
```hcl
# Use AzAPI for features not yet in AzureRM provider
resource "azapi_resource" "container_app_environment" {
  type      = "Microsoft.App/managedEnvironments@2024-03-01"
  name      = "cae-${var.workload}-${var.environment}"
  parent_id = azurerm_resource_group.main.id
  location  = azurerm_resource_group.main.location
  
  body = {
    properties = {
      appLogsConfiguration = {
        destination = "azure-monitor"
      }
      dapr = {
        enabled = true
      }
      peerAuthentication = {
        mtls = {
          enabled = true
        }
      }
      workloadProfiles = [
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
        }
      ]
    }
  }
  
  tags = local.common_tags
  
  response_export_values = ["properties.defaultDomain", "properties.staticIp"]
}

# Update existing resources with AzAPI
resource "azapi_update_resource" "app_service_site_config" {
  type        = "Microsoft.Web/sites/config@2023-12-01"
  resource_id = "${azurerm_app_service.main.id}/config/web"
  
  body = {
    properties = {
      # Features not available in azurerm provider
      functionsRuntimeScaleMonitoringEnabled = true
      minimumElasticInstanceCount            = 1
      functionAppScaleLimit                   = 10
    }
  }
}
```

### Azure Key Vault Integration
```hcl
# Centralized secrets management
resource "azurerm_key_vault" "main" {
  name                = local.naming_convention.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  purge_protection_enabled        = var.environment == "prod" ? true : false
  soft_delete_retention_days      = 90
  
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = [azurerm_subnet.main.id]
  }
  
  tags = local.common_tags
}

# Use data source to reference existing secrets
data "azurerm_key_vault_secret" "db_connection" {
  name         = "db-connection-string"
  key_vault_id = azurerm_key_vault.main.id
}

# Create secret with rotation
resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = random_password.api_key.result
  key_vault_id = azurerm_key_vault.main.id
  
  expiration_date = timeadd(timestamp(), "8760h") # 1 year
  
  tags = merge(local.common_tags, {
    rotation_enabled = "true"
    rotation_period  = "365d"
  })
}
```

### Private Endpoints Pattern
```hcl
# Reusable module for private endpoints
module "private_endpoint" {
  source = "./modules/private_endpoint"
  
  for_each = var.private_endpoint_configs
  
  name                = "pe-${each.key}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names
  
  private_dns_zone_ids = each.value.private_dns_zone_ids
  
  tags = local.common_tags
}

# Private DNS Zone configuration
resource "azurerm_private_dns_zone" "main" {
  for_each = toset(var.private_dns_zones)
  
  name                = each.value
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = azurerm_private_dns_zone.main
  
  name                  = "link-${azurerm_virtual_network.main.name}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  
  tags = local.common_tags
}
```

## Security & Compliance

### Managed Identity Pattern
```hcl
# System-assigned managed identity
resource "azurerm_user_assigned_identity" "main" {
  name                = "id-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# RBAC assignments with least privilege
resource "azurerm_role_assignment" "key_vault_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Custom role definition
resource "azurerm_role_definition" "custom" {
  name        = "custom-${var.workload}-operator"
  scope       = data.azurerm_subscription.current.id
  description = "Custom role for ${var.workload} operators"
  
  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/listKeys/action",
      "Microsoft.KeyVault/vaults/secrets/read",
    ]
    not_actions = [
      "Microsoft.KeyVault/vaults/secrets/delete",
    ]
  }
  
  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}
```

### Azure Policy Integration
```hcl
# Enforce governance with Azure Policy
resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-tags"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  
  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })
}

# Custom policy definition
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations-${var.workload}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed locations for ${var.workload}"
  
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = var.allowed_locations
        },
        {
          field = "type"
          notEquals = "Microsoft.AzureActiveDirectory/b2cDirectories"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}
```

## State Management - Azure Backend

```hcl
# backend.tf - Azure Storage backend configuration
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-prod"
    storage_account_name = "stterraformstate${var.unique_suffix}"
    container_name       = "tfstate"
    key                  = "${var.environment}/${var.workload}.tfstate"
    
    # Enable state locking
    use_azuread_auth = true
    use_msi          = true
    
    # Encryption
    encryption_key_id = data.azurerm_key_vault_key.state_encryption.id
  }
}

# State storage account with security best practices
resource "azurerm_storage_account" "terraform_state" {
  name                = local.naming_convention.storage_account
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location
  account_tier        = "Standard"
  account_replication_type = "GRS"
  
  # Security configurations
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  
  # Enable versioning for state history
  blob_properties {
    versioning_enabled = true
    change_feed_enabled = true
    
    delete_retention_policy {
      days = 30
    }
    
    container_delete_retention_policy {
      days = 30
    }
  }
  
  # Network restrictions
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = [azurerm_subnet.management.id]
  }
  
  # Encryption at rest
  encryption {
    key_vault_key_id = azurerm_key_vault_key.storage_encryption.id
    identity {
      type = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.storage.id]
    }
  }
  
  tags = local.common_tags
}
```

## Module Development

### Module Structure with Azure Focus
```hcl
# modules/azure_app_service/variables.tf
variable "app_service_config" {
  description = "App Service configuration"
  type = object({
    name     = string
    sku_size = optional(string, "B1")
    
    app_settings = optional(map(string), {})
    
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    
    site_config = optional(object({
      always_on                = optional(bool, true)
      ftps_state              = optional(string, "Disabled")
      http2_enabled           = optional(bool, true)
      minimum_tls_version     = optional(string, "1.2")
      vnet_route_all_enabled  = optional(bool, true)
      
      application_stack = optional(object({
        dotnet_version = optional(string)
        java_version   = optional(string)
        node_version   = optional(string)
        python_version = optional(string)
      }))
      
      ip_restriction = optional(list(object({
        name        = string
        priority    = number
        action      = string
        ip_address  = optional(string)
        service_tag = optional(string)
        virtual_network_subnet_id = optional(string)
      })), [])
    }))
    
    backup = optional(object({
      enabled            = bool
      storage_account_url = string
      schedule = object({
        frequency_interval = number
        frequency_unit     = string
        retention_days     = number
      })
    }))
    
    autoscale = optional(object({
      enabled     = bool
      min_capacity = number
      max_capacity = number
      rules = list(object({
        metric_trigger = object({
          metric_name      = string
          operator         = string
          threshold        = number
          time_aggregation = string
        })
        scale_action = object({
          direction = string
          type      = string
          value     = number
          cooldown  = string
        })
      }))
    }))
  })
}

# modules/azure_app_service/main.tf
resource "azurerm_service_plan" "main" {
  name                = "${var.app_service_config.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_config.sku_size
  
  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = var.app_service_config.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  
  https_only = true
  
  dynamic "identity" {
    for_each = var.app_service_config.identity != null ? [var.app_service_config.identity] : []
    
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  
  site_config {
    always_on               = try(var.app_service_config.site_config.always_on, true)
    ftps_state             = try(var.app_service_config.site_config.ftps_state, "Disabled")
    http2_enabled          = try(var.app_service_config.site_config.http2_enabled, true)
    minimum_tls_version    = try(var.app_service_config.site_config.minimum_tls_version, "1.2")
    vnet_route_all_enabled = try(var.app_service_config.site_config.vnet_route_all_enabled, true)
    
    dynamic "application_stack" {
      for_each = try(var.app_service_config.site_config.application_stack, null) != null ? [var.app_service_config.site_config.application_stack] : []
      
      content {
        dotnet_version = application_stack.value.dotnet_version
        java_version   = application_stack.value.java_version
        node_version   = application_stack.value.node_version
        python_version = application_stack.value.python_version
      }
    }
    
    dynamic "ip_restriction" {
      for_each = try(var.app_service_config.site_config.ip_restriction, [])
      
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }
  }
  
  app_settings = var.app_service_config.app_settings
  
  dynamic "backup" {
    for_each = try(var.app_service_config.backup.enabled, false) ? [var.app_service_config.backup] : []
    
    content {
      storage_account_url = backup.value.storage_account_url
      
      schedule {
        frequency_interval = backup.value.schedule.frequency_interval
        frequency_unit     = backup.value.schedule.frequency_unit
        retention_period_days = backup.value.schedule.retention_days
      }
    }
  }
  
  tags = var.tags
}

# Autoscaling configuration
resource "azurerm_monitor_autoscale_setting" "main" {
  count = try(var.app_service_config.autoscale.enabled, false) ? 1 : 0
  
  name                = "${var.app_service_config.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id
  
  profile {
    name = "default"
    
    capacity {
      default = var.app_service_config.autoscale.min_capacity
      minimum = var.app_service_config.autoscale.min_capacity
      maximum = var.app_service_config.autoscale.max_capacity
    }
    
    dynamic "rule" {
      for_each = var.app_service_config.autoscale.rules
      
      content {
        metric_trigger {
          metric_name        = rule.value.metric_trigger.metric_name
          metric_resource_id = azurerm_service_plan.main.id
          operator           = rule.value.metric_trigger.operator
          threshold          = rule.value.metric_trigger.threshold
          time_aggregation   = rule.value.metric_trigger.time_aggregation
          time_grain         = "PT1M"
          time_window        = "PT5M"
        }
        
        scale_action {
          direction = rule.value.scale_action.direction
          type      = rule.value.scale_action.type
          value     = rule.value.scale_action.value
          cooldown  = rule.value.scale_action.cooldown
        }
      }
    }
  }
  
  tags = var.tags
}
```

## Cost Optimization

```hcl
# Use Azure Spot instances for non-critical workloads
resource "azurerm_linux_virtual_machine_scale_set" "spot" {
  name                = "vmss-${var.workload}-spot"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_D2s_v3"
  instances           = 2
  
  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = 0.05  # Max price per hour
  
  # ... other configuration
}

# Auto-shutdown for development resources
resource "azurerm_dev_test_global_vm_shutdown_schedule" "dev_vms" {
  for_each = { for vm in azurerm_linux_virtual_machine.dev : vm.name => vm.id if var.environment == "dev" }
  
  virtual_machine_id = each.value
  location          = azurerm_resource_group.main.location
  enabled           = true
  
  daily_recurrence_time = "1900"
  timezone             = "Eastern Standard Time"
  
  notification_settings {
    enabled = false
  }
}

# Use Azure Reserved Instances tags
locals {
  cost_optimization_tags = {
    AutoShutdown      = var.environment == "dev" ? "true" : "false"
    ReservedInstance  = var.environment == "prod" ? "eligible" : "no"
    CostCenter        = var.cost_center
    Budget            = var.monthly_budget
  }
}
```

## Testing & Validation

### Terraform Testing
```hcl
# tests/azure_app_service.tftest.hcl (Terraform 1.6+ test framework)
run "valid_app_service" {
  command = plan
  
  variables {
    app_service_config = {
      name     = "app-test-001"
      sku_size = "B1"
      site_config = {
        always_on = true
      }
    }
  }
  
  assert {
    condition     = azurerm_linux_web_app.main.https_only == true
    error_message = "HTTPS must be enforced"
  }
  
  assert {
    condition     = azurerm_linux_web_app.main.site_config[0].minimum_tls_version == "1.2"
    error_message = "TLS 1.2 or higher must be enforced"
  }
}

# Validation rules
variable "location" {
  description = "Azure region for resources"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3",
      "centralus", "northeurope", "westeurope"
    ], var.location)
    error_message = "Location must be an approved Azure region."
  }
}
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.86.0
    hooks:
      - id: terraform_fmt
      - id: terraform_docs
      - id: terraform_validate
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      - id: terraform_tfsec
        args:
          - --args=--exclude-downloaded-modules
      - id: terraform_checkov
        args:
          - --args=--framework=terraform
          - --args=--skip-check=CKV_AZURE_35
```

## CI/CD Integration

### Azure DevOps Pipeline
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - terraform/**

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: terraform-vars
  - name: TF_VERSION
    value: '1.13.0'

stages:
  - stage: Validate
    jobs:
      - job: TerraformValidate
        steps:
          - task: TerraformInstaller@1
            inputs:
              terraformVersion: $(TF_VERSION)
          
          - script: |
              terraform fmt -check -recursive
              terraform init -backend=false
              terraform validate
            displayName: 'Terraform Validation'
          
          - script: |
              tflint --init
              tflint --recursive
            displayName: 'TFLint Analysis'
          
          - script: |
              tfsec . --format junit --out tfsec-report.xml
            displayName: 'Security Scan'
  
  - stage: Plan
    condition: and(succeeded(), ne(variables['Build.Reason'], 'PullRequest'))
    jobs:
      - job: TerraformPlan
        steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: 'Azure-Service-Connection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                terraform init
                terraform plan -out=tfplan
                terraform show -json tfplan > plan.json
            displayName: 'Terraform Plan'
          
          - script: |
              # Cost estimation
              infracost breakdown --path plan.json
            displayName: 'Cost Analysis'
```

## File Organization Best Practices

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   ├── storage/
│   └── security/
├── global/
│   ├── dns/
│   ├── monitoring/
│   └── governance/
├── scripts/
│   ├── setup-backend.sh
│   └── destroy-environment.sh
├── tests/
│   ├── unit/
│   └── integration/
├── .tflint.hcl
├── .pre-commit-config.yaml
└── README.md
```

## Documentation

### Auto-generated Documentation
```hcl
# Use terraform-docs to generate README
# Add this comment block to your modules

/**
 * # Azure App Service Module
 * 
 * This module creates an Azure App Service with best practices.
 * 
 * ## Features
 * - Managed identity integration
 * - Private endpoint support
 * - Automated backups
 * - Autoscaling configuration
 * 
 * ## Usage
 * 
 * ```hcl
 * module "app_service" {
 *   source = "./modules/azure_app_service"
 *   
 *   app_service_config = {
 *     name     = "app-example-prod"
 *     sku_size = "P1v3"
 *   }
 * }
 * ```
 */
```

## Common Patterns & Anti-Patterns

### ✅ Do This
```hcl
# Use data sources for existing resources
data "azurerm_key_vault" "existing" {
  name                = "kv-shared-prod"
  resource_group_name = "rg-shared-prod"
}

# Use for_each for multiple similar resources
resource "azurerm_storage_account" "regional" {
  for_each = var.regions
  
  name                = "st${var.workload}${each.key}"
  location            = each.value
  resource_group_name = azurerm_resource_group.main[each.key].name
  # ...
}

# Use dynamic blocks to avoid repetition
dynamic "ip_restriction" {
  for_each = var.ip_restrictions
  content {
    # ...
  }
}
```

### ❌ Don't Do This
```hcl
# Don't hardcode resource names
resource "azurerm_resource_group" "main" {
  name = "my-resource-group"  # Bad: hardcoded
}

# Don't use count when for_each is more appropriate
resource "azurerm_storage_account" "main" {
  count = length(var.storage_accounts)  # Bad: use for_each
  name  = var.storage_accounts[count.index]
}

# Don't ignore dependency management
resource "azurerm_virtual_network" "main" {
  # Missing depends_on when needed
}
```

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure API Provider Documentation](https://registry.terraform.io/providers/Azure/azapi/latest)
- [Azure Terraform Modules Registry](https://registry.terraform.io/browse/modules?provider=azurerm)
- [Microsoft Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
