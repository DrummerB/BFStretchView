//
//  BFStretchView.h
//  BFStretchView
//
//  Created by Balázs Faludi on 13.06.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFStretchViewDirection) {
	BFStretchViewDirectionHorizontal,
	BFStretchViewDirectionVertical,
};

@interface BFStretchView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic) BFStretchViewDirection stretchDirection;

@end
