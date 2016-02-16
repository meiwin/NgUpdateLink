//
//  NgUpdateLink.h
//  NgUpdateLink
//
//  Created by Meiwin Fu on 18/10/15.
//  Copyright © 2015 Meiwin Fu. All rights reserved.
//

@import UIKit;

#pragma mark -
@protocol NgUpdateLinkUpdate <NSObject>
@required
- (void)ng_update;
@end

#pragma mark -
@interface NgUpdateLink : NSObject

+ (NgUpdateLink *)currentInstanceForDefaultRunLoopMode;
+ (NgUpdateLink *)currentInstanceforRunLoopCommonModes;

- (instancetype)init __unavailable;
- (void)addUpdate:(id<NgUpdateLinkUpdate>)update;

@end

#pragma mark -
@interface NSObject (NgUpdateLink) <NgUpdateLinkUpdate>

- (void)ng_setNeedsUpdate;
- (void)ng_setNeedsUpdate:(NSString *)runLoopMode;
- (void)ng_setNeedsUpdateWithAction:(SEL)action; // default to NSDefaultRunLoopMode
- (void)ng_setNeedsUpdate:(NSString *)runLoopMode action:(SEL)action;
- (void)ng_update;

@end