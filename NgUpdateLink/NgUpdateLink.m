//
//  NgUpdateLink.m
//  NgUpdateLink
//
//  Created by Meiwin Fu on 18/10/15.
//  Copyright © 2015 BlockThirty. All rights reserved.
//

#import "NgUpdateLink.h"

#pragma mark -
@interface NgUpdateLink ()
@property (nonatomic, weak) CADisplayLink     * displayLink;
@property (nonatomic, strong) NSHashTable     * nextUpdates;
@property (nonatomic, strong) NSRecursiveLock * nextUpdatesLock;
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
- (void)update:(CADisplayLink *)dl {
  
  if (self.nextUpdates.count == 0) return;
  
  [self.nextUpdatesLock lock];
  NSHashTable * updates = self.nextUpdates;
  self.nextUpdates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
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

- (void)ng_update {}

@end