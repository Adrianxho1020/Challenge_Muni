#Creación base de datos en RDS MySQL 
resource "aws_db_instance" "db_rds_Muni" {
    identifier            = "mysql-db-muni"
    storage_type          = "gp2"               #Opcional ya teraform lo seleccionaría por defecto
    allocated_storage     = 20                  #Gigas
    engine                = "mysql"
    engine_version        = "8.0"               #Opcional, Terraform eligiría la mejor opción
    instance_class        = "db.t2.micro"
    port                  = "3306"              #Opcional, en la capa gratuita ya esta seleccionado
    #db_subnet_group_name  = "VPC_Muni"         #Opcional
    name                  = "DB Muni"           #Opcional, pero es meor definirlo
    username              = "userMuni"
    password              = "muni1234"    
    parameter_group_name  = "default.mysql8.0"  #Opcional, se asume que la DB lo crea
    skip_final_snapshot   = true  
    #availability_zone     = "us_east-2"        #Opcional para RDS
    publicly_accessible   = true
    #deletion_protection   = true               #opcional para protger la DB

    tags = {
      name = "DB RDS Muni"
    }
       
}






















# Create Database Subnet Group
# # terraform aws db subnet group
# resource "aws_db_subnet_group" "database-subnet-group" {
#   name         = "database subnets"
#   subnet_ids   = [aws_subnet.Privada.id]
#   description  = "Subred asignada a la instancia de la base de datos"

#   tags   = {
#     Name = "Subred de la Base de datos "
#   }
# }

# # Get the Latest DB Snapshot
# # terraform aws data db snapshot
# data "aws_db_snapshot" "latest-db-snapshot" {
#   db_snapshot_identifier = "${var.Identificador_SnapShot_DB}"
#   most_recent            = true
#   snapshot_type          = "manual"
# }

# # Create Database Instance Restored from DB Snapshots
# # terraform aws db instance
# resource "aws_db_instance" "database-instance" {
#   instance_class          = "${var.DB_instance_Class}"
#   skip_final_snapshot     = true
#   availability_zone       = var.aws_region
#   identifier              = "${var.DB_instance_Identifier}"
#   snapshot_identifier     = data.aws_db_snapshot.latest-db-snapshot.id
#   db_subnet_group_name    = aws_db_subnet_group.database-subnet-group.name
#   multi_az                = "${var.multi_az_deploy}"
#   vpc_security_group_ids  = [aws_security_group.database-security-group.id]
# }


