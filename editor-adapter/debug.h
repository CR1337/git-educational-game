#ifndef __DEBUG_H
#define __DEBUG_H

#include <errno.h>
#include <string.h>
#include <stdio.h>

#ifdef _DEBUG
void debug_print(const char *message, ...)
{
    va_list args;
    va_start(args, message);
    vfprintf(stderr, message, args);
    va_end(args);
}

void print_error()
{
    if (!errno)
    {
        return;
    }
    
    fprintf(
        stderr,
        "\t(%d): %s\n",
        errno,
        strerror(errno)
    );
}
#else
void debug_print(const char *message, ...) {}
void print_error() {}
#endif


#endif