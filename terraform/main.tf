resource "null_resource" "placeholder" {
  triggers = {
    environment = var.environment
  }
}
