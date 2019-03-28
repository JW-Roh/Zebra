//
//  ZBDependencyResolver.m
//  Zebra
//
//  Created by Wilson Styres on 3/26/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

#import "ZBDependencyResolver.h"
#import "ZBDatabaseManager.h"
#import <Packages/Helpers/ZBPackage.h>
#import <ZBAppDelegate.h>
#import <sqlite3.h>

@implementation ZBDependencyResolver

@synthesize databaseManager;
@synthesize database;

- (id)init {
    self = [super init];
    
    if (self) {
        databaseManager = [[ZBDatabaseManager alloc] init];
        
        sqlite3_open([[ZBAppDelegate databaseLocation] UTF8String], &database);
    }
    
    return self;
}

- (NSArray *)dependenciesForPackage:(ZBPackage *)package {
    if ([databaseManager packageIsInstalled:[package identifier] inDatabase:database]) {
        NSLog(@"%@ (%@) is already installed, dependencies resolved.", [package name], [package identifier]);
        return NULL;
    }
    
    NSArray *dependencies = [self getDependenciesForPackage:package alreadyQueued:@[package]];
    
    NSLog(@"Dependencies for package %@: %@", [package name], dependencies);
    
    return dependencies;
}

- (NSArray *)getDependenciesForPackage:(ZBPackage *)package alreadyQueued:(NSArray *)qd {
    NSMutableArray *queued = [qd mutableCopy];
    
    NSArray *dependencies = [package dependsOn];
    NSLog(@"Depends On: %@", dependencies);
    
    for (NSString *line in dependencies) {
        NSArray *comps = [line componentsSeparatedByString:@" | "]; //Separates OR requirements
        
        if ([comps count] > 1) { //There is an OR operator, lets try to resolve it one by one
            for (NSString *dPID in comps) {
                NSArray *removeVersion = [dPID componentsSeparatedByString:@" ("];
                NSString *depPackageID = removeVersion[0];
                NSLog(@"Comp line %@", depPackageID);
                NSString *depPackgageVersion = NULL;
                ZBPackage *depPackage = [databaseManager packageForID:depPackageID version:depPackgageVersion inDatabase:database];
                
                if ([queued containsObject:[depPackage identifier]]) {
                    NSLog(@"%@ is already queued, skipping", depPackageID);
                    break;
                }
                
                if ([databaseManager packageIsInstalled:[depPackage identifier] inDatabase:database]) {
                    NSLog(@"%@ is already installed, skipping", [depPackage identifier]);
                    break;
                }
                else if ([databaseManager packageIsAvailable:[depPackage identifier] inDatabase:database]) {
                    NSLog(@"%@ is available, adding it to queued packages", [depPackage identifier]);
                    if (![queued containsObject:depPackage]) {
                        [queued addObject:depPackage];
                        
                        NSArray *depsForDep = [self getDependenciesForPackage:depPackage alreadyQueued:queued];
                        for (ZBPackage *dep in depsForDep) {
                            if (![queued containsObject:dep]) {
                                [queued addObject:dep];
                            }
                        }
                        break;
                    }
                    else {
                        NSLog(@"%@ is already queued (2), skipping", [depPackage identifier]);
                        break;
                    }
                    
                    
                }
                else {
                    NSLog(@"Cannot resolve dependencies for %@ because %@ cannot be found", [package identifier], depPackageID);
                    continue;
                }
            }
        }
        else { //Continue about your business
            NSArray *removeVersion = [comps[0] componentsSeparatedByString:@" ("];
            NSString *depPackageID = removeVersion[0];
            NSString *depPackgageVersion = NULL;
            ZBPackage *depPackage = [databaseManager packageForID:depPackageID version:depPackgageVersion inDatabase:database];
            
            if ([queued containsObject:[depPackage identifier]]) {
                NSLog(@"%@ is already queued, skipping", depPackageID);
                continue;
            }
            
            if ([databaseManager packageIsInstalled:[depPackage identifier] inDatabase:database]) {
                NSLog(@"%@ is already installed, skipping", [depPackage identifier]);
                continue;
            }
            else if ([databaseManager packageIsAvailable:[depPackage identifier] inDatabase:database]) {
                NSLog(@"%@ is available, adding it to queued packages", [depPackage identifier]);
                if (![queued containsObject:depPackage]) {
                    [queued addObject:depPackage];
                    
                    NSArray *depsForDep = [self getDependenciesForPackage:depPackage alreadyQueued:queued];
                    for (ZBPackage *dep in depsForDep) {
                        if (![queued containsObject:dep]) {
                            [queued addObject:dep];
                        }
                    }
                }
                else {
                    NSLog(@"%@ is already queued (2), skipping", [depPackage identifier]);
                }
                
                
            }
            else {
                NSLog(@"Cannot resolve dependencies for %@ because %@ cannot be found", [package identifier], depPackageID);
            }
        }
        
    }
    
    return queued;
}

@end