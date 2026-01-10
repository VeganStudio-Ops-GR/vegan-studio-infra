# 1. THE VPC (The House)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # The IP range for the whole network (e.g., 10.0.0.0/16)
  enable_dns_hostnames = true         # Allows resources to have a DNS name (like website.com)
  enable_dns_support   = true         # Allows AWS to resolve DNS names

  tags = {
    Name = "${var.project_name}-vpc" # Naming it "vegan-studio-vpc"
  }
}

# 2. INTERNET GATEWAY (The Front Door)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # Attaching the door to our VPC house

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. PUBLIC SUBNETS (The Guest Rooms - Accessible from outside)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr) # Loops twice (for 2 subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index] # Picks the IP range from our list
  availability_zone       = var.availability_zones[count.index]  # Picks AP-SOUTH-1A then 1B
  map_public_ip_on_launch = true                                 # Auto-assigns public IP to servers here

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}" # Names it public-1, public-2
  }
}

# 4. PRIVATE APP SUBNETS (The Kitchen - Staff only)
resource "aws_subnet" "private_app" {
  count             = length(var.app_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-app-${count.index + 1}"
  }
}

# 5. PRIVATE DATA SUBNETS (The Vault - Highly Secure)
resource "aws_subnet" "private_data" {
  count             = length(var.data_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-data-${count.index + 1}"
  }
}

# 6. ELASTIC IP (Static IP for the NAT Gateway)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 7. NAT GATEWAY (Single Shared Gateway)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Placing it in the first Public Subnet

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  # Dependency: We must wait for the Internet Gateway to be ready first!
  depends_on = [aws_internet_gateway.igw]
}

# ------------------------------------------------------------------------------
# 8. PUBLIC ROUTE TABLE (For Public Subnets -> IGW)
# ------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate ALL Public Subnets with this Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# 9. PRIVATE ROUTE TABLE (For App & Data Subnets -> NAT Gateway)
# ------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Associate App Subnets (Private)
resource "aws_route_table_association" "private_app" {
  count          = length(var.app_subnets_cidr)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Data Subnets (Private)
resource "aws_route_table_association" "private_data" {
  count          = length(var.data_subnets_cidr)
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private.id
}
