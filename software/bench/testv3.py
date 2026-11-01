# -*- coding: utf-8 -*-
import pyvisa as visa 
import time, sys, os, datetime
import matplotlib.pyplot as plt
import numpy as np

import pandas as pd
from playsound import playsound

os.system('cls')

rm = visa.ResourceManager()

#Bottom Keithley 2450 Vg
sourceGateVoltage = rm.open_resource('GPIB0::24::INSTR')


#Keithley 2000
sourceBiasCurrent = rm.open_resource('GPIB1::16::INSTR')


######################################################################################
######################################################################################

minBias = 0.0  # in V
maxBias = 1
stepBias = 0.00625

# Define Amount of sweeps
sweepCount = 3

# Save excel naming
# define goal of the experiment session
excelFilename = "chip6n"

input("!!! MAKE SURE THE EXCEL SHEET NAME IS UNIQUE !!! - then press any key/n")

######################################################################################
######################################################################################
forwardGate = np.arange(minBias, maxBias, stepBias)
backwardGate = np.arange(maxBias, minBias, -stepBias)
fullGate = np.concatenate((forwardGate, backwardGate), axis=None)

nA = 1e-9
uA = 1000*nA


# K2450 bottom 
GATE_NPLC = 1
GATE_Compliance = 1*nA
##GATE_VoltRange = max(abs(np.asarray(fullGate))) 


# K2000
Vp_NPLC = 1     
Vp_Range = 10                       # Range of volts for probe voltage Keithley 2000

# K2000
Vp_NPLC = 1     
Vp_Range = 10                       # Range of volts for probe voltage Keithley 2000


def setup_sourceGateVoltage(autoRange = False): #Bottom Keithley 2450 - Gate

    #READ WITH: ask("READ? 'voltMeasBuffer', READ, SOUR")
    sourceGateVoltage.write("*RST")
    sourceGateVoltage.write("SOUR:FUNC VOLT")
    sourceGateVoltage.write("SOUR:VOLT:READ:BACK ON")

    sourceGateVoltage.write("TRAC:MAKE 'voltMeasBuffer', 50000")
    sourceGateVoltage.write("SENS:FUNC 'CURR'")
    sourceGateVoltage.write("SENS:CURR:NPLC %f" %GATE_NPLC)
    
    #sourceGateVoltage.write("SENSe:CURRent:RANGe:AUTO ON")
    sourceGateVoltage.write(":SENS:AZERO:ONCE")
    sourceGateVoltage.write(":SYSTEM:AZERO:STATE ON")
    sourceGateVoltage.write("OUTP ON")
    
    
def setup_sourceBiasCurrent(): #Top Keithley 2450 - SD

    ##READ WITH: ask("READ? 'voltMeasBuffer', READ, SOUR")
    sourceBiasCurrent.write("*RST")
    sourceBiasCurrent.write("SOUR:FUNC CURR")
    sourceBiasCurrent.write("SENS:FUNC 'CURR'")
    sourceBiasCurrent.write("SOUR:CURR:READ:BACK ON")

    sourceBiasCurrent.write("TRAC:MAKE 'voltMeasBuffer', 50000")
    

def turnOffAll():

    sourceGateVoltage.write("OUTP OFF")
    sourceBiasCurrent.write("OUTP OFF")


def turnOnAll():

    sourceGateVoltage.write("OUTP ON")
    sourceBiasCurrent.write("OUTP ON")

setup_sourceGateVoltage()
setup_sourceBiasCurrent();

#time.sleep(1)

turnOnAll()   
  
## FILE CREATION

#start = time.time()

datelog = []
gateVoltlog = []
drainCurrentlog = []

for sweep in range(sweepCount):
    for gat in fullGate:
        sourceGateVoltage.write("SOUR:VOLT %f" %gat)
        time.sleep(0.01)
        readCurrent = sourceBiasCurrent.query_ascii_values("READ?")[0]
        print('Ramping gate to', gat, ' -> drain current = ', readCurrent)

        datelog.append(datetime.datetime.now().time())
        gateVoltlog.append(gat)
        drainCurrentlog.append(readCurrent)

dataLog = pd.DataFrame({"date":datelog,"gateVolt":gateVoltlog,"drainCurrent":drainCurrentlog})

filnExten = excelFilename + ".xlsx"
sheetName = excelFilename
dataLog.to_excel(filnExten , sheetName, index=False)

#rampToGateVoltage(0)
sourceGateVoltage.write("SOUR:VOLT %f" %0)
turnOffAll()



