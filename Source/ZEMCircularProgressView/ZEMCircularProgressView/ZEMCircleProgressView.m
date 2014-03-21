//
//  CDWCircleProgressView.m
//  CDWCircleProgressView
//
//  Created by Cory D. Wiles on 12/23/13.
//  Copyright (c) 2013 Cory Wiles. All rights reserved.
//  Code originally inspired from https://github.com/elbryan/FFCircularProgressView
//
@import QuartzCore;

#import "ZEMCircleProgressView.h"
#import "ZEMCircleProgressViewLayer.h"

NSString * const CDWCircleProgressViewAnimatingKey = @"animating";
NSString * const CDWCircleProgressViewCompletedKey = @"complete";

static NSString * const PROGRESS_VIEW_STROKE_ANIMATION_KEY      = @"strokeAnimation";
static NSString * const PROGRESS_VIEW_STROKE_ANIMATION_KEY_PATH = @"strokeEnd";

@interface ZEMCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) SEL buttonSelector;

- (void)startTimer;
- (void)setSelectorForControl:(SEL)selector;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)updateValueFromTimer:(NSTimer *)timer;

@end

@implementation ZEMCircleProgressView

@synthesize progressTintColor = _progressTintColor;
@synthesize complete          = _complete;
@synthesize animating         = _animating;

- (void)dealloc {
  
  [self removeObserver:self forKeyPath:CDWCircleProgressViewCompletedKey context:NULL];
  [self removeObserver:self forKeyPath:CDWCircleProgressViewAnimatingKey context:NULL];
  
  [self.timer invalidate];
}

+ (Class) layerClass {
  return [ZEMCircleProgressViewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame totalUnitCount:(CGFloat)unitCount {

  self = [super initWithFrame:frame];
  
  if (self) {

    NSAssert1(unitCount > 0.0, @"The unit count must be greater than 0.0", unitCount);
    
    self.contentMode     = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor whiteColor];
    
    _buttonSelector    = @selector(startTimer);
    _complete          = NO;
    _animating         = NO;
    _totalUnitCount    = unitCount;
    _progressTintColor = [UIColor blackColor];
    _timeInterval      = 1.0f;
    
    _progressLayer = [[ZEMCircleProgressViewLayer alloc] init];
    
    _progressLayer.strokeColor = self.progressTintColor.CGColor;
    _progressLayer.frame       = self.bounds;
    
    [self.layer addSublayer:_progressLayer];
    
    [self addTarget:self
             action:_buttonSelector
   forControlEvents:UIControlEventTouchUpInside];
    
    [self updatePath];
    
    [self addObserver:self
           forKeyPath:CDWCircleProgressViewCompletedKey
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [self addObserver:self
           forKeyPath:CDWCircleProgressViewAnimatingKey
              options:NSKeyValueObservingOptionNew
              context:NULL];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame totalUnitCount:0.0];
}

- (void)drawRect:(CGRect)rect {

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(ctx);
  
  CGContextSetFillColorWithColor(ctx, self.progressTintColor.CGColor);
  CGContextSetStrokeColorWithColor(ctx, self.progressTintColor.CGColor);
  CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 1, 1));
  
  CGRect shapeRect;

  shapeRect.origin.x    = CGRectGetMidX(self.bounds) - self.bounds.size.width / 8;
  shapeRect.origin.y    = CGRectGetMidY(self.bounds) - self.bounds.size.height / 8;
  shapeRect.size.width  = self.bounds.size.width / 4;
  shapeRect.size.height = self.bounds.size.height / 4;
  
  if ([self isAnimating]) {
    
    CGContextFillRect(ctx, CGRectIntegral(shapeRect));
    CGContextRestoreGState(ctx);

  } else {

    /**
     * Must offset the "play" arrow just a bit more than the the square
     */

    shapeRect.origin.x = CGRectGetMidY(self.bounds) - self.bounds.size.height / 10;
    
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    
    [self.progressTintColor setFill];
  
    CGPoint firstPoint  = (CGPoint){(shapeRect.origin.x + shapeRect.size.width), shapeRect.origin.y + (shapeRect.size.height / 2)};
    CGPoint secondPoint = (CGPoint){shapeRect.origin.x, (shapeRect.origin.y + shapeRect.size.height)};
  
    /**
     * Top Left Point
     */

    [trianglePath moveToPoint:shapeRect.origin];

    /**
     * Middle Right Point
     */

    [trianglePath addLineToPoint:firstPoint];

    /**
     * Bottom Left Point
     */

    [trianglePath addLineToPoint:secondPoint];

    [trianglePath closePath];
    [trianglePath fill];
  }
}

#pragma mark - Public Methods

