//
//  ViewController.m
//  MyCoreData
//
//  Created by deng on 16/7/10.
//  Copyright © 2016年 txx. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Employee.h"

@interface ViewController ()

@property(nonatomic,strong)NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    创建一个数据库 company.sqlite
//    数据库要有一张表 员工表（Name，age，height）
//    往里面添加员工信息
    
    [self setupContext];
}
//添加员工信息
- (IBAction)addEmployeeInfoClick:(UIButton *)sender {
//    创建员工
    Employee *emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    emp.name = @"唐旋";
    emp.age = @26;
    emp.height = @180;
    
    //保存
    NSError *error = nil ;
    [self.context save:&error];
    
    if (error) {
        NSLog(@"-----insert-------%@",error);
    }else
    {
        NSLog(@"------insert sccess--------");
    }
    
}
//查询员工信息
- (IBAction)checkEmployeeInfoClick:(id)sender {
    //创建一个请求对象 填入要查询的表名-实体类
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
//    排序   -----------以身高进行升序排列yes   no表示降序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sort];
    
//    过滤查询 ----------没有predicate表示查询表中所有数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@ and height > %@",@"唐旋",@"179"];
    request.predicate = predicate ;

//    分页查询 每页显示5条，第一页第二份参数为0 第二页第二参数为5.....
    request.fetchLimit = 5 ;
    request.fetchOffset = 0 ;
    
//    读取信息
    NSError *error = nil;
    NSArray * emps = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"------read------%@",error);
    }else
    {
        for (Employee *emp in emps) {
            NSLog(@"--read----%@---%@----%@-",emp.name,emp.age,emp.height);
        }
    }
}
- (IBAction)deleteEmployee:(id)sender {
    
//    1.查找到需要删除的记录
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",@"mozixi"];
    request.predicate = predicate ;
    NSArray *emps = [self.context executeFetchRequest:request error:nil];

//    2.删除
    for (Employee *emp in emps) {
        [self.context deleteObject:emp];
    }
//    3.同步 -------------所有的操作都是暂时存储在内存里，需要同步到数据库
    [self.context save:nil];
}
- (IBAction)update:(id)sender {
// 把唐旋的身高改为190；
//    1.查找唐旋
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",@"唐旋"];
    request.predicate = predicate ;
    NSArray *emps = [self.context executeFetchRequest:request error:nil];

//    2.更新身高
    if (emps.count) {
        for (Employee *emp in emps) {
            emp.height = @190;
        }
    }
//    3.同步保存到数据库
    [self.context save:nil];
}
- (IBAction)moHuChaXun:(id)sender {
//    模糊查询
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
//    过滤 以唐开头的员工
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswitch %@",@"唐"];
    
//    过滤 以旋结尾的员工
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name endswitch %@",@"旋"];
    
//    过滤 包含唐的员工
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains %@",@"唐"];
//    过滤 like
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@",@"*唐"];
    request.predicate = predicate ;
    
//    读取信息
    NSError *error = nil ;
    NSArray * emps = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"------read------%@",error);
    }else
    {
        for (Employee *emp in emps) {
            NSLog(@"--read----%@---%@----%@-",emp.name,emp.age,emp.height);
        }
    }

}
-(void)setupContext
{
    //    1.创建上下文
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    //    2. 关联Company.xcdatamodeld模型文件
    //    传一个nil会把buddle下的所有模型文件关联起来
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    //存储数据库的名字
    NSError *error = nil ;
    //获取Document的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)lastObject];
    //数据库路径
    NSString *sqlitePath = [docPath stringByAppendingPathComponent:@"company.sqlite"];
    NSLog(@"-----------path-------%@",sqlitePath);
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
    
    context.persistentStoreCoordinator = store ;
    self.context = context ;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    static int count = 0 ;
    Employee *emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    emp.name = @"zhouling";
    emp.age = @26;
    emp.height = @(180+count++);
    
    //保存
    NSError *error = nil ;
    [self.context save:&error];
    
    if (error) {
        NSLog(@"-----insert-------%@",error);
    }else
    {
        NSLog(@"------insert sccess--------");
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
