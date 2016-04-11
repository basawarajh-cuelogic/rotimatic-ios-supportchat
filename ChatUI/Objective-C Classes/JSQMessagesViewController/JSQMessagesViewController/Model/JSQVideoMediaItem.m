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



#import "JSQVideoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"

#import "ChatUI-Swift.h"
#import "UCZProgressView.h"

typedef enum : NSUInteger {
    kMediaUploadStatusNone,
    kMediaUploadStatusWillStart,
    kMediaUploadStatusUploading,
    kMediaUploadStatusUploaded,
    kMediaUploadStatusFailed
} kMediaUploadStatus;


@interface JSQVideoMediaItem ()<FileUploadAPIManagerDelegate> {
    FileUploadAPIManager *manager;
}

@property (strong, nonatomic) UIView *cachedVideoImageView;
@property (strong, nonatomic) UCZProgressView *progressView;
@property (nonatomic) kMediaUploadStatus mediauploadStatus;
@property (nonatomic) float progressValue;
@property (strong, nonatomic) UIButton *imgViewUploadORCancel;
@property (strong, nonatomic) UIImageView *imgViewPlay;


@end


@implementation JSQVideoMediaItem

#pragma mark - Initialization

-(void)setMediauploadStatus:(kMediaUploadStatus)mediauploadStatus {
    _mediauploadStatus = mediauploadStatus;
    
    if (mediauploadStatus == kMediaUploadStatusWillStart) {
        
    } else if (mediauploadStatus == kMediaUploadStatusFailed) {
        _imgViewUploadORCancel.hidden= NO;
        [_imgViewUploadORCancel setSelected:true];
        self.isFileUploaded = NO;
        
    } else if (mediauploadStatus == kMediaUploadStatusUploading){
        _imgViewUploadORCancel.hidden= NO;
        [_imgViewUploadORCancel setSelected:false];
        self.isFileUploaded = NO;
        
    } else if (mediauploadStatus == kMediaUploadStatusUploaded){
        _imgViewUploadORCancel.hidden= YES;
        self.isFileUploaded = YES;

    }
}


