//
//  ContinuousReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "BeeCouchTest.h"
#import "AppDelegate.h"

@interface ContinuousReplicationTest : BeeCouchTest

@end


#define kDocumentsize 10000
//NSString *remotedb = @"http://farshid:farshid@single.couchbase.net/bitcoin";

@implementation ContinuousReplicationTest

{
    int _sequence;
}



- (void) heartbeat {
    if (self.suspended)
        return;
    double teststart = CFAbsoluteTimeGetCurrent();
    //double teststartall = CFAbsoluteTimeGetCurrent();
    double wait = 60;
    do {
        CouchReplication *op;
        op = [self.database pullFromDatabaseAtURL:[NSURL URLWithString:@"http://subarvind:stein*#*@ec2-50-16-117-7.compute-1.amazonaws.com:5984/ipaddr"] options:kCouchReplicationContinuous];
    } while ([self.database getDocumentCount] < kDocumentsize);
    double testend = CFAbsoluteTimeGetCurrent();
    NSLog(@"Continuous Replication took: %f seconds",(testend - teststart));
    
    if (CFAbsoluteTimeGetCurrent() - teststart >= wait){    //replication runs for 60 seconds at intervals of 600 seconds 
        double compactstart = CFAbsoluteTimeGetCurrent(); 
        RESTOperation *com;
        com = [self.database compact];
        [NSThread sleepForTimeInterval:600];
        double compactend = CFAbsoluteTimeGetCurrent();
        NSLog(@"Compaction takes: %f seconds",(compactend - compactstart));
    }
    
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
