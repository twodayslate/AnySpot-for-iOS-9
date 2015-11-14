%hook SBSearchGesture
-(void)resetAnimated:(_Bool)arg1 {
    %log;
    %orig;
}
- (void)_displayLaunched:(id)arg1 {
    %log;
    %orig;
}
%end

%hook SPUISearchViewController
- (BOOL)_isPullDownSpotlight {
    // This makes it so it always shows more Siri suggestions:
    //      Nearby, and News
    //  However, you lose the up swipe to dismiss
    %log;
    return %orig;
}
%end

%hook SBSearchViewController
- (void)dismissAnimated:(_Bool)arg1 completionBlock:(id)arg2 {
    // Not sure if this is worth hooking and adding to the completion block
    %log;
    %orig;
}
- (void)searchViewControllerWillTriggerLaunch {
    %log;
    %orig;
}
%end

%hook SPUISearchViewController
+ (void)openApplicationWithBundleID:(id)arg1 {
    %log;
    %orig;
}

- (void)didSelectActionItemForResult:(id)arg1 {
    %log;
    %orig;
}
- (void)_dismissAnimated:(BOOL)arg1 completionBlock:(id)arg2 {
    %log;
    %orig;
}
- (void)actionManager:(id)arg1 dismissAnimated:(BOOL)arg2 completionBlock:(id /* block */)arg3 {
    %log;
    %orig;
}
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
    %log;
    %orig;
}
%end

%hook SBIconController
- (_Bool)_dismissRightEdgeSpotlight:(_Bool)arg1 {
    %log;
    return %orig;
}
- (_Bool)_presentRightEdgeSpotlight:(_Bool)arg1 {
    %log;
    return %orig;
}
- (_Bool)_dismissTopEdgeSpotlight:(_Bool)arg1 {
    %log;
    return %orig;
}
- (_Bool)_presentTopEdgeSpotlight:(_Bool)arg1 {
    %log;
    return %orig;
}
- (void)_searchViewControllerIsPresented:(_Bool)arg1 fromBreadcrumb:(_Bool)arg2 {
    %log;
    %orig;
}
- (_Bool)dismissSpotlightIfNecessary {
    %log;
    return %orig;
}
- (_Bool)dismissSpotlightAnimated:(_Bool)arg1 {
    %log;
    return %orig;
}
- (_Bool)presentSpotlightFromEdge:(unsigned long long)arg1 fromBreadcrumb:(_Bool)arg2 animated:(_Bool)arg3 {
    %log;
    return %orig;
}

%end

%hook SBMainDisplaySceneManager
- (_Bool)_isActivatingPinnedBreadcrumbApp:(id)arg1 withTransitionContext:(id)arg2 {
    %log;
    return %orig;
}
- (id)_breadcrumbNavigationActionForApplication:(id)arg1 withTransitionContext:(id)arg2{
    %log;
    return %orig;
}
- (void)_activateAppLink:(id)arg1 withAppLinkState:(id)arg2 transitionContext:(id)arg3 wasFromSpotlight:(_Bool)arg4 previousBreadcrumb:(id)arg5 {
    %log;
    %orig;
}
- (void)_activateBreadcrumbApplication:(id)arg1 {
    %log;
    %orig;
}
- (id)_breadcrumbBundleIdForApplication:(id)arg1 withTransitionContext:(id)arg2 {
    %log;
    return %orig;
}
- (void)_presentSpotlightFromEdge:(unsigned long long)arg1 fromBreadcrumb:(_Bool)arg2 {
    %log;
    %orig;
}
%end