
resource "aws_elasticache_cluster" "noMemcachedInElastiCache" {
  cluster_id           = "cluster-test"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 11211

  az_mode = "cross-az"
}

resource "aws_elasticache_cluster" "redis_version_non_compliant" {
  cluster_id           = "cluster-test"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis4.0"
  engine_version       = "4.0.10"
  port                 = 6379

}
