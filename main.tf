locals {
  instance_name = "terraform-github-actions-ec2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "null_resource" "delete_existing_instance" {
  triggers = {
    instance_name = local.instance_name
    aws_region    = var.aws_region
  }

  provisioner "local-exec" {
    command = <<EOT
      $ids = aws ec2 describe-instances --region "${var.aws_region}" --filters "Name=tag:Name,Values=${local.instance_name}" "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].InstanceId" --output text

      if (-not [string]::IsNullOrWhiteSpace($ids)) {
        Write-Host "Terminating existing EC2 instance(s): $ids"
        aws ec2 terminate-instances --region "${var.aws_region}" --instance-ids $ids
      } else {
        Write-Host "No existing EC2 instance found with tag Name=${local.instance_name}"
      }
    EOT
  }
}

resource "aws_instance" "app" {
  depends_on = [null_resource.delete_existing_instance]

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name = local.instance_name
  }
}