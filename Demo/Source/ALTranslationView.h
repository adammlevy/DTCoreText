//
//  ALTranslationView.h
//  DTCoreText
//
//  Created by Adam Levy on 3/2/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALVocabItem.h"

@interface ALTranslationView : UIView

@property (nonatomic, strong) ALVocabItem *vocabItem;

- (id)initWithVocabItem:(ALVocabItem *)vocabItem wordFrame:(CGRect)wordFrame;

@end
