## ZEMCircleProgressView

Simple circle timer progress view that will animate the stroke of the view. You can manually start and stop the timer, as well as, provide a completion and cancel block.

### Inspiration

[FFCircularProgressView](https://github.com/elbryan/FFCircularProgressView)

## Install

Just add the following files to your project

* `ZEMCircleProgressView.h/m`
* `ZEMCircleProgressViewLayer.h/m`

## Usage

```ObjectiveC

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

```