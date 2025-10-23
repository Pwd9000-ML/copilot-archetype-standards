# Terraform Conventions

This document provides extended Terraform guidelines and best practices for infrastructure as code projects following the organization's standards.

## Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Standards](#naming-standards)
3. [Resource Management](#resource-management)
4. [State Management](#state-management)
5. [Modules](#modules)
6. [Security](#security)
7. [Testing](#testing)
8. [CI/CD Integration](#cicd-integration)
9. [Common Patterns](#common-patterns)

## Project Structure

### Recommended Layout
```
terraform-project/
├── main.tf                 # Primary resource definitions
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Terraform and provider versions
├── locals.tf               # Local values
├── data.tf                 # Data sources
├── backend.tf              # Backend configuration
├── terraform.tfvars        # Default variable values (not in git)
├── .terraform.lock.hcl     # Provider version lock file (in git)
├── .gitignore              # Git ignore patterns
├── README.md               # Documentation
├── modules/                # Local modules
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── environments/           # Environment-specific configurations
    ├── dev/
    │   ├── terraform.tfvars
    │   └── backend.tf
    ├── staging/
    │   ├── terraform.tfvars
    │   └── backend.tf
    └── prod/
        ├── terraform.tfvars
        └── backend.tf
```

### File Organization

#### main.tf
Primary resource definitions, organized by logical grouping:
```hcl
# main.tf

# Networking Resources
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

# Compute Resources
resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  
  tags = local.common_tags
}
```

#### variables.tf
```hcl
# variables.tf

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition     = can(regex("^[a-z]+$", var.location))
    error_message = "Location must be lowercase letters only."
  }
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}
```

#### outputs.tf
```hcl
# outputs.tf

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "admin_credentials" {
  description = "Admin credentials for the VM"
  value = {
    username = var.admin_username
    ssh_key  = var.ssh_public_key
  }
  sensitive = true
}
```

#### locals.tf
```hcl
# locals.tf

locals {
  # Naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Resource names
  resource_group_name = "rg-${local.resource_prefix}-${var.location}"
  vnet_name          = "vnet-${local.resource_prefix}"
  subnet_name        = "snet-${local.resource_prefix}-default"
  vm_name            = "vm-${local.resource_prefix}"
  
  # Common tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedDate = timestamp()
    }
  )
}
```

## Naming Standards

### Resource Naming Convention
Follow cloud provider best practices with consistent patterns:

#### Azure Resources
```hcl
# Format: <resource-type>-<project>-<environment>-<location>-<instance>

resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-prod-eastus"
  location = "eastus"
}

resource "azurerm_storage_account" "main" {
  # Storage accounts have restrictions, use abbreviations
  name                = "stmyappprodeastus001"  # Max 24 chars, no hyphens
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_key_vault" "main" {
  name                = "kv-myapp-prod-eastus"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

#### AWS Resources
```hcl
# Format: <project>-<environment>-<resource-type>-<purpose>

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "myapp-prod-vpc-main"
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "myapp-prod-s3-data"
  
  tags = {
    Name = "myapp-prod-s3-data"
  }
}
```

### Variable and Local Names
```hcl
# Use snake_case
variable "virtual_network_address_space" {}
locals {
  resource_group_name = "..."
  storage_account_name = "..."
}

# Avoid unnecessary prefixes
# Bad
variable "var_location" {}
locals {
  local_vm_name = "..."
}

# Good
variable "location" {}
locals {
  vm_name = "..."
}
```

## Resource Management

### Resource Dependencies
```hcl
# Implicit dependency (preferred)
resource "azurerm_subnet" "main" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name  # Implicit dependency
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Explicit dependency (when needed)
resource "azurerm_network_interface" "main" {
  name                = "nic-main"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on = [
    azurerm_virtual_network.main  # Explicit when implicit isn't sufficient
  ]
}
```

### Lifecycle Management
```hcl
resource "azurerm_virtual_machine" "main" {
  # Configuration...
  
  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = true
    
    # Ignore changes to specific attributes
    ignore_changes = [
      tags["CreatedDate"],
    ]
    
    # Create new before destroying old
    create_before_destroy = true
  }
}
```

### Count and For_each
```hcl
# Use for_each for named resources
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
  default = {
    web = { address_prefix = "10.0.1.0/24" }
    app = { address_prefix = "10.0.2.0/24" }
    db  = { address_prefix = "10.0.3.0/24" }
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}

# Use count for identical resources
resource "azurerm_linux_virtual_machine" "worker" {
  count = var.worker_count
  
  name                = "vm-worker-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size
  
  # Configuration...
}
```

## State Management

### Remote Backend Configuration

#### Azure Backend
```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    
    # Enable encryption and locking
    use_msi              = true  # Use managed identity
  }
}
```

#### S3 Backend
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "myapp-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### State File Security
```hcl
# .gitignore
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
```

### Workspaces
```bash
# Create and switch between workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Use workspace in configuration
resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-${terraform.workspace}"
  location = var.location
}
```

## Modules

### Module Structure
```
modules/
└── networking/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    └── examples/
        └── basic/
            ├── main.tf
            └── README.md
```

### Module Best Practices
```hcl
# modules/networking/main.tf
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}

# modules/networking/variables.tf
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  
  validation {
    condition     = length(var.address_space) > 0
    error_message = "Address space must contain at least one CIDR block."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefix = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# modules/networking/outputs.tf
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

# Usage in main configuration
module "networking" {
  source = "./modules/networking"
  
  vnet_name           = "vnet-myapp-prod"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  subnets = {
    web = { address_prefix = "10.0.1.0/24" }
    app = { address_prefix = "10.0.2.0/24" }
    db  = { address_prefix = "10.0.3.0/24" }
  }
  
  tags = local.common_tags
}
```

## Security

### Secrets Management
```hcl
# Bad - Hardcoded secrets
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "SuperSecret123!"  # NEVER DO THIS!
  key_vault_id = azurerm_key_vault.main.id
}

# Good - Use variables marked as sensitive
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
}

# Best - Generate secrets in Terraform
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.main.id
}
```

### Security Best Practices
```hcl
# Enable encryption
resource "azurerm_storage_account" "main" {
  name                     = "stmyappprod"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # Enable encryption
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  # Enable blob encryption
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
  }
}

# Restrictive network rules
resource "azurerm_network_security_group" "main" {
  name                = "nsg-myapp-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = var.allowed_ip_ranges  # Specific IPs only
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
```

## Testing

### Validation Commands
```bash
# Format check
terraform fmt -check -recursive

# Validate configuration
terraform validate

# Security scanning
tfsec .
checkov -d .

# Plan with detailed output
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

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
      - id: terraform_tfsec
```

## CI/CD Integration

### GitLab CI Example
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan
  - apply

variables:
  TF_VERSION: "1.6.0"

.terraform_base:
  image: hashicorp/terraform:$TF_VERSION
  before_script:
    - terraform init -backend-config="backend-${CI_ENVIRONMENT_NAME}.hcl"

validate:
  extends: .terraform_base
  stage: validate
  script:
    - terraform fmt -check -recursive
    - terraform validate
    - tfsec .

plan:
  extends: .terraform_base
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan
  only:
    - merge_requests

apply:
  extends: .terraform_base
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  only:
    - main
  when: manual
  environment:
    name: production
```

## Additional Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [AWS Tagging Best Practices](https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html)
- [TFSec Documentation](https://aquasecurity.github.io/tfsec/)
