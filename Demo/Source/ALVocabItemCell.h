//
//  ALVocabItemCell.h
//  DTCoreText
//
//  Created by Adam Levy on 3/12/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALVocabItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *word;
@property (nonatomic, strong) IBOutlet UILabel *translation;
@property (nonatomic, strong) IBOutlet UILabel *attribute;

@end
