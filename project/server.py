import asyncio
import aiohttp
import async_timeout
import json
import os, sys, time, re

API_KEY = ''

clients = {}
serverIDs = ['Goloman', 'Hands', 'Holiday', 'Welsh', 'Wilkes']
allCommands = ['IAMAT', 'WHATSAT']

TIMEDIFF = 1
TIMESENT = 3
tasks = {}      

ports = {'Goloman': 11525, 'Hands': 11526,
    'Holiday': 11527,'Wilkes': 11528,
    'Welsh': 11529}

relationships = {
    'Goloman': ['Hands', 'Holiday', 'Wilkes'],
    'Hands': ['Goloman', 'Wilkes'],
    'Holiday': ['Goloman', 'Welsh'],
    'Wilkes': ['Goloman', 'Hands'],
    'Welsh': ['Holiday'],
}




fields= re.compile(r'^\S+$')
iso = re.compile(r'^[+-][0-9]+.[0-9]+[+-][0-9]+.[0-9]+$')
unix = re.compile(r'^[0-9]*.[0-9]+$|^[0-9]+.[0-9]*$')
imatch = re.compile(r'^[0-9]+$')
formTimeDiff = re.compile(r'^[+-][0-9]+.[0-9]+$')
nospace = re.compile(r'\s+')



