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
#import "QuartzCore/QuartzCore.h"

@interface ViewController () <NITableViewModelDelegate, UISearchResultsUpdating, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic) ResultTableViewController* searchResultTableViewController;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) __block NSString* groupNameContact;
@property (nonatomic) dispatch_queue_t imageCahceQueue;
@property (nonatomic) NIMutableTableViewModel* model;
@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic) NSArray<Contact*>* contacts;
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
    _groupNameContact = @"";
    _tableView = [[UITableView alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(0, -7, 0, 0);
    _tableView.showsVerticalScrollIndicator = YES;
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
    
    [[CoreDataManager sharedInstance] initWithCoreDataName:@"CoreDataDemo" andSqliteName:@"CoreDataDemoSQLite"];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _tableView.delegate = self;
    
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
//    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
    [_tableView setShowsVerticalScrollIndicator:YES];
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_needReload) {
        
        _pageNumber = 0;
        _groupNameContact = @"";
        _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
//        [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
        [_tableView setShowsVerticalScrollIndicator:YES];
        [self loadDataFromCoreData];
    }
}

#pragma mark - loadDataFromCoreData

- (void)loadDataFromCoreData {
    
    [[CoreDataManager sharedInstance] getEntitiesFromClass:CONTACT withCondition:nil maximumEntities:PAGEITEMS fromIndex:_pageNumber * PAGEITEMS callbackQueue:_contactQueue success:^(NSArray* results) {
        
        [results enumerateObjectsUsingBlock:^(Contact* _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString* nameString = [NSString stringWithFormat:@"%@ %@",[contact firstName], [contact lastName]];
            NSString* name = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = @"";
            
            if ([name length] > 0) {
                
                firstChar = [name substringToIndex:1];
            } else {
                
                firstChar = [[contact phoneNumber] substringToIndex:1];
            }
            
            if ([_groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                
                _groupNameContact = [_groupNameContact stringByAppendingString:firstChar.uppercaseString];
                [_model addSectionWithTitle:firstChar.uppercaseString];
            }
            
            NSRange range = [_groupNameContact rangeOfString:firstChar.uppercaseString];
            
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                
                cellObject.firstName = [contact firstName] ? [contact firstName] : @"";
                cellObject.lastName = [contact lastName] ? [contact lastName] : @"";
                cellObject.identifier = [contact identifier];
                cellObject.phoneNumber = [contact phoneNumber];
                cellObject.company = [contact company];
                NSString* lastChar = @"";
                
                if ([cellObject.lastName length] > 0) {
                    
                    lastChar = [cellObject.lastName substringToIndex:1];
                }
                
                NSString* nameDefault = [NSString stringWithFormat:@"%@%@",firstChar,lastChar];
                cellObject.contactImage = [[ImageSupporter sharedInstance] profileImageDefault:nameDefault];//[UIImage imageNamed:@"ic_userDefault"];
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
    } failed:^(NSError* error) {
        
        NSLog(@"%@",error);
    }];
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
        NSPredicate* predicate = [[CoreDataManager sharedInstance] setConditonWithSearchKey:@"identifier" searchValue:[object identifier]];
        
        [[CoreDataManager sharedInstance] getEntitiesFromClass:CONTACT withCondition:predicate callbackQueue:nil success:^(NSArray* results) {
            
             // delete entity
            Contact* deletedContact = results[0];
          
            if (deletedContact) {
             
                [[CoreDataManager sharedInstance] deleteEntity:deletedContact];
                [[ImageSupporter sharedInstance] removeImageFromFolder:[object identifier]];
                [[ContactCache sharedInstance] removeImageForKey:[object identifier] completionWith:nil];
                [_model removeObjectAtIndexPath:indexPath];
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                
                if ([_tableView numberOfRowsInSection:indexPath.section] == 0) {
                    
                    [_model removeSectionAtIndex:indexPath.section];
                    [_tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                [_tableView reloadData];
                [_model updateSectionIndex];
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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR lastName contains[cd] %@ OR phoneNumber contains[cd] %@ OR company contains[cd] %@", searchString, searchString, searchString, searchString];
    
    [[CoreDataManager sharedInstance] getEntitiesFromClass:CONTACT withCondition:predicate callbackQueue:nil success:^(NSArray* results) {
        
        [_searchResultTableViewController repareData:results];
    } failed:^(NSError* error) {
        
        NSLog(@"%@",error);
    }];
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
    }
    
    return contactTableViewCell;
}

#pragma mark - loadMoreContact

- (void)loadMoreContact:(NSIndexPath *)indexPath {
 
    int numberItem = 0;
    
    for (int i = 0; i < indexPath.section; i++) {
        
        numberItem += [_tableView numberOfRowsInSection:i];
    }
    numberItem += indexPath.row;
    
    if (numberItem >= (_pageNumber + 1) * PAGEITEMS - 1) {
        
        _pageNumber++;
        [self loadDataFromCoreData];
    }
    NSLog(@"%d",numberItem);
}

#pragma mark - willDisplayCell

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self loadMoreContact:indexPath];
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
        
        [self showMessage:cellObject.phoneNumber withTitle:@"Do you want to call?"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - showMessage

- (void)showMessage:(NSString*)message withTitle:(NSString *)title {
    
    if ([UIAlertController class]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* settingButton = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:message]]];
        }];
        
        UIAlertAction* closeButton = [UIAlertAction actionWithTitle:@"CLOSE" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:settingButton];
        [alert addAction:closeButton];
        
        UIViewController* vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alert animated:YES completion:nil];
    } else {
        
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Call" otherButtonTitles:@"Close", nil] show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // gotosetting
    if (buttonIndex == 0) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:alertView.message]]];
    }
}

@end
