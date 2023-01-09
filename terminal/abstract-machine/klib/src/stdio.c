#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

static int putnum(unsigned int num, char *bits)
{
    int cnt = 0;
    if(num == 0)
    {
        bits[0] = '0';
        bits[1] = '\0';
        return 1;
    }
    while(num !=0)
    {
        bits[cnt] = (char)(num % 10) + '0';
        cnt++;
        num /= 10;
    }
    for(int i = 0, j = cnt -1; i < j; ++i, --j)
    {
        char temp =bits[i];
        bits[i] = bits[j];
        bits[j] = temp;
    }
    bits[cnt] = '\0';
    return cnt;
}

static void getstr(char *str)
{
    char ch = getchar();
    while(ch == ' ' || ch == '\n')
        ch = getchar();
    int cnt = 0;
    while(ch != 0 && ch != ' ' && ch != '\n')
    {
        str[cnt] = ch;
        ++cnt;
        ch = getchar();
    }
    str[cnt] = '\0';
    
}

static int getnum()
{
    char ch = getchar();
    while(ch == ' ' || ch == '\n')
        ch = getchar();
    int negative = 0;
    if(ch == '-')
    {
        negative = 1;
        ch = getchar();
    }
    // 没有处理 - 11111 这种情况

    int num = 0;
    while(ch >= '0' && ch <= '9')
    {
        num = num * 10 + ch - '0';
        ch = getchar();
    }

    if(negative == 1)
        return -num;
    else
        return num;
}

int printf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int cnt = 0;
    char bits[15];

    for(int i = 0; fmt[i] != '\0'; ++i)
    {
        if(fmt[i] != '%')
        {
           
          putch(fmt[i]);
          cnt++;
        }
        else
        {
            i++;
            char ch;
            char *str;
            int num;
            switch(fmt[i])
            {
                case 'c':
                    ch = (char)va_arg(ap, int);
                    cnt++;
                    putch(ch);
                    break;
                case 's':
                    str = va_arg(ap, char*);
                    cnt += strlen(str);
                    putstr(str);
                    break;
                case 'd':
                    num = va_arg(ap, int);
                    if(num < 0)
                    {
                        putch('-');
                        num = -num;
                    }
                    cnt += putnum((unsigned int)num, bits);
                    putstr(bits);
                    break;
                default:
                    putstr("undefine output format\n");
                    return -1;
            }
        }
    }
    va_end(ap);
    return cnt;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
    panic("Not implemented");

}

int sprintf(char *out, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int len = 0;
    int cnt = 0;
    for(int i = 0; fmt[i] != '\0'; ++i)
    {
        if(fmt[i] != '%')
        {
            out[cnt] = fmt[i];
            cnt++;
        }
        else
        {
            i++;
            char ch;
            int num;
            char *str;
            char bits[15];
            switch(fmt[i])
            {
                case 'c':
                    ch = (char)va_arg(ap, int);
                    out[cnt] = ch;
                    cnt++;
                    break;
                case 's':
                    str = va_arg(ap, char*);
                    out[cnt] = '\0';
                    strcat(out, str);
                    cnt += strlen(str);
                    break;
                case 'd':
                    num = va_arg(ap, int);
                    if(num < 0)
                    {
                        out[cnt] = '-';
                        ++cnt;
                        num = -num;
                    }
                    out[cnt] = '\0';
                    cnt += putnum((unsigned int)num, bits);
                    strcat(out, bits);
                    break;
                default:
                    //putstr("undefine output format\n");
                    return -1;
            }
        }
    }
    va_end(ap);
    out[cnt] = '\0';
    return cnt;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int puts(const char* str)
{
  putstr(str);
  return strlen(str);
}

int putchar(char c)
{
    putch(c);
    return (int)c;
}

int scanf(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    for(int i = 0; fmt[i] != '\0'; ++i)
    {
        if(fmt[i] != '%')
        {
            char ch = getchar();
            if(ch != fmt[i])
            {
                //TODO()
                //not match. error
                ;
            }
        }
        else
        {
            ++i;
            char *str;
            int *num;
            switch(fmt[i])
            {
                case 'c':
                    str = va_arg(ap, char*);
                    *str = getchar();
                    break;
                case 's':
                    str = va_arg(ap, char*);
                    getstr(str);
                    break;
                case 'd':
                    num = va_arg(ap, int*);
                    *num = getnum();
                    break;
            }
        }
    }
    return 0;
}

char* gets(char* str)
{
    char ch = getchar();
    while(ch == ' ')
        ch = getchar();
    int cnt = 0;
    while(ch != 0 && ch != '\n')
    {
        str[cnt] = ch;
        ++cnt;
        ch = getchar();
    }
    str[cnt] = '\0';
    return str;
}


