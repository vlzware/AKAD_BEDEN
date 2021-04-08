#!/usr/bin/python3
import time, requests
from smbus2 import SMBus

# taken from the EasyVR software
G1_LICHT_AN     = 1
G1_LICHT_AUS    = 2
G1_HELLER       = 3
G1_DUNKLER      = 4
G1_EINS_AN      = 5
G1_EINS_AUS     = 6
G1_ZWEI_AN      = 7
G1_ZWEI_AUS     = 8

# taken from OpenHAB settings
#OH_url_base = 'http://pi-z.local:8080/rest/items/'
OH_url_base     = 'http://localhost:8080/rest/items/'
OH_url_licht    = 'HueLampe_Color'
OH_url_eins     = 'TPLINK_Power'
OH_url_zwei     = 'Shelly_Power'
OH_cmd_an       = 'ON'
OH_cmd_aus      = 'OFF'
OH_cmd_heller   = 'INCREASE'
OH_cmd_dunkler  = 'DECREASE'

def rest_request(url, payload):
    x = requests.post(url = url, data = payload)
    # TODO: check response

bus = SMBus(1)
done = False
print("Polling started. To quit use Ctrl-C")
while not done:
    try:
        b = bus.read_byte_data(8, 0)
        if (b == G1_LICHT_AN):
            rest_request(OH_url_base + OH_url_licht, OH_cmd_an)
        elif (b == G1_LICHT_AUS):
            rest_request(OH_url_base + OH_url_licht, OH_cmd_aus)
        elif (b == G1_HELLER):
            rest_request(OH_url_base + OH_url_licht, OH_cmd_heller)
        elif (b == G1_DUNKLER):
            rest_request(OH_url_base + OH_url_licht, OH_cmd_dunkler)
        elif (b == G1_EINS_AN):
            rest_request(OH_url_base + OH_url_eins, OH_cmd_an)
        elif (b == G1_EINS_AUS):
            rest_request(OH_url_base + OH_url_eins, OH_cmd_aus)
        elif (b == G1_ZWEI_AN):
            rest_request(OH_url_base + OH_url_zwei, OH_cmd_an)
        elif (b == G1_ZWEI_AUS):
            rest_request(OH_url_base + OH_url_zwei, OH_cmd_aus)

        # print debug message
        if (b != 0):
            print(b)
        time.sleep(0.5)

    # sometimes we need to wait for OpenHAB to become ready - just keep trying
    except requests.HTTPError as e:
        print(e)

    # this gets thrown by problems with the I2C bus, so we just keep retrying
    except OSError as e:
        print(e)

    except KeyboardInterrupt:
        bus.close()
        done = True
print()
print("Bye")
