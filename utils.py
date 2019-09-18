#!/usr/bin/python3

from sys import *
from os.path import *
from netifaces import *
from munch import *
from pprint import *


def net_info():
    net = Munch()
    net.def_if = gateways()['default'][AF_INET][1]
    net.ip = ifaddresses(net.def_if)[AF_INET][0]['addr']
    net.def_mac = ifaddresses(net.def_if)[AF_PACKET][0]['addr']
    return dict(net)


def repeated_gray():
    passed = {}
    for l in stdin:
        l = l.rstrip()
        if l in passed:
            print('\033[37m%s\033[30m' % (l))
        else:
            print(l)
            passed[l] = True


def commonprefix_gray():
    p = ''
    pcl = 0
    for l in stdin:
        l = l.rstrip()
        c = commonprefix([p, l])
        cl = len(c)
        print('\033[37m' + l[:cl] + '\033[30m' + l[cl:])
        if False:
            if cl < pcl:
                print(l)
            else:
                print('\033[37m' + '·' * cl + '\033[30m' + l[cl:])
        p = l
        pcl = cl


if __name__ == "__main__":
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
            pprint(str(ret)) if ret else 0
        if isinstance(ret, type(False)) and ret == False:
            exit(os.EX_CONFIG)
    except KeyboardInterrupt:
        warning("\nInterrupted")
