//
//  ContinuousReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "ContinuousReplicationTest.h"
#define kDocumentsize 500
//NSString *remotedb = @"http://farshid:farshid@single.couchbase.net/bitcoin";

@implementation ContinuousReplicationTest

{
    int _sequence;
}



- (void) heartbeat {
    if (self.suspended)
        return;
    double teststart = CFAbsoluteTimeGetCurrent();
    double wait = 60;
    do {
        CouchReplication *op;
        op = [self.database pullFromDatabaseAtURL:[NSURL URLWithString:@"http://farshid:farshid@single.couchbase.net/bitcoin"] options:kCouchReplicationContinuous];
    } while ([self.database getDocumentCount] < kDocumentsize);
    
    if (CFAbsoluteTimeGetCurrent() - teststart >= wait){    //replication runs for 60 seconds at intervals of 600 seconds 
        RESTOperation *com;
        com = [self.database compact];
        [NSThread sleepForTimeInterval:600];
    }
    
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
