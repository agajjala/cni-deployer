data external az_ids {
  program = ["python", "${path.module}/../scripts/az_ids.py"]

  query = {
    region = var.region
  }
}
