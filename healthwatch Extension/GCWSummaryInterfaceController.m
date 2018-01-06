//
//  InterfaceController.m
//  healthwatch Extension
//
//  Created by Brice Rosenzweig on 09/08/2015.
//  Copyright © 2015 Brice Rosenzweig. All rights reserved.
//

#import "GCWSummaryInterfaceController.h"
#import "GCWExtensionDelegate.h"

@interface GCWSummaryInterfaceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *image;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *image2;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *label2;

@end


@implementation GCWSummaryInterfaceController



- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    GCWExtensionDelegate * delegate = (GCWExtensionDelegate*)[WKExtension sharedExtension].delegate;
    if (delegate) {
        delegate.mainInterface = self;
    }
    [self updateSummaryImages];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Update UI

-(void)updateForContext{
    [self updateSummaryImages];
}
-(nullable NSString*)writeableFilePathIfExists:(NSString*)aName{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    NSString    *   rv = [documentsDirectory stringByAppendingPathComponent:aName];
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:rv]){
        rv = nil;
    }
    return( rv );
}

-(void)updateSummaryImages{
    [self.label setText:@"Progression"];
    [self.label2 setText:@"Performance"];
    NSString * imgPath = [self writeableFilePathIfExists:@"summary.png"];
    if( imgPath){
        [self.image setImageData:[NSData dataWithContentsOfFile:imgPath]];
    }
    NSString * imgPath2 = [self writeableFilePathIfExists:@"performance.png"];
    if (imgPath) {
        [self.image2 setImage:[UIImage imageWithContentsOfFile:imgPath2]];
    }
    
}
@end



