#include <stdio.h>
#include <string.h>

char vul[28+0x200]="h!\n\x00\x00hckedhattaj\x01[\x89\xe1j\nZRQS\xb8\xf7\x04\x80\x00\xff\xd0j\x00\xb8\xe4\r\x80\x00\xff\xd0";

void foo() {
  char s[4]="oook";
  *(int *)(s+0x8)=(int)vul;
  return;

}

int main(void) {

  cprintf("hello,I am main\n");
  cprintf("vul is %p\n",vul);
  foo();
  return 0;
}
    
