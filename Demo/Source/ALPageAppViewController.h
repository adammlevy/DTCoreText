//
//  ALPageAppViewController.h
//  DTCoreText
//
//  Created by Adam Levy on 3/29/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALPageAppViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageContent;

@end
