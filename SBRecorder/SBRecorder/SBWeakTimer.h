

#import <Foundation/Foundation.h>

typedef void (^SBTimerHandler)(id userInfo);

@interface SBWeakTimer : NSObject

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(SBTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

@end
