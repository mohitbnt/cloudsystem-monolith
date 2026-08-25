# Create a policy for s3 access
data "aws_iam_policy_document" "s3_access_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.app_bucket}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.app_bucket}/*"
    ]
  }
}

# Create a trust policy for the role
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create a IAM role for the EC2 instance
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# Attache SSM policy to the ec2 role
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name   = "${var.project_name}-${var.environment}-s3-access"
  policy = data.aws_iam_policy_document.s3_access_document.json
}

# Attache S3 policy to the ec2 role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create policy document for Secret Manager access and parameter store access
data "aws_iam_policy_document" "credentials_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-${var.environment}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
      ]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/*",
    ]
  }
}

# Create policy for Secret Manager and Parameter store access
resource "aws_iam_policy" "credentials_policy" {
  name   = "${var.project_name}-${var.environment}-credentials-policy"
  policy = data.aws_iam_policy_document.credentials_policy_document.json 
}

# Attach credentials policy to the ec2 role
resource "aws_iam_role_policy_attachment" "credentials_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.credentials_policy.arn
}