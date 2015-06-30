//
//  CommunicationMgr.m
//  SkinDetect
//
//  Created by Q on 14-9-17.
//  Copyright (c) 2014年 EADING. All rights reserved.
//

#import "CommunicationMgr.h"
#import "aurio_helper.h"
#import "CAXException.h"
#import "FFTBufferManager.h"

#import <AVFoundation/AVFoundation.h>

enum uart_state {
    STARTBIT = 0,
    SAMEBIT  = 1,
    NEXTBIT  = 2,
    STOPBIT  = 3,
    STARTBIT_FALL = 4,
    DECODE   = 5,
};

typedef enum aurioTouchDisplayMode {
    aurioTouchDisplayModeOscilloscopeWaveform,
    aurioTouchDisplayModeOscilloscopeFFT,
    aurioTouchDisplayModeSpectrum
} aurioTouchDisplayMode;

typedef struct SendDataStruct {
    int sendDataSize;
    uint8_t *sendBytes;
}SendDataStruct;

typedef struct RecieveDataStruct {
    int recieveDataSize;
    uint8_t *recieveBytes;
}RecieveDataStruct;

#define fc 1200
#define df 100
#define T (1/df)
#define N (SInt32)(T * THIS->hwSampleRate)
#define THRESHOLD 0 // threshold used to detect start bit
#define HIGHFREQ 1378.125 // baud rate. best to take a divisible number for 44.1kS/s
#define SAMPLESPERBIT 32 // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define SAMPLESPERBIT 5 // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define HIGHFREQ (44100 / SAMPLESPERBIT) // baud rate. best to take a divisible number for 44.1kS/s
#define LOWFREQ (HIGHFREQ / 2)
#define SHORT (SAMPLESPERBIT/2 + SAMPLESPERBIT/4) //
#define LONG (SAMPLESPERBIT + SAMPLESPERBIT/2)    //
#define NUMSTOPBITS 100 // number of stop bits to send before sending next value.
//#define NUMSTOPBITS 10 // number of stop bits to send before sending next value.
#define AMPLITUDE (1<<24)

//#define DEBUG // verbose output about the bits and symbols
//#define DEBUG2 // output the byte values encoded
//#define DEBUGWAVE // enables output of the waveform after the 10th byte is sent. CAREFUL!!! Usually overloads debug output
//#define DECDEBUGBYTE // output the received byte only
//#define DECDEBUG // output for decoding debugging
//#define DECDEBUG2 // verbose decoding output

@interface CommunicationMgr () {
    AURenderCallbackStruct inputProc;
    AudioUnit rioUnit;
    SystemSoundID buttonPressSound;
    
    int32_t *l_fftData;
    GLfloat *oscilLine;
    
    Float64	hwSampleRate;
    UInt8 textBoxByte;
    int	unitIsRunning;
    int sendTXPtr;
    int recieveTXPtr;
    BOOL mute;
    
    CAStreamBasicDescription thruFormat;
    aurioTouchDisplayMode displayMode;
    SendDataStruct sendData;
    RecieveDataStruct recieveData;
    FFTBufferManager *fftBufferManager;
    DCRejectionFilter *dcFilter;
}

@property (strong, nonatomic) AVAudioSession *avAudioSession;

@property (nonatomic) BOOL mute;
@property (nonatomic) BOOL isDetecting;
@property (nonatomic) BOOL isStartRecievePakage;
@property (nonatomic) BOOL hasInit;
@property (nonatomic) int unitIsRunning;
@property (nonatomic) int timeoutCounting;
@property (nonatomic) SendRequest finishFlag;
@property (strong, nonatomic) NSTimer *timeoutTimer;

@end

@implementation CommunicationMgr
@synthesize mute;
@synthesize unitIsRunning;

