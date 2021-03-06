//
//  DemoTextViewController.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "DemoTextViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DTVersion.h"
#import "DTTiledLayerWithoutFade.h"

#import "ALTranslationView.h"

#import "ALVocabListViewController.h"

@interface DemoTextViewController ()
- (void)_segmentedControlChanged:(id)sender;

- (void)linkPushed:(DTLinkButton *)button;
- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture;
- (void)debugButton:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableSet *mediaPlayers;
@property (nonatomic, strong) ALTranslationView *currentTranslationView;

@property (nonatomic, strong) NSMutableDictionary *guids;

@property (nonatomic, strong) UIPopoverController *vocabPopoverController;

@end


@implementation DemoTextViewController
{
	NSString *_fileName;
	
	UISegmentedControl *_segmentedControl;
	DTAttributedTextView *_textView;
	UITextView *_rangeView;
	UITextView *_charsView;
	UITextView *_htmlView;
	UITextView *_iOS6View;
	
	NSURL *baseURL;
	
	// private
	NSURL *lastActionLink;
	NSMutableSet *mediaPlayers;
}


#pragma mark NSObject

- (id)init
{
	self = [super init];
	if (self)
	{
		NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:@"View", @"Ranges", @"Chars", @"HTML", nil];
		
		if (![DTVersion osVersionIsLessThen:@"6.0"])
		{
			[items addObject:@"iOS 6"];
		}
		
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
		_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		_segmentedControl.selectedSegmentIndex = 0;
		[_segmentedControl addTarget:self action:@selector(_segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
		//self.navigationItem.titleView = _segmentedControl;
		
		UIBarButtonItem *vocab = [[UIBarButtonItem alloc] initWithTitle:@"Vocab" style:UIBarButtonItemStyleBordered target:self action:@selector(vocabButtonPressed:)];
		
		NSArray *toolbarItems = [NSArray arrayWithObjects:vocab, nil];
		[self setToolbarItems:toolbarItems];
		
		_guids = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	
	CGRect frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	
	// Create chars view
	_charsView = [[UITextView alloc] initWithFrame:frame];
	_charsView.editable = YES;
	_charsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_charsView];
	
	// Create range view
	_rangeView = [[UITextView alloc] initWithFrame:frame];
	_rangeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_rangeView.editable = NO;
	[self.view addSubview:_rangeView];

	// Create html view
	_htmlView = [[UITextView alloc] initWithFrame:frame];
	_htmlView.editable = NO;
	_htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_htmlView];

	// Create text view
	[DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
	_textView = [[DTAttributedTextView alloc] initWithFrame:frame];
	
	// we draw images and links via subviews provided by delegate methods
	_textView.shouldDrawImages = NO;
	_textView.shouldDrawLinks = NO;
	_textView.textDelegate = self; // delegate for custom sub views
	
	// set an inset. Since the bottom is below a toolbar inset by 44px
	[_textView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
	_textView.contentInset = UIEdgeInsetsMake(10, 10, 54, 10);

	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_textView];
	
	// create a text view to for testing iOS 6 compatibility
	// Create html view
	_iOS6View = [[UITextView alloc] initWithFrame:frame];
	_iOS6View.editable = NO;
	_iOS6View.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
	_iOS6View.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_iOS6View];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	[self.view addGestureRecognizer:tapGesture];
}


- (void)viewTapped:(UITapGestureRecognizer *)sender {
	if (self.currentTranslationView)
		[self.currentTranslationView removeFromSuperview];
}

- (NSAttributedString *)_attributedStringForSnippetUsingiOS6Attributes:(BOOL)useiOS6Attributes
{
	// Load HTML data
	NSString *readmePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:nil];
	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	
	// example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
		// if an element is larger than twice the font size put it in it's own block
		if (element.displayStyle == DTHTMLElementDisplayStyleInline && element.textAttachment.displaySize.height > 2.0 * element.fontDescriptor.pointSize)
		{
			element.displayStyle = DTHTMLElementDisplayStyleBlock;
		}
	};
	
	NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
							 @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, nil];
	
	if (useiOS6Attributes)
	{
		[options setObject:[NSNumber numberWithBool:YES] forKey:DTUseiOS6Attributes];
	}
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
	
	return string;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	CGRect bounds = self.view.bounds;
	_textView.frame = bounds;

	// Display string
	_textView.shouldDrawLinks = NO; // we draw them in DTLinkButton
	_textView.attributedString = [self _attributedStringForSnippetUsingiOS6Attributes:NO];
	
	[self _segmentedControlChanged:nil];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// now the bar is up so we can autoresize again
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillDisappear:(BOOL)animated;
{
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	// stop all playing media
	for (MPMoviePlayerController *player in self.mediaPlayers)
	{
		[player stop];
	}
	
	[super viewWillDisappear:animated];
}


