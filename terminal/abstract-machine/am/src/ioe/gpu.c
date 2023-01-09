#include <am.h>
#include <nemu.h>

// #define SYNC_ADDR (VGACTL_ADDR + 4)

void change_vga (int chooes)
{
  outb(VGA_SELECTOR, chooes);
}

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = 640, .height = 480,
    .vmemsz = 0
  };
}

//AM_DEVREG(11, GPU_FBDRAW,   WR, int x, y; void *pixels; int w, h; bool sync);
// 向屏幕(x, y)坐标处绘制w*h的矩形图像. 
//图像像素按行优先方式存储在pixels中, 每个像素用32位整数以00RRGGBB的方式描述颜色. 
void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    for(int i = 0; i < ctl->h; ++i)
      for(int j = 0; j< ctl->w; ++j)
      {
        outl(BIG_VGA + ((ctl->x + j) << 9) + ctl->y + i,((uint32_t*)(ctl->pixels))[i * ctl->w + j]);
      }
  
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
