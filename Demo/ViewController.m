//
//  ViewController.m
//  Demo
//
//  Created by Balázs Faludi on 17.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "ViewController.h"
#import "BFStretchView.h"
#import <BFDebugView.h>

@interface ViewController ()

@end

@implementation ViewController {
	BFDebugView *debugView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	CGRect frame = CGRectMake(0, 20, 320, 548);
	CGRect contentFrame = CGRectMake(0, 0, 600, 548);
	
	BFStretchView *stretchView = [[BFStretchView alloc] initWithFrame:frame];
//	stretchView.contentSize = CGSizeMake(320, 548);
//	stretchView.bouncesZoom = NO;
	stretchView.minimumZoomScale = 1;
	stretchView.maximumZoomScale = 10;
	stretchView.stretchDirection = BFStretchViewDirectionHorizontal;
//	stretchView.delegate = self;
	[self.view addSubview:stretchView];
	
	debugView = [[BFDebugView alloc] initWithFrame:contentFrame];
	debugView.alpha = 0.5;
	[stretchView addSubview:debugView];
	
	stretchView.contentSize = debugView.frame.size;
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//	return debugView;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
