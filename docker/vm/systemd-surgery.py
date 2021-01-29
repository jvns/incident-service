import glob
import os
keep = [
        'ssh.service',
        'systemd-user-sessions.service',
        'systemd-remount-fs.service',
        'sys-kernel-config.mount',
        'systemd-journald.service',
        'sys-kernel-debug.mount',
        'sys-kernel-tracing.mount',
#        'dbus.service', # for systemd analyze i guess
]
targets = ['getty', 'multi-user', 'sockets', 'timers', 'sysinit', 'default']

for t in targets:
    for filename in glob.glob(f"/etc/systemd/system/{t}.target.wants/*"):
        if os.path.basename(filename) in keep:
            continue
        print(filename)
        os.remove(filename)
    for filename in glob.glob(f"/usr/lib/systemd/system/{t}.target.wants/*"):
        if os.path.basename(filename) in keep:
            continue
        print(filename)
        os.remove(filename)
