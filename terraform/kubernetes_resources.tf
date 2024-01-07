provider "kubernetes" {
  # Configuration options for the Kubernetes provider...
}

resource "kubernetes_deployment" "ch03frontend" {
  metadata {
    name = "ch03frontend"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "ch03frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "ch03frontend"
        }
      }

      spec {
        container {
          name  = "ch03frontend"
          image = "${var.docker_username}/ch03fe_vote:stable"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ch03frontend_service" {
  metadata {
    name = "ch03frontend-service"
  }

  spec {
    selector = {
      app = "ch03frontend"
    }

    # You need to define the type and ports for the service
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }
  }
}