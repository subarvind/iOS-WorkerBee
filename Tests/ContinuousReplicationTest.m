//
//  ContinuousReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "ContinuousReplicationTest.h"

@implementation ContinuousReplicationTest

{
    int _sequence;
}



- (void) heartbeat {
    if (self.suspended)
        return;
    double teststart = CFAbsoluteTimeGetCurrent();
    double wait = 600;
    do {
        CouchReplication *op;
        op = [self.database pullFromDatabaseAtURL:[NSURL URLWithString:@"http://farshid:farshid@single.couchbase.net/_utils/database.html?cbstats"] options:kCouchReplicationContinuous];
    } while ([self.database getDocumentCount] < 10000);
    
    if (CFAbsoluteTimeGetCurrent() - teststart >= wait){    
        RESTOperation *com;
        com = [self.database compact];
    }
    
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
