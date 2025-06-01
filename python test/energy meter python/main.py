print("Hello Core IOT")
import paho.mqtt.client as mqttclient
import time
import json

#BROKER_ADDRESS = "app.coreiot.io"
#PORT = 1883
BROKER_ADDRESS = "10.28.2.47"
PORT = 11883
ACCESS_TOKEN = "oeiO1WQSGswlVfpGIjgd" 

def subscribed(client, userdata, mid, granted_qos):
    print("Subscribed...")


def recv_message(client, userdata, message):
    print("Received: ", message.payload.decode("utf-8"))
    temp_data = {'value': True}
    try:
        jsonobj = json.loads(message.payload)
        if jsonobj['method'] == "setLedSwitchValue1":
            temp_data['value'] = jsonobj['params']
            #TODO HERE

            #END TODO
            client.publish('v1/devices/me/attributes', json.dumps(temp_data), 1)

        if jsonobj['method'] == "setLedSwitchValue2":
            temp_data['value'] = jsonobj['params']

    except:
        pass


def connected(client, usedata, flags, rc):
    if rc == 0:
        print("Connected successfully!!")
        client.subscribe("v1/devices/me/rpc/request/+")
    else:
        print("Connection is failed")


client = mqttclient.Client("Energy meter")
client.username_pw_set(ACCESS_TOKEN)

client.on_connect = connected
client.connect(BROKER_ADDRESS, 1883)
client.loop_start()

client.on_subscribe = subscribed
client.on_message = recv_message

amperage = 15.0
energy = 130.3
frequency = 61.0
power = 5000.0
voltage = 247.9

while True:
    collect_data = {
        'amperage': amperage,
        'energy': energy,
        'frequency': frequency,
        'power': power,
        'voltage': voltage
    }
    client.publish('v1/devices/me/telemetry', json.dumps(collect_data), 1)
    print("Published done")
    time.sleep(30)