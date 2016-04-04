//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQPhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "ChatUI-Swift.h"
#import "UCZProgressView.h"

typedef enum : NSUInteger {
    kMediaUploadStatusNone,
    kMediaUploadStatusWillStart,
    kMediaUploadStatusUploading,
    kMediaUploadStatusUploaded,
    kMediaUploadStatusFailed
} kMediaUploadStatus;



@interface JSQPhotoMediaItem ()<FileUploadAPIManagerDelegate> {
    FileUploadAPIManager *manager;
}

@property (strong, nonatomic) UIImageView *cachedImageView;
@property (strong, nonatomic) UCZProgressView *progressView;
@property (nonatomic) kMediaUploadStatus mediauploadStatus;
@property (nonatomic) float progressValue;
@property (strong, nonatomic) UIButton *imgViewUploadORCancel;



@end


@implementation JSQPhotoMediaItem

#pragma mark - Initialization

-(void)setMediauploadStatus:(kMediaUploadStatus)mediauploadStatus {
    _mediauploadStatus = mediauploadStatus;
    
    if (mediauploadStatus == kMediaUploadStatusWillStart) {
        
    } else if (mediauploadStatus == kMediaUploadStatusFailed) {
        _imgViewUploadORCancel.hidden= NO;
        [_imgViewUploadORCancel setSelected:true];
        
    } else if (mediauploadStatus == kMediaUploadStatusUploading){
        _imgViewUploadORCancel.hidden= NO;
        [_imgViewUploadORCancel setSelected:false];
        
    } else if (mediauploadStatus == kMediaUploadStatusUploaded){
        _imgViewUploadORCancel.hidden= YES;
    }
}


- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = [image copy];
        _cachedImageView = nil;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)imageURL fileUploaded:(BOOL) isFileUploaded
{
    self = [super init];
    if (self) {
        _imageURL = [imageURL copy];
        _cachedImageView = nil;
        _isFileUploaded = isFileUploaded;
        if (_isFileUploaded) {
            _mediauploadStatus = kMediaUploadStatusUploaded;
        } else {
            _mediauploadStatus = kMediaUploadStatusWillStart;
            
        }

    }
    return self;
}

- (void)dealloc
{
    _image = nil;
    _cachedImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.image == nil && self.imageURL == nil) {
        return nil;
    }
    
    if (self.imageURL == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    else{
        
        CGSize size = [self mediaViewDisplaySize];

        
        UIView * view;
        if (true) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        } else {
            view = self.mediaView;
        }

        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor grayColor];
        
        self.imageURL = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:self.imageURL.lastPathComponent];
        
        if (_mediauploadStatus == kMediaUploadStatusUploaded) {
            
            NSURL * filePath = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:self.imageURL.lastPathComponent];
            UIImage *pic = [UIImage imageWithContentsOfFile:filePath.path];
            imageView.image = pic;

        }
        else if(_mediauploadStatus == kMediaUploadStatusUploading){
            
            NSURL * filePath = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:self.imageURL.lastPathComponent];
            UIImage *pic = [UIImage imageWithContentsOfFile:filePath.path];
            imageView.image = pic;
            
            self.progressView = [[UCZProgressView alloc] init];
            self.progressView.frame = CGRectMake(0, 0, 20, 20);
            self.progressView.center = imageView.center;
            self.progressView.usesVibrancyEffect = true;
            self.progressView.tintColor = [UIColor orangeColor];
            self.progressView.backgroundColor = [UIColor clearColor];
            self.progressView.backgroundView = [UIView new];
            
            _imgViewUploadORCancel = [UIButton new];
            [_imgViewUploadORCancel setBounds:CGRectMake(0, 0, 32, 32)];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"close_icon.png"] forState:UIControlStateNormal];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"up_arrow_chat.png"] forState:UIControlStateSelected];
            [_imgViewUploadORCancel addTarget:self action:@selector(onTapOfProgress:) forControlEvents:UIControlEventTouchUpInside];

            
        } else if(_mediauploadStatus == kMediaUploadStatusWillStart) {
            
            
            NSURL * filePath = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:self.imageURL.lastPathComponent];
            UIImage *pic = [UIImage imageWithContentsOfFile:filePath.path];
            imageView.image = pic;
            self.progressView = [[UCZProgressView alloc] init];
            self.progressView.frame = CGRectMake(0, 0, 20, 20);
            self.progressView.center = imageView.center;
            self.progressView.usesVibrancyEffect = true;
            self.progressView.tintColor = [UIColor orangeColor];
            self.progressView.backgroundColor = [UIColor clearColor];
            self.progressView.backgroundView = [UIView new];
            [imageView addSubview:self.progressView];
            
            
            _imgViewUploadORCancel = [UIButton new];
            [_imgViewUploadORCancel setBounds:CGRectMake(0, 0, 32, 32)];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"close_icon.png"] forState:UIControlStateNormal];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"up_arrow_chat.png"] forState:UIControlStateSelected];
            [_imgViewUploadORCancel addTarget:self action:@selector(onTapOfProgress:) forControlEvents:UIControlEventTouchUpInside];
            _imgViewUploadORCancel.center = imageView.center;
            
            [self uploadImageFile];
            
        }else if(_mediauploadStatus == kMediaUploadStatusFailed) {
            _mediauploadStatus = kMediaUploadStatusFailed;
        }
        
        [view addSubview:imageView];
        [view addSubview:_imgViewUploadORCancel];
        
              
        /*__block UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.center = imageView.center;
        activityView.hidesWhenStopped = YES;
        [activityView startAnimating];
        
        [imageView sd_setImageWithURL:self.imageURL placeholderImage: nil options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityView removeFromSuperview];
            imageView.image = image;
        }];*/
        
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMediaView = view;
    }
    
    return self.cachedMediaView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}

- (void) uploadImageFile {
    manager = [[FileUploadAPIManager alloc] init];
    manager.delegate= self;
    [manager uploadFile:[manager uploadRequest:self.imageURL fileName:self.imageURL.lastPathComponent]];
    [self.progressView setHidden:NO];
    self.mediauploadStatus = kMediaUploadStatusUploading;
}

- (void) cancelUpload {
    [manager cancelUpload:manager.uploadRequest];
    self.progressView.progress = 0.0f;
}

- (void)onTapOfProgress:(UITapGestureRecognizer *)gestureObj {
    if (_mediauploadStatus == kMediaUploadStatusUploading) {
        [self cancelUpload];
        _mediauploadStatus = kMediaUploadStatusFailed;
    } else {
        _mediauploadStatus = kMediaUploadStatusWillStart;
        [self uploadImageFile];
    }
    
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQPhotoMediaItem *copy = [[JSQPhotoMediaItem allocWithZone:zone] initWithImage:self.image];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

#pragma mark - FileUploadManager delegate
- (void)progressUpload:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"Total Percent Upload = %f",(double)totalBytesSent / (double)totalBytesExpectedToSend);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        _progressValue = (double)totalBytesSent / (double)totalBytesExpectedToSend;;
        if (self.progressView.progress != 1.0) {
            self.mediauploadStatus = kMediaUploadStatusUploading;
        }
    });

}

- (void)uploadSuccess:(NSString *)fileURL
{
    [self.progressView setHidden:YES];
    [_imgViewUploadORCancel setHidden:YES];
    [[ChatAPIManager sharedManager] sendChatMessage:fileURL];
    self.mediauploadStatus = kMediaUploadStatusUploaded;
    
}

- (void)uploadFailed
{
    [self.progressView setHidden:YES];
    self.mediauploadStatus = kMediaUploadStatusFailed;

}

@end
