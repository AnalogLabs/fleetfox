import mplleaflet
import matplotlib.pyplot as plt
from random import randint

lats = []
longs = []
descriptions = []
cum_distance = 0
last_lat = None
last_lon = None

shapes = ['o','v','^','s','*','P','X']
colors = ['b','r','m']
markers=[]
title = None
marker_desc={}
marker_desc['b'] = "Blue"
marker_desc['r'] = "Red"
marker_desc['m'] = "Magenta"
marker_desc['o'] = "Circle"
marker_desc['v'] = "Up-Triangle"
marker_desc['^'] = "Down-Triangle"
marker_desc['s'] = "Square"
marker_desc['*'] = "Star"
marker_desc['P'] = "Plus (+)"
marker_desc['X'] = "X"

while True:
	gps_file_path = input('Enter path of .ffx file containing annotated GPS coordinates: ')
	if gps_file_path: break

with open(gps_file_path) as f:
        lines = f.readlines()
        for index,l in enumerate(lines):
                print(l)
                if index==0:
                        print('TITLE:  ',l)     
                        title=l
                elif ';' not in l: pass
                else:
                        line = l.split(';')
                        coord_string = line[0]
                        description = line[1]
                        

                        latitude = float(coord_string.split(',')[0])
                        longitude = float(coord_string.split(',')[1])
                        
                        print('adding longitude: ',longitude)
                        print('adding latitude: ',latitude)
                        longs.append(float(longitude))
                        lats.append(float(latitude))
                        descriptions.append(description)

                        while True:
                                color_idx = randint(0,len(colors)-1)
                                shape_idx = randint(0,len(shapes)-1)
                                        
                                print('color_idx: ',color_idx)
                                print('shape_idx: ',shape_idx)
                                color = colors[color_idx]
                                shape = shapes[shape_idx]
                                if color+shape not in markers: break

                        markers.append(color+shape)
                        plt.plot(longitude,latitude,color+shape,ms='20')

while True:

	map_path = input('Enter filename and path to save map: ')
	if map_path: break

legend_html = "<font face='Courier'><b>"+title+"</b><br><br>Powered by <a href='http://github.com/AnalogLabs/fleetfox'>FLEET FOX</a><br>A collaborative map of the world<br>on the Ethereum blockchain.<br><a href='http://analog.earth'>ANALOG LABS</a><br><br>"
legend_html += "<b>LEGEND</b><br><table>"
for index,lon in enumerate(longs):
        legend_html += "<tr><td>"+marker_desc[markers[index][0]]+" "+marker_desc[markers[index][1]]+" - "+descriptions[index]+"</td></tr>"
legend_html += "</table></font>"


#plt.show()

mplleaflet.show(path=map_path,display=True)
f = open(map_path,'r')
contents = f.readlines()
f.close()
#contents.insert(len(contents),legend_html)
contents.insert(0,legend_html)

f=open(map_path,"w")
contents="".join(contents)
f.write(contents)
f.close()


