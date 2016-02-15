//
//  HospitalTableViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/13.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "HospitalTableViewController.h"
#import "MeetingViewController.h"
#import "FMDB.h"

@interface HospitalTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *hospitals;
@property (nonatomic, strong) NSArray *filteredArray;

@end

@implementation HospitalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务医院列表";
    
    [self loadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HospitalCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"brt_data" ofType:@"sqlite"];
    
    //导入医院数据
//    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"hospitals" ofType:@"txt"];
//    NSString *srcString = [[NSString alloc] initWithContentsOfFile:srcPath encoding:NSUTF8StringEncoding error:NULL];
//    NSArray *rows = [srcString componentsSeparatedByString:@"\r"];
//    
//    NSString *dbPath2 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/brt_data.sqlite"];
//    [[NSFileManager defaultManager] copyItemAtPath:dbPath toPath:dbPath2 error:NULL];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath2];
//    
//    if (![db open]) {
//        NSLog(@"%@", [db lastErrorMessage]);
//        return;
//    }
//    
//    for (NSString *string in rows) {
//        NSArray *columns = [string componentsSeparatedByString:@"\t"];
//        if (columns.count != 7) {
//            NSLog(@"column error");
//            break;
//        }
//        BOOL retValue = [db executeUpdate:@"insert into hospitals (_id, Code, Name, Region, District, TerritoryName, UserName, ManagerName) values (?,?,?,?,?,?,?,?)", NULL, columns[0], columns[1], columns[2], columns[3], columns[4], columns[5], columns[6]];
//        if (!retValue) {
//            NSLog(@"%@", [db lastErrorMessage]);
//        }
//    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select distinct Name from hospitals"];
    NSMutableArray *array = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *name = [resultSet stringForColumn:@"Name"];
        [array addObject:name];
    }
    [db close];
    self.hospitals = array;
    self.filteredArray = array;
}

- (void)filterHospitalsWithText:(NSString*)text {
    if (text.length == 0) {
        self.filteredArray = self.hospitals;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains %@", text];
        
        NSArray *array = [self.hospitals filteredArrayUsingPredicate:predicate];
        self.filteredArray = array;
    }
    [self.tableView reloadData];
}

#pragma mark - SearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterHospitalsWithText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.filteredArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HospitalCell" forIndexPath:indexPath];
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    cell.textLabel.text = self.filteredArray[indexPath.row];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_acc"]];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMeeting" sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMeeting"]) {
        MeetingViewController *dvc = segue.destinationViewController;
        dvc.title = @"医院会议列表";
        dvc.meetingType = self.meetingType;
    }
}


@end
