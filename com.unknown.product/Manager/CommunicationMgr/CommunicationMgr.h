//
//  CommunicationMgr.h
//  SkinDetect
//
//  Created by Q on 14-9-17.
//  Copyright (c) 2014年 EADING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@class CommunicationMgr;

@protocol CommunicationMgrDelegate <NSObject>

@optional
- (void)didSendDataFinished:(CommunicationMgr *)mgr;
- (void)didConnected:(CommunicationMgr *)mgr;
- (void)communicationMgr:(CommunicationMgr *)mgr didGetMoisture:(int)moisture grease:(int)grease;
- (void)didFinishDetect:(CommunicationMgr *)mgr;
- (void)receiveDataTimeout:(CommunicationMgr *)mgr;
- (void)didConnectingFailed:(CommunicationMgr *)mgr;
- (void)communicationMgr:(CommunicationMgr *)mgr didHeadsetPlugIn:(BOOL)isPlugIn;

@end

@interface CommunicationMgr : NSObject

@property (weak, nonatomic) id<CommunicationMgrDelegate>delegate;

@property (nonatomic) SendRequest sendReq;

+ (instancetype)sharedInstance;
+ (BOOL)isRoutConnect;

- (void)commnunicationInit;
- (void)clear;
- (void)startDetect;
- (void)stopDetect;
- (void)sendStartDetectReq;

@end
