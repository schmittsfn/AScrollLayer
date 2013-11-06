/*
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

#import "HelloWorldLayer.h"
#import "AScrollLayer.h"


@interface Primitive : CCDrawNode
+ (id)drawRectangle;
@end
@implementation Primitive
+ (id)drawRectangle
{
    Primitive *aNode = [[Primitive alloc] init];
    CGPoint vertices[4] = {
        ccp(0.f, 0.f),
        ccp(0.f, 40),
        ccp(100, 40),
        ccp(100, 0.f)
    };
    [aNode drawPolyWithVerts:vertices
                       count:4
                   fillColor:ccc4f(0.5,0.2,0.1,1)
                 borderWidth:2.f
                 borderColor:ccc4f(0,0,1,1)];
    return aNode;
}
@end



@interface HelloWorldLayer() <AScrollLayerDelegate>
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    AScrollLayer *scrollLayer = [AScrollLayer node];
    //scrollLayer.horizontalScrollDisabled = YES;
    //scrollLayer.verticalScrollDisabled = YES;
    scrollLayer.contentSize = CGSizeMake(800, 4000);
    
    for (int i=0; i<100; i++)
    {
        Primitive *rectangle = [Primitive drawRectangle];
        rectangle.position = ccp(50 + i * 3, 280 - i * 40);
        [scrollLayer.contentLayer addChild:rectangle];
    }
    
	[scene addChild: scrollLayer];
	return scene;
}

- (void)scrollLayerDidScroll:(CGPoint)translation
{
    // Add custom code here
    //printf("translation.x:%f  y:%f\n", translation.x, translation.y);
}

@end
