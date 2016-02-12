/*+
 *
 *  BookmarkTitle.m
 *
 *  Copyright © 2003 David C. Salmon. All Rights Reserved.
 *
 *  Handle the bookmark title sheet.
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

#import "BookmarkTitle.h"

@implementation BookmarkTitle

//----------------------------------------------------------------------------------------
//  runDialog:
//
//      run the sheet and return the title for the bookmark.
//
//  runDialog: NSWindow* window    -> the window for the sheet.
//
//  returns NSString*              <- the title.
//----------------------------------------------------------------------------------------
+ (NSString*) runDialog: (NSWindow*) window {
	int rVal = 0;
	NSString* response = nil;
	BookmarkTitle* dialog = [[BookmarkTitle alloc] init];
	
	[NSApp 	beginSheet:[dialog window] 
			modalForWindow:window 
			modalDelegate:nil 
			didEndSelector:nil 
			contextInfo:nil];
	rVal = [NSApp runModalForWindow: [dialog window]]; 
	[NSApp endSheet: [dialog window]];
	
	if (rVal == NSRunStoppedResponse) {
		response = [dialog value];
	}
	
	[dialog close];
	[dialog release];
	return response;
}

//----------------------------------------------------------------------------------------
//  init
//
//      intialize.
//
//  returns id <- self
//----------------------------------------------------------------------------------------
- (id) init {
	[self initWithWindowNibName:@"BookmarkTitle"];
	[self window];
	[_text setStringValue: @"Fractal"];
	[_okButton setKeyEquivalent: @"\r"];
	return self;
}

//----------------------------------------------------------------------------------------
//  okButton:
//
//      handle ok button press. stop the sheet.
//
//  okButton: id sender    -> ignored.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) okButton: (id) sender {
	[NSApp stopModal];
}

//----------------------------------------------------------------------------------------
//  cancelButton:
//
//      handle cancel button press. abort the sheet.
//
//  cancelButton: id sender    -> 
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (IBAction) cancelButton: (id) sender {
	[NSApp abortModal];
}

//----------------------------------------------------------------------------------------
//  value
//
//      return the value.
//
//  returns NSString*  <- return the title value.
//----------------------------------------------------------------------------------------
- (NSString*) value {
	return [_text stringValue];
}

//----------------------------------------------------------------------------------------
//  controlTextDidChange:
//
//      ensure that there is a title specified.
//
//  controlTextDidChange: NSNotification * obj -> ignored.
//
//  returns nothing
//----------------------------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)obj {
	if ([[self value] length] == 0) {
		[_okButton setEnabled: NO];
		[_cancelButton setKeyEquivalent: @"\r"];
	} else {
		[_okButton setEnabled: YES];
		[_okButton setKeyEquivalent: @"\r"];
		[_cancelButton setKeyEquivalent: @"\x1b"];
	}
}

@end
