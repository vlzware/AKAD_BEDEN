#!/usr/bin/env bash

######################################################
#
# TODO: Write a header here...
#
######################################################

if [ "$(whoami)" != "root" ]; then
    >&2 echo -e "ERROR: Run this as root!"
    exit 1
fi

# usefull when debugging (from http://wiki.bash-hackers.org/scripting/debuggingtips)
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# fixed network data
. /home/pi/BOX/conf/constants.sh

# colorizing output (the colors may vary between terminals)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# prefix in the log file
TIMESTAMP="date +%F_%T"
LOGFILE="/home/pi/BOX/logs/log"
# uncomment if you like separate log files:
#LOGFILE="/home/pi/BOX/logs/log_$(date +%F_%H%M%S)"
ERRMSG="${RED}ERROR${RESET}" # for grep-ing the log

# internal variables
COUNT="100"                                     # number of packets to gather
IFACEA=""                                       # first network interface
IFACEB=""                                       # second network interface
IFACE=""                                        # interface to listen on
MACINT=""                                       # internal device's MAC
MACEXT=""                                       # external device's MAC
IPINT=""                                        # IP of the internal device
IPEXT=""                                        # IP of the external device
IFACEINT=""                                     # interface facing the internal net
IFACEEXT=""                                     # interface facing the external net

NFTVARSFILE="/home/pi/BOX/conf/variables.nft"   # to be read with nft
SHVARSFILE="/home/pi/BOX/conf/variables.sh"     # to be read from bash
STATEFILE="/home/pi/BOX/state"                  # save the current state here
MACSFILE="/home/pi/BOX/conf/MACs_default.sh"    # original MACs
NFTNS0="/home/pi/BOX/rulesets/ns0.nft"          # nftables rulesets
NFTDEFAULT="/home/pi/BOX/rulesets/nsdefault.nft"
DUMPFILE="dump"                                 # tmp files
ARPREPLY="arpreply"
DHCPSERVER="/home/pi/BOX/python/DHCPS.py"       # DHCP "server"
DHCPDUMP="/home/pi/BOX/dhcp.pcap"               # raw DHCP data (for debugging)
DHCPDATA="/home/pi/BOX/conf/dhcp_vars.sh"       # parsed DHCP data
DHCPTSFILE="/home/pi/BOX/python/timestamp"      # timestamp: last checked for new data (dhcp)
DHCPTS="0"                                      # to be compared with DHCPTSFILE

# see 'parse_dhcp_data'
NMVIRTEXT=""                                    # netmask external facing iface
DHCPLEASE=""                                    # DHCP lease time
DHCPDNS=""                                      # DHCP name server
DHCPHOST="Linksys"                              # hostname of the client (to be copied by us)

STATEBRIDGE="bridge"
STATEWORKING="working"
STATEERROR="error"
echo "${STATEBRIDGE}" > "${STATEFILE}"          # default state is bridge mode

# GPIO stuff
LEDREADY=17
LEDBRIDGE=18
LEDWORKING=27
LEDERROR=22
GPIOSWITCH=23
# simple blink
SCRIPTBLINK1="tag 123 w ${LEDWORKING} 1 mils 500 w ${LEDWORKING} 0 mils 500 jmp 123"
# long | short blink
SCRIPTBLINK2="tag 123 w ${LEDWORKING} 1 mils 500 w ${LEDWORKING} 0 mils 500 \
                      w ${LEDWORKING} 1 mils 100 w ${LEDWORKING} 0 mils 100 jmp 123"
# long | short | short | short
SCRIPTBLINK3="tag 123 w ${LEDWORKING} 1 mils 500 w ${LEDWORKING} 0 mils 500 \
                      w ${LEDWORKING} 1 mils 100 w ${LEDWORKING} 0 mils 100 \
                      w ${LEDWORKING} 1 mils 100 w ${LEDWORKING} 0 mils 100 jmp 123"
# quick blink
SCRIPTBLINK4="tag 123 w ${LEDWORKING} 1 mils 100 w ${LEDWORKING} 0 mils 100 jmp 123"
SCRIPTBLINK1ID=0
SCRIPTBLINK2ID=0
SCRIPTBLINK3ID=0
SCRIPTBLINK4ID=0
SCRIPTMAXID=31                                  # the max possible script-id on raspi 32

