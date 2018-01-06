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
    //UIFont *font = [GCViewConfig boldSystemFontOfSize:fontSize];
    UIColor *shadowColor = nil;
    UIColor *textColor = nil;
    UIImage *markerImage = nil;
    
    //NSDictionary * attr = @{NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:fontSize]};
    
    //CGContextTranslateCTM(ctx, 0, kTileSize.height);
    //CGContextScaleCTM(ctx, 1, -1);
    
    if ([self isToday] && self.selected) {
        [[[UIImage imageNamed:kalBundleFile(@"kal_tile_today_selected.png")] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, _tileSize.width+1, _tileSize.height+1)];
        textColor = [UIColor whiteColor];
        shadowColor = [UIColor blackColor];
        markerImage = [UIImage imageNamed:kalBundleFile(@"kal_marker_today.png")];
    } else if ([self isToday] && !self.selected) {
        [[[UIImage imageNamed:kalBundleFile(@"kal_tile_today.png")] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, _tileSize.width+1, _tileSize.height+1)];
        textColor = [UIColor whiteColor];
        shadowColor = [UIColor blackColor];
        markerImage = [UIImage imageNamed:kalBundleFile(@"kal_marker_today.png")];
    } else if (self.selected) {
        [[[UIImage imageNamed:kalBundleFile(@"kal_tile_selected.png")] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, _tileSize.width+1, _tileSize.height+1)];
        textColor = [UIColor whiteColor];
        shadowColor = [UIColor blackColor];
        markerImage = [UIImage imageNamed:kalBundleFile(@"kal_marker_selected.png")];
    } else if (self.belongsToAdjacentMonth) {
        if (useIOS7Look()) {
            textColor = [UIColor lightGrayColor];
        }else{
            textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kalBundleFile(@"kal_tile_dim_text_fill.png")]];
        }
        shadowColor = nil;
        markerImage = [UIImage imageNamed:kalBundleFile(@"kal_marker_dim.png")];
    } else {
        if (useIOS7Look()) {
            textColor = [UIColor darkGrayColor];
        }else{
            textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kalBundleFile(@"kal_tile_text_fill.png")]];
        }
        shadowColor = [UIColor whiteColor];
        markerImage = [UIImage imageNamed:kalBundleFile(@"kal_marker.png")];
    }
    UIFont * systemFont = nil;
    if( [self.dataSource respondsToSelector:@selector(systemFontOfSize:)]){
        systemFont = [self.dataSource systemFontOfSize:fontSize];
    }else{
        systemFont = [UIFont systemFontOfSize:fontSize];
    }
    NSDictionary * attr = @{NSFontAttributeName:systemFont,NSForegroundColorAttributeName:textColor};

    if([dataSource respondsToSelector:@selector(drawBackgroundInRect:forDate:selected:)]){
        [dataSource drawBackgroundInRect:rect forDate:[date NSDate] selected:self.selected];
    }

    if (flags.marked){
        //CGRectMake(3.f,3.f,40.f,7.f)
        if (dataSource == nil || ![dataSource drawMarkerInRect:CGRectMake(2.f,_tileSize.height-11.f ,_tileSize.width-4.f,7.f) forDate:[date NSDate] selected:self.selected]) {
            //CGRectMake(21.f, 5.f, 4.f, 5.f)
            [markerImage drawInRect:CGRectMake(21.f, _tileSize.height-9.f, 4.f, 5.f)];
        }
    }
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    CGSize textSize = [dayText sizeWithAttributes:attr];
    CGFloat textX, textY;
    textX = roundf(0.5f * (_tileSize.width - textSize.width));
    //textY = 6.f + roundf(0.5f * (kTileSize.height - textSize.height));
    textY = -2.f + roundf(0.5f * (_tileSize.height - textSize.height));
    if (shadowColor && ! useIOS7Look()) {
        [shadowColor setFill];
        [dayText drawAtPoint:CGPointMake(textX, textY) withAttributes:attr];
        textY += 1.f;
    }
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
