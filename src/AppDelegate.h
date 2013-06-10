#import <Cocoa/Cocoa.h>

NSString *const GREP_OUTPUT = @"Displays:";
const int DEFAULT_SLEEP = 20;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
    BOOL _working;
}
@property (atomic) BOOL working;

@end