# available commands
CMDBRIDGE="bridge"
CMDPARSE="parsenet"
CMDFULLON="fullmode"
CMDONBOOT="onboot"
CMDHELP="help"

# paths
NFT="/usr/sbin/nft"
DHCPCLIENT="/usr/sbin/dhcpcd" # "dhclient" in Pi does not support "-H"

######################################################
#
# Helper functions
#
######################################################

# logs data to a file
function log() {
    echo -e "${GREEN}$(${TIMESTAMP})${RESET} ${1}" >> "${LOGFILE}"
    #echo -e "${GREEN}$(${TIMESTAMP})${RESET} ${1}"
}

# set default LED state
function resetled() {
    pigs procs "${SCRIPTBLINK1ID}"
    pigs procs "${SCRIPTBLINK2ID}"
    pigs procs "${SCRIPTBLINK3ID}"
    pigs procs "${SCRIPTBLINK4ID}"
    pigs w "${LEDREADY}" 1 # even on error the box is still on
    pigs w "${LEDBRIDGE}" 0
    pigs w "${LEDWORKING}" 0
    pigs w "${LEDERROR}" 0
}

function error() {
    log "${ERRMSG} ${1}"
    >&2 echo "${RED}${1}${RESET}"
    resetled
    pigs w "${LEDERROR}" 1
    echo "${STATEERROR}" > "${STATEFILE}"
}

function stop_dhcp() {
    log "Stopping DHCP server (internal net) ..."
    killall $(basename "${DHCPSERVER}")
    log "Stopping DHCP client (external net) ..."
    killall $(basename "${DHCPCLIENT}")
}

function start_dhcp() {
    parse_dhcp_data
    log "Starting DHCP server (internal net) ..."
    ip netns exec ns0 "${DHCPSERVER}" "${IFACEINT}" &
    log "Starting DHCP client (external net) ..."
    "${DHCPCLIENT}" -b -h "${DHCPHOST}" "${IFACEEXT}" #for dhclient: "${DHCPCLIENT}" -nw -i "${IFACEEXT}"
}

function setup_GPIO() {
    log "Setting up GPIO ..."
    # clear all previous scripts
    for ((i=0; i<=SCRIPTMAXID; i++)); do
        pigs procd "${i}" > /dev/null 2>&1
    done
    # save the pigs-scripts
    SCRIPTBLINK1ID=$(pigs proc ${SCRIPTBLINK1})
    SCRIPTBLINK2ID=$(pigs proc ${SCRIPTBLINK2})
    SCRIPTBLINK3ID=$(pigs proc ${SCRIPTBLINK3})
    SCRIPTBLINK4ID=$(pigs proc ${SCRIPTBLINK4})

    # set INPUT/OUTPUT mode on the GPIO-pins
    pigs m "${LEDREADY}" w
    pigs m "${LEDBRIDGE}" w
    pigs m "${LEDWORKING}" w
    pigs m "${LEDERROR}" w

    pigs m "${GPIOSWITCH}" r
    pigs pud "${GPIOSWITCH}" u # activate internal pull-up

    resetled
    log "GPIO setup done."
}

function show_usage() {
    echo "Usage: [sudo] $0 command"
    echo
    echo "Available commands:"
    printf "\t${GREEN}%-15s${RESET} sets the box in bridge mode; single run\n" "${CMDBRIDGE}"
    printf "\t${GREEN}%-15s${RESET} tries to guess the network settings (this should be run from bridge mode); single run\n" "${CMDPARSE}"
    printf "\t${GREEN}%-15s${RESET} sets the IPs, MACs, routes and firewall rules for full operational mode; single run\n" "${CMDFULLON}"
    printf "\t${GREEN}%-15s${RESET} endless loop of 'fullmode' with additional saving of the original MACs\n" "${CMDONBOOT}"
    printf "\t${GREEN}%-15s${RESET} prints this message\n" "${CMDHELP}"
    echo
}

