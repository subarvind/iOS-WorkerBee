//
//  FilteredReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "FilteredReplicationTest.h"

//NSString *remotedb = @"http://farshid:farshid@single.couchbase.net/bitcoin";
CouchPersistentReplication* _pull;
CouchPersistentReplication* _push;
@implementation FilteredReplicationTest

{
    int _sequence;
}

- (void) heartbeat {
    if (self.suspended)
        return;
    double teststart = CFAbsoluteTimeGetCurrent();
    // Create a CouchDB 'view' containing list items sorted by date:
    CouchDesignDocument* design = [self.database designDocumentWithName: @"test"];
    [design defineViewNamed: @"byDate"
                        map: @"function(doc) {if (doc.date) emit(doc.date, doc);}"];
    CouchLiveQuery* query = [[design queryViewNamed: @"byDate"] asLiveQuery];
    query.descending = YES;  // Sort by descending date, i.e. newest items first
    CouchPersistentReplication* rep;
    rep = [self.database replicationFromDatabaseAtURL:[NSURL URLWithString:@"http://farshid:farshid@single.couchbase.net/bitcoin"]];
    [rep addObserver:self forKeyPath:@"completed" options:0 context:NULL];
    
    
    double testend = CFAbsoluteTimeGetCurrent();
    NSLog(@"Filtered Replication took: %f seconds",(testend - teststart));
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
