//
//  IVImageProcessingOperation.h
//  InstaVoice
//
//  Created by adwivedi on 21/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
	IVImageProcessingOperationTypeDownloadImage = 0,
	IVImageProcessingOperationTypeUploadImage,
	IVImageProcessingOperationTypeProcessImage
} IVImageProcessingOperationType;

@interface IVImageData : NSObject
@property (nonatomic,strong)NSString* imgServerPath;
@property (nonatomic,strong)NSString* imgLocalPath;
@property (nonatomic,strong)NSData* imgData;
@property (nonatomic)BOOL thumbnailImage;
@end

@protocol IVImageProcessingOperationDelegate <NSObject>
-(void)ivImageProcessingOperationType:(IVImageProcessingOperationType)type completedWithResponse:(IVImageData*)imageData;
@end

@interface IVImageProcessingOperation : NSOperation<NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic)IVImageProcessingOperationType ivImageProcessingOperationType;
@property (nonatomic, strong) IVImageData *imageData;

@property (nonatomic,weak)id<IVImageProcessingOperationDelegate> delegate;
- (id)initWithImageData:(IVImageData *)imageData ivImageProcessingOperationType:(IVImageProcessingOperationType)operationType;


@end

