output "web_instance_public_ip" {
    value = aws_instance.terraform_web.public_ip
}
output "jenkins_instance_public_ip" {
    value = aws_instance.terraform_jenkins.public_ip
}
output "mysql-rds" {
  value = aws_db_instance.mysql.endpoint
}