function find_net_devices() {
    IFACES=$(ip -br l | grep -v "lo\|wl" | cut -d ' ' -f 1)
    IFACESCNT=$(echo "${IFACES}" | wc -l)
    if [[ "${IFACESCNT}" -lt 2 ]]; then
        error "Can't find enough network interfaces!"
        return 1
    fi
    IFACEA=$(echo ${IFACES} | cut -d ' ' -f 1)
    IFACEB=$(echo ${IFACES} | cut -d ' ' -f 2)

    IFACE="${IFACEA}" # doesn't matter if A or B, as we are bridging at this point
    log "Found ${IFACESCNT} ethernet devices. Using ${IFACEA} and ${IFACEB}. Tcpdump will run on ${IFACE}."
}

save_network_data() {
    log "Saving all the network data ..."
    cat <<EOF  > "${NFTVARSFILE}"
define IFACEINT = "${IFACEINT}"
define IFACEEXT = "${IFACEEXT}"
define IPINT = "${IPINT}"
define IPEXT = "${IPEXT}"
EOF

    cat <<EOF > "${SHVARSFILE}"
MACINT="${MACINT}"
MACEXT="${MACEXT}"
IPINT="${IPINT}"
IPEXT="${IPEXT}"
IFACEINT="${IFACEINT}"
IFACEEXT="${IFACEEXT}"
NMVIRTEXT="${NMVIRTEXT}"
DHCPDNS="${DHCPDNS}"
DHCPLEASE="${DHCPLEASE}"
EOF
}

update_hostname() {
    TMP=$(hostname)
    if [[ "${DHCPHOST}" == "${TMP}" ]]; then
        return
    fi
    hostnamectl set-hostname "${DHCPHOST}"
    sed -i "s|$TMP|$DHCPHOST|g" /etc/hosts
    echo "${DHCPHOST}" > /etc/hostname
    hostname "${DHCPHOST}"
}

parse_dhcp_data() {
    log "Checking for DHCP data ..."
    if [ -f "${DHCPDATA}" ]; then
        # load the last DNS ACK overwriting some variables
        . "${DHCPDATA}"
        if [ -z "${NMVIRTEXT}" ]; then
            NMVIRTEXT="255.255.255.0"
        fi
        if [ -z "${DHCPDNS}" ]; then
            DHCPDNS="${IPEXT}"
        fi
        if [ -z "${DHCPLEASE}" ]; then
            DHCPLEASE="1000"
        fi
        if [ -z "${DHCPHOST}" ]; then
            DHCPHOST="Linksys"
        fi
        #update_hostname # it seems that "dhclient -H" is sufficient
        log "DHCP data found. Updated following values:\n$(cat ${DHCPDATA})"
    else
        # set some sane(?) default values
        log "No DHCP data found. Using default values."
        NMVIRTEXT="255.255.255.0"
        DHCPDNS="${IPEXT}"
        DHCPLEASE="1000"
        DHCPHOST="Linksys"
    fi
    save_network_data
}

######################################################
#
# set_bridge: Setup a bridge
#
######################################################
function set_bridge() {
    log "${YELLOW}Setting up a bridge ...${RESET}"
    stop_dhcp

    # enable ip forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward

    # clear all nftables rules
    "${NFT}" flush ruleset

    # this deletes both the veth devices
    # it also "frees" "${IFACEINT}" but is too slow so we do it manually
    ip netns exec ns0 ip link set "${IFACEA}" netns 1 2>/dev/null
    ip netns exec ns0 ip link set "${IFACEB}" netns 1 2>/dev/null
    ip link del veth1 2>/dev/null
    ip netns delete ns0 2>/dev/null

    ip link set dev "${IFACEA}" nomaster
    ip link set dev "${IFACEB}" nomaster
    ip link del br0 2>/dev/null
    ip link set dev "${IFACEA}" down
    ip link set dev "${IFACEB}" down
    ip address flush dev "${IFACEA}"
    ip address flush dev "${IFACEB}"
    # restore MACs
    while IFS= read -r line; do
        I=$(echo "${line}" | cut -d ' ' -f 1)
        M=$(echo "${line}" | cut -d ' ' -f 2)
        ip link set dev "${I}" addr "${M}"
    done < "${MACSFILE}"

    # create a virtual bridge
    ip link add name br0 type bridge
    ip link set dev br0 up

    # add both network interfaces to the bridge
    ip link set dev "${IFACEA}" master br0
    ip link set dev "${IFACEB}" master br0

    ip link set dev "${IFACEA}" up
    ip link set dev "${IFACEB}" up

    pigs w "${LEDBRIDGE}" 1
    pigs w "${LEDWORKING}" 0
    log "${YELLOW}Bridge setup finished.${RESET}"
}

