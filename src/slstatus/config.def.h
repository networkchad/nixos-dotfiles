/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms)
 *
 * 1000 because of `datetime` at the bottom of args[]: slstatus has ONE global
 * interval and the clock is the only component that wants a fast one. That is
 * affordable when the shell side is a single run_command (scripts/status.sh,
 * ~10 ms a pass); with one script per segment it was ~70 ms of fork+exec every
 * second, serialized against the clock in the same single-threaded loop. */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*
 * function            description                     argument (example)
 *
 * battery_perc        battery percentage              battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_remaining   battery remaining HH:MM         battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_state       battery charging state          battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * cat                 read arbitrary file             path
 * cpu_freq            cpu frequency in MHz            NULL
 * cpu_perc            cpu usage in percent            NULL
 * datetime            date and time                   format string (%F %T)
 * disk_free           free disk space in GB           mountpoint path (/)
 * disk_perc           disk usage in percent           mountpoint path (/)
 * disk_total          total disk space in GB          mountpoint path (/)
 * disk_used           used disk space in GB           mountpoint path (/)
 * entropy             available entropy               NULL
 * gid                 GID of current user             NULL
 * hostname            hostname                        NULL
 * ipv4                IPv4 address                    interface name (eth0)
 * ipv6                IPv6 address                    interface name (eth0)
 * kernel_release      `uname -r`                      NULL
 * keyboard_indicators caps/num lock indicators        format string (c?n?)
 *                                                     see keyboard_indicators.c
 * keymap              layout (variant) of current     NULL
 *                     keymap
 * load_avg            load average                    NULL
 * netspeed_rx         receive network speed           interface name (wlan0)
 * netspeed_tx         transfer network speed          interface name (wlan0)
 * num_files           number of files in a directory  path
 *                                                     (/home/foo/Inbox/cur)
 * ram_free            free memory in GB               NULL
 * ram_perc            memory usage in percent         NULL
 * ram_total           total memory size in GB         NULL
 * ram_used            used memory in GB               NULL
 * run_command         custom shell command            command (echo foo)
 * swap_free           free swap in GB                 NULL
 * swap_perc           swap usage in percent           NULL
 * swap_total          total swap size in GB           NULL
 * swap_used           used swap in GB                 NULL
 * temp                temperature in degree celsius   sensor file
 *                                                     (/sys/class/thermal/...)
 *                                                     NULL on OpenBSD
 *                                                     thermal zone on FreeBSD
 *                                                     (tz0, tz1, etc.)
 * uid                 UID of current user             NULL
 * up                  interface is running            interface name (eth0)
 * uptime              system uptime                   NULL
 * username            username of current user        NULL
 * vol_perc            OSS/ALSA volume in percent      mixer file (/dev/mixer)
 *                                                     NULL on OpenBSD/FreeBSD
 * wifi_essid          WiFi ESSID                      interface name (wlan0)
 * wifi_perc           WiFi signal in percent          interface name (wlan0)
 */

static const struct arg args[] = {
    /* function     format          argument */
    /* Everything the shell knows: OS, VPN, net, battery, volume. One component,
     * not five -- see the header of scripts/status.sh for the cost and for the
     * ordering rule that comes with it (the shell segments have to stay
     * adjacent; move the two lines below it up here to put CPU/RAM on the left).
     * The script supplies its own separators, so each format string below starts
     * with " | ".
     *
     * Called as a program, not through an extra `sh -c`: slstatus already hands
     * this string to `sh -c`, so the path is the whole command -- which means
     * scripts/status.sh needs its shebang AND its exec bit (git mode 100755). */
    { run_command,    "%s",          "$HOME/.config/slstatus/scripts/status.sh" },
    { cpu_perc,       " | CPU:%s%%", NULL },
    { ram_perc,       " | RAM:%s%%", NULL },
    { datetime,       " | %s",       "%Y-%m-%d %H:%M" },
};
