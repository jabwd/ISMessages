//
//  ISMessages.m
//  ISMessages
//
//  Created by Ilya Inyushin on 08.09.16.
//  Copyright © 2016 Ilya Inyushin. All rights reserved.
//

#import "ISMessages.h"

static CGFloat const kDefaultCardViewHeight = 51.f;
static CGFloat const kDefaulInset = 8.f;

@interface ISMessages ()

// Content
@property (nonatomic, copy) NSString* titleString;
@property (nonatomic, copy) NSString* messageString;
@property (strong, nonatomic) UIImage* iconImage;

// Interaction

@property (assign, nonatomic) BOOL hideOnSwipe;
@property (assign, nonatomic) BOOL hideOnTap;

// Position

@property (assign, nonatomic) ISAlertPosition alertPosition;
@property (assign, nonatomic) ISAlertType usedType;

// Duration

@property (assign, nonatomic) NSTimeInterval duration;

// Sizes

@property (assign, nonatomic) CGFloat messageLabelHeight;
@property (assign, nonatomic) CGFloat titleLabelHeight;
@property (assign, nonatomic) CGFloat alertViewHeight;
@property (assign, nonatomic) CGSize iconImageSize;

// callback

@property handler handler;

@end

@implementation ISMessages

static NSMutableArray* currentAlertArray = nil;

+ (instancetype)showCardAlertWithTitle:(NSString *)title
                               message:(NSString *)message
                             iconImage:(UIImage *)iconImage
                              duration:(NSTimeInterval)duration
                           hideOnSwipe:(BOOL)hideOnSwipe
                             hideOnTap:(BOOL)hideOnTap
                             alertType:(ISAlertType)type
                         alertPosition:(ISAlertPosition)position {
    
    ISMessages* alert = [[ISMessages alloc] initCardAlertWithTitle:title
                                                           message:message
                                                         iconImage:iconImage
                                                          duration:duration
                                                       hideOnSwipe:hideOnSwipe
                                                         hideOnTap:hideOnTap
                                                         alertType:type
                                                     alertPosition:position];
    [alert show:nil];
    return alert;
    
}

+ (instancetype)cardAlertWithTitle:(NSString*)title
                           message:(NSString*)message
                         iconImage:(UIImage*)iconImage
                          duration:(NSTimeInterval)duration
                       hideOnSwipe:(BOOL)hideOnSwipe
                         hideOnTap:(BOOL)hideOnTap
                         alertType:(ISAlertType)type
                     alertPosition:(ISAlertPosition)position{
    
    ISMessages* alert = [[ISMessages alloc] initCardAlertWithTitle:title
                                                           message:message
                                                         iconImage:iconImage
                                                          duration:duration
                                                       hideOnSwipe:hideOnSwipe
                                                         hideOnTap:hideOnTap
                                                         alertType:type
                                                     alertPosition:position];
    return alert;
    
}

