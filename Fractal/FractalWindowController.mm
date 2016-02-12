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

#import "FractalWindowController.h"

#import "FractalView.h"
#import "FractalAppController.h"
#import "BookmarkTitle.h"

#include "Julia.h"
#include "Mandelbrot.h"

const double kBaseIncrement = 0.0001;

//----------------------------------------------------------------------------------------
//  computeRow
//
//      Compute one row for the image, using operator() (int, int) for the given class.
//
//  unsigned short* rPtr   -> the current row.
//  int row                -> the row number (0-based)
//  int ncols              -> the number of columns in the row.
//  const T& f             -> the computation class.
//
//  returns nothing
//----------------------------------------------------------------------------------------
template <class T>
void
computeRow(unsigned short* rPtr, double top, double left, double scale, int ncols, const T& f) {
	for (int i = 0; i < ncols; ++i, ++rPtr) {
		*rPtr = f(left, top);
		left += scale;
	}
}

//----------------------------------------------------------------------------------------
//  changed                                                                        inline
//
//      return true if the value is different
//
//  double x1      -> first value
//  double x2      -> second value
//
//  returns bool   <- true if different.
//----------------------------------------------------------------------------------------
inline bool
changed(double x1, double x2) {
	return fabs(x1 - x2) > 1.0e-10;
}

//----------------------------------------------------------------------------------------
//  getFactor                                                                      static
//
//      return the stepper factor from the event modifiers. Each modifier key
//		magnifies steppers by a factor of 10.
//
//  NSEventModifierFlags flags -> the flags.
//
//  returns double             <- the factor.
//----------------------------------------------------------------------------------------
static double
getFactor(NSEventModifierFlags flags)
{
	double factor = 1.0;
	
	if (flags & NSShiftKeyMask)
		factor *= 10;
	
	if (flags & NSAlternateKeyMask)
		factor *= 10;
	
	if (flags & NSControlKeyMask)
		factor *= 10;
	
	return factor;
}


@implementation FractalWindowController

//----------------------------------------------------------------------------------------
//  acceptsFirstResponder
//
//      return true to get key events.
//
//  returns BOOL   <- 
//----------------------------------------------------------------------------------------
- (BOOL) acceptsFirstResponder
{
	return YES;
}

//----------------------------------------------------------------------------------------
//  flagsChanged:
//
//      handle keyboard modifier events. Use to modify stepper increments.
//
//  flagsChanged: NSEvent* evt -> the event.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) flagsChanged: (NSEvent*) evt
{	
	NSEventModifierFlags flags = [evt modifierFlags];
	
	double factor = getFactor(flags);
	
	[_lambdaXStepper setIncrement: kBaseIncrement * factor];
	[_lambdaYStepper setIncrement: kBaseIncrement * factor];
}

//----------------------------------------------------------------------------------------
//  dealloc
//
//      free memory used by this class.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) dealloc {
	delete [] _colorTable;
	delete [] _dataTable;
	[super dealloc];
}

//----------------------------------------------------------------------------------------
//  awakeFromNib
//
//      handle startup conditions.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)awakeFromNib {
	//printf("waking\n");
	_colorTable = NULL;
	_dataTable = NULL;
	_dataSize = 0;
	_x0 = 0;
	_y0 = 0;
	_width = 4;
	_height = 4;
	_isMandelbrot = [_functionType selectedRow] == 1;

//	[self updateScale];
		
	_iterations = [self stepperIterations];
    _radius = [self stepperRadius];
    _lambdaX = [self stepperLambdaX];
    _lambdaY = [self stepperLambdaY];
    _startColor = [[self startColor] retain];
    _endColor = [[self endColor] retain];

	[_fractalView setDelegate: self];
	[self makeColorTable];
	[self displayColorTable];
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  colorChanged:
//
//      handle changes to the start and end colors.
//
//  colorChanged: id sender    -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) colorChanged: (id) sender {
	NSColorWell* s = sender;
	if (s == _startColorWell) {
		[self setStartColor: [self startColor]];
	} else if (s == _endColorWell) {
		[self setEndColor: [self endColor]];
	}
//	[self makeColorTable];
//	[self displayColorTable];
}

