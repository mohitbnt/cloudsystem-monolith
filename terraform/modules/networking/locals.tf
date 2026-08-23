locals {
    # Interface Endpoints
    interface_endpoints = {
        ssm = "com.amazonaws.${var.region}.ssm"
        ec2messages = "com.amazonaws.${var.region}.ec2messages"
        ssmmessages = "com.amazonaws.${var.region}.ssmmessages"
    }
}