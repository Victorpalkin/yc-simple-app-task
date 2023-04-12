output "k8s_rendered_yaml" {
    value = module.interview-task-1.k8s_rendered_yaml
    sensitive = true
}

output "app_host" {
    value = module.interview-task-1.app_host
}