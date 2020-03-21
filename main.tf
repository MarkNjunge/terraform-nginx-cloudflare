# Initialize the Digital Ocean provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Initialize the Cloudflare provider
provider "cloudflare" {
  version   = "~> 2.0"
  api_token = var.cloudflare_api_token
}

# Upload the ssh key to Digital Ocean
resource "digitalocean_ssh_key" "default" {
  name       = "Terraform"
  public_key = file("~/.ssh/terraform.pub")
}

# Create a droplet on Digital Ocean
resource "digitalocean_droplet" "default" {
  image      = var.digitalocean_image
  name       = var.digitalocean_droplet_name
  region     = var.digitalocean_region
  size       = var.digitalocean_size
  monitoring = true
  ssh_keys   = [digitalocean_ssh_key.default.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/terraform")
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "scripts/1-install-nginx.sh"
    destination = "~/1-install-nginx.sh"
  }

  provisioner "file" {
    source      = "scripts/2-install-certbot.sh"
    destination = "~/2-install-certbot.sh"
  }

  # Install Nginx and Certbot
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/1-install-nginx.sh",
      "~/1-install-nginx.sh",
      "chmod +x ~/2-install-certbot.sh",
      "~/2-install-certbot.sh",
    ]
  }

  # Upload the nginx server config
  provisioner "file" {
    source      = "nginx/default.conf"
    destination = "/etc/nginx/conf.d/default.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart nginx",
    ]
  }

  # Revoke the certificate to prevent the expiry reminder email being sent
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "certbot revoke -n --cert-path /etc/letsencrypt/live/${var.certbot_domain}/fullchain.pem",
    ]
  }
}

# Create firewall for the droplet
resource "digitalocean_firewall" "default" {
  name        = var.digitalocean_droplet_name
  droplet_ids = [digitalocean_droplet.default.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Create an A record on Cloudflare, pointing to the droplet
resource "cloudflare_record" "terraform" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_record_name
  value   = digitalocean_droplet.default.ipv4_address
  type    = "A"
  proxied = false
}

# Provision a certificate using Certbot
resource "null_resource" "default" {
  depends_on = [cloudflare_record.terraform]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/terraform")
    host        = digitalocean_droplet.default.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "certbot --nginx -n -d ${var.certbot_domain} --agree-tos -m ${var.certbot_email} --no-eff-email --redirect",
    ]
  }
}

output "ip" {
  value = digitalocean_droplet.default.ipv4_address
}
