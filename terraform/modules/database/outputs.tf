# Publish the PostgreSQL connection string
output "db_secret_name" {
    value = aws_secretsmanager_secret.db_secret.name
    description = "The name of the Secrets Manager secret storing the PostgreSQL connection string"
}