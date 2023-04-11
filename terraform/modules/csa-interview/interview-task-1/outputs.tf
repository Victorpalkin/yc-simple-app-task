output "k8s_rendered_yaml" {
    value = data.template_file.k8s.rendered
}