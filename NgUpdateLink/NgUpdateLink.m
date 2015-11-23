//
//  NgUpdateLink.m
//  NgUpdateLink
//
//  Created by Meiwin Fu on 18/10/15.
//  Copyright © 2015 BlockThirty. All rights reserved.
//

#import "NgUpdateLink.h"

@interface NgUpdateLinkUpdateWithAction : NSObject<NgUpdateLinkUpdate>
@property (nonatomic, weak, readonly)     id target;
@property (nonatomic, readonly)           SEL action;
@property (nonatomic, strong, readonly)   NSString * hashString;
- (instancetype)init __unavailable;
- (instancetype)initWithTarget:(id)target action:(SEL)action hashString:(NSString *)hashString;
+ (NSString *)hashStringForTarget:(id)target action:(SEL)action;
@end

@implementation NgUpdateLinkUpdateWithAction
- (instancetype)initWithTarget:(id)target action:(SEL)action hashString:(NSString *)hashString {

  NSParameterAssert(target);
  NSParameterAssert(action);
  NSParameterAssert(hashString);
  
  self = [super init];
  if (self) {
    _target = target;
    _action = action;
    _hashString = hashString;
  }
  return self;
}
+ (NSString *)hashStringForTarget:(id)target action:(SEL)action {
  return [NSString stringWithFormat:@"%p-%@", target, NSStringFromSelector(action)];
}
- (id)strongTarget {
  __strong id strongTarget = self.target;
  return strongTarget;
}
- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[NgUpdateLinkUpdateWithAction class]]) return NO;
  NgUpdateLinkUpdateWithAction * other = (NgUpdateLinkUpdateWithAction *)object;
  return [other.hashString isEqual:self.hashString];
}
- (NSUInteger)hash {
  return [self.hashString hash];
}
- (void)ng_update {
  
  id strongTarget = [self strongTarget];
  if (!strongTarget) return;

  IMP impl = [strongTarget methodForSelector:self.action];
  ((void(*)(id, SEL))impl)(strongTarget, self.action);
}
@end

#pragma mark -
@interface NgUpdateLink ()
@property (nonatomic, weak) CADisplayLink           * displayLink;
@property (nonatomic, strong) NSHashTable           * nextUpdates;
@property (nonatomic, strong) NSRecursiveLock       * nextUpdatesLock;
@property (nonatomic, strong) NSMutableDictionary   * actionUpdates;
@end

@implementation NgUpdateLink

- (instancetype)_initWithRunLoopMode:(NSString *)runLoopMode {
  self = [super init];
  if (self) {
    CADisplayLink * displayLink =
    [CADisplayLink displayLinkWithTarget:self
                                selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                      forMode:runLoopMode];
    
    self.displayLink = displayLink;
    self.actionUpdates = [NSMutableDictionary dictionary];
    self.nextUpdatesLock = [[NSRecursiveLock alloc] init];
    self.nextUpdates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
  }
  return self;
}
+ (NgUpdateLink *)currentInstanceforRunLoopCommonModes {
  static NgUpdateLink * _currentInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _currentInstance = [[NgUpdateLink alloc] _initWithRunLoopMode:NSRunLoopCommonModes];
  });
  return _currentInstance;
}
+ (NgUpdateLink *)currentInstanceForDefaultRunLoopMode {
  static NgUpdateLink * _currentInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _currentInstance = [[NgUpdateLink alloc] _initWithRunLoopMode:NSDefaultRunLoopMode];
  });
  return _currentInstance;
}
- (void)addUpdate:(id<NgUpdateLinkUpdate>)update {

  [self.nextUpdatesLock lock];
  [self.nextUpdates addObject:update];
  [self.nextUpdatesLock unlock];
}
- (void)addUpdateWithTarget:(id)target action:(SEL)action {

  [self.nextUpdatesLock lock];
  NSString * hashString =
  [NgUpdateLinkUpdateWithAction hashStringForTarget:target action:action];
  
  NgUpdateLinkUpdateWithAction * update = self.actionUpdates[hashString];
  if (!update) {
    update = [[NgUpdateLinkUpdateWithAction alloc] initWithTarget:target action:action hashString:hashString];
    self.actionUpdates[hashString] = update;
    [self.nextUpdates addObject:update];
  }
  
  [self.nextUpdatesLock unlock];
}
- (void)update:(CADisplayLink *)dl {
  
  if (self.nextUpdates.count == 0) return;
  
  [self.nextUpdatesLock lock];
  NSHashTable * updates = self.nextUpdates;
  self.nextUpdates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
  __unused NSDictionary * actionUpdates = self.actionUpdates;
  self.actionUpdates = [NSMutableDictionary dictionary];
  [self.nextUpdatesLock unlock];
  
  [self invokeUpdate:updates];
}
- (void)invokeUpdate:(NSHashTable *)updates {
  
  for (id<NgUpdateLinkUpdate> update in updates) {
    if (!update) continue;
    [update ng_update];
  }
}
@end

#pragma mark -
@implementation NSObject (NgUpdateLink)

- (void)ng_setNeedsUpdate {
  [[NgUpdateLink currentInstanceForDefaultRunLoopMode] addUpdate:self];
}
- (void)ng_setNeedsUpdate:(NSString *)runLoopMode {
  if (runLoopMode == NSRunLoopCommonModes) {
    [[NgUpdateLink currentInstanceforRunLoopCommonModes] addUpdate:self];
  }
  [[NgUpdateLink currentInstanceForDefaultRunLoopMode] addUpdate:self];
}
- (void)ng_setNeedsUpdateWithAction:(SEL)action {
  [self ng_setNeedsUpdate:NSDefaultRunLoopMode action:action];
}
- (void)ng_setNeedsUpdate:(NSString *)runLoopMode action:(SEL)action {
  
  if (runLoopMode == NSRunLoopCommonModes) {
    [[NgUpdateLink currentInstanceforRunLoopCommonModes] addUpdateWithTarget:self action:action];
  }
  [[NgUpdateLink currentInstanceForDefaultRunLoopMode] addUpdateWithTarget:self action:action];
}
- (void)ng_update {}

@end