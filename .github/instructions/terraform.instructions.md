---
applyTo: "**/*.tf"
description: Terraform 1.13 with Azure-focused infrastructure as code standards
---

# Terraform 1.13 Development Standards with Azure Focus

## Version Requirements
- **Required** always use: Terraform ">= 1.13"
- **Azure Providers** always use:  AzureRM "~> 4.0", AzAPI "~> 2.0"

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

## State Management & Backend Configuration

### Azure Storage Backend (Recommended)
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate${var.suffix}"
    container_name       = "tfstate"
    key                  = "${var.workload}/${var.environment}/terraform.tfstate"
    use_azuread_auth     = true  # Prefer Azure AD auth over access keys
  }
}
```

### State Locking
- Always use state locking with Azure Blob Storage
- Configure lease duration appropriately for long-running operations
- Implement break-glass procedures for stuck locks

## Azure Security Best Practices

### Managed Identity Usage
```hcl
# Always prefer Managed Identity over Service Principal
provider "azurerm" {
  features {}
  use_msi                    = true
  skip_provider_registration = false
  
  # Use specific subscription if needed
  subscription_id = var.subscription_id
}
```

### Key Vault Integration
```hcl
# Retrieve secrets from Key Vault
data "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  key_vault_id = azurerm_key_vault.main.id
}

