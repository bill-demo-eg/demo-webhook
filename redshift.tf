resource "aws_redshift_cluster" "redshiftEncryptedFalse" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "mydb"
  master_username    = "foo"
  master_password    = "Mustbe8characters"
  node_type          = "dc1.large"
  cluster_type       = "single-node"

  encrypted           = true
  publicly_accessible = false

  logging {
    enable        = true
    bucket_name   = "<bucket_name>"
    s3_key_prefix = "<s3_key_prefix>"
  }
  port = 1234
}
