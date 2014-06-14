//
//  BFStretchView.m
//  BFStretchView
//
//  Created by Balázs Faludi on 13.06.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchView.h"
#import <objc/runtime.h>

@implementation BFStretchView {
	id<UIScrollViewDelegate> _realDelegate;
	UIView *_zoomedView;
	UIView *_zoomProxyView;
	BOOL _observingProxyView;
	
	CGPoint initialContentOffset;
	BOOL pinching;
	CGSize realContentSize;
}

#pragma mark - Initialization & Destruction

- (void)setup {
	super.delegate = self;
	_observingProxyView = NO;
	pinching = NO;
	_zoomProxyView = [[UIView alloc] initWithFrame:CGRectZero];
	_zoomProxyView.hidden = YES;
	[self addSubview:_zoomProxyView];
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

#pragma mark - Delegate swapping

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    _realDelegate = delegate;
}

- (BOOL)selectorIsScrollViewDelegateMethod:(SEL)selector {
    Protocol *protocol = @protocol(UIScrollViewDelegate);
    struct objc_method_description description = protocol_getMethodDescription(protocol, selector, NO, YES);
    return (description.name != NULL);
}

- (BOOL)respondsToSelector:(SEL)selector {
    if ([self selectorIsScrollViewDelegateMethod:selector]) {
        return [_realDelegate respondsToSelector:selector] || [super respondsToSelector:selector];
    }
    return [super respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    if ([self selectorIsScrollViewDelegateMethod:selector]) {
        return _realDelegate;
    }
    return [super forwardingTargetForSelector:selector];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	static BOOL first = YES;
	if ([_realDelegate respondsToSelector:_cmd]) {
		UIView *view = [_realDelegate viewForZoomingInScrollView:scrollView];
		_zoomedView = view;
		if (_zoomedView) {
			[self stopObservingZoomProxyView];
			if (first) {
				_zoomProxyView.frame = _zoomedView.frame;
				first = NO;
			}
			[self startObservingZoomProxyView];
			return _zoomProxyView;
		}
	}
	return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[self startObservingZoomProxyView];
	initialContentOffset = self.contentOffset;
	pinching = YES;
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewWillBeginZooming:scrollView withView:view];
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	[self stopObservingZoomProxyView];
	pinching = NO;
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewDidScroll:scrollView];
	}
}

#pragma mark - Observing

- (void)startObservingZoomProxyView {
	if (_observingProxyView) return;
	[_zoomProxyView addObserver:self forKeyPath:@"transform" options:0 context:nil];
	[_zoomProxyView addObserver:self forKeyPath:@"frame" options:0 context:nil];
	_observingProxyView = YES;
}

- (void)stopObservingZoomProxyView {
	if (!_observingProxyView) return;
	[_zoomProxyView removeObserver:self forKeyPath:@"transform"];
	[_zoomProxyView removeObserver:self forKeyPath:@"frame"];
	_observingProxyView = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	
	BOOL isHorizontal = _stretchDirection == BFStretchViewDirectionHorizontal;
	BOOL isZooming = self.pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
					 self.pinchGestureRecognizer.state == UIGestureRecognizerStateChanged ||
					 self.pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
					 self.pinchGestureRecognizer.state == UIGestureRecognizerStateEnded;
	
	CGSize contentSize = realContentSize;
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGPoint origin;
	CGPoint contentOffset = self.contentOffset;
	
	if (isHorizontal) {
		contentSize.height /= self.zoomScale;
		transform = CGAffineTransformMakeScale(self.zoomScale, 1);
		origin = CGPointMake(_zoomProxyView.frame.origin.x, 0);
		if (isZooming) {
			contentOffset.y = initialContentOffset.y;
		}
	} else {
		contentSize.width /= self.zoomScale;
		transform = CGAffineTransformMakeScale(1, self.zoomScale);
		origin = CGPointMake(0, _zoomProxyView.frame.origin.y);
		if (isZooming) {
			contentOffset.x = initialContentOffset.x;
		}
	}
	
	[super setContentSize:contentSize];
	_zoomedView.transform = transform;
	_zoomedView.frame = (CGRect){origin, _zoomedView.frame.size};
	self.contentOffset = contentOffset;
	
}

- (void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	realContentSize = contentSize;
}

@end
