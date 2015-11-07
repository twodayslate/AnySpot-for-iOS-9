@interface SpringBoard
+ (id)sharedApplication;
-(id)_accessibilityFrontMostApplication;
-(BOOL)isLocked;
-(void)_revealSpotlight;
@property (nonatomic,readonly) UIWindow * keyWindow;
@end

@interface SBSearchGesture
+ (SBSearchGesture *)sharedInstance;
- (void)revealAnimated:(_Bool)arg1;
- (_Bool)_isShowingSearch;
@property(readonly, nonatomic, getter=isActivated) _Bool activated;
@end

@interface SBSearchViewController : UIViewController
+ (SBSearchViewController *)sharedInstance;
- (void)dismiss;
- (void)searchViewControllerWillTriggerLaunch;
- (BOOL)_isSupportedInterfaceOrientation:(int)arg1;
@end

@interface SBHomeScreenWindow : UIWindow
@end

@interface SBApplication 
- (id)mainScene;
- (id)bundleIdentifier;
@end

@interface FBScene
- (id)contextHostManager;
@end

@interface FBWindowContextHostManager : NSObject
-(id)snapshotUIImageForFrame:(CGRect)arg1 excludingContexts:(id)arg2 opaque:(BOOL)arg3 outTransform:(CGAffineTransform*)arg4 ;
@end

@interface SBUIController : NSObject
+ (SBUIController *)sharedInstance;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
@end

@interface SBWallpaperController : NSObject
+ (SBWallpaperController *)sharedInstance;
- (void)beginRequiringWithReason:(id)reason;
@end

@interface UIView (extras)
-(id)recursiveDescription;
@end