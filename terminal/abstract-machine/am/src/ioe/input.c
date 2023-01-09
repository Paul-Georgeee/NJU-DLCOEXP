#include <am.h>
#include <nemu.h>
#include <klib.h>


static uint8_t table[256] = {
    0, 0, 0, 0, 0, 0, 0, 0,     //00-07
    0, 0, 0, 0, 0, 0, '`', 0,     //08-0f
    0, 0, 0, 0, 0, AM_KEY_Q, AM_KEY_1, 0,     //10-17
    0, 0, AM_KEY_Z, AM_KEY_S, AM_KEY_A, AM_KEY_W, AM_KEY_2, 0,   //18-1f    
    0, AM_KEY_C, AM_KEY_X, AM_KEY_D, AM_KEY_E, AM_KEY_4, AM_KEY_3, 0,     //20-27
    0, AM_KEY_SPACE, AM_KEY_V, AM_KEY_F, AM_KEY_T, AM_KEY_R, AM_KEY_5, 0,     //28-2f
    0, AM_KEY_N, AM_KEY_B, AM_KEY_H, AM_KEY_G, AM_KEY_Y, AM_KEY_6, 0,     //30-37
    0, 0, AM_KEY_M, AM_KEY_J, AM_KEY_U, AM_KEY_7, AM_KEY_8, 0,     //38-3f
    0, AM_KEY_COMMA, AM_KEY_K, AM_KEY_I, AM_KEY_O, AM_KEY_0, AM_KEY_9, 0,     //40-47
    0, AM_KEY_PERIOD, AM_KEY_SLASH, AM_KEY_L, AM_KEY_SEMICOLON, AM_KEY_P, AM_KEY_MINUS, 0,     //48-4f
    0, 0, AM_KEY_APOSTROPHE, 0, AM_KEY_LEFTBRACKET, AM_KEY_EQUALS, 0, 0,     //50-57
    0, 0, AM_KEY_RETURN, AM_KEY_RIGHTBRACKET, 0, AM_KEY_BACKSLASH, 0, 0,     //58-5f
    0, 0, 0, 0, 0, 0, 0, 0,     //60-6f
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, AM_KEY_ESCAPE, 0,
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

static uint8_t read_scancode()
{
    uint8_t scancode = inb(KEY_START);
    if(scancode != 0)
        outb(KEY_HEAD, inb(KEY_HEAD) + 1);
    return scancode;
}

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint8_t scancode = read_scancode();
  if(scancode != 0)
  {
      if(scancode != 0xf0)
      {
          kbd->keydown = 1;
          kbd->keycode = table[scancode];
      }
      else{
            kbd->keydown = 0;
            scancode = read_scancode();
            while(scancode == 0)
            scancode = read_scancode(); 
            kbd->keycode = table[scancode];  
      }
  }
  else
  {
      kbd->keydown = 0;
      kbd->keycode = AM_KEY_NONE;
  }
  
}
