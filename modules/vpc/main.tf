
resource "aws_vpc" "mainVPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "vpc_IGW" {
  vpc_id = aws_vpc.mainVPC.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

// Public subnets
resource "aws_subnet" "publicSubnet" {
    // Create a subnet for each CIDR block in the public_subnets variable
  for_each = {
    // idx = index of the CIDR block in the list, cidr = the CIDR block itself
    for idx, cidr in var.public_subnets :
    idx => cidr // Create a map with the index as the key and the CIDR block as the value
  }

  vpc_id                  = aws_vpc.mainVPC.id
  cidr_block              = each.value // Use the CIDR block from the map
  availability_zone       = var.availability_zones[each.key] // Use the index to get the corresponding availability zone for each subnet
  map_public_ip_on_launch = true // Automatically assign public IPs to instances launched in this subnet cause Public Subnet

  tags = {
    Name = "${var.project_name}-public-${each.key + 1}" // Name the subnets as public-1, public-2, etc. using the index
  }
}

// Presentation subnets
resource "aws_subnet" "presentationSubnet" {
    // Create a subnet for each CIDR block in the public_subnets variable
  for_each = {
    // idx = index of the CIDR block in the list, cidr = the CIDR block itself
    for idx, cidr in var.presentation_subnets :
    idx => cidr // Create a map with the index as the key and the CIDR block as the value
  }

  vpc_id            = aws_vpc.mainVPC.id
  cidr_block        = each.value // Use the CIDR block from the map
  availability_zone = var.availability_zones[each.key] // Use the index to get the corresponding availability zone for each subnet

  tags = {
    Name = "${var.project_name}-presentation-${each.key + 1}" // Name the subnets as presentation-1, presentation-2, etc. using the index
  }
}

// Logic subnets
resource "aws_subnet" "logicSubnet" {
    // Create a subnet for each CIDR block in the public_subnets variable
  for_each = {
    // idx = index of the CIDR block in the list, cidr = the CIDR block itself
    for idx, cidr in var.logic_subnets :
    idx => cidr // Create a map with the index as the key and the CIDR block as the value
  }

  vpc_id            = aws_vpc.mainVPC.id
  cidr_block        = each.value // Use the CIDR block from the map
  availability_zone = var.availability_zones[each.key] // Use the index to get the corresponding availability zone for each subnet

  tags = {
    Name = "${var.project_name}-logic-${each.key + 1}" // Name the subnets as logic-1, logic-2, etc. using the index
  }
}

// Database subnets
resource "aws_subnet" "databaseSubnet" {
    // Create a subnet for each CIDR block in the public_subnets variable
  for_each = {
    // idx = index of the CIDR block in the list, cidr = the CIDR block itself
    for idx, cidr in var.database_subnets :
    idx => cidr // Create a map with the index as the key and the CIDR block as the value
  }

  vpc_id            = aws_vpc.mainVPC.id
  cidr_block        = each.value // Use the CIDR block from the map
  availability_zone = var.availability_zones[each.key] // Use the index to get the corresponding availability zone for each subnet

  tags = {
    Name = "${var.project_name}-database-${each.key + 1}" // Name the subnets as database-1, database-2, etc. using the index
  }
}

// Allocate Elastic IPs for NAT Gateways in each public subnet
resource "aws_eip" "nat" {
  for_each = aws_subnet.publicSubnet // Create an Elastic IP for each public subnet
  domain   = "vpc"
}

// Create a NAT Gateway in each public subnet using the allocated Elastic IPs
resource "aws_nat_gateway" "natGateway" {
  for_each = aws_subnet.publicSubnet // Create a NAT Gateway for each public subnet

  allocation_id = aws_eip.nat[each.key].id // Use the index to get the corresponding Elastic IP for each NAT Gateway
  subnet_id     = each.value.id // Use the index to get the corresponding public subnet for each NAT Gateway

  depends_on = [aws_internet_gateway.vpc_IGW] // Ensure the Internet Gateway is created before the NAT Gateways

  tags = {
    Name = "${var.project_name}-nat-${each.key + 1}" // Name the NAT Gateways as nat-1, nat-2, etc. using the index
  }
}


// Create a route table for the public subnets
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.mainVPC.id

  route {
    cidr_block = "0.0.0.0/0" // Route all outbound traffic to the Internet
    gateway_id = aws_internet_gateway.vpc_IGW.id // Route all outbound traffic from the public subnets to the Internet Gateway
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

// Associate the public route table with the public subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.publicSubnet

  subnet_id      = each.value.id // Use the index to get the corresponding public subnet for each association
  route_table_id = aws_route_table.publicRT.id // Associate each public subnet with the public route table
}

// Create a route table for the private subnets
resource "aws_route_table" "privateRT" {
  for_each = aws_nat_gateway.natGateway

  vpc_id = aws_vpc.mainVPC.id

  route {
    cidr_block     = "0.0.0.0/0" // Route all outbound traffic to the Internet
    nat_gateway_id = each.value.id // Use the index to get the corresponding NAT Gateway for each route table
  }

  tags = {
    Name = "${var.project_name}-private-rt-${each.key + 1}"
  }
}

// Associate the private route tables with the presentation subnets
resource "aws_route_table_association" "presentation" {
  for_each = aws_subnet.presentationSubnet

  subnet_id = each.value.id
  route_table_id = aws_route_table.privateRT[each.key].id // Use the index to get the corresponding private route table for each association
}

// Associate the private route tables with the logic subnets
resource "aws_route_table_association" "logic" {
  for_each = aws_subnet.logicSubnet

  subnet_id = each.value.id
  route_table_id = aws_route_table.privateRT[each.key].id // Use the index to get the corresponding private route table for each association
}




