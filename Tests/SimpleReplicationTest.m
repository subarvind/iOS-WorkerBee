//
//  SimpleReplicationTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//
#import "BeeCouchTest.h"
#import "AppDelegate.h"

@interface SimpleReplicationTest : BeeCouchTest
@end


//NSString* remotedb = @"http://admin:northscale!23@ec2-50-16-117-7.compute-1.amazonaws.com:5984/ios-tests";

@implementation SimpleReplicationTest

{
    int _sequence;
}



- (void) heartbeat {
    if (self.suspended)
        return;
    
    double teststart = CFAbsoluteTimeGetCurrent();
    CouchPersistentReplication* rep;
    rep = [self.database replicationFromDatabaseAtURL:[NSURL URLWithString:@"http://subarvind:stein*#*@ec2-50-16-117-7.compute-1.amazonaws.com:5984/ipaddr"]];
    double testend = CFAbsoluteTimeGetCurrent();
    NSLog(@"Simple Replication took: %f seconds", (testend - teststart));
}



- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
