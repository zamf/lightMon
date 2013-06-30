//
//  AppDelegate.m

#import "AppDelegate.h"

@implementation AppDelegate

- (enum GFX_RET_TYPE) getGFXStatus {
    
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    
    if (pipe == nil || task == nil) {
        NSLog(@"allocation error");
        return ERROR;
    }
    
    [task setLaunchPath:@"/bin/bash"];
    
    NSArray *arguments;
    
    arguments = [NSArray arrayWithObjects: @"-c", @"/usr/sbin/system_profiler SPDisplaysDataType | /usr/bin/grep Intel -A15 | /usr/bin/grep Displays", nil];
    
    [task setArguments: arguments];
    
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    //trim string
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:GREP_OUTPUT]) {
        return INTEGRATED;
    } else {
        return DISCRETE;
    }
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
   
    
    [statusItem setMenu:menu];
    
    
    // If your application is background (LSBackgroundOnly) then you need this call
    // otherwise the window manager will draw other windows on top of your menu
    [NSApp activateIgnoringOtherApps:YES];
    
    NSLog(@"Starting GFX Status App - Launching Worker Thread");
    
    _working = true;
    
    [NSThread detachNewThreadSelector:@selector(updateGFXStatus:) toTarget:self withObject:nil];
    
}


-(void)updateGFXStatus:(id)sender {
    
    while(_working) {
        
        enum GFX_RET_TYPE ret = [self getGFXStatus];
        
        if (ret == INTEGRATED) {
            [statusItem setTitle:@"i"];
        } else if (ret == DISCRETE){
            [statusItem setTitle:@"n"];
        } else {
            assert(ret == ERROR);
            [statusItem setTitle:@"e"];
        }

        
        sleep(DEFAULT_SLEEP);
    }
    
    [NSThread exit];
}


- (void) dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}


- (void) quit_application {
    _working = false;
    NSLog(@"exiting");
    exit(0);
}

@end
