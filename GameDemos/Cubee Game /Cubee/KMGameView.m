//
//  KMGameView.m
//  Cubee
//
//  Created by 周祺华 on 2016/11/24.
//  Copyright © 2016年 周祺华. All rights reserved.
//

#define USE_DEBUG 0

#import "KMGameView.h"
#import "KMAnimatorManager.h"
#import "KMCubeBehavior.h"
#import "KMDropView.h"
#import "UIColor+KMColorHelper.h"


NSInteger dropsPerRow = 8;
CGSize DROP_SIZE = {50, 50};

@interface KMGameView () <UIDynamicAnimatorDelegate>
{
    KMCubeBehavior *_cubeBehavior;
    KMAnimatorManager *_animator;
    
    CGPoint _touchBeganPoint;
}
@end

@implementation KMGameView

#pragma mark - Init & Setup
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;

}

- (void)initData
{
    [self initView];
    [self initPhysicalEngine];
    [self setupBoundsAndFrame];
}

- (void)initView
{
    self.backgroundColor = [UIColor grayColor];
    
    [self addSwipeGesturer];
}

- (void)initPhysicalEngine
{
    _animator = [[KMAnimatorManager alloc] initWithReferenceView:self];
    _animator.delegate = self;
    
    _cubeBehavior = [[KMCubeBehavior alloc] init];
    [_animator addBehavior:_cubeBehavior];
}

- (void)setupBoundsAndFrame
{
    dropsPerRow = 8;
    DROP_SIZE  = CGSizeMake(self.frame.size.width/dropsPerRow, self.frame.size.width/dropsPerRow);
}

#pragma mark - Gesture
- (void)addSwipeGesturer
{
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportSwipe:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportSwipe:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:downSwipe];
}

