output "vpc_id" {
  value = aws_vpc.mainVPC.id // Output the ID of the VPC created in this module
}

output "public_subnets" {
    // Use a for expression to create a list of subnet IDs from the aws_subnet.publicSubnet resource
  value = [for s in aws_subnet.publicSubnet : s.id]
}

output "presentation_subnets" {
    // Use a for expression to create a list of subnet IDs from the aws_subnet.presentationSubnet resource
  value = [for s in aws_subnet.presentationSubnet : s.id]
}

output "logic_subnets" {
    // Use a for expression to create a list of subnet IDs from the aws_subnet.logicSubnet resource
  value = [for s in aws_subnet.logicSubnet : s.id]
}

output "database_subnets" {
    // Use a for expression to create a list of subnet IDs from the aws_subnet.databaseSubnet resource
  value = [for s in aws_subnet.databaseSubnet : s.id]
}