static uint8_t pattern0[] = {0x00, 0x23, 0x02, 0x57, 0x00, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x00 ^ 0x00)), 0x05};
static uint8_t pattern1[] = {0x00, 0x23, 0x02, 0x57, 0x01, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x01 ^ 0x00)), 0x05};
static uint8_t pattern2[] = {0x00, 0x23, 0x02, 0x57, 0x02, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x02 ^ 0x00)), 0x05};
static uint8_t pattern3[] = {0x00, 0x23, 0x02, 0x57, 0x03, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x03 ^ 0x00)), 0x05};
static uint8_t pattern4[] = {0x00, 0x23, 0x02, 0x57, 0x04, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x04 ^ 0x00)), 0x05};
static uint8_t pattern5[] = {0x00, 0x23, 0x02, 0x57, 0x05, 0x00, (uint8_t)(~(0x02 ^ 0x57 ^ 0x05 ^ 0x00)), 0x05};

static uint8_t finishDetectBytes[5] = {0xbb, 0xa0, 0xca, 0xa0 ^ 0xca, 0xaa};

//#pragma mark -Audio Session Interruption Listener
//void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
//{
//	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
//
//	CommunicationMgr *THIS = (__bridge CommunicationMgr*)inClientData;
//
//	if (inInterruption == kAudioSessionEndInterruption) {
//		// make sure we are again the active session
//		AudioSessionSetActive(true);
//		AudioOutputUnitStart(THIS->rioUnit);
//	}
//
//	if (inInterruption == kAudioSessionBeginInterruption) {
//		AudioOutputUnitStop(THIS->rioUnit);
//    }
//}

//#pragma mark -Audio Session Property Listener
//void propListener(	void *                  inClientData,
//                  AudioSessionPropertyID	inID,
//                  UInt32                  inDataSize,
//                  const void *            inData)
//{
//	CommunicationMgr *THIS = (__bridge CommunicationMgr*)inClientData;
//	// FIXME: disable the changing of property for now.
//	if (inID == kAudioSessionProperty_AudioRouteChange)
//	{
//		try {
//			// if there was a route change, we need to dispose the current rio unit and create a new one
//			XThrowIfError(AudioComponentInstanceDispose(THIS->rioUnit), "couldn't dispose remote i/o unit");
//
//			SetupRemoteIO(THIS->rioUnit, THIS->inputProc, THIS->thruFormat);
//
//			UInt32 size = sizeof(THIS->hwSampleRate);
//			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &THIS->hwSampleRate), "couldn't get new sample rate");
//
//			XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
//
//			// we need to rescale the sonogram view's color thresholds for different input
//			CFStringRef newRoute;
//			size = sizeof(CFStringRef);
//			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
//		} catch (CAXException e) {
//			char buf[256];
//			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//		}
//
//	}
//}

#pragma mark -RIO Render Callback

