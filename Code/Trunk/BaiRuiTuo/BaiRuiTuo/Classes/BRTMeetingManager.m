//
//  BRTMeetingManager.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/20.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "BRTMeetingManager.h"
#import "Define.h"
#import "AFNetworking.h"
#import "XMLDictionary.h"
#import "SSZipArchive.h"
#import "BaiduMobStat.h"

#define kBRTDataFolderName @"BaiRuiTuo"
#define kBRTDatabaseName @"brt.db"

//#define TEST

@interface BRTMeetingManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation BRTMeetingManager

+ (instancetype)sharedManager
{
    static id shardInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shardInstance = [[self alloc] init];
    });
    return shardInstance;
}

- (void)createDatabase
{
    NSString *dbPath = [[self dataFolder] stringByAppendingPathComponent:kBRTDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    self.dbPath = dbPath;

    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }

    BOOL result = [db executeStatements:@"create table if not exists 'brt_meeting' ('id' INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL, 'meeting_id' varchar, 'meeting_type' varchar, 'meeting_time' varchar, 'meeting_name' varchar, 'meeting_office' varchar, 'requester_cwid' varchar, 'submitter_cwid' varchar, 'lm_cwid' varchar, 'lm_namecn' varchar, 'HomeCostCenterCode' varchar, 'HomeCostCenterDesc' varchar, 'RegionCode' varchar, 'Region' varchar, 'meeting_state' integer, 'begin_time' integer, 'end_time' integer, 'upload_time' integer, 'update_flag' integer)"];
    if (result == NO) {
        NSLog(@"%@", [db lastErrorMessage]);
    }
    
    result = [db executeStatements:@"create table if not exists 'brt_meeting_detail' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'meeting_id' varchar, 'image_type' integer, 'image_name' varchar)"];
    if (result == NO) {
        NSLog(@"%@", [db lastErrorMessage]);
    }
    
    [db close];
    
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
}

- (NSString*)dataFolder
{
    NSString *libraryDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *dataDir = [libraryDir stringByAppendingPathComponent:kBRTDataFolderName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dataDir]) {
        return dataDir;
    }
    BOOL result = [fm createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:NULL];
    if (result == NO) {
        NSLog(@"Failed to create data folder!");
        return nil;
    }
    return dataDir;
}

- (NSMutableArray*)meetings {
    
    if (_meetings) {
        return _meetings;
    }
    
    NSMutableArray *array = [self loadMeetings];
    _meetings = array;
    
    return _meetings;
}

- (NSMutableArray*)loadMeetings
{
    return [self loadMeetingList:AllMeeting];
}

- (NSMutableArray*)loadMeetingList:(BRTMeetingType)meetingType
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *dbPath = [[self dataFolder] stringByAppendingPathComponent:kBRTDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return nil;
    }
