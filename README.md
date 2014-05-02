# ACETelPrompt

`ACETelPrompt` is an helper to easily make phone call using the telprompt scheme.

Using telprompt first gives a prompt asking whether the user wants to make the call or cancel it. If the user selects the call option from the prompt that is displayed, the call is placed and the control returns back to the app after the call is finished.

The helper uses blocks to get the user choice also logging the phone duration.

## Example Usage

```objective-c
    [ACETelPrompt callPhoneNumber:self.phoneField.text
                             call:^(NSTimeInterval duration) {
                                 NSLog(@"User made a call of %.1f seconds", duration);
                                 
                             } cancel:^{
                                 NSLog(@"User cancelled the call");
                             }];
```

## Cocoapods

1. Add `pod 'ACETelPrompt'` to your Podfile.
2. Run `pod install`

## License

ACETelPrompt is available under the MIT license. See the LICENSE file for more info.
