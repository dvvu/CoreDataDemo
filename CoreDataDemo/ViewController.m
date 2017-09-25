//
//  ViewController.m
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "Contact+CoreDataClass.h"
#import "ResultTableViewController.h"
#import "ThreadSafeForMutableArray.h"
#import "AddContactViewController.h"
#import "ContactTableViewCell.h"
#import "CoreData/CoreData.h"
#import "CoreDataManager.h"
#import "ViewController.h"
#import "ImageSupporter.h"
#import "ContactCache.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "Masonry.h"

@interface ViewController () <NITableViewModelDelegate, UISearchResultsUpdating, UITableViewDelegate>

@property (nonatomic) ResultTableViewController* searchResultTableViewController;
@property (nonatomic) NSArray<Contact*>* contacts;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) dispatch_queue_t imageCahceQueue;
@property (nonatomic) NIMutableTableViewModel* model;
@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) int pageNumber;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"Contacts"];
    [self setupLayout];
    [self setupBarButton];
    [self createSearchController];
    [self setupTableMode];
    [self loadDataFromCoreData];
}

#pragma mark - setupLayout

- (void)setupLayout {

    _pageNumber = 0;
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
    
    _contacts = [[NSArray alloc] init];
    _contactQueue = dispatch_queue_create("CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    _imageCahceQueue = dispatch_queue_create("IMAGE_CAHCES_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    [[CoreDataManager sharedInstance] initSettingWithCoreDataName:@"CoreDataDemo" sqliteName:@"CoreDataDemoSqlite"];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _tableView.delegate = self;
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_needReload) {
        
        [self loadDataFromCoreData];
    }
}

#pragma mark - loadDataFromCoreData

- (void)loadDataFromCoreData {
    
    [[CoreDataManager sharedInstance] getEntityWithClass:CONTACT condition:nil success:^(NSArray* results) {
        
        _contacts = results;
        [self setupData];
    } failed:^(NSError* error) {
        
        NSLog(@"%@",error);
    }];
}

#pragma mark - setupData

