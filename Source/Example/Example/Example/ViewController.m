//
//  ViewController.m
//  Example
//
//  Created by Cory D. Wiles on 3/21/14.
//  Copyright (c) 2014 Cory Wiles. All rights reserved.
//

#import "ViewController.h"
#import "ZEMCircleProgressView.h"

@interface ViewController ()

@property (nonatomic, strong) ZEMCircleProgressView *circularProgressView;

@end

@implementation ViewController

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  CGRect progressViewFrame = (CGRect){0, 0, 100, 100};
  
  self.circularProgressView = [[ZEMCircleProgressView alloc] initWithFrame:progressViewFrame totalUnitCount:10.f];
  
  self.circularProgressView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
  
  self.circularProgressView.cancelledBlock = ^{
    NSLog(@"cancelled called");
  };
  
  self.circularProgressView.completedBlock = ^{
    NSLog(@"completed block called");
  };
  
  [self.view addSubview:self.circularProgressView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
