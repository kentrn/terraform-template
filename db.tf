resource "aws_dynamodb_table" "terraform_dynamodb_table" {
    name = "terraform_table"
    billing_mode = "PROVISIONED"
    read_capacity = 5
    write_capacity = 5
    hash_key = "id"
    attribute = [{
        name = "id"
        type = "S"
    }]
}