#ifdef TEST
    FMResultSet *resultSet = [db executeQuery:@"select * from brt_meeting where meeting_id = 15080210001"];
    if (![resultSet next]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"meeting" ofType:@"txt"];
        NSString *srcString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        NSMutableArray *testArray = [NSMutableArray array];
        NSArray *rows = [srcString componentsSeparatedByString:@"\n\n"];
        for (NSString *subStr in rows) {
            NSArray *columns = [subStr componentsSeparatedByString:@"\n"];
            [testArray addObject:columns];
        }
        
        for (NSArray *columns in testArray) {
            NSString *meetingID = columns[0];
            NSString *meetingTime = columns[2];
            NSString *meetingName = columns[3];
            NSString *office = columns[4];
            int state = [columns[5] intValue];
            
            //城市会
            NSString *meetingType = @"10";//columns[1];
            BOOL retValue = [db executeUpdate:@"insert into brt_meeting (id, meeting_id, meeting_type, meeting_time, meeting_name, meeting_office, requester_cwid, submitter_cwid, lm_cwid, lm_namecn, HomeCostCenterCode, HomeCostCenterDesc, RegionCode, region, meeting_state, begin_time, end_time, upload_time, update_flag) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                             NULL, meetingID, meetingType, meetingTime, meetingName, office, @"", @"", @"", @"", @"", @"", @"", @"", @(state), @(0), @(0), @(0), @(1)];
            if (!retValue) {
                NSLog(@"%@", [db lastErrorMessage]);
            }
            //科室会
            meetingType = @"1";
            [db executeUpdate:@"insert into brt_meeting (id, meeting_id, meeting_type, meeting_time, meeting_name, meeting_office, requester_cwid, submitter_cwid, lm_cwid, lm_namecn, HomeCostCenterCode, HomeCostCenterDesc, RegionCode, region, meeting_state, begin_time, end_time, upload_time, update_flag) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
             NULL, meetingID, meetingType, meetingTime, meetingName, office, @"", @"", @"", @"", @"", @"", @"", @"", @(state), @(0), @(0), @(0), @(1)];
            //院内会
            meetingType = @"1";
            [db executeUpdate:@"insert into brt_meeting (id, meeting_id, meeting_type, meeting_time, meeting_name, meeting_office, requester_cwid, submitter_cwid, lm_cwid, lm_namecn, HomeCostCenterCode, HomeCostCenterDesc, RegionCode, region, meeting_state, begin_time, end_time, upload_time, update_flag) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
             NULL, meetingID, meetingType, meetingTime, meetingName, office, @"", @"", @"", @"", @"", @"", @"", @"", @(state), @(0), @(0), @(0), @(1)];
        }
    }
#endif
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd";
    NSDate *today = [NSDate date];
    NSTimeInterval oneDay = 86400;
    
    //超过30天的不显示
    NSDate *overOneMonth = [today dateByAddingTimeInterval:oneDay * -30];
    NSString *overTime = [dateFmt stringFromDate:overOneMonth];
    //超过6天过期
    NSDate *minValidDate = [today dateByAddingTimeInterval:oneDay * -6];
    NSString *minTime = [dateFmt stringFromDate:minValidDate];
#ifdef TEST
    overTime = @"0";
//    minTime = @"0";
#endif
    BOOL result = [db executeUpdate:@"update brt_meeting set meeting_state = ?, update_flag = ? where meeting_time < ? and meeting_state = ?", @(ExpiredState), @(1), minTime, @(BeforeMeetingState)];
    if (result == NO) {
        NSLog(@"%@", [db lastErrorMessage]);
    }
    
    FMResultSet *allMeeting;
    if (meetingType == AllMeeting) {
        allMeeting = [db executeQuery:@"select * from brt_meeting where meeting_time > ?", overTime];
    }
    else {
        allMeeting = [db executeQuery:@"select * from brt_meeting where meeting_type = ? and meeting_time > ?", @(meetingType), overTime];
    }
    
    while ([allMeeting next]) {
        BRTMeetingModel *meeting = [[BRTMeetingModel alloc] init];
        meeting.meetingID = [allMeeting stringForColumn:kBRTMeetingIDKey];
        meeting.meetingName = [allMeeting stringForColumn:kBRTMeetingNameKey];
        meeting.meetingOffice = [allMeeting stringForColumn:kBRTMeetingOfficeKey];
        meeting.meetingTime = [allMeeting stringForColumn:kBRTMeetingTimeKey];
        meeting.meetingState = @([allMeeting intForColumn:kBRTMeetingStateKey]);
        meeting.meetingType = [allMeeting stringForColumn:kBRTMeetingTypeKey];
        
        int beginTime = [allMeeting intForColumn:kBRTMeetingBeginTimeKey];
        int endTime = [allMeeting intForColumn:kBRTMeetingEndTimeKey];
        int uploadTime = [allMeeting intForColumn:kBRTMeetingUploadTimeKey];
        if (beginTime > 0) {
            meeting.beginTime = [NSDate dateWithTimeIntervalSince1970:beginTime];
        }
        if (endTime > 0) {
            meeting.endTime = [NSDate dateWithTimeIntervalSince1970:endTime];
        }
        if (uploadTime > 0) {
            meeting.uploadTime = [NSDate dateWithTimeIntervalSince1970:uploadTime];
        }
        
        [array addObject:meeting];
    }
    
    for (BRTMeetingModel *meeting in array) {
        NSString *meetingDir = [[self dataFolder] stringByAppendingPathComponent:meeting.meetingID];
        BRTMeetingDetailModel *meetingDetail = meeting.meetingDetail;
        FMResultSet *allImages = [db executeQuery:@"select * from brt_meeting_detail where meeting_id = ?", meeting.meetingID];
        while ([allImages next]) {
            BRTImageType imageType = [allImages intForColumn:@"image_type"];
            NSString *imageName = [allImages stringForColumn:@"image_name"];
            NSString *imagePath = [meetingDir stringByAppendingPathComponent:imageName];
            switch (imageType) {
                case BeforeMeetingType:
                    [meetingDetail.beforeMeetingImages addObject:imagePath];
                    break;
                case InMeetingType:
                    [meetingDetail.inMeetingImages addObject:imagePath];
                    break;
                case AfterMeetingType:
                    [meetingDetail.afterMeetingImages addObject:imagePath];
                    break;
                case RefreshmentsType:
                    [meetingDetail.teaBreakImages addObject:imagePath];
                    break;
                case CarsType:
                    [meetingDetail.carServiceImages addObject:imagePath];
                    break;
                case MealsType:
                    [meetingDetail.diningImages addObject:imagePath];
                    break;
                case OthersType:
                    [meetingDetail.otherImages addObject:imagePath];
                    break;
                    
                default:
                    break;
            }
        }
        [allMeeting close];
    }
    
    [db close];
    
    return array;
}

