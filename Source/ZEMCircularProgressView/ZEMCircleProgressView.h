//
//  ZEMCircleProgressView.h
//  ZEMCircleProgressView
//
//  Created by Cory D. Wiles on 12/23/13.
//  Copyright (c) 2013 Cory Wiles. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ZEMCircleProgressViewAnimatingKey;
extern NSString * const ZEMCircleProgressViewCompletedKey;

@interface ZEMCircleProgressView : UIControl

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, assign, readonly) CGFloat totalUnitCount;
@property (nonatomic, assign, getter=isComplete, readonly) BOOL complete;
@property (nonatomic, assign, getter=isAnimating, readonly) BOOL animating;
@property (nonatomic, copy) void (^cancelledBlock)();
@property (nonatomic, copy) void (^pausedBlock)();
@property (nonatomic, copy) void (^completedBlock)();
@property (nonatomic, assign) CGFloat timeInterval;

- (instancetype)initWithFrame:(CGRect)frame totalUnitCount:(CGFloat)unitCount;

@end