static OSStatus	PerformThru(
                            void						*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp 		*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList 			*ioData)
{
    CommunicationMgr *THIS = (__bridge CommunicationMgr *)inRefCon;
    OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    // TX vars
    static UInt32 phase = 0;
    static UInt32 phase2 = 0;
    static UInt32 lastPhase2 = 0;
    static SInt32 sample = 0;
    static SInt32 lastSample = 0;
    static int decState = STARTBIT;
    static int byteCounter = 1;
    static UInt8 parityTx = 0;
    
    // UART decoding
    static int bitNum = 0;
    static uint8_t uartByte = 0;
    
    // UART encode
    static uint32_t phaseEnc = 0;
    static uint32_t nextPhaseEnc = SAMPLESPERBIT;
    static uint8_t uartByteTx = 0x0;
    static uint32_t uartBitTx = 0;
    static uint8_t state = STARTBIT;
    static float uartBitEnc[SAMPLESPERBIT];
    static uint8_t currentBit = 1;
    static UInt8 parityRx = 0;
    
    if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
    
    // Remove DC component
    //for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
    //	THIS->dcFilter[i].InplaceFilter((SInt32*)(ioData->mBuffers[i].mData), inNumberFrames, 1);
    SInt32* lchannel = (SInt32*)(ioData->mBuffers[0].mData);
    //printf("sample %f\n", THIS->hwSampleRate);
    
    /************************************
     * UART Decoding
     ************************************/
#if 1
    for(int j = 0; j < inNumberFrames; j++) {
        float val = lchannel[j];
#ifdef DEBUGWAVE
        printf("%8ld, %8.0f\n", phase2, val);
#endif
#ifdef DECDEBUG2
        if(decState == DECODE)
            printf("%8ld, %8.0f\n", phase2, val);
#endif
        phase2 += 1;
        if (val < THRESHOLD ) {
            sample = 0;
        } else {
            sample = 1;
        }
        if (sample != lastSample) {
            // transition
            SInt32 diff = phase2 - lastPhase2;
            switch (decState) {
                case STARTBIT:
                    if (lastSample == 0 && sample == 1)
                    {
                        // low->high transition. Now wait for a long period
                        decState = STARTBIT_FALL;
                    }
                    break;
                case STARTBIT_FALL:
                    if (( SHORT < diff ) && (diff < LONG) )
                    {
                        // looks like we got a 1->0 transition.
                        bitNum = 0;
                        parityRx = 0;
                        uartByte = 0;
                        decState = DECODE;
                    } else {
                        decState = STARTBIT;
                    }
                    break;
                case DECODE:
                    if (( SHORT < diff) && (diff < LONG) ) {
                        // we got a valid sample.
                        if (bitNum < 8) {
                            uartByte = ((uartByte >> 1) + (sample << 7));
                            bitNum += 1;
                            parityRx += sample;
#ifdef DECDEBUG
                            printf("Bit %d value %ld diff %ld parity %d\n", bitNum, sample, diff, parityRx & 0x01);
#endif
                        } else if (bitNum == 8) {
                            // parity bit
                            if(sample != (parityRx & 0x01))
                            {
#ifdef DECDEBUGBYTE
                                printf("sample %f\n", THIS->hwSampleRate);
                                printf(" -- parity %ld,  UartByte 0x%x\n", sample, uartByte);
#endif
                                decState = STARTBIT;
                            } else {
#ifdef DECDEBUG
                                printf(" ++ good parity %ld, UartByte 0x%x\n", sample, uartByte);
#endif
                                
                                bitNum += 1;
                            }
                            
                        } else {
                            // we should now have the stopbit
                            if (sample == 1) {
                                // we have a new and valid byte!
#ifdef DECDEBUGBYTE
                                printf(" ++ StopBit: %ld UartByte 0x%x\n", sample, uartByte);
#endif
                                THIS->textBoxByte = uartByte;
                                [THIS handleRecivedData:uartByte];
                            } else {
                                // not a valid byte.
#ifdef DECDEBUGBYTE
                                printf(" -- StopBit: %ld UartByte %d\n", sample, uartByte);
#endif
                            }
                            decState = STARTBIT;
                        }
                    } else if (diff > LONG) {
#ifdef DECDEBUG
                        printf("diff too long %ld\n", diff);
#endif
                        decState = STARTBIT;
                    } else {
                        // don't update the phase as we have to look for the next transition
                        lastSample = sample;
                        continue;
                    }
                    
                    break;
                default:
                    break;
            }
            lastPhase2 = phase2;
        }
        lastSample = sample;
    }
#endif
    /*******************************
     * Drawing Oscope
     *******************************/
    if (THIS->displayMode == aurioTouchDisplayModeOscilloscopeWaveform)
    {
        // The draw buffer is used to hold a copy of the most recent PCM data to be drawn on the oscilloscope
        if (drawBufferLen != drawBufferLen_alloced)
        {
            int drawBuffer_i;
            
            // Allocate our draw buffer if needed
            if (drawBufferLen_alloced == 0)
                for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
                    drawBuffers[drawBuffer_i] = NULL;
            
            // Fill the first element in the draw buffer with PCM data
            for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
            {
                drawBuffers[drawBuffer_i] = (SInt8 *)realloc(drawBuffers[drawBuffer_i], drawBufferLen);
                bzero(drawBuffers[drawBuffer_i], drawBufferLen);
            }
            
            drawBufferLen_alloced = drawBufferLen;
        }
        
        /*
         int i;
         
         SInt8 *data_ptr = (SInt8 *)(ioData->mBuffers[0].mData);
         for (i=0; i<inNumberFrames; i++)
         {
         if ((i+drawBufferIdx) >= drawBufferLen)
         {
         cycleOscilloscopeLines();
         drawBufferIdx = -i;
         }
         if (THIS->mute == YES) {
         drawBuffers[0][i + drawBufferIdx] = symbols[i]*64;
         } else {
         drawBuffers[0][i + drawBufferIdx] = data_ptr[2]*10;
         }
         data_ptr += 4;
         }
         drawBufferIdx += inNumberFrames;
         */
    }
    
    
    else if ((THIS->displayMode == aurioTouchDisplayModeSpectrum) ||
             (THIS->displayMode == aurioTouchDisplayModeOscilloscopeFFT))
    {
        if (THIS->fftBufferManager == NULL) return noErr;
        
        if (THIS->fftBufferManager->NeedsNewAudioData())
        {
            THIS->fftBufferManager->GrabAudioData(ioData);
        }
        
    }
    
    if (THIS->mute == YES) {
        // prepare sine wave
        
        SInt32 values[inNumberFrames];
        /*******************************
         * Generate 22kHz Tone
         *******************************/
        
        double waves;
        //printf("inBusNumber %d, inNumberFrames %d, ioData->NumberBuffers %d mNumberChannels %d\n", inBusNumber, inNumberFrames, ioData->mNumberBuffers, ioData->mBuffers[0].mNumberChannels);
        //printf("size %d\n", ioData->mBuffers[0].mDataByteSize);
        //printf("sample rate %f\n", THIS->hwSampleRate);
        for(int j = 0; j < inNumberFrames; j++) {
            
            
            waves = 0;
            
            //waves += sin(M_PI * 2.0f / THIS->hwSampleRate * 22050.0 * phase);
            waves += sin(M_PI * phase+0.5); // This should be 22.050kHz
            
            waves *= (AMPLITUDE); // <--------- make sure to divide by how many waves you're stacking
            
            values[j] = (SInt32)waves;
            //values[j] += values[j]<<16;
            //printf("%d: %ld\n", phase, values[j]);
            phase++;
            
        }
        // copy sine wave into left channels.
        //memcpy(ioData->mBuffers[0].mData, values, ioData->mBuffers[0].mDataByteSize);
        // copy sine wave into right channels.
        memcpy(ioData->mBuffers[1].mData, values, ioData->mBuffers[1].mDataByteSize);
        /*******************************
         * UART Encoding
         *******************************/
        for(int j = 0; j< inNumberFrames; j++) {
            if ( phaseEnc >= nextPhaseEnc){
                if (uartBitTx >= NUMSTOPBITS) {
                    state = STARTBIT;
                } else {
                    state = NEXTBIT;
                }
            }
            
            switch (state) {
                case STARTBIT:
                {
                    //					uartByteTx = (uint8_t)THIS->slider.value;
                    if (THIS->sendTXPtr < THIS->sendData.sendDataSize) {
                        uartByteTx = THIS->sendData.sendBytes[THIS->sendTXPtr];
                        THIS->sendTXPtr++;
                    } else {
                        THIS->mute = NO;
                        [THIS sendDataFinished];
                        
                        break;
                    }
                    //uartByteTx += 1;
#ifdef DEBUG2
                    printf("uartByteTx: 0x%x\n", uartByteTx);
#endif
                    byteCounter += 1;
                    uartBitTx = 0;
                    parityTx = 0;
                    
                    state = NEXTBIT;
                    // break; UNCOMMENTED ON PURPOSE. WE WANT TO FALL THROUGH!
                }
                case NEXTBIT:
                {
                    uint8_t nextBit;
                    if (uartBitTx == 0) {
                        // start bit
                        nextBit = 0;
                    } else {
                        if (uartBitTx == 9) {
                            // parity bit
                            nextBit = parityTx & 0x01;
                        } else if (uartBitTx >= 10) {
                            // stop bit
                            nextBit = 1;
                        } else {
                            nextBit = (uartByteTx >> (uartBitTx - 1)) & 0x01;
                            parityTx += nextBit;
                        }
                    }
                    if (nextBit == currentBit) {
                        if (nextBit == 0) {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = -sin(M_PI * 2.0f / THIS->hwSampleRate * HIGHFREQ * (p+1));
                            }
                        } else {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * HIGHFREQ * (p+1));
                            }
                        }
                    } else {
                        if (nextBit == 0) {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * LOWFREQ * (p+1));
                            }
                        } else {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = -sin(M_PI * 2.0f / THIS->hwSampleRate * LOWFREQ * (p+1));
                            }
                        }
                    }
                    
