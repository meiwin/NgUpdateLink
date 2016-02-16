//
//  ViewController.h
//  NgUpdateLinkDemo
//
//  Created by Meiwin Fu on 18/10/15.
//  Copyright © 2015 Meiwin Fu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NgUpdateLink.h"

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel    * textLabel;
- (IBAction)increment:(id)sender;
- (IBAction)decrement:(id)sender;
@end