# Thermal and power policy for the hosts that are laptops. Two of these three
# lines replace something that is currently being done by nobody; the third stops
# an error every browser start logs.
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

  # upower owns `org.freedesktop.UPower` -- battery and uptime information, which
  # is what a browser asks before it will tell a page there is a battery at all.
  # Nothing here enabled it, so the name is not activatable and every Chromium
  # start logs `Failed to call method ... /org/freedesktop/UPower/devices/
  # DisplayDevice: The name is not activatable`. `busctl` makes this easy to
  # misread: the `org.freedesktop.UPower.PowerProfiles` that IS on the bus is
  # power-profiles-daemon's own, differently shaped interface, not upower. The two
  # coexist -- that is the GNOME combination -- and PPD only asserts against TLP
  # and auto-cpufreq, not against upower.
  services.upower.enable = true;
}
