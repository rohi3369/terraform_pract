#create vpc 
resource "aws_vpc" "vpc77" {
    cidr_block = "192.168.0.0/16"

    tags = {
        name = "vpc77"
  }
}

#create public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc77.id
    cidr_block = "192.168.0.0/24"
     
       tags = {
    Name = "public_subnet"
  }
  
}

#create private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc77.id
    cidr_block = "192.168.1.0/24"
     
       tags = {
    Name = "private_subnet"
  }
  
}

# internetgateway creation
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc77.id

  tags = {
    Name = "igw1"
  }
}

#attach internetgateway to vpc
resource "aws_internet_gateway_attachment" "attach" {
    vpc_id = aws_vpc.vpc77.id
    internet_gateway_id = aws_internet_gateway.igw1.id
  
}
  #create security group
resource "aws_security_group" "mysecuritygroup" {
    name        = "mysecuritygroup"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc77.id

  ingress {
    description      = "allowall from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc77.cidr_block]
   
  }

ingress {
    description      = "allowall from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc77.cidr_block]
   
  }

  ingress {
    description      = "allowall from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc77.cidr_block]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "mysecuritygroup"
  }
}

#create routetable
resource "aws_route_table" "myroute1" {
  vpc_id = aws_vpc.vpc77.id

      tags = {
    Name = "myroute1"
  }
}

#route table association to subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.myroute1.id
}

#route
resource "aws_route" "r" {
  route_table_id            = aws_route_table.myroute1.id
  gateway_id       = aws_internet_gateway.igw1.id
  destination_cidr_block    = "0.0.0.0/0"
}

#create keypair
resource "aws_key_pair" "mad" {
    key_name = "mad-key"
    public_key = file("C:/Users/Dell/.ssh/id_rsa.pub")
}

#create EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "bucket" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "mad-key"
  vpc_security_group_ids = ["${aws_security_group.mysecuritygroup.id}"]
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = "true"
  

  tags = {
    Name = "bucket"
  }
}

