resource "aws_lb" "main" {
  name            = "myapp-load-balancer"
  subnets         = aws_subnet.Publica.*.id
  security_groups = [aws_security_group.balanceador.id]
}

resource "aws_lb_target_group" "app" {
  name        = "myapp-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC_Muni.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirecciona todo el trafico desde el balanceador de carga
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app.id
    type             = "forward"
  }
}