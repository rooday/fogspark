# FogSpark

Terraform configuration for deploying nginx proxy servers on DigitalOcean with geo-routing support.

## Overview

Two DigitalOcean droplets (East and West coast) configured as nginx reverse proxies. Designed to work with AWS Route53 geo-based routing to direct traffic to the nearest proxy.

## Prerequisites

- Terraform >= 1.0
- DigitalOcean API token
- SSH key added to DigitalOcean
- Backend server addresses

## Installation

**Terraform:**
- Windows: `winget install Hashicorp.Terraform` or download from [terraform.io/downloads](https://www.terraform.io/downloads)
- macOS: `brew install terraform`
- Linux: Use HashiCorp's apt repository

**Linters (optional):**
- `terraform fmt` and `terraform validate` (built-in)
- `yamllint` for YAML: `pip install yamllint`
- VS Code: HashiCorp Terraform and YAML extensions

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in:
   - `do_token`: DigitalOcean API token
   - `ssh_key_name`: Exact name of SSH key in DigitalOcean
   - `ssh_public_key`: Your SSH public key content
   - `east_server` / `west_server`: Backend server URLs

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan    # Review changes
   terraform apply   # Create resources
   ```

## Iteration Workflow

### Cloud-init vs Nginx Configs

**Cloud-init** (`cloud-init-*.yaml`):
- Only runs on first boot
- Changes require droplet recreation (`terraform apply` will destroy + recreate)
- Use for: package installation, user setup, initial configuration

**Nginx configs** (`nginx-sites-*/*.conf`):
- Can be updated without recreation
- Use update script or manually copy files

### Updating Nginx Configs

**Script (recommended):**
```bash
# Linux/macOS
./scripts/update-nginx-configs.sh $(terraform output -raw east_coast_ip) $(terraform output -raw west_coast_ip)

# Windows PowerShell
.\scripts\update-nginx-configs.ps1 -EastIP (terraform output -raw east_coast_ip) -WestIP (terraform output -raw west_coast_ip)
```

**Manual:**
```bash
scp nginx-sites-east/*.conf rooday@<east-ip>:/tmp/
ssh rooday@<east-ip> "sudo cp /tmp/*.conf /etc/nginx/sites-available/ && sudo nginx -t && sudo systemctl reload nginx"
```

**Note:** Update script copies configs as-is. Template variables (`${east_server}`, `${west_server}`) won't be substituted - use `terraform apply` for those.

### Updating Cloud-init

Changes to `cloud-init-*.yaml` require recreation:
```bash
terraform plan   # Shows "replace" action
terraform apply   # Destroys and recreates droplets
```

## Configuration

**Defaults:**
- Droplet size: `s-1vcpu-1gb` ($5/month each)
- Regions: `nyc1` (East), `sfo3` (West)

**Override in `terraform.tfvars`:**
```hcl
droplet_size      = "s-2vcpu-2gb"
east_coast_region = "nyc3"
west_coast_region = "sfo2"
project_name      = "my-proxy"
```

**Adding nginx configs:**
Add `.conf` files to `nginx-sites-east/` or `nginx-sites-west/`. They're automatically deployed on `terraform apply`. Use `${east_server}` and `${west_server}` template variables if needed.

## Project Structure

```
├── main.tf                    # Terraform resources
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── versions.tf                # Version requirements
├── terraform.tfvars.example   # Config template
├── cloud-init-east.yaml       # East coast setup
├── cloud-init-west.yaml       # West coast setup
├── nginx-sites-east/          # East nginx configs
├── nginx-sites-west/          # West nginx configs
└── scripts/                   # Update scripts
```

## Commands

```bash
terraform init          # Initialize
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Delete everything
terraform output        # Show IPs
terraform fmt           # Format code
terraform validate      # Validate syntax
```

## Access

- SSH: `ssh rooday@<ip-from-terraform-output>`
- LibreSpeed: `http://<ip>/librespeed`
- User: `rooday` (sudo, no password)

## Security

- SSH key authentication only (password disabled)
- UFW firewall (ports 22, 80, 443)
- User `rooday` with sudo access

## Troubleshooting

- **Invalid token**: Check `do_token` in `terraform.tfvars`
- **SSH key not found**: Verify `ssh_key_name` matches DigitalOcean exactly
- **Can't SSH**: Wait 2-3 min after `terraform apply` for cloud-init to finish
- **Terraform wants to recreate**: Cloud-init changes require recreation