# Publish DB Secret ARN
output "db_secret_arn" {
    description = "DB Secret ARN"
    value = aws_secretsmanager_secret.db_secret.arn
}