- (void)updateMeetingList:(NSArray*)array
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    for (NSDictionary *dict in array) {
        id meetingID = [dict objectForKey:@"EventID"];
        id meetingType = [dict objectForKey:@"EventType"];
        id meetingTime = [dict objectForKey:@"StartDate"];
        id meetingName = [dict objectForKey:@"ActivityName"];
        id requester_cwid = [dict objectForKey:@"RequesterCWID"];
        id submitter_cwid = [dict objectForKey:@"SubmitterCWID"];
        id lm_cwid = [dict objectForKey:@"LMCWID"];
        if (lm_cwid == nil) {
            lm_cwid = @"";
        }
        id lm_namecn = [dict objectForKey:@"LMNameCN"];
        if (lm_namecn == nil) {
            lm_namecn = @"";
        }
        id HomeCostCenterCode = [dict objectForKey:@"HomeCostCenterCode"];
        if (HomeCostCenterCode == nil) {
            HomeCostCenterCode = @"";
        }
        id HomeCostCenterDesc = [dict objectForKey:@"HomeCostCenterDesc"];
        if (HomeCostCenterDesc == nil) {
            //接口传来的参数名拼写错了
            HomeCostCenterDesc = [dict objectForKey:@"HomeCostCeterDesc"];
            if (HomeCostCenterDesc == nil) {
                HomeCostCenterDesc = @"";
            }
        }
        id RegionCode = [dict objectForKey:@"RegionCode"];
        if (RegionCode == nil) {
            RegionCode = @"";
        }
        id region = [dict objectForKey:@"Region"];
        if (region == nil) {
            region = @"";
        }
        int status = [[dict objectForKey:@"Status"] intValue];
        BRTMeetingState meetingState;
        if (status == 10) {
            meetingState = BeforeMeetingState;
        }
        else if (status == 12) {
            meetingState = CancelByServerState;
        }
        else {
            meetingState = BeforeMeetingState;
        }
        FMResultSet *resultSet = [db executeQuery:@"select * from brt_meeting where meeting_id = ?", meetingID];
        if ([resultSet next]) {
            //存在则更新
            if (meetingState == CancelByServerState) {
                BOOL result = [db executeUpdate:@"update brt_meeting set meeting_state = ?, update_flag = ? where meeting_id = ? and meeting_state <> ?", @(meetingState), @(1), meetingID,  @(meetingState)];
                if (result == NO) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
            }
        }
        else {
            //不存在则插入
            BOOL result = [db executeUpdate:@"insert into brt_meeting values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", NULL, meetingID, meetingType, meetingTime, meetingName, @"骨科", requester_cwid, submitter_cwid, lm_cwid, lm_namecn, HomeCostCenterCode, HomeCostCenterDesc, RegionCode, region, @(meetingState), @(0), @(0), @(0), @(1)];
            if (result == NO) {
                NSLog(@"%@", [db lastErrorMessage]);
            }
        }
    }
    
    [db close];
    
    [self uploadMeetingRecords];
}

