//
//  FilteredReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/24/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//


#import "BeeCouchTest.h"
#import "AppDelegate.h"

@interface FilteredReplicationTest : BeeCouchTest
@end

#define kDocumentBatchSize 10000
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
    rep = [self.database replicationFromDatabaseAtURL:[NSURL URLWithString:@"http://sidius.iriscouch.com/test"]];
    [rep addObserver:self forKeyPath:@"completed" options:0 context:NULL];
    
    
    double testend = CFAbsoluteTimeGetCurrent();
    NSLog(@"Filtered Replication took: %f seconds",(testend - teststart));
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"completed"]) {
        for (int i = 0; i < kDocumentBatchSize; i++) {
            ++_sequence;
            NSString* dateStr = [RESTBody JSONObjectWithDate: [NSDate date]];
            CFUUIDRef uuid = CFUUIDCreate(nil);
            NSString *guid = (NSString*)CFUUIDCreateString(nil, uuid);
            CFRelease(uuid);
            NSString *docId = [NSString stringWithFormat:@"%@-%@", dateStr, guid];
            //NSLog(@"added %i", _sequence);
            [guid release];
            NSString* changedName = [change objectForKey:NSKeyValueChangeNewKey];
            NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: _sequence], @"sequence",
                                   [NSString stringWithFormat:changedName],@"nameupdate",
                                   dateStr, @"date", nil];
            CouchDocument* doc = [self.database documentWithID:docId];
            RESTOperation* op = [doc putProperties: props];
            [op onCompletion: ^{
                if (op.error) {
                    [self logFormat: @"!!! Failed to create doc %@", props];
                    self.error = op.error;
                }
            }]; 
            
            // do something with the changedName - call a method or update the UI here
            //self.nameLabel.text = changedName;
        }    
    }
}


- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
