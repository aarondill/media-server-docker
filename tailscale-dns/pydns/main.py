from urllib.parse import urlsplit
import docker
import re
import os
import psutil
import signal
import sys
import time

output_file = sys.argv[1] if len(
    sys.argv) > 1 else os.environ.get("HOST_FILE", "")
if output_file == "":
    print("You must provide an output file or set the HOST_FILE environment variable")
    sys.exit(2)

# TODO: remove polling
interval = sys.argv[2] if len(sys.argv) > 2 else 30

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


def go():
    client = docker.from_env()
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

try:
    while True:
        contents = go() or ""
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
        time.sleep(interval)
except InterruptException:
    print("Interrupted, exiting")
