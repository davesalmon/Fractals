/*+
 *
 *  FractalAppController.m
 *
 *  Copyright © 2003 David C. Salmon. All Rights Reserved.
 *
 *  Contains application level code for the Fractal program. Mainly supports saving
 *  bookmarks in the preferences.
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

#import "FractalAppController.h"

#import "FractalWindowController.h"

//----------------------------------------------------------------------------------------
//  strCompare                                                                     static
//
//      compare two strings for sorting bookmarks.
//
//  id s1          -> first string
//  id s2          -> second string
//  void* context  -> NULL
//
//  returns int    <- -1 for less, 0 for equal, and 1 for greater.
//----------------------------------------------------------------------------------------
static NSInteger
strCompare(id s1, id s2, void* context) 
{
	return [s1 caseInsensitiveCompare: s2];
}

@implementation FractalAppController

//----------------------------------------------------------------------------------------
//  appController
//
//      return this instance.
//
//  returns FractalAppController*  <- the application controller.
//----------------------------------------------------------------------------------------
+ (FractalAppController*) appController {
	return [NSApp delegate];
}

//----------------------------------------------------------------------------------------
//  state:fromString:
//
//      convert the string into a state object.
//
//  state: FractalState* state <-> the state to extract into
//  fromString: NSString* s    -> the string
//
//  returns BOOL               <- true if valid.
//----------------------------------------------------------------------------------------
- (BOOL) state: (FractalState*) state fromString: (NSString*) s {
	NSScanner* scanner = [NSScanner scannerWithString: s];
	[scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

#if defined(__LP64__) && __LP64__
	#define scanMethod	scanDouble
#else
	#define scanMethod	scanFloat
#endif

	if (
		[scanner scanInt: &state->isMandelbrot] && 
		[scanner scanInt: &state->iters] && 
		[scanner scanDouble: &state->x0] && 
		[scanner scanDouble: &state->y0] && 
		[scanner scanDouble: &state->width] && 
		[scanner scanDouble: &state->height] && 
		[scanner scanDouble: &state->radius] && 
		[scanner scanDouble: &state->lambdax] && 
		[scanner scanDouble: &state->lambday] && 
		[scanner scanMethod: &state->r1] &&
		[scanner scanMethod: &state->g1] &&
		[scanner scanMethod: &state->b1] &&
		[scanner scanMethod: &state->r2] &&
		[scanner scanMethod: &state->g2] &&
		[scanner scanMethod: &state->b2]
		) {
		
		return YES;
	}
	return NO;
}

//----------------------------------------------------------------------------------------
//  stringFromState:
//
//      convert the state into a string.
//
//  stringFromState: FractalState* s   -> the state.
//
//  returns NSString*                  <- the converted string.
//----------------------------------------------------------------------------------------
- (NSString*) stringFromState: (FractalState*) s {
	return [NSString stringWithFormat: @"%d\t%d\t"
				"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f",
		s->isMandelbrot, s->iters, s->x0, s->y0, 
		s->width, s->height, s->radius, s->lambdax, s->lambday, 
		s->r1, s->g1, s->b1, s->r2, s->g2, s->b2];
}

//----------------------------------------------------------------------------------------
//  applicationWillFinishLaunching:
//
//      Notification when the application finishes launching. Build the bookmark menu.
//
//  applicationWillFinishLaunching: NSNotification* aNotification  -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)applicationWillFinishLaunching:(NSNotification*)aNotification {
	_bookmarks = [[[NSUserDefaults standardUserDefaults] 
					dictionaryForKey: @"bookmarks"] mutableCopy];
	if (_bookmarks != nil) {
		[_bookmarks retain];
		NSArray* keys = [[_bookmarks allKeys] sortedArrayUsingFunction: 
							strCompare context: NULL];
		NSEnumerator* enumerator = [keys objectEnumerator];
		NSString* aKey;
		while ((aKey = [enumerator nextObject]) != nil) {
//			NSString* data = [_bookmarks objectForKey: aKey];
			[_bookmarkMenu addItemWithTitle:aKey action:@selector(selectBookmark:) 
					keyEquivalent:@""];
		}
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

//----------------------------------------------------------------------------------------
//  applicationWillTerminate:
//
//      Notification that the application is exiting. Save bookmarks to user prefs.
//
//  applicationWillTerminate: NSNotification * notification    -> ignored
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)applicationWillTerminate: (NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] setObject: _bookmarks forKey: @"bookmarks"];
}

//----------------------------------------------------------------------------------------
//  addBookmark:withTitle:
//
//      Add a bookmark with the specified state and title.
//
//  addBookmark: FractalState* s   -> the state to save in bookmark.
//  withTitle: NSString* title     -> the title for the bookmark.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)addBookmark: (FractalState*) s withTitle: (NSString*) title {
	NSString* str = [self stringFromState:s];
	int itemIndex;
	int itemCount = [_bookmarkMenu numberOfItems];
	if (_bookmarks == nil) {
		_bookmarks = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	} else {
		if ([_bookmarks objectForKey: title] != nil) {
			int index = [_bookmarkMenu indexOfItemWithTitle: title];
			if (index >= 0) 
				[_bookmarkMenu removeItemAtIndex: index];
		}
	}
	
	[_bookmarks setObject: str forKey: title];
	
	for (itemIndex = 2; itemIndex < itemCount; itemIndex++) {
		NSString* itemTitle = [[_bookmarkMenu itemAtIndex:itemIndex] title];
		if (strCompare(itemTitle, title, NULL) >= 0) 
			break;
	}

	[_bookmarkMenu insertItemWithTitle: title
								action: @selector(selectBookmark:)
						 keyEquivalent: @""
							   atIndex: itemIndex];
}

//----------------------------------------------------------------------------------------
//  findBookmark:forTitle:
//
//      return the state for the specified bookmark.
//
//  findBookmark: FractalState* s  <-> the state (returned)
//  forTitle: NSString* title      -> the title.
//
//  returns BOOL                   <- true if state found and is valid.
//----------------------------------------------------------------------------------------
- (BOOL)findBookmark:(FractalState*) s forTitle: (NSString*) title {
//	printf("%s\n", [[[_bookmarks class] description] cString]);
	NSString* str = [_bookmarks objectForKey: title];
	if (str != nil) {
		return [self state: s fromString: str];
	}
	return NO;
}

@end
