//
//  ALRecordNumberScanViewController.m
//  AnylineExamples
//
//  Created by Daniel Albertini on 04/02/16.
//  Copyright © 2016 9yards GmbH. All rights reserved.
//

#import "ALRecordNumberScanViewController.h"
#import <Anyline/Anyline.h>
#import "ALBaseViewController.h"
#import "NSUserDefaults+ALExamplesAdditions.h"
#import "ALAppDemoLicenses.h"

// This is the license key for the examples project used to set up Aynline below
NSString * const kRecordNumberLicenseKey = kDemoAppLicenseKey;
// The controller has to conform to <AnylineOCRModuleDelegate> to be able to receive results
@interface ALRecordNumberScanViewController ()<ALOCRScanPluginDelegate, ALInfoDelegate>

// The Anyline plugin used for OCR
@property (nonatomic, strong) ALOCRScanViewPlugin *recordScanViewPlugin;
@property (nonatomic, strong) ALOCRScanPlugin *recordScanPlugin;
@property (nullable, nonatomic, strong) ALScanView *scanView;

@end

@implementation ALRecordNumberScanViewController
/*
 We will do our main setup in viewDidLoad. Its called once the view controller is getting ready to be displayed.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the background color to black to have a nicer transition
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Record Number";
    
    // Initializing the module. Its a UIView subclass. We set the frame to fill the whole screen
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame = CGRectMake(frame.origin.x, frame.origin.y + self.navigationController.navigationBar.frame.size.height, frame.size.width, frame.size.height - self.navigationController.navigationBar.frame.size.height);
    
    ALOCRConfig *config = [[ALOCRConfig alloc] init];
    config.charHeight = ALRangeMake(22, 105);
    NSString *engTraineddata = [[NSBundle mainBundle] pathForResource:@"eng_no_dict" ofType:@"traineddata"];
    NSString *deuTraineddata = [[NSBundle mainBundle] pathForResource:@"deu" ofType:@"traineddata"];
    [config setLanguages:@[engTraineddata,deuTraineddata] error:nil];
    config.charWhiteList = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-.";
    config.minConfidence = 75;
    config.validationRegex = @"^([A-Z]+\\s*-*\\s*)?[0-9A-Z-\\s\\.]{3,}$";
    config.scanMode = ALLine;
    config.removeSmallContours = NO;
    
    NSError *error = nil;
    
    self.recordScanPlugin = [[ALOCRScanPlugin alloc] initWithPluginID:@"ANYLINE_OCR"
                                                           licenseKey:kRecordNumberLicenseKey
                                                             delegate:self
                                                            ocrConfig:config
                                                                error:&error];
    NSAssert(self.recordScanPlugin, @"Setup Error: %@", error.debugDescription);
    [self.recordScanPlugin addInfoDelegate:self];
    
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"record_number_config" ofType:@"json"];
    ALScanViewPluginConfig *scanViewPluginConfig = [ALScanViewPluginConfig configurationFromJsonFilePath:confPath];
    
    self.recordScanViewPlugin = [[ALOCRScanViewPlugin alloc] initWithScanPlugin:self.recordScanPlugin
                                                           scanViewPluginConfig:scanViewPluginConfig];
    NSAssert(self.recordScanViewPlugin, @"Setup Error: %@", error.debugDescription);
    
    self.scanView = [[ALScanView alloc] initWithFrame:frame scanViewPlugin:self.recordScanViewPlugin];
    
    // After setup is complete we add the module to the view of this view controller
    [self.view addSubview:self.scanView];
    [self.view sendSubviewToBack:self.scanView];
    
    //Start Camera:
    [self.scanView startCamera];
    [self startListeningForMotion];
    
    self.controllerType = ALScanHistoryRecordNumber;
}

/*
 This method will be called once the view controller and its subviews have appeared on screen
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // We use this subroutine to start Anyline. The reason it has its own subroutine is
    // so that we can later use it to restart the scanning process.
    [self startAnyline];
    
    //Update Position of Warning Indicator
    [self updateWarningPosition:
     self.recordScanViewPlugin.cutoutRect.origin.y +
     self.recordScanViewPlugin.cutoutRect.size.height +
     self.recordScanViewPlugin.frame.origin.y +
     120];
}

/*
 Cancel scanning to allow the module to clean up
 */
- (void)viewWillDisappear:(BOOL)animated {
    [self.recordScanViewPlugin stopAndReturnError:nil];
}

/*
 This method is used to tell Anyline to start scanning. It gets called in
 viewDidAppear to start scanning the moment the view appears. Once a result
 is found scanning will stop automatically (you can change this behaviour
 with cancelOnResult:). When the user dismisses self.identificationView this
 method will get called again.
 */
- (void)startAnyline {
    NSError *error;
    BOOL success = [self.recordScanViewPlugin startAndReturnError:&error];
    if( !success ) {
        // Something went wrong. The error object contains the error description
        NSAssert(success, @"Start Scanning Error: %@", error.debugDescription);
    }
    
    self.startTime = CACurrentMediaTime();
}

#pragma mark -- AnylineOCRModuleDelegate
/*
 This is the main delegate method Anyline uses to report its results
 */
- (void)anylineOCRScanPlugin:(ALOCRScanPlugin *)anylineOCRScanPlugin didFindResult:(ALOCRResult *)result {
    [self anylineDidFindResult:result.result barcodeResult:@"" image:result.image scanPlugin:anylineOCRScanPlugin viewPlugin:self.recordScanViewPlugin completion:^{
        ALBaseViewController *vc = [[ALBaseViewController alloc] init];
        vc.result = result.result;
        NSString *url = [NSString stringWithFormat:@"https://www.google.at/search?q=\"%@\" site:discogs.com OR site:musbrainz.org OR site:allmusic.com", result.result];
        [vc startWebSearchWithURL:url];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)anylineScanPlugin:(ALAbstractScanPlugin *)anylineScanPlugin reportInfo:(ALScanInfo *)info{
    if ([info.variableName isEqualToString:@"$brightness"]) {
        [self updateBrightness:[info.value floatValue] forModule:self.recordScanViewPlugin];
    }
}


@end
