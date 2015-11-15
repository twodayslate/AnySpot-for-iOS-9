#import <UIKit/UIKit.h>
#import "AnySpotActivator.h"
#import "AnySpotHeaders.h"

static UIWindow *latestHostWindow = nil;
static NSString *latestBundleID = nil;
static UIImageView *latestSnapshotView = nil;
static BOOL didLaunchfrominsideapplication = NO;

static NSMutableDictionary *settings = nil;

/* 
 * Does any necessary cleanup of Spotlight if launched from an application
 * Running in the main queue to avoid exceptions for doing graphics stuff
 */
static void cleanup() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(latestHostWindow) {
            HBLogDebug(@"Restting window level to original value");
            latestHostWindow.windowLevel = 0.0;
        }
        
        if(latestSnapshotView) {
            HBLogDebug(@"remvoing from superview");
            // Not sure if all this is necessary. Probably not. 
            [latestSnapshotView removeFromSuperview];
            [latestSnapshotView release];
            latestSnapshotView = nil;
        }
        
        // For some reason the above doesn't want to work all the time so I have to do this
        UIView *outerview = ((SBSearchViewController *)[%c(SBSearchViewController) sharedInstance]).view;
        for(UIView *view in outerview.subviews) {
            if([view isKindOfClass:[UIImageView class]]) {
                HBLogDebug(@"Darn thing was hiding!");
                [view removeFromSuperview];
            }
        }
        
        BOOL extraSmooth = [settings objectForKey:@"extraSmooth"] ? [[settings objectForKey:@"extraSmooth"] boolValue] : NO;
        HBLogDebug(@"Want extra smoothness? = %f", (float) extraSmooth);
        if(extraSmooth) {
            [[outerview.superview viewWithTag:666] removeFromSuperview];
        }
    });
    didLaunchfrominsideapplication = NO;
    latestBundleID = @"";
}

%hook SPUISearchViewController
/* 
 * Need to cleanup when Spotlight is dismissed
 * Although, this is not always called after launching from spotlight
 */
- (void)_didFinishDismissing {
    %log;
    %orig;
    cleanup();
}

/* 
 * If already inside an application, and it tries to launch itself, just dismiss spotlight
 * Can continue to do original action as mail might be trying to open a different
 * email or something like that - that is a bad example but you get the idea
 */
+ (void)openApplicationWithBundleID:(id)arg1 {
    %log;
    if(latestBundleID && [latestBundleID isEqualToString:arg1]){
        [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
    }
    %orig;
}
/*
 * Similiar to + (void)openApplicationWithBundleID:(id)arg1 except has more details
 * Have to cleanup so add that to the completion handler
 * HAVE TO RUN dismiss in main thread or the device will crash
 * @param arg1 the bundle identifier for the application that is being launched
 * @param arg2 the action that will occure when the application is done launching
 *             for example, when launching mail, it will then go to a certain email
 * @param arg3 what happens when everything is done. I think this is for breadcrumbs
 */
+ (void)openApplicationWithBundleID:(id)arg1 continuationAction:(id)arg2 completionHandler:(void(^)(void))arg3 {
    HBLogDebug(@"SPUISearchViewController openApplicationWithBundleID:%@ continuationAction:%@ completionHandler:%@", arg1, arg2, (id)arg3);
    if(latestBundleID && [latestBundleID isEqualToString:arg1]){
        [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
    } else {
        if(arg3) {
            void (^blockName)(void) = ^ {
                cleanup();
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
                });
                Block_copy(arg3);
            };
            %orig(arg1, arg2, blockName);
        } else {
            void (^blockName)(void) = ^ {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
                });
            };
            
            %orig(arg1, arg2, blockName);
        }
    }
}

/*
 * Need to cleanup after opening a URL (Search web)
 * _displayLaunched: is also called for a search
 * @param arg1 the url that will be launched
 */
- (void)openURL:(id)arg1 {
    %log;
    if(didLaunchfrominsideapplication) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
        });
    }
    %orig;
}
%end

%hook SBMainDisplaySceneManager
/*
 * Determines if a breadcrumb should show
 * @param arg1 where you are going
 * @param arg2 where you came from
 * @return YES if you want a breadcrumb
 */
- (_Bool)_shouldBreadcrumbApplication:(id)arg1 withTransitionContext:(id)arg2 {
    %log;
    // This will remove the breadcrumb that will take you back to Spotlight
    // on SpringBoard's homescreen if launched from inside an application
    // What should actually happen is the breadcrumb should take you back to the application
    if(didLaunchfrominsideapplication) {
        cleanup();
        return NO;
    }
    return %orig;
}
%end

%hook SpringBoard
/*
 * You need this to enable rotation on non-rotatable devices
 * Currently not being used
 * @return YES if you want rotation
 */
