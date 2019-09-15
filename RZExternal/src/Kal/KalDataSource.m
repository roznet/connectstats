/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDataSource.h"
#import "KalPrivate.h"

@implementation SimpleKalDataSource

+ (SimpleKalDataSource*)dataSource
{
  return [[[[self class] alloc] init] autorelease];
}

#pragma mark UITableViewDataSource protocol conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"MyCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  cell.textLabel.text = NSLocalizedString(@"Filler text", @"Calendar");
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
  [delegate loadedDataSource:self];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
  return [NSArray array];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
  // do nothing
}

- (void)removeAllItems
{
  // do nothing
}

- (BOOL)drawMarkerInRect:(CGRect)rect forDate:(NSDate*)adate selected:(BOOL)asel{
    return false;
}
- (NSArray*)rightButtonItems{
    return nil;
}
-(NSArray*)leftButtonItems{
    return nil;
}
-(NSString*)title{
    return @"Calendar";
}
-(UIFont*)systemFontOfSize:(CGFloat)size{
    return [UIFont systemFontOfSize:size];
}
-(UIFont*)boldSystemFontOfSize:(CGFloat)size{
    return [UIFont boldSystemFontOfSize:size];
}

- (UIColor*)backgroundColor{
    return [UIColor grayColor];
}
- (UIColor*)weekdayTextColor{
    return [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
}
- (UIColor*)dayCurrentMonthTextColor{
    return [UIColor blackColor];
}
- (UIColor*)dayAdjacentMonthTextColor{
    return [UIColor darkGrayColor];
}
- (UIColor*)separatorColor{
    return [UIColor colorWithRed:0.63f green:0.65f blue:0.68f alpha:1.f];
}

-(UIColor*)daySelectedTextColor{
    return [UIColor whiteColor];
}
-(UIColor*)tileColor{
    return self.backgroundColor;
}
-(UIColor*)tileSelectedColor{
    //0x1843c7
    return [UIColor colorWithRed:0.094 green:0.263 blue:0.780 alpha:1.00];
}
-(UIColor*)tileTodayColor{
    //0x7788a2
    return [UIColor colorWithRed:0.467 green:0.533 blue:0.635 alpha:1.00];
}
-(UIColor*)tileTodaySelectedColor{
    //0x3b7dde
    return [UIColor colorWithRed:0.231 green:0.490 blue:0.871 alpha:1.00];
}
-(UIColor*)primaryTextColor{
    return [UIColor blackColor];
}
-(UIColor*)secondaryTextColor{
    return [UIColor darkGrayColor];
}

@end
