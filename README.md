// 详情看工程文件
    // userName 为 HZQContactPerson模型中的 userName
    ![image](https://github.com/huzhiqin/HZQSearchDisplayController/search.png)

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
