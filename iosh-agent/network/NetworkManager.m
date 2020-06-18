//
//  NetworkManager.m
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#import "NetworkManager.h"
#import "HookerManager.h"
//#import "writeData.h"
#define RESPONSE_MAX_LEN 255
#define BUFF_SIZE        255
#define OPCODE_SIZE      1

// WILL BE USED..
typedef struct IOSH_OPERATION{
    unsigned int data_length;
    unsigned char* client_data;
} IOSH_OPERATION;

// WILL BE USED..
typedef struct IOSH_RESPONSE{
    unsigned int response_message_length;
    unsigned char response[RESPONSE_MAX_LEN];
} IOSH_RESPONSE;


@implementation NetworkManager

-(int)doProcess{
    NSLog(@"NetworkManager doProcess");
    int   server_socket;
    int   client_socket;
    int   client_addr_size;
    char  buff_snd[BUFF_SIZE] = {0,};
    
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    

    server_socket = socket( PF_INET, SOCK_STREAM, 0);
    if( -1 == server_socket){
        NSLog(@"server_socket is -1");
        return -1;
    }
    
    memset( &server_addr, 0, sizeof( server_addr));
    server_addr.sin_family     = AF_INET;
    server_addr.sin_port       = htons( 36003 );
    server_addr.sin_addr.s_addr= htonl( INADDR_ANY);
    
    if( -1 == bind( server_socket, (struct sockaddr*)&server_addr, sizeof( server_addr) ) ){
        NSLog(@"bind -1");
        close(server_socket);
        return -1;
    }
    
    if( -1 == listen(server_socket, 5)){
        NSLog(@"listen -1");
        close(server_socket);
        return -1;
    }
    
    self.hook_manager = [[HookerManager alloc] init];
    dispatch_queue_t hooking_handler_queue = dispatch_queue_create("hooking_handler_queue", NULL);
    NSLog(@"HookerManager init");
    __block int ret = -1;
    
    dispatch_async(hooking_handler_queue, ^{
        while(1){
            __block client_addr_size  = sizeof( client_addr);
            __block client_socket     = accept( server_socket, (struct sockaddr*)&client_addr, &client_addr_size);
            uint8_t buff_size = 0;
            uint8_t buff_rcv[BUFF_SIZE] = {0,};
            
            __block uint8_t * opcode = malloc(OPCODE_SIZE);
            __block uint8_t * data1;
            __block uint8_t * data2;
            
            if ( -1 == client_socket){
                NSLog(@"client_socket -1");
                return;
            }

            read ( client_socket, &buff_size, 1);
            NSLog(@"buff size: %d", buff_size);
            if( !buff_size ){
                uint8_t each_data_size = (buff_size - OPCODE_SIZE) /2;
                data1  = malloc(each_data_size);
                data2  = malloc(each_data_size);
                
                read ( client_socket, opcode, OPCODE_SIZE);
                read ( client_socket, data1 , each_data_size);
                read ( client_socket, data2 , each_data_size);
                NSLog( @"RECV OPCODE: %02x", opcode);
                NSLog( @"RECV DATA1 : %08x", data1);
                NSLog( @"RECV DATA2 : %08x", data2);
            }
            NSLog( @"hook_manager doProcess");
            NSLog( @"OPCODE: %s", opcode);
            NSLog( @"DATA1 : %08x", data1);
            NSLog( @"DATA2 : %08x", data2);
            
            ret = [self.hook_manager doProcess:opcode[0] operand1:data1 operand2:data2];

            write( client_socket, &ret, sizeof(int));
            close( client_socket);
        }
    });
    return ret;
}

@end
