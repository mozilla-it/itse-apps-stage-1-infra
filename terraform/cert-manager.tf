locals {
  cert_manager_version      = "v0.16.0"
  cert_manager_crd_manifest = "https://github.com/jetstack/cert-manager/releases/download/${local.cert_manager_version}/cert-manager.crds.yaml"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      app = "cert-manager"
    }
  }
}

# CRDs have to be installed differently, there is a drama about it in the community.
# TL;DR: Helm is not yet ready to upgrade CRDs and this can cause an outage.
# For more info read https://github.com/helm/helm/issues/7735
resource "null_resource" "cert_manager_crd" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOF
for i in `seq 1 10`; do \
  echo $kube_config | base64 --decode > kube_config.yaml & \
  kubectl apply --validate=false -f ${local.cert_manager_crd_manifest} --kubeconfig kube_config.yaml && break ||
  sleep 10; \
done; \
rm kube_config.yaml;
EOF
    interpreter = ["/bin/bash", "-c"]
    environment = {
      kube_config = base64encode(module.itse-apps-stage-1.kubeconfig)
    }
  }

  triggers = {
    endpoint = module.itse-apps-stage-1.cluster_endpoint
    version  = local.cert_manager_version
  }

  depends_on = [
    module.itse-apps-stage-1,
    helm_release.cert_manager
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = local.cert_manager_version
}
