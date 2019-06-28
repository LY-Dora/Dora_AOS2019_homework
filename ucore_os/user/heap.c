#include <malloc.h>
#include <stdio.h>

int main(void)
{
    cprintf("====== Heap Test ======\n");

    void **blocks[5];
    for (int i = 0; i < 5; i++)
    {
        blocks[i] = malloc(0x20);
        cprintf("block %d = %08p\n", i, blocks[i]);
    }

    free(blocks[2]);
    blocks[2] = malloc(0x20);

    cprintf("block 2 = %08p\n", blocks[2]);

    free(blocks[3]);
    free(blocks[2]);

    blocks[2] = malloc(0x30);
    cprintf("block 2 = %08p\n", blocks[2]);

    blocks[3] = malloc(0x50);
    cprintf("block 3 = %08p\n", blocks[3]);

    return 0;
}
