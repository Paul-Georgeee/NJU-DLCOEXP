#include <am.h>
#include <klib-macros.h>
#include <klib.h>
#include <handle.h>
#define HANDLE_LEN (sizeof(handle) / sizeof(handle[0]))

struct Handle{
    const char* name;
    void (*func) ();
};

struct Handle handle[] = {
    {"help", help},
    {"fib", fib},
    {"time", time},
    {"snake", snake},
    {"light", light},
    {"eval", eval},
    {"setsreg", setsreg},
    {"typinggame", typinggame},
    {"coremark", coremark},
    {"fail", fail}
};

void help()
{
    printf("help        fib         time        snake");
    putch('\n');
    printf("light       setsreg     typinggame  eval");
    putch('\n');
    printf("coremark");
    putch('\n');

}

void get_handle(char *str)
{
    int i = 0;
    
    for(i = 0; i < HANDLE_LEN - 1; ++i)
    {
        if(strcmp(str, handle[i].name) == 0)
        {
            handle[i].func();
            return;
        }
    }
    handle[i].func();
    return;
}
int main()
{
    char str[80];
    printf("Prompt : ");
    while(gets(str))
    {
        get_handle(str);
        printf("Prompt : ");
    }
}