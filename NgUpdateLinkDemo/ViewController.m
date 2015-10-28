//
//  ViewController.m
//  NgUpdateLinkDemo
//
//  Created by Meiwin Fu on 18/10/15.
//  Copyright © 2015 BlockThirty. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) NSInteger   counter;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self ng_setNeedsUpdate];
}
- (void)increment:(id)sender {
  self.counter++;
  [self ng_setNeedsUpdate];
}
- (void)decrement:(id)sender {
  self.counter--;
  [self ng_setNeedsUpdateWithAction:@selector(updateLabel)];
}
- (void)ng_update {
  self.textLabel.text = [NSString stringWithFormat:@"%ld", self.counter];
}
- (void)updateLabel {
  self.textLabel.text = [NSString stringWithFormat:@"%ld", self.counter];
}
@end