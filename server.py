import asyncio
import websockets

#from websockets.asyncio.server import serve

import json

webplayers = set()
players = []
msg = set()
confirm = "OK"


# Lidar com o servidor =================
async def handler(websocket):

    webplayers.add(websocket)

    try:
        await websocket.send("OK")

        while True:
            message = await websocket.recv()

            var = decode_message_var(message)

            if var['mode'] == 1:
                players.append(var)
                await websocket.send(json.dumps(players))

            websockets.broadcast(webplayers,message)

    except websockets.exceptions.ConnectionClosedOK:
        print("Player ",websocket," desconectado")
        websocket.send(decode_message_var("{mode = 5,msg = Desconectado}"))

    except websockets.exceptions.ConnectionClosedError:
        print("Player ",websocket," não conseguiu conectar")
        websocket.send(decode_message_var("{mode = 5,msg = Error}"))

    finally:
        webplayers.remove(websocket)



def decode_message_var(str):
    message_str = str.decode("utf-8")
    message_json = json.loads(message_str)

    return message_json


#Abrir o servidor =========
print("Started server")

async def main():
    async with websockets.serve(handler, host="192.168.1.106", port=2468):
        await asyncio.get_running_loop().create_future()  # run forever

asyncio.run(main())