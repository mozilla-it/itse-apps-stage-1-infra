resource "aws_elasticache_subnet_group" "securitywiki_memcache_clients" {
  name        = "${var.project}-${var.environment}-memcache-sg"
  description = "Subnet group for ${var.project}-${var.environment}"
  subnet_ids  = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
}

resource "aws_elasticache_cluster" "memcache" {
  cluster_id         = "${var.project}-${var.environment}"
  engine             = "memcached"
  node_type          = var.memcache_node_type
  num_cache_nodes    = "1"
  apply_immediately  = true
  subnet_group_name  = aws_elasticache_subnet_group.securitywiki_memcache_clients.name
  security_group_ids = [aws_security_group.securitywiki_memcache_clients.id]
}

resource "aws_security_group" "securitywiki_memcache_clients" {
  name   = "${var.project}-${var.environment}-memcache-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = "11211"
    to_port     = "11211"
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
