//
//  BFStretchView2.m
//  BFStretchView
//
//  Created by Balázs Faludi on 13.06.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchView.h"

@implementation BFStretchView {
	UIView *zoomingView;
	UIView *zoomProxyView;
}

- (void)setup {
	self.delegate = self;
	zoomProxyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 0)];
//	zoomProxyView.backgroundColor = [UIColor redColor];
	zoomProxyView.hidden = YES;
	[self addSubview:zoomProxyView];
	[zoomProxyView addObserver:self forKeyPath:@"transform" options:0 context:nil];
	[zoomProxyView addObserver:self forKeyPath:@"frame" options:0 context:nil];
	self.backgroundColor = [UIColor greenColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	NSLog(@"zooming view");
	zoomingView = self.subviews[1];
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stop:) userInfo:nil repeats:NO];
	return zoomProxyView;

}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	NSLog(@"will zoom");
	
}
- (void)stop:(NSTimer*)timer {
	NSLog(@"stop");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	NSLog(@"end zoom");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	CGAffineTransform transform = CGAffineTransformMakeScale(self.zoomScale, 1);
	zoomingView.transform = transform;
	CGPoint center = zoomingView.center;
	center.x = zoomProxyView.center.x;
	center.y = self.contentOffset.y + zoomingView.bounds.size.height / 2;
	zoomingView.center = center;
//	zoomingView.frame = zoomProxyView.frame;
}

@end
