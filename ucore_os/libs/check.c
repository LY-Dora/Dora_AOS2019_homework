//
// Created by dora on 19-6-18.
//
//
// Created by dora on 19-6-18.
//
#include "stdio.h"
#include "stdlib.h"
#include "unistd.h"
#include "../user/libs/ulib.h"
#include "stdio.h"
#include "string.h"
#include "../user/libs/dir.h"
#include "../user/libs/file.h"
#include "error.h"


//#include "../kern/syscall/syscall.c"

//#define printf(...) fprintf(1, __VA_ARGS__)
typedef int32_t intptr_t;
typedef uint32_t uintptr_t;
//void *aa;
//#define EXEC_SIZE 100
//uint32_t exec[EXEC_SIZE]={0};
uint32_t ip_add;
uint32_t exec_start=0x00800020;
uint32_t exec_end1=0x00803000;
uint32_t exec_end2=0x00804000;

//uint32_t exec_end;

uint32_t kernel_start=0xc0100000;
uint32_t kernel_end=0xc0130000;

extern void check_exec(void);
extern void gen_execend(void* aa);

void  gen_execend(void* aa )
{
    //__asm__ __volatile__ ( "leal (%%eip),%0\n\t"
    //:"=r"(aa)
    //:
    //:"%ebx"
    //);
   ip_add=(uint32_t)aa;
   // exec_end=(((ip_add-0x800000)/0x1000)+1)*0x1000+0x800000;

}
void  check_exec(void)
{
    //int32_t a=a+1;
    //uint32_t ip_add=(uint32_t)aa;
    //exec_end=(((ip_add-0x800000)/0x1000)+1)*0x1000+0x800000;
    int32_t flag_1=0;
    /*if ((exec_end2-ip_add)>0x1000){
        flag_1=100;
    }*/
    void **a;
    void *value;
    //cprintf("breakpoint\n");
    __asm__ __volatile__ ( "mov (%%ebp),%%ebx\n\t"
            "mov %%ebx,%0\n\t"
    :"=g"(a)
    :
    :"%ebx"
    );
    value=*(a+1);
    uint32_t value_u=(uint32_t)value;
    int32_t flag= 0;
    if(flag_1) {
        if ((value_u >= exec_start) && (value_u <= exec_end1)) {
            flag = 100;
        }
    } else{
        if ((value_u >= exec_start) && (value_u <= exec_end2)) {
            flag = 100;
        }
    }

    if ((value_u >= kernel_start) && (value_u <= kernel_end))
    {
        flag=100;

    }
    if(!flag)
    {
        cprintf("\nError: Writable address is not executable\n\n");
        //cprintf("\nError: kill the process\n");
        __asm__ __volatile__ ("int3");
    }
   // cprintf("return address is %p\n",value);
  // cprintf("hello word\n");
}