- (void)setupData {
    
    dispatch_async(_contactQueue, ^ {
        
        __block NSString* groupNameContact = @"";
        _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
        [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
        
        [_contacts enumerateObjectsUsingBlock:^(Contact* _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString* nameString = [NSString stringWithFormat:@"%@ %@",[contact firstName], [contact lastName]];
            NSString* name = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = @"";
            
            if ([name length] > 0) {
                
                firstChar = [name substringToIndex:1];
            } else {
                
                firstChar = [[contact phoneNumber] substringToIndex:1];
            }
            
            if ([groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                
                groupNameContact = [groupNameContact stringByAppendingString:firstChar.uppercaseString];
            }
        }];
        
        int characterGroupNameCount = (int)[groupNameContact length];

        [_contacts enumerateObjectsUsingBlock:^(Contact* _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx < characterGroupNameCount) {
                
                [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(idx,1)].uppercaseString];
            }
            
            NSString* nameString = [NSString stringWithFormat:@"%@ %@",[contact firstName] ? [contact firstName ]:@"", [contact lastName] ? [contact lastName ]:@""];
            NSString* name = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = @"";
            
            if ([name length] > 0) {
                
                firstChar = [name substringToIndex:1];
            } else if ([contact phoneNumber]) {
                
                firstChar = [[contact phoneNumber] substringToIndex:1];
            }
            
            NSRange range = [groupNameContact rangeOfString:firstChar.uppercaseString];
            
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                
                cellObject.firstName = [contact firstName] ? [contact firstName] : @"";
                cellObject.lastName = [contact lastName] ? [contact lastName] : @"";
                cellObject.identifier = [contact identifier];
                cellObject.phoneNumber = [contact phoneNumber];
                cellObject.company = [contact company];
                NSLog(@"i: %@",cellObject.identifier);
                
                NSString* lastChar = @"";
                
                if ([cellObject.lastName length] > 0) {
                    
                    lastChar = [cellObject.lastName substringToIndex:1];
                }
                
                NSString* nameDefault = [NSString stringWithFormat:@"%@%@",firstChar,lastChar];
                cellObject.image = [[ImageSupporter sharedInstance] profileImageDefault:nameDefault];
                [_model addObject:cellObject toSection:range.location];
            }
        }];
        
        [_model updateSectionIndex];
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
    
    ContactCellObject* object = [_model objectAtIndexPath:indexPath];
    
    UITableViewRowAction* eidtButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
        
        [tableView setEditing:NO];
        AddContactViewController* addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
        [self.navigationController pushViewController:addContactViewController animated:YES];
        addContactViewController.contact = object;
    }];
    
    eidtButton.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction* deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
        
        [tableView setEditing:NO];
        
        NSPredicate* predicate = [[CoreDataManager sharedInstance] setPredicateEqualWithSearchKey:@"identifier" searchValue:[object identifier]];
        
        [[CoreDataManager sharedInstance] getEntityWithClass:CONTACT condition:predicate success:^(NSArray* results) {
            
             // delete entity
            Contact* deletedContact = results[0];
          
            if (deletedContact) {
             
                [[CoreDataManager sharedInstance] deleteWithEntity:deletedContact];
                [[ImageSupporter sharedInstance] removeImageFromFolder:[object identifier]];
                
                [[ContactCache sharedInstance] removeImageForKey:[object identifier] completionWith:^{
                    
                    [self loadDataFromCoreData];
                }];
            }
         } failed:^(NSError* error) {
             
             NSLog(@"%@",error);
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
    
    if (_contacts.count > 0 && ![[_contacts objectAtIndex:0] managedObjectContext]) {
     
        [[CoreDataManager sharedInstance] getEntityWithClass:CONTACT condition:nil success:^(NSArray* results) {
            
            _contacts = results;
            
            if (searchString.length > 0) {
                
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR lastName contains[cd] %@ OR phoneNumber contains[cd] %@ OR company contains[cd] %@", searchString, searchString, searchString, searchString];
                
                NSArray<Contact*>* contacts = [_contacts filteredArrayUsingPredicate:predicate];
                
                if (contacts) {
                    
                    [_searchResultTableViewController repareData:contacts];
                }
            }
            
        } failed:^(NSError* error) {
            
            NSLog(@"%@",error);
        }];
    } else {
        
        if (searchString.length > 0) {
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR lastName contains[cd] %@ OR phoneNumber contains[cd] %@ OR company contains[cd] %@", searchString, searchString, searchString, searchString];
            
            NSArray<Contact*>* contacts = [_contacts filteredArrayUsingPredicate:predicate];
            
            if (contacts) {
                
                [_searchResultTableViewController repareData:contacts];
            }
        }
    }
}

#pragma mark - Nimbus tableViewDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    ContactTableViewCell* contactTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    
    if (contactTableViewCell.model != object) {
        
        ContactCellObject* cellObject = (ContactCellObject *)object;
        contactTableViewCell.identifier = cellObject.identifier;
        [contactTableViewCell setModel:object];
        [cellObject getImageCacheForCell:contactTableViewCell];
        [contactTableViewCell shouldUpdateCellWithObject:object];
        
        int numberItem = 0;
      
        for (int i = 0; i < indexPath.section; i++) {
            
            numberItem += [tableView numberOfRowsInSection:i];
        }
        numberItem += indexPath.row;
        
        if (numberItem > _pageNumber * 10) {
            
        }
    }
    
    return contactTableViewCell;
}

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // action click to call contact cell.
    ContactCellObject* cellObject = [_model objectAtIndexPath:indexPath];
    
    if (cellObject.phoneNumber) {
        
        [[[UIAlertView alloc] initWithTitle:@"Do you want to call?" message: cellObject.phoneNumber delegate:self cancelButtonTitle:@"Call" otherButtonTitles:@"Close", nil] show];
    }
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

@end
