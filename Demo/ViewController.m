//
//  ViewController.m
//  Demo
//
//  Created by Balázs Faludi on 17.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "ViewController.h"
#import "BFStretchView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	CGRect frame = CGRectMake(0, 20, 320, 548);
	BFStretchView *view = [[BFStretchView alloc] initWithFrame:frame];

	[self.view addSubview:view];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
