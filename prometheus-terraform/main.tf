provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "./modules/networking"
  vpc_cidr = "192.168.0.0/16"
  public_subnets  = ["192.168.10.0/24", "192.168.20.0/24"]
  private_subnets = ["192.168.30.0/24", "192.168.40.0/24"]
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "instances" {
  source = "./modules/instances"
  ami_id = "ami-0e1bed4f06a3b463d"
  instance_type = "t2.micro"
  key_name = "ansible"
  public_subnet_id  = module.networking.public_subnet_ids[0]
  private_subnet_id = module.networking.private_subnet_ids[0]
  public_sg_id  = module.security.public_sg_id
  private_sg_id = module.security.private_sg_id
}

output "public_instance_ip" {
  value = module.instances.public_instance_ip
}

output "private_instance_ip" {
  value = module.instances.private_instance_ip
}
