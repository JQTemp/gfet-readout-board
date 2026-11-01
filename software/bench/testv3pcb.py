# -*- coding: utf-8 -*-
import pyvisa as visa 
import time, sys, os, datetime
import matplotlib.pyplot as plt
import numpy as np

import pandas as pd
from playsound import playsound

os.system('cls')

rm = visa.ResourceManager()

#Bottom Keithley 2400 Vg
sourceGateVoltage = rm.open_resource('GPIB0::24::INSTR')


#Keithley 2000
probeBiasVolt = rm.open_resource('GPIB1::16::INSTR')


######################################################################################
######################################################################################

minBias = 0  # in V
maxBias = 1
stepBias = 0.0125

# Define Amount of sweeps
sweepCount = 2

# Save excel naming
# define goal of the experiment session
excelFilename = "test_pcb2"
# define the goal of the specific measurment of the experiment session // plus define the round!! (r1, r2, r3, ...)
sheetName = "test_pcb2"


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


def setup_probeBiasVoltage(): #Keithley 2000
	probeBiasVolt.write("*rst; status:preset; *cls")
	probeBiasVolt.write("SENS:FUNC 'VOLT:DC'")
	probeBiasVolt.write("SENS:VOLT:DC:RANG:UPP %f" %Vp_Range)   
	probeBiasVolt.write(":TRIG:DEL 0.0")
	probeBiasVolt.write(":SENSE:VOLT:DC:NPLC %f" %Vp_NPLC)
	probeBiasVolt.write(":SYSTEM:AZERO:STATE OFF")

def turnOffAll():

    sourceGateVoltage.write("OUTP OFF")
    probeBiasVolt.write("OUTP OFF")


def turnOnAll():

    sourceGateVoltage.write("OUTP ON")
    probeBiasVolt.write("OUTP ON")
    

def rampToGateVoltage(voltage):

        
    sourceGateVoltage.write("SOUR:VOLT %f" %voltage)
    time.sleep(1)
    gateVolt = sourceGateVoltage.query_ascii_values("READ?")[0]
    
    readDrainVolt = probeBiasVolt.query_ascii_values("READ?")[0]
    
    print('Ramping gate to', gateVolt, ' -> drain volt = ', readDrainVolt)
    
    return {'DrainVolt': readDrainVolt,'GateVolt': gateVolt}  


setup_sourceGateVoltage()
setup_probeBiasVoltage()

time.sleep(1)

turnOnAll()   
    
dummy = 0
  
## FILE CREATION

start = time.time()

datelog = []
gateVoltlog = []
drainVoltlog = []

for sweep in range(sweepCount):
    for gat in fullGate:
        data = rampToGateVoltage(gat)
        
        datelog.append(datetime.datetime.now().time())
        gateVoltlog.append(data['GateVolt'])
        drainVoltlog.append(data['DrainVolt'])
        
        
    
col1 = "date"
col2 = "gateVolt"
col3 = "drainVolt"

dataLog = pd.DataFrame({col1:datelog,col2:gateVoltlog,col3:drainVoltlog})

filnExten = excelFilename + ".xlsx"



#input("\n!!! Close the excel file to which you are loggind data - then press any key !!!")
dataLog.to_excel(filnExten , sheetName, index=False)

rampToGateVoltage(0)
sourceGateVoltage.write("SOUR:VOLT %f" %0)
turnOffAll()