def main():
    
    if len(sys.argv) != 2:
        print('Port needed')
        sys.exit(1)
    global serverName
    serverName = sys.argv[1]
    if serverName not in serverIDs:
        print('Invalid server ID')
        sys.exit(1)
    print(serverName)

    global log
    log = '%s.log' % serverName
    
    
    global f
    f = open(log, 'a+')

    global loop
    loop = asyncio.get_event_loop()
    

    
    coro = asyncio.start_server(accept, '127.0.0.1', ports[serverName], loop=loop)
    server = loop.run_until_complete(coro)

    
    print('Connecting to socket {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print('...Closing server...')
        f.close()

  
    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()
    f.close()


async def server_write(writer, msg):
    if msg == None:
        return

    await writestream(writer, msg)
    writer.close()  

async def writestream(writer, msg):
    if msg == None:
        return

    try:
        writer.write(msg.encode())
        await writer.drain()
    except:
        print('IOError in writestream: %s' % msg)

async def writelog(msg):
    if msg == None:
        return
        
    try:
        f.write(msg)
    except:
        print('IOError in writing log: %s' % msg)



async def tcp(msg, nullmsg):
    for server in relationships[serverName]:
        if server in nullmsg:
            continue
        try:
            reader, writer = await asyncio.open_connection('127.0.0.1', ports[server], loop=loop)
            await writelog('Opened connection with %s\n' % server)
            await server_write(writer, msg)
            await writelog('...propagated: %s\n' % msg)
            await writelog('Dropped connection with %s\n' % server)
        except:
            print('Error while connecting and propagating message to server %s' % server)
            await writelog('Error: cannot connect and propagate message to server %s: Dropped connection with %s\n' % (server, server))






def accept(reader, writer):
    task = asyncio.ensure_future(handle_client(reader, writer))
    tasks[task] = (reader, writer)

    def close_client(task):
        print('...Closing client...')
        del tasks[task]
        writer.close()

    task.add_done_callback(close_client)



async def handle_client(reader, writer):
    while not reader.at_eof():
        data = await reader.readline()
        mybuffer = list(filter(lambda x: len(x) > 0, nospace.sub(r' ', data.decode()).strip().split(' ')))
        await handle_buf(writer, mybuffer)
        print(mybuffer)


async def handle_buf(writer, mybuffer):
    receivedTime = time.time()

    print('Processing {}'.format(mybuffer))

    if len(mybuffer) < 4:
        return

    command = mybuffer[0]
    if command in allCommands or command == 'AT':
        if await validate_command(command, mybuffer[1:]):
            input_command = '%s %s' % (command, ' '.join(mybuffer[1:]))
            toret = await handle_command(command, mybuffer[1:], receivedTime)
        else:
            input_command = '%s' % ' '.join(mybuffer)
            toret = '? %s' % ' '.join(mybuffer)   

    else:       
        input_command = '%s' % ' '.join(mybuffer)
        toret = '? %s' % ' '.join(mybuffer)   

   
    await writestream(writer, toret)
    
    await writelog('Received: %s\n' % input_command)      
    await writelog('Sent: %s\n' % toret)                 



async def handle_command(command, message, receivedTime):
    toret = None
    if command == 'IAMAT':
        clientName = message[0]
        lat = message[1]
        sentTime = message[2]
        
        timeDiff = receivedTime - float(sentTime)
        if timeDiff < 0:
            timeDiff = '-%f' %timeDiff
        else:
            timeDiff = '+%f' %timeDiff

        clients[clientName] = [serverName, timeDiff, lat, sentTime]  
        toret = 'AT %s %s %s %s %s\n' % (serverName, timeDiff, clientName, lat, sentTime)
        topropogate = 'AT %s %s %s %s %s %s\n' % (serverName, timeDiff, clientName, lat, sentTime, serverName)

        nullmsg = [] 
        connectservers = asyncio.ensure_future(tcp(topropogate, nullmsg))
        def finish_connecting(task):
            print('Propagated messages to servers {}'.format(relationships[serverName]))
        connectservers.add_done_callback(finish_connecting)


    elif command == 'WHATSAT':
        clientName = message[0]
        radius = int(message[1])    
        resultsTotal = int(message[2])

        if clientName not in clients:
            return None

        temp_server, timeDiff, lat, sentTime = clients[clientName]

       
        allLatAndLong = list(filter(lambda x: len(x) > 0, re.split(r'[+-]', lat)))
        latitude = allLatAndLong[0]
        longitude = allLatAndLong[1]
        url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%s,%s&radius=%d&key=%s' % (latitude, longitude, radius, API_KEY)
        
        async with aiohttp.ClientSession() as session:
            json_response = await fetch(session, url)
            json_response['results'] = json_response['results'][:resultsTotal]
            api_response = json.dumps(json_response, indent=3)

        toret = 'AT %s %s %s %s %s\n%s\n\n' % (temp_server, timeDiff, clientName, lat, sentTime, api_response)

    elif command == 'AT':
        original_server = message[0]
        timeDiff = message[1]
        clientName = message[2]
        lat = message[3]
        sentTime = message[4]
        clientServer = message[5]

        print('Opened connection with %s\n' % clientServer)
        print('Dropped connection with %s after receiving message ->\n' % clientServer)
        await writelog('Opened connection with %s\n' % clientServer)
        await writelog('Dropped connection with %s after receiving message ->\n' % clientServer)

        if clientName not in clients or float(sentTime) > float(clients[clientName][TIMESENT]):
            clients[clientName] = [original_server, timeDiff, lat, sentTime]   
            topropogate = '%s %s %s\n' % (command, ' '.join(message[:-1]), serverName)    
            nullmsg = [clientServer, original_server] 
            connectservers = asyncio.ensure_future(tcp(topropogate, nullmsg))
            def finish_connecting(task):
                print('Propagated messages to servers {}'.format(relationships[serverName]))
            connectservers.add_done_callback(finish_connecting)
        else:
            return None 

    return toret


async def fetch(session, url):
    async with async_timeout.timeout(10):
        async with session.get(url) as response:
            return await response.json()  


async def validate_command(command, rest):

    if not all([fields.match(x) for x in rest]):
        return False

   
    if command == 'IAMAT':
        if len(rest) != 3:
            return False
        lat = rest[1]
        sentTime = rest[2]
        if not (iso.match(lat) and unix.match(sentTime)):
            return False

    elif command == 'WHATSAT':
        if len(rest) != 3:
            return False
        clientName = rest[0]
        radius = rest[1]
        resultsTotal = rest[2]

        if not (imatch.match(radius) and imatch.match(resultsTotal)):
            return False

        radius = int(radius)
        resultsTotal = int(resultsTotal)

        if (radius > 50 or radius < 0) or (clientName not in clients) or (resultsTotal > 20 or resultsTotal < 0):
            return False

        if clientName not in clients:
            return False
        
    elif command == 'AT':           
        if len(rest) != 6:
            return False
        timeDiff = rest[1]
        lat = rest[3]
        sentTime = rest[4]

        if not (formTimeDiff.match(timeDiff) and iso.match(lat) and unix.match(sentTime)):
            return False
    else:
        return False

    return True


if __name__ == '__main__':
    main()
