#include <handle.h>
#include <am.h>
#define SEG_START 0x00700000
#define LED_START 0x00600000

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }

int cal_fib(int a)
{
    if(a <= 1)
        return 1;
    else
        return cal_fib(a - 1) + cal_fib(a -2);
}

void fib()
{
    puts("Please enter a num: ");
    int num;
    scanf("%d", &num);
    printf("Result: %d\n", cal_fib(num));
}

void sleep(int sec)
{
    int before, now;
    now =(int) get_second();
    before = now;
    while(now - before < sec)
    {
        now = (int)get_second();
    }
}

void light()
{
    printf("Please enter the num of the led you want to light: ");
    int num;
    scanf("%d", &num);
    outb(LED_START + num, 1);

}
void time()
{
    printf("time : %ds\n", (int)get_second());    
}

void fail()
{
    printf("unknow command \n");
    putch('\n');
}

void setsreg()
{
    printf("Please enter the val of six sreg by order: ");
    char str[20] = "0000000000";
    gets(str);
    // puts(str);
    for(int i = 5; i >= 0; --i)
    {
        if(str[i] >= '0' && str[i] <= '9')
        {
            outb(SEG_START + i, str[i] - '0');
        }
        else if(str[i] >= 'A' && str[i] <= 'F')
        {
            outb(SEG_START + i, str[i] - 'A' + 10);
        }
        else if(str[i] >= 'a' && str[i] <= 'f')
        {
            outb(SEG_START + i, str[i] - 'a' + 10);
        }
        else
        {
            printf("error! Please enter the correct val between 0~f");
            putch('\n');
        }
    }
}


void help()
{
    printf("help        fib         time        snake");
    putch('\n');
    printf("light       setsreg     typinggame  eval");
    putch('\n');
    printf("coremark");
    putch('\n');

}