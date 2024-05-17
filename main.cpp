/*
 * Copyright (c) 2017-2020 Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "mbed.h"
#include <chrono>
#include <cmath>

// Initialize a pins to perform analog input and digital output functions
AnalogIn   ain(A0);
DigitalOut dout(LED1);

using namespace std::chrono;

BufferedSerial pc(USBTX,USBRX);
char buff[6]; // largest value is 65535, new line
bool onPeak = false;
static unsigned short threshold = 53000;
float t1 = 0;
bool calculated = true;
float maxValue = 0;
float maxIndex = 0;
Timer timer;

Ticker sample;

float ihr(float t1, float t2) {
    return 1/(t2 - t1)*60;
}

void sampleADC(){
    unsigned short value = ain.read_u16();
    t1++;
    int now = timer.read_ms();

    if (value > threshold) {
            onPeak = true;
        
            if (maxValue < value) {
        
                maxValue = value;
                maxIndex = now;
                calculated = false; 
            }
    
        else { 
            if (onPeak && !calculated) {

                if (t1 >= 0) {
                    float IHR = ihr(t1 / 1000, maxIndex / 1000);
                    //printf("IHR: %f\n", IHR);
                }
                t1 = now;
                maxValue = -9000;
                onPeak = false;
                calculated = true; 
            }

        }
    }

    // buff[0] = value/10000 + 0x30;
    // value = value - (buff[0]-0x30)*10000;
    
    // buff[1] = value/1000 + 0x30;
    // value = value - (buff[1]-0x30)*1000;
    
    // buff[2] = value/100 + 0x30;
    // value = value - (buff[2]-0x30)*100;
    
    // buff[3] = value/10 + 0x30;
    // value = value - (buff[3]-0x30)*10;
    
    // buff[4] = value/1 + 0x30;
    // pc.write(&buff,6);
}

int main(void)
{
    // needed to use thread_sleep_for in debugger
    // your board will get stuck without it :(
    timer.start();
    #if defined(MBED_DEBUG) && DEVICE_SLEEP
        HAL_DBGMCU_EnableDBGSleepMode();
    #endif
    dout = 0;
    
    buff[5] = '\n';

    sample.attach(&sampleADC,10ms);

    while (1) {
        thread_sleep_for(100);
        
    }
}