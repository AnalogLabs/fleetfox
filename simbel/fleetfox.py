# fleetfox.py
# Blockchain Messaging Service (BMS Client)
#( (C) 2018 Omar Metwally :: ANALOG LABS
# omar@analog.earth
# LICENSE: Analog Labs License (analog.earth)

import serial, sys, os
from random import randint
from time import sleep, time
from bcmutil import *
import hashlib

ACCOUNT_PASSWORD = ""
CHECKPOINT_LOCATION = "0xC64ee12746939033208D3fad8E2D455217BDB852"
DEFAULT_ACCOUNT_INDEX = 0
CHECKPOINT_INDEX = 0
DEFAULT_PING_GAS = 44000
SECRET = ''
ACCURACY = 3  # number of decimal places to use for latitude and longitude
SCAN_IN_3_DIMENSIONS = False  # if True, set altitude read from GPS to 0
GPS_TRACE_PATH = '/home/pi/Desktop/way.csv'

ser = serial.Serial('/dev/ttyACM0')
latitude = '' 
longitude = ''
altitude = ''
velocity = ''
velocity_whole = ''
velocity_decimals = ''
velocity_1decimals = 0.0
description = ''

REDISCOVER_INTERVAL = 60 # number of seconds to wait before user can 'rediscover' a location
target_discovered = {}  # dictionary with key = encrypted gps coord string and value a tuple of form (found,timestamp)
                        # where found is 0 or 1 and timestamp is the UTC timestamp
target_descriptions = {}  # gps coord string to description mapping

last_timestamp = 0
last_velocity = 0.0
dist_traveled = 0.0


checkpoint_util = BCMUtil()

greeting = "Loading Fleet Fox Blockchain Messaging Service...\n\nHold down the Control key and C (Ctrl+C) to connect to the Ethereum blockchain..."
print(greeting)
greeting= "ANALOG.EARTH\n\nTo the future machine with the computational power to unlock today's encrypted secrets. To the future human with the spiritual power to unlock all secrets.\n\n"

checkpoint_util.download_checkpoints(CHECKPOINT_LOCATION)

while True:
                line = str(ser.readline())
                #print('GPS data: ',line)

                if '$GPGGA' in line:
                    line = line.split(',')
                    try:
                        lat_dd = float(str(line[2])[0:2])
                        lat_mm = float(str(line[2])[2:])/60
                        latitude = lat_dd + lat_mm
                    except:
                        latitude = None

                    if len(line) >3:
                        if line[3].lower() == 's':
                            latitude = latitude * -1

                    if len(line) > 4:
                        try:
                            long_dd = float(str(line[4])[0:3]) 
                            long_mm = float(str(line[4][3:]))/60
                            longitude = long_dd + long_mm
                        except:
                            longitude = None

                    if len(line) > 5:
                        if line[5].lower() == 'w':
                            longitude = longitude * -1

                    if latitude and longitude:
                        latitude = str(latitude)
                        longitude = str(longitude)
                        #print('Longitude: ', longitude)
                        #print('Latitude: ', latitude)

                    try:
                        altitude = float(line[9])
                        if not SCAN_IN_3_DIMENSIONS: altitude = 0.0
                        #print('Altitude: ', altitude, ' meters')
                    except:
                        altitude = None
               
                if '$GPVTG' in line:
                    line = line.split(',K')
                    if len(line) > 0:
                        if ',' in line[0]:
                            try:
                                velocity = float(line[0].split(',')[-1])
                                velocity_whole = str(velocity).split('.')[0]
                                velocity_decimals = str(velocity).split('.')[1][:1]
                                velocity_1decimals = float( velocity_whole+'.'+velocity_decimals )

                                #print('Velocity: ',str(velocity),' km/hr')
                            except: pass

                coord_string = 'waiting for gps signal'

                if latitude and longitude:
                    hashed_coords, raw_string = checkpoint_util.gen_location_hash(longitude,latitude,str(altitude).split('.')[0], ACCURACY, SECRET)
                    index, ret_hashed_coords, coord_description = checkpoint_util.location_hash_exists(hashed_coords)
                    print('index: ', index, ', raw_string: ', raw_string, ', hashed_coords: ',hashed_coords)

                    if coord_description:
                        target_discovered[coord_string] = (0, time())
                        target_descriptions[coord_string] = coord_description
                        
                if coord_string in target_discovered.keys():
                    if target_discovered[coord_string][0] == 0 or (target_discovered[coord_string][0] == 1 and time() - target_discovered[coord_string][1] > REDISCOVER_INTERVAL):

                        target_discovered[coord_string] = (1,time())
                        display_string = "Target Found! \n\n "+target_descriptions[coord_string]
                        display_string = checkpoint_util.format_string_to_2in7epd(display_string)

                        # ping blockchain
                        checkpoint_util.init_bcinterface()
                        checkpoint_util.bci.set_gas(DEFAULT_PING_GAS)
                        checkpoint_util.bci.set_account(DEFAULT_ACCOUNT_INDEX)
                        checkpoint_util.bci.unlock_account(ACCOUNT_PASSWORD)
                        tx= checkpoint_util.bci.contract.transact(checkpoint_util.bci.tx).ping_checkpoint(CHECKPOINT_LOCATION, index, raw_string, SECRET)
                        print(tx)

                        filehandle = open('/home/pi/Desktop/discovered', 'a')
                        filehandle.write( coord_string +'\t'+display_string+'\t'+str(time()).split('.')[0]+'\n')
                        filehandle.close()

                        sleep(30)

                if (last_timestamp == 0) and velocity:
                    last_timestamp = time()
                    last_velocity = velocity_1decimals
                elif velocity:
                    delta_time = float( time() - last_timestamp )
                    #print('delta_time: ',delta_time, str( type(delta_time) ))
                    #print('last_velocity: ', last_velocity, str( type(last_velocity) ) )

                    dist_traveled += ( float(last_velocity) * float((delta_time / 3600)) * 1000)
                    #print('distance traveled: ',dist_traveled,' meters.')
                    last_timestamp = time()
                    last_velocity = velocity_1decimals

                if len(str(longitude))*len(str(latitude)) > 0:
                        display_string = 'Fleet Fox \nanalog.earth \n\n'
                        display_string += 'Latitude: '+latitude[:8]+' \n'
                        display_string += 'Long: '+longitude[:8]+' \n'
                        display_string += 'Altitude: '+str(altitude)+' meters \n'
                        display_string += 'Velocity: '+str(velocity)+' km/h \n'
                        display_string += 'Distance: '+str(dist_traveled)+'\n'

                        #print('display_string before formatting: ',display_string)
                        display_string = checkpoint_util.format_string_to_2in7epd(display_string)
                        print(display_string)

                        print('Writing coordinates, altitude, velocity, distance, timestamp, and description to file: ',longitude, latitude, altitude, velocity, dist_traveled, time(), description)
                        filehandle = open(GPS_TRACE_PATH, 'a')
                        filehandle.write(str(longitude)+', '+str(latitude)+', '+str(altitude)+', '+str(velocity)+', '+str(dist_traveled)+', '+str(time())+', '+description+'\n')
                        filehandle.close()

                        longitude =''
                        latitude = ''
                        altitude = ''
                        velocity = ''

