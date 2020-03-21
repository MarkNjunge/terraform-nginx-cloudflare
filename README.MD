# terraform-nginx-cloudflare

Setup for Digital Ocean + Nginx + Certbot + Cloudflare using [Terraform](https://www.terraform.io/).

This will use Terraform to:

- Create a Digital Ocean Droplet
- Install Nginx & Certbot
- Create a firewall on Digital Ocean
- Setup an A record on Cloudflare to point to the droplet's IP
- Provision an SSL certificate for the domain using Certbot

Written for Terraform v0.12.24

## Installation

1. Clone the repository

```
git clone https://github.com/MarkNjunge/terraform-nginx-cloudflare.git
cd terraform-nginx-cloudflare
```

2. Create a `terraform.tfvars` file and modify the contents.

```
cp terraform.tfvars.sample terraform.tfvars
```

3. Modify [nginx/default.conf](./nginx/default.conf). Change `server_name`to your domain.

4. Create an ssh key named `terraform`.  
   It should be saved in `~/.ssh` (`C:\Users\username\.ssh` on Windows)

```
ssh-keygen -t rsa
```

5. Install Terraform providers and apply

```
terraform init

terraform apply
```

## Requirements

### Digital Ocean

Create a personal access token on Digital Ocean: [LINK](https://cloud.digitalocean.com/account/api/tokens/new)

### Cloudflare

Create an **API Token** on Cloudflare: [Managing API Tokens and Keys](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys). The token needs to have permission to edit DNS in a zone.

[How to find your zone id](https://community.cloudflare.com/t/how-to-find-cloudflare-zone-id-to-configure-it-with-wp-rocket/83131/2).
