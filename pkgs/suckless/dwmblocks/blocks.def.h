//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
    /*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/os.sh\"",        20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/cpu.sh\"",       20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/ram.sh\"",       20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/vpn.sh\"",       20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/internet.sh\"",  20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/battery.sh\"",   20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/volume.sh\"",    20,            0},
    {"", "sh -c \"$HOME/nixos-dotfiles/pkgs/suckless/dwmblocks/scripts/clock.sh\"",     20,            0},
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " | ";
static unsigned int delimLen = 5;

