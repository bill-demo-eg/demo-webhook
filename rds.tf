resource "aws_rds_cluster" "awsRdsNotEncrypted" {
  master_password      = "test123"
  master_username      = "test"
}

resource "aws_rds_cluster" "storageEncryptedFalse" {
  master_password      = "test123"
  master_username      = "test"
  storage_encrypted    = false
}
