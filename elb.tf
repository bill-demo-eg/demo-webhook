# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "acme_elb" {
  name        = "acme_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.acme_root.id}"

  tags = {
    Name = "acme_elb"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
 /* # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
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

resource "aws_elb" "acme_elb" {
  name = "acme-elb"

  subnets         = ["${aws_subnet.acme_web.id}"]
  security_groups = ["${aws_security_group.acme_elb.id}"]
  instances       = ["${aws_instance.acme_web.id}"]

  connection_draining = true
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
   tags = {
    Name = "acme_elb"
  }
}