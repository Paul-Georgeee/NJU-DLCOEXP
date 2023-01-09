#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  int i = 0;
  for(; s[i] != '\0'; ++i)
    ;
  return i;
}

char *strcpy(char *dst, const char *src) {
  int i = 0;
  for(; src[i] != '\0'; ++i)
    dst[i] = src[i];
  dst[i] = '\0';
  return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  int i = 0;
  for(;src[i] != '\0'&& i < n; ++i)
    dst[i] = src[i];
  dst[i] = '\0';
  return dst; 
}

char *strcat(char *dst, const char *src) {
  size_t dst_len = strlen(dst);
  int i = 0;
  for(i = 0; src[i] != '\0'; ++i)
    dst[dst_len + i] = src[i];
  dst[dst_len + i] = '\0';
  return dst;
}

int strcmp(const char *s1, const char *s2) {
  size_t len1 = strlen(s1);
  size_t len2= strlen(s2);
  int i = 0;
  for(i = 0; i <= len1 && i <= len2; ++i)
    if(s1[i] != s2[i])
      return s1[i] - s2[i];
  return 0;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  size_t len1 = strlen(s1);
  size_t len2 = strlen(s2);
  int i = 0;
 for(i = 0; i <= len1 && i <= len2 && i < n; ++i)
    if(s1[i] != s2[i])
      return s1[i] - s2[i];
  return 0;
}

void *memset(void *s, int c, size_t n) {
/*
  The  memset() function fills the first n bytes of 
the memory area pointed to by s with the constant byte c.
*/
  char *buff = s;
  for(int i = 0; i < n; ++i)
    buff[i] = (char)c;
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  /*
     The  memmove() function copies n bytes from memory area src to memory area dest.  The mem‐
      ory areas may overlap: copying takes place as though the bytes in  src  are  first  copied
      into  a  temporary  array that does not overlap src or dest, and the bytes are then copied
      from the temporary array to dest.
  */
  for(int i = 0; i < n; ++i)
    ((char*)dst)[i] = ((char*)src)[i];
  
  return dst;
  
}

void *memcpy(void *out, const void *in, size_t n) {
    /* 
    The memcpy() function copies n bytes from memory area src to memory area dest.  
    The memory areas must not overlap.  Use memmove(3) if the memory areas do overlap.
*/
   for(int i = 0; i < n; ++i)
    ((char*)out)[i] = ((char*)in)[i];
  
  return out;

}

int memcmp(const void *s1, const void *s2, size_t n) {
/*
DESCRIPTION
       The  memcmp()  function  compares the first n bytes (each interpreted as unsigned char)
      of the memory areas s1 and s2.

RETURN VALUE
       The memcmp() function returns an integer less than, equal to, or greater than zero if  
       the first  n bytes of s1 is found, respectively, to be less than, to match, or be greater 
       than the first n bytes of s2.

       For a nonzero return value, the sign is determined by the sign of the  difference 
      between the first pair of bytes (interpreted as unsigned char) that differ in s1 and s2.

       If n is zero, the return value is zero.
*/
    unsigned char *a1 = s1;
    unsigned char *a2 = s2;
    for(int i = 0; i < n; ++i)
    {
        if(a1[i] != a2[i])
          return a1[i] - a2[i];
    }
    return 0;
}

#endif
