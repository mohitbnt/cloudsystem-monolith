# AWS Region
region = "ap-south-1"

environment = "development"

project_name = "cloudsystem-monolith"

cloudflare_api_token = ""
cloudflare_zone_id   = ""
domain_name          = "dev.cloudsystemonline.com"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
private_subnet_cidrs = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]

store_bucket_name = "cloudsystem-monolith-dev"

golden_ami_id = "ami-07e5ce642bbc48c0d"

app_instance_config = {
  instance_type             = "t3.micro"
  root_volume_size          = 8
  root_volume_type          = "gp3"
  root_volume_encrypted     = true
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  protect_scale_in          = false
  termination_policy = [
    "OldestLaunchTemplate"
  ]
}

db_instance_config = {
  family            = "postgres16"
  allocated_storage = 8
  engine_version    = "16"
  instance_class    = "db.t4g.micro"
  db_name           = "cmm-prod-db"
  username          = "cmm-prod-user"
  multi_az          = false
}

cache_config = {
  engine_version             = "7.1"
  node_type                  = "cache.t4g.micro"
  auotmatic_failover_enabled = false
  multi_az_enabled           = false
}