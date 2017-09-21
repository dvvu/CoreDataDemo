//
//  AddContactViewController.m
//  ContactsWithCoreData
//
//  Created by Doan Van Vu on 9/13/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "AddContactViewController.h"
#import "ImageSupporter.h"
#import "ContactsStoreManager.h"
#import "ViewController.h"
#import "ContactCache.h"
#import "NIInMemoryCache.h"
#import "Constants.h"
#import "Masonry.h"
#import "ZLMImageCache.h"

@interface AddContactViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) ContactsStoreManager* contactsStoreManager;
@property (nonatomic) UITextField* companyNameTextField;
@property (nonatomic) UITextField* phoneNumberTextField;
@property (nonatomic) UITextField* firstNameTextField;
@property (nonatomic) UIScrollView* containScrollView;
@property (nonatomic) UITextField* lastNameTextField;
@property (nonatomic) UIBarButtonItem* doneBarButton;
@property (nonatomic) UIImageView* profileImageView;
@property (nonatomic) UIImageView* phoneImageView;
@property (nonatomic) CGFloat phoneNumberOrginY;
@property (nonatomic) NSURL* profileImageURL;
@property (nonatomic) UIButton* doneButton;
@property (nonatomic) UILabel* phoneLabel;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupLayout];
    [self setupBarButton];
    [self setTitle:@"Add Contacts"];
    
    _contactsStoreManager = [ContactsStoreManager sharedInstance];
    [_contactsStoreManager initializeCoreDataURLForResource:@"CoreDataDemo" andNameTable:CONTACTENTITIES];
    [self setupDataUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - setupLayout

- (void)setupLayout {
    
    _containScrollView = [[UIScrollView alloc] init];
    UITapGestureRecognizer* dismisKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [_containScrollView addGestureRecognizer:dismisKeyboardGesture];
    [self.view addSubview:_containScrollView];
    
    CGFloat scale = FONTSIZE_SCALE;
    
    _profileImageView = [[UIImageView alloc] init];
    _profileImageView.image = [UIImage imageNamed:@"ic_user"];
    _profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* openPickerImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPickerImage:)];
    [_profileImageView addGestureRecognizer:openPickerImageGesture];
    [_containScrollView addSubview:_profileImageView];
    
    _firstNameTextField = [[UITextField alloc] init];
    _firstNameTextField.returnKeyType = UIReturnKeyNext;
    _firstNameTextField.delegate = self;
    [_firstNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_firstNameTextField setPlaceholder:@"first Name"];
    [_containScrollView addSubview:_firstNameTextField];
    
    _lastNameTextField = [[UITextField alloc] init];
    _lastNameTextField.returnKeyType = UIReturnKeyNext;
    _lastNameTextField.delegate = self;
    [_lastNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_lastNameTextField setPlaceholder:@"Last Name"];
    [_containScrollView addSubview:_lastNameTextField];
    
    _companyNameTextField = [[UITextField alloc] init];
    _companyNameTextField.returnKeyType = UIReturnKeyNext;
    _companyNameTextField.delegate = self;
    [_companyNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_companyNameTextField setPlaceholder:@"Company Name"];
    [_containScrollView addSubview:_companyNameTextField];
    
    _phoneNumberTextField = [[UITextField alloc] init];
    _phoneNumberTextField.returnKeyType = UIReturnKeyDone;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneNumberTextField setEnablesReturnKeyAutomatically:YES];
    [_phoneNumberTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_phoneNumberTextField setPlaceholder:@"phone Number"];
    [_phoneNumberTextField addTarget:self action:@selector(phoneTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_containScrollView addSubview:_phoneNumberTextField];
    
    _phoneImageView = [[UIImageView alloc] init];
    _phoneImageView.image = [UIImage imageNamed:@"ic_phone"];
    [_containScrollView addSubview:_phoneImageView];
    
    _phoneLabel = [[UILabel alloc] init];
    [_phoneLabel setFont:[UIFont boldSystemFontOfSize:10 * scale]];
    [_phoneLabel setText:@"Phone number"];
    [_containScrollView addSubview:_phoneLabel];
    
    [_containScrollView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(0);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.height.mas_equalTo(self.view.frame.size.height);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    [_profileImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_containScrollView).offset(5);
        make.left.equalTo(_containScrollView).offset(20);
        make.width.and.height.mas_equalTo(40);
    }];
    
    [_firstNameTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_containScrollView).offset(5);
        make.left.equalTo(_profileImageView.mas_right).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(30);
    }];
    
    [_lastNameTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_firstNameTextField.mas_bottom).offset(8);
        make.left.equalTo(_profileImageView.mas_right).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(30);
    }];
    
    [_companyNameTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_lastNameTextField.mas_bottom).offset(8);
        make.left.equalTo(_profileImageView.mas_right).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(30);
    }];
    
    [_phoneImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_companyNameTextField.mas_bottom).offset(12);
        make.left.equalTo(_containScrollView).offset(20);
        make.height.and.width.mas_equalTo(20);
    }];
    
    [_phoneLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_companyNameTextField.mas_bottom).offset(8);
        make.left.equalTo(_phoneImageView.mas_right).offset(5);
        make.height.mas_equalTo(30);
    }];
    
    [_phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_companyNameTextField.mas_bottom).offset(8);
        make.left.equalTo(_phoneLabel.mas_right).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - setupDataUpdate