//----------------------------------------------------------------------------------------
//  functionTypeChanged:
//
//      handle changes to the function type.
//
//  functionTypeChanged: id sender -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) functionTypeChanged: (id) sender {
	_isMandelbrot = [_functionType selectedRow] == 1;
	
	
	NSString* xString;
	NSString* yString;
	
	if (_isMandelbrot) {
		xString = NSLocalizedString(@"mand_x", nil);
		yString = NSLocalizedString(@"mand_y", nil);
	} else {
		xString = NSLocalizedString(@"julia_x", nil);
		yString = NSLocalizedString(@"julia_y", nil);
	}
	
	xLabel.stringValue = xString;
	yLabel.stringValue = yString;
	
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  stepperChanged:
//
//      handle changes in any of the steppers.
//
//  stepperChanged: id sender  -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) stepperChanged:(id)sender {
	NSStepper* s = sender;
	if (s == _iterStepper) {
		[self setIterations: [self stepperIterations]];
	} else if (s == _radiusStepper) {
		[self setRadius: [self stepperRadius]];
	} else if (s == _lambdaXStepper) {
		[self setLambdaX: [self stepperLambdaX]];
	} else if (s == _lambdaYStepper) {
		[self setLambdaY: [self stepperLambdaY]];
	}
}

//----------------------------------------------------------------------------------------
//  addBookmark:
//
//      add a bookmark for this state
//
//  addBookmark: id sender -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) addBookmark: (id) sender {

	NSString* btitle = [BookmarkTitle runDialog: [self window]];
	if (btitle != nil) {
		

		FractalState s;
		CGFloat tmp;
		s.isMandelbrot = _isMandelbrot;
		s.iters = _iterations;
		s.x0 = _x0;
		s.y0 = _y0;
		s.width = _width;
		s.height = _height;
		s.radius = _radius;
		s.lambdax = _lambdaX;
		s.lambday = _lambdaY;
		[_startColor getRed: &s.r1 green: &s.g1 blue: &s.b1 alpha: &tmp];
		[_endColor getRed: &s.r2 green: &s.g2 blue: &s.b2 alpha: &tmp];

		[[FractalAppController appController] addBookmark: &s withTitle:btitle];
	}
}

//----------------------------------------------------------------------------------------
//  selectBookmark:
//
//      handle user bookmark selection from menu.
//
//  selectBookmark: id sender  -> (NSMenuUItem*) the menu
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) selectBookmark: (id) sender {
	FractalState s;
	NSMenuItem* item = sender;
		
	if ([[FractalAppController appController] findBookmark:&s forTitle:[item title]]) {
		[self setState: s];
	}
}

