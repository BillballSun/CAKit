//
//  CAFluidDrawerController.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidDrawerController.h"
#import "CAFluidDrawerController+Private.h"
#import "CAVerticalScrollView.h"
#import "CAFluidDrawerPanGR.h"
#import "CAFluidDrawerDialogueView.h"
#import "CAButton.h"
#import "CAExtended.h"
#import "CARubberbandFunction.h"
#import "CAFluidAnimator.h"
#import "CAViscousDampingFunction.h"

typedef enum : NSUInteger {
    CAFluidDrawerDisplayStatusDialogue,
    CAFluidDrawerDisplayStatusScroll,
} CAFluidDrawerDisplayStatus;

@interface CAFluidDrawerController ()

#pragma mark - Outlet

@property(weak) IBOutlet NSLayoutConstraint *effectViewBottomConstraint;
@property(weak) IBOutlet NSLayoutConstraint *scrollViewFixedHeightConstraint;
@property(weak) IBOutlet NSLayoutConstraint *headerViewFixedHeightConstraint;
@property(weak) IBOutlet NSLayoutConstraint *effectViewFixedHeightConstraint;
@property(weak) IBOutlet CAFluidDrawerPanGR *panGestureRecognizer;
@property(weak) IBOutlet CAVerticalScrollView *scrollView;
@property(weak) IBOutlet UIView *headerView;
@property(weak) IBOutlet CAFluidDrawerDialogueView *dialogueView;

#pragma mark - Control Property

@property CAFluidDrawerDisplayStatus displayStatus;
@property(readonly) CGFloat maxConstraintConstant;
@property(readonly) CGFloat panGestureTorlerance;
@property(readonly) CGFloat commonVelocityMutiply;
@property(readonly) CGFloat cancelAndNotExtendToleranceVelocityMutiply;
@property(readonly) CGFloat maxVelocityAmount;
@property(readonly) CGFloat minVelocityAmount;
@property(readonly) CGFloat energyRemainingPercentageToComplete;
@property(readonly) CGFloat preferredScrollViewDisplayHeight;
@property(readonly) CGFloat scrollViewFixedHeightConstantJustFillView;
@property CAFluidAnimator *animator;
@property(getter=isTowardsOtherStatus) BOOL towardsOtherStatus;
@property CGFloat currentSpeed;
@property CADisplayLink *displayLink;
@property CGFloat fromConstantValue;
@property BOOL extendScrollViewFlag;
@end

@implementation CAFluidDrawerController

#pragma mark - Dragging Control

- (CGFloat)energyRemainingPercentageToComplete { return 0.0003; }

- (CGFloat)preferredScrollViewDisplayHeight { CGSize size = UIScreen.mainScreen.bounds.size; return MAX(size.width, size.height) * 0.7; }

- (CGFloat)panGestureTorlerance { return 0.1; }

- (CGFloat)commonVelocityMutiply { return 1.0; }

- (CGFloat)cancelAndNotExtendToleranceVelocityMutiply { return 0.5; }

- (CGFloat)maxVelocityAmount { return 1200.0; }

- (CGFloat)minVelocityAmount { return 900.0; }

- (CGFloat)maxConstraintConstant
{
    /* if changed updated Contraints */
    return [self maxConstraintConstantForViewSize:self.view.size];
}

- (CGFloat)maxConstraintConstantForViewSize:(CGSize)size
{
    CGFloat possibleHeight = size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - self.headerViewFixedHeightConstraint.constant - self.effectViewFixedHeightConstraint.constant;
    if(possibleHeight <= self.preferredScrollViewDisplayHeight)
        return possibleHeight;
    else
        return self.preferredScrollViewDisplayHeight;
}

- (void)setMaxConstraintConstantChanged
{
    switch (self.displayStatus) {
        case CAFluidDrawerDisplayStatusDialogue:
            self.effectViewBottomConstraint.constant = 0;
            break;
        case CAFluidDrawerDisplayStatusScroll:
            self.effectViewBottomConstraint.constant = - self.maxConstraintConstant;
            break;
    }
}

