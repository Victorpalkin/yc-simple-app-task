terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

resource "kubernetes_namespace" "space" {
  metadata {
    name = var.namespace
  }
}

# resource "kubernetes_config_map" "demo_app_1" {
#   metadata {
#     name = "alb-demo-1"
#     namespace = kubernetes_namespace.space.metadata.0.name
#   }

#   data = {
#     "nginx.conf" = <<-EOT
#     worker_processes auto;
#     events {
#     }
#     http {
#       server {
#         listen 80 ;
#         location = /_healthz {
#           add_header Content-Type text/plain;
#           return 200 'ok';
#         }
#         location / {
#           add_header Content-Type text/plain;
#           return 200 'Index';
#         }
#         location = /app1 {
#           add_header Content-Type text/plain;
#           return 200 'This is APP#1';
#         }
#       }
#     }
#   EOT
#   }
# }


resource "kubernetes_deployment" "demo_app_1" {
  metadata {
    name      = "alb-demo-1"
    namespace = kubernetes_namespace.space.metadata.0.name
    labels = {
        app = "alb-demo-1"
        version = "v1"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "alb-demo-1"
      }
    }
    strategy {
        type = "RollingUpdate"
        rolling_update {
          max_surge = 2
          max_unavailable = 1
        }
    }
    template {
      metadata {
        labels = {
          app = "alb-demo-1"
          version = "v1"
        }
      }
      spec {
        termination_grace_period_seconds = 5
        # volume {
        #   name = "alb-demo-1"
        #   config_map {
        #     name = "alb-demo-1"
        #   }
        # }
        container {
          image = "cr.yandex/${var.container_registry_id}/demo-app-1:v1"
          name  = "alb-demo-1"
          port {
            name = "http"
            container_port = 80
          }
          liveness_probe {
            http_get {
              path = "/_healthz"
              port = 80
            }
            initial_delay_seconds = 3
            timeout_seconds = 2
            failure_threshold = 2
          }
          # volume_mount {
          #   name = "alb-demo-1"
          #   mount_path = "/etc/nginx"
          #   read_only = true
          # }
          resources {
            limits = {
                cpu = "250m"
                memory = "128Mi"
            }
            requests = {
                cpu = "100m"
                memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_app_1" {
  metadata {
    name      = "alb-demo-1"
    namespace = kubernetes_namespace.space.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.demo_app_1.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      name = "http"
      node_port   = 30081
      port        = 80
      target_port = 80
      protocol = "TCP"
    }
  }
}

# resource "kubernetes_config_map" "demo_app_2" {
#   metadata {
#     namespace = kubernetes_namespace.space.metadata.0.name
#     name = "alb-demo-2"
#   }

#   data = {
#     "nginx.conf" = <<-EOT
#     worker_processes auto;
#     events {
#     }
#     http {
#       server {
#         listen 80 ;
#         location = /_healthz {
#           add_header Content-Type text/plain;
#           return 200 'ok';
#         }
#         location / {
#           add_header Content-Type text/plain;
#           return 200 'Add app#';
#         }
#         location = /app2 {
#           add_header Content-Type text/plain;
#           return 200 'This is APP#2';
#         }
#       }
#     }
#   EOT
#   }
# }

resource "kubernetes_deployment" "demo_app_2" {
  metadata {
    name      = "alb-demo-2"
    namespace = kubernetes_namespace.space.metadata.0.name
    labels = {
        app = "alb-demo-2"
        version = "v1"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "alb-demo-2"
      }
    }
    strategy {
        type = "RollingUpdate"
        rolling_update {
          max_surge = 2
          max_unavailable = 1
        }
    }
    template {
      metadata {
        labels = {
          app = "alb-demo-2"
          version = "v1"
        }
      }
      spec {
        termination_grace_period_seconds = 5
        # volume {
        #   name = "alb-demo-2"
        #   config_map {
        #     name = "alb-demo-2"
        #   }
        # }
        container {
          image = "cr.yandex/${var.container_registry_id}/demo-app-2:v1"
          name  = "alb-demo-2"
          port {
            name = "http"
            container_port = 80
          }
          liveness_probe {
            http_get {
              path = "/_healthz"
              port = 80
            }
            initial_delay_seconds = 3
            timeout_seconds = 2
            failure_threshold = 2
          }
          # volume_mount {
          #   name = "alb-demo-2"
          #   mount_path = "/etc/nginx"
          #   read_only = true
          # }
          resources {
            limits = {
                cpu = "250m"
                memory = "128Mi"
            }
            requests = {
                cpu = "100m"
                memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_app_2" {
  metadata {
    name      = "alb-demo-2"
    namespace = kubernetes_namespace.space.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.demo_app_2.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      name = "http"
      node_port   = 30082
      port        = 80
      target_port = 80
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "alb-demo"
    namespace = kubernetes_namespace.space.metadata.0.name
    annotations = {
      "ingress.alb.yc.io/subnets" = var.subnet_ids
      "ingress.alb.yc.io/security-groups" = var.security_group_ids
      "ingress.alb.yc.io/external-ipv4-address" = var.external_ip_adress
      "ingress.alb.yc.io/group-name" = "demo"
    }
  }
  spec {
    tls {
      hosts = [ var.host ]
      secret_name = "yc-certmgr-cert-id-${var.certificate_id}"
    }
    rule {
      host = var.host
      http {
        path {
          path = "/app1"
          path_type = "Prefix"
          backend {
            service {
              name = "alb-demo-1"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path = "/app2"
          path_type = "Prefix"
          backend {
            service {
              name = "alb-demo-2"
              port {
                number = 80
              }
            }
          }          
        }
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "alb-demo-2"
              port {
                number = 80
              }
            }
          }          
        }
      }
    }
  }
}
