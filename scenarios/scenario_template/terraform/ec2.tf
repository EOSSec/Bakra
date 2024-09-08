## This is an example of an EC2 with a proper whitelist -- note the whitelist on ingress and egress 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "cg-instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.cg-ec2-instance-profile.name
  subnet_id              = aws_subnet.cg_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name     = "cg-instance-${var.cgid}"
    Stack    = var.stack-name
    Scenario = var.scenario-name
  }
}

resource "aws_security_group" "sg" {
  name        = "cg-sg-${var.cgid}"
  description = "Allow SSH and HTTP(s) inbound traffic"
  vpc_id      = aws_vpc.cg_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cg_whitelist
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cg_whitelist
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cg_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}