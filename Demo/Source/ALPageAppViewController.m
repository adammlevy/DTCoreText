//
//  ALPageAppViewController.m
//  DTCoreText
//
//  Created by Adam Levy on 3/29/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "ALPageAppViewController.h"
#import "DemoTextViewController.h"
#import "ALVocabItem.h"

@interface ALPageAppViewController ()

@end

@implementation ALPageAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createPageContent];
	
	// set up page contorller
	NSDictionary *options =
	[NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
								forKey: UIPageViewControllerOptionSpineLocationKey];
	
    self.pageViewController = [[UIPageViewController alloc]
						   initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
						   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
						   options: options];
	
    _pageViewController.dataSource = self;
    [[_pageViewController view] setFrame:[[self view] bounds]];
	
    DemoTextViewController *initialViewController =
	[self viewControllerAtIndex:0];
    NSArray *viewControllers =
	[NSArray arrayWithObject:initialViewController];
	
    [_pageViewController setViewControllers:viewControllers
							 direction:UIPageViewControllerNavigationDirectionForward
							  animated:NO
							completion:nil];
	
    [self addChildViewController:_pageViewController];
    [[self view] addSubview:[_pageViewController view]];
    [_pageViewController didMoveToParentViewController:self];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)createPageContent {
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Snippets" ofType:@"plist"];
	_pageContent = [[NSArray alloc] initWithContentsOfFile:plistPath];	
}

- (DemoTextViewController *)viewControllerAtIndex:(NSUInteger)index {
	// Return the data view controller for the given index.
    if (([self.pageContent count] == 0) ||
		(index >= [self.pageContent count])) {
        return nil;
    }
	
    // Create a new view controller and pass suitable data.
	NSDictionary *rowSnippet = [_pageContent objectAtIndex:index];
	
	DemoTextViewController *viewController = [[DemoTextViewController alloc] init];
	viewController.fileName = [rowSnippet objectForKey:@"File"];
	viewController.baseURL = [NSURL URLWithString:[rowSnippet  objectForKey:@"BaseURL"]];
	
	NSString *chapter;
	if (index == 0) {
		chapter = @"Chapter1";
	} else if (index == 1) {
		chapter = @"Chapter1LessonII";
	}
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:chapter ofType:@"plist"];
	NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSMutableDictionary *vocabulary = [NSMutableDictionary dictionary];
	
	[plistDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		ALVocabItem *vocabItem = [[ALVocabItem alloc] init];
		NSDictionary *word = (NSDictionary *)object;
		vocabItem.word = [word objectForKey:@"word"];
		vocabItem.translation = [word objectForKey:@"translation"];
		vocabItem.pinyin = [word objectForKey:@"pinyin"];
		[vocabulary setObject:vocabItem forKey:key];
	}];
	viewController.vocabulary = vocabulary;
	viewController.rowSnippet = rowSnippet;
	
	return viewController;
}

- (NSUInteger)indexOfViewController:(DemoTextViewController *)viewController {
	return [self.pageContent indexOfObject:viewController.rowSnippet];
	
	return 0;
}

#pragma mark - PageController Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:
(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:
						(DemoTextViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
	
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:
						(DemoTextViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
	
    index++;
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
