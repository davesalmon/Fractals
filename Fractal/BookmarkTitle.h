/*+
 *
 *  BookmarkTitle.h
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

#import <Cocoa/Cocoa.h>

@interface BookmarkTitle : NSWindowController
{
	IBOutlet NSTextField*	_text;
	IBOutlet NSButton* 		_okButton;
	IBOutlet NSButton* 		_cancelButton;
}

+ (NSString*) runDialog: (NSWindow*) window;

- (id) init;

- (IBAction) okButton: (id) sender;
- (IBAction) cancelButton: (id) sender;

- (void)controlTextDidChange:(NSNotification *)obj;

- (NSString*) value;

@end
