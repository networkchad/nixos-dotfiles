# Thermal and power policy for the hosts that are laptops. Neither line fixes a
# bug; both replace a thing that is currently being done by nobody.
#
# thermald is Intel's own answer to a package that hits its thermal envelope:
# without it the chip reacts through firmware rules only, and the P-state driver
# leaves nothing to tune from userspace (`scaling_governor` reads `powersave` on
# both boxes and always has). It needs no configuration to be worth having.
#
# power-profiles-daemon owns `net.hadess.PowerProfiles` and turns a profile
# choice into governor + platform-profile writes -- the useful half of what a
# DE's battery slider does, driven from `powerprofilesctl` (the module puts the
# package on the PATH itself). It asserts against TLP and auto-cpufreq, so
# enabling it is also the decision that those two stay out. The profile is
# runtime state, not a setting: `powerprofilesctl set performance` before a
# build, `powerprofilesctl set power-saver` on the train, and a rebuild changes
# none of it.
{
  services.thermald.enable = true;

  services.power-profiles-daemon.enable = true;
}