#ifdef DEBUG
                    printf("BitTX %d: last %d next %d\n", uartBitTx, currentBit, nextBit);
#endif
                    currentBit = nextBit;
                    uartBitTx++;
                    state = SAMEBIT;
                    phaseEnc = 0;
                    nextPhaseEnc = SAMPLESPERBIT;
                    
                    break;
                }
                default:
                    break;
            }
            
            values[j] = (SInt32)(uartBitEnc[phaseEnc%SAMPLESPERBIT] * AMPLITUDE);
#ifdef DEBUG
            printf("val %ld\n", values[j]);
#endif
            phaseEnc++;
            
        }
        // copy data into right channel
        //memcpy(ioData->mBuffers[1].mData, values, ioData->mBuffers[1].mDataByteSize);
        // copy data into left channel
        memcpy(ioData->mBuffers[0].mData, values, ioData->mBuffers[0].mDataByteSize);
    }
    
    return err;
}

+ (instancetype)sharedInstance {
    static CommunicationMgr *_sharedCommunicationMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCommunicationMgr = [[self alloc] init];
    });
    
    return _sharedCommunicationMgr;
}

+ (BOOL)isRoutConnect {
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *description in route.outputs) {
        if ([description.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    
    return NO;
}

- (id)init {
    if (self = [super init]) {
        self.avAudioSession = [AVAudioSession sharedInstance];
        _isDetecting = NO;
        _hasInit = NO;
        _sendReq = SendRequestNon;
        _finishFlag = SendRequestNon;
        
        [self addObserver:self
               forKeyPath:@"finishFlag"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"finishFlag"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    delete[] dcFilter;
    delete fftBufferManager;
}

- (void)commnunicationInit {
    if (_hasInit) {
        return;
    }
    
    _hasInit = YES;
    self.mute = NO;
    displayMode = aurioTouchDisplayModeOscilloscopeWaveform;
    
    inputProc.inputProc = PerformThru;
    inputProc.inputProcRefCon = (__bridge void *)self;
    
    CFURLRef url = NULL;
    try {
        //		url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFStringRef([[NSBundle mainBundle] pathForResource:@"button_press" ofType:@"caf"]), kCFURLPOSIXPathStyle, false);
        //		XThrowIfError(AudioServicesCreateSystemSoundID(url, &buttonPressSound), "couldn't create button tap alert sound");
        //		CFRelease(url);
        
        // Initialize and configure the audio session
        //		XThrowIfError(AudioSessionInitialize(NULL, NULL, rioInterruptionListener, self), "couldn't initialize audio session");
        //		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        NSError *error = nil;
        if (![self.avAudioSession setActive:YES error:&error]) {
            NSLog(@"*****AVAudioSession Active Failed!");
            return;
        }
        //        XThrowIfError([self.avAudioSession setActive:YES error:&error], "couldn't initialize audio session");
        
        //		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
        //		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
        [self.avAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:kAudioSessionCategory_PlayAndRecord error:nil];
        //		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self), "couldn't set property listener");
        
        Float32 preferredBufferSize = .005;
        //		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
        [self.avAudioSession setPreferredIOBufferDuration:preferredBufferSize error:nil];
        
        //		UInt32 size = sizeof(hwSampleRate);
        //		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
        hwSampleRate = self.avAudioSession.sampleRate;
        
        XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");
        
        dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
        
        UInt32 maxFPS;
        UInt32 size = sizeof(maxFPS);
        XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
        
        fftBufferManager = new FFTBufferManager(maxFPS);
        l_fftData = new int32_t[maxFPS/2];
        
        oscilLine = (GLfloat*)malloc(drawBufferLen * 2 * sizeof(GLfloat));
        
        XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
        size = sizeof(thruFormat);
        XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
        
        unitIsRunning = 1;
    }
    catch (CAXException &e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        unitIsRunning = 0;
        if (dcFilter) delete[] dcFilter;
        if (url) CFRelease(url);
    }
    catch (...) {
        fprintf(stderr, "An unknown error occurred\n");
        unitIsRunning = 0;
        if (dcFilter) delete[] dcFilter;
        if (url) CFRelease(url);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioInterrupt:)
                                                 name:@"AVAudioSessionInterruptionNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRoutChange:)
                                                 name:@"AVAudioSessionRouteChangeNotification"
                                               object:nil];
}

- (void)clear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    delete[] dcFilter;
    delete fftBufferManager;
    
    [self.avAudioSession setActive:NO error:nil];
}

- (void)countingDown {
    _timeoutCounting++;
    if (_timeoutCounting > TIME_OUT) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
        
        if (_sendReq == SendRequestConnection) {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(didConnectingFailed:)]) {
                [self.delegate didConnectingFailed:self];
            }
        }
        else {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(receiveDataTimeout:)]) {
                [self.delegate receiveDataTimeout:self];
            }
            
            _sendReq = SendRequestNon;
            self.finishFlag = SendRequestNon;
        }
    }
}