//----------------------------------------------------------------------------------------
//  setRadius:
//
//      set the radius value.
//
//  setRadius: double rad  -> the new radius value.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setRadius: (double) rad {
	[_radiusStepper setDoubleValue: rad];
	[_radiusText setDoubleValue: rad];
	_radius = rad;
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setIterations:
//
//      set the iterations value.
//
//  setIterations: int iters   -> the new iterations
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setIterations: (int) iters {
	[_iterStepper setIntValue: iters];
	[_iterText setIntValue: iters];
	_iterations = iters;
	[self makeColorTable];
	[self displayColorTable];
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setLambdaX:
//
//      set the value for real component of lambda.
//
//  setLambda: double lam  -> the new real lambda component.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setLambdaX: (double) lam {
	[_lambdaXStepper setDoubleValue: lam];
	[_lambdaXText setDoubleValue: lam];
	_lambdaX = lam;
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setLambdaY:
//
//      set the value for the im component of lambda.
//
//  setLambda2: double lam -> the imaginary lambda component.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setLambdaY: (double) lam {
	[_lambdaYStepper setDoubleValue: lam];
	[_lambdaYText setDoubleValue: lam];
	_lambdaY = lam;
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setStartColor:
//
//      set the start color
//
//  setStartColor: NSColor* clr    -> the new color
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setStartColor: (NSColor*) clr {
	[_startColor autorelease];
	_startColor = [clr retain];
	[_startColorWell setColor: _startColor];
	[_startColorWell setNeedsDisplay: YES];
	[self updateColors];
}

//----------------------------------------------------------------------------------------
//  setEndColor:
//
//      set the end color
//
//  setEndColor: NSColor* clr  -> the new end color
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setEndColor: (NSColor*) clr {
	[_endColor autorelease];
	_endColor = [clr retain];
	[_endColorWell setColor: _endColor];
	[_endColorWell setNeedsDisplay: YES];
	[self updateColors];
}

//----------------------------------------------------------------------------------------
//  setState:
//
//      set the new state.
//
//  setState: FractalState s   -> the state to set
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setState: (FractalState) s {
	_isMandelbrot = s.isMandelbrot;
	[_functionType selectCellAtRow: (_isMandelbrot ? 1 : 0) column: 0];
	//_currIter = s.iters;
	_x0 = s.x0;
	_y0 = s.y0;
	_width = s.width;
	_height = s.height;

	[_endColor release];
	_endColor = [[NSColor colorWithDeviceRed:s.r2 green:s.g2 blue:s.b2 alpha:1.0] retain];
	[_endColorWell setColor: _endColor];
	[_endColorWell setNeedsDisplay: YES];

	[_startColor release];
	_startColor = [[NSColor colorWithDeviceRed:s.r1 green:s.g1 blue:s.b1 alpha:1.0] retain];
	[_startColorWell setColor: _startColor];
	[_startColorWell setNeedsDisplay: YES];

	[_iterStepper setIntValue: s.iters];
	[_iterText setIntValue: s.iters];
	_iterations = s.iters;

	[_radiusStepper setDoubleValue: s.radius];
	[_radiusText setDoubleValue: s.radius];
	_radius = s.radius;
	
	[_lambdaXStepper setDoubleValue: s.lambdax];
	[_lambdaXText setDoubleValue: s.lambdax];
	_lambdaX = s.lambdax;

	[_lambdaYStepper setDoubleValue: s.lambday];
	[_lambdaYText setDoubleValue: s.lambday];
	_lambdaY = s.lambday;
			
	[self makeColorTable];
	[self displayColorTable];
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setOrigin:
//
//      set the new origin.
//
//  setOrigin: NSPoint p   -> the new origin.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setOrigin: (NSPoint) p {
	_x0 = p.x;
	_y0 = p.y;
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  setBounds:
//
//      set the new bounds.
//
//  setBounds: NSRect r    -> the new bounds.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setBounds: (NSRect) r
{
	_x0 = r.origin.x;
	_y0 = r.origin.y;
	_width = r.size.width;
	_height = r.size.height;
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  controlTextDidEndEditing:
//
//      handle changes caused by editing the values.
//
//  controlTextDidEndEditing: NSNotification * obj -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)controlTextDidEndEditing:(NSNotification *)obj {
	if (_iterations != [_iterText intValue]) {
		[self setIterations: [_iterText intValue]];
	} else if (changed(_lambdaX, [_lambdaXText doubleValue])) {
		[self setLambdaX: [_lambdaXText doubleValue]];
	} else if (changed(_lambdaY, [_lambdaYText doubleValue])) {
		[self setLambdaY: [_lambdaYText doubleValue]];
	} else if (changed(_radius, [_radiusText doubleValue])) {
		[self setRadius: [_radiusText doubleValue]];
	}
}

//------------------------------------------------------------------------------
//  windowDidResize:
//
//      The window resized. Scroll the selection into view.
//
//  windowWillResize: NSNotification* aNotification  	-> ignored
//
//  returns 											nothing
//------------------------------------------------------------------------------
- (void) windowDidResize:(NSNotification*) aNotification {
//	[self updateScale];
	[self updateImage];
}

//----------------------------------------------------------------------------------------
//  displayColorTable
//
//      display an updated color table.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) displayColorTable {
	NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes:&_colorTable 
			pixelsWide:_iterations + 1 
			pixelsHigh:1
			bitsPerSample:8 
			samplesPerPixel:3 
			hasAlpha:NO 
			isPlanar:NO 
			colorSpaceName:NSDeviceRGBColorSpace 
			bytesPerRow:3 * (_iterations + 1)
			bitsPerPixel:24];
	
	NSImage* viewIm = [[NSImage alloc] initWithSize: NSMakeSize(_iterations + 1, 1)];
	[viewIm addRepresentation: rep];
	[rep release];
	[_imageView setImage: viewIm];
	[viewIm release];
		
	[_imageView setNeedsDisplay:YES];
}

//----------------------------------------------------------------------------------------
//  updateImage
//
//      update the image.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) updateImage {
	NSSize imSize = [_fractalView bounds].size;
	delete [] _dataTable;
	_dataTable = [self computeImageData: imSize];
	[_fractalView setImage: [self createImageOfSize: imSize withData: _dataTable]];
}

//----------------------------------------------------------------------------------------
//  updateColors
//
//      update the colormap and display.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) updateColors {
	[self makeColorTable];
	[self displayColorTable];
	[_fractalView setImage: [self createImageOfSize: [_fractalView bounds].size withData:_dataTable]];
	[_fractalView setNeedsDisplay: YES];
}

//----------------------------------------------------------------------------------------
//  stepperRadius
//
//      return the radius value.
//
//  returns double <- the current radius value
//----------------------------------------------------------------------------------------
- (double) stepperRadius {
	return [_radiusStepper doubleValue];
}

