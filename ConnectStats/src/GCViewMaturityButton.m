//  MIT Licence
//
//  Created on 07/07/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "GCViewMaturityButton.h"
#import "GCAppGlobal.h"

@implementation GCViewMaturityButton

+(GCViewMaturityButton*)maturityButtonForDelegate:(NSObject<GCViewMaturityButtonDelegate>*)del{
    GCViewMaturityButton * rv = [[[GCViewMaturityButton alloc] init] autorelease];
    if (rv) {
        rv.delegate = del;
        rv.fromButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All", @"MaturityButton")
                                                              style:UIBarButtonItemStylePlain
                                                             target:rv
                                                             action:@selector(nextFromDate)] autorelease];
    }
    return rv;
}


-(void)dealloc{
    [_delegate release];
    [_fromButtonItem release];
    [super dealloc];
}

-(NSArray*)fromDateChoices{
    if (self.delegate.calendarUnit == NSCalendarUnitMonth) {
        return @[@"All",@"3m",@"6m",@"1y"];
    }else if(self.delegate.calendarUnit == NSCalendarUnitYear){
        return @[@"All",@"1y",@"2y"];
    }else {
        return @[@"All",@"3m",@"6m",@"1y"];
    }
}

-(void)setCurrentFromDateChoice:(NSString*)choice{
    self.fromButtonItem.title = choice;
    [self refreshDelegate];

}

-(NSString*)currentFromDateChoice{
    NSArray * choices = [self fromDateChoices];
    NSString * rv = nil;
    for (NSString * one in choices) {
        if ([one isEqualToString:self.fromButtonItem.title]) {
            rv = one;
            break;
        }
    }
    if (rv == nil) {
        rv = NSLocalizedString(@"All", @"MaturityButton");
        self.fromButtonItem.title = rv;
    }
    return rv;
}

-(NSDate*)currentFromDate{
    NSString * choice = [self currentFromDateChoice];
    if ([choice isEqualToString:NSLocalizedString(@"All", @"MaturityButton")]) {
        return nil;
    }
    NSDateComponents * comp = [NSDateComponents dateComponentsFromString:[NSString stringWithFormat:@"-%@",choice]];
    NSDate * rv = [[NSDate date] dateByAddingGregorianComponents:comp];

    return rv;
}

-(void)nextFromDate{
    NSArray * choices = [self fromDateChoices];

    NSUInteger cur = 0;
    for (cur=0; cur<choices.count; cur++) {
        NSString * one = choices[cur];
        if ([one isEqualToString:self.fromButtonItem.title]) {
            break;
        }
    }
    if (cur+1<choices.count) {
        cur=cur+1;
    }else{
        cur=0;
    }

    self.fromButtonItem.title = choices[cur];
    [self refreshDelegate];
}

-(void)refreshDelegate{
    if (self.useWorkerThread) {
        dispatch_async([GCAppGlobal worker],^(){
            [self.delegate configureGraph];
        });
    }else{
        [self.delegate configureGraph];
    }
}
@end
