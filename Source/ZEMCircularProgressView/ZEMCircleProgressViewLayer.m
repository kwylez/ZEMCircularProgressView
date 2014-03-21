//
//  CDWCircleProgressViewLayer.m
//  CDWCircleProgressView
//
//  Created by Cory D. Wiles on 12/26/13.
//  Copyright (c) 2013 Cory Wiles. All rights reserved.
//

#import "ZEMCircleProgressViewLayer.h"

@implementation ZEMCircleProgressViewLayer

- (id)init {
  
  self = [super init];
  
  if (self) {
    
    self.strokeEnd = 0;
    self.lineWidth = 3;
    self.fillColor = nil;
  }
  
  return self;
}

@end
