# NgUpdateLink

NgUpdateLink is an iOS library for regulating/scheduling UI updates. It provides simple abstraction to UIKit `CADisplayLink` api.

## Adding to your project

If you are using Cocoapods, add to your Podfile:
```ruby
pod NgUpdateLink
```

To manually add to your projects:
```
1. Add files in NgUpdateLink folder to your project.
2. Add these frameworks to your project: `UIKit`.
```

## Features

NgUpdateLink supports scheduling updates in both `NSDefaultRunLoopMode` and `NSCommonRunLoopModes`.
The library includes a NSObject category that allows every object to easily schedule an update.

There are 2 ways to do it:

1. By calling `-ng_setNeedsUpdate` (or `-ng_setNeedsUpdate:` with desired run loop mode) to schedule. The object that calls this method will receive `ng_update` callback.
2. By calling `-ng_setNeedsUpdateWithAction:` (or `-ng_setNeedsUpdate:action:`) to schedule update with specific method callback.

## Usage

NgUpdateLink is designed to solve problem in certain category of app, e.g. chat, where you have a lot of UI updates that are triggered by various events. And ideally, we want to perform UI updates only once regardless the number of events that arrived in a single run loop.

```objective-c

// imaginary events
- (void)newReplyInserted:(NSNotification *)note {
  [self ng_setNeedsUpdate:NSCommonRunLoopModes action:@selector(insertNewReplies)];
}

// the callback
- (void)insertNewReplies {
  // insert rows to table/collection view for new replies
}
```

## Contact

Meiwin Fu
* http://github.com/meiwin
* http://twitter.com/meiwin

## License

NgUpdateLink is available under the MIT license. See the LICENSE file for more info.
