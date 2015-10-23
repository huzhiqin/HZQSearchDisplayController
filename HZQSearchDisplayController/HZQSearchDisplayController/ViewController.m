//
//  ViewController.m
//  HZQSearchDisplayController
//
//  Created by 1 on 15/10/23.
//  Copyright © 2015年 HZQ. All rights reserved.
//

#import "ViewController.h"
#import "HZQSearchDisplayController.h"
#import "BaseTableViewCell.h"
#import "RealtimeSearchUtil.h"
#import "MJExtension.h"
#import "HZQContactPerson.h"


@interface ViewController () <UISearchDisplayDelegate, UISearchBarDelegate> {
    NSMutableArray *_dataArray;
}

@property (nonatomic, strong) UISearchBar *searchBar;

@property (strong, nonatomic) HZQSearchDisplayController *searchController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataArray = [NSMutableArray array];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        NSDictionary *dict = @{@"ID":[NSString stringWithFormat:@"%d", i],
                               @"userName":[NSString stringWithFormat:@"胡智钦%d", i],
                               @"mobile":[NSString stringWithFormat:@"胡智钦182028...%d", i]};
        
        [arr addObject:dict];

    }
    
    [_dataArray addObjectsFromArray:[HZQContactPerson objectArrayWithKeyValuesArray:arr]];

    
    [self.view addSubview:self.searchBar];

    
    [self searchController];

}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }

    return _searchBar;
}


- (HZQSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[HZQSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ChatListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            
            HZQContactPerson *model = (HZQContactPerson *)weakSelf.searchController.resultsSource[indexPath.row];
            cell.textLabel.text = model.userName;
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 70;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            HZQContactPerson *model = (HZQContactPerson *)weakSelf.searchController.resultsSource[indexPath.row];

            NSLog(@"%@", model.userName);
        }];
    }
    
    return _searchController;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:_dataArray searchText:(NSString *)searchText collationStringSelector:@selector(userName) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%@", results);
                
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


@end
