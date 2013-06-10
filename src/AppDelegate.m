//
//  AppDelegate.m

#import "AppDelegate.h"

@implementation AppDelegate


//return true if Intel
- (BOOL) getGFXStatus {
    
    NSTask *task;
    task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/bin/bash"];
    
    NSArray *arguments;
    //arguments = [NSArray arrayWithObjects: @"-c", @"\"/usr/sbin/system_profiler SPDisplaysDataType | /usr/bin/grep Intel -A15 | /usr/bin/grep Displays\"", nil];
    
    arguments = [NSArray arrayWithObjects: @"-c", @"/usr/sbin/system_profiler SPDisplaysDataType | /usr/bin/grep Intel -A15 | /usr/bin/grep Displays", nil];
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    
    //trim string
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog (@"parsed: \n%@", string);
    return [string isEqualToString:GREP_OUTPUT];
}



#pragma mark - lifecycle
- (void) awakeFromNib {
    // obtain a new statusItem from the global NSStatusBar
    float width = 20.0;
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
    [statusItem setHighlightMode:YES];
    
    // create a new NSMenu for the status bar item
    NSMenu *menu = [[NSMenu alloc] init];

    // create some top level menu items
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit_application) keyEquivalent:@"Q"];
    
    [menu addItem:quit];
   
    
    //[statusItem setTitle:@"i"];
    [statusItem setMenu:menu];
    
    
    // If your application is background (LSBackgroundOnly) then you need this call
    // otherwise the window manager will draw other windows on top of your menu
    //[NSApp activateIgnoringOtherApps:YES];
    
    NSLog(@"Starting GFX Status App - Launching Worker Thread");
    
    _working = true;
    
    [NSThread detachNewThreadSelector:@selector(updateGFXStatus:) toTarget:self withObject:nil];
    

}


-(void)updateGFXStatus:(id)sender {
    
    // Perform a search operation here
    
    while(_working) {
        
        BOOL isIntel = [self getGFXStatus];
        
        if (isIntel) {
            [statusItem setTitle:@"i"];
        } else {
            [statusItem setTitle:@"n"];
        }

        
        sleep(DEFAULT_SLEEP);
    }
    
    [NSThread exit];
}


- (void) dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}


#pragma mark - Menu Actions
- (void) doSomethingCool {
    NSLog(@"Doing something really awesome!");
}

- (void) quit_application {
    _working = false;
    NSLog(@"exiting");
    exit(0);
}

@end
