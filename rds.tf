resource "aws_rds_cluster" "awsRdsNotEncrypted" {
  master_password       = "test123"
  master_username       = "test"
  storage_encrypted     = true
  copy_tags_to_snapshot = true
  deletion_protection   = true
  backtrack_window      = 86400
}

resource "aws_rds_cluster" "storageEncryptedFalse" {
  master_password       = "test123"
  master_username       = "test"
  storage_encrypted     = true
  copy_tags_to_snapshot = true
  deletion_protection   = true
  backtrack_window      = 86400
}
