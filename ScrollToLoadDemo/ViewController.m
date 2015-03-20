//
//  ViewController.m
//  ScrollToLoadDemo
//
//  Created by xzysun on 15/3/19.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "ViewController.h"
#import "ScrollToLoad.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataList = [NSMutableArray array];
    [self loadData];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView addLoadMoreFooterWithCallback:^{
        NSLog(@"trigger load more!!!");
        [self loadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    NSLog(@"Load data start");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 5; i ++) {
            int random = arc4random_uniform(1000);
            [self.dataList addObject:[NSString stringWithFormat:@"随机数:%d", random]];
        }
        NSLog(@"Load data finished");
        [self.tableView loadMoreFooterEndLoading];
        [self.tableView reloadData];
    });
}

- (IBAction)rightButtonAction:(id)sender
{
    NSLog(@"切换开关");
    [self.tableView setLoadMoreFooterEnabled:!self.tableView.loadMoreFooterEnabled];
}

#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.dataList objectAtIndex:indexPath.row];
    return cell;
}
@end