- (void)updateValue:(id)value forKey:(NSString*)key withMeetingID:(NSString*)meetingID
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    if ([key isEqualToString:kBRTMeetingStateKey]) {
        BOOL result = [db executeUpdate:@"update brt_meeting set meeting_state = ?, update_flag = ? where meeting_id = ?", value, @(1), meetingID];
        if (result == NO) {
            NSLog(@"update %@ error:%@", key, [db lastErrorMessage]);
        }
    }
    else if ([key isEqualToString:kBRTMeetingBeginTimeKey]) {
        BOOL result = [db executeUpdate:@"update brt_meeting set begin_time = ?, update_flag = ? where meeting_id = ?", value, @(1), meetingID];
        if (result == NO) {
            NSLog(@"update %@ error:%@", key, [db lastErrorMessage]);
        }
    }
    else if ([key isEqualToString:kBRTMeetingEndTimeKey]) {
        BOOL result = [db executeUpdate:@"update brt_meeting set end_time = ?, update_flag = ? where meeting_id = ?", value, @(1), meetingID];
        if (result == NO) {
            NSLog(@"update %@ error:%@", key, [db lastErrorMessage]);
        }
    }
    else if ([key isEqualToString:kBRTMeetingUploadTimeKey]) {
        BOOL result = [db executeUpdate:@"update brt_meeting set upload_time = ?, update_flag = ? where meeting_id = ?", value, @(1), meetingID];
        if (result == NO) {
            NSLog(@"update %@ error:%@", key, [db lastErrorMessage]);
        }
    }
    
    [db close];
    [self uploadMeetingRecords];
}

