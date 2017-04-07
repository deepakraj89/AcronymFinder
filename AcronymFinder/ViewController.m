//
//  ViewController.m
//  AcronymFinder
//
//  Created by Deepak on 4/7/17.
//  Copyright © 2017 Personal. All rights reserved.
//

#import "ViewController.h"
#define API_URL "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf="

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if(status!=AFNetworkReachabilityStatusUnknown && status!= AFNetworkReachabilityStatusNotReachable)
            self.isNetworkReachable=YES;
        else
            self.isNetworkReachable=NO;
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self.definitionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    self.definitionsTableView.layer.borderWidth = 1.0;
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)cleanupInputWhiteSpaces {
    
    NSString *textInputString = self.inputTextField.text;
    
    NSString *trimmedInput = [textInputString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedInput;

}

-(BOOL)IsValidInput {
    
    BOOL isValid=YES;
    NSString *textInputString = self.inputTextField.text;
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ"] invertedSet];
    
    if ([textInputString rangeOfCharacterFromSet:set].location != NSNotFound || textInputString.length==0) {
        isValid=NO;
    }

    return isValid;
}


-(void)throwAlertView:(NSString*)title alertMessage:(NSString*)message{
    
    UIAlertController *alertController = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];

    
    UIAlertAction *alertAction = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      
                                      self.inputTextField.text=@"";
                                      
                                  }];
    
    [alertController addAction:alertAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(IBAction)fetchDefinitionsFromAPI:(id)sender {
    
    [self.inputTextField resignFirstResponder];
    if(_isNetworkReachable) {
     
        if([self IsValidInput]) {
            
    NSString *cleanInputString = [self cleanupInputWhiteSpaces];
    NSString *acromineAPIURLString = [NSString stringWithFormat:@"%s%@",API_URL,cleanInputString];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    NSURL *acromineAPIURL = [NSURL URLWithString:acromineAPIURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:acromineAPIURL];
    
    
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        
        if(error){
            NSLog(@"Response Error: %@", error.description);
        }
        
        else {
            NSError *parsingError = nil;
            NSArray *jsonArray;
            if(responseObject){
                
                @try {
                jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &parsingError];
                NSLog(@"JSON data: %@",jsonArray);
                }
                @catch(NSException *exception) {
                    
                    NSLog(@"Exception occured while parsing JSON: %@",exception.description);
                }
                
                
            }
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", parsingError);
            } else {
                
                [self.tableViewDataSourceArray removeAllObjects];
                self.tableViewDataSourceArray=nil;
                if(jsonArray.count>0) {
                    
                    NSArray *arrayOfLongDefinitions;
                    @try {
                        
                    NSDictionary *jsonDictionary = [jsonArray objectAtIndex:0];
                    NSArray *arrayOfLongDefinitionDictionaries = [jsonDictionary valueForKey:@"lfs"];
                    NSLog(@"%@", [arrayOfLongDefinitionDictionaries valueForKey:@"lf"]);
                    arrayOfLongDefinitions =[arrayOfLongDefinitionDictionaries valueForKey:@"lf"];
                        
                    }
                    
                    @catch(NSException *exception) {
                        
                        NSLog(@"Exception occured while pulling long form: %@",exception.description);
                    }
                    self.tableViewDataSourceArray=[[NSMutableArray alloc]initWithArray:arrayOfLongDefinitions];
                }
                else {
                    
                    [self throwAlertView:@"No Results" alertMessage:@"No long form available for the acronym/initials provided."];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //if(self.tableViewDataSourceArray.count>0)
                    [self.definitionsTableView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.inputTextField resignFirstResponder];
                });
                
            }
            
        }
    }]resume];
    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
        else {
            [self throwAlertView:@"Invalid Input" alertMessage:@"Please enter only alphabets."];
        }
        
    }
    
    else {
        [self throwAlertView:@"No Network" alertMessage:@"Please check your network connection."];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableViewDataSourceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.textLabel.textColor=[UIColor blueColor];
    cell.textLabel.text=[self.tableViewDataSourceArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

@end
