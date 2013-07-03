//
//  AppDelegate.m

#import "AppDelegate.h"

@implementation AppDelegate

- (enum GFX_RET_TYPE) getGFXStatus {
    
    NSTask *task = [[NSTask alloc] init];
    if (task == nil) {
        NSLog(@"failed alloc or init for task");
        return ERROR;
    }

    NSPipe *pipe = [NSPipe pipe];
    
    if (pipe == nil) {
        NSLog(@"failed init for pipe, maybe ran out of file descriptors?");
        return ERROR;
    }
    
    [task setLaunchPath:@"/bin/bash"];
    
    NSArray *arguments;
    
    arguments = [NSArray arrayWithObjects: @"-c", @"/usr/sbin/system_profiler SPDisplaysDataType | /usr/bin/grep Intel -A15 | /usr/bin/grep Displays", nil];
    
    [task setArguments: arguments];
    
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
   
    [file closeFile];
    
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


- (int) getCPUUsage:(int *) average {
    
    natural_t numCPUsU = 0U;
    
    kern_return_t err = host_processor_info(mach_host_self(),
                                            PROCESSOR_CPU_LOAD_INFO,
                                            &numCPUsU, &cpuInfo,
                                            &numCpuInfo);
    
    if(err != KERN_SUCCESS)
    {
        return CPU_USAGE_ERROR;
    }
    
    
    [CPUUsageLock lock];
    
    float sum = 0;
    
    int usedCores = 0; //only count cores that are used more than 1%
    
    for(unsigned i = 0U; i < numCPUs; ++i) {
        float inUse, total;
        if(prevCpuInfo) {
            inUse = (
                     (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                     + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                     + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                    );
            total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] -
                             prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
        } else {
            inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] +
                    cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] +
                    cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
            total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
        }
        
        if (inUse / total > 0.01) {
            sum += inUse / total;
            usedCores++;
            NSLog(@"Core: %u Usage: %d", i, (int) (100 * inUse / total));
        }
    }
    
    [CPUUsageLock unlock];
    
    if (usedCores > 0) {
        *average = (int) (100 * sum / usedCores);
    } else {
        *average = 0;
    }


    if(prevCpuInfo) {
        size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
        vm_deallocate(mach_task_self(), (vm_address_t) prevCpuInfo, prevCpuInfoSize);
    }
    
    prevCpuInfo = cpuInfo;
    numPrevCpuInfo = numCpuInfo;
    
    cpuInfo = NULL;
    numCpuInfo = 0U;
    
    return CPU_USAGE_SUCCESS;
}


- (void) initCPUUsage {
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
}


#pragma mark - lifecycle
- (void) awakeFromNib {
    // obtain a new statusItem from the global NSStatusBar
    float width = 40.0;
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
    
    NSLog(@"Starting");
    
    _working = true;
    
    [self initCPUUsage];
    
    [NSThread detachNewThreadSelector:@selector(updateGFXStatus:) toTarget:self withObject:nil];
    
}


-(void)updateGFXStatus:(id)sender {
    
    while(_working) {
        
        NSString *status;
        
        enum GFX_RET_TYPE ret = [self getGFXStatus];
        
        if (ret == INTEGRATED) {
            status = @"i";
        } else if (ret == DISCRETE){
            status = @"n";
        } else {
            assert(ret == ERROR);
            status = @"e";
        }
        
        int average;
        int ret_cpu_usage = [self getCPUUsage: &average];
        
        if (ret_cpu_usage != CPU_USAGE_ERROR) {
            status = [NSString stringWithFormat:@"%@%d%@", status, average, @"%"];
        } else {
            status = [NSString stringWithFormat:@"%@%@", status, @"e"];
        }
  
        [statusItem setTitle:status];
        
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
