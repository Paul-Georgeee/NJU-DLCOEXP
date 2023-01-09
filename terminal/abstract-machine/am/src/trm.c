#include <am.h>
#include <nemu.h>
// extern char _heap_start;
int main();

static char transform_table[10] = {')', '!', '@', '#', '$', '%', '^', '&', '*', '('};
static int flag = 1;
void set_font_vmem(int a)
{
    flag = a;
}
uint32_t has_prompt[64] = { 0 };

static char table[256] = {
    0, 0, 0, 0, 0, 0, 0, 0,     //00-07
    0, 0, 0, 0, 0, 0, '`', 0,     //08-0f
    0, 0, 0, 0, 0, 'q', '1', 0,     //10-17
    0, 0, 'z', 's', 'a', 'w', '2', 0,   //18-1f    
    0, 'c', 'x', 'd', 'e', '4', '3', 0,     //20-27
    0, ' ', 'v', 'f', 't', 'r', '5', 0,     //28-2f
    0, 'n', 'b', 'h', 'g', 'y', '6', 0,     //30-37
    0, 0, 'm', 'j', 'u', '7', '8', 0,     //38-3f
    0, ',', 'k', 'i', 'o', '0', '9', 0,     //40-47
    0, '.', '/', 'l', ';', 'p', '-', 0,     //48-4f
    0, 0, '\'', 0, '[', '=', 0, 0,     //50-57
    0, 0, '\n', ']', 0, '\\', 0, 0,     //58-5f
    0, 0, 0, 0, 0, 0, 0, 0,     //60-6f
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
};

uint32_t vga_line = 0;
uint32_t vga_ch = 0;
uint32_t start_line = 0;
Area heap = RANGE(0, 0);

// static const char mainargs[] = MAINARGS;

void putch(char ch)
{
    if (ch == 8) //backspace
    {
        vga_ch++;
        outl(VGA_COL, vga_ch);
        return;
    }
    if (ch == 10) //enter
    {
        if(vga_line == 29)  
        {
            start_line++;   //如果已到了最后一行 则row_start需要加1 从而实现向下滚屏
            outl(VGA_ROW_START, start_line);
            vga_ch = 0;
        }
        else
        {   vga_line++;
            vga_ch = 0;
        }
        outl(VGA_COL, vga_ch);
        outl(VGA_ROW, vga_line);
        return;
    }
    outb(VGA_START + ((vga_line + start_line) << 7) + vga_ch, ch);  //向显存写入ascii码
    vga_ch++;
    if (vga_ch >= VGA_MAXCOL)   //一列已输满 要换行
    {
        if(vga_line == 29)
        {
            start_line++;   //向下滚屏
            outl(VGA_ROW_START, start_line);
            vga_ch = 0;
        }
        else
        {
            vga_line++;
            vga_ch = 0;
        }
    }

    outl(VGA_COL, vga_ch);
    outl(VGA_ROW, vga_line);
    return;
}


void halt(int code) {
  if(code == 1)
  {
    putstr("error\n");
  }
  else
  {
    putstr("nice\n");
  }
  while (1);
}

void _trm_init() {
  int ret = main();
  halt(ret);
}


#define BUFF_SIZE 200

static int is_capslk, is_shift;

struct Buff{
    char q[BUFF_SIZE];
    unsigned int head;
    unsigned int tail;
};
static struct Buff key_buff;


static uint8_t read_scancode()
{
    uint8_t scancode = inb(KEY_START);
    if(scancode != 0)
        outb(KEY_HEAD, inb(KEY_HEAD) + 1);
    return scancode;
}

void buff_init()
{
    key_buff.head = 0;
    key_buff.tail = 0;
}

static char read_buff()
{
    if(key_buff.head == key_buff.tail)
        return 0;   //empty
    else
    {
        char c = key_buff.q[key_buff.head];
        key_buff.head = (key_buff.head + 1) % BUFF_SIZE;
        return c;
    }
}

