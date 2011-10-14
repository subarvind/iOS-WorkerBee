//
//  FilteredReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "FilteredReplicationTest.h"

@implementation FilteredReplicationTest

{
    int _sequence;
}

- (void) heartbeat {
    if (self.suspended)
        return;
    NSArray* idarray;    
    CouchQuery* que;
    que = [self.database getDocumentsWithIDs:idarray];    
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
