{ pkgs, ... }:

# The cluster CLIs, plus `kind`, whose clusters are containers: import
# ./docker.nix alongside this.
{
  environment.systemPackages = with pkgs; [
    kubectl
    helm
    k9s
    kind
  ];
}
