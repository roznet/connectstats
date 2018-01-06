//  MIT Licence
//
//  Created on 07/04/2014.
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

#import "GCTableHeaderFieldsCategory.h"
#import "GCFieldsCategory.h"
#import "GCViewConfig.h"
#import "GCViewIcons.h"

@implementation GCTableHeaderFieldsCategory


+(UIView*)tableView:(UITableView *)tableView viewForHeaderCategory:(NSString*)category{

    CGFloat width             = CGRectGetWidth(tableView.bounds);
    CGFloat height            = [GCTableHeaderFieldsCategory tableView:tableView heightForHeaderCategory:category];
    UIView *container         = [[[UIView alloc] initWithFrame:CGRectMake(0,0,width,height)] autorelease];
    NSString *title           = [GCFieldsCategory displayNameForCategory:category];
    container.backgroundColor = [GCViewConfig backgroundForCategory:category];
    if (title) {
        UIImage * image = [GCViewIcons categoryIconFor:category];
        if (image) {
            UIImageView * iview = [[UIImageView alloc] initWithFrame:CGRectMake(2., (height-25.)/2., 25., 25.)];
            iview.image         = image;
            iview.contentMode   = UIViewContentModeScaleAspectFit;
            [container addSubview:iview];
            [iview release];
        }

        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(32.,0,width-27.,height)] autorelease];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor       = [UIColor blackColor];
        headerLabel.shadowColor     = [UIColor darkGrayColor];
        headerLabel.attributedText  = [GCViewConfig attributedString:title attribute:@selector(attributeBold14)];
        [container addSubview:headerLabel];

    }

    return container;
}

+(CGFloat)tableView:(UITableView *)tableView heightForHeaderCategory:(NSString*)category{

    return category ? 32. : 0.;
}

@end