- (instancetype)initCardAlertWithTitle:(NSString*)title
                               message:(NSString*)message
                             iconImage:(UIImage*)iconImage
                              duration:(NSTimeInterval)duration
                           hideOnSwipe:(BOOL)hideOnSwipe
                             hideOnTap:(BOOL)hideOnTap
                             alertType:(ISAlertType)type
                         alertPosition:(ISAlertPosition)position{
    
    self = [super init];
    
    if (self) {
        
        if (!currentAlertArray) {
            currentAlertArray = [NSMutableArray new];
        }
        
        self.titleString = title;
        self.messageString = message;
        self.duration = duration;
        self.hideOnTap = hideOnTap;
        self.hideOnSwipe = hideOnSwipe;
        self.iconImageSize = CGSizeMake(35.f, 35.f);
        [self configureViewForAlertType:type iconImage:iconImage];
        self.alertPosition = position;
       
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageLabelHeight = ceilf([self preferredHeightForMessageString:_messageString]);
    self.titleLabelHeight = ceilf([self preferredHeightForTitleString:_titleString]);
    self.alertViewHeight = kDefaulInset + _titleLabelHeight + 3.f + _messageLabelHeight + 8.f;
    
    
    if (_alertViewHeight < kDefaultCardViewHeight) {
        self.alertViewHeight = kDefaultCardViewHeight;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat alertYPosition = screenHeight - (_alertViewHeight + screenHeight);
    
    if (_alertPosition == ISAlertPositionBottom) {
        alertYPosition = screenHeight + _alertViewHeight;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), _alertViewHeight);
    
    self.view.alpha = 0.7f;
    self.view.layer.cornerRadius = 5.f;
    self.view.layer.masksToBounds = YES;
    [self constructAlertCardView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self hide:@(YES)];
}

- (void)constructAlertCardView {
    
    UIView* alertView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    alertView.backgroundColor = _alertViewBackgroundColor;
    [self.view addSubview:alertView];
	
    UIImageView* iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(kDefaulInset, (_alertViewHeight - _iconImageSize.height) / 2.f, _iconImageSize.width, _iconImageSize.height)];
    iconImage.contentMode = UIViewContentModeScaleAspectFit;
    iconImage.image = _iconImage;
	if( _usedType == ISAlertTypeMessageBlack || _usedType == ISAlertTypeMessageWhite ) {
		iconImage.clipsToBounds = true;
		iconImage.layer.cornerRadius = ceilf(iconImage.bounds.size.width/2);
	}
    [alertView addSubview:iconImage];
    
    UILabel* titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake((kDefaulInset*2.f) + _iconImageSize.width, kDefaulInset, self.view.frame.size.width - ((kDefaulInset*3.f) + _iconImageSize.width), _titleLabelHeight);
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = _titleLabelTextColor;
    titleLabel.font = _titleLabelFont;
    titleLabel.text = _titleString;
    [alertView addSubview:titleLabel];
    
    UILabel* messageLabel = [UILabel new];
    messageLabel.frame = CGRectMake((kDefaulInset*2.f) + _iconImageSize.width, kDefaulInset + _titleLabelHeight + 3.f, self.view.frame.size.width - ((kDefaulInset*3.f) + _iconImageSize.width), _messageLabelHeight);
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = _messageLabelTextColor;
    messageLabel.font = _messageLabelFont;
    messageLabel.text = _messageString;
    [alertView addSubview:messageLabel];
    
    if (_hideOnSwipe) {
        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
        [alertView addGestureRecognizer:swipeGesture];
    }
    
    if (_hideOnTap) {
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureActionWithHandler)];
        [alertView addGestureRecognizer:tapGesture];
    }
    
}

- (void)show:(handler)handler {
    
    if (handler) {
        _handler = handler;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureActionWithHandler)];
        [self.view addGestureRecognizer:tapGesture];
    }
    
    [self performSelectorOnMainThread:@selector(showInMain) withObject:nil waitUntilDone:NO];
}

- (void)showInMain {
        
    if ([currentAlertArray count] != 0) {
        [self performSelectorOnMainThread:@selector(hide:) withObject:@(YES) waitUntilDone:YES];
    }
    
    @synchronized (currentAlertArray) {
        
        [([UIApplication sharedApplication].delegate).window addSubview:self.view];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat alertYPosition = [[UIApplication sharedApplication] statusBarFrame].size.height == 20.f ? [[UIApplication sharedApplication] statusBarFrame].size.height : [[UIApplication sharedApplication] statusBarFrame].size.height + 5.f;
        
        if (_alertPosition == ISAlertPositionBottom) {
            alertYPosition = screenHeight - _alertViewHeight - 10.f;
        }
        
        [UIView animateWithDuration:0.5f
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
							 self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), self->_alertViewHeight);
                             self.view.alpha = 1.f;
                         } completion:^(BOOL finished) {
							 self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), self->_alertViewHeight);
                             self.view.alpha = 1.f;
                         }];
        
        [currentAlertArray addObject:self];
        
        if (_duration > 0.5f) {
            [self performSelector:@selector(hide:) withObject:@(NO) afterDelay:_duration];
        }
    }
    
}

- (void)hide:(NSNumber*)force {
    if (force.boolValue == YES) {
        [self forceHideInMain];
    } else {
        [self hideInMain];
    }
}

- (void)gestureAction {
    [self hide:@(NO)];
}

- (void)gestureActionWithHandler {
    if (_handler) {
        _handler();
    }
    [self hide:@(NO)];
}

#pragma mark - Private Methods

- (void)hideInMain {
    
    if ([currentAlertArray containsObject:self]) {
        @synchronized (currentAlertArray) {
            
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
            [currentAlertArray removeObject:self];
            
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat alertYPosition = -_alertViewHeight;
            
            if (_alertPosition == ISAlertPositionBottom) {
                alertYPosition = screenHeight;
            }
            
            [UIView animateWithDuration:0.3f animations:^{
                self.view.alpha = 0.7;
                self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) {
                self.view.alpha = 0.7;
                self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, self.view.frame.size.width, self.view.frame.size.height);
                [self.view removeFromSuperview];
            }];
            
        }
    }
    
}

