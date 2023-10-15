resource "aws_dynamodb_table" "basic-dynamodb-table-papi" {
  name         = "GameScores"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }




  tags = {
    Name = "basic-dynamodb-table-papi"
  }
}