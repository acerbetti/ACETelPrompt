//
//  ACEViewController.m
//  ACETelPromptDemo
//
//  Created by Stefano Acerbetti on 5/1/14.
//  Copyright (c) 2014 Aceland. All rights reserved.
//

#import "ACEViewController.h"
#import "ACETelPrompt.h"

@interface ACEViewController ()

@end

@implementation ACEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)callNumber:(id)sender
{
    [ACETelPrompt callPhoneNumber:self.phoneField.text
                             call:^(NSTimeInterval duration) {
                                 NSLog(@"User made a call of %.1f secods", duration);
                                 
                             } cancel:^{
                                 NSLog(@"User cancelled the call");
                             }];
}

@end
