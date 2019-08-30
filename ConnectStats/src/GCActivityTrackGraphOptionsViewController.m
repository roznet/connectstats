//  MIT Licence
//
//  Created on 02/03/2013.
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

#import "GCActivityTrackGraphOptionsViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCFormattedFieldText.h"


#define GC_SECTION_FIELD            0
#define GC_SECTION_XFIELD           1
#define GC_SECTION_MOVINGAVERAGE    2
#define GC_SECTION_LINEFIELD        3
#define GC_SECTION_OTHERFIELD       4
#define GC_SECTION_DISTANCEAXIS     5
#define GC_SECTION_END              6

#define GC_ROW_FIELD        0
#define GC_ROW_SMOOTHING    1

#define GC_ID(indexPath) [indexPath section]*100+[indexPath row]

@interface GCActivityTrackGraphOptionsViewController ()

@end

@implementation GCActivityTrackGraphOptionsViewController

-(void)dealloc{
    [_viewController release];
    [super dealloc];
}
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorGroupedTable];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return GC_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == GC_SECTION_MOVINGAVERAGE || section == GC_SECTION_DISTANCEAXIS? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GridCell";
    GCCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"GridCell"];
    if (!cell) {
        cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.section==GC_SECTION_MOVINGAVERAGE) {
        [cell setupForRows:1 andCols:1];
        GCActivityTrackOptions * option = [self.viewController currentOption];
        NSString * maStr = option.movingAverage==0.?@"None":[NSString stringWithFormat:@"%d points", (int)option.movingAverage];
        GCFormattedFieldText * ma = [GCFormattedFieldText formattedFieldText:@"Moving Average"
                                                                       value:maStr
                                                                     forSize:16.];
        ma.valueFont = [GCViewConfig boldSystemFontOfSize:16.];
        [cell labelForRow:0 andCol:0].attributedText = [ma attributedString];
    }else if(indexPath.section==GC_SECTION_DISTANCEAXIS){
        [cell setupForRows:1 andCols:1];
        GCActivityTrackOptions * option = [self.viewController currentOption];
        NSString * axis = option.distanceAxis ? @"Use distance axis" : @"Use time axis";
        [cell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:axis attribute:@selector(attributeBold16)];
    }else{
        if (indexPath.row == GC_ROW_FIELD) {
            [cell setupForRows:2 andCols:1];
            GCField * field = [self fieldForSection:indexPath.section];
            NSString * desc =  field ? field.displayName : NSLocalizedString(@"None", @"Field List description");
            GCFormattedFieldText * fi = [GCFormattedFieldText formattedFieldText:[self labelForSection:indexPath.section]
                                                                           value:desc forSize:16.];
            fi.valueFont = [GCViewConfig boldSystemFontOfSize:16.];

            [cell labelForRow:0 andCol:0].attributedText = [fi attributedString];
            [cell labelForRow:1 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:[self descriptionForSection:indexPath.section]
                                                                                            attributes:[GCViewConfig attribute14Gray]] autorelease];
        }else{
            [cell setupForRows:1 andCols:1];
            gcSmoothingFlag flag = [self smoothingForSection:indexPath.section];

            NSString * val = [GCActivityTrackOptions smoothingDescriptions][flag];
            GCFormattedFieldText * fi = [GCFormattedFieldText formattedFieldText:@"Smoothing"
                                                                           value:val forSize:16.];
            fi.valueFont = [GCViewConfig boldSystemFontOfSize:16.];

            [cell labelForRow:0 andCol:0].attributedText = [fi attributedString];

        }

    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rv = 44.;
    if (tableView.rowHeight > 0) {
        if (indexPath.section==GC_SECTION_MOVINGAVERAGE || indexPath.row==GC_ROW_SMOOTHING) {
            rv = tableView.rowHeight*0.75;
        }else{
            rv = tableView.rowHeight;
        }
    }
    return rv;
}
-(NSString*)descriptionForSection:(NSUInteger)section{
    NSArray * names = @[@"Main data displayed",
                        @"Data for x axis in a scatter plot", @"",
                        @"Data for the color of the line",
                        @"Data for a second plot"];
    if (section < names.count) {
        return names[section];
    }
    return nil;
}

