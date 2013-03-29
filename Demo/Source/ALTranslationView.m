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
@property (nonatomic, assign) CGRect selectedWordFrame;
@end

@implementation ALTranslationView

- (id)initWithVocabItem:(ALVocabItem *)vocab wordFrame:(CGRect)wordFrame {
	self.selectedWordFrame = wordFrame;
	CGRect frame = CGRectMake(wordFrame.origin.x + 5, wordFrame.origin.y - 50 - wordFrame.size.height, 250, 50);
	self = [super initWithFrame:frame];
	if (self) {
		self.vocabItem = vocab;
		
		self.backgroundColor = [UIColor whiteColor];
		
		CGSize maxSize = CGSizeMake(self.frame.size.width, 9999);
		UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:15];
		CGSize wordLabelSize = [_vocabItem.word sizeWithFont:labelFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
		CGSize translationLabelSize = [_vocabItem.translation sizeWithFont:labelFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
		
		// add word label
		CGRect wordLabelFrame = CGRectMake(5, 5, frame.size.width -10, wordLabelSize.height);
		self.wordLabel = [[UILabel alloc] initWithFrame:wordLabelFrame];
		self.wordLabel.font = labelFont;
		self.wordLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		self.wordLabel.numberOfLines = 0;
		self.wordLabel.lineBreakMode = NSLineBreakByWordWrapping;
		self.wordLabel.text = [NSString stringWithFormat:@"%@ %@", self.vocabItem.word, self.vocabItem.pinyin];
		[self addSubview:_wordLabel];
		
		// add translation label
		CGRect translationLabelFrame = CGRectMake(5, wordLabelFrame.origin.y + wordLabelFrame.size.height, wordLabelFrame.size.width, translationLabelSize.height);
		self.translationLabel = [[UILabel alloc] initWithFrame:translationLabelFrame];
		self.translationLabel.font = labelFont;
		self.translationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		self.translationLabel.numberOfLines = 0;
		self.translationLabel.lineBreakMode = NSLineBreakByWordWrapping;
		self.translationLabel.text = self.vocabItem.translation;
		[self addSubview:_translationLabel];
		
		// add play button
		self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect playButtonRect = self.playButton.frame;
		playButtonRect.size.width = 30;
		playButtonRect.size.height = 30;
		playButtonRect.origin.x = self.frame.size.width/2 - playButtonRect.size.width/2;
		playButtonRect.origin.y = self.frame.size.height - playButtonRect.size.height - 5;
		self.playButton.frame = playButtonRect;
		[self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		self.playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playButton];
		
		CGRect frame = self.frame;
		frame.size.height = wordLabelSize.height + translationLabelSize.height + _playButton.frame.size.height + 10;
		frame.origin.y = wordFrame.origin.y - frame.size.height + 5;
		self.frame = frame;
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
