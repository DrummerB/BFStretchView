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
	BFDebugView *_debugViewH;
	BFStretchView *_stretchViewH;
	BFDebugView *_debugViewV;
	BFStretchView *_stretchViewV;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	CGRect frame, contentFrame;
	
	frame = CGRectMake(0, 20, 320, 200);
	contentFrame = CGRectMake(0, 0, 600, 400);
	
	_stretchViewH = [[BFStretchView alloc] initWithFrame:frame];
	_stretchViewH.minimumZoomScale = 1;
	_stretchViewH.maximumZoomScale = 10;
	_stretchViewH.stretchDirection = BFStretchViewDirectionHorizontal;
	_stretchViewH.delegate = self;
	
	_debugViewH = [[BFDebugView alloc] initWithFrame:contentFrame];
	_debugViewH.alpha = 0.5;
	
	[self.view addSubview:_stretchViewH];
	[_stretchViewH addSubview:_debugViewH];
	_stretchViewH.contentSize = _debugViewH.frame.size;
	
	frame = CGRectMake(60, 250, 200, 300);
	contentFrame = CGRectMake(0, 0, 200, 1000);
	
	_stretchViewV = [[BFStretchView alloc] initWithFrame:frame];
	_stretchViewV.minimumZoomScale = 1;
	_stretchViewV.maximumZoomScale = 10;
	_stretchViewV.stretchDirection = BFStretchViewDirectionVertical;
	_stretchViewV.delegate = self;
	
	_debugViewV = [[BFDebugView alloc] initWithFrame:contentFrame];
	_debugViewV.alpha = 0.5;
	
	[self.view addSubview:_stretchViewV];
	[_stretchViewV addSubview:_debugViewV];
	_stretchViewV.contentSize = _debugViewV.frame.size;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if (scrollView == _stretchViewH) {
		return _debugViewH;
	}
	if (scrollView == _stretchViewV) {
		return _debugViewV;
	}
	return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
