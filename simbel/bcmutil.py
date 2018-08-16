# bcmutil.py - Blockchain Messaging Utility # Handles message encryption, ePaper display formatting,
# (C) 2018 Omar Metwally :: ANALOG LABS
# omar@analog.earth
# LICENSE:  ANALOG LABS LICENSE (analog.earth)


from Crypto.Cipher import AES
from Crypto.Hash import keccak
import base64
import hashlib
import os
from bcinterface import *
from time import time

SECRET = ""
ACCURACY = 3

KEY = "analog labs 2018".encode("latin-1")
IV = "This is an IV456".encode("latin-1")

class BCMUtil:

    def __init__(self):
       self.bottle = []  # a bottle is a collection of (encrypted or unencrypted) messages
       self.checkpoints = []
       self.bci = None
       #print('Initialized new Blockchain Message Utility object.')

    # bottle_message formats a location+message combination in the ffx standard
    # modes:
    #     cad - 'clear as day'
    #     fk - 'finders keepers' (lock/unlock using gps coordinate)
    #     enc - encrypted using user-defined key
    def encrypt_message(self, message, key=KEY ):
        message = message.encode('latin-1')

        if len(key) != 16:
            print('AES encryption key must be 16 characters.')
            return
        cipher = AES.new(key, AES.MODE_CFB, IV)
        encoded_message = cipher.encrypt(message)
        print('Encrypted message: ',encoded_message)

        return encoded_message

    def init_bcinterface(self):
        self.bci = BCInterface(mainnet=True)
        self.bci.load_contract()
        self.bci.howdyho()

    def decrypt(self, encoded_message, key=KEY):
        cipher = AES.new(key, AES.MODE_CFB, IV)
        decoded_message = cipher.decrypt(encoded_message)
        print('decoded message: ',decoded_message)
        return decoded_message


    def gen_location_hash(self, longitude, latitude, altitude, accuracy=ACCURACY, secret=SECRET):
        longitude = str(longitude)
        latitude = str(latitude)
        altitude = str(altitude)
        
        hasher = keccak.new(digest_bits=256)
        longitude_whole = longitude.split('.')[0]
        longitude_dd = longitude.split('.')[1][:accuracy]
        longitude_rounded = '.'.join([longitude_whole, longitude_dd])

        latitude_whole = latitude.split('.')[0]
        latitude_dd = latitude.split('.')[1][:accuracy]
        latitude_rounded = '.'.join([latitude_whole, latitude_dd])

        input_string = ','.join([longitude_rounded, latitude_rounded, altitude ])
        hasher.update(input_string.encode('latin-1'))
        hashed_output = "0x"+hasher.hexdigest()

        return hashed_output, input_string

    def format_string_to_2in7epd(self, string_in):
        row_length = 0 
        row = ''
        display_string = ''
        words = string_in.split(' ')

        for w in words:
            if len(w) > 20:
                print('No words greater than 20 characters!')
                return
            row_length = len(row) + len(w) + 1
            if row_length > 20:
                display_string += '\n'
                display_string += w + ' '
                row = w + ' '
            else:
                row += w + ' '
                display_string += w + ' '

        return display_string


    def format_string_to_2in9epd(self, string_in):
        row_length = 0 
        row = ''
        display_string = ''
        words = string_in.split(' ')

        for w in words:
            if len(w) > 15:
                print('No words greater than 15 characters!')
                return
            row_length = len(row) + len(w) + 1
            if row_length > 15:
                display_string += '\n'
                display_string += w + ' '
                row = w + ' '
            else:
                row += w + ' '
                display_string += w + ' '

        print('String formatted to 2.9in ePaper display: ')
        print(display_string)
        return display_string

    # convert unencrypted ffx file to a file with gps coordinates hashed
    # and messages (description field) encrypted
    def hash_coords_encrypt_messages(self,path_in,key=KEY):
        coords_messages = []

        f = open(path_in)
        f_lines = f.readlines()
        for line in f_lines:
            hashed_output = None
            message = None
            line_list = line.split(';')
            coords = line_list[0]
            if len(coords.split(',')) < 3:
                print('Invalid coordinate format. Correct format is latitude,longitude,altitude')
                pass
            elif len(line_list) ==2:
                message = line_list[1]
                longitude = coords.split(',')[1]
                latitude = coords.split(',')[0]
                altitude = coords.split(',')[2]
                coord_string = ','.join([longitude, latitude, altitude, SECRET])

                hashed_output, raw_string = self.gen_location_hash(longitude, latitude, altitude, ACCURACY, SECRET)
                print('raw coord_string: ',raw_string, ', message: ',message)
                print('hashed coord_string: ',hashed_output)

            if hashed_output and message:
                coords_messages.append( (hashed_output, message ))

        f.close()
        return coords_messages


    def check_if_account_exists(self):
        if not self.bci:
            self.init_bcinterface()
    
        if len(self.bci.eth_accounts) == 0:
            while True:
                response = input('No Ethereum accounts found. Would you like to create one?')
                if response.lower() == 'y':
                    self.bci.new_account()
                    break

    def download_checkpoints(self, address):
        if not self.bci:
            print('No Blockchain Interface detected. Creating new BCInterface object...')
            self.init_bcinterface()
        num_checkpoints = self.bci.contract.call().get_num_checkpoints(address)
        i = 0
        while i < num_checkpoints:
                checkpoint = self.bci.contract.call().get_checkpoint_status(address,i)
                if checkpoint not in self.checkpoints:
                        self.checkpoints.append( (i, checkpoint) )
                i += 1

    def location_hash_exists(self, location_hash):
        for index, checkpoint in self.checkpoints:
                if location_hash == '0x'+checkpoint[0].hex():
                        print('Checkpoint Found!')
                        return index, checkpoint[0], checkpoint[1]
        return False