######################################################
#
# parse_network_data:
# Figure which device is which, also what IPs and MACs
# are being used on the network.Try to guess which is
# which.
#
######################################################
# TODO: use forking to run on both interfaces at the same time (speedup!)
function parse_network_data() {
    log "${YELLOW}Network parsing started ...${RESET}"
    log "Collecting raw data ..."
    resetled
    pigs procr "${SCRIPTBLINK1ID}" # start blink mode 1

    # collect raw data
    # expected data format:
    # MACAddressA > MACAddressB, length xxx: IPAddress.Port > IPAddrress.Port: tcp xxx
    log "Collecting incoming data on '${IFACE}' ..."
    tcpdump -i "${IFACE}" -nqte ip -c "${COUNT}" -Q "in" > "${DUMPFILE}".in 2>/dev/null

    pigs procs "${SCRIPTBLINK1ID}"
    pigs procr "${SCRIPTBLINK2ID}" # start blink mode 2

    log "Collecting outgoing data on '${IFACE}' ..."
    tcpdump -i "${IFACE}" -nqte ip -c "${COUNT}" -Q "out" > "${DUMPFILE}".out 2>/dev/null
    cat "${DUMPFILE}".in "${DUMPFILE}".out > "${DUMPFILE}"

    log "Raw data collected. Parsing ..."

    # try to parse the data:
    # 1. extract all MAC addresses
    # 2. sort
    # 3. find the unique lines and count them
    # 4. sort after number of occurances
    # 5. remove the counts
    # 6. get the first two lines (most used MACs)
    MACS=$(awk -F'[ ,]' '{ print $1 "\n" $3 }' "${DUMPFILE}" | sort | uniq -c | sort -nr | cut -c9- | head -n 2)
    MACA=$(echo "${MACS}" | sed -n '1p')
    MACB=$(echo "${MACS}" | sed -n '2p')
    log "MACS:\n${MACS}"
    log "MACA: ${MACA} | MACB: ${MACB}"

    # now parse all MAC/IP commbinations
    COMBOS=$(awk -F"[ ,]" '{print $1 " " $9 "\n" $3 " " $11}' "${DUMPFILE}" | cut -d '.' -f 1-4 | sed 's/:$//' | sort -u)
    log "COMBOS:\n${COMBOS}"

    # from the two MAC addresses we have, one should correspond to only one IP (the device on the inside)
    # and the other one - to at least two IPs to decide unambiguously
    CNTA=$(echo "${COMBOS}" | grep -o "${MACA}" | wc -l)
    CNTB=$(echo "${COMBOS}" | grep -o "${MACB}" | wc -l)
    log "CNTA: ${CNTA} | CNTB: ${CNTB}"
    if [ "${CNTA}" -eq 1 ] && [ "${CNTB}" -ge 2 ]; then
        MACINT="${MACA}"
        MACEXT="${MACB}"
        IPINT=$(echo "${COMBOS}" | grep "${MACA}" | cut -d ' ' -f 2)
    elif [ "${CNTB}" -eq 1 ] && [ "${CNTA}" -ge 2 ]; then
        MACINT="${MACB}"
        MACEXT="${MACA}"
        IPINT=$(echo "${COMBOS}" | grep "${MACB}" | cut -d ' ' -f 2)
    else
        error "Can't determine MACs and IPs!"
        return 1
    fi
    log "MACINT: ${MACINT} | MACEXT: ${MACEXT} | IPINT: ${IPINT}"

    # now start wating for an ARP-Reply from the external device
    log "Waiting for an ARP-reply on '${IFACE}' ..."

    pigs procs "${SCRIPTBLINK2ID}"
    pigs procr "${SCRIPTBLINK3ID}" # blink mode 3

    tcpdump -i "${IFACE}" -nqte -c 1 arp and arp[6:2] == 2 and ether src "${MACEXT}" > "${ARPREPLY}" 2>/dev/null
    IPEXT=$(cut -d ' ' -f 8 "${ARPREPLY}")
    log "IPEXT: ${IPEXT}"

    MACSRCIN=$(cut -d ' ' -f 1 "${DUMPFILE}".in | grep -v "${MACINT}")
    MACSRCOUT=$(cut -d ' ' -f 1 "${DUMPFILE}".out | grep -v "${MACINT}")

    SECIFACE=""
    if [[ "${IFACE}" == "${IFACEA}" ]]; then
        SECIFACE="${IFACEB}"
    else
        SECIFACE="${IFACEA}"
    fi
    if [[ -z "${MACSRCIN}" ]]; then
        IFACEINT="${IFACE}"
        IFACEEXT="${SECIFACE}"
    elif [[ -z "${MACSRCOUT}" ]]; then
        IFACEINT="${SECIFACE}"
        IFACEEXT="${IFACE}"
    else
        error "Can't determine the direction of the interfaces!"
        return 1
    fi
    log "${IFACEINT} is facing the INTERNAL device"
    log "${IFACEEXT} is facing the EXTERNAL device"

    # After so much traffic we expect to have DHCP data as well:
    parse_dhcp_data

    pigs w "${LEDBRIDGE}" 1
    pigs w "${LEDWORKING}" 0
    pigs procs "${SCRIPTBLINK3ID}"
    log "${YELLOW}Parsing finished.${RESET}"
}

