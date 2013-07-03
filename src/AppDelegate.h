#import <Cocoa/Cocoa.h>

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>


#define CPU_USAGE_SUCCESS 0
#define CPU_USAGE_ERROR   1


processor_info_array_t cpuInfo, prevCpuInfo;
mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
unsigned numCPUs;
NSTimer *updateTimer;
NSLock *CPUUsageLock;

NSString *const GREP_OUTPUT = @"Displays:";
const int DEFAULT_SLEEP = 10;

enum GFX_RET_TYPE {
INTEGRATED, DISCRETE, ERROR};



@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
    BOOL _working;
}

@property (atomic) BOOL working;

@end
