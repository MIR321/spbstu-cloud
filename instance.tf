resource "aws_instance" "terraform_web" {
  
    ami           = var.AMI
    instance_type = "t2.micro"
    key_name      = aws_key_pair.sshkey.key_name
    subnet_id     = aws_subnet.main-public-1.id
    vpc_security_group_ids = [aws_security_group.allow-ssh.id]

    tags = {
        Name = "web-instance"
    }

    # ждем пока SSH будет готов

    provisioner "remote-exec" {
        inline = ["echo connected"]
        connection {
            type        = "ssh"
            user        = var.INSTANCE_USERNAME
            private_key = file(var.PATH_TO_PRIVATE_KEY)
            host        = aws_instance.terraform_web.public_ip
        }
    }

    # SSH готов - запускаем Ansible

    provisioner "local-exec" {        
         command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ubuntu@${aws_instance.terraform_web.public_ip}, --private-key ${var.PATH_TO_PRIVATE_KEY} provision_web.yaml"
    }
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "eu-west-1a"
  size              = 4
  type              = "gp2"
  tags = {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.ebs-volume-1.id
  instance_id = aws_instance.terraform_web.id

  provisioner "local-exec" {        
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ubuntu@${aws_instance.terraform_web.public_ip}, --private-key ${var.PATH_TO_PRIVATE_KEY} provision_ebs.yaml"
  }
  
}

resource "aws_instance" "terraform_jenkins" {

    ami           = var.AMI
    instance_type = "t2.micro"
    key_name      = aws_key_pair.sshkey.key_name
    subnet_id     = aws_subnet.main-public-1.id
    vpc_security_group_ids = [aws_security_group.allow-http.id]

    tags = {
        Name = "jenkins-instance"
    }

    provisioner "remote-exec" {
        inline = ["echo connected"]
        connection {
            type        = "ssh"
            user        = var.INSTANCE_USERNAME
            private_key = file(var.PATH_TO_PRIVATE_KEY)
            host        = aws_instance.terraform_jenkins.public_ip
        }
    }

    # SSH готов - запускаем Ansible

    provisioner "local-exec" {        
         command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ubuntu@${aws_instance.terraform_jenkins.public_ip}, --private-key ${var.PATH_TO_PRIVATE_KEY} provision_jenkins.yaml"
    }
    
}
