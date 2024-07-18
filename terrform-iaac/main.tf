# terrform scripts
resource "aws_vpc" "sap-vpc" {
  cidr_block = var.cidr-range
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.sap-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "sap-sg" {
  name   = "sap-sg"
  vpc_id = aws_vpc.sap-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Specific will be allowed for ssh 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sap-security_group"
  }
}

resource "aws_internet_gateway" "prod-igw" {
    vpc_id = "${aws_vpc.sap-vpc.id}"
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_route_table" "prod-public-crt" {
    vpc_id = "${aws_vpc.sap-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.prod-igw.id}" 
    }
    
    tags = {
        Name = "prod-public-crt"
    }
}


resource "aws_route_table_association" "prod-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.subnet-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
}

resource "aws_key_pair" "ec2-ssh-key" {
    key_name = "key-pair"
    public_key = file("./id_rsa.pub")
}

resource "aws_instance" "vm1" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sap-sg.id]
  subnet_id              = aws_subnet.subnet-1.id
  key_name      = aws_key_pair.ec2-ssh-key.key_name
}