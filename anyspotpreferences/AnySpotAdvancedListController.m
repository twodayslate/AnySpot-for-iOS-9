#include "AnySpotAdvancedListController.h"

@implementation AnySpotAdvancedListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        // Grab the Root.plist file from Resources/Root.plist and present that stuff
        _specifiers = [[self loadSpecifiersFromPlistName:@"AnySpotAdvanced" target:self] retain];
    }
    
    return _specifiers;
}

@end
