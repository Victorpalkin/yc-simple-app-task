output "labels" {
  value = {
    owner = "palkin"
    environment = lower(var.environment)
    }
}

