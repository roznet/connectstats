//  MIT Licence
//
//  Created on 13/12/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "TSTennisTagSelectionView.h"
#import "TSTennisEvent.h"
#import "TSTennisFields.h"
#import "TSTagIcons.h"


@implementation TSTennisTagSelectionView


+(TSTennisTagSelectionView*)tagSelectionViewFor:(NSObject<RZIconPanelViewDelegate>*)delegate{
    NSArray * items = @[
                        [RZIconPanelItem itemForImage:[TSTagIcons tagIcon:tsTagIconHappy]
                                                label:[TSTennisFields tagDescription:tsTagStar]
                                        andIdentifier:tsTagStar],
                        [RZIconPanelItem itemForImage:[TSTagIcons tagIcon:tsTagIconUpset]
                                                label:[TSTennisFields tagDescription:tsTagUpset]
                                        andIdentifier:tsTagUpset],
                        [RZIconPanelItem itemForImage:[TSTagIcons tagIcon:tsTagIconThinking]
                                                label:[TSTennisFields tagDescription:tsTagReview]
                                        andIdentifier:tsTagReview],

                        ];
    TSTennisTagSelectionView * rv = [[TSTennisTagSelectionView alloc] initFor:items delegate:delegate];
    return  rv;
}
@end