######################################################
#
# set_full_mode: Setting devices, routes and firewall
#
######################################################
function set_full_mode() {
    log "${YELLOW}Setting devices, routes and firewall rules ...${RESET}"
    resetled
    pigs procr "${SCRIPTBLINK4ID}" # blink mode 4

    echo 1 > /proc/sys/net/ipv4/ip_forward

    log "Resetting and flushing network devices ..."
    ip link set dev "${IFACEINT}" down
    ip link set dev "${IFACEEXT}" down
    ip link set dev "${IFACEINT}" nomaster
    ip link set dev "${IFACEEXT}" nomaster
    ip link del br0 # TODO: rewrite with some check
    ip address flush dev "${IFACEINT}"
    ip address flush dev "${IFACEEXT}"

    log "Mirroring the MACs on the opposite sides ..."
    ip link set dev "${IFACEINT}" addr "${MACEXT}"
    ip link set dev "${IFACEEXT}" addr "${MACINT}"

    log "Creating the virtual devices pair ..."
    ip netns add ns0
    ip link add veth0 type veth peer name veth1
    ip link set veth0 netns ns0
    ip link set "${IFACEINT}" netns ns0

    # namespace ns0 is facing the internal net,
    # the default namespace - the external one
    log "Assigning IP addresses ..."
    ip -n ns0 addr add "${VETH0IP}"/"${NMVETH}" dev veth0
    ip addr add "${VETH1IP}"/"${NMVETH}" dev veth1

    ip -n ns0 addr add "${IPVIRTINT}"/"${NMVIRTINT}" dev "${IFACEINT}"
    ip addr add "${IPINT}"/"${NMVIRTEXT}" dev "${IFACEEXT}"

    log "Bringing all devices up ..."
    ip -n ns0 link set dev veth0 up
    ip link set dev veth1 up
    ip -n ns0 link set dev "${IFACEINT}" up
    ip link set dev "${IFACEEXT}" up

    # direct static routes to both device we know for certain exist
    log "Assigning routes ..."
    ip -n ns0 route add "${IPINT}"/32 dev "${IFACEINT}"
    ip route add "${IPEXT}"/32 dev "${IFACEEXT}"

    ip -n ns0 route add default via "${VETH1IP}" dev veth0
    ip route add default via "${IPEXT}" dev "${IFACEEXT}"

    log "Setting up the firewall ..."
    "${NFT}" -f "${NFTDEFAULT}"
    ip netns exec ns0 "${NFT}" -f "${NFTNS0}"

    log "Switching proxy_arp on ..."
    # TODO: check and adjust
    #ip netns exec ns0 bash -c "echo 1 > /proc/sys/net/ipv4/conf/"${IFACEINT}"/proxy_arp_pvlan"
    ip netns exec ns0 bash -c "echo 1 > /proc/sys/net/ipv4/conf/${IFACEINT}/proxy_arp"

    # (Re)starting DHCP server
    stop_dhcp
    start_dhcp

    # use our pi.hole dns
    # EDIT: manually edited and protected resolv.conf (chattr +i)
    #echo "nameserver 127.0.0.1" > /etc/resolv.conf
    #sudo systemctl restart systemd-resolved.service

    pigs procs "${SCRIPTBLINK4ID}"
    pigs w "${LEDBRIDGE}" 0
    pigs w "${LEDWORKING}" 1
    log "${YELLOW}Devices, routes and firewall setup finisched.${RESET}"
}