- (void)handleRecivedData:(uint8_t)byte {
    printf("*****receive data: 0x%x\n", byte);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveData" object:[NSString stringWithFormat:@"%x", byte]];
    
    if (self.isStartRecievePakage) {
        if (byte == 0xbb) {
            recieveTXPtr = 1;
            return;
        }
        
        if (recieveTXPtr == 1) {
            if ((int)byte > 32) {
                self.isStartRecievePakage = NO;
                
                return;
            }
            recieveData.recieveDataSize = byte;
        }
        recieveData.recieveBytes[recieveTXPtr] = byte;
        recieveTXPtr++;
        if (recieveTXPtr == recieveData.recieveDataSize &&
            byte == 0xaa) {
            self.isStartRecievePakage = NO;
            [self recieveDataFinished];
        }
        else if (recieveTXPtr == recieveData.recieveDataSize) {
            self.isStartRecievePakage = NO;
        }
    }
    else {
        if (byte == 0xbb) {
            self.isStartRecievePakage = YES;
            recieveTXPtr = 0;
            recieveData.recieveBytes = (uint8_t *)malloc(32 * sizeof(uint8_t));
            recieveData.recieveBytes[recieveTXPtr] = byte;
            recieveTXPtr++;
        }
        else {
            self.isStartRecievePakage = NO;
        }
    }
}

