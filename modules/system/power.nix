# Laptop thermal and power policy. Power-profiles-daemon conflicts with TLP and
# auto-cpufreq; its selected profile is runtime state that survives rebuilds.
{
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;

  # Battery status for applications; distinct from UPower.PowerProfiles above.
  services.upower.enable = true;
}