#define kBRTImageTypes @[@"Panorama",@"Speaker",@"AfterMeeting",@"Refreshments",@"Cars",@"Meals",@"Others"]
- (NSString*)writeImageData:(NSData*)data withImageType:(BRTImageType)imageType
{
    BRTMeetingModel *meeting = self.currentMeeting;
    NSString *meetingID = meeting.meetingID;
    NSString *meetingDir = [[self dataFolder] stringByAppendingPathComponent:meetingID];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL result;
    if (![fm fileExistsAtPath:meetingDir]) {
        result = [fm createDirectoryAtPath:meetingDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (result == NO) {
            NSLog(@"创建文件夹失败：%@", [error description]);
            return nil;
        }
    }
    NSArray *imageTypes = kBRTImageTypes;
    NSString *typeString = imageTypes[imageType];
    NSString *lastImageName = nil;
    switch (imageType) {
        case BeforeMeetingType:
            lastImageName = [meeting.meetingDetail.beforeMeetingImages lastObject];
            break;
        case InMeetingType:
            lastImageName = [meeting.meetingDetail.inMeetingImages lastObject];
            break;
        case AfterMeetingType:
            lastImageName = [meeting.meetingDetail.afterMeetingImages lastObject];
            break;
        case RefreshmentsType:
            lastImageName = [meeting.meetingDetail.teaBreakImages lastObject];
            break;
        case CarsType:
            lastImageName = [meeting.meetingDetail.carServiceImages lastObject];
            break;
        case MealsType:
            lastImageName = [meeting.meetingDetail.diningImages lastObject];
            break;
        case OthersType:
            lastImageName = [meeting.meetingDetail.otherImages lastObject];
            break;
            
        default:
            break;
    }
    
    NSString *fileName = nil;
    if (lastImageName == nil) {
        fileName = [NSString stringWithFormat:@"%@ %d.jpg", typeString, 1];
    }
    else {
        NSMutableString *lastName = [NSMutableString stringWithString:[lastImageName lastPathComponent]];
        NSString *pattern = @"[\\d]+";
        NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *result = [regExp firstMatchInString:lastName options:0 range:NSMakeRange(0, lastName.length)];
        
        if (result) {
            NSRange range = result.range;
            int lastIndex = [[lastName substringWithRange:range] intValue];
            fileName = [NSString stringWithFormat:@"%@ %d.jpg", typeString, lastIndex+1];
        }
    }
    
    
    NSString *filePath = [meetingDir stringByAppendingPathComponent:fileName];
    result = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (result == NO) {
        NSLog(@"保存图片失败：%@", [error description]);
        return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return nil;
    }
    result = [db executeUpdate:@"insert into brt_meeting_detail (id, meeting_id, image_type, image_name) values(NULL,?,?,?)", meetingID, @(imageType), fileName];
    if (result == NO) {
        NSLog(@"%@", [db lastErrorMessage]);
        return nil;
    }
    
    [db close];
    
    return filePath;
}

- (void)deleteImage:(NSString*)imagePath withMeetingID:(NSString*)meetingID
{    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    NSString *imageName = [imagePath lastPathComponent];
    BOOL result = [db executeUpdate:@"delete from brt_meeting_detail where meeting_id = ? and image_name = ?", meetingID, imageName];
    if (result == NO) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    [db close];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:imagePath error:NULL];
}

- (void)uploadMeeting:(BRTMeetingModel*)meeting success:(void (^)(id JSON))success
              failure:(void (^)(NSError *error))failure
{
#ifdef TEST
    success(@{@"Result":@"Success"});
    return;
#endif
    NSString *meetingID = meeting.meetingID;
    
    NSString *guid = [[NSUUID UUID] UUIDString];
    NSString *zipName = [guid stringByAppendingString:@".zip"];
    NSString *xmlName = [guid stringByAppendingString:@".xml"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *meetingDir = [[self dataFolder] stringByAppendingPathComponent:meetingID];
    
    NSString *zipFilePath = [meetingDir stringByAppendingPathComponent:zipName];
    NSString *xmlFilePath = [meetingDir stringByAppendingPathComponent:xmlName];
    
    SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:zipFilePath];
    [zipArchive open];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSArray *imageTypes = kBRTImageTypes;
    
    NSString *dbPath = [[self dataFolder] stringByAppendingPathComponent:kBRTDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    FMResultSet *resultSet = [db executeQuery:@"select * from brt_meeting_detail where meeting_id = ?", meetingID];
    while ([resultSet next]) {
        NSString *imageName = [resultSet stringForColumn:@"image_name"];
        NSString *filePath = [meetingDir stringByAppendingPathComponent:imageName];
        if ([fm fileExistsAtPath:filePath]) {
            BRTImageType imageType = [resultSet intForColumn:@"image_type"];
            NSString *typeString = imageTypes[imageType];
            [images addObject:@{@"name":imageName, @"type":typeString}];
            BOOL retValue = [zipArchive writeFile:filePath];
            if (retValue == NO) {
                
            }
        }
    }
    [db close];
    
    NSMutableDictionary *xmlDict = [[NSMutableDictionary alloc] init];
    [xmlDict setObject:@"event_execution" forKey:XMLDictionaryNodeNameKey];
    [xmlDict setObject:@{@"guid":guid} forKey:XMLDictionaryAttributesKey];
    [xmlDict setObject:@{@"id":meetingID} forKey:@"event"];
    [xmlDict setObject:@{@"image":images} forKey:@"images"];
    
    NSString *clientString = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        clientString = @"iPad";
    }
    else {
        clientString = @"iPhone";
    }
    [xmlDict setObject:@{@"client":clientString} forKey:XMLDictionaryAttributesKey];
    
    NSString *xmlString = [xmlDict XMLString];
    [xmlString writeToFile:xmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

    [zipArchive writeFile:xmlFilePath];
    [zipArchive close];
    
    NSData *zipFileData = [NSData dataWithContentsOfFile:zipFilePath];
    
    NSString *urlString = [kBRTOPERAServerURL stringByAppendingPathComponent:@"Execution.aspx"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 120;
    
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:[@"File" dataUsingEncoding:NSUTF8StringEncoding] name:@"File"];
        [formData appendPartWithFileData:zipFileData name:@"File" fileName:zipName mimeType:@"application/zip"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef TEST
        responseObject = @{@"Result":@"Success"};
#endif
        success(responseObject);
        [fm removeItemAtPath:xmlFilePath error:NULL];
        [fm removeItemAtPath:zipFilePath error:NULL];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [fm removeItemAtPath:xmlFilePath error:NULL];
        [fm removeItemAtPath:zipFilePath error:NULL];
    }];
}

