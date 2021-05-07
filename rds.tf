resource "aws_db_subnet_group" "mysql-subnet" {
  name        = "mysql-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.main-private-1.id, aws_subnet.main-private-2.id]
}

resource "aws_db_parameter_group" "mysql-parameters" {
  name        = "mysql-parameters"
  family      = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_instance" "mysql" {
    allocated_storage             = 10
    engine                        = "mysql"
    engine_version                = "5.7"
    instance_class                = "db.t2.micro"
    name                          = "ghost"
    username                      = "root"
    password                      = var.RDS_PASSWORD
    db_subnet_group_name          = aws_db_subnet_group.mysql-subnet.name
    parameter_group_name          = aws_db_parameter_group.mysql-parameters.name
    vpc_security_group_ids        = [aws_security_group.allow-mysql.id]
    availability_zone             = aws_subnet.main-private-1.availability_zone
    skip_final_snapshot           = true
    multi_az                      = "false"
    tags = {
        Name = "mysql-instance"
    }
}

