//
//  JCViewController.h
//  voiceDemo
//
//  Created by admin on 16/4/11.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinVoicePlayer.h"
#import "SinVoiceRecognizer.h"
#include "ESPcmPlayer.h"
#include "ESPcmRecorder.h"

@interface JCViewController : UIViewController
{
@private
    SinVoicePlayer*     mSinVoicePlayer;
    SinVoiceRecognizer* mSinVoiceRecorder;
    ESPcmPlayer         mPcmPlayer;
    ESPcmRecorder       mPcmRecorder;
    
@public
    int mRates[100];
    int mPlayCount;
    int mResults[100];
    int mResultCount;
    int mMaxEncoderIndex;
}

@property (weak, nonatomic) IBOutlet UITextField *mPlayTextField;
@property (weak, nonatomic) IBOutlet UILabel *mRecognisedLable;

-(void)onPlayData:(JCViewController *)data;
-(void)onRecogToken:(JCViewController *)data;
@end
