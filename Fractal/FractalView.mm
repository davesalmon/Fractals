/*+
 *
 *  FractalView.mm
 *
 *  Copyright © 2003 David C. Salmon. All Rights Reserved.
 *
 *  This file contains the custom view for displaying the fractal images. Also contains
 *  selection code.
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-*/

#import "FractalView.h"
#import "FractalWindowController.h"

//----------------------------------------------------------------------------------------
//  constrain                                                                      static
//
//      constrain rectangle to drawing grid.
//
//  const NSRect& r    -> the rectangle to constrain to drawing coords.
//
//  returns NSRect     <- the constrained rect.
//----------------------------------------------------------------------------------------
inline NSRect
constrain(const NSRect& r)
{
	NSRect cr = r;
	cr.origin.x = (int)r.origin.x + 0.5;
	cr.origin.y = (int)r.origin.y - 0.5;
	return cr;
}


@implementation FractalView

//----------------------------------------------------------------------------------------
//  initWithFrame:
//
//      Initialize the view.
//
//  initWithFrame: NSRect frameRect    -> the view frame.
//
//  returns id                         <- self
//----------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frameRect {
	_image = nil;
	_selecting = false;
	_phase = 0;
	return [super initWithFrame: frameRect];
}

//----------------------------------------------------------------------------------------
//  dealloc
//
//      free memory.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)dealloc {
	[_image release];
	[super dealloc];
}

//----------------------------------------------------------------------------------------
//  drawRect:
//
//      draw the view.
//
//  drawRect: NSRect rect  -> the rect to draw.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect {
	
	[_image drawAtPoint: NSMakePoint(0,0)
			   fromRect: NSZeroRect
			  operation: NSCompositeSourceOver
			   fraction: 1.0];
	
	if (_selecting) {
		NSBezierPath* path = [NSBezierPath bezierPathWithRect:constrain(_selectionRect)];
		CGFloat theArray[4];
		theArray[0] = 1;
		theArray[1] = 1;
		//	for some reason, changing the phase does not cause the pattern to march.
		[path setLineDash:theArray count:2 phase:_phase + 0.5];
		[[NSColor grayColor]set];
		[path stroke];
		_phase = (_phase + 1) % 2;		
	}
}


//----------------------------------------------------------------------------------------
//  setImage:
//
//      set a new image for the view.
//
//  setImage: NSImageRep* image    -> the new image.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)setImage:(NSImageRep*) image {
	[_image release];
	_image = [[NSImage alloc] initWithSize: [image size]];
	[_image addRepresentation:image];
	[self setNeedsDisplay: YES];
}

//----------------------------------------------------------------------------------------
//  setDelegate:
//
//      specify the delegate for mouse clicks and selection.
//
//  setDelegate: FractalWindowController* del  -> the delegate
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)setDelegate: (FractalWindowController*) del {
	_delegate = del;	
}

//----------------------------------------------------------------------------------------
//  mouseDraggedFrom:to:withFlags:
//
//      handle drags.
//
//  mouseDraggedFrom: NSPoint start        -> initial location
//  to: NSPoint current                    -> current location
//  withFlags: unsigned int modifierFlags  -> modifiers.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) mouseDraggedFrom: (NSPoint)start to: (NSPoint)current withFlags: (unsigned int)modifierFlags
{
	if (_selecting)
		[self setNeedsDisplayInRect: NSInsetRect(_selectionRect, -1, -1)];

	float l, w, b, h;
	if (start.x > current.x) {
		l = current.x;
		w = start.x - l;
	} else {
		l = start.x;
		w = current.x - l;
	}
	if (start.y > current.y) {
		b = current.y;
		h = start.y - b;
	} else {
		b = start.y;
		h = current.y - b;
	}
	_selectionRect.origin.x = l;
	_selectionRect.origin.y = b;
	_selectionRect.size.width = w;
	_selectionRect.size.height = h;
	[self setNeedsDisplayInRect:NSInsetRect(_selectionRect, -1, -1)];
	_selecting = true;
}

//----------------------------------------------------------------------------------------
//  mouseDown:
//
//      handle mouse down event.
//
//  mouseDown: NSEvent* theEvent   -> the event
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) mouseDown: (NSEvent*) theEvent
{
	BOOL keepOn = YES;
    BOOL isInside = YES;
    NSPoint mouseLoc;
	NSPoint	startLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	_selecting = false;

	try {
//		if (![self mouseClicked: startLoc withFlags: [theEvent modifierFlags]]) {
//			[_eventDelegate endClick];
//			return;
//		}

	    while (keepOn) {
	        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
	                NSLeftMouseDraggedMask];
	        mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	        isInside = [self mouse:mouseLoc inRect:[self bounds]];
			

	        switch ([theEvent type]) {
            case NSLeftMouseDragged:
//        		currDist = fabs(mouseLoc.x - startLoc.x);
//        		if (currDist > maxDist)
//        			maxDist = currDist;
//         		currDist = fabs(mouseLoc.y - startLoc.y);
//        		if (currDist > maxDist)
//        			maxDist = currDist;
//              [self mouseMoved: theEvent];
              	[self mouseDraggedFrom: startLoc to: mouseLoc 
                		withFlags: [theEvent modifierFlags]];
            	break;
            case NSLeftMouseUp:
//                    if (isInside) 
//                    	[self mouseClicked: mouseLoc withFlags: [theEvent modifierFlags]];
//                    [self highlight:NO];
                keepOn = NO;
                break;
            default:
                /* Ignore any other kind of event. */
                break;
	        }
	    }
	    
	    if (_selecting) {
	    	[self setNeedsDisplayInRect: NSInsetRect(_selectionRect, -1, -1)];
	    	_selecting = false;
	    	[_delegate setSelection: _selectionRect zoom: ([theEvent modifierFlags] & NSShiftKeyMask) == 0];
	    } else {
	    	[_delegate click: startLoc];
	    }
	    
//	    [_eventDelegate endClick];
    } catch (...) {
    }
} 


@end
