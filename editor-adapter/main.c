#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>

#include "sockets.h"
#include "debug.h"
#include "server_port.h"

static const int VALID_ARGUMENT_COUNT = 2;
static const int FILENAME_ARGUMENT_INDEX = 1;
static const char LOCALHOST[] = "127.0.0.1"; 
static const uint8_t DEFAULT_RESPONSE = 1;
static const uint8_t SUCCESS_RESPONSE = 0;

void validate_argument_count(
    const int argc
)
{
    if (argc != VALID_ARGUMENT_COUNT) 
    {
        debug_print(
            "Invalid number of arguments: %d, must be %d.\n", 
            argc - 1,
            VALID_ARGUMENT_COUNT - 1
        );
        exit(EXIT_FAILURE);
    }
    debug_print("Valid number of arguments received.\n");
}

void parse_filename(
    char *const argv[],
    char **filename
)
{
    *filename = argv[FILENAME_ARGUMENT_INDEX];
    errno = 0;
    FILE *file = fopen(*filename, "r");
    if (!file || errno) 
    {
        fclose(file);
        debug_print("File does not exist: %s.\n", *filename);
        print_error();
        exit(EXIT_FAILURE);
    }
    fclose(file);
    debug_print("File does exist: %s.\n", *filename);
}

void parse_arguments(
    const int argc, 
    char *const argv[], 
    char **filename
) 
{
    validate_argument_count(argc);
    parse_filename(argv, filename);
}

int prepare_socket()
{
    int sockfd = 0;
    errno = 0;
    if ((sockfd = socket_create()) < 0 || errno) 
    {
        debug_print("Error creating socket.\n");
        print_error();
        exit(EXIT_FAILURE);
    }
    debug_print("Socket created successfully.\n");

    errno = 0;
    if (socket_connect(sockfd, LOCALHOST, SERVER_PORT) < 0 || errno)
    {
        debug_print("Error connecting to server.\n");
        print_error();
        exit(EXIT_FAILURE);
    }
    debug_print("Connected to server successfully.\n");

    return sockfd;
}

uint8_t communicate(
    const int sockfd, 
    const char* filename
)
{
    const size_t filename_length = strlen(filename);
    errno = 0;
    if (socket_send(sockfd, filename, filename_length + 1) < 0 || errno) {
        debug_print("Error sending filename.\n");
        print_error();
        exit(EXIT_FAILURE);
    }
    debug_print("Sent filename successfully.\n");

    uint8_t response = DEFAULT_RESPONSE;
    errno = 0;
    if (socket_receive(sockfd, (char*)&response, sizeof(response)) < 0 || errno) {
        debug_print("Error receiving response.\n");
        print_error();
        exit(EXIT_FAILURE);
    }
    debug_print("Received response: %d.\n", response);

    socket_close(sockfd);

    return response;
}

int main(
    const int argc,
    char *argv[]
) 
{
    char *filename = NULL;
    parse_arguments(argc, argv, &filename);

    const int sockfd = prepare_socket();
    const uint8_t response = communicate(sockfd, filename);

    if (response == SUCCESS_RESPONSE) {
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}