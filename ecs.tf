# Configuración de contenedor ECS

resource "aws_ecs_cluster" "main" {
  name = "Aplicacion_Cluster" #"myapp-cluster"
}

data "template_file" "myapp" {
  template = file("./templates/ecs/myapp.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

#Definición de la tarea en el contenedor
resource "aws_ecs_task_definition" "app" {
  family                   = "myapp-task"  
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.myapp.rendered
}

#Definición del numero de contenedores que se crearán
resource "aws_ecs_service" "main" {
  name            = "myapp-service"
  #cluster         = aws_ecs_cluster.main.id
  #task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

#Configuración de la Red definida en red.tf
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.Privada.*.id
    assign_public_ip = true
  }

#Configuración del Balanceador de carga para el contenedor
  load_balancer {
    target_group_arn = aws_lb_target_group.app.id
    container_name   = "myapp"
    container_port   = var.app_port
  }

#La ejecución del servicio depende de la configuración del balanceador de carga definido,
#del rol y las políticas deefinidas en role.tf y en red.tf
  depends_on = [aws_lb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}