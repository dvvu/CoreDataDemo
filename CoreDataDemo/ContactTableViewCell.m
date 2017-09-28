//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "Masonry.h"

#define CELLHEIGHT 70

@interface ContactTableViewCell ()

@property (nonatomic) UIAttachmentBehavior* springBehavior;
@property (nonatomic) UIDynamicAnimator* dynamicAnimator;
@property (nonatomic) UIView* containView;

@end

@implementation ContactTableViewCell

#pragma mark - initWithStyle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    if (self) {
    
        [self setupLayoutForCell];
    }
    
    return self;
}

#pragma mark - initWithCoder

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self setupLayoutForCell];
    }
    
    return self;
}

#pragma mark - delegate oif NICell -> change when something is changed in cell

- (BOOL)shouldUpdateCellWithObject:(id<ContactModelProtocol>)object {

    _nameLabel.text = [NSString stringWithFormat:@"%@ %@",object.firstName, object.lastName];
    _profileImageView.image = object.contactImage;
    _phoneNumber.text = object.phoneNumber;
    _company.text = object.company;
    return YES;
}

#pragma mark - animateBounce

- (void)animateBounce:(CGPoint)touchLocation withOrientation:(ScrollOrientation)orienatation {
    
    if (![[_dynamicAnimator behaviors] containsObject:_springBehavior]) {
        
        [_dynamicAnimator addBehavior:_springBehavior];
    }
    
    CGPoint anchorPoint = self.center;
    
    _springBehavior.anchorPoint = anchorPoint;
    
    CGFloat distanceFromTouch = touchLocation.y - anchorPoint.y;
    CGFloat scrollResistance = distanceFromTouch / 100;
    
    anchorPoint.y += 10 * orienatation * scrollResistance;
    self.center = anchorPoint;
    
    [_dynamicAnimator updateItemUsingCurrentState:self];
}

#pragma mark - setModel

- (void)setModel:(id<ContactModelProtocol>)model {
    
    _model = model;
}

#pragma mark - setupLayoutForCell

- (void)setupLayoutForCell {
    
    if (!_springBehavior) {
        
        _springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:self.center];
        _springBehavior.length = 0;
        _springBehavior.damping = 0.8;
        _springBehavior.frequency = 1;
        
        _dynamicAnimator = [[UIDynamicAnimator alloc] init];
        [_dynamicAnimator addBehavior:_springBehavior];
    }
    
    CGFloat scale = FONTSIZE_SCALE;
    
    _containView = [[UIView alloc] init];
    [_containView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_containView];
    
     _profileImageView = [[UIImageView alloc] init];
    [_containView addSubview:_profileImageView];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setTextColor:[UIColor darkGrayColor]];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:16 * scale]];
    [_containView addSubview:_nameLabel];
    
    _phoneNumber = [[UILabel alloc] init];
    [_phoneNumber setTextColor:[UIColor darkGrayColor]];
    [_phoneNumber setFont:[UIFont systemFontOfSize:11 * scale]];
    [_containView addSubview:_phoneNumber];
    
    _company = [[UILabel alloc] init];
    [_company setTextColor:[UIColor darkGrayColor]];
    [_company setFont:[UIFont systemFontOfSize:12 * scale]];
    [_containView addSubview:_company];
    
    [_containView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 0, 10, 0));
    }];
    
    [_profileImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerY.equalTo(_containView);
        make.left.equalTo(_containView).offset(23);
        make.width.and.height.mas_equalTo(_containView.mas_height);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerY.equalTo(_containView).offset(-10);
        make.left.equalTo(_profileImageView.mas_right).offset(8);
        make.right.equalTo(_containView).offset(-8);
    }];
    
    [_phoneNumber mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_nameLabel.mas_bottom).offset(5);
        make.left.equalTo(_profileImageView.mas_right).offset(8);
        make.right.equalTo(_containView).offset(-8);
    }];
    
    [_company mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerY.equalTo(_containView);
        make.right.equalTo(_containView.mas_right).offset(-8);
    }];
}

#pragma mark - heightForObject NI delegate

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    return CELLHEIGHT;
}

@end
