
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "MLNavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface MLNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@end
static MLNavigationController *mlNavigationController;
@implementation UIViewController (MLNavigationControllerSupport)
- (MLNavigationController *)mlNavigationController
{
    return mlNavigationController;
}
@end
@implementation MLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.screenShotsList = [[[NSMutableArray alloc]initWithCapacity:2]autorelease];
        self.canDragBack = YES;
        mlNavigationController = self;
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }

    
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // draw a shadow for navigation view to differ the layers obviously.
    // using this way to draw shadow will lead to the low performace
    // the best alternative way is making a shadow image.
    //
    //self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    //self.view.layer.shadowOffset = CGSizeMake(5, 5);
    //self.view.layer.shadowRadius = 5;
    //self.view.layer.shadowOpacity = 1;
    self.view.superview.backgroundColor = [UIColor blackColor];
    UIImageView *shadowImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]]autorelease];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
   self.recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(paningGestureReceive:)]autorelease];
    [self.recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:self.recognizer];

}
-(void)canAddGesture:(BOOL)ifCan
{
    if (ifCan) {

    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage * temp = [self capture];
    if (temp) {
        [self.screenShotsList addObject:temp];
    }
    
    
    [super pushViewController:viewController animated:animated];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)capture//截屏
{
    UIWindow * screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(screenWindow.frame.size, NO, 0.0);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    NSLog(@"capture1...");
    return img;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    
    NSLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
//    float scale = (x/6400)+0.95;
    float scale = 1;  //改为无大小变化
    float alpha = 0.4 - (x/800);

    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
//    CGRect frame2 = lastScreenShotView.frame;
    float newx = x/2-160;
    lastScreenShotView.frame = CGRectMake(newx, lastScreenShotView.frame.origin.y, lastScreenShotView.frame.size.width, lastScreenShotView.frame.size.height);
    blackMask.alpha = alpha;
    
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (self.backgroundView) {
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        }
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            self.backgroundView.backgroundColor = [UIColor blackColor];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
      
//        if ([[self.backgroundView subviews] containsObject:lastScreenShotView])
//        {
//            [lastScreenShotView removeFromSuperview];
//        }
     
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        if (!lastScreenShot) {
            NSLog(@"nonononno");
        }
        lastScreenShotView = [[[UIImageView alloc]initWithImage:lastScreenShot]autorelease];
//        UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//        [bg setBackgroundColor:[UIColor blackColor]];
//        [lastScreenShotView addSubview:bg];
//        [bg release];
        [lastScreenShotView setBackgroundColor:[UIColor blackColor]];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
         
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}
-(void)setGestureEnableNO
{
//    for (UIPanGestureRecognizer * yyy in self.view.gestureRecognizers) {
//        //[yyy removeTarget:self action:@selector(paningGestureReceive:)];
//        [self.view removeGestureRecognizer:self.recognizer];
//    }
    [self.recognizer setEnabled:NO];
}
-(void)setGestureEnableYES
{
    [self.recognizer setEnabled:YES];
}
@end
