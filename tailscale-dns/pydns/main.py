import docker
import sys
import os
import time
import psutil
import socket

output_file = sys.argv[1] if len(
    sys.argv) > 1 else os.environ.get("HOST_FILE", "")
if output_file == "":
    print("You must provide an output file or set the HOST_FILE environment variable")
    sys.exit(2)

# TODO: remove polling
interval = sys.argv[2] if len(sys.argv) > 2 else 30

DOMAIN_LABEL = "caddy"
INTERFACE = "tailscale0"


def ip_is_loopback(ip: str) -> bool:
    return ip.startswith("127.") or ip.startswith("0.") or ip == "::1" or ip == "::" or ip.startswith("fe80:")


def get_interface_ips(interface: str) -> [str]:
    s = psutil.net_if_addrs()
    if interface not in s:
        return None
    return [i.address for i in s[interface] if not ip_is_loopback(i.address)]


def go():
    client = docker.from_env()
    containers = [c for c in client.containers.list()
                  if c.labels.get(DOMAIN_LABEL)]
    if len(containers) == 0:
        print("No containers found with label %s" %
              DOMAIN_LABEL, file=sys.stderr)
        return None
    ips = get_interface_ips(INTERFACE)
    if len(ips) == 0:
        print("No IPs found for %s" % INTERFACE, file=sys.stderr)
        return None
    ret = []
    for c in containers:
        domain = c.labels[DOMAIN_LABEL]
        for ip in ips:
            ret.append("%-26s\t%s" % (ip, domain))
    return "\n".join(ret)


while True:
    # write even if it returns 1, since this means we don't want any entries
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
