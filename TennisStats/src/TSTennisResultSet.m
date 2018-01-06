//  MIT Licence
//
//  Created on 06/12/2014.
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

#import "TSTennisResultSet.h"



//      0x00000000
// Pack:   pG oG

static NSUInteger _pack_mask = 0x7F;
static NSUInteger _pack_maskbits = 7;

const char * byte_to_binary(unsigned int x){
    static char buf[sizeof(int)*8+1] = {0};
    int y;
    long long z;
    for( z=1LL<<(sizeof(int)*8-1),y=0;z>0;z>>=1,y++){
        buf[y] = (((x&z)==z) ? '1' : '0');
    }
    buf[y] = 0;
    return buf;
}

@implementation TSTennisResultSet

-(TSResultPacked)pack{

    TSResultPacked rv = 0;
    rv |= self.tieBreakSet & 0x1;
    rv = rv << 1;
    rv |= self.lastGameWasTieBreak & 0x1;
    rv = rv << _pack_maskbits;
    rv |= self.playerGames & _pack_mask;
    rv = rv << _pack_maskbits;
    rv |= self.opponentGames & _pack_mask;
    rv = rv << _pack_maskbits;
    rv |= self.playerTieBreakPoints & _pack_mask;
    rv = rv << _pack_maskbits;
    rv |= self.opponentTieBreakPoints & _pack_mask;
    //NSLog(PRINTF_BINARY_PATTERN_INT32, PRINTF_BYTE_TO_BINARY_INT32(rv));

    return rv;
}
-(TSTennisResultSet*)unpack:(TSResultPacked)val{
    TSResultPacked unpack = val;
    self.opponentTieBreakPoints = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.playerTieBreakPoints = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.opponentGames = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.playerGames = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.lastGameWasTieBreak = unpack & 0x1;
    unpack = unpack >> 1;
    self.tieBreakSet = unpack & 0x1;
    return self;
}
-(BOOL)isEqualToResult:(TSTennisResultSet*)other{
    return (self.opponentTieBreakPoints == other.opponentTieBreakPoints &&
            self.playerTieBreakPoints   == other.playerTieBreakPoints &&
            self.playerGames            == other.playerGames &&
            self.opponentGames          == other.opponentGames &&
            self.lastGameWasTieBreak    == other.lastGameWasTieBreak &&
            self.tieBreakSet            == other.tieBreakSet );
}

-(NSString*)asString{
    if (self.lastGameWasTieBreak) {
        return [NSString stringWithFormat:@"%d-%d(%d)", (int)self.playerGames, (int)self.opponentGames,(int) MAX(self.playerTieBreakPoints, self.opponentTieBreakPoints)];
    }else{
        return [NSString stringWithFormat:@"%d-%d", (int)self.playerGames, (int)self.opponentGames];
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), [self asString]];
}

@end
