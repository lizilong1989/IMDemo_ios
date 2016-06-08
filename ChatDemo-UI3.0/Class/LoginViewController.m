/************************************************************
  *  * Hyphenate CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Inc.
  */

#import "LoginViewController.h"
#import "EMError.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UISwitch *useIpSwitch;

- (IBAction)doRegister:(id)sender;
- (IBAction)doLogin:(id)sender;
- (IBAction)useIpAction:(id)sender;

@end

@implementation LoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize registerButton = _registerButton;
@synthesize loginButton = _loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupForDismissKeyboard];
    _usernameTextField.delegate = self;
    _passwordTextField.delegate = self;
    
    NSString *username = [self lastLoginUsername];
    if (username && username.length > 0) {
        _usernameTextField.text = username;
    }
    
    self.title = NSLocalizedString(@"AppName", @"EaseMobDemo");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Registered account
- (IBAction)doRegister:(id)sender {
    if (![self isEmpty]) {
        //Hide keyborad
        [self.view endEditing:YES];
        //To determine whether it is Chinese, but does not support in English and Chinese mixed
        if ([self.usernameTextField.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient] asyncRegisterWithUsername:self.usernameTextField.text password:self.passwordTextField.text success:^{
            [weakself hideHud];
            TTAlertNoTitle(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
        } failure:^(EMError *aError) {
            [weakself hideHud];
            switch (aError.code) {
                case EMErrorServerNotReachable:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                    break;
                case EMErrorUserAlreadyExist:
                    TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                    break;
                case EMErrorNetworkUnavailable:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                    break;
                case EMErrorServerTimeout:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                    break;
                default:
                    TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
                    break;
            }
        }];
    }
}

//Click the button for login
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    //Asynchronous to login
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] asyncLoginWithUsername:username password:password success:^{
        //Set whether autologin or not
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        
        //Get data from database
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EMClient sharedClient] dataMigrationTo3];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ChatDemoHelper shareHelper] asyncGroupFromServer];
                [[ChatDemoHelper shareHelper] asyncConversationFromDB];
                [[ChatDemoHelper shareHelper] asyncPushOptions];
                [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
                //Send notification for state of login
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
                
                //Save the username for last login
                [weakself saveLastLoginUsername];
            });
        });
    } failure:^(EMError *aError) {
        switch (aError.code)
        {
            case EMErrorUserNotFound:
                TTAlertNoTitle(aError.errorDescription);
                break;
            case EMErrorNetworkUnavailable:
                TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                break;
            case EMErrorServerNotReachable:
                TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                break;
            case EMErrorUserAuthenticationFailed:
                TTAlertNoTitle(aError.errorDescription);
                break;
            case EMErrorServerTimeout:
                TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                break;
            default:
                TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                break;
        }
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        //Get text from textfield
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        if(nameTextField.text.length > 0)
        {
            //set nickname for apns
            [[EMClient sharedClient] asyncSetApnsNickname:nameTextField.text success:^{} failure:^(EMError *aError) {}];
        }
    }
    //login
    [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
}

//Login with username
- (IBAction)doLogin:(id)sender {
    if (![self isEmpty]) {
        [self.view endEditing:YES];
        //does not support Chinese
        if ([self.usernameTextField.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
    }
}

- (IBAction)useIpAction:(id)sender
{
//    UISwitch *ipSwitch = (UISwitch *)sender;
//    [[EMClient sharedClient].options setEnableDnsConfig:ipSwitch.isOn];
}

//If empty with username or password
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password")
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return ret;
}


#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _usernameTextField) {
        _passwordTextField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameTextField) {
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [self doLogin:nil];
    }
    return YES;
}

#pragma  mark - private
- (void)saveLastLoginUsername
{
    NSString *username = [[EMClient sharedClient] currentUsername];
    if (username && username.length > 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:username forKey:[NSString stringWithFormat:@"em_lastLogin_username"]];
        [ud synchronize];
    }
}

- (NSString*)lastLoginUsername
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:[NSString stringWithFormat:@"em_lastLogin_username"]];
    if (username && username.length > 0) {
        return username;
    }
    return nil;
}

@end
