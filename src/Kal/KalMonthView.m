/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "KalPrivate.h"

//extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame andTileSize:(CGSize)size;
{
    if ((self = [super initWithFrame:frame])) {
        tileAccessibilityFormatter = [[NSDateFormatter alloc] init];
        [tileAccessibilityFormatter setDateFormat:@"EEEE, MMMM d"];
        self.tileSize = size;
        self.opaque = NO;
        self.clipsToBounds = YES;
        for (int i=0; i<6; i++) {
            for (int j=0; j<7; j++) {
                CGRect r = CGRectMake(j*_tileSize.width, i*_tileSize.height, _tileSize.width, _tileSize.height);
                KalTileView * tileView = [[[KalTileView alloc] initWithFrame:r andTileSize:self.tileSize] autorelease];
                [self addSubview:tileView];
            }
        }
    }
    return self;
}

-(void)setupFrame:(CGRect)frame{
    int tileNum = 0;
    for (int i=0; i<6; i++) {
        for (int j=0; j<7; j++) {
            CGRect r = CGRectMake(j*_tileSize.width, i*_tileSize.height, _tileSize.width, _tileSize.height);
            KalTileView *tile = [self.subviews objectAtIndex:tileNum];
            tile.tileSize = self.tileSize;
            tile.frame = r;
            tileNum++;

        }
    }
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
  int tileNum = 0;
  NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };
  
  for (int i=0; i<3; i++) {
    for (KalDate *d in dates[i]) {
      KalTileView *tile = [self.subviews objectAtIndex:tileNum];
      [tile resetState];
      tile.date = d;
      tile.type = dates[i] != mainDates
                    ? KalTileTypeAdjacent
                    : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
      tileNum++;
    }
  }
  
  numWeeks = ceilf(tileNum / 7.f);
  [self sizeToFit];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,_tileSize}, [[UIImage imageNamed:kalBundleFile(@"kal_tile.png")] CGImage]);
    [[UIColor darkGrayColor] setStroke];
    [[UIColor darkGrayColor] setFill];  
    CGContextSetLineWidth(ctx, 0.5f);
    for (int i=0; i<6; i++) {
        CGContextMoveToPoint(ctx, 0., i*_tileSize.height);
        CGContextAddLineToPoint(ctx, _tileSize.width*7.,i*_tileSize.height);
        CGContextStrokePath(ctx);
    }
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) {
      tile = t;
      break;
    }
  }
  NSAssert1(tile != nil, @"Failed to find corresponding tile for date %@", date);
  
  return tile;
}

- (void)sizeToFit
{
  self.height = 1.f + _tileSize.height * numWeeks;
}

- (void)markTilesForDates:(NSArray *)dates andSource:(id<KalDataSource>)source
{
    for (KalTileView *tile in self.subviews)
    {
        tile.marked = [dates containsObject:tile.date];
        tile.dataSource = source;
        NSString *dayString = [tileAccessibilityFormatter stringFromDate:[tile.date NSDate]];
        if (dayString) {
            NSMutableString *helperText = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
            if ([tile.date isToday])
                [helperText appendFormat:@"%@ ", NSLocalizedString(@"Today", @"Accessibility text for a day tile that represents today")];
            [helperText appendString:dayString];
            if (tile.marked)
                [helperText appendFormat:@". %@", NSLocalizedString(@"Marked", @"Accessibility text for a day tile which is marked with a small dot")];
            [tile setAccessibilityLabel:helperText];
        }
        [tile setNeedsDisplay];
    }
}

#pragma mark -

- (void)dealloc
{
  [tileAccessibilityFormatter release];
  [super dealloc];
}

@end
