//
//  NotificationBar.m
//  ServerAPITest
//
//  Created by EninovUser on 11/09/13.
//  Copyright (c) 2013 Eninov. All rights reserved.
//

#import "NotificationBar.h"
#import "OBGradientView.h"
#import <AudioToolbox/AudioToolbox.h>

#import "UserProfileModel.h"
#import "Profile.h"
#import "Common.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#endif

#define NOTIFY_STRING_LEN 50

#define kMPNotificationHeight    40.0f
#define RADIANS(deg) ((deg) * M_PI / 180.0f)


static CGRect notificationRect()
{
    CGFloat topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        topPadding = window.safeAreaInsets.top;
    }else{
        topPadding = 0.0f;
    }
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, kMPNotificationHeight);
    }
    return CGRectMake(0.0f, topPadding, [UIScreen mainScreen].bounds.size.width, kMPNotificationHeight);
}

NSString *kNotificationBarTapReceivedNotification = @"kNotificationBarTapReceivedNotification";

#pragma mark NotificationWindow

@interface NotificationWindow : UIWindow

@property (nonatomic, strong) NSMutableArray *notificationQueue;
@property (nonatomic, strong) UIView *currentNotification;

@end

@implementation NotificationWindow

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        _notificationQueue = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

@end

static NotificationWindow * __notificationWindow = nil;
static CGFloat const __imagePadding = 10.0f;

#pragma mark -
#pragma mark NotificationView

@interface NotificationBar ()


@property (nonatomic, strong) OBGradientView * contentView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end


@implementation NotificationBar

- (void) dealloc
{
    [self removeGestureRecognizer:_tapGestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame titleText:(NSString*)title detailText:(NSString*)detail
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //NOV 2 CGFloat notificationWidth = notificationRect().size.width;
        
        CGSize titleTextSize = [self sizeOfString:title withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        
        NSString* detailStr = detail;
        if([detail length] > NOTIFY_STRING_LEN) {
            detailStr = [detailStr substringToIndex:NOTIFY_STRING_LEN];
        }
    
        CGSize detailTextSize = [self sizeOfString:detailStr withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];

        CGSize notificationSize = CGSizeMake(titleTextSize.width+detailTextSize.width, titleTextSize.height+detailTextSize.height);
        
        notificationSize.width = [UIScreen mainScreen].bounds.size.width;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGRect rectFrame = CGRectMake(0, 0, notificationSize.width, notificationSize.height);
        
        _contentView = [[OBGradientView alloc] initWithFrame:rectFrame /*self.bounds*/];
        _contentView.colors = @[(id)[[UIColor colorWithWhite:0.99f alpha:1.0f] CGColor],
        (id)[[UIColor colorWithWhite:0.9f  alpha:1.0f] CGColor]];
        
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentView.layer.cornerRadius = 8.0f;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.layer.cornerRadius = 4.0f;
        _logoImageView.clipsToBounds = YES;
        [self addSubview:_logoImageView];
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(6+CGRectGetMaxX(_logoImageView.frame), 0, 1, notificationSize.height)];
        lineView.backgroundColor = [UIColor colorWithRed:230.0 green:230.0 blue:230.0 alpha:0.8];
        [self addSubview:lineView];
        
        //CMP UIFont *textFont = [UIFont boldSystemFontOfSize:14.0f];
        UIFont *textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        CGRect textFrame = CGRectMake(__imagePadding + CGRectGetMaxX(_logoImageView.frame),
                                      0,notificationSize.width - __imagePadding * 2 - CGRectGetMaxX(_logoImageView.frame),
                                      titleTextSize.height);
        _titleLabel = [[UILabel alloc] initWithFrame:textFrame];
        _titleLabel.font = textFont;
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_titleLabel];
        
        //CMP UIFont *detailFont = [UIFont systemFontOfSize:13.0f];
        UIFont *detailFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        
        CGRect detailFrame = CGRectMake(CGRectGetMinX(textFrame),
                                        CGRectGetMaxY(textFrame),
                                        notificationSize.width - __imagePadding * 2 - CGRectGetMaxX(_logoImageView.frame),detailTextSize.height);
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:detailFrame];
        _detailTextLabel.font = detailFont;
        _detailTextLabel.numberOfLines = 2;
        _detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_detailTextLabel];
        
        /*
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                      CGRectGetHeight(frame) - 1.0f,
                                                                      CGRectGetWidth(frame),
                                                                      1.0f)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        
        [_contentView addSubview:bottomLine];
        */
    }
    return self;
}