#pragma mark Private Methods

- (void)updateDetailViewForIndex:(NSUInteger)index
{
	switch (index) 
	{
		case 1:
		{
			NSMutableString *dumpOutput = [[NSMutableString alloc] init];
			NSDictionary *attributes = nil;
			NSRange effectiveRange = NSMakeRange(0, 0);
			
			if ([_textView.attributedString length])
			{
				
				while ((attributes = [_textView.attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange]))
				{
					[dumpOutput appendFormat:@"Range: (%d, %d), %@\n\n", effectiveRange.location, effectiveRange.length, attributes];
					effectiveRange.location += effectiveRange.length;
					
					if (effectiveRange.location >= [_textView.attributedString length])
					{
						break;
					}
				}
			}
			_rangeView.text = dumpOutput;
			break;
		}
		case 2:
		{
			// Create characters view
			NSMutableString *dumpOutput = [[NSMutableString alloc] init];
			NSData *dump = [[_textView.attributedString string] dataUsingEncoding:NSUTF8StringEncoding];
			for (NSInteger i = 0; i < [dump length]; i++)
			{
				char *bytes = (char *)[dump bytes];
				char b = bytes[i];
				
				[dumpOutput appendFormat:@"%i: %x %c\n", i, b, b];
			}
			_charsView.text = dumpOutput;
			
			break;
		}
		case 3:
		{
			_htmlView.text = [_textView.attributedString htmlString];
			break;
		}
		case 4:
		{
			if (![_iOS6View.attributedText length])
			{
				_iOS6View.attributedText = [self _attributedStringForSnippetUsingiOS6Attributes:YES];
			}
		}
	}
}

- (void)_segmentedControlChanged:(id)sender {
	UIScrollView *selectedView = _textView;
	
	switch (_segmentedControl.selectedSegmentIndex) {
		case 1:
			selectedView = _rangeView;
			break;
		case 2:
			selectedView = _charsView;
			break;
		case 3:
		{
			selectedView = _htmlView;
			break;
		}
		case 4:
		{
			selectedView = _iOS6View;
			break;
		}
	}

	// refresh only this tab
	[self updateDetailViewForIndex:_segmentedControl.selectedSegmentIndex];
	
	[self.view bringSubviewToFront:selectedView];
	[selectedView flashScrollIndicators];
}


#pragma mark Custom Views on Text

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	[_guids setObject:string.string forKey:identifier];
		
	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	
	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	[button addGestureRecognizer:longPress];
	
	return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if (attachment.contentType == DTTextAttachmentTypeVideoURL)
	{
		NSURL *url = (id)attachment.contentURL;
		
		// we could customize the view that shows before playback starts
		UIView *grayView = [[UIView alloc] initWithFrame:frame];
		grayView.backgroundColor = [DTColor blackColor];
		
		// find a player for this URL if we already got one
		MPMoviePlayerController *player = nil;
		for (player in self.mediaPlayers)
		{
			if ([player.contentURL isEqual:url])
			{
				break;
			}
		}
		
		if (!player)
		{
			player = [[MPMoviePlayerController alloc] initWithContentURL:url];
			[self.mediaPlayers addObject:player];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_2
		NSString *airplayAttr = [attachment.attributes objectForKey:@"x-webkit-airplay"];
		if ([airplayAttr isEqualToString:@"allow"])
		{
			if ([player respondsToSelector:@selector(setAllowsAirPlay:)])
			{
				player.allowsAirPlay = YES;
			}
		}
#endif
		
		NSString *controlsAttr = [attachment.attributes objectForKey:@"controls"];
		if (controlsAttr)
		{
			player.controlStyle = MPMovieControlStyleEmbedded;
		}
		else
		{
			player.controlStyle = MPMovieControlStyleNone;
		}
		
		NSString *loopAttr = [attachment.attributes objectForKey:@"loop"];
		if (loopAttr)
		{
			player.repeatMode = MPMovieRepeatModeOne;
		}
		else
		{
			player.repeatMode = MPMovieRepeatModeNone;
		}
		
		NSString *autoplayAttr = [attachment.attributes objectForKey:@"autoplay"];
		if (autoplayAttr)
		{
			player.shouldAutoplay = YES;
		}
		else
		{
			player.shouldAutoplay = NO;
		}
		
		[player prepareToPlay];
		
		player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		player.view.frame = grayView.bounds;
		[grayView addSubview:player.view];
		
		return grayView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeImage)
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
		if (attachment.contents)
		{
			imageView.image = attachment.contents;
		}
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
			
			DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
			button.URL = attachment.hyperLinkURL;
			button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
			button.GUID = attachment.hyperLinkGUID;
			
			// use normal push action for opening URL
			[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
			
			// demonstrate combination with long press
			UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
			[button addGestureRecognizer:longPress];
			
			[imageView addSubview:button];
		}
		
		return imageView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeIframe)
	{
		DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
		videoView.attachment = attachment;
		
		return videoView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeObject)
	{
		// somecolorparameter has a HTML color
		UIColor *someColor = [UIColor colorWithHTMLName:[attachment.attributes objectForKey:@"somecolorparameter"]];
		
		UIView *someView = [[UIView alloc] initWithFrame:frame];
		someView.backgroundColor = someColor;
		someView.layer.borderWidth = 1;
		someView.layer.borderColor = [UIColor blackColor].CGColor;
		
		return someView;
	}
	
	return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,10,10) cornerRadius:10];

	CGColorRef color = [textBlock.backgroundColor CGColor];
	if (color)
	{
		CGContextSetFillColorWithColor(context, color);
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextFillPath(context);
		
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextStrokePath(context);
		return NO;
	}
	
	return YES; // draw standard background
}

