#import "LAListener.h"

@interface LAActivator
+ (LAActivator *)sharedInstance;
-(id)hasSeenListenerWithName:(id)arg1;
-(id)assignEvent:(id)arg1 toListenerWithName:(id)arg2;
-(id)registerListener:(id)arg1 forName:(id)arg2;
@end

@interface LAEvent
+(id)eventWithName:(id)arg1;
-(void)setHandled:(BOOL)arg1;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *mode;
@property (nonatomic, getter=isHandled) BOOL handled;
@property (nonatomic, copy) NSDictionary *userInfo;
@end

@interface AnySpotActivator : NSObject <LAListener>
@end