//----------------------------------------------------------------------------------------
//  stepperIterations
//
//      return the iterations value.
//
//  returns int    <- the current iterations.
//----------------------------------------------------------------------------------------
- (int) stepperIterations {
	return [_iterStepper intValue];
}

//----------------------------------------------------------------------------------------
//  stepperLambda
//
//      return the lambda value.
//
//  returns double <- the current real lambda component.
//----------------------------------------------------------------------------------------
- (double) stepperLambdaX {
	return [_lambdaXStepper doubleValue];
}
//----------------------------------------------------------------------------------------
//  stepperLambda2
//
//      return the im component of lambda.
//
//  returns double <- the current imagainary lambda component.
//----------------------------------------------------------------------------------------
- (double) stepperLambdaY {
	return [_lambdaYStepper doubleValue];
}

//----------------------------------------------------------------------------------------
//  startColor
//
//      return the start color
//
//  returns NSColor*   <- the start color
//----------------------------------------------------------------------------------------
- (NSColor*) startColor {
	return [[_startColorWell color] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
}

//----------------------------------------------------------------------------------------
//  endColor
//
//      return the end color
//
//  returns NSColor*   <- the end color
//----------------------------------------------------------------------------------------
- (NSColor*) endColor {
	return [[_endColorWell color] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
}

//----------------------------------------------------------------------------------------
//  click:
//
//      set the origin.
//
//  setOrigin: NSPoint p   -> the new display origin.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) click: (NSPoint) p {
	NSRect r = [_fractalView bounds];
	double scale = [self computeScale : r.size];
	double newx0 = _x0 + scale * (p.x - r.size.width/2.0);
	double newy0 = _y0 + scale * (p.y - r.size.height/2.0);
	if (changed(newx0, _x0) || changed(newy0, _y0)) {
		p.x = (float)newx0;
		p.y = (float)newy0;
		[self setOrigin: p];
	}
}

//----------------------------------------------------------------------------------------
//  setSelection:zoom:
//
//      zoom in.
//
//  setSelection: NSRect r -> the new rectangle.
//  zoom: bool iszoom      -> true if zoom-in, false if zoom out
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) setSelection: (NSRect) r zoom: (bool) iszoom {

	if (r.size.width == 0 || r.size.height == 0) {
		[self click: r.origin];
		return;
	}

	NSRect bounds = [_fractalView bounds];
	NSRect newBounds;
	double scale = [self computeScale: bounds.size];
	//	put r into the current coordinates
	newBounds.origin.x = _x0 + scale * (r.origin.x + (r.size.width - bounds.size.width) / 2.0);
	newBounds.origin.y = _y0 + scale * (r.origin.y + (r.size.height - bounds.size.height) / 2.0);
	
	if (iszoom) {
		newBounds.size.width = r.size.width * scale;
		newBounds.size.height = r.size.height * scale;
	} else {
		double xfact = bounds.size.width / r.size.width;
		double yfact = bounds.size.height / r.size.height;
		//double fact = xfact < yfact ? yfact : xfact;
		newBounds.size.width = bounds.size.width * scale * xfact;
		newBounds.size.height = bounds.size.height * scale * yfact;
	}
	
	[self setBounds: newBounds];
}

//----------------------------------------------------------------------------------------
//  updateScale
//
//      update the scale of the image.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (double) computeScale: (NSSize) imSize {
	double scalex = _width / imSize.width;
	double scaley = _height / imSize.height;
	return scalex > scaley ? scalex : scaley;
}


