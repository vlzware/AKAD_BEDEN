#!/usr/bin/python

# https://github.com/ptef/dhcp-scapy-server

import sys
from scapy.all import *
from datetime import *

if len(sys.argv) != 2:
    print("Primitive DHCP server. It reads its data from " + conffile)
    print("Usage: " + sys.argv[0] + " interface")
    print("")
    sys.exit(1)

conffile="/home/pi/BOX/conf/variables.sh"
tstampfile="/home/pi/BOX/python/timestamp"
mconf={}
conf.ipv6_enabled=False
conf.iface=sys.argv[1]

def parse_packet(p):
    if not (p.haslayer(BOOTP) and p.haslayer(DHCP) and p.haslayer(UDP)):
        return

    with open(conffile) as cfgf:
        variables = cfgf.read()
    exec(variables, mconf)

    with open(tstampfile, 'w') as mf:
        mf.write(datetime.now().strftime("%s"))

    # Ether / IP / UDP / BOOTP / DHCP
    e=Ether(src=mconf['MACEXT'], dst=p[BOOTP].chaddr[:6])
    i=IP(src=mconf['IPEXT'], dst=mconf['IPINT'])
    u=UDP(sport=67, dport=68)
    b=BOOTP(op=2, xid=p[BOOTP].xid, yiaddr=mconf['IPINT'], siaddr=mconf['IPEXT'], chaddr=p[BOOTP].chaddr)
    d=DHCP(options=[ \
            ('message-type','offer'), \
            ('server_id', mconf['IPEXT']), \
            ('lease_time', int(mconf['DHCPLEASE'])), \
            ('subnet_mask', mconf['NMVIRTEXT']), \
            ('router', mconf['IPEXT']), \
            ('name_server', mconf['DHCPDNS']), \
            'end'])

    for op in p[DHCP].options:
        if op[0]=='message-type' and op[1]==1:
            d.options[0]=('message-type', 2) # 2=offer
            sendp(e/i/u/b/d)
            return
        if op[0]=='message-type' and op[1]==3:
            d.options[0]=('message-type', 5) # 5=ack
            sendp(e/i/u/b/d)
            return

sniff(filter='udp src port 68', prn=parse_packet)
