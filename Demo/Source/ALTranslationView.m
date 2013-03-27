//
//  ALTranslationView.m
//  DTCoreText
//
//  Created by Adam Levy on 3/2/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ALTranslationView.h"
#import "ALAttributeItem.h"

@interface ALTranslationView ()
@property (nonatomic, strong) UILabel *wordLabel;
@property (nonatomic, strong) UILabel *translationLabel;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation ALTranslationView

- (id)initWithVocabItem:(ALVocabItem *)vocab wordFrame:(CGRect)wordFrame {
	CGRect frame = CGRectMake(0, -50, 250, 50);
	self = [super initWithFrame:frame];
	if (self) {
		self.vocabItem = vocab;
		
		self.backgroundColor = [UIColor whiteColor];
		
		// add word label
		CGRect wordLabelFrame = CGRectMake(5, 5, frame.size.width -10, 20);
		self.wordLabel = [[UILabel alloc] initWithFrame:wordLabelFrame];
		self.wordLabel.numberOfLines = 0;
		self.wordLabel.lineBreakMode = NSLineBreakByWordWrapping;
		self.wordLabel.text = [NSString stringWithFormat:@"%@ %@", self.vocabItem.word, self.vocabItem.pinyin];
		[self addSubview:_wordLabel];
		
		// add translation label
		CGRect translationLabelFrame = CGRectMake(5, wordLabelFrame.origin.y + wordLabelFrame.size.height, wordLabelFrame.size.width, wordLabelFrame.size.height);
		self.translationLabel = [[UILabel alloc] initWithFrame:translationLabelFrame];
		self.translationLabel.numberOfLines = 0;
		self.translationLabel.lineBreakMode = NSLineBreakByWordWrapping;
		self.translationLabel.text = self.vocabItem.translation;
		[self addSubview:_translationLabel];
		
		// add play button
		self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		[self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playButton];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGSize maxSize = CGSizeMake(self.frame.size.width, 9999);
	CGSize wordLabelSize = [_vocabItem.word sizeWithFont:_wordLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
	CGSize translationLabelSize = [_vocabItem.translation sizeWithFont:_translationLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
	
	// adjust word frame
	CGRect wordLabelFrame = self.wordLabel.frame;
	wordLabelFrame.size.height = wordLabelSize.height;
	self.wordLabel.frame = wordLabelFrame;
	
	// adjust translation frame
	CGRect transLabelFrame = self.translationLabel.frame;
	transLabelFrame.size.height = translationLabelSize.height;
	self.translationLabel.frame = transLabelFrame;
	
	// adjust play button frame
	CGRect buttonRect = _playButton.frame;
	buttonRect.size.width = 30;
	buttonRect.size.height = 30;
	_playButton.frame = buttonRect;
	CGPoint buttonCenter = self.playButton.center;
	buttonCenter.y = self.frame.size.height + buttonRect.size.height - buttonRect.size.height/2;
	buttonCenter.x = self.center.x;
	_playButton.center = buttonCenter;
	
	
	// adjust view frame
	CGRect frame = self.frame;
	frame.size.height = wordLabelSize.height + translationLabelSize.height + _playButton.frame.size.height + 10;
	self.frame = frame;
	
	
	// set up layer
	self.layer.borderWidth = 2;
	self.layer.cornerRadius = 5;
	self.layer.shadowOffset = CGSizeZero;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
	self.layer.shadowOpacity = 0.3f;
	self.layer.shadowRadius = 5.0f;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)playButtonTapped:(id)sender {
	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//	CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    // Set the border width
//    CGContextSetLineWidth(contextRef, 5.0);
//	// Set line cap
//	CGContextSetLineCap(contextRef, kCGLineCapRound);
//    // Set the border color to Black
//    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 0.0, 1.0);
//    // Draw the border along the view edge
//    CGContextStrokeRect(contextRef, rect);
}


@end
