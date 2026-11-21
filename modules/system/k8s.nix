{ pkgs, ... }:

# The cluster CLIs, plus `kind`, whose clusters are containers -- import
# ./docker.nix alongside this.
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    kind
    fluxcd
  ];
}