- (void)deleteUnusedMeetingData
{
    NSString *dbPath = [[self dataFolder] stringByAppendingPathComponent:kBRTDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd";
    NSTimeInterval oneDay = 86400;
    NSDate *minValidDate = [[NSDate date] dateByAddingTimeInterval:oneDay * -30];
    NSString *minTime = [dateFmt stringFromDate:minValidDate];
#ifdef DEBUG
    minTime = @"0";
#endif
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    FMResultSet *resultSet = [db executeQuery:@"select * from brt_meeting where meeting_time < ? ", minTime];
    while ([resultSet next]) {
        NSString *meetingID = [resultSet stringForColumn:kBRTMeetingIDKey];
        [db executeUpdate:@"delete from brt_meeting_detail where meeting_id = ? ", meetingID];
        NSString *meetingDir = [[self dataFolder] stringByAppendingPathComponent:meetingID];
        if ([fm fileExistsAtPath:meetingDir]) {
            [fm removeItemAtPath:meetingDir error:NULL];
        }
    }
    
    [db close];
}

/*
 http://www.bayernorth.com/sync.aspx
 192.168.8.27
 http://www.bayernorth.com/login.aspx
 admin/1111
 
 post数据 meetingjson=url encode json string
 * 导入返回结果
 * 成功 {"result":"success"}
 * 失败 {"result":"fail","meeting_id":"导入失败的会议ID"}
 * 异常 {"result":"exception","cause":"产生异常的原因"}
 */
- (void)uploadMeetingRecords
{
//#ifdef TEST
//    return;
//#endif
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *dbPath = [[self dataFolder] stringByAppendingPathComponent:kBRTDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"%@", [db lastErrorMessage]);
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:kBRTUsernameKey];
    
    NSArray *meetingStates = kBRTMeetingStates;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [db executeQuery:@"select * from brt_meeting where update_flag > 0"];
    while ([resultSet next]) {
        NSString *meetingID = [resultSet objectForColumnName:kBRTMeetingIDKey];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:meetingID forKey:kBRTMeetingIDKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingNameKey] forKey:kBRTMeetingNameKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingOfficeKey] forKey:kBRTMeetingOfficeKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingRequesterCWIDKey] forKey:kBRTMeetingRequesterCWIDKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingSubmitterCWIDKey] forKey:kBRTMeetingSubmitterCWIDKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingLMCWIDKey] forKey:kBRTMeetingLMCWIDKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingLMNameCNKey] forKey:kBRTMeetingLMNameCNKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingHomeCostCenterCodeKey] forKey:kBRTMeetingHomeCostCenterCodeKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingHomeCostCenterDescKey] forKey:kBRTMeetingHomeCostCenterDescKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingRegionCodeKey] forKey:kBRTMeetingRegionCodeKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingRegionKey] forKey:kBRTMeetingRegionKey];
