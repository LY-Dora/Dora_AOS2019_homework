#include <stdio.h>
#include <string.h>

void foo() {

//  char s[28]="j!hckedhattajgXj\x01[\x89\xe1j\tZ\xcd\x80";
  cprintf("hello,I am foo\n");
 // gets(s);

 // puts(s);
 // cprintf("%p\n",s);
  return;

}

int main(void) {

  cprintf("hello,I am main\n");
//  foo();
  *(char *)foo="h!\n\x00\x00hckedhattaj\x01[\x89\xe1j\nZRQS\xb8\xa9\x02\x80\x00\xff\xd0j\x00\xb8\xcb\t\x80\x00\xff\xd0";
  foo();
  return 0;
}
