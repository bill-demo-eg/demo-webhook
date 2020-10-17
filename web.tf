
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "acme_web" {
  name        = "acme_web"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.acme_root.id}"

  tags = {
    Name = "acme_web"
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


 # HTTP access from the VPC - changed
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 /* ingress {
    to_port     = 3306
    from_port   = 3306
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 137
    from_port   = 137
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 9090
    from_port   = 9090
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 3389
    from_port   = 3389
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 9042
    from_port   = 9042
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 7000
    from_port   = 7000
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 7199
    from_port   = 7199
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 61620
    from_port   = 61620
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 8888
    from_port   = 8888
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }

  ingress {
    to_port     = 9160
    from_port   = 9160
    protocol    = "tcp"
    cidr_blocks = ["192.164.0.0/24"]
  }*/

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "default-acc-sg" {
  name        = "default"
  description = "default VPC security group"
  vpc_id      = "${aws_vpc.acme_root.id}"

  tags = {
    Name = "Ps-demo"
  }
}
resource "aws_instance" "acme_web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    host = "acme"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "acme_web"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.acme_web.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.acme_web.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}