#pragma mark Actions

- (void)linkPushed:(DTLinkButton *)button
{
//	NSLog(@"GUID: %@",button.GUID);
//	NSLog(@"stringSelected: %@",button.GUID);
//	
	NSString *word = [_guids objectForKey:button.GUID];
	ALVocabItem *vocabItem = [_vocabulary objectForKey:word];
	ALTranslationView *translation = [[ALTranslationView alloc] initWithVocabItem:vocabItem wordFrame:button.frame];
	[self.view addSubview:translation];
	[self.view bringSubviewToFront:translation];
	// remove view before showing new one
	if (self.currentTranslationView)
		[self.currentTranslationView removeFromSuperview];
	
	self.currentTranslationView = translation;
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[[UIApplication sharedApplication] openURL:[self.lastActionLink absoluteURL]];
	}
}

- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		DTLinkButton *button = (id)[gesture view];
		button.highlighted = NO;
		self.lastActionLink = button.URL;
		
		if ([[UIApplication sharedApplication] canOpenURL:[button.URL absoluteURL]])
		{
			UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[[button.URL absoluteURL] description] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
			[action showFromRect:button.frame inView:button.superview animated:YES];
		}
	}
}

- (void)vocabButtonPressed:(UIBarButtonItem *)sender {
	if (!_vocabPopoverController) {
		ALVocabListViewController *vocabListVC = [[ALVocabListViewController alloc] initWithNibName:@"ALVocabListViewController" bundle:nil];
		vocabListVC.vocabList = self.vocabulary.allValues;
	
		UIPopoverController* aPopover = [[UIPopoverController alloc]
										 initWithContentViewController:vocabListVC];
		aPopover.delegate = self;
	
		// Store the popover in a custom property for later use.
		self.vocabPopoverController = aPopover;
	
		[self.vocabPopoverController presentPopoverFromBarButtonItem:sender
								   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[_vocabPopoverController dismissPopoverAnimated:YES];
		self.vocabPopoverController = nil;
	}
}

#pragma mark UIPopoverDelegate 

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.vocabPopoverController = nil;
}

#pragma mark DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [_textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		oneAttachment.originalSize = imageSize;
		
		if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize))
		{
			oneAttachment.displaySize = imageSize;
		}
	}
	
	// need to reset the layouter because otherwise we get the old framesetter or cached layout frames
	_textView.attributedTextContentView.layouter=nil;
	
	// here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
	[_textView.attributedTextContentView relayoutText];
}

#pragma mark Properties

- (NSMutableSet *)mediaPlayers
{
	if (!mediaPlayers)
	{
		mediaPlayers = [[NSMutableSet alloc] init];
	}
	
	return mediaPlayers;
}

@synthesize fileName = _fileName;
@synthesize lastActionLink;
@synthesize mediaPlayers;
@synthesize baseURL;


@end
