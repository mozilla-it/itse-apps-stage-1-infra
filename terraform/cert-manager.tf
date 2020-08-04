resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      app = "cert-manager"
    }
  }
}

resource "helm_release" "cert_manager" {
  # CRDs have to be installed by hand, there is a drama about it in the community.
  # TL;DR: Helm is not yet ready to upgrade CRDs and this can cause an outage.
  # For more info read https://github.com/helm/helm/issues/7735
  #
  # Manually install CRDs with:
  # kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.crds.yaml
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v0.16.0"
}
