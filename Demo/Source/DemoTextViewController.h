//
//  DemoTextViewController.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "DTAttributedTextView.h"
#import "DTLazyImageView.h"

@interface DemoTextViewController : UIViewController <UIActionSheetDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSURL *lastActionLink;

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) NSDictionary *vocabulary;

@property (nonatomic, strong) NSDictionary *rowSnippet;


@end
