terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
#variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}


resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}


data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""

}

variable "do_token" {
  default = ""

}

variable "ssh_key_name" {
  default = ""

}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "kube_config" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}

#Usamos o serviço https://registry.terraform.io/ para pegar um provider da digital ocean
#Copiamos a configuração inicial
#Executamos o comando terraform init para inicializar o provider
#Buscamos dados do droplet no https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet

#Executamos o recurso para digitalOcean com: terraform apply

#Formatar arquivo: terraform fmt

#Mostrar plano de execução arquivo: terraform plan
#Destruir infraestrutura: terraform destroy