//        [dict setObject:username forKey:@"user_cwid"];//代表的CWID
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingBeginTimeKey] forKey:kBRTMeetingBeginTimeKey];
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingEndTimeKey] forKey:kBRTMeetingEndTimeKey];
        
        // QCW 1.4 Fix
        [dict setObject:[resultSet objectForColumnName:kBRTMeetingTypeKey] forKey:kBRTMeetingTypeKey];
//        BRTMeetingType meetingType = [resultSet intForColumn:kBRTMeetingTypeKey];
//        NSString *typeString = @"";
//        if (meetingType == BRTOfficeMeeting) {
//            typeString = @"科室会";
//        }
//        else if (meetingType == BRTHospitalMeeting)
//        {
//            typeString = @"院内会";
//        }
//        else if (meetingType == BRTCityMeeting)
//        {
//            typeString = @"城市会";
//        }
//        [dict setObject:typeString forKey:kBRTMeetingTypeKey];
        
        BRTMeetingState meetingState = [resultSet intForColumn:kBRTMeetingStateKey];
        NSString *stateString = @"";
        if (meetingState >= BeforeMeetingState && meetingState < InvalidState) {
            stateString = meetingStates[meetingState];
        }
        [dict setObject:stateString forKey:kBRTMeetingStateKey];
        
        // 2015-06-10,将meeting_time也上传，用于服务器判断是否过期
        NSString *meetingTime = [resultSet objectForColumnName:kBRTMeetingTimeKey];
        int timeInterval = [[dateFmt dateFromString:meetingTime] timeIntervalSince1970];
        [dict setObject:@(timeInterval) forKey:kBRTMeetingTimeKey];
        
        FMResultSet *imageCountSet = [db executeQuery:@"select image_type, count(image_name) as image_count from brt_meeting_detail where meeting_id = ? group by image_type", meetingID];
        int totalCount = 0;
        while ([imageCountSet next]) {
            int imageCount = [imageCountSet intForColumn:@"image_count"];
            int imageType = [imageCountSet intForColumn:@"image_type"];
            NSString *key = [NSString stringWithFormat:@"image_count%d", imageType+1];
            [dict setObject:@(imageCount) forKey:key];
        }
        [dict setObject:@(totalCount) forKey:@"image_totalcount"];
        [array addObject:dict];
    }
    
    [db close];
    if (array.count == 0) {
        return;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:NULL];
#ifdef DEBUG
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
#endif
    
    NSString *urlString = [kBRTMeetingRecordURL stringByAppendingPathComponent:@"sync.aspx"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = nil;
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:jsonData name:@"meetingjson"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *result = [responseObject objectForKey:@"result"];
            if ([result isEqualToString:@"success"]) {
                if (![db open]) {
                    NSLog(@"%@", [db lastErrorMessage]);
                    return;
                }
                [db executeUpdate:@"update brt_meeting set update_flag = 0"];
                [db close];
            }
            else if ([result isEqualToString:@"fail"]) {
                NSLog(@"%s:%@",__func__, [responseObject objectForKey:@"meeting_id"]);
                NSString *errMsg = [NSString stringWithFormat:@"fail:%@", [responseObject objectForKey:@"meeting_id"]];
                [[BaiduMobStat defaultStat] logEvent:@"2" eventLabel:errMsg];
            }
            else if ([result isEqualToString:@"exception"]) {
                NSLog(@"%s:%@",__func__, [responseObject objectForKey:@"cause"]);
                NSString *errMsg = [NSString stringWithFormat:@"exception:%@", [responseObject objectForKey:@"cause"]];
                [[BaiduMobStat defaultStat] logEvent:@"2" eventLabel:errMsg];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s:%@",__func__, error.localizedDescription);
    }];
}

@end
