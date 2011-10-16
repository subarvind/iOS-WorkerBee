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
    // Create a CouchDB 'view' containing list items sorted by date:
    CouchDesignDocument* design = [self.database designDocumentWithName: @"test"];
    [design defineViewNamed: @"byDate"
                        map: @"function(doc) {if (doc.created_at) emit(doc.created_at, doc);}"];
    CouchLiveQuery* query = [[design queryViewNamed: @"byDate"] asLiveQuery];
    query.descending = YES;  // Sort by descending date, i.e. newest items first
    NSArray *repls = [self.database replicateWithURL:[NSURL URLWithString:@"http://farshid:farshid@single.couchbase.net/bitcoin"] exclusively:YES];
    _pull = [[repls objectAtIndex: 0] retain];
    _push = [[repls objectAtIndex: 1] retain];
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];   
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