- (void)startTimer {

  [self setSelectorForControl:@selector(stop:)];
  
  /**
   * Need to reset the progress when starting the timer
   */

  self.progress = 0.f;
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                target:self
                                              selector:@selector(updateValueFromTimer:)
                                              userInfo:nil
                                               repeats:YES];

  [self willChangeValueForKey:CDWCircleProgressViewAnimatingKey];
  _animating = YES;
  [self didChangeValueForKey:CDWCircleProgressViewAnimatingKey];

  [self willChangeValueForKey:CDWCircleProgressViewCompletedKey];
  _complete = NO;
  [self didChangeValueForKey:CDWCircleProgressViewCompletedKey];

  [self setNeedsDisplay];
}

#pragma mark - Accessor Methods

- (void)setProgress:(CGFloat)progress {
  [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
  
  //NSLog(@"progress being set: %@", @(progress));
  //NSLog(@"self.totalUnitCount: %f", self.totalUnitCount);
  
  if (progress < self.totalUnitCount) {
    
    //NSLog(@"in the if");
    
    if (animated) {
      
      //NSLog(@"in the animation");
      
      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:PROGRESS_VIEW_STROKE_ANIMATION_KEY_PATH];
      
      animation.fromValue = @(self.progress / self.totalUnitCount);
      animation.toValue   = @(progress / self.totalUnitCount);

      /*
       This also worked
       
       self.progressLayer.strokeStart = 0;
       self.progressLayer.strokeEnd = progress / self.totalUnitCount;
       */
      
      animation.duration  = 1.0f;
      
      [self.progressLayer addAnimation:animation forKey:PROGRESS_VIEW_STROKE_ANIMATION_KEY];
      
    } else {
      
      //NSLog(@"in the else");
      
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      self.progressLayer.strokeEnd = progress;
      [CATransaction commit];
    }
  }
  
  _progress = progress;
}

- (UIColor *)progressTintColor {
  return self.tintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {

  self.tintColor = _progressTintColor = progressTintColor;
  
  self.progressLayer.strokeColor = progressTintColor.CGColor;

  [self setNeedsDisplay];
}

- (void)tintColorDidChange {

  [super tintColorDidChange];
  
  self.progressLayer.strokeColor = self.tintColor.CGColor;
  
  [self setNeedsDisplay];
}

- (BOOL)isComplete {
  return _complete;
}

- (BOOL)isAnimating {
  return _animating;
}

#pragma mark - Private

- (void)updatePath {

  CGPoint center     = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  CGFloat radius     = self.bounds.size.width / 2 - 2;
  CGFloat startAngle = -M_PI_2;
  CGFloat endAngle   = -M_PI_2 + 2 * M_PI;

  self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:startAngle
                                                         endAngle:endAngle
                                                        clockwise:YES].CGPath;
}

- (void)updateValueFromTimer:(NSTimer *)timer {
  
  if (self.progress >= self.totalUnitCount) {
    
    if (self.completedBlock) {
      self.completedBlock();
    }
    
    [self setSelectorForControl:@selector(startTimer)];
    
    [self willChangeValueForKey:CDWCircleProgressViewCompletedKey];
    _complete  = YES;
    [self didChangeValueForKey:CDWCircleProgressViewCompletedKey];
    
    [self willChangeValueForKey:CDWCircleProgressViewAnimatingKey];
    _animating = NO;
    [self didChangeValueForKey:CDWCircleProgressViewAnimatingKey];
    
    [self setNeedsDisplay];
    
    return;
  }
  
  CGFloat progress = self.progress < self.totalUnitCount ? (self.progress + self.timeInterval) : 0.0f;

  [self setProgress:progress animated:YES];
}

- (void)stop:(__unused id)sender {
  
  [self setSelectorForControl:@selector(startTimer)];
    
  [self willChangeValueForKey:CDWCircleProgressViewCompletedKey];
  _complete  = YES;
  [self didChangeValueForKey:CDWCircleProgressViewCompletedKey];
  
  [self willChangeValueForKey:CDWCircleProgressViewAnimatingKey];
  _animating = NO;
  [self didChangeValueForKey:CDWCircleProgressViewAnimatingKey];
  
  [self setNeedsDisplay];
  
  if (self.cancelledBlock) {
    self.cancelledBlock();
  }
}

- (void)setSelectorForControl:(SEL)selector {

  [self removeTarget:self
              action:self.buttonSelector
    forControlEvents:UIControlEventAllEvents];
  
  self.buttonSelector = selector;
  
  [self addTarget:self
           action:self.buttonSelector
 forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - KVO Method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if ([keyPath isEqual:CDWCircleProgressViewCompletedKey]) {
    
    if ([self isComplete]) {
      [self.timer invalidate];
    }
    
  } else if ([keyPath isEqual:CDWCircleProgressViewAnimatingKey]) {
  
    if ([self isAnimating]) {

      self.progressLayer.lineWidth = 3.0f;

    } else {

      self.progressLayer.lineWidth = 0.0f;
    }

  } else {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

@end
