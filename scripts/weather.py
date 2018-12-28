#!/bin/python
# -*- coding: utf-8 -*-

import requests
import datetime

# Comente a linha abaixo!!!
from weathercfg import *

# Descomente e preencha (http://openweathermap.org/help/city_list.txt)
CITY = "3467747"
# Faça uma conta em https://home.openweathermap.org/users/sign_up e copia sua API aqui...
#API_KEY = "SUA_API_KEY"
UNITS = "Metric"
UNIT_KEY = "C"

try:
    REQ = requests.get("http://api.openweathermap.org/data/2.5/weather?id={}&appid={}&units={}".format(CITY, API_KEY, UNITS))
    if REQ.status_code == 200:
        CURRENT = REQ.json()["weather"][0]["description"].capitalize()
        VELOCIDADE = REQ.json()["wind"]["speed"]
        #DIRECAO = REQ.json()["wind"]["deg"]
        PRESSAO = REQ.json()["main"]["pressure"]
        #VISIBILIDADE = REQ.json()["visibility"]
        HUMIDADE = REQ.json()["main"]["humidity"]
        ID = int(float(REQ.json()["weather"][0]["id"]))
        TEMP = int(float(REQ.json()["main"]["temp"]))
        HOUR = datetime.datetime.now().hour

        #for k, v in REQ.json().iteritems():
        #    print k, v

        #if DIRECAO > 270 and DIRECAO <= 45:
        #    DIRECAO = "norte"
        #elif DIRECAO > 45 and DIRECAO <= 135:
        #    DIRECAO = "norte"
        #elif DIRECAO > 135 and DIRECAO <= 225:
        #    DIRECAO = "sul"
        #elif DIRECAO > 225 and DIRECAO <= 270:
        #    DIRECAO = "oeste"

        if CURRENT == "Shower rain":
            CURRENT = "Chuva torrencial"
        if CURRENT == "Overcast clouds":
            CURRENT = "Nublado"
        elif CURRENT == "Scattered clouds":
            CURRENT = "Nuvens esparsas"
        elif CURRENT == "Thunderstorm":
            CURRENT = "Trovoada"
        elif CURRENT == "Thunderstorm with light rain":
            CURRENT = "Trovoada com chuva fina"
        elif CURRENT == "Few clouds":
            CURRENT = "Poucas nuvens"
        elif CURRENT == "Broken clouds":
            CURRENT = "Nuvens esparsas"
        elif CURRENT == "Clear sky":
            CURRENT = "Céu claro"
        elif CURRENT == "Moderate rain":
            CURRENT = "Chuva moderada"
        elif CURRENT == "Thunderstorm with heavy rain":
            CURRENT = "Trovoada com chuva pesada"
        elif CURRENT == "Light rain":
            CURRENT = "Chuva leve"
        elif CURRENT == "Light intensity shower rain":
            CURRENT = "Chuva leve"
        elif CURRENT == "Mist":
            CURRENT = "Névoa"
        elif CURRENT == "Light intensity drizzle":
            CURRENT = "Chuvisco leve"
        elif CURRENT == "Thunderstorm with rain":
            CURRENT = "Trovoada com chuva"

        if ID >= 200 and ID <= 232:
            ICON = ""
        elif ID == 300:
            ICON = ""
        elif ID == 501 or ID == 500 or ID == 520:
            ICON = ""
        elif ID == 521:
            ICON = ""
        elif ID >= 310 and ID <= 531:
            ICON = ""
        elif ID >= 600 and ID <= 622:
            ICON = ""
        elif ID >= 701 and ID <= 761:
            ICON = ""
        elif ID >= 801 and ID <= 804:
            if HOUR >= 6 and HOUR <= 19:
                ICON = ""
            else:
                ICON = ""
        elif ID >= 900 and ID <= 902 or ID >= 957 and ID <= 962:
            ICON = ""
        elif ID == 903 or ID == 906:
            ICON = ""
        elif ID == 904:
            ICON = ""
        elif ID == 905 or ID >= 951 and ID <= 956:
            ICON = ""
        else:
            if HOUR >= 6 and HOUR <= 19:
                ICON = ""
            else:
                ICON = ""
        #print("%%{F#FFF}%s %%{F-}%s  %i°%s  %s%%  %s  %skm/h  %shPa " % (ICON, CURRENT, TEMP, UNIT_KEY, HUMIDADE, DIRECAO, VELOCIDADE, PRESSAO)) # Icon with description
        print("%%{F#FFF}%s %%{F-}%s  %i°%s  %s%%  %skm/h  %shPa " % (ICON, CURRENT, TEMP, UNIT_KEY, HUMIDADE, VELOCIDADE, PRESSAO)) # Icon with description

except requests.exceptions.RequestException:  # This is the correct syntax
    print("Recuperando condições do clima.") # Icon with description
