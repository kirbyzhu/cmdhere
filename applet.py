#!/usr/bin/env python
# coding:utf-8

import base64
import email.utils
import getopt
import hashlib
import json
import logging
import os
import socket
import struct
import sys
import telnetlib
import time
import urllib2

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)

socket.setdefaulttimeout(30)

def getip(iface=''):
    if not iface:
        sock = socket.socket()
        sock = socket.socket(type=socket.SOCK_DGRAM)
        sock.connect(('8.8.8.8', 53))
        ip = sock.getsockname()[0]
        sock.close()
        return ip
    lines = os.popen('ip -o addr show {}'.format(iface)).read().splitlines()
    for line in lines:
        _, name, network, addr = line.strip().split()[:4]
        if network in (('inet', 'inet6')):
            return addr.split('/')[0]


def getip_from_akamai():
    ip = urllib2.urlopen('http://whatismyip.akamai.com/').read()
    return ip


def getip_from_3322():
    ip = urllib2.urlopen('http://ip.3322.net/').read()
    return ip


def f3322_ddns(username, password, hostname, ip):
    api_url = 'http://members.3322.net/dyndns/update?hostname=%s&myip=%s&wildcard=OFF&offline=NO' % (hostname, ip)
    headers = {'Authorization': 'Basic %s' % base64.b64encode(username+':'+password)}
    resp = urllib2.urlopen(urllib2.Request(api_url, data=None, headers=headers))
    logging.info('f3322_ddns hostname=%r to ip=%r result: %s', hostname, ip, resp.read())


def cx_ddns(api_key, api_secret, domain, ip=''):
    lip = socket.gethostbyname(domain)
    rip = getip_from_akamai()
    if lip == rip:
        logging.info('remote ip and local ip is same to %s, exit.', lip)
        return
    api_url = 'https://www.cloudxns.net/api2/ddns'
    data = json.dumps({'domain': domain, 'ip': ip, 'line_id': '1'})
    date = email.utils.formatdate()
    api_hmac = hashlib.md5(''.join((api_key, api_url, data, date, api_secret))).hexdigest()
    headers = {'API-KEY': api_key, 'API-REQUEST-DATE': date, 'API-HMAC': api_hmac, 'API-FORMAT': 'json'}
    resp = urllib2.urlopen(urllib2.Request(api_url, data=data, headers=headers))
    logging.info('cx_ddns domain=%r to ip=%r result: %s', domain, ip, resp.read())


def cx_update(api_key, api_secret, domain_id, host, ip):
    api_url = 'https://www.cloudxns.net/api2/record/{}'.format(domain_id)
    date = email.utils.formatdate()
    api_hmac = hashlib.md5(''.join((api_key, api_url, date, api_secret))).hexdigest()
    headers = {'API-KEY': api_key, 'API-REQUEST-DATE': date, 'API-HMAC': api_hmac, 'API-FORMAT': 'json'}
    resp = urllib2.urlopen(urllib2.Request(api_url, data=None, headers=headers))
    data = json.loads(resp.read())['data']
    record_id = int((x['record_id'] for x in data if x['type']==('AAAA' if ':' in ip else 'A') and x['host']==host).next())
    logging.info('cx_update query domain_id=%r host=%r to record_id: %r', domain_id, host, record_id)
    api_url = 'https://www.cloudxns.net/api2/record/{}'.format(record_id)
    data = json.dumps({'domain_id': domain_id, 'host': host, 'value': ip})
    date = email.utils.formatdate()
    api_hmac = hashlib.md5(''.join((api_key, api_url, data, date, api_secret))).hexdigest()
    headers = {'API-KEY': api_key, 'API-REQUEST-DATE': date, 'API-HMAC': api_hmac, 'API-FORMAT': 'json'}
    request = urllib2.Request(api_url, data=data, headers=headers)
    request.get_method = lambda: 'PUT'
    resp = urllib2.urlopen(request)
    logging.info('cx_update update domain_id=%r host=%r ip=%r result: %r', domain_id, host, ip, resp.read())
    return


def wol(mac='18:66:DA:17:A2:95', broadcast='192.168.1.255'):
    if len(mac) == 12:
        pass
    elif len(mac) == 12 + 5:
        mac = mac.replace(mac[2], '')
    else:
        raise ValueError('Incorrect MAC address format')
    data = ''.join(['FFFFFFFFFFFF', mac * 20])
    send_data = b''
    # Split up the hex values and pack.
    for i in range(0, len(data), 2):
        send_data = b''.join([send_data, struct.pack('B', int(data[i: i + 2], 16))])
    # Broadcast it to the LAN.
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.sendto(send_data, (broadcast, 7))
    logging.info('wol packet sent to MAC=%r', mac)


def reboot_r6220(ip, password):
    request = urllib2.Request('http://%s/setup.cgi?todo=debug' % ip)
    request.add_header('Authorization', 'Basic %s' % base64.b64encode('admin:%s' % password))
    for _ in xrange(3):
        try:
            resp = urllib2.urlopen(request)
            logging.info('Enable %s debug return: %s', ip, resp.read())
            break
        except Exception as e:
            logging.error('Enable %s debug return: %s', ip, e)
            time.sleep(1)
    else:
        return
    logging.info('Begin telnet %s', ip)
    t = telnetlib.Telnet(ip, port=23, timeout=10)
    t.read_until('login:')
    t.write('root\n')
    resp = t.read_until('#')
    logging.info('telnet r6220 return: %s', resp)
    t.write('reboot\n')
    resp = t.read_until('#')
    logging.info('reboot r6220 return: %s', resp)
    t.close()


def main():
    applet = os.path.basename(sys.argv.pop(0))
    funcs = sorted([v for v in globals().values() if type(v) is type(main) and v is not main])
    if not sys.argv and applet == 'applet.py':
        params = {f.func_name:f.func_code.co_varnames[:f.func_code.co_argcount] for f in funcs}
        print 'Usage: {0} <applet> [arguments]\n\nExamples:\n'.format(applet)
        print '\n'.join('\t{0} {1} {2}'.format(applet, k, ' '.join('--{0} {1}'.format(x.replace('_', '-'), x.upper()) for x in v)) for k, v in params.items())
        return
    if applet == 'applet.py':
        applet = sys.argv.pop(0)
    for f in funcs:
        if f.func_name == applet:
            options = [x.replace('_','-')+'=' for x in f.func_code.co_varnames[:f.func_code.co_argcount]]
            kwargs, _ =  getopt.gnu_getopt(sys.argv, '', options)
            kwargs = {k[2:].replace('-', '_'):v for k, v in kwargs}
            logging.info('main %s(%s)', f.func_name, kwargs)
            result = f(**kwargs)
            if result:
                print result
            return


if __name__ == '__main__':
    main()

