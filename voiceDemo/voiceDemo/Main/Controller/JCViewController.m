//
//  JCViewController.m
//  voiceDemo
//
//  Created by admin on 16/4/11.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "JCViewController.h"
#import "MyPcmPlayerImp.h"
#import "MyPcmRecorderImp.h"
static const char* const CODE_BOOK = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_";

#define TOKEN_COUNT 24

#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioSession.h>

FILE*   mFile;

ESVoid onSinVoiceRecognizerStart(ESVoid* cbParam) {
    NSLog(@"onSinVoiceRecognizerStart file");
    JCViewController* vc = (__bridge JCViewController*)cbParam;
    vc->mResultCount = 0;
}

ESVoid onSinVoiceRecognizerToken(ESVoid* cbParam, ESInt32 index) {
    NSLog(@"onSinVoiceRecognizerToken, index:%d", index);
    JCViewController* vc = (__bridge JCViewController*)cbParam;
    vc->mResults[vc->mResultCount++] = index;
}

ESVoid onSinVoiceRecognizerEnd(ESVoid* cbParam, ESInt32 result) {
    NSLog(@"onSinVoiceRecognizerEnd, result:%d", result);
    JCViewController* vc = (__bridge JCViewController*)cbParam;
    [vc onRecogToken:vc];
}

ESVoid onSinVoicePlayerStart(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStart, start");
    JCViewController* vc = (__bridge JCViewController*)cbParam;
    [vc onPlayData:vc];
    NSLog(@"onPlayData, end");
}

ESVoid onSinVoicePlayerStop(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStop");
}

SinVoicePlayerCallback gSinVoicePlayerCallback = {onSinVoicePlayerStart, onSinVoicePlayerStop};
SinVoiceRecognizerCallback gSinVoiceRecognizerCallback = {onSinVoiceRecognizerStart, onSinVoiceRecognizerToken, onSinVoiceRecognizerEnd};



@interface JCViewController ()

@end

@implementation JCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    mSinVoicePlayer = SinVoicePlayer_create("com.sinvoice.demo", "SinVoiceDemo", &gSinVoicePlayerCallback, (__bridge ESVoid *)(self));
    mPcmPlayer.create = MyPcmPlayerImp_create;
    mPcmPlayer.start = MyPcmPlayerImp_start;
    mPcmPlayer.stop = MyPcmPlayerImp_stop;
    mPcmPlayer.setParam = MyPcmPlayerImp_setParam;
    mPcmPlayer.destroy = MyPcmPlayerImp_destroy;
    mSinVoicePlayer = SinVoicePlayer_create2("com.sinvoice.for_uzoo", "SinVoice", &gSinVoicePlayerCallback, (__bridge ESVoid *)(self), &mPcmPlayer);
    
        mSinVoiceRecorder = SinVoiceRecognizer_create("com.sinvoice.for_uzoo", "SinVoice", &gSinVoiceRecognizerCallback, (__bridge ESVoid *)(self));
    mPcmRecorder.create = MyPcmRecorderImp_create;
    mPcmRecorder.start = MyPcmRecorderImp_start;
    mPcmRecorder.stop = MyPcmRecorderImp_stop;
    mPcmRecorder.setParam = MyPcmRecorderImp_setParam;
    mPcmRecorder.destroy = MyPcmRecorderImp_destroy;
    mSinVoiceRecorder = SinVoiceRecognizer_create2("com.sinvoice.for_uzoo", "SinVoice", &gSinVoiceRecognizerCallback, (__bridge ESVoid *)(self), &mPcmRecorder);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    mMaxEncoderIndex = SinVoicePlayer_getMaxEncoderIndex(mSinVoicePlayer);
}

-(void)onPlayData:(JCViewController *)data
{
    NSThread* curThrd =[NSThread currentThread];
    NSLog(@"onPlayData, thread:%@",curThrd);
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:data waitUntilDone:FALSE];
}

-(void)updateUI:(JCViewController *)data
{
    NSThread* curThrd =[NSThread currentThread];
    NSLog(@"updateUI, thread:%@",curThrd);
    
    char ch[100] = { 0 };
    for ( int i = 0; i < mPlayCount; ++i ) {
        ch[i] = (char)data->mRates[i];
    }
}

-(void)onRecogToken:(JCViewController *)data
{
    NSThread* curThrd =[NSThread currentThread];
    NSLog(@"onRecordData, thread:%@",curThrd);
    [self performSelectorOnMainThread:@selector(updateRecordUI:) withObject:data waitUntilDone:FALSE];
}

-(void)updateRecordUI:(JCViewController *)data
{
    NSThread* curThrd =[NSThread currentThread];
    NSLog(@"updateUI, thread:%@",curThrd);
    
    if ( mMaxEncoderIndex < 255 ) {
        NSMutableString* str = [[NSMutableString alloc]init];
        for ( int i = 0; i < mResultCount; ++i ) {
            [str appendFormat:@"%c", CODE_BOOK[data->mResults[i]]];
        }
        
        _mRecognisedLable.text = str;
    } else {
        char ch[100] = { 0 };
        for ( int i = 0; i < mResultCount; ++i ) {
            ch[i] = (char)data->mResults[i];
        }
        
        NSString* str = [NSString stringWithCString:ch encoding:NSUTF8StringEncoding];
        _mRecognisedLable.text = str;
    }
}
- (void)playVoid {
    
}
- (IBAction)startPlay:(UIButton *)sender {
    NSLog(@"push start play");
    int index = 0;
    NSString* xx = [NSString stringWithFormat:@"%@",_mPlayTextField.text];
    const char* str = [xx cStringUsingEncoding:NSUTF8StringEncoding];
    
    mPlayCount = (int)strlen(str);
    
    if ( mMaxEncoderIndex < 255 ) {
        int lenCodeBook = (int)strlen(CODE_BOOK);
        int isOK = 1;
        while ( index < mPlayCount) {
            int i = 0;
            for ( i = 0; i < lenCodeBook; ++i ) {
                if ( str[index] == CODE_BOOK[i] ) {
                    mRates[index] = i;
                    break;
                }
            }
            if ( i >= lenCodeBook ) {
                isOK = 0;
                break;
            }
            ++index;
        }
        if ( isOK ) {
            SinVoicePlayer_play(mSinVoicePlayer, mRates, mPlayCount);
        }
    } else {
        int index = 0;
        
        while ( index < mPlayCount) {
            mRates[index] = str[index];
            ++index;
        }
        SinVoicePlayer_play(mSinVoicePlayer, mRates, mPlayCount);
    }

    
}

- (IBAction)stopPlay:(UIButton *)sender {
    NSLog(@"push stop play");
    SinVoicePlayer_stop(mSinVoicePlayer);
}

- (IBAction)startRecord:(UIButton *)sender {
    NSLog(@"push start record");
    
    SinVoiceRecognizer_start(mSinVoiceRecorder, TOKEN_COUNT);
    mFile = fopen([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record1.pcm"].UTF8String, "wb");
    
}

- (IBAction)stopRecord:(UIButton *)sender {
    NSLog(@"push stop record");
    SinVoiceRecognizer_stop(mSinVoiceRecorder);
    
    if ( ES_NULL != mFile ) {
        fclose(mFile);
        mFile = ES_NULL;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
