## Creación parámetros de red necesarios para el despliegue del servicio

# Fetch AZs in the current region
data "aws_availability_zones" "Disponible" { #"available"
}

#Creación de la VPC para el servicio
resource "aws_vpc" "VPC_Muni" {         #main
  cidr_block = "10.0.0.0/16"      #172.17.0.0/16
}

#Creación de las subredes Privadas en zonas de disponibilidad diferentes por medio
#utilizando la variable az_count
resource "aws_subnet" "Privada" {#"private"
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.VPC_Muni.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.Disponible.names[count.index]
  vpc_id            = aws_vpc.VPC_Muni.id
}

#Creación de las subredes públicas en zonas de disponibilidad diferentes por medio
#utilizando la variable az_count
resource "aws_subnet" "Publica" {#"public"
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.VPC_Muni.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.Disponible.names[count.index]
  vpc_id                  = aws_vpc.VPC_Muni.id
  map_public_ip_on_launch = true
}

#Creación del Gateway de internet para la subred pública
resource "aws_internet_gateway" "Gateway" {#"gw"
  vpc_id = aws_vpc.VPC_Muni.id
}

#Enrutamiento del tráfico de la subred pública a través del Gateway 
#el bloque de red 0.0.0.0/0 habilita el tráfico por defecto
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.VPC_Muni.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Gateway.id
}

#Creación de una NAT Gateway para que las instancias de las subredes privadas puedan 
#conectar con otros servicios fuera de la VPC 
resource "aws_eip" "gateway_eip" {#"gw"
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.Gateway]
}

resource "aws_nat_gateway" "gateway_nat" {#gw
  count         = var.az_count
  subnet_id     = element(aws_subnet.Publica.*.id, count.index)
  allocation_id = element(aws_eip.gateway_eip.*.id, count.index)
}

#Creación de una tabla de enrutamiento para las subredes privadas, para hacer que el
#enrutamiento del tráfico que no es local vaya a través del NAT gateway hacia internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.VPC_Muni.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway_nat.*.id, count.index)
  }
}

#Asocia las tablas de enrutamiento más recientemente creadas a las subredes privadas
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.Privada.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}