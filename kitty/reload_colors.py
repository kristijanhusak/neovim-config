import os
import signal
from typing import (Iterable, List)

def reload_all_kitty_terminals():
    for pid in get_all_processes():
        try:
            cmd = cmdline_of_pid(pid)
        except Exception:
            continue
        if cmd and is_kitty_gui_cmdline(*cmd):
            os.kill(pid, signal.SIGUSR1)

def is_kitty_gui_cmdline(*cmd: str) -> bool:
    if not cmd:
        return False
    if os.path.basename(cmd[0]) != 'kitty':
        return False
    if len(cmd) == 1:
        return True
    s = cmd[1][:1]
    if s == '@':
        return False
    if s == '+':
        if cmd[1] == '+':
            return len(cmd) > 2 and cmd[2] == 'open'
        return cmd[1] == '+open'
    return True

def get_all_processes() -> Iterable[int]:
    for c in os.listdir('/proc'):
        if c.isdigit():
            yield int(c)

def cmdline_of_pid(pid: int) -> List[str]:
    with open(f'/proc/{pid}/cmdline', 'rb') as f:
        return list(filter(None, f.read().decode('utf-8').split('\0')))

reload_all_kitty_terminals()
