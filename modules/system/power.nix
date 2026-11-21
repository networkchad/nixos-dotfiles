# Thermal and power policy for the hosts that are laptops. Each of these three
# lines buys something that is currently done by nobody.
#
# thermald: without it the chip reacts through firmware rules only, and the P-state
# driver leaves nothing to tune from userspace. No configuration needed.
#
# power-profiles-daemon: turns a profile choice into governor + platform-profile
# writes, driven from `powerprofilesctl`. It asserts against TLP and auto-cpufreq,
# so enabling it is also the decision that those two stay out. The profile is
# runtime state -- `powerprofilesctl set performance` before a build, and a rebuild
# changes none of it.
{
  services.thermald.enable = true;

  services.power-profiles-daemon.enable = true;

  # Owns `org.freedesktop.UPower`, which is what a browser asks before it will tell
  # a page there is a battery at all; without it every Chromium start logs
  # `The name is not activatable`. Unrelated to power-profiles-daemon's own
  # `org.freedesktop.UPower.PowerProfiles` interface, which the two share a bus with.
  services.upower.enable = true;
}
