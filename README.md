### Links ###
[local k8s cluster with minikube](https://www.linkedin.com/pulse/getting-started-minikube-setting-up-local-kubernetes-cluster-mealy/)
[setup CICD pipeline with Jenkins and Github](https://github.com/mjah/kubernetes-jenkins-cicd-pipeline-example)

### Important Concepts ###

1. **LoadBalancer:** This type of service exposes the service externally using a cloud provider's load balancer. The cloud provider will provision an external IP address and traffic from that IP address will be directed to the service's pods. The service is accessible on the specified `port` at the external IP address.

2. **NodePort:** This type of service exposes the service on each Node's IP at a static port (the NodePort). A `ClusterIP` service, to which the `NodePort` service will route, is automatically created. You'll be able to contact the `NodePort` service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`. 

The main difference is that a `LoadBalancer` service will make use of a load balancer provided by the cloud, and the service can be accessed using the external IP address provided by the cloud provider. On the other hand, a `NodePort` service is accessible on the same port on every node in the cluster, and you need to use the IP address of one of the nodes and the NodePort to access the service.

In general, `LoadBalancer` is often used when you're running your cluster on a cloud provider that provides load balancing, while `NodePort` can be used in any environment.

The `LoadBalancer` service should be enough to expose your services to the internet, provided that your Kubernetes cluster is running in an environment that supports `LoadBalancer` services (like most cloud providers).

When you create a `LoadBalancer` service, Kubernetes will provision an external IP address for that service. Any traffic that comes to that IP address on the specified port will be forwarded to your service.

However, there are a few additional things you might need to consider:

1. **DNS:** You'll probably want to set up DNS records to map a domain name to the external IP address of your service. This makes it easier for users to access your service, as they can use a domain name instead of an IP address.

2. **Ingress Controller:** If you need more advanced routing features (like path-based routing or host-based routing), you might want to use an Ingress controller. An Ingress controller is a type of load balancer that can route traffic to different services based on the request path or host. To use an Ingress controller, you'll need to create an Ingress resource that defines your routing rules.

3. **Firewall Rules:** Depending on your cloud provider or network configuration, you might need to configure firewall rules to allow traffic to reach your service.

4. **TLS/SSL:** If you want to secure your service with HTTPS, you'll need to set up TLS/SSL. This can be done at the Ingress level if you're using an Ingress controller, or at the application level if you're not.

Remember to check the status of your services with `kubectl get services` to ensure they're running and have an external IP address assigned.
