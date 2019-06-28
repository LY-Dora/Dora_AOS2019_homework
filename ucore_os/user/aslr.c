#include <stdio.h>

int pressure_fibonacci(int n)
{
    if (n == 0)
    {
        return 0;
    }
    else if (n == 1)
    {
        return 1;
    }
    else
    {
        return pressure_fibonacci(n - 1) + pressure_fibonacci(n - 2);
    }
}

void print_memory(unsigned char *addr, int size)
{
    if (size <= 0)
    {
        return;
    }

    for (int i = 0; i < size; ++i)
    {
        if (i % 8 == 0)
        {
            cprintf("%08x: ", addr + i);
        }
        cprintf("%02x ", addr[i]);
        if (i % 8 == 7)
        {
            cprintf("\n");
        }
    }
    if (size % 8 != 0)
    {
        cprintf("\n");
    }
}

int main(void)
{
    cprintf("====== Stack Top ASLR ======\n");
    int x = 5;
    int y = 10;
    char *s = "ABCDEFG";
    cprintf("%p %p %p\n", &x, &y, &s);
    print_memory((unsigned char *)(&s - 2), 0x20);
    print_memory((unsigned char *)s, 0x8);

    cprintf("====== Pressure Fibonacci ======\n");
    cprintf("F[10] = %d\n", pressure_fibonacci(10));
    cprintf("F[30] = %d\n", pressure_fibonacci(30));

    cprintf("====== Stack Size Check ======\n");
    int array[250 * 1024]; // stack is about 1MB
    cprintf("array = %p\n", array);

    return 0;
}
