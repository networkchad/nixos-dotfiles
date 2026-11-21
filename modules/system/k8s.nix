{ pkgs, ... }:

# The cluster CLIs, plus `kind`, whose clusters are containers -- import
# ./docker.nix alongside this. sops decrypts the ciphertext the cluster repo
# commits; the private half lives in ~/.config/sops/age/keys.txt.
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    kind
    fluxcd
    sops
    age
  ];
}