+ (NotificationBar *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
andDuration:(NSTimeInterval)duration msgPayLoad:(NSDictionary*)payload
{
    
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    for (NSString *phNumber in currentUserProfileDetails.additionalVerifiedNumbers) {
        if ([[payload valueForKey:@"ph"] isEqualToString:[phNumber valueForKey:@"contact_id"]]) {
            detail = [NSString stringWithFormat:@"InstaVoice is active on %@",[Common getFormattedNumber:[payload valueForKey:@"ph"] withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        }
    }
    
    if (__notificationWindow == nil)
    {
        __notificationWindow = [[NotificationWindow alloc] initWithFrame:notificationRect()];
        __notificationWindow.hidden = NO;
    }
    
    NotificationBar *notification;
    notification = [[NotificationBar alloc] initWithFrame:__notificationWindow.bounds titleText:text detailText:detail];
    notification.titleLabel.text = text;
    notification.detailTextLabel.text = detail;
    notification.logoImageView.image = image;
    if(detail.length >= 20)
        notification.duration = 3;
    else
        notification.duration = duration;
    notification.msgPayLoad = payload;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:notification
                                                                         action:@selector(handleTap:)];
    notification.tapGestureRecognizer = gr;
    [notification addGestureRecognizer:gr];
    
    [__notificationWindow.notificationQueue addObject:notification];
    
    if (__notificationWindow.currentNotification == nil)
    {
        [self showNextNotification];
    }
    
    return notification;
    
}

- (void) handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBarTapReceivedNotification object:self];
    
    [NotificationBar showNextNotification];
}


+ (void) showNextNotification
{
   
    [NSObject cancelPreviousPerformRequestsWithTarget:[self class]
                                             selector:@selector(showNextNotification)
                                               object:nil];
    
    UIView *viewToRotateOut = nil;
    //UIImage *screenshot = [self screenImageWithRect:__notificationWindow.frame];
    
    if (__notificationWindow.currentNotification)
    {
        viewToRotateOut = __notificationWindow.currentNotification;
    }
    else
    {
        viewToRotateOut = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        //((UIImageView *)viewToRotateOut).image = screenshot;
        [__notificationWindow addSubview:viewToRotateOut];
        __notificationWindow.hidden = NO;
    }
    
    UIView *viewToRotateIn = nil;
    
    if ([__notificationWindow.notificationQueue count] > 0)
    {
        viewToRotateIn = __notificationWindow.notificationQueue[0];
    }
    else
    {
        viewToRotateIn = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        //((UIImageView *)viewToRotateIn).image = screenshot;
    }
    
    viewToRotateIn.layer.anchorPointZ = 11.547f;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 2;
    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(RADIANS(-120), 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0 / 200.0;
    
    viewToRotateOut.layer.anchorPointZ = 11.547f;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 2;
    
    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(RADIANS(120), 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0 / 200.0;
    
    [__notificationWindow addSubview:viewToRotateIn];
    __notificationWindow.backgroundColor = [UIColor clearColor];
    
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    if ([viewToRotateIn isKindOfClass:[NotificationBar class]] )
    {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        //bgImage.image = screenshot;
        [viewToRotateIn addSubview:bgImage];
        [viewToRotateIn sendSubviewToBack:bgImage];
        __notificationWindow.currentNotification = viewToRotateIn;//TODO crash
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {
                         [viewToRotateOut removeFromSuperview];
                         [__notificationWindow.notificationQueue removeObject:viewToRotateOut];
                         if ([viewToRotateIn isKindOfClass:[NotificationBar class]])
                         {
                             NotificationBar *notification = (NotificationBar*)viewToRotateIn;
                             
                             if (notification.duration > 0.0)
                             {
                                 [self performSelector:@selector(showNextNotification)
                                            withObject:nil
                                            afterDelay:notification.duration];
                             }
                             
                             __notificationWindow.currentNotification = notification;
                             [__notificationWindow.notificationQueue removeObject:notification];
                             
                             NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"InstavoiceNotificationTone" ofType:@"caf"];
                             
                             /* Sachin changes
                             AppDelegate *appDelegate = (AppDelegate *)APP_DELEGATE;
                             NSDictionary *soundInfo = [appDelegate.confgReader getNotificationSoundInfo];
                             if (soundInfo != nil) {
                                 soundPath = [[soundInfo allValues] firstObject];
                             } else {
                                 soundPath = [[NSBundle mainBundle] pathForResource:@"AudioResource.bundle/NotificationTones/ReachMeDefaultNotificationTone" ofType:@"mp3"];
                             }*/
                             
                             SystemSoundID soundID;
                             AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
                             AudioServicesPlaySystemSound (soundID);
                         }
                         else
                         {
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                         }
                         
                         __notificationWindow.backgroundColor = [UIColor clearColor];
                     }];
     
}

+ (UIImage *) screenImageWithRect:(CGRect)rect
{
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale
                      , rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                      scale:croppedScreenshot.scale
                                orientation:imageOrientation];
}

-(CGSize)sizeOfString:(NSString *)string withFont:(UIFont *)font
{
    CGSize max = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX);
    CGRect rect;
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        rect =
        [string boundingRectWithSize:max
                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                          attributes:@{NSFontAttributeName:font}
                             context:nil];
        rect.size.height += 2;
    }
    else {
        //DC MAY 26 2016
        NSAttributedString *offsetAttributedString;
        if (string.length) {
            offsetAttributedString = [[NSAttributedString alloc]initWithString:string   attributes:@{NSFontAttributeName:font}];
        }
        else
            offsetAttributedString = [[NSAttributedString alloc]initWithString:@""   attributes:@{}];
        CGRect offsetTextStringRect = [offsetAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        rect.size = offsetTextStringRect.size;

        //rect.size =  [string sizeWithFont:font constrainedToSize:max lineBreakMode:NSLineBreakByWordWrapping];
        rect.size.width = rect.size.width;
    }
    
    return rect.size;
}


@end
