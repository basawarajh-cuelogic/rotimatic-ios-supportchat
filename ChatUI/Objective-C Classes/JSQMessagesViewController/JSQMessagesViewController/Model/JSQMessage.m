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

#import "JSQMessage.h"


@interface JSQMessage ()

- (instancetype)initWithSenderId:(NSString *)senderId
                       messageId:(NSString *)messageId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia;

@end



@implementation JSQMessage

#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                          messageId:(NSString *)messageId
                        displayName:(NSString *)displayName
                               text:(NSString *)text
{
    return [[self alloc] initWithSenderId:senderId
                                messageId:messageId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                     text:text];
}

- (instancetype)initWithSenderId:(NSString *)senderId
                       messageId:(NSString *)messageId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
{
    NSParameterAssert(text != nil);

    self = [self initWithSenderId:senderId messageId:messageId senderDisplayName:senderDisplayName date:date isMedia:NO];
    if (self) {
        _text = [text copy];
    }
    return self;
}

+ (instancetype)messageWithSenderId:(NSString *)senderId
                          messageId:(NSString *)messageId
                        displayName:(NSString *)displayName
                              media:(id<JSQMessageMediaData>)media
{
    return [[self alloc] initWithSenderId:senderId
                                messageId:(NSString *)messageId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                    media:media];
}

- (instancetype)initWithSenderId:(NSString *)senderId
                       messageId:(NSString *)messageId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
{
    NSParameterAssert(media != nil);

    self = [self initWithSenderId:senderId messageId:messageId senderDisplayName:senderDisplayName date:date isMedia:YES];
    if (self) {
        _media = media;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
                       messageId:(NSString *)messageId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);
    NSParameterAssert(messageId != nil);

    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _isMediaMessage = isMedia;
        _messageId = messageId;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(methodOfReceivedNotification:) name:@"NotificationIdentifier" object:nil];

    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@.", __PRETTY_FUNCTION__, [self class]);
    return nil;
}

- (void)dealloc
{
    _senderId = nil;
    _senderDisplayName = nil;
    _date = nil;
    _text = nil;
    _media = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationIdentifier" object:nil];
}

- (NSUInteger)messageHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    JSQMessage *aMessage = (JSQMessage *)object;

    if (self.isMediaMessage != aMessage.isMediaMessage) {
        return NO;
    }

    BOOL hasEqualContent = self.isMediaMessage ? [self.media isEqual:aMessage.media] : [self.text isEqualToString:aMessage.text];

    return [self.senderId isEqualToString:aMessage.senderId]
    && [self.senderDisplayName isEqualToString:aMessage.senderDisplayName]
    && ([self.date compare:aMessage.date] == NSOrderedSame)
    && hasEqualContent;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.isMediaMessage ? [self.media mediaHash] : self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, messageId=%@, senderDisplayName=%@, date=%@, isMediaMessage=%@, text=%@, media=%@>",
            [self class], self.senderId, self.messageId, self.senderDisplayName, self.date, @(self.isMediaMessage), self.text, self.media];
}

- (id)debugQuickLookObject
{
    return [self.media mediaView] ?: [self.media mediaPlaceholderView];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _senderId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderId))];
        _messageId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messageId))];
        _senderDisplayName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderDisplayName))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        _isMediaMessage = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isMediaMessage))];
        _text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.messageId forKey:NSStringFromSelector(@selector(messageId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeBool:self.isMediaMessage forKey:NSStringFromSelector(@selector(isMediaMessage))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];

    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    if (self.isMediaMessage) {
        return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                         messageId:self.messageId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:self.date
                                                             media:self.media];
    }

    return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                     messageId:self.messageId
                                             senderDisplayName:self.senderDisplayName
                                                          date:self.date
                                                          text:self.text];
}

- (void) methodOfReceivedNotification: (NSNotification *) notification {
    
    NSString *messageId = [notification object];
    self.messageId = messageId;
    
}

@end
