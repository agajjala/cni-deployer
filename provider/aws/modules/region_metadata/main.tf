locals {
  az_ids = split(",", data.external.az_ids.result.az_ids)
}
