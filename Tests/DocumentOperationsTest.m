//
//  DocumentOperationsTest.m
//  Worker Bee
//
//  Created by Arvind on 10/6/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//


#import "BeeCouchTest.h"
#import "AppDelegate.h"

@interface DocumentOperationsTest : BeeCouchTest

@end



#define kDocumentBatchSize 10000
NSString *remotedb = @"http://sidius.iriscouch.com/test"; 
@implementation DocumentOperationsTest

{
    int _sequence;
}



- (void) heartbeat {
    if (self.suspended)
        return;
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self logFormat: @"Adding docs %i--%i ...",
     _sequence+1, _sequence+kDocumentBatchSize];
    for (int i = 0; i < kDocumentBatchSize; i++) {
        ++_sequence;
        NSString* dateStr = [RESTBody JSONObjectWithDate: [NSDate date]];
        CFUUIDRef uuid = CFUUIDCreate(nil);
        NSString *guid = (NSString*)CFUUIDCreateString(nil, uuid);
        CFRelease(uuid);
        NSString *docId = [NSString stringWithFormat:@"%@-%@", dateStr, guid];
        //NSLog(@"added %i", _sequence);
        [guid release];
        [ids insertObject:docId atIndex:i];
        
        NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt: _sequence], @"sequence",
                               dateStr, @"date", nil];
        CouchDocument* doc = [self.database documentWithID:docId];
        RESTOperation* op = [doc putProperties: props];
        [op onCompletion: ^{
            if (op.error) {
                [self logFormat: @"!!! Failed to create doc %@", props];
                self.error = op.error;
            }
        }]; 
        
    }
    
    CouchPersistentReplication* rep;
    rep = [self.database replicationToDatabaseAtURL:[NSURL URLWithString:remotedb]];
    
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
