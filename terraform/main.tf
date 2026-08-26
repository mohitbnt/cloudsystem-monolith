# All Modules
module "networking" {
  source               = "./modules/networking"
  common_tags          = local.common_tags
  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  vpc_endpoint_sg_id   = module.security.vpc_endpoint_sg_id
}

module "security" {
  source                      = "./modules/security"
  common_tags                 = local.common_tags
  project_name                = var.project_name
  environment                 = var.environment
  region                      = var.region
  vpc_id                      = module.networking.vpc_id
  app_bucket_arn              = module.storage.app_bucket_arn
  database_backups_bucket_arn = var.database_backups_bucket_arn
}

module "storage" {
  source       = "./modules/storage"
  region       = var.region
  environment  = var.environment
  project_name = var.project_name
  common_tags  = local.common_tags
  domain_name  = var.domain_name
}

module "database" {
  source                = "./modules/database"
  region                = var.region
  environment           = var.environment
  project_name          = var.project_name
  common_tags           = local.common_tags
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_instance_config    = var.db_instance_config
}

module "compute" {
  source                         = "./modules/compute"
  common_tags                    = local.common_tags
  project_name                   = var.project_name
  environment                    = var.environment
  region                         = var.region
  vpc_id                         = module.networking.vpc_id
  public_subnet_ids              = module.networking.public_subnet_ids
  private_subnet_ids             = module.networking.private_subnet_ids
  vpc_endpoint_sg_id             = module.security.vpc_endpoint_sg_id
  golden_ami_id                  = var.golden_ami_id
  ec2_role_name                  = module.security.ec2_role_name
  ec2_security_group_id          = module.security.ec2_security_group_id
  alb_security_group_id          = module.security.alb_security_group_id
  rds_security_group_id          = module.security.rds_security_group_id
  vpc_endpoint_security_group_id = module.security.vpc_endpoint_security_group_id
  app_instance_config            = var.app_instance_config
  tls_certificate_arn            = module.dns-and-ssl.tls_certificate_arn
  db_secret_arn                  = module.database.db_secret_arn
  s3_parameter                   = module.parameters.s3_parameter
  redis_parameter                = module.parameters.redis_parameter
  database_backups_bucket        = var.database_backups_bucket
  database_backups_bucket_key    = var.database_backups_bucket_key
}

module "cache" {
  source                  = "./modules/cache"
  region                  = var.region
  environment             = var.environment
  project_name            = var.project_name
  common_tags             = local.common_tags
  private_subnet_ids      = module.networking.private_subnet_ids
  redis_elasticache_sg_id = module.security.redis_elasticache_sg_id
  cache_config            = var.cache_config
}

module "parameters" {
  source         = "./modules/paramters"
  common_tags    = local.common_tags
  region         = var.region
  environment    = var.environment
  project_name   = var.project_name
  redis_endpoint = module.cache.redis_endpoint
  app_bucket     = module.storage.app_bucket
}

module "dns-and-ssl" {
  source             = "./modules/dns-and-ssl"
  common_tags        = local.common_tags
  region             = var.region
  environment        = var.environment
  project_name       = var.project_name
  cloudflare_zone_id = var.cloudflare_zone_id
  domain_name        = var.domain_name
  alb_dns_name       = module.compute.alb_dns_name
}