- (_Bool)homeScreenSupportsRotation {
    if([(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]) {
        return YES;
    }
    return %orig;
}
/*
 * You need this to enable rotation on non-rotatable devices
 * Currently not being used
 * @return YES if you want rotation
 */
- (_Bool)homeScreenRotationStyleWantsUIKitRotation {
    if([(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]) {
        return YES;
    }
    return %orig;
}

/*
 * You need this to enable rotation on non-rotatable devices
 * Currently not being used
 * @return the style of rotation, doesn't really matter I don't think
 */
- (long long)homeScreenRotationStyle {
    if([(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]) {
        return 1.0;
    }
    return %orig;
}

/* 
 * Since not all devices support orientation we will have to do some things
 * to get Spotlight to not look terrible when rotating
 * Pretty sure Ethan can make this better but I'm not gonna bother him
 * @param arg1 the new orientation of the device
 * @param arg2 how long the animation will last
 */
- (void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 {
    // duration is usually 3 or 4
    %log;
    %orig;
    if([(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]) {
        if(![(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] _isSupportedInterfaceOrientation:arg1]) {
            HBLogWarn(@"AnySpot9: Interface is not supported so have to dismiss. Sorry!");
            [(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
        } else {
            SBApplication *frontMostApplication = [(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];
            latestBundleID =[frontMostApplication bundleIdentifier];
            HBLogDebug(@"AnySpot9: frontMostApplication = %@", frontMostApplication);
            // Check if in application
            if(frontMostApplication != nil) {
                FBScene *appScene = [frontMostApplication mainScene];
                FBWindowContextHostManager *contextHost = [appScene contextHostManager];
                UIImage *snapshot = [contextHost snapshotUIImageForFrame:[[UIScreen mainScreen] applicationFrame] excludingContexts:nil opaque:NO outTransform:nil];
                latestSnapshotView = [[UIImageView alloc] initWithImage:snapshot];
            }
        }
    }
}
%end


@implementation AnySpotActivator
- (void)activator:(id)activator receiveEvent:(LAEvent *)event {
	HBLogDebug(@"AnySpot9: event = %@", event);

	HBLogDebug(@"AnySpot9: _isShowingSearch = %d", [(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]);
	HBLogDebug(@"AnySpot9: SBSearchGesture.activeted = %d", ((SBSearchGesture *)[%c(SBSearchGesture) sharedInstance]).activated);
	
    didLaunchfrominsideapplication = NO;
    
    // First check if search is showing...
	if([(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] _isShowingSearch]) {
        HBLogInfo(@"AnySpot9: Dismissing since Spotlight is already showing.");
		[(SBSearchViewController *)[%c(SBSearchViewController) sharedInstance] dismiss];
	}
    else {
	 	HBLogDebug(@"AnySpot9: keyWindow = %@", (SBHomeScreenWindow *)((SpringBoard *)[%c(SpringBoard) sharedApplication]).keyWindow);
	 	SBApplication *frontMostApplication = [(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];
        latestBundleID =[frontMostApplication bundleIdentifier];
        
		HBLogDebug(@"AnySpot9: frontMostApplication = %@", frontMostApplication);
		
        // Check if in application
		if(frontMostApplication != nil) {
            HBLogInfo(@"AnySpot9: Launching from inside %@", latestBundleID);
             didLaunchfrominsideapplication = YES;
			FBScene *appScene = [frontMostApplication mainScene];
		    FBWindowContextHostManager *contextHost = [appScene contextHostManager];
            UIImage *snapshot = [contextHost snapshotUIImageForFrame:[[UIScreen mainScreen] applicationFrame] excludingContexts:nil opaque:NO outTransform:nil];
            latestSnapshotView = [[UIImageView alloc] initWithImage:snapshot];
            latestSnapshotView.tag = 666;
            
		    latestHostWindow = [[contextHost valueForKey:@"_hostView"] window];
            
            UIView *outerview = ((SBSearchViewController *)[%c(SBSearchViewController) sharedInstance]).view;
            // I would love to insert the image in outerview's superview but this caused
            //  removing it more difficult.
            HBLogDebug(@"Adding UIImage to %@", outerview);
            
            BOOL extraSmooth = [settings objectForKey:@"extraSmooth"] ? [[settings objectForKey:@"extraSmooth"] boolValue] : NO;
            if(extraSmooth) {
                HBLogDebug(@"Going for some extra smoothness");
                [outerview.superview insertSubview:latestSnapshotView belowSubview:outerview];
            } else {
                [outerview insertSubview:latestSnapshotView atIndex:0];
            }
            
		    latestHostWindow.windowLevel = -3.0; // put it under the homescreen which is -2.0
		    [(SBUIController *)[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];
		    //[[SBWallpaperController sharedInstance] beginRequiringWithReason:@"HSCloseAppGesture"];
            
			[(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] revealAnimated:YES];
		}
        else {
			//check if on the lockscreen
			if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
                HBLogInfo(@"AnySpot9: Screen is locked so cannot display Spotlight. Sorry!");
			}
            else {
                HBLogInfo(@"AnySpot9: Launching from SpringBoard.");
				[(SpringBoard*)[%c(SpringBoard) sharedApplication] _revealSpotlight];
			}
		}
	}
    
	[event setHandled:YES];
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"AnySpot";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Toggle AnySpot.";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
@end

static void getSettings() {
    
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.anyspot9.plist"];
    //logging = [settings objectForKey:@"logging_enabled"] ? [[settings objectForKey:@"logging_enabled"] boolValue] : NO;
    HBLogDebug(@"Settings changed or initiated %@", settings);
}

%ctor {
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
    static AnySpotActivator *listener = [[AnySpotActivator alloc] init];
    [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:listener forName:@"org.thebigboss.anyspot9"];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)getSettings, CFSTR("org.thebigboss.anyspot9/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    getSettings();

}