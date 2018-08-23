//
//  ImageScrollView.m
//  InstaVoice
//
//  Created by kirusa on 11/28/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ImageScrollView.h"
#import "IVFileLocator.h"
#import "TableColumns.h"
#import "IVMediaLoader.h"

@interface ImageScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *zoomView;  // contains the full image

@property CGSize imageSize;

@property CGPoint pointToCenterAfterResize;
@property CGFloat scaleToRestoreAfterResize;

@end


#pragma mark -

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame witharray:(NSArray *)array{
    
    self = [super initWithFrame:frame];
    if (self) {
        _mediaList = array;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureCaptured:)];
    [doubleTap setDelegate:self];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    return self;
}

- (void)doubleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if(!(check == imgThumbnail)){
        float newScale;
        if([self zoomScale] > 1){
            newScale = [self minimumZoomScale] * 0.5;
        }else{
            newScale = [self zoomScale] * 5;
        }

        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:[self zoomView]]];
        [self zoomToRect:zoomRect animated:YES];
    }else{
        if(image){
            [self displayImage:image];
            check = image;
        }
    }
}

- (void)setIndex:(NSUInteger)index {
    
    _index = index;
    NSDictionary *mediaDic = [_mediaList objectAtIndex:index];
    NSString *msgContentType  = [[mediaDic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
    
    if([msgContentType isEqualToString:IMAGE_TYPE])
    {
        NSString* msgLocalPath = [mediaDic valueForKey:MSG_LOCAL_PATH];
        if(!msgLocalPath || !msgLocalPath.length)
            msgLocalPath = [[mediaDic valueForKey:MSG_ID]stringValue]; //TODO MAY 2017
        
        if(msgLocalPath && msgLocalPath.length > 1)
        {
            NSString* localPath = [IVFileLocator getMediaImagePath:msgLocalPath];
            localPath = [[localPath stringByDeletingPathExtension]stringByAppendingPathExtension:@"jpg"];
            if(localPath != nil)
            {
                image = [UIImage imageWithContentsOfFile:localPath];
                //APR, 2017
                NSString* thumbnailURL=nil;
                NSString* base64String=nil;
                NSString* imageUrl=nil;
                if(!image) {
                    NSString *msgContent = [mediaDic valueForKey:MSG_CONTENT];
                    NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error = nil;
                    NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    NSMutableArray* imageArr = [imageData valueForKey:@"img"];
                    
                    for(NSMutableDictionary* imageDic in imageArr)
                    {
                        thumbnailURL = [imageDic valueForKey:@"thumb_url"];
                        base64String = [imageDic valueForKey:@"thumb_base64"];
                        imageUrl = [imageDic valueForKey:@"url"];
                    }
                }
                //
                if(imageUrl.length)
                    [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
                
                imgThumbnail = [[IVMediaLoader sharedIVMediaLoader]getThumbnailImageForLocalPath:msgLocalPath serverPath:thumbnailURL base64String:base64String];
                
                if(image)
                {
                    [self displayImage:image];
                    check = image;
                } else if (imgThumbnail) {
                    [self displayImage:imgThumbnail];
                    check = imgThumbnail;
                }
                else{
                    [self displayImage:[UIImage imageNamed:@"reg_background.png"]];
                }
            }
        }
    }
}

- (void)layoutSubviews  {
    
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame {
    
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _zoomView;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - Configure scrollView to display new image

- (void)displayImage:(UIImage *)image {
    
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize {
    
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    //CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    CGFloat maxScale = 2.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
//    if (minScale > maxScale) {
//        minScale = maxScale;
//    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale * 0.99999;
}


#pragma mark - Methods called during rotation to preserve the zoomScale and the visible portion of the image

- (void)prepareToResize {
    
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    
    return CGPointZero;
}

@end

