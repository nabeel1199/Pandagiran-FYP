


#import "UIViewController+MMDrawerController.h"

@implementation UIViewController (MMDrawerController)


-(MMDrawerController*)mm_drawerController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[MMDrawerController class]]){
            return (MMDrawerController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

-(CGRect)mm_visibleDrawerFrame{
    if([self isEqual:self.mm_drawerController.leftDrawerViewController] ||
       [self.navigationController isEqual:self.mm_drawerController.leftDrawerViewController]){
        CGRect rect = self.mm_drawerController.view.bounds;
        rect.size.width = self.mm_drawerController.maximumLeftDrawerWidth;
        if (self.mm_drawerController.showsStatusBarBackgroundView) {
            rect.size.height -= 20.0f;
        }
        return rect;
        
    }
    else if([self isEqual:self.mm_drawerController.rightDrawerViewController] ||
             [self.navigationController isEqual:self.mm_drawerController.rightDrawerViewController]){
        CGRect rect = self.mm_drawerController.view.bounds;
        rect.size.width = self.mm_drawerController.maximumRightDrawerWidth;
        rect.origin.x = CGRectGetWidth(self.mm_drawerController.view.bounds)-rect.size.width;
        if (self.mm_drawerController.showsStatusBarBackgroundView) {
            rect.size.height -= 20.0f;
        }
        return rect;
    }
    else {
        return CGRectNull;
    }
}

@end
