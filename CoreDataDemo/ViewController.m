//
//  ViewController.m
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ContactEntities+CoreDataClass.h"
#import "ResultTableViewController.h"
#import "ThreadSafeForMutableArray.h"
#import "AddContactViewController.h"
#import "ContactsStoreManager.h"
#import "ContactTableViewCell.h"
#import "CoreData/CoreData.h"
#import "ViewController.h"
#import "ContactCache.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "Masonry.h"

@interface ViewController () <NITableViewModelDelegate, UISearchResultsUpdating, UITableViewDelegate>

@property (nonatomic) ResultTableViewController* searchResultTableViewController;
@property (nonatomic) ContactsStoreManager* contactsStoreManager;
@property (nonatomic) NSArray<ContactEntities*>* contactEntites;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) NIMutableTableViewModel* model;
@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic) UITableView* tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"Contacts"];
    [self setupLayout];
    [self setupBarButton];
    [self createSearchController];
    [self setupTableMode];
    [self setupData];
}

#pragma mark - setupLayout

- (void)setupLayout {

    _tableView = [[UITableView alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(0, -7, 0, 0);
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_searchBarView.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _contactQueue = dispatch_queue_create("CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    _contactsStoreManager = [ContactsStoreManager sharedInstance];
    [_contactsStoreManager initializeCoreDataURLForResource:@"" andNameTable:@""];
//    [_contactsStoreManager clearCoreData:CONTACTENTITIES];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _tableView.delegate = self;
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:YES showsSummary:NO];
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_needReload) {
        
        [self setupData];
    }
}

#pragma mark - setupData

- (void)setupData {
    
    dispatch_async(_contactQueue, ^ {
        
        _contactEntites = [[NSArray alloc] init];
        _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
        _contactEntites = [_contactsStoreManager getObjectsFromTable:CONTACTENTITIES];
        
        int contacts = (int)_contactEntites.count;
        
        if (contacts > 0) {
            
            NSString* groupNameContact = @"";
            
            // Run on background to get name group
            for (int i = 0; i < contacts; i++) {
                
                ContactEntities* contactEntity = [_contactEntites objectAtIndex:i];
                NSString* nameString = [NSString stringWithFormat:@"%@ %@",contactEntity.firstName, contactEntity.lastName];
                NSString* name = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* firstChar = @"";
                
                if ([name length] > 0) {
                    
                    firstChar = [name substringToIndex:1];
                } else {
                    
                    firstChar = [contactEntity.phoneNumber substringToIndex:1];
                }
                
                if ([groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                    
                    groupNameContact = [groupNameContact stringByAppendingString:firstChar.uppercaseString];
                }
            }
            
            int characterGroupNameCount = (int)[groupNameContact length];
            
            // Run on background to get object
            for (int i = 0; i < contacts; i++) {
                
                if (i < characterGroupNameCount) {
                    
                    [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(i,1)].uppercaseString];
                }
                
                ContactEntities* contactEntity = [_contactEntites objectAtIndex:i];

                NSString* nameString = [NSString stringWithFormat:@"%@ %@",contactEntity.firstName ? contactEntity.firstName:@"", contactEntity.lastName ? contactEntity.lastName:@""];
                NSString* name = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* firstChar = @"";
                
                if ([name length] > 0) {
                    
                    firstChar = [name substringToIndex:1];
                } else {
                    
                    firstChar = [contactEntity.phoneNumber substringToIndex:1];
                }
                
                NSRange range = [groupNameContact rangeOfString:firstChar.uppercaseString];
                
                if (range.location != NSNotFound) {
                    
                    ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                    
                    cellObject.firstName = [contactEntity firstName] ? [contactEntity firstName] : @"";
                    cellObject.lastName = [contactEntity lastName] ? [contactEntity lastName] : @"";
                    cellObject.identifier = [contactEntity identifier];
                    cellObject.phoneNumber = [contactEntity phoneNumber];
                    cellObject.company = [contactEntity company];
                    NSLog(@"i: %@",cellObject.identifier);
                    
                    NSString* lastChar = @"";
                    
                    if ([cellObject.lastName length] > 0) {
                        
                        lastChar = [cellObject.lastName substringToIndex:1];
                    }
                    
                    NSString* nameDefault = [NSString stringWithFormat:@"%@%@",firstChar,lastChar];
                    cellObject.contactImage = [ViewController profileImageDefault:nameDefault];
                    [_model addObject:cellObject toSection:range.location];
                }
            }
            
            [_model updateSectionIndex];
        }
        
        _tableView.dataSource = _model;
        
        // Run on main Thread
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [_tableView reloadData];
            _needReload = NO;
        });
    });
}

#pragma mark - Create searchBar

