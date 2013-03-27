//
//  ALVocabItem.h
//  DTCoreText
//
//  Created by Adam Levy on 3/3/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALVocabItem : NSObject

@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSString *translation;
@property (nonatomic, copy) NSString *pinyin;

@end
