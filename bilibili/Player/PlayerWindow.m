//
//  PlayerWindow.m
//  bilibili
//
//  Created by TYPCN on 2016/3/4.
//  Copyright © 2016 TYPCN. All rights reserved.
//

#import "PlayerWindow.h"

@implementation PlayerWindow{
    
}

@synthesize postCommentWindowC;

BOOL paused = NO;
BOOL hide = NO;
BOOL obServer = NO;
BOOL isFirstCall = YES;
BOOL shiftKeyPressed = NO;
BOOL frontMost = NO;

- (BOOL)canBecomeMainWindow { return YES; }
- (BOOL)canBecomeKeyWindow { return YES; }

- (NSArray *)customWindowsToEnterFullScreenForWindow:(NSWindow *)window{
    return nil;
}

- (void)window:(NSWindow *)window
startCustomAnimationToEnterFullScreenWithDuration:(NSTimeInterval)duration{
    
}

- (NSSize)windowWillResize:(NSWindow *)sender
                    toSize:(NSSize)frameSize{
    if(!obServer){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
        obServer = YES;
    }else{
        if(self.player.mpv){
            dispatch_async(self.player.queue, ^{
                if(strcmp(mpv_get_property_string(self.player.mpv,"pause"),"yes")){
                    mpv_set_property_string(self.player.mpv,"pause","yes");
                }
            });
        }
    }
    // Save window size
    [[NSUserDefaults standardUserDefaults] setDouble:frameSize.width forKey:@"playerwidth"];
    [[NSUserDefaults standardUserDefaults] setDouble:frameSize.height forKey:@"playerheight"];
    return frameSize;
}
- (void)windowDidResize:(NSNotification *)notification{
    [self performSelector:@selector(Continue) withObject:nil afterDelay:1.0];
}

- (void)Continue{
    if(self.player.mpv && !isFirstCall){
        dispatch_async(self.player.queue, ^{
            if(strcmp(mpv_get_property_string(self.player.mpv,"pause"),"no")){
                mpv_set_property_string(self.player.mpv,"pause","no");
            }
        });
    }else{
        isFirstCall = NO;
    }
}

- (void)flagsChanged:(NSEvent *) event {
    shiftKeyPressed = ([event modifierFlags] & NSShiftKeyMask) != 0;
}

