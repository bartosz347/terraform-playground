resource "kubernetes_deployment" "demo_app" {
  metadata {
    name = "demo-app"
    labels = {
      test = "DemoApp"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "DemoApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "DemoApp"
        }
      }

      spec {
        container {
          #          image = "nginx:1.21.6"
          image = "gcr.io/google-samples/hello-app:1.0"
          name  = "example"
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_app_svc" {
  metadata {
    name = "myapp-1"
  }
  spec {
    selector = {
      test = kubernetes_deployment.demo_app.metadata.0.labels.test
    }
    port {
      port = 8080
      #      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "demo_app_ingress" {
  metadata {
    name = "demo-app-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.demo_app_svc.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    rule {
      host = "xyz.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.demo_app_svc.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
