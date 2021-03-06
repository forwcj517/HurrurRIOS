//
//  OrderFrameExpand.m
//  Logistika
//
//  Created by BoHuang on 7/11/18.
//  Copyright © 2018 BoHuang. All rights reserved.
//

#import "OrderFrameExpand.h"
#import "CGlobal.h"
#import "ReviewCameraTableViewCell.h"
#import "ReviewItemTableViewCell.h"
#import "ReviewPackageTableViewCell.h"
#import "NetworkParser.h"
#import "TopBarView.h"
#import "AppDelegate.h"
#import "TrackMapViewController.h"
#import "OrderTableViewCell.h"
#import "RescheduleDateInput.h"
#import "Logistika-Swift.h"

@implementation OrderFrameExpand

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)clickEntire:(id)sender {
    if (self.aDelegate) {
        [self.aDelegate didSubmit:self.original_data View:self];
    }
}


-(void)firstProcess:(NSDictionary*)data{
    self.original_data =data;
    self.vc = data[@"vc"];
    self.aDelegate = data[@"aDelegate"];
    self.data = data[@"model"];
    
    OrderHisModel* model = data[@"model"];
    self.lblTracking.text = model.trackId;
    self.lblOrderNumber.text = model.orderId;
    
    NSDictionary* pred_str = @{@"step1":@"Associated ",
                               @"step2":@"Order Picked up & in\ntransit to drop off ",
                               @"order_delivered":@"Order Delivered ",
                               @"order_on_hold":@"Order On Hold ",
                               @"order_returned":@"Order Returned ",
                               @"associate":@"Associate on the \n way",
                               @"pickup_cancelled":@"Pickup Cancelled",
                               };
    self.lblStat1.text = pred_str[@"associate"];
    self.lblStat2.text = pred_str[@"step2"];
    self.lblStat3.text = pred_str[@"order_returned"];
    
    int state = [model.state intValue];
    _btnPos.hidden = true;
    _btnCancel.hidden = true;
    _btnReschedule.hidden = true;
    switch (state) {
        case 1:{
            _lblStatus.text = @"In Process";
            self.imgStep.image = [UIImage imageNamed:@"step_inprogress.png"];
            self.btnPos.hidden = true;
            self.lblStat3.text = pred_str[@"order_delivered"];
            
            _btnCancel.hidden = false;
            _btnReschedule.hidden = false;
            break;
        }
        case 0:
        {
            _lblStatus.text = @"Order Cancel";
            self.imgStep.image = [UIImage imageNamed:@"step_cancel1.png"];
            self.btnPos.hidden = true;
            self.lblStat1.text = [@"   " stringByAppendingString:pred_str[@"pickup_cancelled"]];
            self.lblStat2.text = @"";
            self.lblStat3.text = @"";
            break;
        }
        case 2:
        {
            _lblStatus.text = @"Associate on the way for pickup";
            self.imgStep.image = [UIImage imageNamed:@"step1.png"];
            self.btnPos.hidden = true;
            self.lblStat3.text = pred_str[@"order_delivered"];
            _btnPos.hidden = false;
            break;
        }
        case 3:
        {
            _lblStatus.text = @"On the way to destination";
            self.imgStep.image = [UIImage imageNamed:@"step2.png"];
            self.lblStat3.text = pred_str[@"order_delivered"];
            _btnPos.hidden = false;
            break;
        }
        case 4:
        {
            _lblStatus.text = @"Order Delivered";
            self.btnPos.hidden = true;
            self.imgStep.image = [UIImage imageNamed:@"step3.png"];
            self.lblStat3.text = pred_str[@"order_delivered"];
            break;
        }
        case 5:
        {
            _lblStatus.text = @"Order on hold";
            self.imgStep.image = [UIImage imageNamed:@"step_onhold.png"];
            self.lblStat3.text = pred_str[@"order_on_hold"];
            _btnPos.hidden = false;
            break;
        }
        case 6:
        {
            _lblStatus.text = @"Returned Order";
            self.btnPos.hidden = true;
            self.imgStep.image = [UIImage imageNamed:@"step_return.png"];
            self.lblStat3.text = pred_str[@"order_returned"];
            break;
        }
        default:
            break;
    }
    
    if (model.addressModel.desAddress!=nil) {
        _lblPickName.text = model.addressModel.sourceName;
        _lblPickAddress.text = model.addressModel.sourceAddress;
        _lblPickLandMark.text = model.addressModel.sourceLandMark;
        _lblPickPhone.text = model.addressModel.sourcePhonoe;
        _lblPickInst.text = model.addressModel.sourceInstruction;
        
        
        _lblDestName.text = model.addressModel.desName;
        _lblDestAddress.text = model.addressModel.desAddress;
        _lblDestLandMark.text = model.addressModel.desLandMark;
        _lblDestPhone.text = model.addressModel.desPhone;
        _lblDestInst.text = model.addressModel.desInstruction;

        
        NSString* sin = [model.addressModel.sourceInstruction stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([sin length]>0) {
            _lblPickInst.text = model.addressModel.sourceInstruction;
        }else{
            _lblPickInst.hidden = true;
        }
        sin = [model.addressModel.desInstruction stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([sin length]>0) {
            _lblDestInst.text = model.addressModel.desInstruction;
        }else{
            _lblDestInst.hidden = true;
        }
        
        self.lblServiceLevel.text = [NSString stringWithFormat:@"%@, %@%@, %@",model.serviceModel.name,symbol_dollar,model.serviceModel.price,model.serviceModel.time_in];
        self.lblPaymentMethod.text = [NSString stringWithFormat:@"%@",model.payment];
        self.lblPickDate.text = [NSString stringWithFormat:@"%@ %@",model.dateModel.date,model.dateModel.time];
        
        
        [self showItemLists:model];
    }
    
    if (model.cellSizeCalculated == false){
        CGRect scRect = [[UIScreen mainScreen] bounds];
        scRect.size.width = scRect.size.width;
        CGSize size = [self.stackRoot systemLayoutSizeFittingSize:scRect.size withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityDefaultLow];
        
        
        
        model.cellSizeCalculated = true;
        
        // get total height
        
        CGFloat baseHeight = self.viewHeader.frame.origin.y + 30;
        baseHeight = 196;
        CGFloat height = baseHeight + size.height + self.tableHeight;
        
        self.constraint_Height.constant = height + 4;
        self.data.cellSize = CGSizeMake(size.width, height+4);
    }
    
    
    [self.tableView_items reloadData];
}
-(void)showItemLists:(OrderHisModel*)model{
    self.orderModel = model.orderModel;
    if (model.orderModel.product_type == g_CAMERA_OPTION) {
        
        self.viewHeader_CAMERA.hidden = false;
        self.viewHeader_ITEM.hidden = true;
        self.viewHeader_PACKAGE.hidden = true;
        
        UINib* nib = [UINib nibWithNibName:@"ReviewCameraTableViewCell" bundle:nil];
        [self.tableView_items registerNib:nib forCellReuseIdentifier:@"cell1"];
        self.cellHeight = 40;
        self.tableView_items.delegate = self;
        self.tableView_items.dataSource = self;
    }else if(model.orderModel.product_type == g_ITEM_OPTION){
        self.viewHeader_CAMERA.hidden = true;
        self.viewHeader_ITEM.hidden = false;
        self.viewHeader_PACKAGE.hidden = true;
        
        UINib* nib = [UINib nibWithNibName:@"ReviewItemTableViewCell" bundle:nil];
        [self.tableView_items registerNib:nib forCellReuseIdentifier:@"cell2"];
        self.cellHeight = 40;
        self.tableView_items.delegate = self;
        self.tableView_items.dataSource = self;
    }else if(model.orderModel.product_type == g_PACKAGE_OPTION){
        self.viewHeader_CAMERA.hidden = true;
        self.viewHeader_ITEM.hidden = true;
        self.viewHeader_PACKAGE.hidden = false;
        
        UINib* nib = [UINib nibWithNibName:@"ReviewPackageTableViewCell" bundle:nil];
        [self.tableView_items registerNib:nib forCellReuseIdentifier:@"cell3"];
        self.cellHeight = 40;
        self.tableView_items.delegate = self;
        self.tableView_items.dataSource = self;
    }else{
        self.viewHeader_CAMERA.hidden = true;
        self.viewHeader_ITEM.hidden = true;
        self.viewHeader_PACKAGE.hidden = true;
        
        self.constraint_TH.constant = 0;
        return;
    }
    [self calculateRowHeight:model];
    self.constraint_TH.constant = self.tableHeight;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    [self.tableView_items setNeedsUpdateConstraints];
    [self.tableView_items layoutIfNeeded];
    return self.orderModel.itemModels.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.orderModel.product_type == g_CAMERA_OPTION) {
        ReviewCameraTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        
        NSMutableDictionary* inputData = [[NSMutableDictionary alloc] init];
        inputData[@"vc"] = self.vc;
        inputData[@"indexPath"] = indexPath;
        inputData[@"aDelegate"] = self;
        inputData[@"tableView"] = tableView;
        inputData[@"model"] = self.orderModel.itemModels[indexPath.row];
        
        [cell setData:inputData];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_RESERVED2;
        
        return cell;
    }else if(self.orderModel.product_type == g_ITEM_OPTION){
        ReviewItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        
        [cell initMe:self.orderModel.itemModels[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.aDelegate = self;
        cell.backgroundColor = COLOR_RESERVED2;
        return cell;
    }else{
        ReviewPackageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
        
        [cell initMe:self.orderModel.itemModels[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.aDelegate = self;
        cell.backgroundColor = COLOR_RESERVED2;
        return cell;
    }
    
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* key = [NSString stringWithFormat:@"%d",indexPath.row];
    if(self.height_dict[key]!=nil){
        NSString* value = self.height_dict[key];
        return [value floatValue];
    }
    return self.cellHeight;
}
-(void)calculateRowHeight:(OrderHisModel*)model{
    self.height_dict = [[NSMutableDictionary alloc] init];
    self.tableHeight = 0;
    for (int i=0; i<self.orderModel.itemModels.count; i++) {
        NSIndexPath*path = [NSIndexPath indexPathForRow:i inSection:0];
        CGFloat height = [CGlobal tableView1:self.tableView_items heightForRowAtIndexPath:path DefaultHeight:self.cellHeight Data:self.orderModel OrderType:model.orderModel.product_type Padding:0 Width:0];
        
        NSString*key = [NSString stringWithFormat:@"%d",i];
        NSString*value = [NSString stringWithFormat:@"%f",height];
        self.height_dict[key] = value;
        self.tableHeight = self.tableHeight + height;
    }
    NSLog(@"calculatedHeight Total = %.2f",self.tableHeight);
}
@end
