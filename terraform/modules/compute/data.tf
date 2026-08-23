data "aws_ami" "selected_ami" {
    filter {
      name = "image-id"
      values = [var.golden_ami_id]
    }
}