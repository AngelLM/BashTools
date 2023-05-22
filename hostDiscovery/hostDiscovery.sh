#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!] Saliendo...\n"
	tput cnorm; exit 1
}

#Ctrl+C
trap ctrl_c SIGINT
tput civis

for i in $(seq 1 254); do
	timeout 1 bash -c "ping -c 1 102.168.111.$i" &>/dev/null && echo "[+] Host 192.168.111.$i - ACTIVE" &
done

wait

tput cnorm
