//
//  ALScanViewPluginConfig.h
//  Anyline
//
//  Created by Daniel Albertini on 09.05.18.
//  Copyright © 2018 9Yards GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALScanFeedbackConfig.h"
#import "ALCutoutConfig.h"

@interface ALScanViewPluginConfig : NSObject

@property (nonatomic, strong) ALScanFeedbackConfig * _Nonnull scanFeedbackConfig;
@property (nonatomic, strong) ALCutoutConfig * _Nonnull cutoutConfig;

@property (nonatomic, assign) BOOL cancelOnResult;

- (instancetype _Nullable)initWithDictionary:(NSDictionary * _Nonnull)configDict;
- (instancetype _Nullable)initWithScanFeedbackConfig:(ALScanFeedbackConfig * _Nonnull)scanFeedbackConfig
                                        cutoutConfig:(ALCutoutConfig * _Nonnull)cutoutConfig
                                      cancelOnResult:(BOOL)cancelOnResult;

+ (_Nonnull instancetype)defaultScanViewPluginConfig;

+ (_Nonnull instancetype)defaultDocumentScannerConfig;
+ (_Nonnull instancetype)defaultBarcodeConfig;
+ (_Nonnull instancetype)defaultLicensePlateConfig;
+ (_Nonnull instancetype)defaultOCRConfig;
+ (_Nonnull instancetype)defaultMRZConfig;
+ (_Nonnull instancetype)defaultDrivingLicenseConfig;
+ (_Nonnull instancetype)defaultMeterConfig;

@end
