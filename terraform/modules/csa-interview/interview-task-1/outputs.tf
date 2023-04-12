output "external_ip_adress" {
    value = module.alb_ingress.external_ip
}

output "app_host" {
    value = var.host
}

output "load_balancer"{
    value = module.demo_app_deployment.load_balancer
}