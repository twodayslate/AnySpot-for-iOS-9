#include "AnySpotRootListController.h"

@implementation AnySpotRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
        // Grab the Root.plist file from Resources/Root.plist and present that stuff
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

/* 
 * @param tableView
 * @param indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // As of now just using this method to control and check if activator is installed
    // and display an alert if it is not
	if(indexPath.section == 0 && indexPath.row == 0 && !NSClassFromString(@"LASettingsViewController")) {
		HBLogInfo(@"Activator not installed. Class not found!");

		UIAlertController *alertController = [UIAlertController
                              alertControllerWithTitle:@"libactivator missing!"
                              message:@"The libactivator package is missing. Please install it if you would like to assign an Activator event to AnySpot."
                              preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *cancelAction = [UIAlertAction 
            actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *action)
                    {
                      HBLogDebug(@"Cancel action");

                    }];

		UIAlertAction *okAction = [UIAlertAction 
            actionWithTitle:NSLocalizedString(@"Get", @"OK action")
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action)
                    {
                      HBLogDebug(@"OK action");
                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/libactivator"]];
                      //[self deselectRowAtIndexPath:indexPath animated:YES];
                    }];
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
		[alertController addAction:cancelAction];
		[alertController addAction:okAction];
		//http://useyourloaf.com/blog/2014/09/05/uialertcontroller-changes-in-ios-8.html
		[self presentViewController:alertController animated:YES completion:nil];
	} else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}
@end
