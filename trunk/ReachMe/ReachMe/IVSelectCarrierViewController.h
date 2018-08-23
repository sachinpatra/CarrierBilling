//
//  IVSelectCarrierViewController.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 29/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "BaseUI.h"

@interface IVSelectCarrierViewController : BaseUI
@property (strong, nonatomic) NSMutableArray *networkName;
@property (nonatomic, strong) NSArray *carrierList;
@property (nonatomic, assign) BOOL isEdit;
@end
