// ACETelPrompt.m
//
// Copyright (c) 2014 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ACETelPrompt.h"

// the time required to launch the phone app and come back (will be substracted to the duration)
#define kCallSetupTime      3.0

@interface ACETelPrompt ()
@property (nonatomic, strong) NSDate *callStartTime;

@property (nonatomic, copy) ACETelCallBlock callBlock;
@property (nonatomic, copy) ACETelCancelBlock cancelBlock;
@end

@implementation ACETelPrompt

+ (instancetype)sharedInstance
{
    static ACETelPrompt *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(ACETelCallBlock)callBlock
                 cancel:(ACETelCancelBlock)cancelBlock
{
    if ([self validPhone:phoneNumber]) {
        
        ACETelPrompt *telPrompt = [ACETelPrompt sharedInstance];
        
        // observe the app notifications
        [telPrompt setNotifications];
        
        // set the blocks
        telPrompt.callBlock = callBlock;
        telPrompt.cancelBlock = cancelBlock;
        
        // clean the phone number
        NSString *simplePhoneNumber =
        [[phoneNumber componentsSeparatedByCharactersInSet:
          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        // call the phone number using the telprompt scheme
        NSString *stringURL = [@"telprompt://" stringByAppendingString:simplePhoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
        
        return YES;
    }
    return NO;
}

+ (BOOL)validPhone:(NSString*) phoneString
{
    NSTextCheckingType type = [[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, phoneString.length)
                                                                            phoneNumber:phoneString] resultType];
    return type == NSTextCheckingTypePhoneNumber;
}


#pragma mark - Notifications

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}


#pragma mark - Events

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // save the time of the call
    self.callStartTime = [NSDate date];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // now it's time to remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.callStartTime != nil) {
        
        // I'm coming back after a call
        if (self.callBlock != nil) {
            self.callBlock(-([self.callStartTime timeIntervalSinceNow]) - kCallSetupTime);
        }
        
        // reset the start timer
        self.callStartTime = nil;
    
    } else if (self.cancelBlock != nil) {
        
        // user didn't start the call
        self.cancelBlock();
    }
}

@end
