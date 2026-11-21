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

  # Nodes hand each other pod traffic sourced from the pod CIDR, which this host has no
  # route to, and strict reverse-path filtering drops that: pods on one node never reach
  # CoreDNS on another, so flux can't even resolve github.com. Loose is still a filter.
  networking.firewall.checkReversePath = "loose";
}
