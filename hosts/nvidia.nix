{
  # PRIME offload, shared by every NVIDIA host. A host sets only its driver
  # generation: `open = true` for Turing and newer, otherwise a pinned
  # `package` (the open modules do not support pre-Turing GPUs).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      # The iGPU drives the session; `nvidia-offload <cmd>` puts one program on
      # the dGPU. These lspci bus ids happen to be identical on both hosts.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Lets the containers docker starts reach the GPU.
  hardware.nvidia-container-toolkit.enable = true;
}