- (void)reportSwipe:(UISwipeGestureRecognizer *)recognizer
{
    // 检测_touchBeganPoint所在的view最上层subview的class
    KMDropView *hitView = [self hitCheckWithPoint:_touchBeganPoint];
    
    // 如果返回不为nil，就说明它是KMDropView*
    if (hitView) {
        
        CGFloat x = hitView.center.x;
        CGFloat y = hitView.center.y;
        CGFloat squreWidth = DROP_SIZE.width;
        
        switch (recognizer.direction) {
            case UISwipeGestureRecognizerDirectionRight: {
                NSLog(@"right swipe detected");
                
                KMDropView *rightView = [self hitCheckWithPoint:CGPointMake(x+squreWidth, y)];
                if (rightView) {
                    
                    NSString *tmpType = hitView.type;
                    hitView.type = rightView.type;
                    rightView.type = tmpType;
                    
                    
                    CGPoint hitViewCenter = hitView.center;
                    CGPoint rightViewCenter = rightView.center;
                    UIColor *hitViewColor = hitView.insideSqureColor;
                    UIColor *rightViewColor = rightView.insideSqureColor;
                    
                    
                    
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        hitView.alpha = 0;
                        rightView.alpha = 0;
                        
                    } completion:^(BOOL finished) {
                        UIColor *tmpCoclor = hitView.insideSqureColor;
                        hitView.insideSqureColor = rightView.insideSqureColor;
                        rightView.insideSqureColor = tmpCoclor;
                        
                        hitView.alpha = 1;
                        rightView.alpha = 1;
                        
                        
                        hitView.state = KMDropViewStateNormal;
                        rightView.state = KMDropViewStateNormal;
                        
                        NSLog(@"this->right: two cubes' color did change!");
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self removeThreeSameColor];
                        });
                    }];
                }
                
                break;
            }
            case UISwipeGestureRecognizerDirectionLeft: {
                NSLog(@"left swipe detected");
                
                KMDropView *leftView = [self hitCheckWithPoint:CGPointMake(x-squreWidth, y)];
                if (leftView) {
                    
                    NSString *tmpType = hitView.type;
                    hitView.type = leftView.type;
                    leftView.type = tmpType;
                    
                    UIColor *tmpCoclor = hitView.insideSqureColor;
                    hitView.insideSqureColor = leftView.insideSqureColor;
                    leftView.insideSqureColor = tmpCoclor;
                    
                    hitView.state = KMDropViewStateNormal;
                    leftView.state = KMDropViewStateNormal;

                    NSLog(@"this->left: two cubes' color did change!");
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self removeThreeSameColor];
                    });
                }
                
                break;
            }
            case UISwipeGestureRecognizerDirectionUp: {
                NSLog(@"up swipe detected");
                
                KMDropView *upView = [self hitCheckWithPoint:CGPointMake(x, y-squreWidth)];
                if (upView) {
                    
                    NSString *tmpType = hitView.type;
                    hitView.type = upView.type;
                    upView.type = tmpType;
                    
                    UIColor *tmpCoclor = hitView.insideSqureColor;
                    hitView.insideSqureColor = upView.insideSqureColor;
                    upView.insideSqureColor = tmpCoclor;
                    
                    hitView.state = KMDropViewStateNormal;
                    upView.state = KMDropViewStateNormal;
                    
                    NSLog(@"this->up: two cubes' color did change!");
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self removeThreeSameColor];
                    });
                }
                
                break;
            }
            case UISwipeGestureRecognizerDirectionDown: {
                NSLog(@"down swipe detected");
                
                KMDropView *downView = [self hitCheckWithPoint:CGPointMake(x, y+squreWidth)];
                if (downView) {
                    
                    NSString *tmpType = hitView.type;
                    hitView.type = downView.type;
                    downView.type = tmpType;
                    
                    UIColor *tmpCoclor = hitView.insideSqureColor;
                    hitView.insideSqureColor = downView.insideSqureColor;
                    downView.insideSqureColor = tmpCoclor;
                    
                    hitView.state = KMDropViewStateNormal;
                    downView.state = KMDropViewStateNormal;
                    
                    NSLog(@"this->down: two cubes' color did change!");
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self removeThreeSameColor];
                    });
                }
                
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark -  Drop Cubes
- (void)randomlyDropCubes
{
//    NSLog(@"A new cube is dropping!");
    
    CGFloat x = arc4random()%dropsPerRow * DROP_SIZE.width;
    CGFloat y = self.bounds.origin.y;
    
    KMDropView *dropView = [[KMDropView alloc] initWithFrame:CGRectMake(x, y, DROP_SIZE.width, DROP_SIZE.width)];
    UIColor *color = [UIColor randomThreeColor];
    
    dropView.borderColor = [UIColor lightGrayColor];
    dropView.insideSqureColor = color;
    dropView.state = KMDropViewStateNormal;
    
    dropView.type = color.description;
    
    [self addSubview:dropView];
    [_cubeBehavior addItem:dropView];
}

#pragma mark - Remove Cubes
- (void)removeCompletedRows
{
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray *dropsFoundOneRow = [[NSMutableArray alloc] init];
    NSInteger dropsCountOneRow = 0;
    
    // 此处(x, y)为了能够提高判断精度，建议取点为方块中心，不要取边角，会无法检测到
    for (CGFloat y =self.bounds.size.height-DROP_SIZE.height/2; y >0; y -=DROP_SIZE.height) {
        for (CGFloat x = DROP_SIZE.width/2; x <self.bounds.size.width; x +=DROP_SIZE.width) {
            // 检测(x, y)这个点所在的view
            UIView *hitView = [self hitTest:CGPointMake(x, y) withEvent:NULL];
            
            // 如果返回的view的父视图是_gameView,就说明它是方块
            if ([[hitView superview] isEqual:self]) {
                
                [dropsFoundOneRow addObject:hitView];
                dropsCountOneRow ++;
            }
        }
        
        if (dropsCountOneRow == dropsPerRow) {
            [dropsToRemove addObjectsFromArray:dropsFoundOneRow];
        }
        
        [dropsFoundOneRow removeAllObjects];
        dropsCountOneRow = 0;
    }
    
    // 增加一些排错判断，防止无谓的消除
    if ([dropsToRemove count] == dropsPerRow) {
        [self kickAwayDrops:dropsToRemove];
    }
}