//----------------------------------------------------------------------------------------
//  createImageOfSize:withData:
//
//      create an image of the specified size with the specified fractal data.
//
//  createImageOfSize: NSSize imSize   -> the image size
//  withData: unsigned short* valPtr   -> the data
//
//  returns NSBitmapImageRep*          <- the new image.
//----------------------------------------------------------------------------------------
- (NSBitmapImageRep*) createImageOfSize : (NSSize)imSize withData: (unsigned short*)valPtr {
	
	int width = imSize.width;
	int height = imSize.height;

	NSBitmapImageRep* rep = [[[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes:nil 
			pixelsWide:width 
			pixelsHigh:height 
			bitsPerSample:8 
			samplesPerPixel:3 
			hasAlpha:NO 
			isPlanar:NO 
			colorSpaceName:NSDeviceRGBColorSpace 
			bytesPerRow:3*width 
			bitsPerPixel:24] autorelease];
	
	int clrBytesPerRow = [rep bytesPerRow];
	unsigned char* clrPtr = [rep bitmapData];
		
	for (int i = 0; i < height; i++) {
		unsigned char* cPtr = clrPtr;
		unsigned short* vPtr = valPtr;
		for (int j = 0; j < width; j++, cPtr += 3, vPtr++) {
			int index = (int)*vPtr * 3;
			
			cPtr[0] = (_colorTable + index)[0];
			cPtr[1] = (_colorTable + index)[1];
			cPtr[2] = (_colorTable + index)[2];
		}
		
		valPtr += width;
		clrPtr += clrBytesPerRow;
	}

	return rep;
}

//----------------------------------------------------------------------------------------
//  makeColorTable
//
//      build the new color table using the colors.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void) makeColorTable {

	delete [] _colorTable;
	_colorTable = new unsigned char[(_iterations + 1) * 3];
	
	CGFloat hue1, sat1, bright1, alpha1;
	CGFloat hue2, sat2, bright2, alpha2;
	
	[_startColor getHue:&hue1 saturation:&sat1 brightness:&bright1 alpha:&alpha1];
	[_endColor getHue:&hue2 saturation:&sat2 brightness:&bright2 alpha:&alpha2];
	
	double hdiff = hue2 - hue1;
	double sdiff = sat2 - sat1;
	double bdiff = bright2 - bright1;

	unsigned char* cPtr = _colorTable;
	for (int i = 0; i <= _iterations; ++i, cPtr += 3) {
		double fract = (double)i / _iterations;
		
		double hue = hue1 + hdiff * fract;
		double sat = sat1 + sdiff * fract;
		double bright = bright1 + bdiff * fract;
		
		CGFloat red, green, blue;
		
		[[NSColor colorWithDeviceHue:hue saturation:sat brightness:bright alpha:1.0]
			getRed:&red green:&green blue:&blue alpha:&alpha1];
		
		cPtr[0] = (unsigned char)(red * 255);
		cPtr[1] = (unsigned char)(green * 255);
		cPtr[2] = (unsigned char)(blue * 255);
	}	
}

//----------------------------------------------------------------------------------------
//  computeImageData
//
//      compute the image data. This method recalculates the entire image.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (unsigned short*) computeImageData : (NSSize) imSize {

	int width = imSize.width;
	int height = imSize.height;
	
	int dataSize = width * height;
	unsigned short* dataTab = new unsigned short[dataSize];

	double scale = [self computeScale: imSize];
	double left = _x0 - scale * width / 2.0;
	double top = _y0 + scale * height / 2.0;
	
	if (_isMandelbrot) {
		Mandelbrot test(_iterations, _radius, _lambdaX, _lambdaY);
		
		unsigned short* planeData = dataTab;
		for (int i = 0; i < height; ++i) {
			computeRow(planeData, top, left, scale, width, test);
			planeData += width;
			top -= scale;
		}
	} else {
		Julia test( _iterations, _radius, _lambdaX, _lambdaY);
		
		unsigned short* planeData = dataTab;
		for (int i = 0; i < height; ++i) {
			computeRow(planeData, top, left, scale, width, test);
			planeData += width;
			top -= scale;
		}
	}

	return dataTab;
}


//----------------------------------------------------------------------------------------
//  save:
//
//      save the image to disk.
//
//  save: id sender    -> ignored.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) save: (id) sender {

	//	put up save dialog
	NSSavePanel *sp;
	int runResult;

	/* create or get the shared instance of NSSavePanel */
	sp = [NSSavePanel savePanel];

	/* set up new attributes */
	[sp setAllowedFileTypes: [NSArray arrayWithObject: @"tiff"]];
	[sp setExtensionHidden:YES];
	[sp setCanSelectHiddenExtension:YES];
	[sp setDirectoryURL: [NSURL URLWithString: [NSHomeDirectory()
												stringByAppendingPathComponent:@"Pictures"]]];
	[sp setNameFieldStringValue: @"fractal"];
	
	/* display the NSSavePanel */
	runResult = [sp runModal];

	/* if successful, save file under designated name */
	if (runResult == NSOKButton) {
		//	generate new full screen image.
		NSSize imSize = [[NSScreen mainScreen] frame].size;
		unsigned short* data = [self computeImageData: imSize];
		NSBitmapImageRep* rep = [self createImageOfSize: imSize withData: data];
		delete [] data;
		
		//	write out image data to TIFF
		NSData* imData = [rep TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.0f];
		if (![imData writeToFile: sp.URL.path atomically: NO])
	    	NSBeep();
	}
}

@end
