from threading import Timer
import functools
from urllib.parse import urlsplit
import docker
import re
import os
import psutil
import signal
import sys

output_file = sys.argv[1] if len(
    sys.argv) > 1 else os.environ.get("HOST_FILE", "")
if output_file == "":
    print("You must provide an output file or set the HOST_FILE environment variable")
    sys.exit(2)

DOMAIN_LABEL = "caddy"
INTERFACE = "tailscale0"


def is_loopback(ip: str) -> bool:
    return ip in ["localhost", "::1", "0.0.0.0", "::"] or ip.startswith("127.") or ip.startswith("fe80:")


def get_interface_ips(interface: str) -> [str]:
    s = psutil.net_if_addrs()
    if interface not in s:
        return None
    return [i.address for i in s[interface] if not is_loopback(i.address)]


# Find anything that matches `caddy` or `caddy_0`, etc.
label_re = re.compile(r"^%s(_\d+)?$" % re.escape(DOMAIN_LABEL))


def get_contents(client):
    containers = client.containers.list()
    # Note: caddyfiles can contain a protocol and a port, want the hostname
    domains = [
        urlsplit(v).hostname or urlsplit("//" + v).hostname
        for c in containers for k, v in c.labels.items() if re.match(label_re, k)
    ]
    # Exclude anything that's not reachable
    domains[:] = [d for d in domains if not is_loopback(d)]
    if len(domains) == 0:
        print("No domains found in labels", file=sys.stderr)
        return None

    ips = get_interface_ips(INTERFACE)
    if len(ips) == 0:
        print("No IPs found for %s" % INTERFACE, file=sys.stderr)
        return None
    ret = ["%-26s\t%s" % (ip, d) for d in domains for ip in ips]
    return "\n".join(ret)


class InterruptException(Exception):
    pass


def signal_handler(signal, frame) -> None:
    raise InterruptException()


signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)


def debounce(timeout: float):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            wrapper.func.cancel()
            wrapper.func = Timer(timeout, func, args, kwargs)
            wrapper.func.start()

        wrapper.func = Timer(timeout, lambda: None)
        return wrapper
    return decorator


@debounce(5)  # wait 5 seconds before updating
def go(client):
    contents = get_contents(client) or ""
    try:
        with open(output_file, "r") as f:
            current = f.read()
    except FileNotFoundError:
        current = ""
    if contents != current:
        # write all at once to avoid dnsmasq reading partial files
        with open(output_file, "w") as f:
            f.write(contents)
        print("Wrote %s" % output_file, file=sys.stderr)


try:
    client = docker.from_env()
    go(client)  # Seed an initial run
    for event in client.events(decode=True, filters={"type": "container", "event": ["start", "stop", "die"]}):
        go(client)
except InterruptException:
    print("Interrupted, exiting")