static void write_buff(char c)
{
    if((key_buff.tail + 1) % BUFF_SIZE == key_buff.head)
        return ;        //full
    else
    {
        putch(c);
        key_buff.q[key_buff.tail] = c;
        key_buff.tail = (key_buff.tail + 1) % BUFF_SIZE;
        return;
    }
}

static void delete_char()
{
    if(key_buff.head == key_buff.tail)
    {
        return ;
    }
    else
    {
        // TODO()
        // 显存删除一个字符
        
        
            if(vga_ch == 0)     //需要往上退一行
            {
                vga_ch = VGA_MAXCOL - 1;
                outl(VGA_COL, vga_ch);
                if(vga_line == 0 && start_line != 0)    //判断是否需要向上滚屏
                {
                    start_line--;
                    outl(VGA_ROW_START, start_line);
                }
                else if(vga_line != 0)   
                {
                    vga_line--;
                    outl(VGA_ROW, vga_line);
                }    
            }
            else
            {
                outb(VGA_START + ((vga_line + start_line) << 7) + vga_ch, 0);
                vga_ch--;
                outl(VGA_COL, vga_ch);
            }
        
        key_buff.tail = (key_buff.tail - 1) % BUFF_SIZE;
    }
}

static void keyboard_to_buff()
{
    char scancode;
    char ch;
    do{
        scancode = read_scancode(); 
        switch(scancode)
        {
           
            case 0xf0:       //断码
                scancode = read_scancode();
                while(scancode == 0)
                    scancode = read_scancode();   //读取下一帧
                if(scancode == 0x12 || scancode == 0x59)    //shift松开
                    is_shift = 1 - is_shift;
                break;

            case 0x66:
                //TODO()
                //退格操作
                delete_char();
                break;

            case 0x00:      //键盘还未键入 等待输入
                break;
                
            case 0x12: case 0x59:       //shift
                is_shift = 1 - is_shift;
                break;

            case 0x58:                  //Caps
                is_capslk = 1 - is_capslk;
                break;

            case 0x5a:                  //回车 return TODO() 处理回车断码后在return
                write_buff('\n');
                return;

            case 0xe0:
                scancode = read_scancode();
                while(scancode == 0)
                    scancode = read_scancode();
                if(scancode == 0xf0)
                {
                    scancode = read_scancode();
                    while(scancode == 0)
                        scancode = read_scancode();
                }
                else
                {
                    switch(scancode)
                    {
                        case 0x75:
                            if(start_line != 0)
                            {
                                start_line--;
                                outl(VGA_ROW_START, start_line);
                            }
                            break;
                        case 0x72:
                            start_line++;
                            outl(VGA_ROW_START, start_line);
                        case 0x6b:
                            break;
                        case 0x74:
                            break;
                    }
                }
                break;
            default:                    //输入字符
                ch = table[(int)scancode];
                if(ch>='a' && ch <= 'z')
                {   
                    if((is_shift == 1 && is_capslk == 0) || (is_capslk == 1 && is_shift == 0))
                        ch = ch - 0x20;
                }
                else if(ch >= '0' && ch <= '9')
                {
                    if(is_shift == 1)
                        ch = transform_table[ch - '0'];
                }
                else
                {
                    if(is_shift == 1)
                    {
                        switch(ch)
                        {
                            case '-': ch = '_'; break;
                            case '=': ch = '+'; break;
                            case '[': ch = '{'; break;
                            case ']': ch = '}'; break;
                            case '\\':ch = '|'; break;
                            case ';': ch = ':'; break;
                            case '\'': ch = '\"'; break;
                            case ',': ch = '<'; break;
                            case '.': ch = '>'; break;
                            case '/': ch = '?'; break; 
                        }
                    }
                }
                write_buff(ch);
                break;
        }
    }while(1);
}

char getchar()
{
    char ch = read_buff();
    while(ch == 0)
    {
        keyboard_to_buff();
        ch = read_buff();
    }
    return ch;
}