- (void)forceHideInMain {
    
    if (currentAlertArray && [currentAlertArray count] > 0) {
        @synchronized (currentAlertArray) {
            
            ISMessages* activeAlert = currentAlertArray[0];
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:activeAlert];
            [currentAlertArray removeObject:activeAlert];
            
            [UIView animateWithDuration:0.1f
                             animations:^{
                                 activeAlert.view.alpha = 0.f;
                             } completion:^(BOOL finished) {
                                 [activeAlert.view removeFromSuperview];
                             }];
            
        }
    }
    
}

+ (void)hideAlertAnimated:(BOOL)animated {
    
    if (currentAlertArray && [currentAlertArray count] != 0) {
        ISMessages* alert = currentAlertArray[0];
        [alert hide:[NSNumber numberWithBool:!animated]];
    }

}

- (CGFloat)preferredHeightForMessageString:(NSString*)message {
    
    if (!message || message.length == 0) {
        return ceilf(0.f);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat messageHeight = [message boundingRectWithSize:CGSizeMake(screenWidth - 40.f - _iconImageSize.height, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                            NSFontAttributeName : _messageLabelFont}
                                                  context:nil].size.height;
    
    return ceilf(messageHeight);
    
}

- (CGFloat)preferredHeightForTitleString:(NSString*)title {
    
    if (!title || title.length == 0) {
        return ceilf(0.f);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat titleHeight = [title boundingRectWithSize:CGSizeMake(screenWidth - 40.f - _iconImageSize.height, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                            NSFontAttributeName : _titleLabelFont}
                                                  context:nil].size.height;
    
    return ceilf(titleHeight);
    
}

- (UIImage*)imageNamed:(NSString*)name {
    NSBundle * pbundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleURL = [pbundle pathForResource:@"ISMessages" ofType:@"bundle"];
    NSBundle *imagesBundle = [NSBundle bundleWithPath:bundleURL];
    UIImage * image = [UIImage imageNamed:name inBundle:imagesBundle compatibleWithTraitCollection:nil];
    return image;
}

- (void)configureViewForAlertType:(ISAlertType)alertType iconImage:(UIImage*)iconImage {
	_usedType = alertType;
    self.titleLabelTextColor = [UIColor whiteColor];
    self.messageLabelTextColor = [UIColor whiteColor];
    self.titleLabelFont = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    self.messageLabelFont = [UIFont systemFontOfSize:15.f];
    
    self.iconImage = iconImage;
    
    switch (alertType) {
        case ISAlertTypeSuccess: {
            //self.alertViewBackgroundColor = [UIColor colorWithRed:31.f/255.f green:177.f/255.f blue:138.f/255.f alpha:1.f];
			self.alertViewBackgroundColor = [UIColor colorWithRed:100.f/255.f green:200.f/255.f blue:220.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [self imageNamed:@"isSuccessIcon"];
            }
            break;
        }
        case ISAlertTypeError: {
            self.alertViewBackgroundColor = [UIColor colorWithRed:205.f/255.f green:1.5f/255.f blue:1.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [self imageNamed:@"isErrorIcon"];
            }
            break;
        }
        case ISAlertTypeWarning: {
            self.alertViewBackgroundColor = [UIColor colorWithRed:255.f/255.f green:134.f/255.f blue:0.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [self imageNamed:@"isWarningIcon"];
            }
            break;
        }
        case ISAlertTypeInfo: {
            self.alertViewBackgroundColor = [UIColor colorWithRed:75.f/255.f green:107.f/255.f blue:122.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [self imageNamed:@"isInfoIcon"];
            }
            break;
        }
        case ISAlertTypeCustom: {
            self.alertViewBackgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.f];
			self.titleLabelTextColor = [UIColor blackColor];
			self.messageLabelTextColor = [UIColor blackColor];
            if (!_iconImage) {
                self.iconImage = [self imageNamed:@"isInfoIcon"];
            }
            break;
        }
		case ISAlertTypeMessageBlack: {
			//CGFloat rgbValue = 0.0f;
			self.alertViewBackgroundColor = [UIColor colorWithRed:75.f/255.f green:107.f/255.f blue:122.f/255.f alpha:1.f];
			self.titleLabelTextColor = [UIColor whiteColor];
			self.messageLabelTextColor = [UIColor whiteColor];
			if (!_iconImage) {
				self.iconImage = [self imageNamed:@"isInfoIcon"];
			}
			break;
		}
		case ISAlertTypeMessageWhite: {
			self.alertViewBackgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.f];
			self.titleLabelTextColor = [UIColor blackColor];
			self.messageLabelTextColor = [UIColor blackColor];
			if (!_iconImage) {
				self.iconImage = [self imageNamed:@"isInfoIcon"];
			}
			break;
		}
        default:
            break;
    }
    
    
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


@end
