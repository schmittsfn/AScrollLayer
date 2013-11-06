/*
 *  AScrollLayer
 *
 *  Copyright (c) 2013 Stefan Schmitt.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "AScrollLayer.h"
#import "cocos2d.h"


@interface AScrollLayer ()
{
    CGSize _winSize;
    NSTimeInterval _oldTouchTime;
    CGPoint _speed;
    BOOL _decelerating;
    BOOL _verticalTranslation;
    BOOL _bouncing;
    CGPoint _overlap;
}

@end


/*
 TODO:
 - Make scrolling more natural by defining deceleration using physics -- it's linear right now
 - Subtle bounce back when hitting edge whilst dragging
 - Remove 'stuttering' of content when pulling content beyond bounds (rubber band)
 - Counter-force when pulling content beyond bounds (i.e. content translates less and less due to rubber band)
 - Let bounds of content restrict scrolling instead of verticalScrollDisabled/horizontalScrollDisabled booleans(lazy)
 
 Bugs:
 - #001 Incorrect behavior when scrolling for both axis is enabled at the same time
 */
@implementation AScrollLayer

-(id)init
{
    self = [super init];
    
    if( self != nil )
    {
        self.touchEnabled = YES;
        _minDeceleration = 0.5;
        _inertia = 0.97;
        _winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayer *layer = [CCLayer node];
        layer.anchorPoint = ccp(0, 1);
        [self addChild:layer];
        _contentLayer = layer;
	}
    
	return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_bouncing) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    _oldTouchTime = event.timestamp;
    _touchLocation = touchLocation;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    _touchLocation = touchLocation;
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint dragPt = ccpSub(touchLocation, oldTouchLocation);
    [self dragging:dragPt];
    
    // This favors vertical drags
    _verticalTranslation =  ABS(dragPt.y) >= ABS(dragPt.x)? YES : NO;
    _oldTouchTime = event.timestamp;
    _speed = dragPt;
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    double elapsedTime = event.timestamp - _oldTouchTime;
    
    BOOL noInertia = NO;
    
    if (_verticalTranslation && _verticalDecelerationDisabled) noInertia = YES;
    if (!_verticalTranslation && _horizontalDecelerationDisabled) noInertia = YES;
    
    if (elapsedTime > 0.02 || noInertia)
        _decelerating = NO;
    else
        _decelerating = YES;
    _oldTouchTime = 0;
}

- (void)draw
{
    
    // Get top left hand corner of content & Add/Remove nodes for better performance
    float top_y = _contentLayer.boundingBox.origin.y + _contentLayer.boundingBox.size.height;
    float top_x = _contentLayer.boundingBox.origin.x;
    
    
    // I think that all/or most of the encapsulated code to determine bounds/bounce/deceleration could be done in a couple of equations and probably get rid of bug #001
    /******************************************************************************************************/
    // Check Bounds
    CGPoint topLeftCorner = ccp(top_x, top_y);
    CGPoint max = ccp((self.contentSize.width - _winSize.width) * -1, self.contentSize.height);
    CGPoint min = ccp(0, _winSize.height);
    
    CGPoint overlapX;
    CGPoint overlapY;
    if (topLeftCorner.y > max.y) {
        overlapY = ccpMult(ccpSub(topLeftCorner, max), -1);
        _overlap.y = overlapY.y;
        _bouncing = YES;
        _decelerating = NO;
    }
    else if (topLeftCorner.y < min.y) {
        overlapY =  ccpSub(min, topLeftCorner);
        _overlap.y = overlapY.y;
        _bouncing = YES;
        _decelerating = NO;
    }else{
        _overlap.y = 0;
    }
    
    if (topLeftCorner.x > min.x) {
        overlapX = ccpMult(topLeftCorner, -1);
        _overlap.x = overlapX.x;
        _bouncing = YES;
        _decelerating = NO;
    }
    else if (topLeftCorner.x < max.x) {
        overlapX = ccpMult(ccpSub(topLeftCorner, max), -1);
        _overlap.x = overlapX.x;
        _bouncing = YES;
        _decelerating = NO;
    }else{
        _overlap.x = 0;
    }
    
    
    
    // Bounce or Decelerate
    if (_bouncing) {
        if ((ABS(_overlap.y) >= _minDeceleration) || (ABS(_overlap.x) >= _minDeceleration)) _overlap = ccpMult(_overlap,0.1f);
        
        [self dragging:_overlap];
        
        if ((ABS(_overlap.y) <= _minDeceleration) || (ABS(_overlap.x) <= _minDeceleration)) _bouncing = NO;
    }
    else if (_decelerating) {
        [self dragging:_speed];
        
        if (_verticalTranslation && ABS(_speed.y) < _minDeceleration) {
            _speed = CGPointZero;
            _decelerating = NO;
        }
        else if (!_verticalTranslation && ABS(_speed.x) < _minDeceleration) {
            _speed = CGPointZero;
            _decelerating = NO;
        }
        else {
            _speed = ccpMult(_speed, _inertia);
        }
    }
    /******************************************************************************************************/
    [super draw];
}

- (void)dragging:(CGPoint)dragPt
{
    if (_verticalScrollDisabled) dragPt = ccp(dragPt.x, 0);
    if (_horizontalScrollDisabled) dragPt = ccp(0, dragPt.y);
    dragPt = ccp(dragPt.x, dragPt.y);
    
    if (_delegate) [_delegate scrollLayerDidScroll:dragPt];
    
    CGPoint newPosition = ccpAdd(_contentLayer.position, dragPt);
    [_contentLayer setPosition:newPosition];
}

@end
