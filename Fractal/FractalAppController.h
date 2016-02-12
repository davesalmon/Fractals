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

#import <Cocoa/Cocoa.h>

#import "FractalWindowController.h"

@interface FractalAppController : NSObject
{
	NSMutableDictionary* _bookmarks;
	IBOutlet NSMenu*	  _bookmarkMenu;
}

+ (FractalAppController*) appController;

- (void)applicationWillFinishLaunching:(NSNotification*)aNotification;
- (void)applicationWillTerminate:(NSNotification *)notification;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)addBookmark:(FractalState*) s withTitle: (NSString*) title;
- (BOOL)findBookmark:(FractalState*) s forTitle: (NSString*) title;

@end
