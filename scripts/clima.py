import requests
import sys
import json
from urllib.request import urlopen

def Celsius(kelvin):
    print(str(int(float(kelvin)-273.15))+" °C")

def Fahrenheit(kelvin):
    print(str(int(float(kelvin)*9/5-459.67))+" °F")

def Kelvin(kelvin):
    print(str(int(kelvin))+" K")

#ipstack api key https://ipstack.com/
ipstack_api_key = '18c0fa1e88a47eddd38129b5a69fb952'
my_ip = urlopen('http://ip.42.pl/raw').read().decode();

#url to send to ipstack with ip and api key
send_url = 'http://api.ipstack.com/'+my_ip+'?access_key='+ipstack_api_key

#openweathermap api key https://openweathermap.org
openweathermap_api_key = ''

#request location from ip
r = requests.get(send_url)
j = json.loads(r.text)
lat = j['latitude']
lon = j['longitude']

#url to send to openweathermap with the coordinates
owm_url = "http://api.openweathermap.org/data/2.5/weather?APPID="+openweathermap_api_key+"&"+"lat="+str(lat)+"&lon="+str(lon)

r = requests.get(owm_url)
j = json.loads(r.text)

_kelvin = j['main']['temp']

#handle arguments
if len(sys.argv)>1:
    if sys.argv[1]=="-f":
        Fahrenheit(_kelvin)
    elif sys.argv[1]=="-k":
        Kelvin(_kelvin)
    else:
        Celsius(_kelvin)
else:
    Celsius(_kelvin)