-(NSString*)labelForSection:(NSUInteger)section{
    NSArray * names = @[@"Field", @"X Field", @"Moving Average", @"Line Field",@"Other Field"];
    if (section < names.count) {
        return names[section];
    }
    return @"Unknown";
}

-(void)updateFieldForSection:(NSUInteger)section field:(GCField*)flag{
    GCActivityTrackOptions * option = [self.viewController currentOption];
    switch (section) {
        case GC_SECTION_FIELD:
            option.field = flag;
            break;
        case GC_SECTION_XFIELD:
            option.x_field =flag;
            break;
        case GC_SECTION_LINEFIELD:
            option.l_field =flag;
            break;
        case GC_SECTION_OTHERFIELD:
            option.o_field = flag;
        default:
            break;
    }
}

-(GCField*)fieldForSection:(NSUInteger)section{
    GCField * flag = nil;
    GCActivityTrackOptions * option = [self.viewController currentOption];
    switch (section) {
        case GC_SECTION_FIELD:
            flag = option.field;
            break;
        case GC_SECTION_XFIELD:
            flag = option.x_field;
            break;
        case GC_SECTION_LINEFIELD:
            flag = option.l_field;
            break;
        case GC_SECTION_OTHERFIELD:
            flag = option.o_field;
            break;
        default:
            flag = nil;
            break;
    }
    return flag;
}

-(gcSmoothingFlag)smoothingForSection:(NSUInteger)section{
    gcSmoothingFlag flag = gcSmoothingAuto;
    GCActivityTrackOptions * option = [self.viewController currentOption];
    switch (section) {
        case GC_SECTION_FIELD:
            flag = option.smoothing;
            break;
        case GC_SECTION_XFIELD:
            flag = option.x_smoothing;
            break;
        case GC_SECTION_LINEFIELD:
            flag = option.l_smoothing;
            break;
        case GC_SECTION_OTHERFIELD:
            flag = option.o_smoothing;
            break;
        default:
            flag = gcSmoothingAuto;
            break;
    }
    return flag;
}

-(void)updateSmoothingForSection:(NSUInteger)section field:(gcSmoothingFlag)flag{
    GCActivityTrackOptions * option = [self.viewController currentOption];
    switch (section) {
        case GC_SECTION_FIELD:
            option.smoothing = flag;
            break;
        case GC_SECTION_XFIELD:
            option.x_smoothing =flag;
            break;
        case GC_SECTION_LINEFIELD:
            option.l_smoothing =flag;
            break;
        case GC_SECTION_OTHERFIELD:
            option.o_smoothing = flag;
        default:
            break;
    }
}

-(BOOL)isFieldSection:(NSUInteger)section{
    return section == GC_SECTION_LINEFIELD||section==GC_SECTION_FIELD||section==GC_SECTION_XFIELD||section==GC_SECTION_OTHERFIELD;
}

#pragma mark - Table view delegate

-(NSArray*)availableForSection:(NSUInteger)section{
    GCActivity * activity = self.viewController.activity;

    NSArray * available =[activity availableTrackFields];
    if (section != GC_SECTION_FIELD) {
        available = [@[@0] arrayByAddingObjectsFromArray:available];
        GCField * skip = [self fieldForSection:GC_SECTION_FIELD];
        available = [available objectsAtIndexes:[available indexesOfObjectsPassingTest:^BOOL(GCField* obj, NSUInteger idx, BOOL *stop) {
            return [obj isKindOfClass:[NSNumber class]] || ![obj isEqualToField:skip];
        }]];
    }
    return available;
}

