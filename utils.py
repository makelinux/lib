#!/usr/bin/python3
# -*- coding: utf-8 -*-

from sys import *
from os.path import *
from netifaces import *
from munch import *
from pprint import *
from sys import *
from inspect import *
import inspect
import types
import pyiface
from pyiface.ifreqioctls import IFF_UP, IFF_RUNNING
from collections import defaultdict
from bs4 import BeautifulSoup
import datetime
import signal



def net_info():
    '''
    Gives basic networking info like local IP
    '''
    net = Munch()
    net.interfaces = dict()
    net.def_if = interfaces()[1]
    try:
        net.def_if = gateways()['default'][AF_INET][1]
    except KeyError:
        pass

    try:
        net.ip = ifaddresses(net.def_if)[AF_INET][0]['addr']
        net.def_mac = ifaddresses(net.def_if)[AF_PACKET][0]['addr']
    except KeyError:
        pass

    #s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    #n = s.fileno()
    #ifr = ifreq()
    #ifr.ifr_ifrn = "lo".encode('utf-8')
    #fcntl.ioctl(n, SIOCGIFFLAGS, ifr);
    #print("SIOCGIFFLAGS", ifr.ifr_flags);
    net.ifs = " ".join(interfaces())
    for i in interfaces():
            ifd = Munch()
            flags = pyiface.Interface(name=i).flags
            #net.flags = defaultdict(lambda: Munch())
            if flags & IFF_UP > 0:
                ifd.flags = "U" 
            if flags & IFF_RUNNING > 0:
                ifd.flags += "R"
            try:
                ifd.addr= ifaddresses(i)[AF_INET][0]['addr']
            except KeyError:
                pass
            net.interfaces[i] = dict(ifd)
    return dict(net)


def repeated_gray():
    '''
    Filters input text and prints in gray color lines which was already before
    '''
    passed = {}
    for l in stdin:
        l = l.rstrip()
        if l in passed:
            print('\033[37m%s\033[30m' % (l))
        else:
            print(l)
            passed[l] = True

def info_gray():
    '''
    Filters input text and prints in gray color info lines
    '''
    passed = {}
    for l in stdin:
        l = l.rstrip()
        e = l.find('=ERR=')
        if e != -1:
            print(l[:e] + '\033[1;38m=ERR=\033[0m' + l[e+5:])
        elif 'INFO' in l:
            print('\033[2;30m%s\033[0m' % (l))
        else:
            print(l)



def commonprefix_gray():
    '''
    Filters input text and prints in gray color start of current line which is same like previous
    '''
    p = ''
    pcl = 0
    for l in stdin:
        l = l.rstrip()
        c = commonprefix([p, l])
        cl = len(c)
        print('\033[2;36m' + l[:cl] + '\033[0;30m' + l[cl:])
        if False:
            if cl < pcl:
                print(l)
            else:
                print('\033[37m' + '·' * cl + '\033[30m' + l[cl:])
        p = l
        pcl = cl

if __name__ == "__main__":
    def handler(signum, frame):
        exit(0)

    signal.signal(signal.SIGHUP, handler)
    try:
        ret = 0
        if len(argv) > 1:
            a1 = argv[1]
            argv = argv[1:]
            if '(' in a1:
                ret = eval(a1)
            else:
                ret = eval(a1 + '(' + ', '.join("'%s'" % (a)
                                                for a in argv[1:]) + ')')
            pprint(ret) if ret else 0
        else:
            for m in getmembers(modules[__name__]):
                if isfunction(m[1]) and m[1].__module__ == __name__:
                    help(m[1])
        if isinstance(ret, type(False)) and ret == False:
            exit(os.EX_CONFIG)
    except KeyboardInterrupt:
        warning("\nInterrupted")
