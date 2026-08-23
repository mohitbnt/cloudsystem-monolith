# AWS Region
region = "ap-south-1"

environment = "production"

project_name = "cm"

cloudflare_api_token = ""
cloudflare_zone_id   = ""
domain_name          = "cloudsystemonline.com"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

store_bucket_name = "cloudsystem-monolith-uploads-prod"

golden_ami_id = ""

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