# Use purge protection for production
resource "azurerm_key_vault" "main" {
  name                        = local.naming_convention.key_vault
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = var.environment == "prod"
  soft_delete_retention_days  = 90
  enable_rbac_authorization   = true  # Prefer RBAC over access policies
  
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
  
  tags = local.common_tags
}
```

### Private Endpoints Pattern
```hcl
# Standard pattern for private endpoints
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-${azurerm_storage_account.main.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdz-group-storage"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }
  
  tags = local.common_tags
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

### Import Blocks (1.5+)
```hcl
# Import existing resources with import blocks
import {
  to = azurerm_resource_group.existing
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-existing"
}

# Use moved blocks for refactoring
moved {
  from = azurerm_storage_account.old
  to   = azurerm_storage_account.new
}
```

### Validation Rules
```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, test, staging, or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region"
  
  validation {
    condition     = can(regex("^(northeurope|westeurope|eastus|westus)$", var.location))
    error_message = "Location must be an approved Azure region."
  }
}
```

### Preconditions and Postconditions
```hcl
resource "azurerm_storage_account" "main" {
  # ...configuration...
  
  lifecycle {
    precondition {
      condition     = var.replication_type == "GRS" || var.environment != "prod"
      error_message = "Production storage accounts must use GRS replication."
    }
    
    postcondition {
      condition     = self.primary_blob_endpoint != ""
      error_message = "Storage account must have a blob endpoint."
    }
  }
}
```

## Azure Resource Patterns

### Hub-Spoke Network Topology
```hcl
module "hub_network" {
  source = "./modules/hub-network"
  
  name                = "hub-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
  
  firewall_subnet_prefix = "10.0.1.0/24"
  gateway_subnet_prefix  = "10.0.2.0/24"
  bastion_subnet_prefix  = "10.0.3.0/24"
  
  tags = local.common_tags
}

module "spoke_networks" {
  source   = "./modules/spoke-network"
  for_each = var.spoke_configs
  
  name                = "spoke-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = each.value.address_space
  hub_network_id      = module.hub_network.vnet_id
  
  tags = local.common_tags
}
```

### Application Gateway with WAF
```hcl
resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.autoscale_enabled ? null : 2
  }
  
  dynamic "autoscale_configuration" {
    for_each = var.autoscale_enabled ? [1] : []
    content {
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
    }
  }
  
  waf_configuration {
    enabled                  = true
    firewall_mode            = var.environment == "prod" ? "Prevention" : "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
    file_upload_limit_mb     = 100
    request_body_check       = true
    max_request_body_size_kb = 128
  }
  
  # ...gateway configuration...
  
  tags = local.common_tags
}
```

## Module Development Best Practices

### Module Structure
```
modules/
├── azure-webapp/
│   ├── main.tf           # Core resources
│   ├── variables.tf      # Input variables with validation
│   ├── outputs.tf        # Output values
│   ├── locals.tf         # Local values and calculations
│   ├── versions.tf       # Provider requirements
│   ├── README.md         # Module documentation
│   └── examples/         # Usage examples
│       └── basic/
│           └── main.tf
```

### Module Interface Design
```hcl
# variables.tf - Well-defined module interface
variable "settings" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    
    sku = object({
      tier = string
      size = string
    })
    
    app_settings = optional(map(string), {})
    
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    
    networking = optional(object({
      vnet_integration_subnet_id = optional(string)
      ip_restrictions            = optional(list(object({
        name                      = string
        ip_address                = optional(string)
        virtual_network_subnet_id = optional(string)
        service_tag               = optional(string)
        priority                  = number
        action                    = optional(string, "Allow")
      })), [])
    }))
  })
  
  description = "Web App configuration settings"
}
```

## Testing and Validation

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
        args:
          - '--args=--config=__GIT_WORKING_DIR__/.tflint.hcl'
      - id: terraform_tfsec
        args:
          - '--args=--config-file=__GIT_WORKING_DIR__/.tfsec/config.yml'
```

### TFLint Configuration
```hcl
# .tflint.hcl
plugin "azurerm" {
  enabled = true
  version = "0.25.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "azurerm_resource_missing_tags" {
  enabled = true
  tags    = ["Environment", "ManagedBy", "Workload"]
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}
```

### Terratest Example
```go
// test/webapp_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestWebAppModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
        Vars: map[string]interface{}{
            "environment": "test",
            "location":    "northeurope",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs
    webAppName := terraform.Output(t, terraformOptions, "web_app_name")
    assert.Contains(t, webAppName, "test")
}
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  pull_request:
    paths:
      - '**.tf'
      - '**.tfvars'
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.13.0
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: TFLint
        uses: terraform-linters/setup-tflint@v3
        with:
          tflint_version: latest
      
      - run: tflint --init
      - run: tflint --recursive
      
      - name: Checkov Security Scan
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: reports/checkov.sarif
      
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: reports/checkov.sarif
```

### Azure DevOps Pipeline
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - '**.tf'

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: Validate
    jobs:
      - job: TerraformValidation
        steps:
          - task: TerraformInstaller@0
            inputs:
              terraformVersion: '1.13.0'
          
          - task: TerraformTaskV3@3
            displayName: 'Terraform Init'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'Azure-Service-Connection'
          
          - task: TerraformTaskV3@3
            displayName: 'Terraform Validate'
            inputs:
              provider: 'azurerm'
              command: 'validate'
          
          - script: |
              terraform fmt -check -recursive
            displayName: 'Terraform Format Check'
```

## Resource Tagging Strategy

### Comprehensive Tagging
```hcl
locals {
  mandatory_tags = {
    Environment         = var.environment
    Workload           = var.workload
    Owner              = var.owner_email
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    BusinessUnit       = var.business_unit
    ManagedBy          = "Terraform"
    Repository         = "https://github.com/${var.github_org}/${var.github_repo}"
    CreatedDate        = timestamp()
    TerraformWorkspace = terraform.workspace
  }
  
  compliance_tags = var.environment == "prod" ? {
    Compliance        = "PCI-DSS"
    BackupRequired    = "true"
    DisasterRecovery  = "enabled"
    SLA              = "99.99"
  } : {}
  
  all_tags = merge(
    local.mandatory_tags,
    local.compliance_tags,
    var.additional_tags
  )
}
```

## Cost Optimization

### Auto-shutdown for Non-Production
```hcl
resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.environment != "prod" ? 1 : 0
  
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "Pacific Standard Time"

  notification_settings {
    enabled = false
  }
  
  tags = local.common_tags
}
```

### Budget Alerts
```hcl
resource "azurerm_consumption_budget_subscription" "main" {
  name            = "budget-${var.subscription_name}"
  subscription_id = data.azurerm_subscription.current.id

  amount     = var.monthly_budget
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  notification {
    enabled   = true
    threshold = 80.0
    operator  = "GreaterThan"
    
    contact_emails = var.budget_alert_emails
  }
  
  notification {
    enabled   = true
    threshold = 100.0
    operator  = "GreaterThan"
    
    contact_emails = var.budget_alert_emails
  }
}
```

## Disaster Recovery Patterns

### Multi-Region Deployment
```hcl
variable "regions" {
  type = map(object({
    location       = string
    is_primary     = bool
    address_space  = list(string)
  }))
  
  default = {
    primary = {
      location      = "northeurope"
      is_primary    = true
      address_space = ["10.0.0.0/16"]
    }
    secondary = {
      location      = "westeurope"
      is_primary    = false
      address_space = ["10.1.0.0/16"]
    }
  }
}

module "regional_deployment" {
  source   = "./modules/regional-infrastructure"
  for_each = var.regions
  
  region_name    = each.key
  location       = each.value.location
  is_primary     = each.value.is_primary
  address_space  = each.value.address_space
  
  enable_dr      = true
  peer_region_id = each.value.is_primary ? module.regional_deployment["secondary"].vnet_id : null
  
  tags = merge(local.common_tags, {
    Region     = each.key
    RegionType = each.value.is_primary ? "Primary" : "Secondary"
  })
}
```

## Common Pitfalls to Avoid

1. **Never hardcode sensitive values** - Use Key Vault or environment variables
2. **Avoid count when possible** - Prefer `for_each` for better state management
3. **Don't use latest provider versions** - Pin to specific versions
4. **Avoid inline provider blocks** - Define at root module level
5. **Don't ignore lifecycle rules** - Implement proper create_before_destroy
6. **Never skip validation** - Always run fmt, validate, and security scans
7. **Avoid large state files** - Split into multiple workspaces or state files
8. **Don't forget about costs** - Implement budget alerts and auto-shutdown

## Links to Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Terraform Modules](https://github.com/Azure/terraform-azurerm-modules)
- [Microsoft Cloud Adoption Framework - Terraform](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/terraform-landing-zone)
- [Organisation Global Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards-demo/tree/master/.github/instructions/global.instructions.md)

---

By following these Terraform standards with Azure focus, teams can build secure, scalable, and maintainable infrastructure while leveraging the latest Terraform 1.13 features and Azure best practices.