######################################################
#
# Wrappers
#
######################################################
function enter_bridge_mode() {
    log "Entering bridge mode ..."
    if ! set_bridge; then
        error "Error in 'set_bridge'"
        return 1
    fi
    echo "${STATEBRIDGE}" > "${STATEFILE}"
}

function enter_full_mode() {
    log "Entering full mode ..."
    if ! set_full_mode; then
        error "Error in 'set_full_mode'"
        return 1
    fi
    echo "${STATEWORKING}" > "${STATEFILE}"
}

######################################################
#
# Main logic
# Note: all options except CMDONBOOT are meant for debugging
#   When everything is fine this script should be called from
#   cron on @reboot
#
######################################################
CMD="${1}"
if [[ "$#" -eq 0 ]] || [[ "${CMD}" == "help" ]]; then
    show_usage
    exit 1
fi

if [[ ! "${CMD}" == "${CMDPARSE}" ]] && [[ ! "${CMD}" == "${CMDONBOOT}" ]] && [[ ! "${CMD}" == "${CMDBRIDGE}" ]] && [[ ! "${CMD}" == "${CMDFULLON}" ]]; then
    echo
    echo "${ERRMSG}: unknown command '${1}'"
    echo
    show_usage
    exit 1
fi

# TODO: make some kind of setup/first run/etc
#systemctl mask dhcpcd.service
#systemctl mask nftables.service
systemctl stop dhcpcd.service
systemctl stop nftables.service

# save the original MACs (this is only needed for debugging)
if [[ "${CMD}" == "${CMDONBOOT}" ]]; then
    log "${YELLOW}Device rebooted${RESET}"
    if [ ! -f "${MACSFILE}" ]; then
        ip -br link | grep -v "lo\|wl" | awk -F'[ ]+' '{print $1 " " $3}' > "${MACSFILE}"
        log "MACs saved"
    fi
fi
log "${YELLOW}$0 started ...${RESET}"

# Start sniffing for DHCP ACK immediately
# This will provide us the data we need for our DHCP "server"
#
# expected result from tcpdump:
#
# eth1  P   IP (tos 0xc0, ttl 64, id 52933, offset 0, flags [none], proto UDP (17), length 338)
#     192.168.1.1.67 > 192.168.1.2.68: BOOTP/DHCP, Reply, length 310, xid 0x12c7c6a6, secs 1, Flags [none]
#           Your-IP 192.168.1.2
#           Server-IP 192.168.1.1
#           Client-Ethernet-Address bc:5f:f4:97:63:59
#           Vendor-rfc1048 Extensions
#             Magic Cookie 0x63825363
#             DHCP-Message (53), length 1: ACK
#             Server-ID (54), length 4: 192.168.1.1
#             Lease-Time (51), length 4: 86400
#             .... # eventually more options
#             Subnet-Mask (1), length 4: 255.255.255.0
#             BR (28), length 4: 192.168.1.255
#             Domain-Name-Server (6), length 4: 192.168.1.100[, DNS2, DNS3...]
#             Hostname (12), length 13: "my-hostname"
#             Unknown (252), length 1: 10
#             Default-Gateway (3), length 4: 192.168.1.1
#
# expected result after sed:
#    IPINT="192.168.1.2"
#    IPEXT="192.168.1.1"
#    DHCPLEASE="86400"
#    NMVIRTEXT="255.255.255.0"
#    DHCPDNS="192.268.1.100"

