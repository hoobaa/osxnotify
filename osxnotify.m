// clang -framework Foundation osxnotify.m -o osxnotify

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NSString *fakeBundleIdentifier = nil;

@implementation NSBundle(swizle) // Overriding bundleIdentifier works, but overriding NSUserNotificationAlertStyle does not work.
- (NSString *)__bundleIdentifier
{
    if (self == [NSBundle mainBundle]) {
        return fakeBundleIdentifier ? fakeBundleIdentifier : @"com.apple.finder";
    } else {
        return [self __bundleIdentifier];
    }
}
@end

BOOL installNSBundleHook()
{
    Class class = objc_getClass("NSBundle");
    if (class) {
        method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)),
                                       class_getInstanceMethod(class, @selector(__bundleIdentifier)));
        return YES;
    }
	return NO;
}


@interface NotificationCenterDelegate : NSObject<NSUserNotificationCenterDelegate>
@property (nonatomic, assign) BOOL keepRunning;
@end

@implementation NotificationCenterDelegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    self.keepRunning = NO;
}
@end

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (installNSBundleHook()) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            fakeBundleIdentifier = [defaults stringForKey:@"identifier"];
            
            NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
            NotificationCenterDelegate *ncDelegate = [[NotificationCenterDelegate alloc]init];
            ncDelegate.keepRunning = YES;
            nc.delegate = ncDelegate;
            
            NSUserNotification *note = [[NSUserNotification alloc] init];
            note.title = [defaults stringForKey:@"title"];
            note.subtitle = [defaults stringForKey:@"subtitle"];
            note.informativeText = [defaults stringForKey:@"informativeText"];
            
            if (!(note.title || note.subtitle || note.informativeText)) {
                note.title = @"Usage: usernotification";
                note.informativeText = @"Options: [-identifier <IDENTIFIER>] [-title <TEXT>] [-subtitle TEXT] [-informativeText TEXT]";
            }
            
            [nc deliverNotification:note];
            
            while (ncDelegate.keepRunning) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        }
    }
    return 0;
}