- (void)recieveDataFinished {
    switch (_sendReq) {
        case SendRequestConnection: {
            int checkVerify = recieveData.recieveBytes[2];
            if (checkVerify == 3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(didConnected:)]) {
                        [self.delegate didConnected:self];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(didConnectingFailed:)]) {
                        [self.delegate didConnectingFailed:self];
                    }
                });
                
                return;
            }
        }
            break;
        case SendRequestGetData: {
            int moisture = recieveData.recieveBytes[4];
            int grease = recieveData.recieveBytes[5];
            if (self.isDetecting) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(communicationMgr:didGetMoisture:grease:)]) {
                        [self.delegate communicationMgr:self didGetMoisture:moisture grease:grease];
                    }
                });
                
                self.isDetecting = NO;
            }
        }
            break;
        case SendRequestFinishDetect: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(didFinishDetect:)]) {
                    [self.delegate didFinishDetect:self];
                }
            });
        }
            break;
            
        default:
            break;
    }
    
    self.finishFlag = _sendReq;
}

- (void)startCountingTimeOut {
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    _timeoutCounting = 0;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(countingDown)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)startDetect {
    [self.avAudioSession setActive:YES error:nil];
}

- (void)stopDetect {
    self.isDetecting = NO;
    self.mute = NO;
    
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    [self.avAudioSession setActive:NO error:nil];
}

