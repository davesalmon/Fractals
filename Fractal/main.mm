/*
 *  Copyright © 1997-2003 Metrowerks Corporation.  All Rights Reserved.
 *
 *  Questions and comments to:
 *       <mailto:support@metrowerks.com>
 *       <http://www.metrowerks.com/>
 *
 *	The main entry point for this application calls into
 *	the Cocoa framework with the routine NSApplicationMain.
 *	Cocoa then takes care of opening the "NSMainNibFile".
 *	
 *	Note:  Be sure to change the "NSMainNibFile" and
 *	"NSPrincipalClass" keys for your Info.plist if you change
 *	them from the defaults of "MainMenu" and "NSApplication".
 */

#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}