-(NSArray*)availableMovingAverage{
    return @[@0,@30,@60,@120,@300,@600];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isFieldSection:indexPath.section]) {
        if (indexPath.row == GC_ROW_FIELD) {
            GCField * current = [self fieldForSection:indexPath.section];

            GCCellEntryListViewController * entry = [[[GCCellEntryListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            NSArray * available = [self availableForSection:indexPath.section];
            NSMutableArray * formatted = [NSMutableArray arrayWithCapacity:available.count];
            NSUInteger selected= 0;
            NSUInteger i = 0;
            for (id one in available) {
                if ([one isKindOfClass:[GCField class]]) {
                    GCField * field = one;
                    [formatted addObject:field.displayName];
                    if (current && [field isEqualToField:current]) {
                        selected = i;
                    }
                }else{
                    [formatted addObject:NSLocalizedString(@"None", @"Field List Choice")];
                    if (current == nil) {
                        selected = i;
                    }
                }
                i++;
            }
            entry.choices = formatted;
            entry.selected = selected;
            [entry setIdentifierInt:GC_ID(indexPath)];
            entry.entryFieldDelegate = self;
            [self.navigationController pushViewController:entry animated:YES];
        }else if (indexPath.row == GC_ROW_SMOOTHING){
            gcSmoothingFlag current = [self smoothingForSection:indexPath.section];
            GCCellEntryListViewController * entry = [[[GCCellEntryListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            NSArray * available = [GCActivityTrackOptions smoothingDescriptions];
            entry.choices = available;
            entry.selected = current;
            [entry setIdentifierInt:GC_ID(indexPath)];
            entry.entryFieldDelegate = self;
            [self.navigationController pushViewController:entry animated:YES];


        }
    }else if (indexPath.section==GC_SECTION_MOVINGAVERAGE){
        GCCellEntryListViewController * entry = [[[GCCellEntryListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        GCActivityTrackOptions * option = [self.viewController currentOption];

        NSArray * available = [self availableMovingAverage];
        NSMutableArray * formatted = [NSMutableArray arrayWithCapacity:available.count];
        NSUInteger selected= 0;
        NSUInteger i = 0;
        for (NSNumber * idx in available) {
            NSUInteger candidate = idx.integerValue;
            [formatted addObject:candidate == 0 ? @"None" : [NSString stringWithFormat:@"%d points", (int)candidate]];
            if ( option.movingAverage == candidate) {
                selected = i;
            }
            i++;
        }
        entry.choices = formatted;
        entry.selected = selected;
        [entry setIdentifierInt:GC_ID(indexPath)];
        entry.entryFieldDelegate = self;
        [self.navigationController pushViewController:entry animated:YES];

    }else if(indexPath.section==GC_SECTION_DISTANCEAXIS){
        GCActivityTrackOptions * option = [self.viewController currentOption];
        option.distanceAxis = ! option.distanceAxis;
        [self.tableView reloadData];
        [self.viewController refreshForCurrentOption];
    }
}


-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    NSUInteger section = [cell identifierInt]/100;
    NSUInteger row     = [cell identifierInt]%100;

    if ([self isFieldSection:section]) {
        if (row == GC_ROW_FIELD) {
            NSArray * available = [self availableForSection:[cell identifierInt]];
            id one = available[ [cell selected] ];
            GCField * field = nil;
            if ([one isKindOfClass:[GCField class]]) {
                field = one;
            }
            [self updateFieldForSection:section field:field];
            [self.viewController refreshForCurrentOption];
        }else{
            [self updateSmoothingForSection:section field:(gcSmoothingFlag)[cell selected]];
            [self.viewController refreshForCurrentOption];
        }
    }else if(section==GC_SECTION_MOVINGAVERAGE){
        NSArray * available = [self availableMovingAverage];
        NSUInteger new = [available[[cell selected]] integerValue];
        GCActivityTrackOptions * option = [self.viewController currentOption];
        option.movingAverage = new;

        [self.viewController refreshForCurrentOption];
    }
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return self.navigationController.navigationItem;
}
@end