#pragma mark - Dragging Essential

- (CAViscousDampingFunction *)createDampingFunction
{
    const CGFloat mass = 1;
    const CGFloat spring = 200;
    const CGFloat coefficient = sqrt(4 * mass * spring);
    return [[CAViscousDampingFunction alloc] initWithMass:mass spring:spring coefficient:coefficient];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    if(gestureRecognizer == self.panGestureRecognizer)
    {
        UIView *target = [self.view hitTest:[touch locationInView:self.view] withEvent:nil];
        if([target isDescendantOfView:self.scrollView])
            return NO;
    }
    return YES;
}

- (IBAction)userDidPan:(UIPanGestureRecognizer *)panGR
{
    CGFloat yTranslation = [panGR translationInView:self.view].y;
    CGFloat maxConstraintConstant = self.maxConstraintConstant;
    if(panGR.state == UIGestureRecognizerStateBegan || panGR.state == UIGestureRecognizerStateChanged)
    {
        if(panGR.state == UIGestureRecognizerStateBegan)
            self.view.userInteractionEnabled = NO;
        switch (self.displayStatus) {
            case CAFluidDrawerDisplayStatusDialogue:
                if(yTranslation < - maxConstraintConstant)
                {
                    self.effectViewBottomConstraint.constant = - ([CARubberbandFunction positionOffsetForTouchOffset:- yTranslation - maxConstraintConstant] + maxConstraintConstant);
                    self.scrollViewFixedHeightConstraint.constant = self.scrollViewFixedHeightConstantJustFillView;
                    self.extendScrollViewFlag = YES;
                }
                else
                {
                    if(self.extendScrollViewFlag)
                    {
                        [self updateScrollContraints];
                        self.extendScrollViewFlag = NO;
                    }
                    if(yTranslation == 0)
                        self.effectViewBottomConstraint.constant = 0;
                    else if(yTranslation > 0)
                        self.effectViewBottomConstraint.constant = [CARubberbandFunction positionOffsetForTouchOffset:yTranslation];
                    else
                        self.effectViewBottomConstraint.constant = yTranslation;
                }
                break;
            case CAFluidDrawerDisplayStatusScroll:
                if(yTranslation < 0)
                {
                    self.effectViewBottomConstraint.constant = - (maxConstraintConstant + [CARubberbandFunction positionOffsetForTouchOffset:-yTranslation]);
                    self.scrollViewFixedHeightConstraint.constant = self.scrollViewFixedHeightConstantJustFillView;
                    self.extendScrollViewFlag = YES;
                }
                else
                {
                    if(self.extendScrollViewFlag)
                    {
                        [self updateScrollContraints];
                        self.extendScrollViewFlag = NO;
                    }
                    if(yTranslation == 0)
                        self.effectViewBottomConstraint.constant = - maxConstraintConstant;
                        else if(yTranslation <= maxConstraintConstant)
                            self.effectViewBottomConstraint.constant = - (maxConstraintConstant - yTranslation);
                        else
                            self.effectViewBottomConstraint.constant = [CARubberbandFunction positionOffsetForTouchOffset:(yTranslation - maxConstraintConstant)];
                }
                break;
        }
        [self.view setNeedsLayout];
    }
    else if(panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat torlerance = self.panGestureTorlerance;
        CGFloat yVelocity = [panGR velocityInView:self.view].y * self.commonVelocityMutiply;
        if(fabs(yVelocity) > self.maxVelocityAmount)
            yVelocity = copysign(self.maxVelocityAmount, yVelocity);
        else if(fabs(yVelocity) < self.minVelocityAmount)
            yVelocity = copysign(self.minVelocityAmount, yVelocity);
        
        switch (self.displayStatus) {
            case CAFluidDrawerDisplayStatusDialogue:
                if(yTranslation < - maxConstraintConstant * torlerance && yVelocity < 0)
                    self.towardsOtherStatus = YES;
                else
                    self.towardsOtherStatus = NO;
                
                break;
            case CAFluidDrawerDisplayStatusScroll:
                if(yTranslation > maxConstraintConstant * torlerance && yVelocity > 0)
                    self.towardsOtherStatus = YES;
                else
                    self.towardsOtherStatus = NO;
                break;
        }
        self.currentSpeed = yVelocity;
        
        BOOL extendTorlerance;
        if(self.displayStatus == CAFluidDrawerDisplayStatusDialogue)
            extendTorlerance = yTranslation < - maxConstraintConstant * torlerance;
        else
            extendTorlerance = yTranslation > maxConstraintConstant * torlerance;
        
        if(!self.towardsOtherStatus && !extendTorlerance) self.currentSpeed *= self.cancelAndNotExtendToleranceVelocityMutiply;
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
        self.fromConstantValue = self.effectViewBottomConstraint.constant;
        [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkCallBack:(CADisplayLink *)displayLink
{
    CGFloat period = displayLink.duration;
    CGFloat currentSpeedAmount = fabs(self.currentSpeed);
    CGFloat maxConstraintConstant = self.maxConstraintConstant;
    CGFloat energyRemainingPercentageToComplete = self.energyRemainingPercentageToComplete;
    CGFloat initalConstant = self.effectViewBottomConstraint.constant;
    BOOL needsCompleteAction = NO;
    switch (self.displayStatus) {
        case CAFluidDrawerDisplayStatusDialogue:
            if(self.towardsOtherStatus)
            {
                if(initalConstant <= - maxConstraintConstant)
                    needsCompleteAction = YES;
                else
                {
                    if(self.extendScrollViewFlag)
                    {
                        [self updateScrollContraints];
                        self.extendScrollViewFlag = NO;
                    }
                    if(initalConstant - period * currentSpeedAmount <= - maxConstraintConstant)
                    {
                        self.effectViewBottomConstraint.constant = - maxConstraintConstant;
                        needsCompleteAction = YES;
                    }
                    else
                        self.effectViewBottomConstraint.constant -= period * currentSpeedAmount;
                }
                if(needsCompleteAction)
                {
                    [self.displayLink invalidate];
                    CAViscousDampingFunction *function = [self createDampingFunction];
                    function.initialDistance = - (maxConstraintConstant + self.effectViewBottomConstraint.constant);
                    function.initialVelocity = self.fromConstantValue <= - maxConstraintConstant ? 0 : currentSpeedAmount;
                    
                    if(function.initialDistance == 0 && function.initialVelocity == 0)
                    {
                        self.displayStatus = CAFluidDrawerDisplayStatusScroll;
                        self.view.userInteractionEnabled = YES;
                    }
                    else
                    {
                        self.animator = [[CAFluidAnimator alloc] initWithDampingFunction:function];
                        self.animator.energyRemainingPercentageToComplete = energyRemainingPercentageToComplete;
                        [self.animator beginAnimationWithBlock:^(CAFluidAnimator *animator){
                            if(animator.status == CAFluidAnimatorStatusInProcess)
                            {
                                self.effectViewBottomConstraint.constant = - (animator.currentDistance + maxConstraintConstant);
                                if(self.effectViewBottomConstraint.constant < - maxConstraintConstant)
                                {
                                    self.scrollViewFixedHeightConstraint.constant = self.scrollViewFixedHeightConstantJustFillView;
                                    self.extendScrollViewFlag = YES;
                                }
                            }
                            else if(animator.status == CAFluidAnimatorStatusComplete || animator.status == CAFluidAnimatorStatusCancelled)
                            {
                                if(self.extendScrollViewFlag)
                                {
                                    [self updateScrollContraints];
                                    self.extendScrollViewFlag = NO;
                                }
                                self.effectViewBottomConstraint.constant = - maxConstraintConstant;
                                self.displayStatus = CAFluidDrawerDisplayStatusScroll;
                                self.view.userInteractionEnabled = YES;
                            }
                            [self.view setNeedsLayout];
                        }];
                    }
                }
            }
            else
            {
                if(initalConstant >= 0 || self.currentSpeed <= 0)
                    needsCompleteAction = YES;
                else
                {
                    if(initalConstant + period * currentSpeedAmount >= 0)
                    {
                        self.effectViewBottomConstraint.constant = 0;
                        needsCompleteAction = YES;
                    }
                    else
                        self.effectViewBottomConstraint.constant += period * currentSpeedAmount;
                }
                if(needsCompleteAction)
                {
                    [self.displayLink invalidate];
                    CAViscousDampingFunction *function = [self createDampingFunction];
                    function.initialDistance = - self.effectViewBottomConstraint.constant;
                    function.initialVelocity = (self.fromConstantValue >= 0 || self.currentSpeed) <= 0 ? 0 : - currentSpeedAmount;
                    if(function.initialDistance == 0 && function.initialVelocity == 0)
                        self.view.userInteractionEnabled = YES;
                    else
                    {
                        self.animator = [[CAFluidAnimator alloc] initWithDampingFunction:function];
                        self.animator.energyRemainingPercentageToComplete = energyRemainingPercentageToComplete;
                        [self.animator beginAnimationWithBlock:^(CAFluidAnimator *animator){
                            if(animator.status == CAFluidAnimatorStatusInProcess)
                                self.effectViewBottomConstraint.constant = - animator.currentDistance;
                            else if(animator.status == CAFluidAnimatorStatusComplete || animator.status == CAFluidAnimatorStatusCancelled)
                            {
                                if(self.extendScrollViewFlag)
                                {
                                    [self updateScrollContraints];
                                    self.extendScrollViewFlag = NO;
                                }
                                self.effectViewBottomConstraint.constant = 0;
                                self.view.userInteractionEnabled = YES;
                            }
                            [self.view setNeedsLayout];
                        }];
                    }
                }
            }
            break;
        case CAFluidDrawerDisplayStatusScroll:
            if(self.towardsOtherStatus)
            {
                if(initalConstant >= 0)
                    needsCompleteAction = YES;
                else if(initalConstant < 0)
                {
                    if(self.extendScrollViewFlag)
                    {
                        [self updateScrollContraints];
                        self.extendScrollViewFlag = NO;
                    }
                    if(initalConstant + period * currentSpeedAmount >= 0)
                    {
                        self.effectViewBottomConstraint.constant = 0;
                        needsCompleteAction = YES;
                    }
                    else
                        self.effectViewBottomConstraint.constant += period * currentSpeedAmount;
                }
                if(needsCompleteAction)
                {
                    [self.displayLink invalidate];
                    CAViscousDampingFunction *function = [self createDampingFunction];
                    function.initialDistance = - self.effectViewBottomConstraint.constant;
                    function.initialVelocity = self.fromConstantValue >= 0 ? 0 : - currentSpeedAmount;
                    if(function.initialDistance == 0 && function.initialVelocity == 0)
                    {
                        self.displayStatus = CAFluidDrawerDisplayStatusDialogue;
                        self.view.userInteractionEnabled = YES;
                    }
                    else
                    {
                        self.animator = [[CAFluidAnimator alloc] initWithDampingFunction:function];
                        self.animator.energyRemainingPercentageToComplete = energyRemainingPercentageToComplete;
                        [self.animator beginAnimationWithBlock:^(CAFluidAnimator *animator){
                            if(animator.status == CAFluidAnimatorStatusInProcess)
                                self.effectViewBottomConstraint.constant = - animator.currentDistance;
                            else if(animator.status == CAFluidAnimatorStatusComplete || animator.status == CAFluidAnimatorStatusCancelled)
                            {
                                if(self.extendScrollViewFlag)
                                {
                                    [self updateScrollContraints];
                                    self.extendScrollViewFlag = NO;
                                }
                                self.effectViewBottomConstraint.constant = 0;
                                self.displayStatus = CAFluidDrawerDisplayStatusDialogue;
                                self.view.userInteractionEnabled = YES;
                            }
                            [self.view setNeedsLayout];
                        }];
                    }
                }
            }
            else
            {
                if(initalConstant <= - maxConstraintConstant || self.currentSpeed >= 0)
                    needsCompleteAction = YES;
                else
                {
                    if(self.extendScrollViewFlag)
                    {
                        [self updateScrollContraints];
                        self.extendScrollViewFlag = NO;
                    }
                    if(initalConstant - period * currentSpeedAmount <= - maxConstraintConstant)
                    {
                        self.effectViewBottomConstraint.constant = - maxConstraintConstant;
                        needsCompleteAction = YES;
                    }
                    else
                        self.effectViewBottomConstraint.constant -= period * currentSpeedAmount;
                }
                if(needsCompleteAction)
                {
                    [self.displayLink invalidate];
                    CAViscousDampingFunction *function = [self createDampingFunction];
                    function.initialDistance = - (maxConstraintConstant + self.effectViewBottomConstraint.constant);
                    function.initialVelocity = (self.fromConstantValue <= - maxConstraintConstant || self.currentSpeed >= 0) ? 0 : currentSpeedAmount;
                    if(function.initialDistance == 0 && function.initialVelocity == 0)
                        self.view.userInteractionEnabled = YES;
                    else
                    {
                        self.animator = [[CAFluidAnimator alloc] initWithDampingFunction:function];
                        self.animator.energyRemainingPercentageToComplete = energyRemainingPercentageToComplete;
                        [self.animator beginAnimationWithBlock:^(CAFluidAnimator *animator){
                            if(animator.status == CAFluidAnimatorStatusInProcess)
                            {
                                self.effectViewBottomConstraint.constant = - (maxConstraintConstant + animator.currentDistance);
                                if(self.effectViewBottomConstraint.constant < - maxConstraintConstant)
                                {
                                    self.scrollViewFixedHeightConstraint.constant = self.scrollViewFixedHeightConstantJustFillView;
                                    self.extendScrollViewFlag = YES;
                                }
                            }
                            else if(animator.status == CAFluidAnimatorStatusComplete || animator.status == CAFluidAnimatorStatusCancelled)
                            {
                                if(self.extendScrollViewFlag)
                                {
                                    [self updateScrollContraints];
                                    self.extendScrollViewFlag = NO;
                                }
                                self.effectViewBottomConstraint.constant = - maxConstraintConstant;
                                self.view.userInteractionEnabled = YES;
                            }
                            [self.view setNeedsLayout];
                        }];
                    }
                }
            }
            break;
    }
    [self.view setNeedsLayout];
}

#pragma mark - Loading Interface

- (void)loadView
{
    [[NSBundle mainBundle] loadNibNamed:@"CAFluidDrawerController" owner:self options:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* dialogue View */
    CAButton *phone = [[CAButton alloc] initWithNormalView:[[UIImage imageNamed:@"phone"] displayInView] highlightedView:[[UIImage imageNamed:@"phone_selected"] displayInView]];
    [phone addTarget:self action:@selector(phoneAction) forControlEvents:UIControlEventTouchUpInside];
    CAButton *QQ = [[CAButton alloc] initWithNormalView:[[UIImage imageNamed:@"QQ"] displayInView] highlightedView:[[UIImage imageNamed:@"QQ_selected"] displayInView]];
    [QQ addTarget:self action:@selector(QQAction) forControlEvents:UIControlEventTouchUpInside];
    CAButton *wechat = [[CAButton alloc] initWithNormalView:[[UIImage imageNamed:@"wechat"] displayInView] highlightedView:[[UIImage imageNamed:@"wechat_selected"] displayInView]];
    [wechat addTarget:self action:@selector(wechatAction) forControlEvents:UIControlEventTouchUpInside];
    CAButton *talk = [[CAButton alloc] initWithNormalView:[[UIImage imageNamed:@"talk"] displayInView] highlightedView:[[UIImage imageNamed:@"talk_selected"] displayInView]];
    [talk addTarget:self action:@selector(talkAction) forControlEvents:UIControlEventTouchUpInside];
    [self.dialogueView addContents:@[phone, QQ, wechat, talk]];
    self.dialogueView.alpha = 0.7;
    
    /* headerView */
    UIImage *headerImage = [[UIImage imageNamed:@"header"] resizableImageWithCapInsets:UIEdgeInsetsMake(16.0 / 3, 16.0 / 3, 0, 16.0 / 3)];
    UIImage *headMidImage = [[UIImage imageNamed:@"header_mid"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0 / 3, 4.0 / 3, 4.0 / 3, 4.0 / 3)];
    UIImageView *headerImageView = [headerImage displayInView];
    UIImageView *headerMidImageView = [headMidImage displayInView];

    headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    headerMidImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:headerImageView];
    [self.headerView addSubview:headerMidImageView];
    
    [headerImageView constraintEqualToView:self.headerView];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:headerMidImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:headerMidImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *fixedWidth = [NSLayoutConstraint constraintWithItem:headerMidImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0 constant:35];
    NSLayoutConstraint *fixedHight = [NSLayoutConstraint constraintWithItem:headerMidImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0 constant:5];
    
    [NSLayoutConstraint activateConstraints:@[centerX, centerY, fixedWidth, fixedHight]];
    
    self.headerView.autoresizesSubviews = YES;
    [self.headerView setNeedsLayout];
    
    /* status */
    self.displayStatus = CAFluidDrawerDisplayStatusDialogue;
    
    /* self configuration */
    self.view.multipleTouchEnabled = NO;
    self.view.autoresizesSubviews = YES;
    
    /* geture recognizer */
    
    /* scroll view */
    [self updateScrollContraints];
    self.scrollView.internalSpaceBetweenContents = 20.0;
    self.scrollView.needSpaceAtTop = YES;
    self.extendScrollViewFlag = NO;
    
    /* customization */
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIView *firstView = [[UIImage imageNamed:@"HuaQ"] displayInView];
    
    firstView.height = self.view.width * firstView.height / firstView.width;
    
    UIView *secondView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    secondView.frame = CGRectMake(0, 0, 10, 900);
    firstView.layer.cornerRadius = 30;
    secondView.layer.cornerRadius = 30;
    firstView.clipsToBounds = YES;
    secondView.clipsToBounds = YES;
    
    [self.scrollView addContent:firstView];
    [self.scrollView addContent:secondView];
    
}

#pragma mark - ScrollView

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self setMaxConstraintConstantChanged];
    [self updateScrollContraints];
}

- (void)updateScrollContraints
{
    self.scrollViewFixedHeightConstraint.constant = self.view.safeAreaInsets.bottom + self.maxConstraintConstant;
}

- (CGFloat)scrollViewFixedHeightConstantJustFillView
{
    return self.scrollViewFixedHeightConstraint.constant = self.view.safeAreaInsets.bottom - self.effectViewBottomConstraint.constant;
}

#pragma mark - Trigger Dialogue Action

- (void)phoneAction
{
    NSLog(@"present Phone");
}

- (void)QQAction
{
    NSLog(@"present QQ");
}

- (void)wechatAction
{
    NSLog(@"present wechat");
}

- (void)talkAction
{
    NSLog(@"present talk");
}

#pragma mark - Orientation Support

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    switch (self.displayStatus)
    {
        case CAFluidDrawerDisplayStatusDialogue:
            self.effectViewBottomConstraint.constant = 0;
            break;
        case CAFluidDrawerDisplayStatusScroll:
            self.effectViewBottomConstraint.constant = - [self maxConstraintConstantForViewSize:size];
            break;
    }
}

#pragma mark - Global Action

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{ return UIInterfaceOrientationMaskAll; }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
