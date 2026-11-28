{ pkgs, ... }:

# Kubernetes CLIs; kind also needs ./docker.nix. SOPS uses the private age key at
# ~/.config/sops/age/keys.txt.
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

  # Loose reverse-path filtering lets remote pod CIDRs reach CoreDNS across nodes;
  # strict mode drops that traffic as unrouteable.
  networking.firewall.checkReversePath = "loose";
}