- (void)setupDataUpdate {
    
    if (_contactEntities) {
        
        [self setTitle:@"Update Contacts"];
        [_firstNameTextField setText:[_contactEntities firstName]];
        [_lastNameTextField setText:[_contactEntities lastName]];
        [_companyNameTextField setText:[_contactEntities company]];
        [_phoneNumberTextField setText:[_contactEntities phoneNumber]];
        [self phoneTextFieldDidChange:_phoneNumberTextField];
        
        if ([_contactEntities profileImageURL]) {
            
            [[ContactCache sharedInstance] getImageForKey:[_contactEntities identifier] completionWith:^(UIImage* image) {
                
                if (image) {
                    
                    _profileImageView.image = image;
                }
            }];
        }
    }
}

#pragma mark - setupBarButton

- (void)setupBarButton {
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [_doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setShowsTouchWhenHighlighted:YES];
    [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [_doneButton setEnabled:NO];
    _doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:_doneButton];
    [_doneBarButton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = _doneBarButton;
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setShowsTouchWhenHighlighted:YES];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:74/255.f green:158/255.f blue:213/255.f alpha:1.0f] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
}

#pragma mark - done

- (IBAction)done:(id)sender {
    
    if (_contactEntities) {
        
        _contactEntities.firstName = _firstNameTextField.text;
        _contactEntities.lastName = _lastNameTextField.text;
        _contactEntities.phoneNumber = _phoneNumberTextField.text;
        _contactEntities.company = _companyNameTextField.text;
        
        if (_contactEntities.profileImageURL != _profileImageURL.absoluteString) {
            
            _contactEntities.profileImageURL = _profileImageURL.absoluteString;
            
            [[ImageSupporter sharedInstance] getImagePickerwithURL:[NSURL URLWithString:[_contactEntities profileImageURL]] completion:^(UIImage* image) {
                
                if (image) {
                    
                    [[ContactCache sharedInstance] setImageForKey:[[ImageSupporter sharedInstance] resizeImage:[[ImageSupporter sharedInstance] resizeImage:image]] forKey:[_contactEntities identifier]];
                }
            }];
        }
        
        [_contactsStoreManager updateObjec:_contactEntities atTable:CONTACTENTITIES];
    } else {
        
        ContactEntities* contactEntities = [[ContactEntities alloc] initWithContext:_contactsStoreManager.managedObjectContext];
        contactEntities.firstName = _firstNameTextField.text;
        contactEntities.lastName = _lastNameTextField.text;
        contactEntities.phoneNumber = _phoneNumberTextField.text;
        contactEntities.company = _companyNameTextField.text;
        contactEntities.identifier = [[NSUUID UUID] UUIDString];
        contactEntities.profileImageURL = _profileImageURL.absoluteString;
        [_contactsStoreManager addObject:contactEntities toTable:CONTACTENTITIES];
        
        if (_profileImageURL.absoluteString) {
            
            [[ImageSupporter sharedInstance] getImagePickerwithURL:_profileImageURL completion:^(UIImage* image) {
                
                if (image) {
                    
                    [[ContactCache sharedInstance] setImageForKey:[[ImageSupporter sharedInstance] resizeImage:[[ImageSupporter sharedInstance] resizeImage:image]] forKey:contactEntities.identifier];
                }
            }];
        }
    }
    
    ViewController* viewController = (ViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    viewController.needReload = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - openPickerImage

- (void)openPickerImage:(id)sender {
    
    [self dismisKeyboard];
    
    [[ImageSupporter sharedInstance] checkPermissionPhoto:^(NSString* errorString) {
        
        if (!errorString) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
}

#pragma mark - imagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* chosenImage = info[UIImagePickerControllerEditedImage];
    _profileImageURL = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    _profileImageView.image = [[ImageSupporter sharedInstance] makeRoundImage:[[ImageSupporter sharedInstance] resizeImage:chosenImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - imagePickerControllerDidCancel

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - dismissKeyboard

- (void)dismissKeyboard:(id)sender {
    
    [self dismisKeyboard];
}

#pragma mark - dismissKeyboard

- (void)dismisKeyboard {
    
    [_firstNameTextField resignFirstResponder];
    [_lastNameTextField resignFirstResponder];
    [_companyNameTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
}

#pragma mark - search

- (IBAction)cancel:(id)sender {
    
   [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - textFieldShouldReturn

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == _firstNameTextField) {
        
        [_lastNameTextField becomeFirstResponder];
        return NO;
    } else if (textField == _lastNameTextField) {
        
        [_companyNameTextField becomeFirstResponder];
    } else if (textField == _companyNameTextField) {
    
        [_phoneNumberTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - startTextFieldDidChange

- (void)phoneTextFieldDidChange:(UITextField*)textField {
    
    NSString* phoneString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([phoneString length] > 0) {
        
        [_doneBarButton setEnabled:YES];
        [_doneButton setTitleColor:[UIColor colorWithRed:74/255.f green:158/255.f blue:213/255.f alpha:1.0f] forState:UIControlStateNormal];
    } else {
        
        [_doneBarButton setEnabled:NO];
        [_doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

#pragma mark - keyboardWillHide

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _phoneNumberOrginY = [_phoneNumberTextField convertRect:self.view.bounds toView:nil].origin.y + 35;
    [_containScrollView  mas_updateConstraints:^(MASConstraintMaker* make) {
        
        make.height.mas_equalTo(_phoneNumberOrginY);
        make.width.mas_equalTo(self.view.frame.size.width);
    }];
    
    [self.view layoutIfNeeded];
    [_containScrollView layoutIfNeeded];
    _containScrollView.contentSize = _containScrollView.frame.size;
}

#pragma mark - keyboardWillShow

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _phoneNumberOrginY = [_phoneNumberTextField convertRect:self.view.bounds toView:nil].origin.y + 35;
    
    NSLog(@"%f ---- %f", _phoneNumberOrginY, kbSize.height);
    
    if (self.view.frame.size.height > _phoneNumberOrginY + kbSize.height) {
        
        [_containScrollView  mas_updateConstraints:^(MASConstraintMaker* make) {
            
            make.height.mas_equalTo(self.view.frame.size.height - kbSize.height);
            make.width.mas_equalTo(self.view.frame.size.width);
        }];
        [self.view layoutIfNeeded];
        [_containScrollView layoutIfNeeded];
        _containScrollView.contentSize = CGSizeMake(0,0);
    } else {
        
        [_containScrollView  mas_updateConstraints:^(MASConstraintMaker* make) {
            
            make.height.mas_equalTo(self.view.frame.size.height - kbSize.height);
            make.width.mas_equalTo(self.view.frame.size.width);
        }];
        
        [self.view layoutIfNeeded];
        [_containScrollView layoutIfNeeded];
        _containScrollView.contentSize = _containScrollView.frame.size;
    }
}

@end
