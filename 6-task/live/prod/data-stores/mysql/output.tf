output "address" {
  description = "Connect to the DB at this endpoint"
  value = aws_db_instance.example.address
}

output "port" {
  description = "DB port is listening on"
  value = aws_db_instance.example.port
}