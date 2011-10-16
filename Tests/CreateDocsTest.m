//
//  CreateDocsTest.m
//  Worker Bee
//
//  Created by Arvind on 10/13/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import "CreateDocsTest.h"

#define kDocumentBatchSize 100
double updateduration = 10;

@implementation CreateDocsTest
{
    int _sequence;
}

- (void) heartbeat {
    if (self.suspended)
        return;
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:kDocumentBatchSize];
    
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
    
    double teststart = CFAbsoluteTimeGetCurrent();
    
    while ((CFAbsoluteTimeGetCurrent() - teststart) < updateduration) {
        for (int j=0; j<kDocumentBatchSize; j++) {
            NSString *docid = [ids objectAtIndex:j];
            CouchDocument *docupdate = [self.database documentWithID:docid];
            //NSString *update = docupdate.currentRevisionID;
            NSString* dateStr = [RESTBody JSONObjectWithDate: [NSDate date]];
            // CouchDocument *udoc = [self.database documentWithID:update];
            NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: _sequence], @"sequence",
                                   dateStr, @"date", nil];
            //NSLog(@"updated %f",(CFAbsoluteTimeGetCurrent() - teststart));
            RESTOperation* op = [docupdate.currentRevision putProperties:props];
            //RESTOperation* op = [udoc putProperties: props];
            [op onCompletion: ^{
                if (op.error) {
                    [self logFormat: @"!!! Failed to create doc %@", props];
                    self.error = op.error;
                }
            }];             
            
        }
        NSLog(@"time is: %f", CFAbsoluteTimeGetCurrent());
    }
    
    for (int j=0; j<(kDocumentBatchSize/10); j++) { //change attachment content
        NSString *docid = [ids objectAtIndex:j];
        CouchDocument *docupdate = [self.database documentWithID:docid];
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"png"];   
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath]; 
        CouchAttachment *attach = [docupdate.currentRevision createAttachmentWithName:@"photo" type:@"image/jpeg"];
        RESTOperation* op;                            
        op = [attach PUT: UIImagePNGRepresentation(prodImg) contentType: @"image/jpeg"];
        NSLog(@"attachment added: %@", docid);
    }
    
    NSMutableArray *delids = [[NSMutableArray alloc] initWithCapacity:(kDocumentBatchSize/10)];   
    // NSMutableArray *deldicts = [[NSMutableArray alloc] initWithCapacity:(kDocumentBatchSize/10)];
    for (int k=0; k<(kDocumentBatchSize/10); k++) {
        NSString *docid = [ids objectAtIndex:k];
        CouchDocument *docdel = [self.database documentWithID:docid];
        // [deldicts insertObject:docdel atIndex:k];
        NSString *update = docdel.currentRevisionID;
        CouchDocument *udoc = [self.database documentWithID:update];
        // NSString *docdelid = docdel.currentRevisionID;
        [delids addObject:udoc];
    }
    
    //add back del docs
       for (int k=0; k<(kDocumentBatchSize/10); k++) {
           NSString* dateStr = [RESTBody JSONObjectWithDate: [NSDate date]];
           CFUUIDRef uuid = CFUUIDCreate(nil);
           NSString *guid = (NSString*)CFUUIDCreateString(nil, uuid);
           CFRelease(uuid);
           NSString *docId = [NSString stringWithFormat:@"%@-%@", dateStr, guid];
           //NSLog(@"added %i", _sequence);
           [guid release];
           NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt: k], @"sequence",
                                  dateStr, @"date", nil];
           CouchDocument* doc = [self.database documentWithID:docId];
           RESTOperation* op;
           op = [doc putProperties: props];
           NSString *thePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"png"];   
           UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath]; 
           CouchAttachment *attach = [doc.currentRevision createAttachmentWithName:@"photo" type:@"image/jpeg"];
           op = [attach PUT: UIImagePNGRepresentation(prodImg) contentType: @"image/jpeg"];
           [op onCompletion: ^{
               if (op.error) {
                   [self logFormat: @"!!! Failed to create doc %@", props];
                   self.error = op.error;
               }
           }];
       }
    
    
    
    NSLog(@"to be deleted %@", delids);
    RESTOperation* op;
    op = [self.database deleteDocuments:delids];
    op = [self.database compact];
    [op onCompletion: ^{
        if (op.error) {
            [self logFormat: @"!!! Failed to create doc"];
            self.error = op.error;
        }
        // NSLog(docId "added");
        self.status = [NSString stringWithFormat: @"Created %i docs", _sequence];
    }];
    
    //add map reduce function
    // Create a CouchDB 'view' containing list items sorted by date:
    CouchDesignDocument* design = [self.database designDocumentWithName: @"test"];
    [design defineViewNamed: @"byDate"
                        map: @"function(doc) {if (doc.created_at) emit(doc.created_at, doc);}"];
    CouchLiveQuery* query = [[design queryViewNamed: @"byDate"] asLiveQuery];
    query.descending = YES;  // Sort by descending date, i.e. newest items first
}

- (void) setUp {
    [super setUp];
    _sequence = 0;
    self.heartbeatInterval = 10;
}

@end
