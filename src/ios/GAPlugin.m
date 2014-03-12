#import "GAPlugin.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    NSString    *callbackId = command.callbackId;
    NSString    *accountID = [command.arguments objectAtIndex:0];
    NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:accountID];
    // Set the appVersion equal to the CFBundleVersion
    [[[GAI sharedInstance] defaultTracker] set:kGAIAppVersion value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds",accountID, dispatchPeriod] toID:callbackId];
}

-(void) exitGA:(CDVInvokedUrlCommand*)command
{
    NSString *callbackId = command.callbackId;

//    if (inited)
//        [[[GAI sharedInstance] defaultTracker] close];
//
    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    NSString        *callbackId = command.callbackId;
    NSString        *category = [command.arguments objectAtIndex:0];
    NSString        *eventAction = [command.arguments objectAtIndex:1];
    NSString        *eventLabel = [command.arguments objectAtIndex:2];
    NSInteger       eventValue = [[command.arguments objectAtIndex:3] intValue];
    NSError         *error = nil;

    if (inited)
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:category
            action:eventAction
            label:eventLabel
            value:[NSNumber numberWithInt:eventValue]] build]];
            [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %d", category, eventAction, eventLabel, eventValue] toID:callbackId];
    }
    else
        [self failWithMessage:@"trackEvent failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
    NSString            *callbackId = command.callbackId;
    NSString            *pageURL = [command.arguments objectAtIndex:0];

    if (inited)
    {
        NSError *error = nil;
        [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:pageURL];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];

        [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:callbackId];
    }
    else
        [self failWithMessage:@"trackPage failed - not initialized" toID:callbackId withError:nil];
}

- (void) setVariable:(CDVInvokedUrlCommand*)command
{
    NSString            *callbackId = command.callbackId;
    NSInteger           index = [[command.arguments objectAtIndex:0] intValue];
    NSString            *value = [command.arguments objectAtIndex:1];

    if (inited)
    {
        NSError *error = nil;
        [[[GAI sharedInstance] defaultTracker] set:[GAIFields customMetricForIndex:index] value:value];

        [self successWithMessage:[NSString stringWithFormat:@"setVariable: index = %d, value = %@;", index, value] toID:callbackId];
    }
    else
        [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
}

-(void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self writeJavascript:[commandResult toSuccessCallbackString:callbackID]];
}

-(void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self writeJavascript:[commandResult toErrorCallbackString:callbackID]];
}

-(void)dealloc
{
//    [[[GAI sharedInstance] defaultTracker] close];
   // [super dealloc];
}

@end