- (void)removeThreeSameColor
{
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc] init];
    
    // 此处(x, y)为了能够提高判断精度，建议取点为方块中心，不要取边角，会无法检测到
    for (CGFloat y =self.bounds.size.height-DROP_SIZE.height/2; y >0; y -=DROP_SIZE.height) {
        for (CGFloat x = DROP_SIZE.width/2; x <self.bounds.size.width; x +=DROP_SIZE.width) {
            // 检测(x, y)这个点所在的view
            KMDropView *hitView = [self hitCheckWithPoint:CGPointMake(x, y)];
            if (hitView) {
                
                NSArray *arr = [self checkCrossAt:hitView];
                if (arr) {
                    [dropsToRemove addObjectsFromArray:arr];
                }
            }
        }
    }
    
    // 增加一些排错判断，防止无谓的消除
    if ([dropsToRemove count]>=3) {
        [self kickAwayDrops:dropsToRemove];
    }
}

- (void)kickAwayDrops:(NSArray *)drops
{
    if ([self.delegate respondsToSelector:@selector(gameViewWillKickAwayCubesWithCount:)]) {
        [self.delegate gameViewWillKickAwayCubesWithCount:[drops count]];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        for (UIView *drop in drops) {
            
            //设定炸飞后终点的位置
            int x = self.bounds.size.width+DROP_SIZE.width;
            int y = - DROP_SIZE.height;
            drop.center = CGPointMake(x, y);
        }
        
    } completion:^(BOOL finished) {
        [drops makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
    
    
    for (UIView *drop in drops) {
        [_cubeBehavior removeItem:drop];
    }
    
    if ([self.delegate respondsToSelector:@selector(gameViewDidKickAwayCubesWithCount:)]) {
        [self.delegate gameViewDidKickAwayCubesWithCount:[drops count]];
    }
}

#pragma mark - Support Methods
#if USE_DEBUG
- (NSArray *)checkHorizontalAt:(UIView *)aView
{
    UIView *centerView = aView;
    UIColor *centerColor = centerView.backgroundColor;
    CGFloat x = centerView.center.x;
    CGFloat y = centerView.center.y;
    CGFloat squreWidth = DROP_SIZE.width;
    
    
    UIView *leftView = [self hitTest:CGPointMake(x-squreWidth, y) withEvent:NULL];
    if (![[leftView superview] isEqual:self]) {
        return nil;
    }
    
    UIView *rightView = [self hitTest:CGPointMake(x+squreWidth, y) withEvent:NULL];
    if (![[rightView superview] isEqual:self]) {
        return nil;
    }
    
    UIColor *leftColor = leftView.backgroundColor;
    UIColor *rightColor = rightView.backgroundColor;
    
    if ([centerColor isEqual:leftColor] && [centerColor isEqual:rightColor]) {
        NSArray *arr = [NSArray arrayWithObjects:leftView, centerView, rightView, nil];
        return arr;
    }
    
    return nil;
}

- (NSArray *)checkHorizontalVerticalAt:(UIView *)aView
{
    UIView *centerView = aView;
    
    UIColor *centerColor = centerView.backgroundColor;
    CGFloat x = centerView.center.x;
    CGFloat y = centerView.center.y;
    CGFloat squreWidth = DROP_SIZE.width;
    
    
    UIView *leftView = [self hitTest:CGPointMake(x-squreWidth, y) withEvent:NULL];
    UIView *rightView = [self hitTest:CGPointMake(x+squreWidth, y) withEvent:NULL];
    UIView *upperView = [self hitTest:CGPointMake(x, y-squreWidth) withEvent:NULL];
    UIView *lowerView = [self hitTest:CGPointMake(x, y+squreWidth) withEvent:NULL];
    
    UIColor *leftColor = leftView.backgroundColor;
    UIColor *rightColor = rightView.backgroundColor;
    UIColor *upperColor = upperView.backgroundColor;
    UIColor *lowerColor = lowerView.backgroundColor;
    
    NSMutableArray *totalArr = [NSMutableArray new];
    if ([centerColor isEqual:leftColor] && [centerColor isEqual:rightColor]) {
        NSArray *arr = [NSArray arrayWithObjects:leftView, centerView, rightView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    if ([centerColor isEqual:upperColor] && [centerColor isEqual:lowerColor]) {
        NSArray *arr = [NSArray arrayWithObjects:upperView, centerView, lowerView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    
    return totalArr;
}
#endif

- (NSArray *)checkCrossAt:(KMDropView *)centerView
{
    NSString *centerColor = centerView.type;
    CGFloat x = centerView.center.x;
    CGFloat y = centerView.center.y;
    CGFloat squreWidth = DROP_SIZE.width;
    
    
    KMDropView *leftView = [self hitCheckWithPoint:CGPointMake(x-squreWidth, y)];
    KMDropView *rightView = [self hitCheckWithPoint:CGPointMake(x+squreWidth, y)];
    KMDropView *upperView = [self hitCheckWithPoint:CGPointMake(x, y-squreWidth)];
    KMDropView *lowerView = [self hitCheckWithPoint:CGPointMake(x, y+squreWidth) ];
    
    
    KMDropView *upperLeftView = [self hitCheckWithPoint:CGPointMake(x-squreWidth, y-squreWidth)];
    KMDropView *lowerLeftView = [self hitCheckWithPoint:CGPointMake(x-squreWidth, y+squreWidth)];
    KMDropView *upperRightView = [self hitCheckWithPoint:CGPointMake(x+squreWidth, y-squreWidth)];
    KMDropView *lowerRightView = [self hitCheckWithPoint:CGPointMake(x+squreWidth, y+squreWidth)];
    
    
    NSString *leftColor = (leftView)?leftView.type : @"#$%^&*";
    NSString *rightColor = (rightView)?rightView.type : @"#$%^&*";
    NSString *upperColor = (upperView)?upperView.type : @"#$%^&*";
    NSString *lowerColor = (lowerView)?lowerView.type : @"#$%^&*";
    
    NSString *upperLeftColor = (upperLeftView)?upperLeftView.type : @"#$%^&*";
    NSString *lowerLeftColor = (lowerLeftView)?lowerLeftView.type : @"#$%^&*";
    NSString *upperRightColor = (upperRightView)?upperRightView.type : @"#$%^&*";
    NSString *lowerRightColor = (lowerRightView)?lowerRightView.type : @"#$%^&*";
    
    NSMutableArray *totalArr = [NSMutableArray new];
    if ([centerColor isEqualToString:leftColor] && [centerColor isEqualToString:rightColor]) {
        NSArray *arr = [NSArray arrayWithObjects:leftView, centerView, rightView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    if ([centerColor isEqualToString:upperColor] && [centerColor isEqualToString:lowerColor]) {
        NSArray *arr = [NSArray arrayWithObjects:upperView, centerView, lowerView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    
    if ([centerColor isEqualToString:upperLeftColor] && [centerColor isEqualToString:lowerRightColor]) {
        NSArray *arr = [NSArray arrayWithObjects:upperLeftView, centerView, lowerRightView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    if ([centerColor isEqualToString:upperRightColor] && [centerColor isEqualToString:lowerLeftColor]) {
        NSArray *arr = [NSArray arrayWithObjects:upperRightView, centerView, lowerLeftView, nil];
        [totalArr addObjectsFromArray:arr];
    }
    
    return totalArr;
}

- (KMDropView *)hitCheckWithPoint:(CGPoint)point
{
    UIView *hitView = [self hitTest:point withEvent:NULL];
//    NSLog(@"hitView class: %@", [hitView class]);

    if ([hitView isKindOfClass:[KMDropView class]]) {
        return (KMDropView *)hitView;
    }
    else {
        return nil;
    }
}

- (void)exchangeObj1:(id)obj1 withObj2:(id)obj2
{
//    id tmp = obj1;
//    obj1 = obj2;
//    obj2 = tmp;
}

#pragma mark - <UIDynamicAnimatorDelegate>
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self removeThreeSameColor];
}

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _touchBeganPoint = [touch locationInView:self];
    
    // 检测_touchBeganPoint所在的view最上层subview的class
    KMDropView *hitView = [self hitCheckWithPoint:_touchBeganPoint];
    // 如果返回不为nil，就说明它是(KMDropView *)
    if (hitView) {
        hitView.state = KMDropViewStateHighlight;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    // 检测_touchBeganPoint所在的view最上层subview的class
//    KMDropView *hitView = [self hitCheckWithPoint:_touchBeganPoint];
//    // 如果返回不为nil，就说明它是(KMDropView *)
//    if (hitView) {
//        hitView.state = KMDropViewStateNormal;
//    }
}


@end