- (instancetype)initWithFileURL:(NSURL *)fileURL thumbnailURL:(NSURL *)thumbnailURL isReadyToPlay:(BOOL)isReadyToPlay isFileUploaded:(BOOL) isFileUploaded ticketId:(NSString *) ticketId subject:(NSString *) subject
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _fileThumbnailURL = [thumbnailURL copy];
        _isReadyToPlay = isReadyToPlay;
        _isFileUploaded = isFileUploaded;
        _ticketId = ticketId;
        _cachedVideoImageView = nil;
        _ticketSubject = subject;
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
    _fileURL = nil;
    _cachedVideoImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedVideoImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVideoImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVideoImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (_cachedMediaView) {
        return _cachedMediaView;
    }
    
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedVideoImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        UIView * view;
        if (true) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        } else {
            view = self.mediaView;
        }
        
        
        UIImageView *thumbnailImage = [[UIImageView alloc] init];
        thumbnailImage.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        thumbnailImage.contentMode = UIViewContentModeScaleAspectFill;
        thumbnailImage.clipsToBounds = YES;
        thumbnailImage.backgroundColor = [UIColor grayColor];
        
        NSString * thumbnailFileName = self.fileThumbnailURL.lastPathComponent.stringByDeletingPathExtension;
        thumbnailFileName = [NSString stringWithFormat:@"%@.png",thumbnailFileName];
        NSURL * filePath = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:thumbnailFileName];
        UIImage *pic = [UIImage imageWithContentsOfFile:filePath.path];
        thumbnailImage.image = pic;
        
        self.fileURL = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"upload"] URLByAppendingPathComponent:self.fileURL.lastPathComponent];
        
        
        if (_mediauploadStatus == kMediaUploadStatusUploaded) {
            
            UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:playIcon];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
            imageView.contentMode = UIViewContentModeCenter;
            imageView.clipsToBounds = YES;
            [view addSubview:imageView];
            
        }
        else if(_mediauploadStatus == kMediaUploadStatusUploading){
            self.progressView = [[UCZProgressView alloc] init];
            self.progressView.frame = CGRectMake(0, 0, 20, 20);
            self.progressView.center = thumbnailImage.center;
            self.progressView.usesVibrancyEffect = true;
            self.progressView.tintColor = [UIColor orangeColor];
            self.progressView.backgroundColor = [UIColor clearColor];
            self.progressView.backgroundView = [UIView new];
            
            [thumbnailImage addSubview:self.progressView];
            [self.progressView setProgress:0.4 animated:YES];
            
            _imgViewUploadORCancel = [UIButton new];
            [_imgViewUploadORCancel setBounds:CGRectMake(0, 0, 32, 32)];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"close_icon.png"] forState:UIControlStateNormal];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"up_arrow_chat.png"] forState:UIControlStateSelected];
            [_imgViewUploadORCancel addTarget:self action:@selector(onTapOfProgress:) forControlEvents:UIControlEventTouchUpInside];
            _imgViewUploadORCancel.center = thumbnailImage.center;
            
            
        } else if(_mediauploadStatus == kMediaUploadStatusWillStart) {
            UIImage *pic = [UIImage imageWithContentsOfFile:self.fileThumbnailURL.path];
            thumbnailImage.image = pic;
            self.progressView = [[UCZProgressView alloc] init];
            self.progressView.frame = CGRectMake(0, 0, 20, 20);
            self.progressView.center = thumbnailImage.center;
            self.progressView.usesVibrancyEffect = true;
            self.progressView.tintColor = [UIColor orangeColor];
            self.progressView.backgroundColor = [UIColor clearColor];
            self.progressView.backgroundView = [UIView new];
            [thumbnailImage addSubview:self.progressView];
            
            
            _imgViewUploadORCancel = [UIButton new];
            [_imgViewUploadORCancel setBounds:CGRectMake(0, 0, 32, 32)];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"close_icon.png"] forState:UIControlStateNormal];
            [_imgViewUploadORCancel setBackgroundImage:[UIImage imageNamed:@"up_arrow_chat.png"] forState:UIControlStateSelected];
            [_imgViewUploadORCancel addTarget:self action:@selector(onTapOfProgress:) forControlEvents:UIControlEventTouchUpInside];
            _imgViewUploadORCancel.center = thumbnailImage.center;
            
            [self uploadVideoFile];
            
        }else if(_mediauploadStatus == kMediaUploadStatusFailed) {
            _mediauploadStatus = kMediaUploadStatusFailed;
        }
        [view addSubview:thumbnailImage];
        [view addSubview:_imgViewUploadORCancel];

        
        
        UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
        
        _imgViewPlay = [[UIImageView alloc] initWithImage:playIcon];
        _imgViewPlay.backgroundColor = [UIColor clearColor];
        _imgViewPlay.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        _imgViewPlay.contentMode = UIViewContentModeCenter;
        _imgViewPlay.clipsToBounds = YES;
        [view addSubview:_imgViewPlay];
        
        if (_isFileUploaded) {
            [_imgViewPlay setHidden:NO];
        }
        else {
            [_imgViewPlay setHidden:YES];
        }
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
        self.cachedVideoImageView = view;
        self.cachedMediaView = view;
    }
    
    return self.cachedVideoImageView;
}

- (void) uploadVideoFile {
    manager = [[FileUploadAPIManager alloc] init];
    manager.delegate= self;
    [manager uploadFile:[manager uploadRequest:self.fileURL fileName:self.fileURL.lastPathComponent]];
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
        [self uploadVideoFile];
    }
    
}


- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQVideoMediaItem *videoItem = (JSQVideoMediaItem *)object;
    
    return [self.fileURL isEqual:videoItem.fileURL]
            && self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQVideoMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL thumbnailURL:self.fileThumbnailURL isReadyToPlay:self.isReadyToPlay isFileUploaded:self.isFileUploaded ticketId: self.ticketId subject:self.ticketSubject];
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
    [_imgViewPlay setHidden:NO];
    //[[ChatAPIManager sharedManager] sendChatMessage:fileURL];
    
    NSMutableDictionary *uploadedInfoDict = [[NSMutableDictionary alloc] init];
    [uploadedInfoDict setObject:fileURL forKey:@"message"];
    [uploadedInfoDict setObject:self.ticketId forKey:@"ticketId"];
    [uploadedInfoDict setObject:self.ticketSubject forKey:@"subject"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MediaUploaded" object:uploadedInfoDict];
    self.mediauploadStatus = kMediaUploadStatusUploaded;

}

- (void)uploadFailed
{
    [self.progressView setHidden:YES];
    
    self.mediauploadStatus = kMediaUploadStatusFailed;
    
}



@end
