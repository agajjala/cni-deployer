variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable table_name {
  description = "Name of the table"
  type        = string
}
variable read_capacity {
  description = "The number of read units for the table"
  type        = number
  default     = 20
}
variable write_capacity {
  description = "The number of write units for the table"
  type        = number
  default     = 20
}