- (void)createSearchController {
    
    _searchResultTableViewController = [[ResultTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultTableViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.dimsBackgroundDuringPresentation = YES;
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor blackColor]];
    [_searchBarView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
}

#pragma mark - setupBarButton

- (void)setupBarButton {
    
    UIButton* addContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addContactButton setFrame:CGRectMake(0, 0, 20, 20)];
    [addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    [addContactButton setShowsTouchWhenHighlighted:YES];
    [addContactButton setImage:[UIImage imageNamed:@"ic_addContact"] forState:UIControlStateNormal];
    [addContactButton setImage:[UIImage imageNamed:@"ic_redAddContact"] forState:UIControlStateHighlighted];
    UIBarButtonItem* addContactBarButton = [[UIBarButtonItem alloc] initWithCustomView:addContactButton];
    self.navigationItem.rightBarButtonItem = addContactBarButton;
}

#pragma mark - addContact

- (IBAction)addContact:(id)sender {
    
    AddContactViewController* addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

#pragma mark - NIMutableTableViewModelDelegate

- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    
    return YES;
}

#pragma mark - NIMutableTableViewModelDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [_model objectAtIndexPath:indexPath];
    ContactEntities* contactEntities = (ContactEntities *)object;
    
    UITableViewRowAction* eidtButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
        
        [tableView setEditing:NO];
        AddContactViewController* addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
        [self.navigationController pushViewController:addContactViewController animated:YES];
        addContactViewController.contactEntities = contactEntities;
    }];
    
    eidtButton.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction* deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
        
        [tableView setEditing:NO];
        [_contactsStoreManager deleteObject:contactEntities fromTable:CONTACTENTITIES];
        
        [[ContactCache sharedInstance] removeImageForKey:[contactEntities identifier] completionWith:^{
          
            [self setupData];
        }];
    }];
    
    return @[deleteAction, eidtButton];
}

#pragma mark - heigh for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    id object = [_model objectAtIndexPath:indexPath];
    id class = [object cellClass];
    
    if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
        
        height = [class heightForObject:object atIndexPath:indexPath tableView:tableView];
    }
    
    return height;
}

#pragma mark - updateSearchResultViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString* searchString = searchController.searchBar.text;
    
    if (_contactEntites.count > 0 && ![[_contactEntites objectAtIndex:0] managedObjectContext]) {
     
        _contactEntites = [_contactsStoreManager getObjectsFromTable:CONTACTENTITIES];
    }
    
    if (searchString.length > 0) {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR lastName contains[cd] %@ OR phoneNumber contains[cd] %@ OR company contains[cd] %@", searchString, searchString, searchString, searchString];
        
        NSArray<ContactEntities*>* contactEntities = [_contactEntites filteredArrayUsingPredicate:predicate];
        
        if (contactEntities) {
            
            [_searchResultTableViewController repareData:contactEntities];
        }
    }
}

#pragma mark - Nimbus tableViewDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    ContactTableViewCell* contactTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    
    if (contactTableViewCell.model != object) {
        
        ContactCellObject* cellObject = (ContactCellObject *)object;
        contactTableViewCell.identifier = cellObject.identifier;
        contactTableViewCell.model = object;
        [cellObject getImageCacheForCell:contactTableViewCell];
        [contactTableViewCell shouldUpdateCellWithObject:object];
    }
    
    return contactTableViewCell;
}

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
}

#pragma mark - profileImageDefault

+ (UIImage *)profileImageDefault:(NSString *)textNameDefault {
    
    // Size image
    int imageWidth = 100;
    int imageHeight =  100;
    
    // Rect for image
    CGRect rect = CGRectMake(0,0,imageHeight,imageHeight);
    
    // setup text
    UIFont* font = [UIFont systemFontOfSize: 50];
    CGSize textSize = [textNameDefault.uppercaseString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50]}];
    NSMutableAttributedString* nameAttString = [[NSMutableAttributedString alloc] initWithString:textNameDefault.uppercaseString];
    NSRange range = NSMakeRange(0, [nameAttString length]);
    [nameAttString addAttribute:NSFontAttributeName value:font range:range];
    [nameAttString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
    
    // Create image
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    UIColor* fillColor = [UIColor lightGrayColor];
    
    // Begin ImageContext Options
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(rect.size);
    
    //  Draw Circle image
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    
    // Draw text
    [nameAttString drawInRect:CGRectIntegral(CGRectMake(imageWidth/2 - textSize.width/2, imageHeight/2 - textSize.height/2, imageWidth, imageHeight))];
    UIImage* profileImageDefault = UIGraphicsGetImageFromCurrentImageContext();
    
    // End ImageContext
    UIGraphicsEndImageContext();
    
    // End ImageContext Options
    UIGraphicsEndImageContext();
    
    return profileImageDefault;
}

@end
