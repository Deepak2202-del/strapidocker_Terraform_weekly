resource "random_string" "sg_suffix" {
  length  = 6  # Adjust the length as needed for uniqueness
  special = false
  upper   = false
}

resource "aws_instance" "strapi_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.strapi_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "Strapi-Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nodejs npm git",
      "sudo npm install -g strapi",
      "git clone https://github.com/Deepak2202-del/strapidocker_Terraform_weekly.git .",  # Clone repository into current directory
      "cd /home/ubuntu/strapidocker_Terraform_weekly",
      "sudo apt-get install -y docker.io", 
      "sudo usermod -aG docker ubuntu",     
      "sudo systemctl enable docker",    
      "sudo systemctl start docker",     
      "sudo docker pull dravula/strapi:latest",  
      "sudo docker run -d -p 1337:1337 --name my_strapi dravula/strapi:latest" 
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group2-${random_string.sg_suffix.result}"
  description = "Security group for Strapi EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "D_Security Group"
  }
}