# these two are redundant - leaving here for debugging
#-e 's/^.*Your-IP (.*)$/IPINT="\1"/p'\
#-e 's/^.*Default-Gateway.*: (.+)$/IPEXT="\1"/p'\
# (sed -u is critical for line-buffering!)
# TODO: maybe put in a separate script?

# start anew:
rm "${DHCPDATA}" 2>/dev/null
log "Forking one tcpdump as a DHCP listener ..."
while true; do
    TMP=$(tcpdump -i any -vns0 -c 1 'udp[247:4] = 0x63350105' -w "${DHCPDUMP}" --print 2>/dev/null \
        | sed -nE \
            -e 's/^.*Lease-Time.*: ([0-9]+)$/DHCPLEASE="\1"/p'\
            -e 's/^.*Subnet-Mask.*: (.+)$/NMVIRTEXT="\1"/p'\
            -e 's/^.*Domain-Name-Server.* ([0-9]{1,3}(\.[0-9]{1,3}){3})[,]*.*$/DHCPDNS="\1"/p' \
            -e 's/^.*Hostname.*: "([a-zA-Z0-9\-]+)"$/DHCPHOST="\1"/p' \
        )
    echo "${TMP}" > "${DHCPDATA}"
done &

# GPIO should always be started
if ! setup_GPIO; then
    error "Error in 'setup_GPIO'"
    exit 1
fi

# We need the available devices in any case
log "Reading net devices ..."
if ! find_net_devices; then
    error "Error in 'find_net_devices'"
    exit 1
fi

# Bridge mode should always be the start state
if [[ "${CMD}" == "${CMDONBOOT}" ]] || [[ "${CMD}" == "${CMDBRIDGE}" ]] || [[ "${CMD}" == "${CMDFULLON}" ]]; then
    if ! enter_bridge_mode; then
        exit 1
    fi
fi

# Both the pi and the user need some time
if [[ "${CMD}" == "${CMDONBOOT}" ]]; then
    sleep 20
fi

# Parse the network data in all cases except when switching to bridge mode
if [[ ! "${CMD}" == "${CMDBRIDGE}" ]]; then
    if ! parse_network_data; then
        exit 1
    fi
fi

if [[ "${CMD}" == "${CMDFULLON}" ]]; then
    if ! enter_full_mode; then
        exit 1
    fi
fi

# Up until now everything needed should be ready (GPIO, devices, network data)
if [[ "${CMD}" == "${CMDONBOOT}" ]]; then
    log "Going in the interactive loop ..."
    sp='.....'
    sc=0
    while true; do
        READINPUT=$(pigs r "${GPIOSWITCH}")
        MSTATE=$(cat "${STATEFILE}")

        # try to recover on error: go to bridge mode and recalculate
        if [[ "${MSTATE}" == "${STATEERROR}" ]]; then
            echo "ERROR RECOVERY started ..."
            sc=0
            if enter_bridge_mode; then
                sleep 10
                parse_network_data
            fi
        fi

        # bridge mode
        if [[ "${READINPUT}" -eq 1 ]] && [[ "${MSTATE}" == "${STATEWORKING}" ]]; then
            echo "User command: Entering bridge mode"
            sc=0
            enter_bridge_mode
        fi

        # full mode
        if [[ "${READINPUT}" -eq 0 ]] && [[ "${MSTATE}" == "${STATEBRIDGE}" ]]; then
            echo "User command: Entering full mode"
            sc=0
            enter_full_mode
        fi

        printf '\rSleeping %s    \r' "${sp:0:++sc}"
        ((sc==${#sp})) && sc=0
        sleep 5

        # the DHCP server writes a timestamp to DHCPTSFILE every time it communicates with the client
        # we use this timestamp as a reminder to update the data provided to the server (in SHVARSFILE)
        TMP=$(cat ${DHCPTSFILE})
        if ((DHCPTS < TMP)); then
            DHCPTS="${TMP}"
            parse_dhcp_data
        fi
    done
fi
