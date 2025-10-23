---
applyTo: "**/*.tf"
description: Terraform infrastructure as code standards
---

# Terraform Development Standards

## Version Requirements
- Use Terraform >= 1.6.0
- Pin provider versions in `required_providers` block
- Use semantic versioning constraints (`~>` for minor version updates)

```hcl
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Code Formatting & Linting

- **Formatter**: Run `terraform fmt -recursive` before committing
- **Linter**: Use `tflint` with appropriate rulesets
- **Security**: Use `tfsec` or `checkov` for security scanning
- **Validation**: Run `terraform validate` in CI/CD

### TFLint Configuration
```hcl
# .tflint.hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_naming_convention" {
  enabled = true
}
```

## File Structure

Organize Terraform code with a clear structure:

```
├── main.tf              # Primary resource definitions
├── variables.tf         # Input variable declarations
├── outputs.tf           # Output value declarations
├── versions.tf          # Terraform and provider version constraints
├── locals.tf            # Local value definitions (optional)
├── data.tf              # Data source definitions (optional)
├── terraform.tfvars     # Variable values (gitignored for secrets)
├── modules/             # Local modules
│   └── <module-name>/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/        # Environment-specific configs
    ├── dev/
    ├── staging/
    └── prod/
```

## Naming Conventions

- Use `snake_case` for all resource names, variables, and outputs
- Use descriptive, meaningful names that indicate purpose
- Prefix resources with type or purpose (e.g., `rg_` for resource groups)
- Use consistent naming across environments

### Examples
```hcl
# Resource names
resource "azurerm_resource_group" "rg_main" {
  name     = "rg-${var.project}-${var.environment}-${var.location}"
  location = var.location
}

# Variable names
variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

# Output names
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg_main.name
}
```

## Variables

- Always include descriptions for variables
- Specify types explicitly
- Use validation blocks for input constraints
- Set sensitive = true for sensitive values
- Provide meaningful defaults when appropriate

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "admin_password" {
  description = "Administrator password for the VM"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}
```

## Outputs

- Document all outputs with descriptions
- Mark sensitive outputs appropriately
- Group related outputs logically
- Use outputs to expose module information

```hcl
output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg_main.id
}

output "admin_credentials" {
  description = "Administrator credentials (sensitive)"
  value = {
    username = azurerm_linux_virtual_machine.vm.admin_username
    password = azurerm_linux_virtual_machine.vm.admin_password
  }
  sensitive = true
}
```

## Modules

- Create reusable modules for common patterns
- Document module usage in README.md
- Version modules using Git tags
- Test modules independently
- Keep modules focused and single-purpose

### Module Structure
```hcl
# modules/virtual_network/main.tf
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

# modules/virtual_network/variables.tf
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

# modules/virtual_network/outputs.tf
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}
```

## State Management

- Use remote state backends (Azure Storage, S3, Terraform Cloud)
- Enable state locking to prevent concurrent modifications
- Never commit state files to version control
- Use workspaces or separate state files per environment

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

## Security Best Practices

- Never hardcode secrets or credentials
- Use Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault
- Enable encryption at rest for state files
- Use managed identities where possible
- Implement least privilege access controls
- Tag resources for cost tracking and compliance

## Testing

- Use `terraform plan` to preview changes before applying
- Implement automated testing with Terratest or similar
- Test in lower environments before production
- Use `-target` flag sparingly (only for debugging)

## Documentation

- Maintain README.md with usage examples
- Document architecture decisions
- Keep diagrams up-to-date
- Use terraform-docs to auto-generate documentation

## Additional Resources

See [Terraform Conventions](../docs/terraform-conventions.md) for extended guidelines.