- (void)sendOvercast {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern0) / sizeof(pattern0[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern0, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendWet {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern1) / sizeof(pattern1[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern1, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendDusk {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern2) / sizeof(pattern2[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern2, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendNight {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern3) / sizeof(pattern3[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern3, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendPattern4 {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern4) / sizeof(pattern4[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern4, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendSOS {
    [self startCountingTimeOut];
    
//    _sendReq = SendRequestConnection;
    _sendReq = SendRequestGetData;
    sendTXPtr = 0;
    sendData.sendDataSize = sizeof(pattern5) / sizeof(pattern5[0]);
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, pattern5, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendGetDataReq {
    [self startCountingTimeOut];
    
    _sendReq = SendRequestGetData;
    //    sendTXPtr = 0;
    //    sendData.sendDataSize = 5;
    //    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    //    memcpy(sendData.sendBytes, getDataBytes, sendData.sendDataSize * sizeof(uint8_t));
    //    self.isDetecting = YES;
    //    self.mute = YES;
}

- (void)sendFinishDetectReq {
    [self startCountingTimeOut];
    
    _sendReq = SendRequestFinishDetect;
    sendTXPtr = 0;
    sendData.sendDataSize = 5;
    sendData.sendBytes = (uint8_t *)malloc(sendData.sendDataSize * sizeof(uint8_t));
    memcpy(sendData.sendBytes, finishDetectBytes, sendData.sendDataSize * sizeof(uint8_t));
    self.isDetecting = YES;
    self.mute = YES;
}

- (void)sendDataFinished {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(didSendDataFinished:)]) {
            [self.delegate didSendDataFinished:self];
        }
    });
}

#pragma mark - Notification Method
- (void)handleAudioInterrupt:(NSNotification *)notification {
    NSInteger reason = 0;
    if ([notification.name isEqualToString:@"AVAudioSessionInterruptionNotification"]) {
        //Posted when an audio interruption occurs.
        reason = [[[notification userInfo] objectForKey:@"AVAudioSessionInterruptionTypeKey"] integerValue];
        if (reason == AVAudioSessionInterruptionTypeBegan) {
            //       Audio has stopped, already inactive
            //       Change state of UI, etc., to reflect non-playing state
            AudioOutputUnitStop(rioUnit);
        }
        
        if (reason == AVAudioSessionInterruptionTypeEnded) {
            //       Make session active
            //       Update user interface
            //       AVAudioSessionInterruptionOptionShouldResume option
            [self.avAudioSession setActive:YES error:nil];
            AudioOutputUnitStart(rioUnit);
        }
        
        
        if ([notification.name isEqualToString:@"AVAudioSessionDidBeginInterruptionNotification"]) {
            //      Posted after an interruption in your audio session occurs.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionDidEndInterruptionNotification"]) {
            //      Posted after an interruption in your audio session ends.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionInputDidBecomeAvailableNotification"]) {
            //      Posted when an input to the audio session becomes available.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionInputDidBecomeUnavailableNotification"]) {
            //      Posted when an input to the audio session becomes unavailable.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        
    };
}

- (void)handleRoutChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if ([userInfo[AVAudioSessionRouteChangeReasonKey] integerValue] == AVAudioSessionRouteChangeReasonCategoryChange) {
        return;
    }
    
    BOOL isPlugIn = NO;
    if ([userInfo[AVAudioSessionRouteChangeReasonKey] integerValue] == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        isPlugIn = YES;
        
        if (!_hasInit) {
            [self commnunicationInit];
        }
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(communicationMgr:didHeadsetPlugIn:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate communicationMgr:self didHeadsetPlugIn:isPlugIn];
        });
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"finishFlag"]) {
        switch (_finishFlag) {
            case SendRequestConnection: {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendGetDataReq];
//                });
            }
                
                break;
            case SendRequestGetData: {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendFinishDetectReq];
//                });
            }
                
                break;
                
            default:
                break;
        }
    }
}

@end
