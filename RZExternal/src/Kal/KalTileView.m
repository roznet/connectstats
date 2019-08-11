/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"


//extern const CGSize kTileSize;

@implementation KalTileView

@synthesize date,dataSource;

- (id)initWithFrame:(CGRect)frame andTileSize:(CGSize)size
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.tileSize = size;
        origin = frame.origin;
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityTraits:UIAccessibilityTraitButton];
        [self resetState];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat fontSize = 24.f;
    UIColor *textColor = nil;
    UIColor *tileColor = nil;
    
    if ([self isToday] && self.selected) {
        tileColor = self.dataSource.tileTodaySelectedColor;
        textColor = self.dataSource.dayCurrentMonthTextColor;
    } else if ([self isToday] && !self.selected) {
        tileColor = self.dataSource.tileTodayColor;
        textColor = self.dataSource.dayCurrentMonthTextColor;
    } else if (self.selected) {
        textColor = self.dataSource.daySelectedTextColor;
        tileColor = self.dataSource.tileSelectedColor;
    } else if (self.belongsToAdjacentMonth) {
        textColor = self.dataSource.dayAdjacentMonthTextColor;
        tileColor = self.dataSource.tileColor;
    } else {
        textColor = self.dataSource.dayCurrentMonthTextColor;
        tileColor = self.dataSource.tileColor;
    }
    
    UIFont * systemFont = nil;
    if( [self.dataSource respondsToSelector:@selector(systemFontOfSize:)]){
        systemFont = [self.dataSource systemFontOfSize:fontSize];
    }else{
        systemFont = [UIFont systemFontOfSize:fontSize];
    }
    NSDictionary * attr = @{NSFontAttributeName:systemFont,NSForegroundColorAttributeName:textColor};

    // Draw Background
    [tileColor setFill];
    CGContextFillRect(ctx, rect);
    
    // Draw Separator line
    [self.dataSource.separatorColor setFill];
    CGRect line;
    line.origin = CGPointMake(0.f, rect.size.height - 1.f);
    line.size = CGSizeMake(rect.size.width, 1.f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), line);
    
    if([dataSource respondsToSelector:@selector(drawBackgroundInRect:forDate:selected:)]){
        [dataSource drawBackgroundInRect:rect forDate:[date NSDate] selected:self.selected];
    }

    if (flags.marked){
        CGRect markerRect = CGRectMake(2.f,_tileSize.height-11.f ,_tileSize.width-4.f,7.f);
        if (dataSource == nil || ![dataSource drawMarkerInRect:markerRect forDate:[date NSDate] selected:self.selected]) {
            markerRect.origin.x = _tileSize.width/2.f - 4.f;
            markerRect.size.width = 8.f;
            
            [textColor setFill];
            CGContextFillRect(ctx, markerRect);
            
        }
    }
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    CGSize textSize = [dayText sizeWithAttributes:attr];
    CGFloat textX, textY;
    textX = roundf(0.5f * (_tileSize.width - textSize.width));
    //textY = 6.f + roundf(0.5f * (kTileSize.height - textSize.height));
    textY = -2.f + roundf(0.5f * (_tileSize.height - textSize.height));
    [textColor setFill];
    [dayText drawAtPoint:CGPointMake(textX, textY) withAttributes:attr];

    if([dataSource respondsToSelector:@selector(drawForegroundInRect:forDate:selected:)]){
        [dataSource drawForegroundInRect:rect forDate:[date NSDate] selected:self.selected];
    }

    if (self.highlighted) {
        [[UIColor colorWithWhite:0.25f alpha:0.3f] setFill];
        CGContextFillRect(ctx, CGRectMake(0.f, 0.f, _tileSize.width, _tileSize.height));
    }
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  //frame.origin = origin;
  frame.size = _tileSize;
  self.frame = frame;
  
  [date release];
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  [date release];
  date = [aDate retain];

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
  if (flags.selected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
  if (flags.marked == marked)
    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else if (flags.type == KalTileTypeToday) {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }

- (void)dealloc
{
  [date release];
  [super dealloc];
}

@end
