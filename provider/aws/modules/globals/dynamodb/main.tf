locals {
  private_links_table_global_secondary_indices = [
    {
      name: "EndpointId",
      type: "S"
    },
    {
      name: "OrgId",
      type: "S"
    },
    {
      name: "AwsAccountId",
      type: "S"
    },
    {
      name: "Domain",
      type: "S"
    },
    {
      name: "State",
      type: "S"
    }
  ]
}