- (void)keyDown:(NSEvent*)event {
    
    [self flagsChanged:event];
    
    if(!self.player.mpv){
        return;
    }
    switch( [event keyCode] ) {
        case 125:{ // ⬇️
            dispatch_async(self.player.queue, ^{
                int volume = atoi(mpv_get_property_string(self.player.mpv,"volume"));
                if(volume < 5){
                    return;
                }
                char volstr[4];
                snprintf(volstr , 4, "%d", volume - 5);
                NSLog(@"Volume: %s",volstr);
                mpv_set_property_string(self.player.mpv,"volume",volstr);
            });
            break;
        }
        case 126:{ // ⬆️
            dispatch_async(self.player.queue, ^{
                int volume = atoi(mpv_get_property_string(self.player.mpv,"volume"));
                if(volume > 94){
                    return;
                }
                char volstr[3];
                snprintf(volstr , 4, "%d", volume + 5);
                NSLog(@"Volume: %s",volstr);
                mpv_set_property_string(self.player.mpv,"volume",volstr);
            });
            break;
        }
        case 124:{ // 👉
            dispatch_async(self.player.queue, ^{
                const char *args[] = {"seek", shiftKeyPressed?"1":"5" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 123:{ // 👈
            dispatch_async(self.player.queue, ^{
                const char *args[] = {"seek", shiftKeyPressed?"-1":"-5" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 49:{ // Space
            dispatch_async(self.player.queue, ^{
                if(strcmp(mpv_get_property_string(self.player.mpv,"pause"),"no")){
                    mpv_set_property_string(self.player.mpv,"pause","no");
                }else{
                    mpv_set_property_string(self.player.mpv,"pause","yes");
                }
            });
            break;
        }
        case 36:{ // Enter
            if(self.player.mpv){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
                    postCommentWindowC = [storyBoard instantiateControllerWithIdentifier:@"PostCommentWindow"];
                    [postCommentWindowC showWindow:self];
                });
            }
            break;
        }
        case 53:{ // Esc key to hide mouse
            // Nothing to do
            break;
        }
        case 3:{
            NSUInteger flags = [[NSApp currentEvent] modifierFlags];
            if ((flags & NSCommandKeyMask)) {
                [self toggleFullScreen:self]; // Command+F key to toggle fullscreen
            }else if(frontMost){
                [self setLevel:NSNormalWindowLevel];
                frontMost = NO;
            }else{
                [self setLevel:NSScreenSaverWindowLevel + 1]; // F key to front most
                [self orderFront:nil];
                frontMost = YES;
            }
            break;
        }
        case 51:{ // BACKSPACE
            dispatch_async(self.player.queue, ^{
                mpv_set_property_string(self.player.mpv,"speed","1");
            });
            break;
        }
            
        default:
            [self handleKeyboardEvnet:event keyDown:YES];
            break;
    }
}

-(void)keyUp:(NSEvent*)event {
    
    [self flagsChanged:event];
    
    if(!self.player.mpv){
        return;
    }
    
    [self handleKeyboardEvnet:event keyDown:NO];
    
}

- (void)handleKeyboardEvnet:(NSEvent *)event keyDown:(BOOL)keyDown {
    
    const char *keyState = keyDown?"keydown":"keyup";
    
    switch ( [event keyCode] ) {
        case 1:{ // s
            const char *args[] = {keyState, shiftKeyPressed?"S":"s", NULL};
            mpv_command(self.player.mpv, args);
            break;
        }
        case 9:{ // v
            const char *args[] = {keyState, shiftKeyPressed?"V":"v", NULL};
            mpv_command(self.player.mpv, args);
            break;
        }
        case 31:{ // o
            const char *args[] = {keyState, shiftKeyPressed?"O":"o", NULL};
            mpv_command(self.player.mpv, args);
            break;
        }
        case 43:{ // ,
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, shiftKeyPressed?"<":"," ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 47:{ // .
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, shiftKeyPressed?">":"." ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 33:{ // [{
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, shiftKeyPressed?"{":"[" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 30:{ // ]}
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, shiftKeyPressed?"}":"]" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 6:{ // z
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, "z" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 7:{ // x
            dispatch_async(self.player.queue, ^{
                const char *args[] = {keyState, "x" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        case 37:{ // l
            dispatch_sync(self.player.queue, ^{
                const char *args[] = {keyState, shiftKeyPressed?"L":"l" ,NULL};
                mpv_command(self.player.mpv, args);
            });
            break;
        }
        default: // Unknow
            NSLog(@"Key pressed: %hu", [event keyCode]);
            break;
    }
}

- (void) mpv_stop
{
    if (self.player.mpv) {
        dispatch_async(self.player.queue, ^{
            const char *args[] = {"stop", NULL};
            mpv_command(self.player.mpv, args);
        });
    }
}

- (void) mpv_quit
{
    if (self.player.mpv) {
        dispatch_async(self.player.queue, ^{
            const char *args[] = {"quit", NULL};
            mpv_command(self.player.mpv, args);
        });
    }
}

- (BOOL)windowShouldClose:(id)sender{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastPlay"];
    NSLog(@"Removing lastplay url");
    if(obServer){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
        obServer = NO;
    }
    dispatch_async(self.player.queue, ^{
        if(self.player.mpv){
            mpv_set_wakeup_callback(self.player.mpv, NULL,NULL);
        }
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setDouble:self.frame.origin.x forKey:@"playerX"];
        [[NSUserDefaults standardUserDefaults] setDouble:self.frame.origin.y forKey:@"playerY"];
        [self mpv_stop];
        [self mpv_quit];
        [postCommentWindowC close];
        if([browser tabCount] > 0){
            [self.lastWindow makeKeyAndOrderFront:nil];
        }
    });
    return YES;
}

@end