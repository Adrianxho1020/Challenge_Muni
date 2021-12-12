##Parámetros de Seguridad y Restricciones

#Grupos de seguridad para el ALB que pueden ser editables para restringir el acceso 
resource "aws_security_group" "balanceador" {#"lb"
  name        = "SG_BalanceadorDeCarga" #"myapp-load-balancer-security-group"
  description = "Control de Acceso a la ALB"
  vpc_id      = aws_vpc.VPC_Muni.id

#Protocolos para la entrada y salida de tráfico. Todos por defecto para el acceso
#desde internet 
  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "SG_ECS_tasks" #"myapp-ecs-tasks-security-group"
  description = "Permite todo elacceso entrante solamente desde el ALB"
  vpc_id      = aws_vpc.VPC_Muni.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.balanceador.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}