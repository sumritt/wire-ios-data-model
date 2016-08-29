// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 

#import "NSManagedObjectContext+TestHelpers.h"

@class NSManagedObjectContext;
@class ZMManagedObject;
@class ZMUser;


/// This class provides a fixture for running tests against our data model.
@interface ZMManagedObjectContextTestFixture : NSObject

- (instancetype)initWithDispatchGroup:(ZMSDispatchGroup *)dispatchGroup;

/// If useInMemoryStore is set to YES an in memory store is used. Defaults to YES.
@property (nonatomic) BOOL shouldUseInMemoryStore;

/// If shouldUseRealKeychain is set to YES the real keychain is accessed. Defaults to NO
@property (nonatomic) BOOL shouldUseRealKeychain;

@property (nonatomic, readonly) NSManagedObjectContext *uiMOC;
@property (nonatomic, readonly) NSManagedObjectContext *syncMOC;
@property (nonatomic, readonly) NSManagedObjectContext *searchMOC;

/// Prepare the fixture for running a test.
- (void)prepareForTestNamed:(NSString *)testName;

/// Waits for queues and managed object contexts to finish work and verifies mocks
- (void)tearDown;

/// Resets UI and Sync contexts
- (void)resetUIandSyncContextsAndResetPersistentStore:(BOOL)resetPersistantStore;

/// Perform operations pretending that the uiMOC is a syncMOC
- (void)performPretendingUiMocIsSyncMoc:(void(^)(void))block;

/// Wait until all contexts have completed their task and tear them down
- (void)waitAndDeleteAllManagedObjectContexts;

@end


@interface ZMManagedObjectContextTestFixture (FilesInCache)

/// Sets up the asset caches on the managed object contexts
- (void)setUpCaches;

/// Wipes the asset caches on the managed object contexts
- (void)wipeCaches;

@end
