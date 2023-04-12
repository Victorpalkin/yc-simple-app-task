output "cluster_id" {
  value = yandex_kubernetes_cluster.k8s_regional.id
}

output "cluster_name" {
    value = yandex_kubernetes_cluster.k8s_regional.name
}

output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.k8s_regional.master[0].external_v4_endpoint
}

output "ca_certificate" {
  value = yandex_kubernetes_cluster.k8s_regional.master[0].cluster_ca_certificate
}

output "cluster_service_account_id" {
  value = yandex_iam_service_account.myaccount.id
}

output "cluster_security_group_id" {
  value = yandex_vpc_security_group.k8s_main_sg.id
}

output "kubectl_config_map" {
  value = "~/.kube/config"
}