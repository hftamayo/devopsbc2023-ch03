### Links ###
- [local k8s cluster with minikube](https://www.linkedin.com/pulse/getting-started-minikube-setting-up-local-kubernetes-cluster-mealy/)
- [setup CICD pipeline with Jenkins and Github](https://github.com/mjah/kubernetes-jenkins-cicd-pipeline-example)
- [install and setup k8s cluster with kubeadm in Debian](https://www.linuxtechi.com/install-kubernetes-cluster-on-debian/)
- [Installation and setup of Minikube on Debian](https://techviewleo.com/install-minikube-kubernetes-on-debian/)
- [Installation of MicroK8S y k0s on Debian](https://techviewleo.com/microk8s-and-k0s-kubernetes-installation-on-debian/)

### Important Concepts ###

#### Related to K8S manifestos ####

1. **LoadBalancer:** This type of service exposes the service externally using a cloud provider's load balancer. The cloud provider will provision an external IP address and traffic from that IP address will be directed to the service's pods. The service is accessible on the specified `port` at the external IP address.

2. **NodePort:** This type of service exposes the service on each Node's IP at a static port (the NodePort). A `ClusterIP` service, to which the `NodePort` service will route, is automatically created. You'll be able to contact the `NodePort` service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`. 

The main difference is that a `LoadBalancer` service will make use of a load balancer provided by the cloud, and the service can be accessed using the external IP address provided by the cloud provider. On the other hand, a `NodePort` service is accessible on the same port on every node in the cluster, and you need to use the IP address of one of the nodes and the NodePort to access the service.

In general, `LoadBalancer` is often used when you're running your cluster on a cloud provider that provides load balancing, while `NodePort` can be used in any environment.

The `LoadBalancer` service should be enough to expose your services to the internet, provided that your Kubernetes cluster is running in an environment that supports `LoadBalancer` services (like most cloud providers).

When you create a `LoadBalancer` service, Kubernetes will provision an external IP address for that service. Any traffic that comes to that IP address on the specified port will be forwarded to your service.

However, there are a few additional things you might need to consider:

3. **DNS:** You'll probably want to set up DNS records to map a domain name to the external IP address of your service. This makes it easier for users to access your service, as they can use a domain name instead of an IP address.

4. **Ingress Controller:** If you need more advanced routing features (like path-based routing or host-based routing), you might want to use an Ingress controller. An Ingress controller is a type of load balancer that can route traffic to different services based on the request path or host. To use an Ingress controller, you'll need to create an Ingress resource that defines your routing rules.

5. **Firewall Rules:** Depending on your cloud provider or network configuration, you might need to configure firewall rules to allow traffic to reach your service.

6. **TLS/SSL:** If you want to secure your service with HTTPS, you'll need to set up TLS/SSL. This can be done at the Ingress level if you're using an Ingress controller, or at the application level if you're not.

Remember to check the status of your services with `kubectl get services` to ensure they're running and have an external IP address assigned.

#### Related to K8S Infrastructure ####

Helm and Minikube serve different purposes in the Kubernetes ecosystem:

1. **Minikube:** Minikube is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster on your personal computer (including Windows, macOS, and Linux PCs) so you can try out Kubernetes, or develop with it day-to-day.

2. **Helm:** Helm is a package manager for Kubernetes. It allows developers and operators to more easily package, configure, and deploy applications and services onto Kubernetes clusters. Helm is like the `apt` or `yum` of Kubernetes as it uses a packaging format called charts, which are a collection of files that describe a related set of Kubernetes resources.

In summary, Minikube is used to create a local, single-node Kubernetes cluster for development and testing, while Helm is used to simplify the deployment of applications on any Kubernetes cluster.

If you have a test environment that can support more than a single Kubernetes node, there are several alternatives to Minikube you can consider:

1. **Kubeadm:** Kubeadm is a tool built to provide `kubeadm init` and `kubeadm join` as best-practice "fast paths" for creating Kubernetes clusters. It's a good choice if you want more control over your cluster setup and configuration.

2. **Kops:** Kops helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters from the command line. It's a good choice for AWS environments, but also supports other cloud providers.

3. **Rancher:** Rancher is an open source platform for managing Kubernetes at scale. It provides a user-friendly interface for managing clusters, making it a good choice if you prefer a GUI over command-line management.

4. **Kind (Kubernetes in Docker):** Kind is a tool for running local Kubernetes clusters using Docker container "nodes". It's primarily designed for testing Kubernetes itself, but may be used for local development or CI.

5. **MicroK8s:** MicroK8s is a lightweight, pure-upstream Kubernetes that delivers the essentials to run Kubernetes clusters in a variety of environments (workstations, edge / IoT, CI/CD). It's a good choice for Linux environments and has a small footprint.

6. **K3s:** K3s is a lightweight Kubernetes distribution by Rancher, designed for edge and IoT use cases, but also suitable for testing environments and small clusters.

Remember to choose the tool that best fits your specific needs and environment.

