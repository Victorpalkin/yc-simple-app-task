output "load_balancer" {
  value = kubernetes_ingress_v1.ingress.status.0.load_balancer
}
