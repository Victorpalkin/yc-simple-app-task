output "k8s_rendered_yaml" {
    value = data.template_file.k8s.rendered
}

output "external_ip_adress" {
    value = module.alb_ingress.external_ip
}

output "app_host" {
    value = var.domain
}

output "load_balancer"{
    value = module.demo_app_deployment.load_balancer
}