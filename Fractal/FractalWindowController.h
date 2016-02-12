/*+
 *
 *  FractalWindowController.mm
 *
 *  Copyright © 2003 David C. Salmon. All Rights Reserved.
 *
 *  Window controller for displaying fractal images.
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

@class FractalView;

typedef struct FractalState {
	
	int 	isMandelbrot;
    int		iters;
	
    double	x0;
    double	y0;
    double	width;
    double	height;
    double	radius;
    double	lambdax;
    double  lambday;
    
    CGFloat	r1, g1, b1;
    CGFloat	r2, g2, b2;
    
}	FractalState;



@interface FractalWindowController : NSWindowController
{
    IBOutlet FractalView *_fractalView;

    IBOutlet NSStepper* _iterStepper;
    IBOutlet NSStepper* _radiusStepper;
    IBOutlet NSStepper* _lambdaXStepper;
    IBOutlet NSStepper* _lambdaYStepper;

    
    IBOutlet NSTextField *_iterText;
    IBOutlet NSTextField *_radiusText;
    IBOutlet NSTextField *_lambdaXText;
    IBOutlet NSTextField *_lambdaYText;
    
    IBOutlet NSColorWell* _startColorWell;
    IBOutlet NSColorWell* _endColorWell;

	IBOutlet NSImageView* _imageView;
	IBOutlet NSMatrix*	  _functionType;
	
	IBOutlet NSTextField *xLabel;
	IBOutlet NSTextField *yLabel;
	
	bool _isMandelbrot;
	
    double	_x0;
    double	_y0;
    double	_height;
    double	_width;
//    double	_scale;
    int		_iterations;
    double	_radius;
    double	_lambdaX;
    double  _lambdaY;
    
    NSColor* _startColor;
    NSColor* _endColor;
        
    unsigned char* _colorTable;
    unsigned short* _dataTable;
    int _dataSize;
}

- (IBAction) stepperChanged: (id) sender;
- (IBAction) colorChanged: (id) sender;
- (IBAction) functionTypeChanged: (id) sender;
- (IBAction) save: (id) sender;
- (IBAction) addBookmark: (id) sender;
- (IBAction) selectBookmark: (id) sender;

- (void) setRadius: (double) rad;
- (void) setIterations: (int) iters;
- (void) setLambdaX: (double) lam;
- (void) setLambdaY: (double) lam;
- (void) setStartColor: (NSColor*) clr;
- (void) setEndColor: (NSColor*) clr;
- (void) setOrigin: (NSPoint) p;
- (void) setBounds: (NSRect) r;
- (void) setState: (FractalState) s;

- (void) updateImage;
- (void) updateColors;
- (void) displayColorTable;
- (double) stepperRadius;
- (int) stepperIterations;
- (double) stepperLambdaX;
- (double) stepperLambdaY;
- (NSColor*) startColor;
- (NSColor*) endColor;

//	image generator methods

- (void) click : (NSPoint) p;
- (void) setSelection: (NSRect) r zoom: (bool) isZoom;
- (double) computeScale: (NSSize) imSize;
	//	create the image from the data and the current color table.
- (NSBitmapImageRep*) createImageOfSize : (NSSize)imSize withData: (unsigned short*)data;
	//	make the color table for the given iterations
- (void) makeColorTable;
	//	compute the image data.
- (unsigned short*) computeImageData : (NSSize) imSize;

@end
