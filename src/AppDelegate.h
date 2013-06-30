#import <Cocoa/Cocoa.h>

NSString *const GREP_OUTPUT = @"Displays:";
const int DEFAULT_SLEEP = 20;

enum GFX_RET_TYPE {
INTEGRATED, DISCRETE, ERROR};


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
    BOOL _working;
}

@property (atomic) BOOL working;

@end
