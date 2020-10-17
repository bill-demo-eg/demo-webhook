resource "aws_efs_file_system" "efsNotEncrypted" {
  creation_token = "efs-test"

  tags = {
    Name = "not-encrypted"
  }
}

resource "aws_efs_file_system" "efsEncryptedFalse" {
  creation_token = "efs-test"

  tags = {
    Name = "encrypted"
  }

  encrypted = false


}