variable "digitalocean_token" {
  default = ""
}

variable "digitalocean_droplet_name" {
  default = ""
}

variable "digitalocean_image" {
  default = "ubuntu-18-04-x64"
}

variable "digitalocean_region" {
  default = "lon1"
}

variable "digitalocean_size" {
  default = "s-1vcpu-1gb"
}

variable "certbot_email" {
  default = ""
}

variable "certbot_domain" {
  default = ""
}

variable "cloudflare_api_token" {
  default = ""
}

variable "cloudflare_zone_id" {
  default = ""
}

variable "cloudflare_record_name" {
  default = ""
}