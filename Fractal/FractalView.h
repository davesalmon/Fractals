/*+
 *
 *  FractalView.h
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

#import <Cocoa/Cocoa.h>

@class FractalWindowController;

@interface FractalView : NSView
{
	NSImage* _image;

	FractalWindowController* _delegate;

    NSRect		_selectionRect;
    bool		_selecting;
    int			_phase;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)rect;

- (void)setImage:(NSImageRep*) image;
- (void)setDelegate: (FractalWindowController*) del;

@end
