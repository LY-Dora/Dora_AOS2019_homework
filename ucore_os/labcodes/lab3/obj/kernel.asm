
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 04 41 12 c0       	mov    $0xc0124104,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 30 12 c0 	movl   $0xc0123000,(%esp)
c010005d:	e8 a4 82 00 00       	call   c0108306 <memset>

    cons_init();                // init the console
c0100062:	e8 ec 1d 00 00       	call   c0101e53 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 8b 10 c0 	movl   $0xc0108be0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 8b 10 c0 	movl   $0xc0108bfc,(%esp)
c010007c:	e8 20 02 00 00       	call   c01002a1 <cprintf>

    print_kerninfo();
c0100081:	e8 c1 08 00 00       	call   c0100947 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 98 00 00 00       	call   c0100123 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 ca 6a 00 00       	call   c0106b5a <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 22 1f 00 00       	call   c0101fb7 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 7b 20 00 00       	call   c0102115 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 c4 35 00 00       	call   c0103663 <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 53 0d 00 00       	call   c0100df7 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 b9 3f 00 00       	call   c0104062 <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 58 15 00 00       	call   c0101606 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 37 20 00 00       	call   c01020ea <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 b5 0c 00 00       	call   c0100d8c <mon_backtrace>
}
c01000d7:	90                   	nop
c01000d8:	c9                   	leave  
c01000d9:	c3                   	ret    

c01000da <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000da:	55                   	push   %ebp
c01000db:	89 e5                	mov    %esp,%ebp
c01000dd:	53                   	push   %ebx
c01000de:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b4 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100101:	90                   	nop
c0100102:	83 c4 14             	add    $0x14,%esp
c0100105:	5b                   	pop    %ebx
c0100106:	5d                   	pop    %ebp
c0100107:	c3                   	ret    

c0100108 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100108:	55                   	push   %ebp
c0100109:	89 e5                	mov    %esp,%ebp
c010010b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100111:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100115:	8b 45 08             	mov    0x8(%ebp),%eax
c0100118:	89 04 24             	mov    %eax,(%esp)
c010011b:	e8 ba ff ff ff       	call   c01000da <grade_backtrace1>
}
c0100120:	90                   	nop
c0100121:	c9                   	leave  
c0100122:	c3                   	ret    

c0100123 <grade_backtrace>:

void
grade_backtrace(void) {
c0100123:	55                   	push   %ebp
c0100124:	89 e5                	mov    %esp,%ebp
c0100126:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100129:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012e:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100135:	ff 
c0100136:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100141:	e8 c2 ff ff ff       	call   c0100108 <grade_backtrace0>
}
c0100146:	90                   	nop
c0100147:	c9                   	leave  
c0100148:	c3                   	ret    

c0100149 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100149:	55                   	push   %ebp
c010014a:	89 e5                	mov    %esp,%ebp
c010014c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100152:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100155:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100158:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015f:	83 e0 03             	and    $0x3,%eax
c0100162:	89 c2                	mov    %eax,%edx
c0100164:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100169:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100171:	c7 04 24 01 8c 10 c0 	movl   $0xc0108c01,(%esp)
c0100178:	e8 24 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100181:	89 c2                	mov    %eax,%edx
c0100183:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 0f 8c 10 c0 	movl   $0xc0108c0f,(%esp)
c0100197:	e8 05 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	89 c2                	mov    %eax,%edx
c01001a2:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001af:	c7 04 24 1d 8c 10 c0 	movl   $0xc0108c1d,(%esp)
c01001b6:	e8 e6 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bf:	89 c2                	mov    %eax,%edx
c01001c1:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ce:	c7 04 24 2b 8c 10 c0 	movl   $0xc0108c2b,(%esp)
c01001d5:	e8 c7 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001da:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001de:	89 c2                	mov    %eax,%edx
c01001e0:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001e5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ed:	c7 04 24 39 8c 10 c0 	movl   $0xc0108c39,(%esp)
c01001f4:	e8 a8 00 00 00       	call   c01002a1 <cprintf>
    round ++;
c01001f9:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001fe:	40                   	inc    %eax
c01001ff:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c0100204:	90                   	nop
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	90                   	nop
c010020b:	5d                   	pop    %ebp
c010020c:	c3                   	ret    

c010020d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020d:	55                   	push   %ebp
c010020e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100210:	90                   	nop
c0100211:	5d                   	pop    %ebp
c0100212:	c3                   	ret    

c0100213 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100213:	55                   	push   %ebp
c0100214:	89 e5                	mov    %esp,%ebp
c0100216:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100219:	e8 2b ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021e:	c7 04 24 48 8c 10 c0 	movl   $0xc0108c48,(%esp)
c0100225:	e8 77 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_user();
c010022a:	e8 d8 ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022f:	e8 15 ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100234:	c7 04 24 68 8c 10 c0 	movl   $0xc0108c68,(%esp)
c010023b:	e8 61 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_kernel();
c0100240:	e8 c8 ff ff ff       	call   c010020d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100245:	e8 ff fe ff ff       	call   c0100149 <lab1_print_cur_status>
}
c010024a:	90                   	nop
c010024b:	c9                   	leave  
c010024c:	c3                   	ret    

c010024d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010024d:	55                   	push   %ebp
c010024e:	89 e5                	mov    %esp,%ebp
c0100250:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 04 24             	mov    %eax,(%esp)
c0100259:	e8 22 1c 00 00       	call   c0101e80 <cons_putc>
    (*cnt) ++;
c010025e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100261:	8b 00                	mov    (%eax),%eax
c0100263:	8d 50 01             	lea    0x1(%eax),%edx
c0100266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100269:	89 10                	mov    %edx,(%eax)
}
c010026b:	90                   	nop
c010026c:	c9                   	leave  
c010026d:	c3                   	ret    

c010026e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026e:	55                   	push   %ebp
c010026f:	89 e5                	mov    %esp,%ebp
c0100271:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100274:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010027b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100282:	8b 45 08             	mov    0x8(%ebp),%eax
c0100285:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100289:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010028c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100290:	c7 04 24 4d 02 10 c0 	movl   $0xc010024d,(%esp)
c0100297:	e8 bd 83 00 00       	call   c0108659 <vprintfmt>
    return cnt;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010029f:	c9                   	leave  
c01002a0:	c3                   	ret    

c01002a1 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a1:	55                   	push   %ebp
c01002a2:	89 e5                	mov    %esp,%ebp
c01002a4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af ff ff ff       	call   c010026e <vcprintf>
c01002bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c5:	c9                   	leave  
c01002c6:	c3                   	ret    

c01002c7 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c7:	55                   	push   %ebp
c01002c8:	89 e5                	mov    %esp,%ebp
c01002ca:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d0:	89 04 24             	mov    %eax,(%esp)
c01002d3:	e8 a8 1b 00 00       	call   c0101e80 <cons_putc>
}
c01002d8:	90                   	nop
c01002d9:	c9                   	leave  
c01002da:	c3                   	ret    

c01002db <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002db:	55                   	push   %ebp
c01002dc:	89 e5                	mov    %esp,%ebp
c01002de:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e8:	eb 13                	jmp    c01002fd <cputs+0x22>
        cputch(c, &cnt);
c01002ea:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ee:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f5:	89 04 24             	mov    %eax,(%esp)
c01002f8:	e8 50 ff ff ff       	call   c010024d <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100300:	8d 50 01             	lea    0x1(%eax),%edx
c0100303:	89 55 08             	mov    %edx,0x8(%ebp)
c0100306:	0f b6 00             	movzbl (%eax),%eax
c0100309:	88 45 f7             	mov    %al,-0x9(%ebp)
c010030c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100310:	75 d8                	jne    c01002ea <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100312:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100315:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100319:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100320:	e8 28 ff ff ff       	call   c010024d <cputch>
    return cnt;
c0100325:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100328:	c9                   	leave  
c0100329:	c3                   	ret    

c010032a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010032a:	55                   	push   %ebp
c010032b:	89 e5                	mov    %esp,%ebp
c010032d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100330:	e8 88 1b 00 00       	call   c0101ebd <cons_getc>
c0100335:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100338:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010033c:	74 f2                	je     c0100330 <getchar+0x6>
        /* do nothing */;
    return c;
c010033e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100341:	c9                   	leave  
c0100342:	c3                   	ret    

c0100343 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100343:	55                   	push   %ebp
c0100344:	89 e5                	mov    %esp,%ebp
c0100346:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100349:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010034d:	74 13                	je     c0100362 <readline+0x1f>
        cprintf("%s", prompt);
c010034f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100352:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100356:	c7 04 24 87 8c 10 c0 	movl   $0xc0108c87,(%esp)
c010035d:	e8 3f ff ff ff       	call   c01002a1 <cprintf>
    }
    int i = 0, c;
c0100362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100369:	e8 bc ff ff ff       	call   c010032a <getchar>
c010036e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100371:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100375:	79 07                	jns    c010037e <readline+0x3b>
            return NULL;
c0100377:	b8 00 00 00 00       	mov    $0x0,%eax
c010037c:	eb 78                	jmp    c01003f6 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100382:	7e 28                	jle    c01003ac <readline+0x69>
c0100384:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010038b:	7f 1f                	jg     c01003ac <readline+0x69>
            cputchar(c);
c010038d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100390:	89 04 24             	mov    %eax,(%esp)
c0100393:	e8 2f ff ff ff       	call   c01002c7 <cputchar>
            buf[i ++] = c;
c0100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039b:	8d 50 01             	lea    0x1(%eax),%edx
c010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a4:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c01003aa:	eb 45                	jmp    c01003f1 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003ac:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b0:	75 16                	jne    c01003c8 <readline+0x85>
c01003b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b6:	7e 10                	jle    c01003c8 <readline+0x85>
            cputchar(c);
c01003b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bb:	89 04 24             	mov    %eax,(%esp)
c01003be:	e8 04 ff ff ff       	call   c01002c7 <cputchar>
            i --;
c01003c3:	ff 4d f4             	decl   -0xc(%ebp)
c01003c6:	eb 29                	jmp    c01003f1 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003c8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003cc:	74 06                	je     c01003d4 <readline+0x91>
c01003ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003d2:	75 95                	jne    c0100369 <readline+0x26>
            cputchar(c);
c01003d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d7:	89 04 24             	mov    %eax,(%esp)
c01003da:	e8 e8 fe ff ff       	call   c01002c7 <cputchar>
            buf[i] = '\0';
c01003df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e2:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01003e7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003ea:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01003ef:	eb 05                	jmp    c01003f6 <readline+0xb3>
        }
    }
c01003f1:	e9 73 ff ff ff       	jmp    c0100369 <readline+0x26>
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003fe:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c0100403:	85 c0                	test   %eax,%eax
c0100405:	75 5b                	jne    c0100462 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100407:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c010040e:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100411:	8d 45 14             	lea    0x14(%ebp),%eax
c0100414:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100417:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010041e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100421:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100425:	c7 04 24 8a 8c 10 c0 	movl   $0xc0108c8a,(%esp)
c010042c:	e8 70 fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c0100431:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100434:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100438:	8b 45 10             	mov    0x10(%ebp),%eax
c010043b:	89 04 24             	mov    %eax,(%esp)
c010043e:	e8 2b fe ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c0100443:	c7 04 24 a6 8c 10 c0 	movl   $0xc0108ca6,(%esp)
c010044a:	e8 52 fe ff ff       	call   c01002a1 <cprintf>
    
    cprintf("stack trackback:\n");
c010044f:	c7 04 24 a8 8c 10 c0 	movl   $0xc0108ca8,(%esp)
c0100456:	e8 46 fe ff ff       	call   c01002a1 <cprintf>
    print_stackframe();
c010045b:	e8 32 06 00 00       	call   c0100a92 <print_stackframe>
c0100460:	eb 01                	jmp    c0100463 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100462:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100463:	e8 89 1c 00 00       	call   c01020f1 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100468:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010046f:	e8 4b 08 00 00       	call   c0100cbf <kmonitor>
    }
c0100474:	eb f2                	jmp    c0100468 <__panic+0x70>

c0100476 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100476:	55                   	push   %ebp
c0100477:	89 e5                	mov    %esp,%ebp
c0100479:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010047c:	8d 45 14             	lea    0x14(%ebp),%eax
c010047f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100482:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100485:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100489:	8b 45 08             	mov    0x8(%ebp),%eax
c010048c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100490:	c7 04 24 ba 8c 10 c0 	movl   $0xc0108cba,(%esp)
c0100497:	e8 05 fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c010049c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010049f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a6:	89 04 24             	mov    %eax,(%esp)
c01004a9:	e8 c0 fd ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c01004ae:	c7 04 24 a6 8c 10 c0 	movl   $0xc0108ca6,(%esp)
c01004b5:	e8 e7 fd ff ff       	call   c01002a1 <cprintf>
    va_end(ap);
}
c01004ba:	90                   	nop
c01004bb:	c9                   	leave  
c01004bc:	c3                   	ret    

c01004bd <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004bd:	55                   	push   %ebp
c01004be:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c0:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c01004c5:	5d                   	pop    %ebp
c01004c6:	c3                   	ret    

c01004c7 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c7:	55                   	push   %ebp
c01004c8:	89 e5                	mov    %esp,%ebp
c01004ca:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d0:	8b 00                	mov    (%eax),%eax
c01004d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d8:	8b 00                	mov    (%eax),%eax
c01004da:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e4:	e9 ca 00 00 00       	jmp    c01005b3 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004ef:	01 d0                	add    %edx,%eax
c01004f1:	89 c2                	mov    %eax,%edx
c01004f3:	c1 ea 1f             	shr    $0x1f,%edx
c01004f6:	01 d0                	add    %edx,%eax
c01004f8:	d1 f8                	sar    %eax
c01004fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100500:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100503:	eb 03                	jmp    c0100508 <stab_binsearch+0x41>
            m --;
c0100505:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050e:	7c 1f                	jl     c010052f <stab_binsearch+0x68>
c0100510:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100513:	89 d0                	mov    %edx,%eax
c0100515:	01 c0                	add    %eax,%eax
c0100517:	01 d0                	add    %edx,%eax
c0100519:	c1 e0 02             	shl    $0x2,%eax
c010051c:	89 c2                	mov    %eax,%edx
c010051e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100521:	01 d0                	add    %edx,%eax
c0100523:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100527:	0f b6 c0             	movzbl %al,%eax
c010052a:	3b 45 14             	cmp    0x14(%ebp),%eax
c010052d:	75 d6                	jne    c0100505 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010052f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100532:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100535:	7d 09                	jge    c0100540 <stab_binsearch+0x79>
            l = true_m + 1;
c0100537:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010053a:	40                   	inc    %eax
c010053b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053e:	eb 73                	jmp    c01005b3 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100540:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100547:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054a:	89 d0                	mov    %edx,%eax
c010054c:	01 c0                	add    %eax,%eax
c010054e:	01 d0                	add    %edx,%eax
c0100550:	c1 e0 02             	shl    $0x2,%eax
c0100553:	89 c2                	mov    %eax,%edx
c0100555:	8b 45 08             	mov    0x8(%ebp),%eax
c0100558:	01 d0                	add    %edx,%eax
c010055a:	8b 40 08             	mov    0x8(%eax),%eax
c010055d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100560:	73 11                	jae    c0100573 <stab_binsearch+0xac>
            *region_left = m;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100568:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056d:	40                   	inc    %eax
c010056e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100571:	eb 40                	jmp    c01005b3 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100573:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100576:	89 d0                	mov    %edx,%eax
c0100578:	01 c0                	add    %eax,%eax
c010057a:	01 d0                	add    %edx,%eax
c010057c:	c1 e0 02             	shl    $0x2,%eax
c010057f:	89 c2                	mov    %eax,%edx
c0100581:	8b 45 08             	mov    0x8(%ebp),%eax
c0100584:	01 d0                	add    %edx,%eax
c0100586:	8b 40 08             	mov    0x8(%eax),%eax
c0100589:	3b 45 18             	cmp    0x18(%ebp),%eax
c010058c:	76 14                	jbe    c01005a2 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010058e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100591:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100594:	8b 45 10             	mov    0x10(%ebp),%eax
c0100597:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100599:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059c:	48                   	dec    %eax
c010059d:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a0:	eb 11                	jmp    c01005b3 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a8:	89 10                	mov    %edx,(%eax)
            l = m;
c01005aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b0:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b9:	0f 8e 2a ff ff ff    	jle    c01004e9 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c3:	75 0f                	jne    c01005d4 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d0:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005d2:	eb 3e                	jmp    c0100612 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d7:	8b 00                	mov    (%eax),%eax
c01005d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005dc:	eb 03                	jmp    c01005e1 <stab_binsearch+0x11a>
c01005de:	ff 4d fc             	decl   -0x4(%ebp)
c01005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e4:	8b 00                	mov    (%eax),%eax
c01005e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005e9:	7d 1f                	jge    c010060a <stab_binsearch+0x143>
c01005eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ee:	89 d0                	mov    %edx,%eax
c01005f0:	01 c0                	add    %eax,%eax
c01005f2:	01 d0                	add    %edx,%eax
c01005f4:	c1 e0 02             	shl    $0x2,%eax
c01005f7:	89 c2                	mov    %eax,%edx
c01005f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fc:	01 d0                	add    %edx,%eax
c01005fe:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100602:	0f b6 c0             	movzbl %al,%eax
c0100605:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100608:	75 d4                	jne    c01005de <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c010060a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100610:	89 10                	mov    %edx,(%eax)
    }
}
c0100612:	90                   	nop
c0100613:	c9                   	leave  
c0100614:	c3                   	ret    

c0100615 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100615:	55                   	push   %ebp
c0100616:	89 e5                	mov    %esp,%ebp
c0100618:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010061b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061e:	c7 00 d8 8c 10 c0    	movl   $0xc0108cd8,(%eax)
    info->eip_line = 0;
c0100624:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100627:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	c7 40 08 d8 8c 10 c0 	movl   $0xc0108cd8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100638:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063b:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100642:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100645:	8b 55 08             	mov    0x8(%ebp),%edx
c0100648:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010064b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100655:	c7 45 f4 cc ab 10 c0 	movl   $0xc010abcc,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065c:	c7 45 f0 58 9d 11 c0 	movl   $0xc0119d58,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100663:	c7 45 ec 59 9d 11 c0 	movl   $0xc0119d59,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066a:	c7 45 e8 b2 d6 11 c0 	movl   $0xc011d6b2,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100671:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100674:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100677:	76 0b                	jbe    c0100684 <debuginfo_eip+0x6f>
c0100679:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067c:	48                   	dec    %eax
c010067d:	0f b6 00             	movzbl (%eax),%eax
c0100680:	84 c0                	test   %al,%al
c0100682:	74 0a                	je     c010068e <debuginfo_eip+0x79>
        return -1;
c0100684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100689:	e9 b7 02 00 00       	jmp    c0100945 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100695:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069b:	29 c2                	sub    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	c1 f8 02             	sar    $0x2,%eax
c01006a2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a8:	48                   	dec    %eax
c01006a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01006af:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006b3:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ba:	00 
c01006bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006be:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cc:	89 04 24             	mov    %eax,(%esp)
c01006cf:	e8 f3 fd ff ff       	call   c01004c7 <stab_binsearch>
    if (lfile == 0)
c01006d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d7:	85 c0                	test   %eax,%eax
c01006d9:	75 0a                	jne    c01006e5 <debuginfo_eip+0xd0>
        return -1;
c01006db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e0:	e9 60 02 00 00       	jmp    c0100945 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f8:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006ff:	00 
c0100700:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100703:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100707:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100711:	89 04 24             	mov    %eax,(%esp)
c0100714:	e8 ae fd ff ff       	call   c01004c7 <stab_binsearch>

    if (lfun <= rfun) {
c0100719:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071f:	39 c2                	cmp    %eax,%edx
c0100721:	7f 7c                	jg     c010079f <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100723:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100726:	89 c2                	mov    %eax,%edx
c0100728:	89 d0                	mov    %edx,%eax
c010072a:	01 c0                	add    %eax,%eax
c010072c:	01 d0                	add    %edx,%eax
c010072e:	c1 e0 02             	shl    $0x2,%eax
c0100731:	89 c2                	mov    %eax,%edx
c0100733:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100736:	01 d0                	add    %edx,%eax
c0100738:	8b 00                	mov    (%eax),%eax
c010073a:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010073d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100740:	29 d1                	sub    %edx,%ecx
c0100742:	89 ca                	mov    %ecx,%edx
c0100744:	39 d0                	cmp    %edx,%eax
c0100746:	73 22                	jae    c010076a <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100748:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	89 d0                	mov    %edx,%eax
c010074f:	01 c0                	add    %eax,%eax
c0100751:	01 d0                	add    %edx,%eax
c0100753:	c1 e0 02             	shl    $0x2,%eax
c0100756:	89 c2                	mov    %eax,%edx
c0100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075b:	01 d0                	add    %edx,%eax
c010075d:	8b 10                	mov    (%eax),%edx
c010075f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100762:	01 c2                	add    %eax,%edx
c0100764:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100767:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010076a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010076d:	89 c2                	mov    %eax,%edx
c010076f:	89 d0                	mov    %edx,%eax
c0100771:	01 c0                	add    %eax,%eax
c0100773:	01 d0                	add    %edx,%eax
c0100775:	c1 e0 02             	shl    $0x2,%eax
c0100778:	89 c2                	mov    %eax,%edx
c010077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077d:	01 d0                	add    %edx,%eax
c010077f:	8b 50 08             	mov    0x8(%eax),%edx
c0100782:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100785:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100788:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078b:	8b 40 10             	mov    0x10(%eax),%eax
c010078e:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100794:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100797:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010079a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010079d:	eb 15                	jmp    c01007b4 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010079f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a5:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b7:	8b 40 08             	mov    0x8(%eax),%eax
c01007ba:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c1:	00 
c01007c2:	89 04 24             	mov    %eax,(%esp)
c01007c5:	e8 b8 79 00 00       	call   c0108182 <strfind>
c01007ca:	89 c2                	mov    %eax,%edx
c01007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cf:	8b 40 08             	mov    0x8(%eax),%eax
c01007d2:	29 c2                	sub    %eax,%edx
c01007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d7:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007da:	8b 45 08             	mov    0x8(%ebp),%eax
c01007dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e1:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e8:	00 
c01007e9:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fa:	89 04 24             	mov    %eax,(%esp)
c01007fd:	e8 c5 fc ff ff       	call   c01004c7 <stab_binsearch>
    if (lline <= rline) {
c0100802:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100805:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100808:	39 c2                	cmp    %eax,%edx
c010080a:	7f 23                	jg     c010082f <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c010080c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010080f:	89 c2                	mov    %eax,%edx
c0100811:	89 d0                	mov    %edx,%eax
c0100813:	01 c0                	add    %eax,%eax
c0100815:	01 d0                	add    %edx,%eax
c0100817:	c1 e0 02             	shl    $0x2,%eax
c010081a:	89 c2                	mov    %eax,%edx
c010081c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081f:	01 d0                	add    %edx,%eax
c0100821:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100825:	89 c2                	mov    %eax,%edx
c0100827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082a:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010082d:	eb 11                	jmp    c0100840 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010082f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100834:	e9 0c 01 00 00       	jmp    c0100945 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100839:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083c:	48                   	dec    %eax
c010083d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100840:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100846:	39 c2                	cmp    %eax,%edx
c0100848:	7c 56                	jl     c01008a0 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010084a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084d:	89 c2                	mov    %eax,%edx
c010084f:	89 d0                	mov    %edx,%eax
c0100851:	01 c0                	add    %eax,%eax
c0100853:	01 d0                	add    %edx,%eax
c0100855:	c1 e0 02             	shl    $0x2,%eax
c0100858:	89 c2                	mov    %eax,%edx
c010085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085d:	01 d0                	add    %edx,%eax
c010085f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100863:	3c 84                	cmp    $0x84,%al
c0100865:	74 39                	je     c01008a0 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	89 d0                	mov    %edx,%eax
c010086e:	01 c0                	add    %eax,%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	c1 e0 02             	shl    $0x2,%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100880:	3c 64                	cmp    $0x64,%al
c0100882:	75 b5                	jne    c0100839 <debuginfo_eip+0x224>
c0100884:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100887:	89 c2                	mov    %eax,%edx
c0100889:	89 d0                	mov    %edx,%eax
c010088b:	01 c0                	add    %eax,%eax
c010088d:	01 d0                	add    %edx,%eax
c010088f:	c1 e0 02             	shl    $0x2,%eax
c0100892:	89 c2                	mov    %eax,%edx
c0100894:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100897:	01 d0                	add    %edx,%eax
c0100899:	8b 40 08             	mov    0x8(%eax),%eax
c010089c:	85 c0                	test   %eax,%eax
c010089e:	74 99                	je     c0100839 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a6:	39 c2                	cmp    %eax,%edx
c01008a8:	7c 46                	jl     c01008f0 <debuginfo_eip+0x2db>
c01008aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ad:	89 c2                	mov    %eax,%edx
c01008af:	89 d0                	mov    %edx,%eax
c01008b1:	01 c0                	add    %eax,%eax
c01008b3:	01 d0                	add    %edx,%eax
c01008b5:	c1 e0 02             	shl    $0x2,%eax
c01008b8:	89 c2                	mov    %eax,%edx
c01008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bd:	01 d0                	add    %edx,%eax
c01008bf:	8b 00                	mov    (%eax),%eax
c01008c1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008c7:	29 d1                	sub    %edx,%ecx
c01008c9:	89 ca                	mov    %ecx,%edx
c01008cb:	39 d0                	cmp    %edx,%eax
c01008cd:	73 21                	jae    c01008f0 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d2:	89 c2                	mov    %eax,%edx
c01008d4:	89 d0                	mov    %edx,%eax
c01008d6:	01 c0                	add    %eax,%eax
c01008d8:	01 d0                	add    %edx,%eax
c01008da:	c1 e0 02             	shl    $0x2,%eax
c01008dd:	89 c2                	mov    %eax,%edx
c01008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e2:	01 d0                	add    %edx,%eax
c01008e4:	8b 10                	mov    (%eax),%edx
c01008e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008e9:	01 c2                	add    %eax,%edx
c01008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ee:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f6:	39 c2                	cmp    %eax,%edx
c01008f8:	7d 46                	jge    c0100940 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008fd:	40                   	inc    %eax
c01008fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100901:	eb 16                	jmp    c0100919 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100906:	8b 40 14             	mov    0x14(%eax),%eax
c0100909:	8d 50 01             	lea    0x1(%eax),%edx
c010090c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090f:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100912:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100915:	40                   	inc    %eax
c0100916:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100919:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010091c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010091f:	39 c2                	cmp    %eax,%edx
c0100921:	7d 1d                	jge    c0100940 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100923:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100926:	89 c2                	mov    %eax,%edx
c0100928:	89 d0                	mov    %edx,%eax
c010092a:	01 c0                	add    %eax,%eax
c010092c:	01 d0                	add    %edx,%eax
c010092e:	c1 e0 02             	shl    $0x2,%eax
c0100931:	89 c2                	mov    %eax,%edx
c0100933:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100936:	01 d0                	add    %edx,%eax
c0100938:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010093c:	3c a0                	cmp    $0xa0,%al
c010093e:	74 c3                	je     c0100903 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100940:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100945:	c9                   	leave  
c0100946:	c3                   	ret    

c0100947 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100947:	55                   	push   %ebp
c0100948:	89 e5                	mov    %esp,%ebp
c010094a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010094d:	c7 04 24 e2 8c 10 c0 	movl   $0xc0108ce2,(%esp)
c0100954:	e8 48 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100959:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100960:	c0 
c0100961:	c7 04 24 fb 8c 10 c0 	movl   $0xc0108cfb,(%esp)
c0100968:	e8 34 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096d:	c7 44 24 04 d8 8b 10 	movl   $0xc0108bd8,0x4(%esp)
c0100974:	c0 
c0100975:	c7 04 24 13 8d 10 c0 	movl   $0xc0108d13,(%esp)
c010097c:	e8 20 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100981:	c7 44 24 04 00 30 12 	movl   $0xc0123000,0x4(%esp)
c0100988:	c0 
c0100989:	c7 04 24 2b 8d 10 c0 	movl   $0xc0108d2b,(%esp)
c0100990:	e8 0c f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100995:	c7 44 24 04 04 41 12 	movl   $0xc0124104,0x4(%esp)
c010099c:	c0 
c010099d:	c7 04 24 43 8d 10 c0 	movl   $0xc0108d43,(%esp)
c01009a4:	e8 f8 f8 ff ff       	call   c01002a1 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009a9:	b8 04 41 12 c0       	mov    $0xc0124104,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009b9:	29 c2                	sub    %eax,%edx
c01009bb:	89 d0                	mov    %edx,%eax
c01009bd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c3:	85 c0                	test   %eax,%eax
c01009c5:	0f 48 c2             	cmovs  %edx,%eax
c01009c8:	c1 f8 0a             	sar    $0xa,%eax
c01009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009cf:	c7 04 24 5c 8d 10 c0 	movl   $0xc0108d5c,(%esp)
c01009d6:	e8 c6 f8 ff ff       	call   c01002a1 <cprintf>
}
c01009db:	90                   	nop
c01009dc:	c9                   	leave  
c01009dd:	c3                   	ret    

c01009de <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009de:	55                   	push   %ebp
c01009df:	89 e5                	mov    %esp,%ebp
c01009e1:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 04 24             	mov    %eax,(%esp)
c01009f4:	e8 1c fc ff ff       	call   c0100615 <debuginfo_eip>
c01009f9:	85 c0                	test   %eax,%eax
c01009fb:	74 15                	je     c0100a12 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a04:	c7 04 24 86 8d 10 c0 	movl   $0xc0108d86,(%esp)
c0100a0b:	e8 91 f8 ff ff       	call   c01002a1 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a10:	eb 6c                	jmp    c0100a7e <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a19:	eb 1b                	jmp    c0100a36 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a21:	01 d0                	add    %edx,%eax
c0100a23:	0f b6 00             	movzbl (%eax),%eax
c0100a26:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a2f:	01 ca                	add    %ecx,%edx
c0100a31:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a33:	ff 45 f4             	incl   -0xc(%ebp)
c0100a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a3c:	7f dd                	jg     c0100a1b <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a3e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a47:	01 d0                	add    %edx,%eax
c0100a49:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a52:	89 d1                	mov    %edx,%ecx
c0100a54:	29 c1                	sub    %eax,%ecx
c0100a56:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a60:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a6a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a72:	c7 04 24 a2 8d 10 c0 	movl   $0xc0108da2,(%esp)
c0100a79:	e8 23 f8 ff ff       	call   c01002a1 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a7e:	90                   	nop
c0100a7f:	c9                   	leave  
c0100a80:	c3                   	ret    

c0100a81 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a81:	55                   	push   %ebp
c0100a82:	89 e5                	mov    %esp,%ebp
c0100a84:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a87:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a90:	c9                   	leave  
c0100a91:	c3                   	ret    

c0100a92 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a92:	55                   	push   %ebp
c0100a93:	89 e5                	mov    %esp,%ebp
c0100a95:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a98:	89 e8                	mov    %ebp,%eax
c0100a9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
c0100aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
c0100aa3:	e8 d9 ff ff ff       	call   c0100a81 <read_eip>
c0100aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100aab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ab2:	e9 88 00 00 00       	jmp    c0100b3f <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aba:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac5:	c7 04 24 b4 8d 10 c0 	movl   $0xc0108db4,(%esp)
c0100acc:	e8 d0 f7 ff ff       	call   c01002a1 <cprintf>
        uint32_t *fun_stack = (uint32_t *)ebp ;
c0100ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 2; j < 6; j ++) {
c0100ad7:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
c0100ade:	eb 24                	jmp    c0100b04 <print_stackframe+0x72>
            cprintf("0x%08x ", fun_stack[j]);
c0100ae0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ae3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100aed:	01 d0                	add    %edx,%eax
c0100aef:	8b 00                	mov    (%eax),%eax
c0100af1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af5:	c7 04 24 d0 8d 10 c0 	movl   $0xc0108dd0,(%esp)
c0100afc:	e8 a0 f7 ff ff       	call   c01002a1 <cprintf>
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *fun_stack = (uint32_t *)ebp ;
        for (int j = 2; j < 6; j ++) {
c0100b01:	ff 45 e8             	incl   -0x18(%ebp)
c0100b04:	83 7d e8 05          	cmpl   $0x5,-0x18(%ebp)
c0100b08:	7e d6                	jle    c0100ae0 <print_stackframe+0x4e>
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
c0100b0a:	c7 04 24 d8 8d 10 c0 	movl   $0xc0108dd8,(%esp)
c0100b11:	e8 8b f7 ff ff       	call   c01002a1 <cprintf>
        print_debuginfo(eip - 1);
c0100b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b19:	48                   	dec    %eax
c0100b1a:	89 04 24             	mov    %eax,(%esp)
c0100b1d:	e8 bc fe ff ff       	call   c01009de <print_debuginfo>
        if(fun_stack[0]==0) break;
c0100b22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b25:	8b 00                	mov    (%eax),%eax
c0100b27:	85 c0                	test   %eax,%eax
c0100b29:	74 20                	je     c0100b4b <print_stackframe+0xb9>
        eip = fun_stack[1];
c0100b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b2e:	8b 40 04             	mov    0x4(%eax),%eax
c0100b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = fun_stack[0];
c0100b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b37:	8b 00                	mov    (%eax),%eax
c0100b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100b3c:	ff 45 ec             	incl   -0x14(%ebp)
c0100b3f:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b43:	0f 8e 6e ff ff ff    	jle    c0100ab7 <print_stackframe+0x25>
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
c0100b49:	eb 01                	jmp    c0100b4c <print_stackframe+0xba>
        for (int j = 2; j < 6; j ++) {
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
c0100b4b:	90                   	nop
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
c0100b4c:	90                   	nop
c0100b4d:	c9                   	leave  
c0100b4e:	c3                   	ret    

c0100b4f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b4f:	55                   	push   %ebp
c0100b50:	89 e5                	mov    %esp,%ebp
c0100b52:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5c:	eb 0c                	jmp    c0100b6a <parse+0x1b>
            *buf ++ = '\0';
c0100b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b61:	8d 50 01             	lea    0x1(%eax),%edx
c0100b64:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b67:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6d:	0f b6 00             	movzbl (%eax),%eax
c0100b70:	84 c0                	test   %al,%al
c0100b72:	74 1d                	je     c0100b91 <parse+0x42>
c0100b74:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b77:	0f b6 00             	movzbl (%eax),%eax
c0100b7a:	0f be c0             	movsbl %al,%eax
c0100b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b81:	c7 04 24 5c 8e 10 c0 	movl   $0xc0108e5c,(%esp)
c0100b88:	e8 c3 75 00 00       	call   c0108150 <strchr>
c0100b8d:	85 c0                	test   %eax,%eax
c0100b8f:	75 cd                	jne    c0100b5e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b94:	0f b6 00             	movzbl (%eax),%eax
c0100b97:	84 c0                	test   %al,%al
c0100b99:	74 69                	je     c0100c04 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b9b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b9f:	75 14                	jne    c0100bb5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ba1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ba8:	00 
c0100ba9:	c7 04 24 61 8e 10 c0 	movl   $0xc0108e61,(%esp)
c0100bb0:	e8 ec f6 ff ff       	call   c01002a1 <cprintf>
        }
        argv[argc ++] = buf;
c0100bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bc8:	01 c2                	add    %eax,%edx
c0100bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bcf:	eb 03                	jmp    c0100bd4 <parse+0x85>
            buf ++;
c0100bd1:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd7:	0f b6 00             	movzbl (%eax),%eax
c0100bda:	84 c0                	test   %al,%al
c0100bdc:	0f 84 7a ff ff ff    	je     c0100b5c <parse+0xd>
c0100be2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be5:	0f b6 00             	movzbl (%eax),%eax
c0100be8:	0f be c0             	movsbl %al,%eax
c0100beb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bef:	c7 04 24 5c 8e 10 c0 	movl   $0xc0108e5c,(%esp)
c0100bf6:	e8 55 75 00 00       	call   c0108150 <strchr>
c0100bfb:	85 c0                	test   %eax,%eax
c0100bfd:	74 d2                	je     c0100bd1 <parse+0x82>
            buf ++;
        }
    }
c0100bff:	e9 58 ff ff ff       	jmp    c0100b5c <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100c04:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c08:	c9                   	leave  
c0100c09:	c3                   	ret    

c0100c0a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c0a:	55                   	push   %ebp
c0100c0b:	89 e5                	mov    %esp,%ebp
c0100c0d:	53                   	push   %ebx
c0100c0e:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c11:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1b:	89 04 24             	mov    %eax,(%esp)
c0100c1e:	e8 2c ff ff ff       	call   c0100b4f <parse>
c0100c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c2a:	75 0a                	jne    c0100c36 <runcmd+0x2c>
        return 0;
c0100c2c:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c31:	e9 83 00 00 00       	jmp    c0100cb9 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c3d:	eb 5a                	jmp    c0100c99 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c3f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c45:	89 d0                	mov    %edx,%eax
c0100c47:	01 c0                	add    %eax,%eax
c0100c49:	01 d0                	add    %edx,%eax
c0100c4b:	c1 e0 02             	shl    $0x2,%eax
c0100c4e:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c53:	8b 00                	mov    (%eax),%eax
c0100c55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c59:	89 04 24             	mov    %eax,(%esp)
c0100c5c:	e8 52 74 00 00       	call   c01080b3 <strcmp>
c0100c61:	85 c0                	test   %eax,%eax
c0100c63:	75 31                	jne    c0100c96 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c68:	89 d0                	mov    %edx,%eax
c0100c6a:	01 c0                	add    %eax,%eax
c0100c6c:	01 d0                	add    %edx,%eax
c0100c6e:	c1 e0 02             	shl    $0x2,%eax
c0100c71:	05 08 00 12 c0       	add    $0xc0120008,%eax
c0100c76:	8b 10                	mov    (%eax),%edx
c0100c78:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c7b:	83 c0 04             	add    $0x4,%eax
c0100c7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c81:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	89 1c 24             	mov    %ebx,(%esp)
c0100c92:	ff d2                	call   *%edx
c0100c94:	eb 23                	jmp    c0100cb9 <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c96:	ff 45 f4             	incl   -0xc(%ebp)
c0100c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c9c:	83 f8 02             	cmp    $0x2,%eax
c0100c9f:	76 9e                	jbe    c0100c3f <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ca1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca8:	c7 04 24 7f 8e 10 c0 	movl   $0xc0108e7f,(%esp)
c0100caf:	e8 ed f5 ff ff       	call   c01002a1 <cprintf>
    return 0;
c0100cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb9:	83 c4 64             	add    $0x64,%esp
c0100cbc:	5b                   	pop    %ebx
c0100cbd:	5d                   	pop    %ebp
c0100cbe:	c3                   	ret    

c0100cbf <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cbf:	55                   	push   %ebp
c0100cc0:	89 e5                	mov    %esp,%ebp
c0100cc2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cc5:	c7 04 24 98 8e 10 c0 	movl   $0xc0108e98,(%esp)
c0100ccc:	e8 d0 f5 ff ff       	call   c01002a1 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cd1:	c7 04 24 c0 8e 10 c0 	movl   $0xc0108ec0,(%esp)
c0100cd8:	e8 c4 f5 ff ff       	call   c01002a1 <cprintf>

    if (tf != NULL) {
c0100cdd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ce1:	74 0b                	je     c0100cee <kmonitor+0x2f>
        print_trapframe(tf);
c0100ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce6:	89 04 24             	mov    %eax,(%esp)
c0100ce9:	e8 e4 15 00 00       	call   c01022d2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cee:	c7 04 24 e5 8e 10 c0 	movl   $0xc0108ee5,(%esp)
c0100cf5:	e8 49 f6 ff ff       	call   c0100343 <readline>
c0100cfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d01:	74 eb                	je     c0100cee <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0d:	89 04 24             	mov    %eax,(%esp)
c0100d10:	e8 f5 fe ff ff       	call   c0100c0a <runcmd>
c0100d15:	85 c0                	test   %eax,%eax
c0100d17:	78 02                	js     c0100d1b <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d19:	eb d3                	jmp    c0100cee <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d1b:	90                   	nop
            }
        }
    }
}
c0100d1c:	90                   	nop
c0100d1d:	c9                   	leave  
c0100d1e:	c3                   	ret    

c0100d1f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d1f:	55                   	push   %ebp
c0100d20:	89 e5                	mov    %esp,%ebp
c0100d22:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d2c:	eb 3d                	jmp    c0100d6b <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d31:	89 d0                	mov    %edx,%eax
c0100d33:	01 c0                	add    %eax,%eax
c0100d35:	01 d0                	add    %edx,%eax
c0100d37:	c1 e0 02             	shl    $0x2,%eax
c0100d3a:	05 04 00 12 c0       	add    $0xc0120004,%eax
c0100d3f:	8b 08                	mov    (%eax),%ecx
c0100d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d44:	89 d0                	mov    %edx,%eax
c0100d46:	01 c0                	add    %eax,%eax
c0100d48:	01 d0                	add    %edx,%eax
c0100d4a:	c1 e0 02             	shl    $0x2,%eax
c0100d4d:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100d52:	8b 00                	mov    (%eax),%eax
c0100d54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5c:	c7 04 24 e9 8e 10 c0 	movl   $0xc0108ee9,(%esp)
c0100d63:	e8 39 f5 ff ff       	call   c01002a1 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d68:	ff 45 f4             	incl   -0xc(%ebp)
c0100d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d6e:	83 f8 02             	cmp    $0x2,%eax
c0100d71:	76 bb                	jbe    c0100d2e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d78:	c9                   	leave  
c0100d79:	c3                   	ret    

c0100d7a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d7a:	55                   	push   %ebp
c0100d7b:	89 e5                	mov    %esp,%ebp
c0100d7d:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d80:	e8 c2 fb ff ff       	call   c0100947 <print_kerninfo>
    return 0;
c0100d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8a:	c9                   	leave  
c0100d8b:	c3                   	ret    

c0100d8c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d8c:	55                   	push   %ebp
c0100d8d:	89 e5                	mov    %esp,%ebp
c0100d8f:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d92:	e8 fb fc ff ff       	call   c0100a92 <print_stackframe>
    return 0;
c0100d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d9c:	c9                   	leave  
c0100d9d:	c3                   	ret    

c0100d9e <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100d9e:	55                   	push   %ebp
c0100d9f:	89 e5                	mov    %esp,%ebp
c0100da1:	83 ec 14             	sub    $0x14,%esp
c0100da4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100da7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100dab:	90                   	nop
c0100dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100daf:	83 c0 07             	add    $0x7,%eax
c0100db2:	0f b7 c0             	movzwl %ax,%eax
c0100db5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100db9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dbd:	89 c2                	mov    %eax,%edx
c0100dbf:	ec                   	in     (%dx),%al
c0100dc0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dc3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dc7:	0f b6 c0             	movzbl %al,%eax
c0100dca:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100dcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd0:	25 80 00 00 00       	and    $0x80,%eax
c0100dd5:	85 c0                	test   %eax,%eax
c0100dd7:	75 d3                	jne    c0100dac <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100dd9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100ddd:	74 11                	je     c0100df0 <ide_wait_ready+0x52>
c0100ddf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de2:	83 e0 21             	and    $0x21,%eax
c0100de5:	85 c0                	test   %eax,%eax
c0100de7:	74 07                	je     c0100df0 <ide_wait_ready+0x52>
        return -1;
c0100de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100dee:	eb 05                	jmp    c0100df5 <ide_wait_ready+0x57>
    }
    return 0;
c0100df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df5:	c9                   	leave  
c0100df6:	c3                   	ret    

c0100df7 <ide_init>:

void
ide_init(void) {
c0100df7:	55                   	push   %ebp
c0100df8:	89 e5                	mov    %esp,%ebp
c0100dfa:	57                   	push   %edi
c0100dfb:	53                   	push   %ebx
c0100dfc:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e02:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e08:	e9 d4 02 00 00       	jmp    c01010e1 <ide_init+0x2ea>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e0d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e11:	c1 e0 03             	shl    $0x3,%eax
c0100e14:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e1b:	29 c2                	sub    %eax,%edx
c0100e1d:	89 d0                	mov    %edx,%eax
c0100e1f:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0100e24:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e27:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2b:	d1 e8                	shr    %eax
c0100e2d:	0f b7 c0             	movzwl %ax,%eax
c0100e30:	8b 04 85 f4 8e 10 c0 	mov    -0x3fef710c(,%eax,4),%eax
c0100e37:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e3b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e46:	00 
c0100e47:	89 04 24             	mov    %eax,(%esp)
c0100e4a:	e8 4f ff ff ff       	call   c0100d9e <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e4f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e53:	83 e0 01             	and    $0x1,%eax
c0100e56:	c1 e0 04             	shl    $0x4,%eax
c0100e59:	0c e0                	or     $0xe0,%al
c0100e5b:	0f b6 c0             	movzbl %al,%eax
c0100e5e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e62:	83 c2 06             	add    $0x6,%edx
c0100e65:	0f b7 d2             	movzwl %dx,%edx
c0100e68:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100e6c:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e6f:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100e73:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100e77:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e78:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e83:	00 
c0100e84:	89 04 24             	mov    %eax,(%esp)
c0100e87:	e8 12 ff ff ff       	call   c0100d9e <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e8c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e90:	83 c0 07             	add    $0x7,%eax
c0100e93:	0f b7 c0             	movzwl %ax,%eax
c0100e96:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100e9a:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100e9e:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100ea2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100ea5:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ea6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb1:	00 
c0100eb2:	89 04 24             	mov    %eax,(%esp)
c0100eb5:	e8 e4 fe ff ff       	call   c0100d9e <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100eba:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ebe:	83 c0 07             	add    $0x7,%eax
c0100ec1:	0f b7 c0             	movzwl %ax,%eax
c0100ec4:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ec8:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100ecc:	89 c2                	mov    %eax,%edx
c0100ece:	ec                   	in     (%dx),%al
c0100ecf:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ed2:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ed6:	84 c0                	test   %al,%al
c0100ed8:	0f 84 f9 01 00 00    	je     c01010d7 <ide_init+0x2e0>
c0100ede:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ee2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100ee9:	00 
c0100eea:	89 04 24             	mov    %eax,(%esp)
c0100eed:	e8 ac fe ff ff       	call   c0100d9e <ide_wait_ready>
c0100ef2:	85 c0                	test   %eax,%eax
c0100ef4:	0f 85 dd 01 00 00    	jne    c01010d7 <ide_init+0x2e0>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100efa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100efe:	c1 e0 03             	shl    $0x3,%eax
c0100f01:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f08:	29 c2                	sub    %eax,%edx
c0100f0a:	89 d0                	mov    %edx,%eax
c0100f0c:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0100f11:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f14:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0100f1b:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f21:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f24:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0100f2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100f2e:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f31:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f34:	89 cb                	mov    %ecx,%ebx
c0100f36:	89 df                	mov    %ebx,%edi
c0100f38:	89 c1                	mov    %eax,%ecx
c0100f3a:	fc                   	cld    
c0100f3b:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f3d:	89 c8                	mov    %ecx,%eax
c0100f3f:	89 fb                	mov    %edi,%ebx
c0100f41:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f44:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f47:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f4d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f50:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f53:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f59:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f5f:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f64:	85 c0                	test   %eax,%eax
c0100f66:	74 0e                	je     c0100f76 <ide_init+0x17f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f68:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f6b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f71:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f74:	eb 09                	jmp    c0100f7f <ide_init+0x188>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f79:	8b 40 78             	mov    0x78(%eax),%eax
c0100f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f7f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f83:	c1 e0 03             	shl    $0x3,%eax
c0100f86:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f8d:	29 c2                	sub    %eax,%edx
c0100f8f:	89 d0                	mov    %edx,%eax
c0100f91:	8d 90 44 34 12 c0    	lea    -0x3fedcbbc(%eax),%edx
c0100f97:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f9a:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f9c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fa0:	c1 e0 03             	shl    $0x3,%eax
c0100fa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100faa:	29 c2                	sub    %eax,%edx
c0100fac:	89 d0                	mov    %edx,%eax
c0100fae:	8d 90 48 34 12 c0    	lea    -0x3fedcbb8(%eax),%edx
c0100fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fb7:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100fbc:	83 c0 62             	add    $0x62,%eax
c0100fbf:	0f b7 00             	movzwl (%eax),%eax
c0100fc2:	25 00 02 00 00       	and    $0x200,%eax
c0100fc7:	85 c0                	test   %eax,%eax
c0100fc9:	75 24                	jne    c0100fef <ide_init+0x1f8>
c0100fcb:	c7 44 24 0c fc 8e 10 	movl   $0xc0108efc,0xc(%esp)
c0100fd2:	c0 
c0100fd3:	c7 44 24 08 3f 8f 10 	movl   $0xc0108f3f,0x8(%esp)
c0100fda:	c0 
c0100fdb:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100fe2:	00 
c0100fe3:	c7 04 24 54 8f 10 c0 	movl   $0xc0108f54,(%esp)
c0100fea:	e8 09 f4 ff ff       	call   c01003f8 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100fef:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ff3:	c1 e0 03             	shl    $0x3,%eax
c0100ff6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100ffd:	29 c2                	sub    %eax,%edx
c0100fff:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0101005:	83 c0 0c             	add    $0xc,%eax
c0101008:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010100b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010100e:	83 c0 36             	add    $0x36,%eax
c0101011:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c0101014:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c010101b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101022:	eb 34                	jmp    c0101058 <ide_init+0x261>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101024:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101027:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010102a:	01 c2                	add    %eax,%edx
c010102c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010102f:	8d 48 01             	lea    0x1(%eax),%ecx
c0101032:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101035:	01 c8                	add    %ecx,%eax
c0101037:	0f b6 00             	movzbl (%eax),%eax
c010103a:	88 02                	mov    %al,(%edx)
c010103c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010103f:	8d 50 01             	lea    0x1(%eax),%edx
c0101042:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101045:	01 c2                	add    %eax,%edx
c0101047:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010104a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104d:	01 c8                	add    %ecx,%eax
c010104f:	0f b6 00             	movzbl (%eax),%eax
c0101052:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101054:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101058:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010105b:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c010105e:	72 c4                	jb     c0101024 <ide_init+0x22d>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101060:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101063:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101066:	01 d0                	add    %edx,%eax
c0101068:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010106b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010106e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101071:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101074:	85 c0                	test   %eax,%eax
c0101076:	74 0f                	je     c0101087 <ide_init+0x290>
c0101078:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010107b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010107e:	01 d0                	add    %edx,%eax
c0101080:	0f b6 00             	movzbl (%eax),%eax
c0101083:	3c 20                	cmp    $0x20,%al
c0101085:	74 d9                	je     c0101060 <ide_init+0x269>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101087:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010108b:	c1 e0 03             	shl    $0x3,%eax
c010108e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101095:	29 c2                	sub    %eax,%edx
c0101097:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c010109d:	8d 48 0c             	lea    0xc(%eax),%ecx
c01010a0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a4:	c1 e0 03             	shl    $0x3,%eax
c01010a7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010ae:	29 c2                	sub    %eax,%edx
c01010b0:	89 d0                	mov    %edx,%eax
c01010b2:	05 48 34 12 c0       	add    $0xc0123448,%eax
c01010b7:	8b 10                	mov    (%eax),%edx
c01010b9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010bd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010c1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010c9:	c7 04 24 66 8f 10 c0 	movl   $0xc0108f66,(%esp)
c01010d0:	e8 cc f1 ff ff       	call   c01002a1 <cprintf>
c01010d5:	eb 01                	jmp    c01010d8 <ide_init+0x2e1>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c01010d7:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010d8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010dc:	40                   	inc    %eax
c01010dd:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010e1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010e5:	83 f8 03             	cmp    $0x3,%eax
c01010e8:	0f 86 1f fd ff ff    	jbe    c0100e0d <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010ee:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01010f5:	e8 8a 0e 00 00       	call   c0101f84 <pic_enable>
    pic_enable(IRQ_IDE2);
c01010fa:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101101:	e8 7e 0e 00 00       	call   c0101f84 <pic_enable>
}
c0101106:	90                   	nop
c0101107:	81 c4 50 02 00 00    	add    $0x250,%esp
c010110d:	5b                   	pop    %ebx
c010110e:	5f                   	pop    %edi
c010110f:	5d                   	pop    %ebp
c0101110:	c3                   	ret    

c0101111 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101111:	55                   	push   %ebp
c0101112:	89 e5                	mov    %esp,%ebp
c0101114:	83 ec 04             	sub    $0x4,%esp
c0101117:	8b 45 08             	mov    0x8(%ebp),%eax
c010111a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010111e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101122:	83 f8 03             	cmp    $0x3,%eax
c0101125:	77 25                	ja     c010114c <ide_device_valid+0x3b>
c0101127:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010112b:	c1 e0 03             	shl    $0x3,%eax
c010112e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101135:	29 c2                	sub    %eax,%edx
c0101137:	89 d0                	mov    %edx,%eax
c0101139:	05 40 34 12 c0       	add    $0xc0123440,%eax
c010113e:	0f b6 00             	movzbl (%eax),%eax
c0101141:	84 c0                	test   %al,%al
c0101143:	74 07                	je     c010114c <ide_device_valid+0x3b>
c0101145:	b8 01 00 00 00       	mov    $0x1,%eax
c010114a:	eb 05                	jmp    c0101151 <ide_device_valid+0x40>
c010114c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101151:	c9                   	leave  
c0101152:	c3                   	ret    

c0101153 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101153:	55                   	push   %ebp
c0101154:	89 e5                	mov    %esp,%ebp
c0101156:	83 ec 08             	sub    $0x8,%esp
c0101159:	8b 45 08             	mov    0x8(%ebp),%eax
c010115c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101160:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101164:	89 04 24             	mov    %eax,(%esp)
c0101167:	e8 a5 ff ff ff       	call   c0101111 <ide_device_valid>
c010116c:	85 c0                	test   %eax,%eax
c010116e:	74 1b                	je     c010118b <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101170:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101174:	c1 e0 03             	shl    $0x3,%eax
c0101177:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010117e:	29 c2                	sub    %eax,%edx
c0101180:	89 d0                	mov    %edx,%eax
c0101182:	05 48 34 12 c0       	add    $0xc0123448,%eax
c0101187:	8b 00                	mov    (%eax),%eax
c0101189:	eb 05                	jmp    c0101190 <ide_device_size+0x3d>
    }
    return 0;
c010118b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101190:	c9                   	leave  
c0101191:	c3                   	ret    

c0101192 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101192:	55                   	push   %ebp
c0101193:	89 e5                	mov    %esp,%ebp
c0101195:	57                   	push   %edi
c0101196:	53                   	push   %ebx
c0101197:	83 ec 50             	sub    $0x50,%esp
c010119a:	8b 45 08             	mov    0x8(%ebp),%eax
c010119d:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01011a1:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01011a8:	77 27                	ja     c01011d1 <ide_read_secs+0x3f>
c01011aa:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011ae:	83 f8 03             	cmp    $0x3,%eax
c01011b1:	77 1e                	ja     c01011d1 <ide_read_secs+0x3f>
c01011b3:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011b7:	c1 e0 03             	shl    $0x3,%eax
c01011ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011c1:	29 c2                	sub    %eax,%edx
c01011c3:	89 d0                	mov    %edx,%eax
c01011c5:	05 40 34 12 c0       	add    $0xc0123440,%eax
c01011ca:	0f b6 00             	movzbl (%eax),%eax
c01011cd:	84 c0                	test   %al,%al
c01011cf:	75 24                	jne    c01011f5 <ide_read_secs+0x63>
c01011d1:	c7 44 24 0c 84 8f 10 	movl   $0xc0108f84,0xc(%esp)
c01011d8:	c0 
c01011d9:	c7 44 24 08 3f 8f 10 	movl   $0xc0108f3f,0x8(%esp)
c01011e0:	c0 
c01011e1:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011e8:	00 
c01011e9:	c7 04 24 54 8f 10 c0 	movl   $0xc0108f54,(%esp)
c01011f0:	e8 03 f2 ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011f5:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01011fc:	77 0f                	ja     c010120d <ide_read_secs+0x7b>
c01011fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101201:	8b 45 14             	mov    0x14(%ebp),%eax
c0101204:	01 d0                	add    %edx,%eax
c0101206:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010120b:	76 24                	jbe    c0101231 <ide_read_secs+0x9f>
c010120d:	c7 44 24 0c ac 8f 10 	movl   $0xc0108fac,0xc(%esp)
c0101214:	c0 
c0101215:	c7 44 24 08 3f 8f 10 	movl   $0xc0108f3f,0x8(%esp)
c010121c:	c0 
c010121d:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101224:	00 
c0101225:	c7 04 24 54 8f 10 c0 	movl   $0xc0108f54,(%esp)
c010122c:	e8 c7 f1 ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101231:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101235:	d1 e8                	shr    %eax
c0101237:	0f b7 c0             	movzwl %ax,%eax
c010123a:	8b 04 85 f4 8e 10 c0 	mov    -0x3fef710c(,%eax,4),%eax
c0101241:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101245:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101249:	d1 e8                	shr    %eax
c010124b:	0f b7 c0             	movzwl %ax,%eax
c010124e:	0f b7 04 85 f6 8e 10 	movzwl -0x3fef710a(,%eax,4),%eax
c0101255:	c0 
c0101256:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010125a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010125e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101265:	00 
c0101266:	89 04 24             	mov    %eax,(%esp)
c0101269:	e8 30 fb ff ff       	call   c0100d9e <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101271:	83 c0 02             	add    $0x2,%eax
c0101274:	0f b7 c0             	movzwl %ax,%eax
c0101277:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010127b:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010127f:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101283:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101287:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101288:	8b 45 14             	mov    0x14(%ebp),%eax
c010128b:	0f b6 c0             	movzbl %al,%eax
c010128e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101292:	83 c2 02             	add    $0x2,%edx
c0101295:	0f b7 d2             	movzwl %dx,%edx
c0101298:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c010129c:	88 45 d8             	mov    %al,-0x28(%ebp)
c010129f:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01012a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01012a6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01012a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012aa:	0f b6 c0             	movzbl %al,%eax
c01012ad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b1:	83 c2 03             	add    $0x3,%edx
c01012b4:	0f b7 d2             	movzwl %dx,%edx
c01012b7:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012bb:	88 45 d9             	mov    %al,-0x27(%ebp)
c01012be:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01012c2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012c6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012ca:	c1 e8 08             	shr    $0x8,%eax
c01012cd:	0f b6 c0             	movzbl %al,%eax
c01012d0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d4:	83 c2 04             	add    $0x4,%edx
c01012d7:	0f b7 d2             	movzwl %dx,%edx
c01012da:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01012de:	88 45 da             	mov    %al,-0x26(%ebp)
c01012e1:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01012e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01012e8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012ec:	c1 e8 10             	shr    $0x10,%eax
c01012ef:	0f b6 c0             	movzbl %al,%eax
c01012f2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012f6:	83 c2 05             	add    $0x5,%edx
c01012f9:	0f b7 d2             	movzwl %dx,%edx
c01012fc:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101300:	88 45 db             	mov    %al,-0x25(%ebp)
c0101303:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101307:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010130b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010130c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010130f:	24 01                	and    $0x1,%al
c0101311:	c0 e0 04             	shl    $0x4,%al
c0101314:	88 c2                	mov    %al,%dl
c0101316:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101319:	c1 e8 18             	shr    $0x18,%eax
c010131c:	24 0f                	and    $0xf,%al
c010131e:	08 d0                	or     %dl,%al
c0101320:	0c e0                	or     $0xe0,%al
c0101322:	0f b6 c0             	movzbl %al,%eax
c0101325:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101329:	83 c2 06             	add    $0x6,%edx
c010132c:	0f b7 d2             	movzwl %dx,%edx
c010132f:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101333:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101336:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010133a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010133d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010133e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101342:	83 c0 07             	add    $0x7,%eax
c0101345:	0f b7 c0             	movzwl %ax,%eax
c0101348:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010134c:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0101350:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101354:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101358:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101359:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101360:	eb 57                	jmp    c01013b9 <ide_read_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101362:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101366:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010136d:	00 
c010136e:	89 04 24             	mov    %eax,(%esp)
c0101371:	e8 28 fa ff ff       	call   c0100d9e <ide_wait_ready>
c0101376:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101379:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010137d:	75 42                	jne    c01013c1 <ide_read_secs+0x22f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c010137f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101383:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101386:	8b 45 10             	mov    0x10(%ebp),%eax
c0101389:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010138c:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101393:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101396:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101399:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010139c:	89 cb                	mov    %ecx,%ebx
c010139e:	89 df                	mov    %ebx,%edi
c01013a0:	89 c1                	mov    %eax,%ecx
c01013a2:	fc                   	cld    
c01013a3:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01013a5:	89 c8                	mov    %ecx,%eax
c01013a7:	89 fb                	mov    %edi,%ebx
c01013a9:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01013ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013af:	ff 4d 14             	decl   0x14(%ebp)
c01013b2:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01013b9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013bd:	75 a3                	jne    c0101362 <ide_read_secs+0x1d0>
c01013bf:	eb 01                	jmp    c01013c2 <ide_read_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01013c1:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013c5:	83 c4 50             	add    $0x50,%esp
c01013c8:	5b                   	pop    %ebx
c01013c9:	5f                   	pop    %edi
c01013ca:	5d                   	pop    %ebp
c01013cb:	c3                   	ret    

c01013cc <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013cc:	55                   	push   %ebp
c01013cd:	89 e5                	mov    %esp,%ebp
c01013cf:	56                   	push   %esi
c01013d0:	53                   	push   %ebx
c01013d1:	83 ec 50             	sub    $0x50,%esp
c01013d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d7:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013db:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013e2:	77 27                	ja     c010140b <ide_write_secs+0x3f>
c01013e4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013e8:	83 f8 03             	cmp    $0x3,%eax
c01013eb:	77 1e                	ja     c010140b <ide_write_secs+0x3f>
c01013ed:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013f1:	c1 e0 03             	shl    $0x3,%eax
c01013f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01013fb:	29 c2                	sub    %eax,%edx
c01013fd:	89 d0                	mov    %edx,%eax
c01013ff:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0101404:	0f b6 00             	movzbl (%eax),%eax
c0101407:	84 c0                	test   %al,%al
c0101409:	75 24                	jne    c010142f <ide_write_secs+0x63>
c010140b:	c7 44 24 0c 84 8f 10 	movl   $0xc0108f84,0xc(%esp)
c0101412:	c0 
c0101413:	c7 44 24 08 3f 8f 10 	movl   $0xc0108f3f,0x8(%esp)
c010141a:	c0 
c010141b:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101422:	00 
c0101423:	c7 04 24 54 8f 10 c0 	movl   $0xc0108f54,(%esp)
c010142a:	e8 c9 ef ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010142f:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101436:	77 0f                	ja     c0101447 <ide_write_secs+0x7b>
c0101438:	8b 55 0c             	mov    0xc(%ebp),%edx
c010143b:	8b 45 14             	mov    0x14(%ebp),%eax
c010143e:	01 d0                	add    %edx,%eax
c0101440:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101445:	76 24                	jbe    c010146b <ide_write_secs+0x9f>
c0101447:	c7 44 24 0c ac 8f 10 	movl   $0xc0108fac,0xc(%esp)
c010144e:	c0 
c010144f:	c7 44 24 08 3f 8f 10 	movl   $0xc0108f3f,0x8(%esp)
c0101456:	c0 
c0101457:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010145e:	00 
c010145f:	c7 04 24 54 8f 10 c0 	movl   $0xc0108f54,(%esp)
c0101466:	e8 8d ef ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010146b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010146f:	d1 e8                	shr    %eax
c0101471:	0f b7 c0             	movzwl %ax,%eax
c0101474:	8b 04 85 f4 8e 10 c0 	mov    -0x3fef710c(,%eax,4),%eax
c010147b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010147f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101483:	d1 e8                	shr    %eax
c0101485:	0f b7 c0             	movzwl %ax,%eax
c0101488:	0f b7 04 85 f6 8e 10 	movzwl -0x3fef710a(,%eax,4),%eax
c010148f:	c0 
c0101490:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101494:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101498:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010149f:	00 
c01014a0:	89 04 24             	mov    %eax,(%esp)
c01014a3:	e8 f6 f8 ff ff       	call   c0100d9e <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014ab:	83 c0 02             	add    $0x2,%eax
c01014ae:	0f b7 c0             	movzwl %ax,%eax
c01014b1:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01014b5:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014b9:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01014bd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01014c1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014c2:	8b 45 14             	mov    0x14(%ebp),%eax
c01014c5:	0f b6 c0             	movzbl %al,%eax
c01014c8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014cc:	83 c2 02             	add    $0x2,%edx
c01014cf:	0f b7 d2             	movzwl %dx,%edx
c01014d2:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01014d6:	88 45 d8             	mov    %al,-0x28(%ebp)
c01014d9:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01014dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01014e0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014e4:	0f b6 c0             	movzbl %al,%eax
c01014e7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014eb:	83 c2 03             	add    $0x3,%edx
c01014ee:	0f b7 d2             	movzwl %dx,%edx
c01014f1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01014f5:	88 45 d9             	mov    %al,-0x27(%ebp)
c01014f8:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01014fc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101500:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101501:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101504:	c1 e8 08             	shr    $0x8,%eax
c0101507:	0f b6 c0             	movzbl %al,%eax
c010150a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010150e:	83 c2 04             	add    $0x4,%edx
c0101511:	0f b7 d2             	movzwl %dx,%edx
c0101514:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0101518:	88 45 da             	mov    %al,-0x26(%ebp)
c010151b:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010151f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101522:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101523:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101526:	c1 e8 10             	shr    $0x10,%eax
c0101529:	0f b6 c0             	movzbl %al,%eax
c010152c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101530:	83 c2 05             	add    $0x5,%edx
c0101533:	0f b7 d2             	movzwl %dx,%edx
c0101536:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010153a:	88 45 db             	mov    %al,-0x25(%ebp)
c010153d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101541:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101545:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101546:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101549:	24 01                	and    $0x1,%al
c010154b:	c0 e0 04             	shl    $0x4,%al
c010154e:	88 c2                	mov    %al,%dl
c0101550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101553:	c1 e8 18             	shr    $0x18,%eax
c0101556:	24 0f                	and    $0xf,%al
c0101558:	08 d0                	or     %dl,%al
c010155a:	0c e0                	or     $0xe0,%al
c010155c:	0f b6 c0             	movzbl %al,%eax
c010155f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101563:	83 c2 06             	add    $0x6,%edx
c0101566:	0f b7 d2             	movzwl %dx,%edx
c0101569:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c010156d:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101570:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101574:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101577:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101578:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010157c:	83 c0 07             	add    $0x7,%eax
c010157f:	0f b7 c0             	movzwl %ax,%eax
c0101582:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101586:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c010158a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010158e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101592:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101593:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010159a:	eb 57                	jmp    c01015f3 <ide_write_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010159c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01015a7:	00 
c01015a8:	89 04 24             	mov    %eax,(%esp)
c01015ab:	e8 ee f7 ff ff       	call   c0100d9e <ide_wait_ready>
c01015b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01015b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01015b7:	75 42                	jne    c01015fb <ide_write_secs+0x22f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01015b9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01015c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01015c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015c6:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01015cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01015d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01015d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01015d6:	89 cb                	mov    %ecx,%ebx
c01015d8:	89 de                	mov    %ebx,%esi
c01015da:	89 c1                	mov    %eax,%ecx
c01015dc:	fc                   	cld    
c01015dd:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01015df:	89 c8                	mov    %ecx,%eax
c01015e1:	89 f3                	mov    %esi,%ebx
c01015e3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01015e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015e9:	ff 4d 14             	decl   0x14(%ebp)
c01015ec:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015f3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015f7:	75 a3                	jne    c010159c <ide_write_secs+0x1d0>
c01015f9:	eb 01                	jmp    c01015fc <ide_write_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01015fb:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ff:	83 c4 50             	add    $0x50,%esp
c0101602:	5b                   	pop    %ebx
c0101603:	5e                   	pop    %esi
c0101604:	5d                   	pop    %ebp
c0101605:	c3                   	ret    

c0101606 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101606:	55                   	push   %ebp
c0101607:	89 e5                	mov    %esp,%ebp
c0101609:	83 ec 28             	sub    $0x28,%esp
c010160c:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101612:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101616:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c010161a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010161e:	ee                   	out    %al,(%dx)
c010161f:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0101625:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0101629:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c010162d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101630:	ee                   	out    %al,(%dx)
c0101631:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101637:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c010163b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010163f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101643:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101644:	c7 05 0c 40 12 c0 00 	movl   $0x0,0xc012400c
c010164b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010164e:	c7 04 24 e6 8f 10 c0 	movl   $0xc0108fe6,(%esp)
c0101655:	e8 47 ec ff ff       	call   c01002a1 <cprintf>
    pic_enable(IRQ_TIMER);
c010165a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101661:	e8 1e 09 00 00       	call   c0101f84 <pic_enable>
}
c0101666:	90                   	nop
c0101667:	c9                   	leave  
c0101668:	c3                   	ret    

c0101669 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101669:	55                   	push   %ebp
c010166a:	89 e5                	mov    %esp,%ebp
c010166c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010166f:	9c                   	pushf  
c0101670:	58                   	pop    %eax
c0101671:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101674:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0101677:	25 00 02 00 00       	and    $0x200,%eax
c010167c:	85 c0                	test   %eax,%eax
c010167e:	74 0c                	je     c010168c <__intr_save+0x23>
        intr_disable();
c0101680:	e8 6c 0a 00 00       	call   c01020f1 <intr_disable>
        return 1;
c0101685:	b8 01 00 00 00       	mov    $0x1,%eax
c010168a:	eb 05                	jmp    c0101691 <__intr_save+0x28>
    }
    return 0;
c010168c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101691:	c9                   	leave  
c0101692:	c3                   	ret    

c0101693 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101693:	55                   	push   %ebp
c0101694:	89 e5                	mov    %esp,%ebp
c0101696:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101699:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010169d:	74 05                	je     c01016a4 <__intr_restore+0x11>
        intr_enable();
c010169f:	e8 46 0a 00 00       	call   c01020ea <intr_enable>
    }
}
c01016a4:	90                   	nop
c01016a5:	c9                   	leave  
c01016a6:	c3                   	ret    

c01016a7 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01016a7:	55                   	push   %ebp
c01016a8:	89 e5                	mov    %esp,%ebp
c01016aa:	83 ec 10             	sub    $0x10,%esp
c01016ad:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016b3:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016b7:	89 c2                	mov    %eax,%edx
c01016b9:	ec                   	in     (%dx),%al
c01016ba:	88 45 f4             	mov    %al,-0xc(%ebp)
c01016bd:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01016c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016c6:	89 c2                	mov    %eax,%edx
c01016c8:	ec                   	in     (%dx),%al
c01016c9:	88 45 f5             	mov    %al,-0xb(%ebp)
c01016cc:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016d2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016d6:	89 c2                	mov    %eax,%edx
c01016d8:	ec                   	in     (%dx),%al
c01016d9:	88 45 f6             	mov    %al,-0xa(%ebp)
c01016dc:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01016e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01016e5:	89 c2                	mov    %eax,%edx
c01016e7:	ec                   	in     (%dx),%al
c01016e8:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016eb:	90                   	nop
c01016ec:	c9                   	leave  
c01016ed:	c3                   	ret    

c01016ee <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016ee:	55                   	push   %ebp
c01016ef:	89 e5                	mov    %esp,%ebp
c01016f1:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016f4:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016fe:	0f b7 00             	movzwl (%eax),%eax
c0101701:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101705:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101708:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c010170d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101710:	0f b7 00             	movzwl (%eax),%eax
c0101713:	0f b7 c0             	movzwl %ax,%eax
c0101716:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c010171b:	74 12                	je     c010172f <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010171d:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101724:	66 c7 05 26 35 12 c0 	movw   $0x3b4,0xc0123526
c010172b:	b4 03 
c010172d:	eb 13                	jmp    c0101742 <cga_init+0x54>
    } else {
        *cp = was;
c010172f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101732:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101736:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101739:	66 c7 05 26 35 12 c0 	movw   $0x3d4,0xc0123526
c0101740:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101742:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101749:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c010174d:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101751:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101755:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101758:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101759:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101760:	40                   	inc    %eax
c0101761:	0f b7 c0             	movzwl %ax,%eax
c0101764:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101768:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010176c:	89 c2                	mov    %eax,%edx
c010176e:	ec                   	in     (%dx),%al
c010176f:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101772:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101776:	0f b6 c0             	movzbl %al,%eax
c0101779:	c1 e0 08             	shl    $0x8,%eax
c010177c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010177f:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101786:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c010178a:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010178e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0101792:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101795:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101796:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c010179d:	40                   	inc    %eax
c010179e:	0f b7 c0             	movzwl %ax,%eax
c01017a1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017a5:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01017a9:	89 c2                	mov    %eax,%edx
c01017ab:	ec                   	in     (%dx),%al
c01017ac:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01017af:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017b3:	0f b6 c0             	movzbl %al,%eax
c01017b6:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017bc:	a3 20 35 12 c0       	mov    %eax,0xc0123520
    crt_pos = pos;
c01017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017c4:	0f b7 c0             	movzwl %ax,%eax
c01017c7:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
}
c01017cd:	90                   	nop
c01017ce:	c9                   	leave  
c01017cf:	c3                   	ret    

c01017d0 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017d0:	55                   	push   %ebp
c01017d1:	89 e5                	mov    %esp,%ebp
c01017d3:	83 ec 38             	sub    $0x38,%esp
c01017d6:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01017dc:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017e0:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017e4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017e8:	ee                   	out    %al,(%dx)
c01017e9:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01017ef:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01017f3:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017fa:	ee                   	out    %al,(%dx)
c01017fb:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0101801:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0101805:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101809:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010180d:	ee                   	out    %al,(%dx)
c010180e:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0101814:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101818:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010181c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0101826:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c010182a:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010182e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
c0101833:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0101839:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c010183d:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101841:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101844:	ee                   	out    %al,(%dx)
c0101845:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010184b:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c010184f:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101853:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101857:	ee                   	out    %al,(%dx)
c0101858:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010185e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101861:	89 c2                	mov    %eax,%edx
c0101863:	ec                   	in     (%dx),%al
c0101864:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0101867:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010186b:	3c ff                	cmp    $0xff,%al
c010186d:	0f 95 c0             	setne  %al
c0101870:	0f b6 c0             	movzbl %al,%eax
c0101873:	a3 28 35 12 c0       	mov    %eax,0xc0123528
c0101878:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010187e:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101882:	89 c2                	mov    %eax,%edx
c0101884:	ec                   	in     (%dx),%al
c0101885:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101888:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c010188e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101891:	89 c2                	mov    %eax,%edx
c0101893:	ec                   	in     (%dx),%al
c0101894:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101897:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c010189c:	85 c0                	test   %eax,%eax
c010189e:	74 0c                	je     c01018ac <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c01018a0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01018a7:	e8 d8 06 00 00       	call   c0101f84 <pic_enable>
    }
}
c01018ac:	90                   	nop
c01018ad:	c9                   	leave  
c01018ae:	c3                   	ret    

c01018af <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01018af:	55                   	push   %ebp
c01018b0:	89 e5                	mov    %esp,%ebp
c01018b2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018bc:	eb 08                	jmp    c01018c6 <lpt_putc_sub+0x17>
        delay();
c01018be:	e8 e4 fd ff ff       	call   c01016a7 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018c3:	ff 45 fc             	incl   -0x4(%ebp)
c01018c6:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c01018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018cf:	89 c2                	mov    %eax,%edx
c01018d1:	ec                   	in     (%dx),%al
c01018d2:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c01018d5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01018d9:	84 c0                	test   %al,%al
c01018db:	78 09                	js     c01018e6 <lpt_putc_sub+0x37>
c01018dd:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018e4:	7e d8                	jle    c01018be <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01018e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01018e9:	0f b6 c0             	movzbl %al,%eax
c01018ec:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c01018f2:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018f5:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01018f9:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01018fc:	ee                   	out    %al,(%dx)
c01018fd:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101903:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101907:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010190b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010190f:	ee                   	out    %al,(%dx)
c0101910:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0101916:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c010191a:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c010191e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101922:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101923:	90                   	nop
c0101924:	c9                   	leave  
c0101925:	c3                   	ret    

c0101926 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101926:	55                   	push   %ebp
c0101927:	89 e5                	mov    %esp,%ebp
c0101929:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010192c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101930:	74 0d                	je     c010193f <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101932:	8b 45 08             	mov    0x8(%ebp),%eax
c0101935:	89 04 24             	mov    %eax,(%esp)
c0101938:	e8 72 ff ff ff       	call   c01018af <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010193d:	eb 24                	jmp    c0101963 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c010193f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101946:	e8 64 ff ff ff       	call   c01018af <lpt_putc_sub>
        lpt_putc_sub(' ');
c010194b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101952:	e8 58 ff ff ff       	call   c01018af <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101957:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010195e:	e8 4c ff ff ff       	call   c01018af <lpt_putc_sub>
    }
}
c0101963:	90                   	nop
c0101964:	c9                   	leave  
c0101965:	c3                   	ret    

c0101966 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101966:	55                   	push   %ebp
c0101967:	89 e5                	mov    %esp,%ebp
c0101969:	53                   	push   %ebx
c010196a:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010196d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101970:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101975:	85 c0                	test   %eax,%eax
c0101977:	75 07                	jne    c0101980 <cga_putc+0x1a>
        c |= 0x0700;
c0101979:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101980:	8b 45 08             	mov    0x8(%ebp),%eax
c0101983:	0f b6 c0             	movzbl %al,%eax
c0101986:	83 f8 0a             	cmp    $0xa,%eax
c0101989:	74 54                	je     c01019df <cga_putc+0x79>
c010198b:	83 f8 0d             	cmp    $0xd,%eax
c010198e:	74 62                	je     c01019f2 <cga_putc+0x8c>
c0101990:	83 f8 08             	cmp    $0x8,%eax
c0101993:	0f 85 93 00 00 00    	jne    c0101a2c <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101999:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019a0:	85 c0                	test   %eax,%eax
c01019a2:	0f 84 ae 00 00 00    	je     c0101a56 <cga_putc+0xf0>
            crt_pos --;
c01019a8:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019af:	48                   	dec    %eax
c01019b0:	0f b7 c0             	movzwl %ax,%eax
c01019b3:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019b9:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c01019be:	0f b7 15 24 35 12 c0 	movzwl 0xc0123524,%edx
c01019c5:	01 d2                	add    %edx,%edx
c01019c7:	01 c2                	add    %eax,%edx
c01019c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01019cc:	98                   	cwtl   
c01019cd:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019d2:	98                   	cwtl   
c01019d3:	83 c8 20             	or     $0x20,%eax
c01019d6:	98                   	cwtl   
c01019d7:	0f b7 c0             	movzwl %ax,%eax
c01019da:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019dd:	eb 77                	jmp    c0101a56 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c01019df:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019e6:	83 c0 50             	add    $0x50,%eax
c01019e9:	0f b7 c0             	movzwl %ax,%eax
c01019ec:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019f2:	0f b7 1d 24 35 12 c0 	movzwl 0xc0123524,%ebx
c01019f9:	0f b7 0d 24 35 12 c0 	movzwl 0xc0123524,%ecx
c0101a00:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101a05:	89 c8                	mov    %ecx,%eax
c0101a07:	f7 e2                	mul    %edx
c0101a09:	c1 ea 06             	shr    $0x6,%edx
c0101a0c:	89 d0                	mov    %edx,%eax
c0101a0e:	c1 e0 02             	shl    $0x2,%eax
c0101a11:	01 d0                	add    %edx,%eax
c0101a13:	c1 e0 04             	shl    $0x4,%eax
c0101a16:	29 c1                	sub    %eax,%ecx
c0101a18:	89 c8                	mov    %ecx,%eax
c0101a1a:	0f b7 c0             	movzwl %ax,%eax
c0101a1d:	29 c3                	sub    %eax,%ebx
c0101a1f:	89 d8                	mov    %ebx,%eax
c0101a21:	0f b7 c0             	movzwl %ax,%eax
c0101a24:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
        break;
c0101a2a:	eb 2b                	jmp    c0101a57 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a2c:	8b 0d 20 35 12 c0    	mov    0xc0123520,%ecx
c0101a32:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a39:	8d 50 01             	lea    0x1(%eax),%edx
c0101a3c:	0f b7 d2             	movzwl %dx,%edx
c0101a3f:	66 89 15 24 35 12 c0 	mov    %dx,0xc0123524
c0101a46:	01 c0                	add    %eax,%eax
c0101a48:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4e:	0f b7 c0             	movzwl %ax,%eax
c0101a51:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a54:	eb 01                	jmp    c0101a57 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101a56:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a57:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a5e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a63:	76 5d                	jbe    c0101ac2 <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a65:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101a6a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a70:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101a75:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a7c:	00 
c0101a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a81:	89 04 24             	mov    %eax,(%esp)
c0101a84:	e8 bd 68 00 00       	call   c0108346 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a89:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a90:	eb 14                	jmp    c0101aa6 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c0101a92:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a9a:	01 d2                	add    %edx,%edx
c0101a9c:	01 d0                	add    %edx,%eax
c0101a9e:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101aa3:	ff 45 f4             	incl   -0xc(%ebp)
c0101aa6:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101aad:	7e e3                	jle    c0101a92 <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101aaf:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101ab6:	83 e8 50             	sub    $0x50,%eax
c0101ab9:	0f b7 c0             	movzwl %ax,%eax
c0101abc:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ac2:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101ac9:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101acd:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101ad1:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101ad5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ad9:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ada:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101ae1:	c1 e8 08             	shr    $0x8,%eax
c0101ae4:	0f b7 c0             	movzwl %ax,%eax
c0101ae7:	0f b6 c0             	movzbl %al,%eax
c0101aea:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101af1:	42                   	inc    %edx
c0101af2:	0f b7 d2             	movzwl %dx,%edx
c0101af5:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101af9:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101afc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101b00:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101b03:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101b04:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101b0b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101b0f:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101b13:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101b17:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b1b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b1c:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101b23:	0f b6 c0             	movzbl %al,%eax
c0101b26:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101b2d:	42                   	inc    %edx
c0101b2e:	0f b7 d2             	movzwl %dx,%edx
c0101b31:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101b35:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101b38:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101b3c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101b3f:	ee                   	out    %al,(%dx)
}
c0101b40:	90                   	nop
c0101b41:	83 c4 24             	add    $0x24,%esp
c0101b44:	5b                   	pop    %ebx
c0101b45:	5d                   	pop    %ebp
c0101b46:	c3                   	ret    

c0101b47 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b47:	55                   	push   %ebp
c0101b48:	89 e5                	mov    %esp,%ebp
c0101b4a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b54:	eb 08                	jmp    c0101b5e <serial_putc_sub+0x17>
        delay();
c0101b56:	e8 4c fb ff ff       	call   c01016a7 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b5b:	ff 45 fc             	incl   -0x4(%ebp)
c0101b5e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b64:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b67:	89 c2                	mov    %eax,%edx
c0101b69:	ec                   	in     (%dx),%al
c0101b6a:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101b6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101b71:	0f b6 c0             	movzbl %al,%eax
c0101b74:	83 e0 20             	and    $0x20,%eax
c0101b77:	85 c0                	test   %eax,%eax
c0101b79:	75 09                	jne    c0101b84 <serial_putc_sub+0x3d>
c0101b7b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b82:	7e d2                	jle    c0101b56 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101b84:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b87:	0f b6 c0             	movzbl %al,%eax
c0101b8a:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101b90:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b93:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101b97:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101b9b:	ee                   	out    %al,(%dx)
}
c0101b9c:	90                   	nop
c0101b9d:	c9                   	leave  
c0101b9e:	c3                   	ret    

c0101b9f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101b9f:	55                   	push   %ebp
c0101ba0:	89 e5                	mov    %esp,%ebp
c0101ba2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101ba5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101ba9:	74 0d                	je     c0101bb8 <serial_putc+0x19>
        serial_putc_sub(c);
c0101bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bae:	89 04 24             	mov    %eax,(%esp)
c0101bb1:	e8 91 ff ff ff       	call   c0101b47 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101bb6:	eb 24                	jmp    c0101bdc <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101bb8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bbf:	e8 83 ff ff ff       	call   c0101b47 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bc4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bcb:	e8 77 ff ff ff       	call   c0101b47 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bd0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bd7:	e8 6b ff ff ff       	call   c0101b47 <serial_putc_sub>
    }
}
c0101bdc:	90                   	nop
c0101bdd:	c9                   	leave  
c0101bde:	c3                   	ret    

c0101bdf <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101bdf:	55                   	push   %ebp
c0101be0:	89 e5                	mov    %esp,%ebp
c0101be2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101be5:	eb 33                	jmp    c0101c1a <cons_intr+0x3b>
        if (c != 0) {
c0101be7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101beb:	74 2d                	je     c0101c1a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101bed:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101bf2:	8d 50 01             	lea    0x1(%eax),%edx
c0101bf5:	89 15 44 37 12 c0    	mov    %edx,0xc0123744
c0101bfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bfe:	88 90 40 35 12 c0    	mov    %dl,-0x3fedcac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c04:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101c09:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c0e:	75 0a                	jne    c0101c1a <cons_intr+0x3b>
                cons.wpos = 0;
c0101c10:	c7 05 44 37 12 c0 00 	movl   $0x0,0xc0123744
c0101c17:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1d:	ff d0                	call   *%eax
c0101c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c22:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c26:	75 bf                	jne    c0101be7 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101c28:	90                   	nop
c0101c29:	c9                   	leave  
c0101c2a:	c3                   	ret    

c0101c2b <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c2b:	55                   	push   %ebp
c0101c2c:	89 e5                	mov    %esp,%ebp
c0101c2e:	83 ec 10             	sub    $0x10,%esp
c0101c31:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c37:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101c3a:	89 c2                	mov    %eax,%edx
c0101c3c:	ec                   	in     (%dx),%al
c0101c3d:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101c40:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c44:	0f b6 c0             	movzbl %al,%eax
c0101c47:	83 e0 01             	and    $0x1,%eax
c0101c4a:	85 c0                	test   %eax,%eax
c0101c4c:	75 07                	jne    c0101c55 <serial_proc_data+0x2a>
        return -1;
c0101c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c53:	eb 2a                	jmp    c0101c7f <serial_proc_data+0x54>
c0101c55:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c5f:	89 c2                	mov    %eax,%edx
c0101c61:	ec                   	in     (%dx),%al
c0101c62:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101c65:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c69:	0f b6 c0             	movzbl %al,%eax
c0101c6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c6f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c73:	75 07                	jne    c0101c7c <serial_proc_data+0x51>
        c = '\b';
c0101c75:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c7f:	c9                   	leave  
c0101c80:	c3                   	ret    

c0101c81 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c81:	55                   	push   %ebp
c0101c82:	89 e5                	mov    %esp,%ebp
c0101c84:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c87:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101c8c:	85 c0                	test   %eax,%eax
c0101c8e:	74 0c                	je     c0101c9c <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101c90:	c7 04 24 2b 1c 10 c0 	movl   $0xc0101c2b,(%esp)
c0101c97:	e8 43 ff ff ff       	call   c0101bdf <cons_intr>
    }
}
c0101c9c:	90                   	nop
c0101c9d:	c9                   	leave  
c0101c9e:	c3                   	ret    

c0101c9f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101c9f:	55                   	push   %ebp
c0101ca0:	89 e5                	mov    %esp,%ebp
c0101ca2:	83 ec 28             	sub    $0x28,%esp
c0101ca5:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cae:	89 c2                	mov    %eax,%edx
c0101cb0:	ec                   	in     (%dx),%al
c0101cb1:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cb4:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cb8:	0f b6 c0             	movzbl %al,%eax
c0101cbb:	83 e0 01             	and    $0x1,%eax
c0101cbe:	85 c0                	test   %eax,%eax
c0101cc0:	75 0a                	jne    c0101ccc <kbd_proc_data+0x2d>
        return -1;
c0101cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cc7:	e9 56 01 00 00       	jmp    c0101e22 <kbd_proc_data+0x183>
c0101ccc:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cd5:	89 c2                	mov    %eax,%edx
c0101cd7:	ec                   	in     (%dx),%al
c0101cd8:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101cdb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101cdf:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101ce2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101ce6:	75 17                	jne    c0101cff <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101ce8:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101ced:	83 c8 40             	or     $0x40,%eax
c0101cf0:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101cf5:	b8 00 00 00 00       	mov    $0x0,%eax
c0101cfa:	e9 23 01 00 00       	jmp    c0101e22 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101cff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d03:	84 c0                	test   %al,%al
c0101d05:	79 45                	jns    c0101d4c <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d07:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d0c:	83 e0 40             	and    $0x40,%eax
c0101d0f:	85 c0                	test   %eax,%eax
c0101d11:	75 08                	jne    c0101d1b <kbd_proc_data+0x7c>
c0101d13:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d17:	24 7f                	and    $0x7f,%al
c0101d19:	eb 04                	jmp    c0101d1f <kbd_proc_data+0x80>
c0101d1b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d1f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d22:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d26:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101d2d:	0c 40                	or     $0x40,%al
c0101d2f:	0f b6 c0             	movzbl %al,%eax
c0101d32:	f7 d0                	not    %eax
c0101d34:	89 c2                	mov    %eax,%edx
c0101d36:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d3b:	21 d0                	and    %edx,%eax
c0101d3d:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101d42:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d47:	e9 d6 00 00 00       	jmp    c0101e22 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101d4c:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d51:	83 e0 40             	and    $0x40,%eax
c0101d54:	85 c0                	test   %eax,%eax
c0101d56:	74 11                	je     c0101d69 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d58:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d5c:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d61:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d64:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    }

    shift |= shiftcode[data];
c0101d69:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d6d:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101d74:	0f b6 d0             	movzbl %al,%edx
c0101d77:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d7c:	09 d0                	or     %edx,%eax
c0101d7e:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    shift ^= togglecode[data];
c0101d83:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d87:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c0101d8e:	0f b6 d0             	movzbl %al,%edx
c0101d91:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d96:	31 d0                	xor    %edx,%eax
c0101d98:	a3 48 37 12 c0       	mov    %eax,0xc0123748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101d9d:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101da2:	83 e0 03             	and    $0x3,%eax
c0101da5:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c0101dac:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101db0:	01 d0                	add    %edx,%eax
c0101db2:	0f b6 00             	movzbl (%eax),%eax
c0101db5:	0f b6 c0             	movzbl %al,%eax
c0101db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dbb:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101dc0:	83 e0 08             	and    $0x8,%eax
c0101dc3:	85 c0                	test   %eax,%eax
c0101dc5:	74 22                	je     c0101de9 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101dc7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101dcb:	7e 0c                	jle    c0101dd9 <kbd_proc_data+0x13a>
c0101dcd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dd1:	7f 06                	jg     c0101dd9 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101dd3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101dd7:	eb 10                	jmp    c0101de9 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101dd9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101ddd:	7e 0a                	jle    c0101de9 <kbd_proc_data+0x14a>
c0101ddf:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101de3:	7f 04                	jg     c0101de9 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101de5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101de9:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101dee:	f7 d0                	not    %eax
c0101df0:	83 e0 06             	and    $0x6,%eax
c0101df3:	85 c0                	test   %eax,%eax
c0101df5:	75 28                	jne    c0101e1f <kbd_proc_data+0x180>
c0101df7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101dfe:	75 1f                	jne    c0101e1f <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101e00:	c7 04 24 01 90 10 c0 	movl   $0xc0109001,(%esp)
c0101e07:	e8 95 e4 ff ff       	call   c01002a1 <cprintf>
c0101e0c:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101e12:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e16:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101e1e:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e22:	c9                   	leave  
c0101e23:	c3                   	ret    

c0101e24 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e24:	55                   	push   %ebp
c0101e25:	89 e5                	mov    %esp,%ebp
c0101e27:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e2a:	c7 04 24 9f 1c 10 c0 	movl   $0xc0101c9f,(%esp)
c0101e31:	e8 a9 fd ff ff       	call   c0101bdf <cons_intr>
}
c0101e36:	90                   	nop
c0101e37:	c9                   	leave  
c0101e38:	c3                   	ret    

c0101e39 <kbd_init>:

static void
kbd_init(void) {
c0101e39:	55                   	push   %ebp
c0101e3a:	89 e5                	mov    %esp,%ebp
c0101e3c:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e3f:	e8 e0 ff ff ff       	call   c0101e24 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e4b:	e8 34 01 00 00       	call   c0101f84 <pic_enable>
}
c0101e50:	90                   	nop
c0101e51:	c9                   	leave  
c0101e52:	c3                   	ret    

c0101e53 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e53:	55                   	push   %ebp
c0101e54:	89 e5                	mov    %esp,%ebp
c0101e56:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e59:	e8 90 f8 ff ff       	call   c01016ee <cga_init>
    serial_init();
c0101e5e:	e8 6d f9 ff ff       	call   c01017d0 <serial_init>
    kbd_init();
c0101e63:	e8 d1 ff ff ff       	call   c0101e39 <kbd_init>
    if (!serial_exists) {
c0101e68:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101e6d:	85 c0                	test   %eax,%eax
c0101e6f:	75 0c                	jne    c0101e7d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e71:	c7 04 24 0d 90 10 c0 	movl   $0xc010900d,(%esp)
c0101e78:	e8 24 e4 ff ff       	call   c01002a1 <cprintf>
    }
}
c0101e7d:	90                   	nop
c0101e7e:	c9                   	leave  
c0101e7f:	c3                   	ret    

c0101e80 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e80:	55                   	push   %ebp
c0101e81:	89 e5                	mov    %esp,%ebp
c0101e83:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e86:	e8 de f7 ff ff       	call   c0101669 <__intr_save>
c0101e8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e91:	89 04 24             	mov    %eax,(%esp)
c0101e94:	e8 8d fa ff ff       	call   c0101926 <lpt_putc>
        cga_putc(c);
c0101e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9c:	89 04 24             	mov    %eax,(%esp)
c0101e9f:	e8 c2 fa ff ff       	call   c0101966 <cga_putc>
        serial_putc(c);
c0101ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea7:	89 04 24             	mov    %eax,(%esp)
c0101eaa:	e8 f0 fc ff ff       	call   c0101b9f <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eb2:	89 04 24             	mov    %eax,(%esp)
c0101eb5:	e8 d9 f7 ff ff       	call   c0101693 <__intr_restore>
}
c0101eba:	90                   	nop
c0101ebb:	c9                   	leave  
c0101ebc:	c3                   	ret    

c0101ebd <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101ebd:	55                   	push   %ebp
c0101ebe:	89 e5                	mov    %esp,%ebp
c0101ec0:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101ec3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101eca:	e8 9a f7 ff ff       	call   c0101669 <__intr_save>
c0101ecf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ed2:	e8 aa fd ff ff       	call   c0101c81 <serial_intr>
        kbd_intr();
c0101ed7:	e8 48 ff ff ff       	call   c0101e24 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101edc:	8b 15 40 37 12 c0    	mov    0xc0123740,%edx
c0101ee2:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101ee7:	39 c2                	cmp    %eax,%edx
c0101ee9:	74 31                	je     c0101f1c <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101eeb:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101ef0:	8d 50 01             	lea    0x1(%eax),%edx
c0101ef3:	89 15 40 37 12 c0    	mov    %edx,0xc0123740
c0101ef9:	0f b6 80 40 35 12 c0 	movzbl -0x3fedcac0(%eax),%eax
c0101f00:	0f b6 c0             	movzbl %al,%eax
c0101f03:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f06:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101f0b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f10:	75 0a                	jne    c0101f1c <cons_getc+0x5f>
                cons.rpos = 0;
c0101f12:	c7 05 40 37 12 c0 00 	movl   $0x0,0xc0123740
c0101f19:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f1f:	89 04 24             	mov    %eax,(%esp)
c0101f22:	e8 6c f7 ff ff       	call   c0101693 <__intr_restore>
    return c;
c0101f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f2a:	c9                   	leave  
c0101f2b:	c3                   	ret    

c0101f2c <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f2c:	55                   	push   %ebp
c0101f2d:	89 e5                	mov    %esp,%ebp
c0101f2f:	83 ec 14             	sub    $0x14,%esp
c0101f32:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f35:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f3c:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101f42:	a1 4c 37 12 c0       	mov    0xc012374c,%eax
c0101f47:	85 c0                	test   %eax,%eax
c0101f49:	74 36                	je     c0101f81 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c0101f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f4e:	0f b6 c0             	movzbl %al,%eax
c0101f51:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f57:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101f5a:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101f5e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f62:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f63:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f67:	c1 e8 08             	shr    $0x8,%eax
c0101f6a:	0f b7 c0             	movzwl %ax,%eax
c0101f6d:	0f b6 c0             	movzbl %al,%eax
c0101f70:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101f76:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101f79:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101f7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101f80:	ee                   	out    %al,(%dx)
    }
}
c0101f81:	90                   	nop
c0101f82:	c9                   	leave  
c0101f83:	c3                   	ret    

c0101f84 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f84:	55                   	push   %ebp
c0101f85:	89 e5                	mov    %esp,%ebp
c0101f87:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f92:	88 c1                	mov    %al,%cl
c0101f94:	d3 e2                	shl    %cl,%edx
c0101f96:	89 d0                	mov    %edx,%eax
c0101f98:	98                   	cwtl   
c0101f99:	f7 d0                	not    %eax
c0101f9b:	0f bf d0             	movswl %ax,%edx
c0101f9e:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101fa5:	98                   	cwtl   
c0101fa6:	21 d0                	and    %edx,%eax
c0101fa8:	98                   	cwtl   
c0101fa9:	0f b7 c0             	movzwl %ax,%eax
c0101fac:	89 04 24             	mov    %eax,(%esp)
c0101faf:	e8 78 ff ff ff       	call   c0101f2c <pic_setmask>
}
c0101fb4:	90                   	nop
c0101fb5:	c9                   	leave  
c0101fb6:	c3                   	ret    

c0101fb7 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fb7:	55                   	push   %ebp
c0101fb8:	89 e5                	mov    %esp,%ebp
c0101fba:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101fbd:	c7 05 4c 37 12 c0 01 	movl   $0x1,0xc012374c
c0101fc4:	00 00 00 
c0101fc7:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101fcd:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101fd1:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101fd5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fd9:	ee                   	out    %al,(%dx)
c0101fda:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101fe0:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101fe4:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101fe8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101feb:	ee                   	out    %al,(%dx)
c0101fec:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101ff2:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101ff6:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101ffa:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101ffe:	ee                   	out    %al,(%dx)
c0101fff:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0102005:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0102009:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010200d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0102010:	ee                   	out    %al,(%dx)
c0102011:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0102017:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c010201b:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010201f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102023:	ee                   	out    %al,(%dx)
c0102024:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c010202a:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c010202e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102032:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102035:	ee                   	out    %al,(%dx)
c0102036:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c010203c:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0102040:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102044:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102048:	ee                   	out    %al,(%dx)
c0102049:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c010204f:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0102053:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102057:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010205a:	ee                   	out    %al,(%dx)
c010205b:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102061:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0102065:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0102069:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010206d:	ee                   	out    %al,(%dx)
c010206e:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0102074:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0102078:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010207c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010207f:	ee                   	out    %al,(%dx)
c0102080:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0102086:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c010208a:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c010208e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102092:	ee                   	out    %al,(%dx)
c0102093:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0102099:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c010209d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01020a4:	ee                   	out    %al,(%dx)
c01020a5:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01020ab:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01020af:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01020b3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020b7:	ee                   	out    %al,(%dx)
c01020b8:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01020be:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01020c2:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01020c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01020c9:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020ca:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c01020d1:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01020d6:	74 0f                	je     c01020e7 <pic_init+0x130>
        pic_setmask(irq_mask);
c01020d8:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c01020df:	89 04 24             	mov    %eax,(%esp)
c01020e2:	e8 45 fe ff ff       	call   c0101f2c <pic_setmask>
    }
}
c01020e7:	90                   	nop
c01020e8:	c9                   	leave  
c01020e9:	c3                   	ret    

c01020ea <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020ea:	55                   	push   %ebp
c01020eb:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01020ed:	fb                   	sti    
    sti();
}
c01020ee:	90                   	nop
c01020ef:	5d                   	pop    %ebp
c01020f0:	c3                   	ret    

c01020f1 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020f1:	55                   	push   %ebp
c01020f2:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01020f4:	fa                   	cli    
    cli();
}
c01020f5:	90                   	nop
c01020f6:	5d                   	pop    %ebp
c01020f7:	c3                   	ret    

c01020f8 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01020f8:	55                   	push   %ebp
c01020f9:	89 e5                	mov    %esp,%ebp
c01020fb:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01020fe:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102105:	00 
c0102106:	c7 04 24 40 90 10 c0 	movl   $0xc0109040,(%esp)
c010210d:	e8 8f e1 ff ff       	call   c01002a1 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102112:	90                   	nop
c0102113:	c9                   	leave  
c0102114:	c3                   	ret    

c0102115 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102115:	55                   	push   %ebp
c0102116:	89 e5                	mov    %esp,%ebp
c0102118:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
c010211b:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
      for(int i=0;i<length;i++)
c0102122:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102129:	e9 c4 00 00 00       	jmp    c01021f2 <idt_init+0xdd>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010212e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102131:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102138:	0f b7 d0             	movzwl %ax,%edx
c010213b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010213e:	66 89 14 c5 60 37 12 	mov    %dx,-0x3fedc8a0(,%eax,8)
c0102145:	c0 
c0102146:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102149:	66 c7 04 c5 62 37 12 	movw   $0x8,-0x3fedc89e(,%eax,8)
c0102150:	c0 08 00 
c0102153:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102156:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c010215d:	c0 
c010215e:	80 e2 e0             	and    $0xe0,%dl
c0102161:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c0102168:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010216b:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c0102172:	c0 
c0102173:	80 e2 1f             	and    $0x1f,%dl
c0102176:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c010217d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102180:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c0102187:	c0 
c0102188:	80 e2 f0             	and    $0xf0,%dl
c010218b:	80 ca 0e             	or     $0xe,%dl
c010218e:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c0102195:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102198:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c010219f:	c0 
c01021a0:	80 e2 ef             	and    $0xef,%dl
c01021a3:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ad:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01021b4:	c0 
c01021b5:	80 e2 9f             	and    $0x9f,%dl
c01021b8:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c2:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01021c9:	c0 
c01021ca:	80 ca 80             	or     $0x80,%dl
c01021cd:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021d7:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c01021de:	c1 e8 10             	shr    $0x10,%eax
c01021e1:	0f b7 d0             	movzwl %ax,%edx
c01021e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e7:	66 89 14 c5 66 37 12 	mov    %dx,-0x3fedc89a(,%eax,8)
c01021ee:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
      for(int i=0;i<length;i++)
c01021ef:	ff 45 fc             	incl   -0x4(%ebp)
c01021f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01021f8:	0f 8c 30 ff ff ff    	jl     c010212e <idt_init+0x19>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
      SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01021fe:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c0102203:	0f b7 c0             	movzwl %ax,%eax
c0102206:	66 a3 28 3b 12 c0    	mov    %ax,0xc0123b28
c010220c:	66 c7 05 2a 3b 12 c0 	movw   $0x8,0xc0123b2a
c0102213:	08 00 
c0102215:	0f b6 05 2c 3b 12 c0 	movzbl 0xc0123b2c,%eax
c010221c:	24 e0                	and    $0xe0,%al
c010221e:	a2 2c 3b 12 c0       	mov    %al,0xc0123b2c
c0102223:	0f b6 05 2c 3b 12 c0 	movzbl 0xc0123b2c,%eax
c010222a:	24 1f                	and    $0x1f,%al
c010222c:	a2 2c 3b 12 c0       	mov    %al,0xc0123b2c
c0102231:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102238:	24 f0                	and    $0xf0,%al
c010223a:	0c 0e                	or     $0xe,%al
c010223c:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c0102241:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102248:	24 ef                	and    $0xef,%al
c010224a:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c010224f:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102256:	0c 60                	or     $0x60,%al
c0102258:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c010225d:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102264:	0c 80                	or     $0x80,%al
c0102266:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c010226b:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c0102270:	c1 e8 10             	shr    $0x10,%eax
c0102273:	0f b7 c0             	movzwl %ax,%eax
c0102276:	66 a3 2e 3b 12 c0    	mov    %ax,0xc0123b2e
c010227c:	c7 45 f4 60 05 12 c0 	movl   $0xc0120560,-0xc(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102283:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102286:	0f 01 18             	lidtl  (%eax)
      lidt(&idt_pd);
}
c0102289:	90                   	nop
c010228a:	c9                   	leave  
c010228b:	c3                   	ret    

c010228c <trapname>:

static const char *
trapname(int trapno) {
c010228c:	55                   	push   %ebp
c010228d:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010228f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102292:	83 f8 13             	cmp    $0x13,%eax
c0102295:	77 0c                	ja     c01022a3 <trapname+0x17>
        return excnames[trapno];
c0102297:	8b 45 08             	mov    0x8(%ebp),%eax
c010229a:	8b 04 85 20 94 10 c0 	mov    -0x3fef6be0(,%eax,4),%eax
c01022a1:	eb 18                	jmp    c01022bb <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022a3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022a7:	7e 0d                	jle    c01022b6 <trapname+0x2a>
c01022a9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022ad:	7f 07                	jg     c01022b6 <trapname+0x2a>
        return "Hardware Interrupt";
c01022af:	b8 4a 90 10 c0       	mov    $0xc010904a,%eax
c01022b4:	eb 05                	jmp    c01022bb <trapname+0x2f>
    }
    return "(unknown trap)";
c01022b6:	b8 5d 90 10 c0       	mov    $0xc010905d,%eax
}
c01022bb:	5d                   	pop    %ebp
c01022bc:	c3                   	ret    

c01022bd <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022bd:	55                   	push   %ebp
c01022be:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01022c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022c3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022c7:	83 f8 08             	cmp    $0x8,%eax
c01022ca:	0f 94 c0             	sete   %al
c01022cd:	0f b6 c0             	movzbl %al,%eax
}
c01022d0:	5d                   	pop    %ebp
c01022d1:	c3                   	ret    

c01022d2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022d2:	55                   	push   %ebp
c01022d3:	89 e5                	mov    %esp,%ebp
c01022d5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022df:	c7 04 24 9e 90 10 c0 	movl   $0xc010909e,(%esp)
c01022e6:	e8 b6 df ff ff       	call   c01002a1 <cprintf>
    print_regs(&tf->tf_regs);
c01022eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ee:	89 04 24             	mov    %eax,(%esp)
c01022f1:	e8 91 01 00 00       	call   c0102487 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01022f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f9:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01022fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102301:	c7 04 24 af 90 10 c0 	movl   $0xc01090af,(%esp)
c0102308:	e8 94 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010230d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102310:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102318:	c7 04 24 c2 90 10 c0 	movl   $0xc01090c2,(%esp)
c010231f:	e8 7d df ff ff       	call   c01002a1 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102324:	8b 45 08             	mov    0x8(%ebp),%eax
c0102327:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010232b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010232f:	c7 04 24 d5 90 10 c0 	movl   $0xc01090d5,(%esp)
c0102336:	e8 66 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010233b:	8b 45 08             	mov    0x8(%ebp),%eax
c010233e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102346:	c7 04 24 e8 90 10 c0 	movl   $0xc01090e8,(%esp)
c010234d:	e8 4f df ff ff       	call   c01002a1 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102352:	8b 45 08             	mov    0x8(%ebp),%eax
c0102355:	8b 40 30             	mov    0x30(%eax),%eax
c0102358:	89 04 24             	mov    %eax,(%esp)
c010235b:	e8 2c ff ff ff       	call   c010228c <trapname>
c0102360:	89 c2                	mov    %eax,%edx
c0102362:	8b 45 08             	mov    0x8(%ebp),%eax
c0102365:	8b 40 30             	mov    0x30(%eax),%eax
c0102368:	89 54 24 08          	mov    %edx,0x8(%esp)
c010236c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102370:	c7 04 24 fb 90 10 c0 	movl   $0xc01090fb,(%esp)
c0102377:	e8 25 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010237c:	8b 45 08             	mov    0x8(%ebp),%eax
c010237f:	8b 40 34             	mov    0x34(%eax),%eax
c0102382:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102386:	c7 04 24 0d 91 10 c0 	movl   $0xc010910d,(%esp)
c010238d:	e8 0f df ff ff       	call   c01002a1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102392:	8b 45 08             	mov    0x8(%ebp),%eax
c0102395:	8b 40 38             	mov    0x38(%eax),%eax
c0102398:	89 44 24 04          	mov    %eax,0x4(%esp)
c010239c:	c7 04 24 1c 91 10 c0 	movl   $0xc010911c,(%esp)
c01023a3:	e8 f9 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ab:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b3:	c7 04 24 2b 91 10 c0 	movl   $0xc010912b,(%esp)
c01023ba:	e8 e2 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01023bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c2:	8b 40 40             	mov    0x40(%eax),%eax
c01023c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c9:	c7 04 24 3e 91 10 c0 	movl   $0xc010913e,(%esp)
c01023d0:	e8 cc de ff ff       	call   c01002a1 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023dc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01023e3:	eb 3d                	jmp    c0102422 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01023e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e8:	8b 50 40             	mov    0x40(%eax),%edx
c01023eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023ee:	21 d0                	and    %edx,%eax
c01023f0:	85 c0                	test   %eax,%eax
c01023f2:	74 28                	je     c010241c <print_trapframe+0x14a>
c01023f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023f7:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c01023fe:	85 c0                	test   %eax,%eax
c0102400:	74 1a                	je     c010241c <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0102402:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102405:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c010240c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102410:	c7 04 24 4d 91 10 c0 	movl   $0xc010914d,(%esp)
c0102417:	e8 85 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010241c:	ff 45 f4             	incl   -0xc(%ebp)
c010241f:	d1 65 f0             	shll   -0x10(%ebp)
c0102422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102425:	83 f8 17             	cmp    $0x17,%eax
c0102428:	76 bb                	jbe    c01023e5 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010242a:	8b 45 08             	mov    0x8(%ebp),%eax
c010242d:	8b 40 40             	mov    0x40(%eax),%eax
c0102430:	25 00 30 00 00       	and    $0x3000,%eax
c0102435:	c1 e8 0c             	shr    $0xc,%eax
c0102438:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243c:	c7 04 24 51 91 10 c0 	movl   $0xc0109151,(%esp)
c0102443:	e8 59 de ff ff       	call   c01002a1 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102448:	8b 45 08             	mov    0x8(%ebp),%eax
c010244b:	89 04 24             	mov    %eax,(%esp)
c010244e:	e8 6a fe ff ff       	call   c01022bd <trap_in_kernel>
c0102453:	85 c0                	test   %eax,%eax
c0102455:	75 2d                	jne    c0102484 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102457:	8b 45 08             	mov    0x8(%ebp),%eax
c010245a:	8b 40 44             	mov    0x44(%eax),%eax
c010245d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102461:	c7 04 24 5a 91 10 c0 	movl   $0xc010915a,(%esp)
c0102468:	e8 34 de ff ff       	call   c01002a1 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010246d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102470:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102474:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102478:	c7 04 24 69 91 10 c0 	movl   $0xc0109169,(%esp)
c010247f:	e8 1d de ff ff       	call   c01002a1 <cprintf>
    }
}
c0102484:	90                   	nop
c0102485:	c9                   	leave  
c0102486:	c3                   	ret    

c0102487 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102487:	55                   	push   %ebp
c0102488:	89 e5                	mov    %esp,%ebp
c010248a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010248d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102490:	8b 00                	mov    (%eax),%eax
c0102492:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102496:	c7 04 24 7c 91 10 c0 	movl   $0xc010917c,(%esp)
c010249d:	e8 ff dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a5:	8b 40 04             	mov    0x4(%eax),%eax
c01024a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ac:	c7 04 24 8b 91 10 c0 	movl   $0xc010918b,(%esp)
c01024b3:	e8 e9 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01024b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024bb:	8b 40 08             	mov    0x8(%eax),%eax
c01024be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c2:	c7 04 24 9a 91 10 c0 	movl   $0xc010919a,(%esp)
c01024c9:	e8 d3 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01024ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d1:	8b 40 0c             	mov    0xc(%eax),%eax
c01024d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d8:	c7 04 24 a9 91 10 c0 	movl   $0xc01091a9,(%esp)
c01024df:	e8 bd dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01024e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e7:	8b 40 10             	mov    0x10(%eax),%eax
c01024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ee:	c7 04 24 b8 91 10 c0 	movl   $0xc01091b8,(%esp)
c01024f5:	e8 a7 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01024fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fd:	8b 40 14             	mov    0x14(%eax),%eax
c0102500:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102504:	c7 04 24 c7 91 10 c0 	movl   $0xc01091c7,(%esp)
c010250b:	e8 91 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102510:	8b 45 08             	mov    0x8(%ebp),%eax
c0102513:	8b 40 18             	mov    0x18(%eax),%eax
c0102516:	89 44 24 04          	mov    %eax,0x4(%esp)
c010251a:	c7 04 24 d6 91 10 c0 	movl   $0xc01091d6,(%esp)
c0102521:	e8 7b dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102526:	8b 45 08             	mov    0x8(%ebp),%eax
c0102529:	8b 40 1c             	mov    0x1c(%eax),%eax
c010252c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102530:	c7 04 24 e5 91 10 c0 	movl   $0xc01091e5,(%esp)
c0102537:	e8 65 dd ff ff       	call   c01002a1 <cprintf>
}
c010253c:	90                   	nop
c010253d:	c9                   	leave  
c010253e:	c3                   	ret    

c010253f <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010253f:	55                   	push   %ebp
c0102540:	89 e5                	mov    %esp,%ebp
c0102542:	53                   	push   %ebx
c0102543:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102546:	8b 45 08             	mov    0x8(%ebp),%eax
c0102549:	8b 40 34             	mov    0x34(%eax),%eax
c010254c:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010254f:	85 c0                	test   %eax,%eax
c0102551:	74 07                	je     c010255a <print_pgfault+0x1b>
c0102553:	bb f4 91 10 c0       	mov    $0xc01091f4,%ebx
c0102558:	eb 05                	jmp    c010255f <print_pgfault+0x20>
c010255a:	bb 05 92 10 c0       	mov    $0xc0109205,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010255f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102562:	8b 40 34             	mov    0x34(%eax),%eax
c0102565:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102568:	85 c0                	test   %eax,%eax
c010256a:	74 07                	je     c0102573 <print_pgfault+0x34>
c010256c:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102571:	eb 05                	jmp    c0102578 <print_pgfault+0x39>
c0102573:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102578:	8b 45 08             	mov    0x8(%ebp),%eax
c010257b:	8b 40 34             	mov    0x34(%eax),%eax
c010257e:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102581:	85 c0                	test   %eax,%eax
c0102583:	74 07                	je     c010258c <print_pgfault+0x4d>
c0102585:	ba 55 00 00 00       	mov    $0x55,%edx
c010258a:	eb 05                	jmp    c0102591 <print_pgfault+0x52>
c010258c:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102591:	0f 20 d0             	mov    %cr2,%eax
c0102594:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010259a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010259e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01025a2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01025a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025aa:	c7 04 24 14 92 10 c0 	movl   $0xc0109214,(%esp)
c01025b1:	e8 eb dc ff ff       	call   c01002a1 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01025b6:	90                   	nop
c01025b7:	83 c4 34             	add    $0x34,%esp
c01025ba:	5b                   	pop    %ebx
c01025bb:	5d                   	pop    %ebp
c01025bc:	c3                   	ret    

c01025bd <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01025bd:	55                   	push   %ebp
c01025be:	89 e5                	mov    %esp,%ebp
c01025c0:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01025c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c6:	89 04 24             	mov    %eax,(%esp)
c01025c9:	e8 71 ff ff ff       	call   c010253f <print_pgfault>
    if (check_mm_struct != NULL) {
c01025ce:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01025d3:	85 c0                	test   %eax,%eax
c01025d5:	74 26                	je     c01025fd <pgfault_handler+0x40>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025d7:	0f 20 d0             	mov    %cr2,%eax
c01025da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01025dd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01025e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e3:	8b 50 34             	mov    0x34(%eax),%edx
c01025e6:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01025eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01025ef:	89 54 24 04          	mov    %edx,0x4(%esp)
c01025f3:	89 04 24             	mov    %eax,(%esp)
c01025f6:	e8 cf 17 00 00       	call   c0103dca <do_pgfault>
c01025fb:	eb 1c                	jmp    c0102619 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c01025fd:	c7 44 24 08 37 92 10 	movl   $0xc0109237,0x8(%esp)
c0102604:	c0 
c0102605:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c010260c:	00 
c010260d:	c7 04 24 4e 92 10 c0 	movl   $0xc010924e,(%esp)
c0102614:	e8 df dd ff ff       	call   c01003f8 <__panic>
}
c0102619:	c9                   	leave  
c010261a:	c3                   	ret    

c010261b <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010261b:	55                   	push   %ebp
c010261c:	89 e5                	mov    %esp,%ebp
c010261e:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102621:	8b 45 08             	mov    0x8(%ebp),%eax
c0102624:	8b 40 30             	mov    0x30(%eax),%eax
c0102627:	83 f8 24             	cmp    $0x24,%eax
c010262a:	0f 84 cc 00 00 00    	je     c01026fc <trap_dispatch+0xe1>
c0102630:	83 f8 24             	cmp    $0x24,%eax
c0102633:	77 18                	ja     c010264d <trap_dispatch+0x32>
c0102635:	83 f8 20             	cmp    $0x20,%eax
c0102638:	74 7c                	je     c01026b6 <trap_dispatch+0x9b>
c010263a:	83 f8 21             	cmp    $0x21,%eax
c010263d:	0f 84 df 00 00 00    	je     c0102722 <trap_dispatch+0x107>
c0102643:	83 f8 0e             	cmp    $0xe,%eax
c0102646:	74 28                	je     c0102670 <trap_dispatch+0x55>
c0102648:	e9 17 01 00 00       	jmp    c0102764 <trap_dispatch+0x149>
c010264d:	83 f8 2e             	cmp    $0x2e,%eax
c0102650:	0f 82 0e 01 00 00    	jb     c0102764 <trap_dispatch+0x149>
c0102656:	83 f8 2f             	cmp    $0x2f,%eax
c0102659:	0f 86 3a 01 00 00    	jbe    c0102799 <trap_dispatch+0x17e>
c010265f:	83 e8 78             	sub    $0x78,%eax
c0102662:	83 f8 01             	cmp    $0x1,%eax
c0102665:	0f 87 f9 00 00 00    	ja     c0102764 <trap_dispatch+0x149>
c010266b:	e9 d8 00 00 00       	jmp    c0102748 <trap_dispatch+0x12d>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102670:	8b 45 08             	mov    0x8(%ebp),%eax
c0102673:	89 04 24             	mov    %eax,(%esp)
c0102676:	e8 42 ff ff ff       	call   c01025bd <pgfault_handler>
c010267b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010267e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102682:	0f 84 14 01 00 00    	je     c010279c <trap_dispatch+0x181>
            print_trapframe(tf);
c0102688:	8b 45 08             	mov    0x8(%ebp),%eax
c010268b:	89 04 24             	mov    %eax,(%esp)
c010268e:	e8 3f fc ff ff       	call   c01022d2 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102693:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102696:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010269a:	c7 44 24 08 5f 92 10 	movl   $0xc010925f,0x8(%esp)
c01026a1:	c0 
c01026a2:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c01026a9:	00 
c01026aa:	c7 04 24 4e 92 10 c0 	movl   $0xc010924e,(%esp)
c01026b1:	e8 42 dd ff ff       	call   c01003f8 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c01026b6:	a1 0c 40 12 c0       	mov    0xc012400c,%eax
c01026bb:	40                   	inc    %eax
c01026bc:	a3 0c 40 12 c0       	mov    %eax,0xc012400c
        if(ticks % TICK_NUM==0)  print_ticks();
c01026c1:	8b 0d 0c 40 12 c0    	mov    0xc012400c,%ecx
c01026c7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01026cc:	89 c8                	mov    %ecx,%eax
c01026ce:	f7 e2                	mul    %edx
c01026d0:	c1 ea 05             	shr    $0x5,%edx
c01026d3:	89 d0                	mov    %edx,%eax
c01026d5:	c1 e0 02             	shl    $0x2,%eax
c01026d8:	01 d0                	add    %edx,%eax
c01026da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01026e1:	01 d0                	add    %edx,%eax
c01026e3:	c1 e0 02             	shl    $0x2,%eax
c01026e6:	29 c1                	sub    %eax,%ecx
c01026e8:	89 ca                	mov    %ecx,%edx
c01026ea:	85 d2                	test   %edx,%edx
c01026ec:	0f 85 ad 00 00 00    	jne    c010279f <trap_dispatch+0x184>
c01026f2:	e8 01 fa ff ff       	call   c01020f8 <print_ticks>
        break;
c01026f7:	e9 a3 00 00 00       	jmp    c010279f <trap_dispatch+0x184>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01026fc:	e8 bc f7 ff ff       	call   c0101ebd <cons_getc>
c0102701:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102704:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102708:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010270c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102710:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102714:	c7 04 24 7a 92 10 c0 	movl   $0xc010927a,(%esp)
c010271b:	e8 81 db ff ff       	call   c01002a1 <cprintf>
        break;
c0102720:	eb 7e                	jmp    c01027a0 <trap_dispatch+0x185>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102722:	e8 96 f7 ff ff       	call   c0101ebd <cons_getc>
c0102727:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010272a:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010272e:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102732:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102736:	89 44 24 04          	mov    %eax,0x4(%esp)
c010273a:	c7 04 24 8c 92 10 c0 	movl   $0xc010928c,(%esp)
c0102741:	e8 5b db ff ff       	call   c01002a1 <cprintf>
        break;
c0102746:	eb 58                	jmp    c01027a0 <trap_dispatch+0x185>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102748:	c7 44 24 08 9b 92 10 	movl   $0xc010929b,0x8(%esp)
c010274f:	c0 
c0102750:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102757:	00 
c0102758:	c7 04 24 4e 92 10 c0 	movl   $0xc010924e,(%esp)
c010275f:	e8 94 dc ff ff       	call   c01003f8 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102764:	8b 45 08             	mov    0x8(%ebp),%eax
c0102767:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010276b:	83 e0 03             	and    $0x3,%eax
c010276e:	85 c0                	test   %eax,%eax
c0102770:	75 2e                	jne    c01027a0 <trap_dispatch+0x185>
            print_trapframe(tf);
c0102772:	8b 45 08             	mov    0x8(%ebp),%eax
c0102775:	89 04 24             	mov    %eax,(%esp)
c0102778:	e8 55 fb ff ff       	call   c01022d2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010277d:	c7 44 24 08 ab 92 10 	movl   $0xc01092ab,0x8(%esp)
c0102784:	c0 
c0102785:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010278c:	00 
c010278d:	c7 04 24 4e 92 10 c0 	movl   $0xc010924e,(%esp)
c0102794:	e8 5f dc ff ff       	call   c01003f8 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102799:	90                   	nop
c010279a:	eb 04                	jmp    c01027a0 <trap_dispatch+0x185>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c010279c:	90                   	nop
c010279d:	eb 01                	jmp    c01027a0 <trap_dispatch+0x185>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
        if(ticks % TICK_NUM==0)  print_ticks();
        break;
c010279f:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c01027a0:	90                   	nop
c01027a1:	c9                   	leave  
c01027a2:	c3                   	ret    

c01027a3 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01027a3:	55                   	push   %ebp
c01027a4:	89 e5                	mov    %esp,%ebp
c01027a6:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01027a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ac:	89 04 24             	mov    %eax,(%esp)
c01027af:	e8 67 fe ff ff       	call   c010261b <trap_dispatch>
}
c01027b4:	90                   	nop
c01027b5:	c9                   	leave  
c01027b6:	c3                   	ret    

c01027b7 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01027b7:	6a 00                	push   $0x0
  pushl $0
c01027b9:	6a 00                	push   $0x0
  jmp __alltraps
c01027bb:	e9 69 0a 00 00       	jmp    c0103229 <__alltraps>

c01027c0 <vector1>:
.globl vector1
vector1:
  pushl $0
c01027c0:	6a 00                	push   $0x0
  pushl $1
c01027c2:	6a 01                	push   $0x1
  jmp __alltraps
c01027c4:	e9 60 0a 00 00       	jmp    c0103229 <__alltraps>

c01027c9 <vector2>:
.globl vector2
vector2:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $2
c01027cb:	6a 02                	push   $0x2
  jmp __alltraps
c01027cd:	e9 57 0a 00 00       	jmp    c0103229 <__alltraps>

c01027d2 <vector3>:
.globl vector3
vector3:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $3
c01027d4:	6a 03                	push   $0x3
  jmp __alltraps
c01027d6:	e9 4e 0a 00 00       	jmp    c0103229 <__alltraps>

c01027db <vector4>:
.globl vector4
vector4:
  pushl $0
c01027db:	6a 00                	push   $0x0
  pushl $4
c01027dd:	6a 04                	push   $0x4
  jmp __alltraps
c01027df:	e9 45 0a 00 00       	jmp    c0103229 <__alltraps>

c01027e4 <vector5>:
.globl vector5
vector5:
  pushl $0
c01027e4:	6a 00                	push   $0x0
  pushl $5
c01027e6:	6a 05                	push   $0x5
  jmp __alltraps
c01027e8:	e9 3c 0a 00 00       	jmp    c0103229 <__alltraps>

c01027ed <vector6>:
.globl vector6
vector6:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $6
c01027ef:	6a 06                	push   $0x6
  jmp __alltraps
c01027f1:	e9 33 0a 00 00       	jmp    c0103229 <__alltraps>

c01027f6 <vector7>:
.globl vector7
vector7:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $7
c01027f8:	6a 07                	push   $0x7
  jmp __alltraps
c01027fa:	e9 2a 0a 00 00       	jmp    c0103229 <__alltraps>

c01027ff <vector8>:
.globl vector8
vector8:
  pushl $8
c01027ff:	6a 08                	push   $0x8
  jmp __alltraps
c0102801:	e9 23 0a 00 00       	jmp    c0103229 <__alltraps>

c0102806 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102806:	6a 00                	push   $0x0
  pushl $9
c0102808:	6a 09                	push   $0x9
  jmp __alltraps
c010280a:	e9 1a 0a 00 00       	jmp    c0103229 <__alltraps>

c010280f <vector10>:
.globl vector10
vector10:
  pushl $10
c010280f:	6a 0a                	push   $0xa
  jmp __alltraps
c0102811:	e9 13 0a 00 00       	jmp    c0103229 <__alltraps>

c0102816 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102816:	6a 0b                	push   $0xb
  jmp __alltraps
c0102818:	e9 0c 0a 00 00       	jmp    c0103229 <__alltraps>

c010281d <vector12>:
.globl vector12
vector12:
  pushl $12
c010281d:	6a 0c                	push   $0xc
  jmp __alltraps
c010281f:	e9 05 0a 00 00       	jmp    c0103229 <__alltraps>

c0102824 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102824:	6a 0d                	push   $0xd
  jmp __alltraps
c0102826:	e9 fe 09 00 00       	jmp    c0103229 <__alltraps>

c010282b <vector14>:
.globl vector14
vector14:
  pushl $14
c010282b:	6a 0e                	push   $0xe
  jmp __alltraps
c010282d:	e9 f7 09 00 00       	jmp    c0103229 <__alltraps>

c0102832 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102832:	6a 00                	push   $0x0
  pushl $15
c0102834:	6a 0f                	push   $0xf
  jmp __alltraps
c0102836:	e9 ee 09 00 00       	jmp    c0103229 <__alltraps>

c010283b <vector16>:
.globl vector16
vector16:
  pushl $0
c010283b:	6a 00                	push   $0x0
  pushl $16
c010283d:	6a 10                	push   $0x10
  jmp __alltraps
c010283f:	e9 e5 09 00 00       	jmp    c0103229 <__alltraps>

c0102844 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102844:	6a 11                	push   $0x11
  jmp __alltraps
c0102846:	e9 de 09 00 00       	jmp    c0103229 <__alltraps>

c010284b <vector18>:
.globl vector18
vector18:
  pushl $0
c010284b:	6a 00                	push   $0x0
  pushl $18
c010284d:	6a 12                	push   $0x12
  jmp __alltraps
c010284f:	e9 d5 09 00 00       	jmp    c0103229 <__alltraps>

c0102854 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102854:	6a 00                	push   $0x0
  pushl $19
c0102856:	6a 13                	push   $0x13
  jmp __alltraps
c0102858:	e9 cc 09 00 00       	jmp    c0103229 <__alltraps>

c010285d <vector20>:
.globl vector20
vector20:
  pushl $0
c010285d:	6a 00                	push   $0x0
  pushl $20
c010285f:	6a 14                	push   $0x14
  jmp __alltraps
c0102861:	e9 c3 09 00 00       	jmp    c0103229 <__alltraps>

c0102866 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102866:	6a 00                	push   $0x0
  pushl $21
c0102868:	6a 15                	push   $0x15
  jmp __alltraps
c010286a:	e9 ba 09 00 00       	jmp    c0103229 <__alltraps>

c010286f <vector22>:
.globl vector22
vector22:
  pushl $0
c010286f:	6a 00                	push   $0x0
  pushl $22
c0102871:	6a 16                	push   $0x16
  jmp __alltraps
c0102873:	e9 b1 09 00 00       	jmp    c0103229 <__alltraps>

c0102878 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102878:	6a 00                	push   $0x0
  pushl $23
c010287a:	6a 17                	push   $0x17
  jmp __alltraps
c010287c:	e9 a8 09 00 00       	jmp    c0103229 <__alltraps>

c0102881 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102881:	6a 00                	push   $0x0
  pushl $24
c0102883:	6a 18                	push   $0x18
  jmp __alltraps
c0102885:	e9 9f 09 00 00       	jmp    c0103229 <__alltraps>

c010288a <vector25>:
.globl vector25
vector25:
  pushl $0
c010288a:	6a 00                	push   $0x0
  pushl $25
c010288c:	6a 19                	push   $0x19
  jmp __alltraps
c010288e:	e9 96 09 00 00       	jmp    c0103229 <__alltraps>

c0102893 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102893:	6a 00                	push   $0x0
  pushl $26
c0102895:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102897:	e9 8d 09 00 00       	jmp    c0103229 <__alltraps>

c010289c <vector27>:
.globl vector27
vector27:
  pushl $0
c010289c:	6a 00                	push   $0x0
  pushl $27
c010289e:	6a 1b                	push   $0x1b
  jmp __alltraps
c01028a0:	e9 84 09 00 00       	jmp    c0103229 <__alltraps>

c01028a5 <vector28>:
.globl vector28
vector28:
  pushl $0
c01028a5:	6a 00                	push   $0x0
  pushl $28
c01028a7:	6a 1c                	push   $0x1c
  jmp __alltraps
c01028a9:	e9 7b 09 00 00       	jmp    c0103229 <__alltraps>

c01028ae <vector29>:
.globl vector29
vector29:
  pushl $0
c01028ae:	6a 00                	push   $0x0
  pushl $29
c01028b0:	6a 1d                	push   $0x1d
  jmp __alltraps
c01028b2:	e9 72 09 00 00       	jmp    c0103229 <__alltraps>

c01028b7 <vector30>:
.globl vector30
vector30:
  pushl $0
c01028b7:	6a 00                	push   $0x0
  pushl $30
c01028b9:	6a 1e                	push   $0x1e
  jmp __alltraps
c01028bb:	e9 69 09 00 00       	jmp    c0103229 <__alltraps>

c01028c0 <vector31>:
.globl vector31
vector31:
  pushl $0
c01028c0:	6a 00                	push   $0x0
  pushl $31
c01028c2:	6a 1f                	push   $0x1f
  jmp __alltraps
c01028c4:	e9 60 09 00 00       	jmp    c0103229 <__alltraps>

c01028c9 <vector32>:
.globl vector32
vector32:
  pushl $0
c01028c9:	6a 00                	push   $0x0
  pushl $32
c01028cb:	6a 20                	push   $0x20
  jmp __alltraps
c01028cd:	e9 57 09 00 00       	jmp    c0103229 <__alltraps>

c01028d2 <vector33>:
.globl vector33
vector33:
  pushl $0
c01028d2:	6a 00                	push   $0x0
  pushl $33
c01028d4:	6a 21                	push   $0x21
  jmp __alltraps
c01028d6:	e9 4e 09 00 00       	jmp    c0103229 <__alltraps>

c01028db <vector34>:
.globl vector34
vector34:
  pushl $0
c01028db:	6a 00                	push   $0x0
  pushl $34
c01028dd:	6a 22                	push   $0x22
  jmp __alltraps
c01028df:	e9 45 09 00 00       	jmp    c0103229 <__alltraps>

c01028e4 <vector35>:
.globl vector35
vector35:
  pushl $0
c01028e4:	6a 00                	push   $0x0
  pushl $35
c01028e6:	6a 23                	push   $0x23
  jmp __alltraps
c01028e8:	e9 3c 09 00 00       	jmp    c0103229 <__alltraps>

c01028ed <vector36>:
.globl vector36
vector36:
  pushl $0
c01028ed:	6a 00                	push   $0x0
  pushl $36
c01028ef:	6a 24                	push   $0x24
  jmp __alltraps
c01028f1:	e9 33 09 00 00       	jmp    c0103229 <__alltraps>

c01028f6 <vector37>:
.globl vector37
vector37:
  pushl $0
c01028f6:	6a 00                	push   $0x0
  pushl $37
c01028f8:	6a 25                	push   $0x25
  jmp __alltraps
c01028fa:	e9 2a 09 00 00       	jmp    c0103229 <__alltraps>

c01028ff <vector38>:
.globl vector38
vector38:
  pushl $0
c01028ff:	6a 00                	push   $0x0
  pushl $38
c0102901:	6a 26                	push   $0x26
  jmp __alltraps
c0102903:	e9 21 09 00 00       	jmp    c0103229 <__alltraps>

c0102908 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102908:	6a 00                	push   $0x0
  pushl $39
c010290a:	6a 27                	push   $0x27
  jmp __alltraps
c010290c:	e9 18 09 00 00       	jmp    c0103229 <__alltraps>

c0102911 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102911:	6a 00                	push   $0x0
  pushl $40
c0102913:	6a 28                	push   $0x28
  jmp __alltraps
c0102915:	e9 0f 09 00 00       	jmp    c0103229 <__alltraps>

c010291a <vector41>:
.globl vector41
vector41:
  pushl $0
c010291a:	6a 00                	push   $0x0
  pushl $41
c010291c:	6a 29                	push   $0x29
  jmp __alltraps
c010291e:	e9 06 09 00 00       	jmp    c0103229 <__alltraps>

c0102923 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102923:	6a 00                	push   $0x0
  pushl $42
c0102925:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102927:	e9 fd 08 00 00       	jmp    c0103229 <__alltraps>

c010292c <vector43>:
.globl vector43
vector43:
  pushl $0
c010292c:	6a 00                	push   $0x0
  pushl $43
c010292e:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102930:	e9 f4 08 00 00       	jmp    c0103229 <__alltraps>

c0102935 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102935:	6a 00                	push   $0x0
  pushl $44
c0102937:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102939:	e9 eb 08 00 00       	jmp    c0103229 <__alltraps>

c010293e <vector45>:
.globl vector45
vector45:
  pushl $0
c010293e:	6a 00                	push   $0x0
  pushl $45
c0102940:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102942:	e9 e2 08 00 00       	jmp    c0103229 <__alltraps>

c0102947 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102947:	6a 00                	push   $0x0
  pushl $46
c0102949:	6a 2e                	push   $0x2e
  jmp __alltraps
c010294b:	e9 d9 08 00 00       	jmp    c0103229 <__alltraps>

c0102950 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102950:	6a 00                	push   $0x0
  pushl $47
c0102952:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102954:	e9 d0 08 00 00       	jmp    c0103229 <__alltraps>

c0102959 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102959:	6a 00                	push   $0x0
  pushl $48
c010295b:	6a 30                	push   $0x30
  jmp __alltraps
c010295d:	e9 c7 08 00 00       	jmp    c0103229 <__alltraps>

c0102962 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102962:	6a 00                	push   $0x0
  pushl $49
c0102964:	6a 31                	push   $0x31
  jmp __alltraps
c0102966:	e9 be 08 00 00       	jmp    c0103229 <__alltraps>

c010296b <vector50>:
.globl vector50
vector50:
  pushl $0
c010296b:	6a 00                	push   $0x0
  pushl $50
c010296d:	6a 32                	push   $0x32
  jmp __alltraps
c010296f:	e9 b5 08 00 00       	jmp    c0103229 <__alltraps>

c0102974 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102974:	6a 00                	push   $0x0
  pushl $51
c0102976:	6a 33                	push   $0x33
  jmp __alltraps
c0102978:	e9 ac 08 00 00       	jmp    c0103229 <__alltraps>

c010297d <vector52>:
.globl vector52
vector52:
  pushl $0
c010297d:	6a 00                	push   $0x0
  pushl $52
c010297f:	6a 34                	push   $0x34
  jmp __alltraps
c0102981:	e9 a3 08 00 00       	jmp    c0103229 <__alltraps>

c0102986 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102986:	6a 00                	push   $0x0
  pushl $53
c0102988:	6a 35                	push   $0x35
  jmp __alltraps
c010298a:	e9 9a 08 00 00       	jmp    c0103229 <__alltraps>

c010298f <vector54>:
.globl vector54
vector54:
  pushl $0
c010298f:	6a 00                	push   $0x0
  pushl $54
c0102991:	6a 36                	push   $0x36
  jmp __alltraps
c0102993:	e9 91 08 00 00       	jmp    c0103229 <__alltraps>

c0102998 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102998:	6a 00                	push   $0x0
  pushl $55
c010299a:	6a 37                	push   $0x37
  jmp __alltraps
c010299c:	e9 88 08 00 00       	jmp    c0103229 <__alltraps>

c01029a1 <vector56>:
.globl vector56
vector56:
  pushl $0
c01029a1:	6a 00                	push   $0x0
  pushl $56
c01029a3:	6a 38                	push   $0x38
  jmp __alltraps
c01029a5:	e9 7f 08 00 00       	jmp    c0103229 <__alltraps>

c01029aa <vector57>:
.globl vector57
vector57:
  pushl $0
c01029aa:	6a 00                	push   $0x0
  pushl $57
c01029ac:	6a 39                	push   $0x39
  jmp __alltraps
c01029ae:	e9 76 08 00 00       	jmp    c0103229 <__alltraps>

c01029b3 <vector58>:
.globl vector58
vector58:
  pushl $0
c01029b3:	6a 00                	push   $0x0
  pushl $58
c01029b5:	6a 3a                	push   $0x3a
  jmp __alltraps
c01029b7:	e9 6d 08 00 00       	jmp    c0103229 <__alltraps>

c01029bc <vector59>:
.globl vector59
vector59:
  pushl $0
c01029bc:	6a 00                	push   $0x0
  pushl $59
c01029be:	6a 3b                	push   $0x3b
  jmp __alltraps
c01029c0:	e9 64 08 00 00       	jmp    c0103229 <__alltraps>

c01029c5 <vector60>:
.globl vector60
vector60:
  pushl $0
c01029c5:	6a 00                	push   $0x0
  pushl $60
c01029c7:	6a 3c                	push   $0x3c
  jmp __alltraps
c01029c9:	e9 5b 08 00 00       	jmp    c0103229 <__alltraps>

c01029ce <vector61>:
.globl vector61
vector61:
  pushl $0
c01029ce:	6a 00                	push   $0x0
  pushl $61
c01029d0:	6a 3d                	push   $0x3d
  jmp __alltraps
c01029d2:	e9 52 08 00 00       	jmp    c0103229 <__alltraps>

c01029d7 <vector62>:
.globl vector62
vector62:
  pushl $0
c01029d7:	6a 00                	push   $0x0
  pushl $62
c01029d9:	6a 3e                	push   $0x3e
  jmp __alltraps
c01029db:	e9 49 08 00 00       	jmp    c0103229 <__alltraps>

c01029e0 <vector63>:
.globl vector63
vector63:
  pushl $0
c01029e0:	6a 00                	push   $0x0
  pushl $63
c01029e2:	6a 3f                	push   $0x3f
  jmp __alltraps
c01029e4:	e9 40 08 00 00       	jmp    c0103229 <__alltraps>

c01029e9 <vector64>:
.globl vector64
vector64:
  pushl $0
c01029e9:	6a 00                	push   $0x0
  pushl $64
c01029eb:	6a 40                	push   $0x40
  jmp __alltraps
c01029ed:	e9 37 08 00 00       	jmp    c0103229 <__alltraps>

c01029f2 <vector65>:
.globl vector65
vector65:
  pushl $0
c01029f2:	6a 00                	push   $0x0
  pushl $65
c01029f4:	6a 41                	push   $0x41
  jmp __alltraps
c01029f6:	e9 2e 08 00 00       	jmp    c0103229 <__alltraps>

c01029fb <vector66>:
.globl vector66
vector66:
  pushl $0
c01029fb:	6a 00                	push   $0x0
  pushl $66
c01029fd:	6a 42                	push   $0x42
  jmp __alltraps
c01029ff:	e9 25 08 00 00       	jmp    c0103229 <__alltraps>

c0102a04 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102a04:	6a 00                	push   $0x0
  pushl $67
c0102a06:	6a 43                	push   $0x43
  jmp __alltraps
c0102a08:	e9 1c 08 00 00       	jmp    c0103229 <__alltraps>

c0102a0d <vector68>:
.globl vector68
vector68:
  pushl $0
c0102a0d:	6a 00                	push   $0x0
  pushl $68
c0102a0f:	6a 44                	push   $0x44
  jmp __alltraps
c0102a11:	e9 13 08 00 00       	jmp    c0103229 <__alltraps>

c0102a16 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102a16:	6a 00                	push   $0x0
  pushl $69
c0102a18:	6a 45                	push   $0x45
  jmp __alltraps
c0102a1a:	e9 0a 08 00 00       	jmp    c0103229 <__alltraps>

c0102a1f <vector70>:
.globl vector70
vector70:
  pushl $0
c0102a1f:	6a 00                	push   $0x0
  pushl $70
c0102a21:	6a 46                	push   $0x46
  jmp __alltraps
c0102a23:	e9 01 08 00 00       	jmp    c0103229 <__alltraps>

c0102a28 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102a28:	6a 00                	push   $0x0
  pushl $71
c0102a2a:	6a 47                	push   $0x47
  jmp __alltraps
c0102a2c:	e9 f8 07 00 00       	jmp    c0103229 <__alltraps>

c0102a31 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102a31:	6a 00                	push   $0x0
  pushl $72
c0102a33:	6a 48                	push   $0x48
  jmp __alltraps
c0102a35:	e9 ef 07 00 00       	jmp    c0103229 <__alltraps>

c0102a3a <vector73>:
.globl vector73
vector73:
  pushl $0
c0102a3a:	6a 00                	push   $0x0
  pushl $73
c0102a3c:	6a 49                	push   $0x49
  jmp __alltraps
c0102a3e:	e9 e6 07 00 00       	jmp    c0103229 <__alltraps>

c0102a43 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102a43:	6a 00                	push   $0x0
  pushl $74
c0102a45:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102a47:	e9 dd 07 00 00       	jmp    c0103229 <__alltraps>

c0102a4c <vector75>:
.globl vector75
vector75:
  pushl $0
c0102a4c:	6a 00                	push   $0x0
  pushl $75
c0102a4e:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102a50:	e9 d4 07 00 00       	jmp    c0103229 <__alltraps>

c0102a55 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102a55:	6a 00                	push   $0x0
  pushl $76
c0102a57:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102a59:	e9 cb 07 00 00       	jmp    c0103229 <__alltraps>

c0102a5e <vector77>:
.globl vector77
vector77:
  pushl $0
c0102a5e:	6a 00                	push   $0x0
  pushl $77
c0102a60:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102a62:	e9 c2 07 00 00       	jmp    c0103229 <__alltraps>

c0102a67 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102a67:	6a 00                	push   $0x0
  pushl $78
c0102a69:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102a6b:	e9 b9 07 00 00       	jmp    c0103229 <__alltraps>

c0102a70 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102a70:	6a 00                	push   $0x0
  pushl $79
c0102a72:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102a74:	e9 b0 07 00 00       	jmp    c0103229 <__alltraps>

c0102a79 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102a79:	6a 00                	push   $0x0
  pushl $80
c0102a7b:	6a 50                	push   $0x50
  jmp __alltraps
c0102a7d:	e9 a7 07 00 00       	jmp    c0103229 <__alltraps>

c0102a82 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102a82:	6a 00                	push   $0x0
  pushl $81
c0102a84:	6a 51                	push   $0x51
  jmp __alltraps
c0102a86:	e9 9e 07 00 00       	jmp    c0103229 <__alltraps>

c0102a8b <vector82>:
.globl vector82
vector82:
  pushl $0
c0102a8b:	6a 00                	push   $0x0
  pushl $82
c0102a8d:	6a 52                	push   $0x52
  jmp __alltraps
c0102a8f:	e9 95 07 00 00       	jmp    c0103229 <__alltraps>

c0102a94 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102a94:	6a 00                	push   $0x0
  pushl $83
c0102a96:	6a 53                	push   $0x53
  jmp __alltraps
c0102a98:	e9 8c 07 00 00       	jmp    c0103229 <__alltraps>

c0102a9d <vector84>:
.globl vector84
vector84:
  pushl $0
c0102a9d:	6a 00                	push   $0x0
  pushl $84
c0102a9f:	6a 54                	push   $0x54
  jmp __alltraps
c0102aa1:	e9 83 07 00 00       	jmp    c0103229 <__alltraps>

c0102aa6 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102aa6:	6a 00                	push   $0x0
  pushl $85
c0102aa8:	6a 55                	push   $0x55
  jmp __alltraps
c0102aaa:	e9 7a 07 00 00       	jmp    c0103229 <__alltraps>

c0102aaf <vector86>:
.globl vector86
vector86:
  pushl $0
c0102aaf:	6a 00                	push   $0x0
  pushl $86
c0102ab1:	6a 56                	push   $0x56
  jmp __alltraps
c0102ab3:	e9 71 07 00 00       	jmp    c0103229 <__alltraps>

c0102ab8 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ab8:	6a 00                	push   $0x0
  pushl $87
c0102aba:	6a 57                	push   $0x57
  jmp __alltraps
c0102abc:	e9 68 07 00 00       	jmp    c0103229 <__alltraps>

c0102ac1 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102ac1:	6a 00                	push   $0x0
  pushl $88
c0102ac3:	6a 58                	push   $0x58
  jmp __alltraps
c0102ac5:	e9 5f 07 00 00       	jmp    c0103229 <__alltraps>

c0102aca <vector89>:
.globl vector89
vector89:
  pushl $0
c0102aca:	6a 00                	push   $0x0
  pushl $89
c0102acc:	6a 59                	push   $0x59
  jmp __alltraps
c0102ace:	e9 56 07 00 00       	jmp    c0103229 <__alltraps>

c0102ad3 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102ad3:	6a 00                	push   $0x0
  pushl $90
c0102ad5:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102ad7:	e9 4d 07 00 00       	jmp    c0103229 <__alltraps>

c0102adc <vector91>:
.globl vector91
vector91:
  pushl $0
c0102adc:	6a 00                	push   $0x0
  pushl $91
c0102ade:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ae0:	e9 44 07 00 00       	jmp    c0103229 <__alltraps>

c0102ae5 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102ae5:	6a 00                	push   $0x0
  pushl $92
c0102ae7:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102ae9:	e9 3b 07 00 00       	jmp    c0103229 <__alltraps>

c0102aee <vector93>:
.globl vector93
vector93:
  pushl $0
c0102aee:	6a 00                	push   $0x0
  pushl $93
c0102af0:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102af2:	e9 32 07 00 00       	jmp    c0103229 <__alltraps>

c0102af7 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102af7:	6a 00                	push   $0x0
  pushl $94
c0102af9:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102afb:	e9 29 07 00 00       	jmp    c0103229 <__alltraps>

c0102b00 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102b00:	6a 00                	push   $0x0
  pushl $95
c0102b02:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102b04:	e9 20 07 00 00       	jmp    c0103229 <__alltraps>

c0102b09 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102b09:	6a 00                	push   $0x0
  pushl $96
c0102b0b:	6a 60                	push   $0x60
  jmp __alltraps
c0102b0d:	e9 17 07 00 00       	jmp    c0103229 <__alltraps>

c0102b12 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102b12:	6a 00                	push   $0x0
  pushl $97
c0102b14:	6a 61                	push   $0x61
  jmp __alltraps
c0102b16:	e9 0e 07 00 00       	jmp    c0103229 <__alltraps>

c0102b1b <vector98>:
.globl vector98
vector98:
  pushl $0
c0102b1b:	6a 00                	push   $0x0
  pushl $98
c0102b1d:	6a 62                	push   $0x62
  jmp __alltraps
c0102b1f:	e9 05 07 00 00       	jmp    c0103229 <__alltraps>

c0102b24 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102b24:	6a 00                	push   $0x0
  pushl $99
c0102b26:	6a 63                	push   $0x63
  jmp __alltraps
c0102b28:	e9 fc 06 00 00       	jmp    c0103229 <__alltraps>

c0102b2d <vector100>:
.globl vector100
vector100:
  pushl $0
c0102b2d:	6a 00                	push   $0x0
  pushl $100
c0102b2f:	6a 64                	push   $0x64
  jmp __alltraps
c0102b31:	e9 f3 06 00 00       	jmp    c0103229 <__alltraps>

c0102b36 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102b36:	6a 00                	push   $0x0
  pushl $101
c0102b38:	6a 65                	push   $0x65
  jmp __alltraps
c0102b3a:	e9 ea 06 00 00       	jmp    c0103229 <__alltraps>

c0102b3f <vector102>:
.globl vector102
vector102:
  pushl $0
c0102b3f:	6a 00                	push   $0x0
  pushl $102
c0102b41:	6a 66                	push   $0x66
  jmp __alltraps
c0102b43:	e9 e1 06 00 00       	jmp    c0103229 <__alltraps>

c0102b48 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102b48:	6a 00                	push   $0x0
  pushl $103
c0102b4a:	6a 67                	push   $0x67
  jmp __alltraps
c0102b4c:	e9 d8 06 00 00       	jmp    c0103229 <__alltraps>

c0102b51 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102b51:	6a 00                	push   $0x0
  pushl $104
c0102b53:	6a 68                	push   $0x68
  jmp __alltraps
c0102b55:	e9 cf 06 00 00       	jmp    c0103229 <__alltraps>

c0102b5a <vector105>:
.globl vector105
vector105:
  pushl $0
c0102b5a:	6a 00                	push   $0x0
  pushl $105
c0102b5c:	6a 69                	push   $0x69
  jmp __alltraps
c0102b5e:	e9 c6 06 00 00       	jmp    c0103229 <__alltraps>

c0102b63 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102b63:	6a 00                	push   $0x0
  pushl $106
c0102b65:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102b67:	e9 bd 06 00 00       	jmp    c0103229 <__alltraps>

c0102b6c <vector107>:
.globl vector107
vector107:
  pushl $0
c0102b6c:	6a 00                	push   $0x0
  pushl $107
c0102b6e:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102b70:	e9 b4 06 00 00       	jmp    c0103229 <__alltraps>

c0102b75 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102b75:	6a 00                	push   $0x0
  pushl $108
c0102b77:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102b79:	e9 ab 06 00 00       	jmp    c0103229 <__alltraps>

c0102b7e <vector109>:
.globl vector109
vector109:
  pushl $0
c0102b7e:	6a 00                	push   $0x0
  pushl $109
c0102b80:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102b82:	e9 a2 06 00 00       	jmp    c0103229 <__alltraps>

c0102b87 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102b87:	6a 00                	push   $0x0
  pushl $110
c0102b89:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102b8b:	e9 99 06 00 00       	jmp    c0103229 <__alltraps>

c0102b90 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102b90:	6a 00                	push   $0x0
  pushl $111
c0102b92:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102b94:	e9 90 06 00 00       	jmp    c0103229 <__alltraps>

c0102b99 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102b99:	6a 00                	push   $0x0
  pushl $112
c0102b9b:	6a 70                	push   $0x70
  jmp __alltraps
c0102b9d:	e9 87 06 00 00       	jmp    c0103229 <__alltraps>

c0102ba2 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $113
c0102ba4:	6a 71                	push   $0x71
  jmp __alltraps
c0102ba6:	e9 7e 06 00 00       	jmp    c0103229 <__alltraps>

c0102bab <vector114>:
.globl vector114
vector114:
  pushl $0
c0102bab:	6a 00                	push   $0x0
  pushl $114
c0102bad:	6a 72                	push   $0x72
  jmp __alltraps
c0102baf:	e9 75 06 00 00       	jmp    c0103229 <__alltraps>

c0102bb4 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102bb4:	6a 00                	push   $0x0
  pushl $115
c0102bb6:	6a 73                	push   $0x73
  jmp __alltraps
c0102bb8:	e9 6c 06 00 00       	jmp    c0103229 <__alltraps>

c0102bbd <vector116>:
.globl vector116
vector116:
  pushl $0
c0102bbd:	6a 00                	push   $0x0
  pushl $116
c0102bbf:	6a 74                	push   $0x74
  jmp __alltraps
c0102bc1:	e9 63 06 00 00       	jmp    c0103229 <__alltraps>

c0102bc6 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102bc6:	6a 00                	push   $0x0
  pushl $117
c0102bc8:	6a 75                	push   $0x75
  jmp __alltraps
c0102bca:	e9 5a 06 00 00       	jmp    c0103229 <__alltraps>

c0102bcf <vector118>:
.globl vector118
vector118:
  pushl $0
c0102bcf:	6a 00                	push   $0x0
  pushl $118
c0102bd1:	6a 76                	push   $0x76
  jmp __alltraps
c0102bd3:	e9 51 06 00 00       	jmp    c0103229 <__alltraps>

c0102bd8 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102bd8:	6a 00                	push   $0x0
  pushl $119
c0102bda:	6a 77                	push   $0x77
  jmp __alltraps
c0102bdc:	e9 48 06 00 00       	jmp    c0103229 <__alltraps>

c0102be1 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102be1:	6a 00                	push   $0x0
  pushl $120
c0102be3:	6a 78                	push   $0x78
  jmp __alltraps
c0102be5:	e9 3f 06 00 00       	jmp    c0103229 <__alltraps>

c0102bea <vector121>:
.globl vector121
vector121:
  pushl $0
c0102bea:	6a 00                	push   $0x0
  pushl $121
c0102bec:	6a 79                	push   $0x79
  jmp __alltraps
c0102bee:	e9 36 06 00 00       	jmp    c0103229 <__alltraps>

c0102bf3 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102bf3:	6a 00                	push   $0x0
  pushl $122
c0102bf5:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102bf7:	e9 2d 06 00 00       	jmp    c0103229 <__alltraps>

c0102bfc <vector123>:
.globl vector123
vector123:
  pushl $0
c0102bfc:	6a 00                	push   $0x0
  pushl $123
c0102bfe:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102c00:	e9 24 06 00 00       	jmp    c0103229 <__alltraps>

c0102c05 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102c05:	6a 00                	push   $0x0
  pushl $124
c0102c07:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102c09:	e9 1b 06 00 00       	jmp    c0103229 <__alltraps>

c0102c0e <vector125>:
.globl vector125
vector125:
  pushl $0
c0102c0e:	6a 00                	push   $0x0
  pushl $125
c0102c10:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102c12:	e9 12 06 00 00       	jmp    c0103229 <__alltraps>

c0102c17 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102c17:	6a 00                	push   $0x0
  pushl $126
c0102c19:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102c1b:	e9 09 06 00 00       	jmp    c0103229 <__alltraps>

c0102c20 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102c20:	6a 00                	push   $0x0
  pushl $127
c0102c22:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102c24:	e9 00 06 00 00       	jmp    c0103229 <__alltraps>

c0102c29 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102c29:	6a 00                	push   $0x0
  pushl $128
c0102c2b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102c30:	e9 f4 05 00 00       	jmp    c0103229 <__alltraps>

c0102c35 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $129
c0102c37:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102c3c:	e9 e8 05 00 00       	jmp    c0103229 <__alltraps>

c0102c41 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102c41:	6a 00                	push   $0x0
  pushl $130
c0102c43:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102c48:	e9 dc 05 00 00       	jmp    c0103229 <__alltraps>

c0102c4d <vector131>:
.globl vector131
vector131:
  pushl $0
c0102c4d:	6a 00                	push   $0x0
  pushl $131
c0102c4f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102c54:	e9 d0 05 00 00       	jmp    c0103229 <__alltraps>

c0102c59 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $132
c0102c5b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102c60:	e9 c4 05 00 00       	jmp    c0103229 <__alltraps>

c0102c65 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102c65:	6a 00                	push   $0x0
  pushl $133
c0102c67:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102c6c:	e9 b8 05 00 00       	jmp    c0103229 <__alltraps>

c0102c71 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102c71:	6a 00                	push   $0x0
  pushl $134
c0102c73:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102c78:	e9 ac 05 00 00       	jmp    c0103229 <__alltraps>

c0102c7d <vector135>:
.globl vector135
vector135:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $135
c0102c7f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102c84:	e9 a0 05 00 00       	jmp    c0103229 <__alltraps>

c0102c89 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102c89:	6a 00                	push   $0x0
  pushl $136
c0102c8b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102c90:	e9 94 05 00 00       	jmp    c0103229 <__alltraps>

c0102c95 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102c95:	6a 00                	push   $0x0
  pushl $137
c0102c97:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102c9c:	e9 88 05 00 00       	jmp    c0103229 <__alltraps>

c0102ca1 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $138
c0102ca3:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102ca8:	e9 7c 05 00 00       	jmp    c0103229 <__alltraps>

c0102cad <vector139>:
.globl vector139
vector139:
  pushl $0
c0102cad:	6a 00                	push   $0x0
  pushl $139
c0102caf:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102cb4:	e9 70 05 00 00       	jmp    c0103229 <__alltraps>

c0102cb9 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102cb9:	6a 00                	push   $0x0
  pushl $140
c0102cbb:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102cc0:	e9 64 05 00 00       	jmp    c0103229 <__alltraps>

c0102cc5 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $141
c0102cc7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102ccc:	e9 58 05 00 00       	jmp    c0103229 <__alltraps>

c0102cd1 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102cd1:	6a 00                	push   $0x0
  pushl $142
c0102cd3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102cd8:	e9 4c 05 00 00       	jmp    c0103229 <__alltraps>

c0102cdd <vector143>:
.globl vector143
vector143:
  pushl $0
c0102cdd:	6a 00                	push   $0x0
  pushl $143
c0102cdf:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102ce4:	e9 40 05 00 00       	jmp    c0103229 <__alltraps>

c0102ce9 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $144
c0102ceb:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102cf0:	e9 34 05 00 00       	jmp    c0103229 <__alltraps>

c0102cf5 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102cf5:	6a 00                	push   $0x0
  pushl $145
c0102cf7:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102cfc:	e9 28 05 00 00       	jmp    c0103229 <__alltraps>

c0102d01 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102d01:	6a 00                	push   $0x0
  pushl $146
c0102d03:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102d08:	e9 1c 05 00 00       	jmp    c0103229 <__alltraps>

c0102d0d <vector147>:
.globl vector147
vector147:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $147
c0102d0f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102d14:	e9 10 05 00 00       	jmp    c0103229 <__alltraps>

c0102d19 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102d19:	6a 00                	push   $0x0
  pushl $148
c0102d1b:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102d20:	e9 04 05 00 00       	jmp    c0103229 <__alltraps>

c0102d25 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102d25:	6a 00                	push   $0x0
  pushl $149
c0102d27:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102d2c:	e9 f8 04 00 00       	jmp    c0103229 <__alltraps>

c0102d31 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $150
c0102d33:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102d38:	e9 ec 04 00 00       	jmp    c0103229 <__alltraps>

c0102d3d <vector151>:
.globl vector151
vector151:
  pushl $0
c0102d3d:	6a 00                	push   $0x0
  pushl $151
c0102d3f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102d44:	e9 e0 04 00 00       	jmp    c0103229 <__alltraps>

c0102d49 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102d49:	6a 00                	push   $0x0
  pushl $152
c0102d4b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102d50:	e9 d4 04 00 00       	jmp    c0103229 <__alltraps>

c0102d55 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $153
c0102d57:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102d5c:	e9 c8 04 00 00       	jmp    c0103229 <__alltraps>

c0102d61 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102d61:	6a 00                	push   $0x0
  pushl $154
c0102d63:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102d68:	e9 bc 04 00 00       	jmp    c0103229 <__alltraps>

c0102d6d <vector155>:
.globl vector155
vector155:
  pushl $0
c0102d6d:	6a 00                	push   $0x0
  pushl $155
c0102d6f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102d74:	e9 b0 04 00 00       	jmp    c0103229 <__alltraps>

c0102d79 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $156
c0102d7b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102d80:	e9 a4 04 00 00       	jmp    c0103229 <__alltraps>

c0102d85 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102d85:	6a 00                	push   $0x0
  pushl $157
c0102d87:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102d8c:	e9 98 04 00 00       	jmp    c0103229 <__alltraps>

c0102d91 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102d91:	6a 00                	push   $0x0
  pushl $158
c0102d93:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102d98:	e9 8c 04 00 00       	jmp    c0103229 <__alltraps>

c0102d9d <vector159>:
.globl vector159
vector159:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $159
c0102d9f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102da4:	e9 80 04 00 00       	jmp    c0103229 <__alltraps>

c0102da9 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102da9:	6a 00                	push   $0x0
  pushl $160
c0102dab:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102db0:	e9 74 04 00 00       	jmp    c0103229 <__alltraps>

c0102db5 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102db5:	6a 00                	push   $0x0
  pushl $161
c0102db7:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102dbc:	e9 68 04 00 00       	jmp    c0103229 <__alltraps>

c0102dc1 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $162
c0102dc3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102dc8:	e9 5c 04 00 00       	jmp    c0103229 <__alltraps>

c0102dcd <vector163>:
.globl vector163
vector163:
  pushl $0
c0102dcd:	6a 00                	push   $0x0
  pushl $163
c0102dcf:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102dd4:	e9 50 04 00 00       	jmp    c0103229 <__alltraps>

c0102dd9 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102dd9:	6a 00                	push   $0x0
  pushl $164
c0102ddb:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102de0:	e9 44 04 00 00       	jmp    c0103229 <__alltraps>

c0102de5 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $165
c0102de7:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102dec:	e9 38 04 00 00       	jmp    c0103229 <__alltraps>

c0102df1 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102df1:	6a 00                	push   $0x0
  pushl $166
c0102df3:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102df8:	e9 2c 04 00 00       	jmp    c0103229 <__alltraps>

c0102dfd <vector167>:
.globl vector167
vector167:
  pushl $0
c0102dfd:	6a 00                	push   $0x0
  pushl $167
c0102dff:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102e04:	e9 20 04 00 00       	jmp    c0103229 <__alltraps>

c0102e09 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $168
c0102e0b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102e10:	e9 14 04 00 00       	jmp    c0103229 <__alltraps>

c0102e15 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102e15:	6a 00                	push   $0x0
  pushl $169
c0102e17:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102e1c:	e9 08 04 00 00       	jmp    c0103229 <__alltraps>

c0102e21 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102e21:	6a 00                	push   $0x0
  pushl $170
c0102e23:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102e28:	e9 fc 03 00 00       	jmp    c0103229 <__alltraps>

c0102e2d <vector171>:
.globl vector171
vector171:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $171
c0102e2f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102e34:	e9 f0 03 00 00       	jmp    c0103229 <__alltraps>

c0102e39 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102e39:	6a 00                	push   $0x0
  pushl $172
c0102e3b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102e40:	e9 e4 03 00 00       	jmp    c0103229 <__alltraps>

c0102e45 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102e45:	6a 00                	push   $0x0
  pushl $173
c0102e47:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102e4c:	e9 d8 03 00 00       	jmp    c0103229 <__alltraps>

c0102e51 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $174
c0102e53:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102e58:	e9 cc 03 00 00       	jmp    c0103229 <__alltraps>

c0102e5d <vector175>:
.globl vector175
vector175:
  pushl $0
c0102e5d:	6a 00                	push   $0x0
  pushl $175
c0102e5f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102e64:	e9 c0 03 00 00       	jmp    c0103229 <__alltraps>

c0102e69 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102e69:	6a 00                	push   $0x0
  pushl $176
c0102e6b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102e70:	e9 b4 03 00 00       	jmp    c0103229 <__alltraps>

c0102e75 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $177
c0102e77:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102e7c:	e9 a8 03 00 00       	jmp    c0103229 <__alltraps>

c0102e81 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102e81:	6a 00                	push   $0x0
  pushl $178
c0102e83:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102e88:	e9 9c 03 00 00       	jmp    c0103229 <__alltraps>

c0102e8d <vector179>:
.globl vector179
vector179:
  pushl $0
c0102e8d:	6a 00                	push   $0x0
  pushl $179
c0102e8f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102e94:	e9 90 03 00 00       	jmp    c0103229 <__alltraps>

c0102e99 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $180
c0102e9b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102ea0:	e9 84 03 00 00       	jmp    c0103229 <__alltraps>

c0102ea5 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102ea5:	6a 00                	push   $0x0
  pushl $181
c0102ea7:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102eac:	e9 78 03 00 00       	jmp    c0103229 <__alltraps>

c0102eb1 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102eb1:	6a 00                	push   $0x0
  pushl $182
c0102eb3:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102eb8:	e9 6c 03 00 00       	jmp    c0103229 <__alltraps>

c0102ebd <vector183>:
.globl vector183
vector183:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $183
c0102ebf:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102ec4:	e9 60 03 00 00       	jmp    c0103229 <__alltraps>

c0102ec9 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102ec9:	6a 00                	push   $0x0
  pushl $184
c0102ecb:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102ed0:	e9 54 03 00 00       	jmp    c0103229 <__alltraps>

c0102ed5 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102ed5:	6a 00                	push   $0x0
  pushl $185
c0102ed7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102edc:	e9 48 03 00 00       	jmp    c0103229 <__alltraps>

c0102ee1 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $186
c0102ee3:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102ee8:	e9 3c 03 00 00       	jmp    c0103229 <__alltraps>

c0102eed <vector187>:
.globl vector187
vector187:
  pushl $0
c0102eed:	6a 00                	push   $0x0
  pushl $187
c0102eef:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102ef4:	e9 30 03 00 00       	jmp    c0103229 <__alltraps>

c0102ef9 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102ef9:	6a 00                	push   $0x0
  pushl $188
c0102efb:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102f00:	e9 24 03 00 00       	jmp    c0103229 <__alltraps>

c0102f05 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $189
c0102f07:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102f0c:	e9 18 03 00 00       	jmp    c0103229 <__alltraps>

c0102f11 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102f11:	6a 00                	push   $0x0
  pushl $190
c0102f13:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102f18:	e9 0c 03 00 00       	jmp    c0103229 <__alltraps>

c0102f1d <vector191>:
.globl vector191
vector191:
  pushl $0
c0102f1d:	6a 00                	push   $0x0
  pushl $191
c0102f1f:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102f24:	e9 00 03 00 00       	jmp    c0103229 <__alltraps>

c0102f29 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $192
c0102f2b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102f30:	e9 f4 02 00 00       	jmp    c0103229 <__alltraps>

c0102f35 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102f35:	6a 00                	push   $0x0
  pushl $193
c0102f37:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102f3c:	e9 e8 02 00 00       	jmp    c0103229 <__alltraps>

c0102f41 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102f41:	6a 00                	push   $0x0
  pushl $194
c0102f43:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102f48:	e9 dc 02 00 00       	jmp    c0103229 <__alltraps>

c0102f4d <vector195>:
.globl vector195
vector195:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $195
c0102f4f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102f54:	e9 d0 02 00 00       	jmp    c0103229 <__alltraps>

c0102f59 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102f59:	6a 00                	push   $0x0
  pushl $196
c0102f5b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102f60:	e9 c4 02 00 00       	jmp    c0103229 <__alltraps>

c0102f65 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102f65:	6a 00                	push   $0x0
  pushl $197
c0102f67:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102f6c:	e9 b8 02 00 00       	jmp    c0103229 <__alltraps>

c0102f71 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $198
c0102f73:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102f78:	e9 ac 02 00 00       	jmp    c0103229 <__alltraps>

c0102f7d <vector199>:
.globl vector199
vector199:
  pushl $0
c0102f7d:	6a 00                	push   $0x0
  pushl $199
c0102f7f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102f84:	e9 a0 02 00 00       	jmp    c0103229 <__alltraps>

c0102f89 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102f89:	6a 00                	push   $0x0
  pushl $200
c0102f8b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102f90:	e9 94 02 00 00       	jmp    c0103229 <__alltraps>

c0102f95 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $201
c0102f97:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102f9c:	e9 88 02 00 00       	jmp    c0103229 <__alltraps>

c0102fa1 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102fa1:	6a 00                	push   $0x0
  pushl $202
c0102fa3:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102fa8:	e9 7c 02 00 00       	jmp    c0103229 <__alltraps>

c0102fad <vector203>:
.globl vector203
vector203:
  pushl $0
c0102fad:	6a 00                	push   $0x0
  pushl $203
c0102faf:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102fb4:	e9 70 02 00 00       	jmp    c0103229 <__alltraps>

c0102fb9 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $204
c0102fbb:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102fc0:	e9 64 02 00 00       	jmp    c0103229 <__alltraps>

c0102fc5 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102fc5:	6a 00                	push   $0x0
  pushl $205
c0102fc7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102fcc:	e9 58 02 00 00       	jmp    c0103229 <__alltraps>

c0102fd1 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102fd1:	6a 00                	push   $0x0
  pushl $206
c0102fd3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102fd8:	e9 4c 02 00 00       	jmp    c0103229 <__alltraps>

c0102fdd <vector207>:
.globl vector207
vector207:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $207
c0102fdf:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102fe4:	e9 40 02 00 00       	jmp    c0103229 <__alltraps>

c0102fe9 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102fe9:	6a 00                	push   $0x0
  pushl $208
c0102feb:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102ff0:	e9 34 02 00 00       	jmp    c0103229 <__alltraps>

c0102ff5 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102ff5:	6a 00                	push   $0x0
  pushl $209
c0102ff7:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102ffc:	e9 28 02 00 00       	jmp    c0103229 <__alltraps>

c0103001 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103001:	6a 00                	push   $0x0
  pushl $210
c0103003:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103008:	e9 1c 02 00 00       	jmp    c0103229 <__alltraps>

c010300d <vector211>:
.globl vector211
vector211:
  pushl $0
c010300d:	6a 00                	push   $0x0
  pushl $211
c010300f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103014:	e9 10 02 00 00       	jmp    c0103229 <__alltraps>

c0103019 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103019:	6a 00                	push   $0x0
  pushl $212
c010301b:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103020:	e9 04 02 00 00       	jmp    c0103229 <__alltraps>

c0103025 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103025:	6a 00                	push   $0x0
  pushl $213
c0103027:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010302c:	e9 f8 01 00 00       	jmp    c0103229 <__alltraps>

c0103031 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103031:	6a 00                	push   $0x0
  pushl $214
c0103033:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103038:	e9 ec 01 00 00       	jmp    c0103229 <__alltraps>

c010303d <vector215>:
.globl vector215
vector215:
  pushl $0
c010303d:	6a 00                	push   $0x0
  pushl $215
c010303f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103044:	e9 e0 01 00 00       	jmp    c0103229 <__alltraps>

c0103049 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103049:	6a 00                	push   $0x0
  pushl $216
c010304b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103050:	e9 d4 01 00 00       	jmp    c0103229 <__alltraps>

c0103055 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103055:	6a 00                	push   $0x0
  pushl $217
c0103057:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010305c:	e9 c8 01 00 00       	jmp    c0103229 <__alltraps>

c0103061 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103061:	6a 00                	push   $0x0
  pushl $218
c0103063:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103068:	e9 bc 01 00 00       	jmp    c0103229 <__alltraps>

c010306d <vector219>:
.globl vector219
vector219:
  pushl $0
c010306d:	6a 00                	push   $0x0
  pushl $219
c010306f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103074:	e9 b0 01 00 00       	jmp    c0103229 <__alltraps>

c0103079 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103079:	6a 00                	push   $0x0
  pushl $220
c010307b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103080:	e9 a4 01 00 00       	jmp    c0103229 <__alltraps>

c0103085 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103085:	6a 00                	push   $0x0
  pushl $221
c0103087:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010308c:	e9 98 01 00 00       	jmp    c0103229 <__alltraps>

c0103091 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103091:	6a 00                	push   $0x0
  pushl $222
c0103093:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103098:	e9 8c 01 00 00       	jmp    c0103229 <__alltraps>

c010309d <vector223>:
.globl vector223
vector223:
  pushl $0
c010309d:	6a 00                	push   $0x0
  pushl $223
c010309f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01030a4:	e9 80 01 00 00       	jmp    c0103229 <__alltraps>

c01030a9 <vector224>:
.globl vector224
vector224:
  pushl $0
c01030a9:	6a 00                	push   $0x0
  pushl $224
c01030ab:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01030b0:	e9 74 01 00 00       	jmp    c0103229 <__alltraps>

c01030b5 <vector225>:
.globl vector225
vector225:
  pushl $0
c01030b5:	6a 00                	push   $0x0
  pushl $225
c01030b7:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01030bc:	e9 68 01 00 00       	jmp    c0103229 <__alltraps>

c01030c1 <vector226>:
.globl vector226
vector226:
  pushl $0
c01030c1:	6a 00                	push   $0x0
  pushl $226
c01030c3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01030c8:	e9 5c 01 00 00       	jmp    c0103229 <__alltraps>

c01030cd <vector227>:
.globl vector227
vector227:
  pushl $0
c01030cd:	6a 00                	push   $0x0
  pushl $227
c01030cf:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01030d4:	e9 50 01 00 00       	jmp    c0103229 <__alltraps>

c01030d9 <vector228>:
.globl vector228
vector228:
  pushl $0
c01030d9:	6a 00                	push   $0x0
  pushl $228
c01030db:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01030e0:	e9 44 01 00 00       	jmp    c0103229 <__alltraps>

c01030e5 <vector229>:
.globl vector229
vector229:
  pushl $0
c01030e5:	6a 00                	push   $0x0
  pushl $229
c01030e7:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01030ec:	e9 38 01 00 00       	jmp    c0103229 <__alltraps>

c01030f1 <vector230>:
.globl vector230
vector230:
  pushl $0
c01030f1:	6a 00                	push   $0x0
  pushl $230
c01030f3:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01030f8:	e9 2c 01 00 00       	jmp    c0103229 <__alltraps>

c01030fd <vector231>:
.globl vector231
vector231:
  pushl $0
c01030fd:	6a 00                	push   $0x0
  pushl $231
c01030ff:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103104:	e9 20 01 00 00       	jmp    c0103229 <__alltraps>

c0103109 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103109:	6a 00                	push   $0x0
  pushl $232
c010310b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103110:	e9 14 01 00 00       	jmp    c0103229 <__alltraps>

c0103115 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103115:	6a 00                	push   $0x0
  pushl $233
c0103117:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010311c:	e9 08 01 00 00       	jmp    c0103229 <__alltraps>

c0103121 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103121:	6a 00                	push   $0x0
  pushl $234
c0103123:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103128:	e9 fc 00 00 00       	jmp    c0103229 <__alltraps>

c010312d <vector235>:
.globl vector235
vector235:
  pushl $0
c010312d:	6a 00                	push   $0x0
  pushl $235
c010312f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103134:	e9 f0 00 00 00       	jmp    c0103229 <__alltraps>

c0103139 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103139:	6a 00                	push   $0x0
  pushl $236
c010313b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103140:	e9 e4 00 00 00       	jmp    c0103229 <__alltraps>

c0103145 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103145:	6a 00                	push   $0x0
  pushl $237
c0103147:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010314c:	e9 d8 00 00 00       	jmp    c0103229 <__alltraps>

c0103151 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103151:	6a 00                	push   $0x0
  pushl $238
c0103153:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103158:	e9 cc 00 00 00       	jmp    c0103229 <__alltraps>

c010315d <vector239>:
.globl vector239
vector239:
  pushl $0
c010315d:	6a 00                	push   $0x0
  pushl $239
c010315f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103164:	e9 c0 00 00 00       	jmp    c0103229 <__alltraps>

c0103169 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103169:	6a 00                	push   $0x0
  pushl $240
c010316b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103170:	e9 b4 00 00 00       	jmp    c0103229 <__alltraps>

c0103175 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103175:	6a 00                	push   $0x0
  pushl $241
c0103177:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010317c:	e9 a8 00 00 00       	jmp    c0103229 <__alltraps>

c0103181 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103181:	6a 00                	push   $0x0
  pushl $242
c0103183:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103188:	e9 9c 00 00 00       	jmp    c0103229 <__alltraps>

c010318d <vector243>:
.globl vector243
vector243:
  pushl $0
c010318d:	6a 00                	push   $0x0
  pushl $243
c010318f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103194:	e9 90 00 00 00       	jmp    c0103229 <__alltraps>

c0103199 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103199:	6a 00                	push   $0x0
  pushl $244
c010319b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01031a0:	e9 84 00 00 00       	jmp    c0103229 <__alltraps>

c01031a5 <vector245>:
.globl vector245
vector245:
  pushl $0
c01031a5:	6a 00                	push   $0x0
  pushl $245
c01031a7:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01031ac:	e9 78 00 00 00       	jmp    c0103229 <__alltraps>

c01031b1 <vector246>:
.globl vector246
vector246:
  pushl $0
c01031b1:	6a 00                	push   $0x0
  pushl $246
c01031b3:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01031b8:	e9 6c 00 00 00       	jmp    c0103229 <__alltraps>

c01031bd <vector247>:
.globl vector247
vector247:
  pushl $0
c01031bd:	6a 00                	push   $0x0
  pushl $247
c01031bf:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01031c4:	e9 60 00 00 00       	jmp    c0103229 <__alltraps>

c01031c9 <vector248>:
.globl vector248
vector248:
  pushl $0
c01031c9:	6a 00                	push   $0x0
  pushl $248
c01031cb:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01031d0:	e9 54 00 00 00       	jmp    c0103229 <__alltraps>

c01031d5 <vector249>:
.globl vector249
vector249:
  pushl $0
c01031d5:	6a 00                	push   $0x0
  pushl $249
c01031d7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01031dc:	e9 48 00 00 00       	jmp    c0103229 <__alltraps>

c01031e1 <vector250>:
.globl vector250
vector250:
  pushl $0
c01031e1:	6a 00                	push   $0x0
  pushl $250
c01031e3:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01031e8:	e9 3c 00 00 00       	jmp    c0103229 <__alltraps>

c01031ed <vector251>:
.globl vector251
vector251:
  pushl $0
c01031ed:	6a 00                	push   $0x0
  pushl $251
c01031ef:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01031f4:	e9 30 00 00 00       	jmp    c0103229 <__alltraps>

c01031f9 <vector252>:
.globl vector252
vector252:
  pushl $0
c01031f9:	6a 00                	push   $0x0
  pushl $252
c01031fb:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103200:	e9 24 00 00 00       	jmp    c0103229 <__alltraps>

c0103205 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103205:	6a 00                	push   $0x0
  pushl $253
c0103207:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010320c:	e9 18 00 00 00       	jmp    c0103229 <__alltraps>

c0103211 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103211:	6a 00                	push   $0x0
  pushl $254
c0103213:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103218:	e9 0c 00 00 00       	jmp    c0103229 <__alltraps>

c010321d <vector255>:
.globl vector255
vector255:
  pushl $0
c010321d:	6a 00                	push   $0x0
  pushl $255
c010321f:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103224:	e9 00 00 00 00       	jmp    c0103229 <__alltraps>

c0103229 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103229:	1e                   	push   %ds
    pushl %es
c010322a:	06                   	push   %es
    pushl %fs
c010322b:	0f a0                	push   %fs
    pushl %gs
c010322d:	0f a8                	push   %gs
    pushal
c010322f:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103230:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103235:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103237:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103239:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010323a:	e8 64 f5 ff ff       	call   c01027a3 <trap>

    # pop the pushed stack pointer
    popl %esp
c010323f:	5c                   	pop    %esp

c0103240 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103240:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103241:	0f a9                	pop    %gs
    popl %fs
c0103243:	0f a1                	pop    %fs
    popl %es
c0103245:	07                   	pop    %es
    popl %ds
c0103246:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103247:	83 c4 08             	add    $0x8,%esp
    iret
c010324a:	cf                   	iret   

c010324b <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010324b:	55                   	push   %ebp
c010324c:	89 e5                	mov    %esp,%ebp
c010324e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103251:	8b 45 08             	mov    0x8(%ebp),%eax
c0103254:	c1 e8 0c             	shr    $0xc,%eax
c0103257:	89 c2                	mov    %eax,%edx
c0103259:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010325e:	39 c2                	cmp    %eax,%edx
c0103260:	72 1c                	jb     c010327e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103262:	c7 44 24 08 70 94 10 	movl   $0xc0109470,0x8(%esp)
c0103269:	c0 
c010326a:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0103271:	00 
c0103272:	c7 04 24 8f 94 10 c0 	movl   $0xc010948f,(%esp)
c0103279:	e8 7a d1 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c010327e:	a1 00 41 12 c0       	mov    0xc0124100,%eax
c0103283:	8b 55 08             	mov    0x8(%ebp),%edx
c0103286:	c1 ea 0c             	shr    $0xc,%edx
c0103289:	c1 e2 05             	shl    $0x5,%edx
c010328c:	01 d0                	add    %edx,%eax
}
c010328e:	c9                   	leave  
c010328f:	c3                   	ret    

c0103290 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0103290:	55                   	push   %ebp
c0103291:	89 e5                	mov    %esp,%ebp
c0103293:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103296:	8b 45 08             	mov    0x8(%ebp),%eax
c0103299:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010329e:	89 04 24             	mov    %eax,(%esp)
c01032a1:	e8 a5 ff ff ff       	call   c010324b <pa2page>
}
c01032a6:	c9                   	leave  
c01032a7:	c3                   	ret    

c01032a8 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01032a8:	55                   	push   %ebp
c01032a9:	89 e5                	mov    %esp,%ebp
c01032ab:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01032ae:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01032b5:	e8 47 4a 00 00       	call   c0107d01 <kmalloc>
c01032ba:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01032bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032c1:	74 58                	je     c010331b <mm_create+0x73>
        list_init(&(mm->mmap_list));
c01032c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01032c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01032cf:	89 50 04             	mov    %edx,0x4(%eax)
c01032d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032d5:	8b 50 04             	mov    0x4(%eax),%edx
c01032d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032db:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01032dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01032e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ea:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01032f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01032fb:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0103300:	85 c0                	test   %eax,%eax
c0103302:	74 0d                	je     c0103311 <mm_create+0x69>
c0103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103307:	89 04 24             	mov    %eax,(%esp)
c010330a:	e8 e3 0d 00 00       	call   c01040f2 <swap_init_mm>
c010330f:	eb 0a                	jmp    c010331b <mm_create+0x73>
        else mm->sm_priv = NULL;
c0103311:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103314:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010331e:	c9                   	leave  
c010331f:	c3                   	ret    

c0103320 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0103320:	55                   	push   %ebp
c0103321:	89 e5                	mov    %esp,%ebp
c0103323:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103326:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010332d:	e8 cf 49 00 00       	call   c0107d01 <kmalloc>
c0103332:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103335:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103339:	74 1b                	je     c0103356 <vma_create+0x36>
        vma->vm_start = vm_start;
c010333b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010333e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103341:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0103344:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103347:	8b 55 0c             	mov    0xc(%ebp),%edx
c010334a:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010334d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103350:	8b 55 10             	mov    0x10(%ebp),%edx
c0103353:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0103356:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103359:	c9                   	leave  
c010335a:	c3                   	ret    

c010335b <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010335b:	55                   	push   %ebp
c010335c:	89 e5                	mov    %esp,%ebp
c010335e:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103361:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0103368:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010336c:	0f 84 95 00 00 00    	je     c0103407 <find_vma+0xac>
        vma = mm->mmap_cache;
c0103372:	8b 45 08             	mov    0x8(%ebp),%eax
c0103375:	8b 40 08             	mov    0x8(%eax),%eax
c0103378:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010337b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010337f:	74 16                	je     c0103397 <find_vma+0x3c>
c0103381:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103384:	8b 40 04             	mov    0x4(%eax),%eax
c0103387:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010338a:	77 0b                	ja     c0103397 <find_vma+0x3c>
c010338c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010338f:	8b 40 08             	mov    0x8(%eax),%eax
c0103392:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103395:	77 61                	ja     c01033f8 <find_vma+0x9d>
                bool found = 0;
c0103397:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010339e:	8b 45 08             	mov    0x8(%ebp),%eax
c01033a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01033aa:	eb 28                	jmp    c01033d4 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01033ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033af:	83 e8 10             	sub    $0x10,%eax
c01033b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01033b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033b8:	8b 40 04             	mov    0x4(%eax),%eax
c01033bb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033be:	77 14                	ja     c01033d4 <find_vma+0x79>
c01033c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033c3:	8b 40 08             	mov    0x8(%eax),%eax
c01033c6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033c9:	76 09                	jbe    c01033d4 <find_vma+0x79>
                        found = 1;
c01033cb:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01033d2:	eb 17                	jmp    c01033eb <find_vma+0x90>
c01033d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01033da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033dd:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01033e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01033e9:	75 c1                	jne    c01033ac <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01033eb:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01033ef:	75 07                	jne    c01033f8 <find_vma+0x9d>
                    vma = NULL;
c01033f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01033f8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01033fc:	74 09                	je     c0103407 <find_vma+0xac>
            mm->mmap_cache = vma;
c01033fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103401:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103404:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103407:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010340a:	c9                   	leave  
c010340b:	c3                   	ret    

c010340c <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010340c:	55                   	push   %ebp
c010340d:	89 e5                	mov    %esp,%ebp
c010340f:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0103412:	8b 45 08             	mov    0x8(%ebp),%eax
c0103415:	8b 50 04             	mov    0x4(%eax),%edx
c0103418:	8b 45 08             	mov    0x8(%ebp),%eax
c010341b:	8b 40 08             	mov    0x8(%eax),%eax
c010341e:	39 c2                	cmp    %eax,%edx
c0103420:	72 24                	jb     c0103446 <check_vma_overlap+0x3a>
c0103422:	c7 44 24 0c 9d 94 10 	movl   $0xc010949d,0xc(%esp)
c0103429:	c0 
c010342a:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103431:	c0 
c0103432:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0103439:	00 
c010343a:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103441:	e8 b2 cf ff ff       	call   c01003f8 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103446:	8b 45 08             	mov    0x8(%ebp),%eax
c0103449:	8b 50 08             	mov    0x8(%eax),%edx
c010344c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010344f:	8b 40 04             	mov    0x4(%eax),%eax
c0103452:	39 c2                	cmp    %eax,%edx
c0103454:	76 24                	jbe    c010347a <check_vma_overlap+0x6e>
c0103456:	c7 44 24 0c e0 94 10 	movl   $0xc01094e0,0xc(%esp)
c010345d:	c0 
c010345e:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103465:	c0 
c0103466:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010346d:	00 
c010346e:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103475:	e8 7e cf ff ff       	call   c01003f8 <__panic>
    assert(next->vm_start < next->vm_end);
c010347a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010347d:	8b 50 04             	mov    0x4(%eax),%edx
c0103480:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103483:	8b 40 08             	mov    0x8(%eax),%eax
c0103486:	39 c2                	cmp    %eax,%edx
c0103488:	72 24                	jb     c01034ae <check_vma_overlap+0xa2>
c010348a:	c7 44 24 0c ff 94 10 	movl   $0xc01094ff,0xc(%esp)
c0103491:	c0 
c0103492:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103499:	c0 
c010349a:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01034a1:	00 
c01034a2:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01034a9:	e8 4a cf ff ff       	call   c01003f8 <__panic>
}
c01034ae:	90                   	nop
c01034af:	c9                   	leave  
c01034b0:	c3                   	ret    

c01034b1 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01034b1:	55                   	push   %ebp
c01034b2:	89 e5                	mov    %esp,%ebp
c01034b4:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01034b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ba:	8b 50 04             	mov    0x4(%eax),%edx
c01034bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034c0:	8b 40 08             	mov    0x8(%eax),%eax
c01034c3:	39 c2                	cmp    %eax,%edx
c01034c5:	72 24                	jb     c01034eb <insert_vma_struct+0x3a>
c01034c7:	c7 44 24 0c 1d 95 10 	movl   $0xc010951d,0xc(%esp)
c01034ce:	c0 
c01034cf:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01034d6:	c0 
c01034d7:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01034de:	00 
c01034df:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01034e6:	e8 0d cf ff ff       	call   c01003f8 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01034eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01034ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01034f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034f4:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01034f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01034fd:	eb 1f                	jmp    c010351e <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01034ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103502:	83 e8 10             	sub    $0x10,%eax
c0103505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010350b:	8b 50 04             	mov    0x4(%eax),%edx
c010350e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103511:	8b 40 04             	mov    0x4(%eax),%eax
c0103514:	39 c2                	cmp    %eax,%edx
c0103516:	77 1f                	ja     c0103537 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0103518:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010351b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010351e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103521:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103524:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103527:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c010352a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010352d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103530:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103533:	75 ca                	jne    c01034ff <insert_vma_struct+0x4e>
c0103535:	eb 01                	jmp    c0103538 <insert_vma_struct+0x87>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c0103537:	90                   	nop
c0103538:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010353b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010353e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103541:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0103544:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0103547:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010354d:	74 15                	je     c0103564 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010354f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103552:	8d 50 f0             	lea    -0x10(%eax),%edx
c0103555:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103558:	89 44 24 04          	mov    %eax,0x4(%esp)
c010355c:	89 14 24             	mov    %edx,(%esp)
c010355f:	e8 a8 fe ff ff       	call   c010340c <check_vma_overlap>
    }
    if (le_next != list) {
c0103564:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103567:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010356a:	74 15                	je     c0103581 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010356c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010356f:	83 e8 10             	sub    $0x10,%eax
c0103572:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103576:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103579:	89 04 24             	mov    %eax,(%esp)
c010357c:	e8 8b fe ff ff       	call   c010340c <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0103581:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103584:	8b 55 08             	mov    0x8(%ebp),%edx
c0103587:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103589:	8b 45 0c             	mov    0xc(%ebp),%eax
c010358c:	8d 50 10             	lea    0x10(%eax),%edx
c010358f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103592:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103595:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103598:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010359b:	8b 40 04             	mov    0x4(%eax),%eax
c010359e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01035a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035a7:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01035aa:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01035ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035b0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035b3:	89 10                	mov    %edx,(%eax)
c01035b5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035b8:	8b 10                	mov    (%eax),%edx
c01035ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01035bd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01035c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035c3:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01035c6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01035c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01035cf:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01035d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d4:	8b 40 10             	mov    0x10(%eax),%eax
c01035d7:	8d 50 01             	lea    0x1(%eax),%edx
c01035da:	8b 45 08             	mov    0x8(%ebp),%eax
c01035dd:	89 50 10             	mov    %edx,0x10(%eax)
}
c01035e0:	90                   	nop
c01035e1:	c9                   	leave  
c01035e2:	c3                   	ret    

c01035e3 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01035e3:	55                   	push   %ebp
c01035e4:	89 e5                	mov    %esp,%ebp
c01035e6:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c01035e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01035ef:	eb 3e                	jmp    c010362f <mm_destroy+0x4c>
c01035f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01035f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035fa:	8b 40 04             	mov    0x4(%eax),%eax
c01035fd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103600:	8b 12                	mov    (%edx),%edx
c0103602:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103605:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010360b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010360e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103611:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103617:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c0103619:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010361c:	83 e8 10             	sub    $0x10,%eax
c010361f:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0103626:	00 
c0103627:	89 04 24             	mov    %eax,(%esp)
c010362a:	e8 72 47 00 00       	call   c0107da1 <kfree>
c010362f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103632:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103635:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103638:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c010363b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010363e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103641:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103644:	75 ab                	jne    c01035f1 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c0103646:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c010364d:	00 
c010364e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103651:	89 04 24             	mov    %eax,(%esp)
c0103654:	e8 48 47 00 00       	call   c0107da1 <kfree>
    mm=NULL;
c0103659:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0103660:	90                   	nop
c0103661:	c9                   	leave  
c0103662:	c3                   	ret    

c0103663 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103663:	55                   	push   %ebp
c0103664:	89 e5                	mov    %esp,%ebp
c0103666:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103669:	e8 03 00 00 00       	call   c0103671 <check_vmm>
}
c010366e:	90                   	nop
c010366f:	c9                   	leave  
c0103670:	c3                   	ret    

c0103671 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103671:	55                   	push   %ebp
c0103672:	89 e5                	mov    %esp,%ebp
c0103674:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103677:	e8 95 2f 00 00       	call   c0106611 <nr_free_pages>
c010367c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010367f:	e8 42 00 00 00       	call   c01036c6 <check_vma_struct>
    check_pgfault();
c0103684:	e8 fd 04 00 00       	call   c0103b86 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0103689:	e8 83 2f 00 00       	call   c0106611 <nr_free_pages>
c010368e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103691:	74 24                	je     c01036b7 <check_vmm+0x46>
c0103693:	c7 44 24 0c 3c 95 10 	movl   $0xc010953c,0xc(%esp)
c010369a:	c0 
c010369b:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01036a2:	c0 
c01036a3:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c01036aa:	00 
c01036ab:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01036b2:	e8 41 cd ff ff       	call   c01003f8 <__panic>

    cprintf("check_vmm() succeeded.\n");
c01036b7:	c7 04 24 63 95 10 c0 	movl   $0xc0109563,(%esp)
c01036be:	e8 de cb ff ff       	call   c01002a1 <cprintf>
}
c01036c3:	90                   	nop
c01036c4:	c9                   	leave  
c01036c5:	c3                   	ret    

c01036c6 <check_vma_struct>:

static void
check_vma_struct(void) {
c01036c6:	55                   	push   %ebp
c01036c7:	89 e5                	mov    %esp,%ebp
c01036c9:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01036cc:	e8 40 2f 00 00       	call   c0106611 <nr_free_pages>
c01036d1:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01036d4:	e8 cf fb ff ff       	call   c01032a8 <mm_create>
c01036d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01036dc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036e0:	75 24                	jne    c0103706 <check_vma_struct+0x40>
c01036e2:	c7 44 24 0c 7b 95 10 	movl   $0xc010957b,0xc(%esp)
c01036e9:	c0 
c01036ea:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01036f1:	c0 
c01036f2:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c01036f9:	00 
c01036fa:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103701:	e8 f2 cc ff ff       	call   c01003f8 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103706:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010370d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103710:	89 d0                	mov    %edx,%eax
c0103712:	c1 e0 02             	shl    $0x2,%eax
c0103715:	01 d0                	add    %edx,%eax
c0103717:	01 c0                	add    %eax,%eax
c0103719:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c010371c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010371f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103722:	eb 6f                	jmp    c0103793 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103724:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103727:	89 d0                	mov    %edx,%eax
c0103729:	c1 e0 02             	shl    $0x2,%eax
c010372c:	01 d0                	add    %edx,%eax
c010372e:	83 c0 02             	add    $0x2,%eax
c0103731:	89 c1                	mov    %eax,%ecx
c0103733:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103736:	89 d0                	mov    %edx,%eax
c0103738:	c1 e0 02             	shl    $0x2,%eax
c010373b:	01 d0                	add    %edx,%eax
c010373d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103744:	00 
c0103745:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103749:	89 04 24             	mov    %eax,(%esp)
c010374c:	e8 cf fb ff ff       	call   c0103320 <vma_create>
c0103751:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103754:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103758:	75 24                	jne    c010377e <check_vma_struct+0xb8>
c010375a:	c7 44 24 0c 86 95 10 	movl   $0xc0109586,0xc(%esp)
c0103761:	c0 
c0103762:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103769:	c0 
c010376a:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0103771:	00 
c0103772:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103779:	e8 7a cc ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c010377e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103781:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103785:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103788:	89 04 24             	mov    %eax,(%esp)
c010378b:	e8 21 fd ff ff       	call   c01034b1 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0103790:	ff 4d f4             	decl   -0xc(%ebp)
c0103793:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103797:	7f 8b                	jg     c0103724 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010379c:	40                   	inc    %eax
c010379d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037a0:	eb 6f                	jmp    c0103811 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01037a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037a5:	89 d0                	mov    %edx,%eax
c01037a7:	c1 e0 02             	shl    $0x2,%eax
c01037aa:	01 d0                	add    %edx,%eax
c01037ac:	83 c0 02             	add    $0x2,%eax
c01037af:	89 c1                	mov    %eax,%ecx
c01037b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037b4:	89 d0                	mov    %edx,%eax
c01037b6:	c1 e0 02             	shl    $0x2,%eax
c01037b9:	01 d0                	add    %edx,%eax
c01037bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037c2:	00 
c01037c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01037c7:	89 04 24             	mov    %eax,(%esp)
c01037ca:	e8 51 fb ff ff       	call   c0103320 <vma_create>
c01037cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01037d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01037d6:	75 24                	jne    c01037fc <check_vma_struct+0x136>
c01037d8:	c7 44 24 0c 86 95 10 	movl   $0xc0109586,0xc(%esp)
c01037df:	c0 
c01037e0:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01037e7:	c0 
c01037e8:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c01037ef:	00 
c01037f0:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01037f7:	e8 fc cb ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c01037fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103803:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103806:	89 04 24             	mov    %eax,(%esp)
c0103809:	e8 a3 fc ff ff       	call   c01034b1 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010380e:	ff 45 f4             	incl   -0xc(%ebp)
c0103811:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103814:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103817:	7e 89                	jle    c01037a2 <check_vma_struct+0xdc>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103819:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010381c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010381f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103822:	8b 40 04             	mov    0x4(%eax),%eax
c0103825:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103828:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c010382f:	e9 96 00 00 00       	jmp    c01038ca <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0103834:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103837:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010383a:	75 24                	jne    c0103860 <check_vma_struct+0x19a>
c010383c:	c7 44 24 0c 92 95 10 	movl   $0xc0109592,0xc(%esp)
c0103843:	c0 
c0103844:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c010384b:	c0 
c010384c:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103853:	00 
c0103854:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c010385b:	e8 98 cb ff ff       	call   c01003f8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103860:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103863:	83 e8 10             	sub    $0x10,%eax
c0103866:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103869:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010386c:	8b 48 04             	mov    0x4(%eax),%ecx
c010386f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103872:	89 d0                	mov    %edx,%eax
c0103874:	c1 e0 02             	shl    $0x2,%eax
c0103877:	01 d0                	add    %edx,%eax
c0103879:	39 c1                	cmp    %eax,%ecx
c010387b:	75 17                	jne    c0103894 <check_vma_struct+0x1ce>
c010387d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103880:	8b 48 08             	mov    0x8(%eax),%ecx
c0103883:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103886:	89 d0                	mov    %edx,%eax
c0103888:	c1 e0 02             	shl    $0x2,%eax
c010388b:	01 d0                	add    %edx,%eax
c010388d:	83 c0 02             	add    $0x2,%eax
c0103890:	39 c1                	cmp    %eax,%ecx
c0103892:	74 24                	je     c01038b8 <check_vma_struct+0x1f2>
c0103894:	c7 44 24 0c ac 95 10 	movl   $0xc01095ac,0xc(%esp)
c010389b:	c0 
c010389c:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01038a3:	c0 
c01038a4:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01038ab:	00 
c01038ac:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01038b3:	e8 40 cb ff ff       	call   c01003f8 <__panic>
c01038b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01038be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038c1:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01038c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01038c7:	ff 45 f4             	incl   -0xc(%ebp)
c01038ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038cd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01038d0:	0f 8e 5e ff ff ff    	jle    c0103834 <check_vma_struct+0x16e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01038d6:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01038dd:	e9 cb 01 00 00       	jmp    c0103aad <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c01038e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038ec:	89 04 24             	mov    %eax,(%esp)
c01038ef:	e8 67 fa ff ff       	call   c010335b <find_vma>
c01038f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c01038f7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01038fb:	75 24                	jne    c0103921 <check_vma_struct+0x25b>
c01038fd:	c7 44 24 0c e1 95 10 	movl   $0xc01095e1,0xc(%esp)
c0103904:	c0 
c0103905:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c010390c:	c0 
c010390d:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0103914:	00 
c0103915:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c010391c:	e8 d7 ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103924:	40                   	inc    %eax
c0103925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103929:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010392c:	89 04 24             	mov    %eax,(%esp)
c010392f:	e8 27 fa ff ff       	call   c010335b <find_vma>
c0103934:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c0103937:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010393b:	75 24                	jne    c0103961 <check_vma_struct+0x29b>
c010393d:	c7 44 24 0c ee 95 10 	movl   $0xc01095ee,0xc(%esp)
c0103944:	c0 
c0103945:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c010394c:	c0 
c010394d:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103954:	00 
c0103955:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c010395c:	e8 97 ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0103961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103964:	83 c0 02             	add    $0x2,%eax
c0103967:	89 44 24 04          	mov    %eax,0x4(%esp)
c010396b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010396e:	89 04 24             	mov    %eax,(%esp)
c0103971:	e8 e5 f9 ff ff       	call   c010335b <find_vma>
c0103976:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0103979:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010397d:	74 24                	je     c01039a3 <check_vma_struct+0x2dd>
c010397f:	c7 44 24 0c fb 95 10 	movl   $0xc01095fb,0xc(%esp)
c0103986:	c0 
c0103987:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c010398e:	c0 
c010398f:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103996:	00 
c0103997:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c010399e:	e8 55 ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01039a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039a6:	83 c0 03             	add    $0x3,%eax
c01039a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039b0:	89 04 24             	mov    %eax,(%esp)
c01039b3:	e8 a3 f9 ff ff       	call   c010335b <find_vma>
c01039b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c01039bb:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01039bf:	74 24                	je     c01039e5 <check_vma_struct+0x31f>
c01039c1:	c7 44 24 0c 08 96 10 	movl   $0xc0109608,0xc(%esp)
c01039c8:	c0 
c01039c9:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c01039d0:	c0 
c01039d1:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c01039d8:	00 
c01039d9:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c01039e0:	e8 13 ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01039e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039e8:	83 c0 04             	add    $0x4,%eax
c01039eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039f2:	89 04 24             	mov    %eax,(%esp)
c01039f5:	e8 61 f9 ff ff       	call   c010335b <find_vma>
c01039fa:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c01039fd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103a01:	74 24                	je     c0103a27 <check_vma_struct+0x361>
c0103a03:	c7 44 24 0c 15 96 10 	movl   $0xc0109615,0xc(%esp)
c0103a0a:	c0 
c0103a0b:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103a12:	c0 
c0103a13:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103a1a:	00 
c0103a1b:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103a22:	e8 d1 c9 ff ff       	call   c01003f8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0103a27:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a2a:	8b 50 04             	mov    0x4(%eax),%edx
c0103a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a30:	39 c2                	cmp    %eax,%edx
c0103a32:	75 10                	jne    c0103a44 <check_vma_struct+0x37e>
c0103a34:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a37:	8b 40 08             	mov    0x8(%eax),%eax
c0103a3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a3d:	83 c2 02             	add    $0x2,%edx
c0103a40:	39 d0                	cmp    %edx,%eax
c0103a42:	74 24                	je     c0103a68 <check_vma_struct+0x3a2>
c0103a44:	c7 44 24 0c 24 96 10 	movl   $0xc0109624,0xc(%esp)
c0103a4b:	c0 
c0103a4c:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103a53:	c0 
c0103a54:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103a5b:	00 
c0103a5c:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103a63:	e8 90 c9 ff ff       	call   c01003f8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103a68:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a6b:	8b 50 04             	mov    0x4(%eax),%edx
c0103a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a71:	39 c2                	cmp    %eax,%edx
c0103a73:	75 10                	jne    c0103a85 <check_vma_struct+0x3bf>
c0103a75:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a78:	8b 40 08             	mov    0x8(%eax),%eax
c0103a7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a7e:	83 c2 02             	add    $0x2,%edx
c0103a81:	39 d0                	cmp    %edx,%eax
c0103a83:	74 24                	je     c0103aa9 <check_vma_struct+0x3e3>
c0103a85:	c7 44 24 0c 54 96 10 	movl   $0xc0109654,0xc(%esp)
c0103a8c:	c0 
c0103a8d:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103a94:	c0 
c0103a95:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103a9c:	00 
c0103a9d:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103aa4:	e8 4f c9 ff ff       	call   c01003f8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103aa9:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103aad:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103ab0:	89 d0                	mov    %edx,%eax
c0103ab2:	c1 e0 02             	shl    $0x2,%eax
c0103ab5:	01 d0                	add    %edx,%eax
c0103ab7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103aba:	0f 8d 22 fe ff ff    	jge    c01038e2 <check_vma_struct+0x21c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103ac0:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103ac7:	eb 6f                	jmp    c0103b38 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0103ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ad3:	89 04 24             	mov    %eax,(%esp)
c0103ad6:	e8 80 f8 ff ff       	call   c010335b <find_vma>
c0103adb:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c0103ade:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103ae2:	74 27                	je     c0103b0b <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0103ae4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ae7:	8b 50 08             	mov    0x8(%eax),%edx
c0103aea:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103aed:	8b 40 04             	mov    0x4(%eax),%eax
c0103af0:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103af4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103afb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103aff:	c7 04 24 84 96 10 c0 	movl   $0xc0109684,(%esp)
c0103b06:	e8 96 c7 ff ff       	call   c01002a1 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0103b0b:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103b0f:	74 24                	je     c0103b35 <check_vma_struct+0x46f>
c0103b11:	c7 44 24 0c a9 96 10 	movl   $0xc01096a9,0xc(%esp)
c0103b18:	c0 
c0103b19:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103b20:	c0 
c0103b21:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103b28:	00 
c0103b29:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103b30:	e8 c3 c8 ff ff       	call   c01003f8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103b35:	ff 4d f4             	decl   -0xc(%ebp)
c0103b38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b3c:	79 8b                	jns    c0103ac9 <check_vma_struct+0x403>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0103b3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b41:	89 04 24             	mov    %eax,(%esp)
c0103b44:	e8 9a fa ff ff       	call   c01035e3 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0103b49:	e8 c3 2a 00 00       	call   c0106611 <nr_free_pages>
c0103b4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103b51:	74 24                	je     c0103b77 <check_vma_struct+0x4b1>
c0103b53:	c7 44 24 0c 3c 95 10 	movl   $0xc010953c,0xc(%esp)
c0103b5a:	c0 
c0103b5b:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103b62:	c0 
c0103b63:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103b6a:	00 
c0103b6b:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103b72:	e8 81 c8 ff ff       	call   c01003f8 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0103b77:	c7 04 24 c0 96 10 c0 	movl   $0xc01096c0,(%esp)
c0103b7e:	e8 1e c7 ff ff       	call   c01002a1 <cprintf>
}
c0103b83:	90                   	nop
c0103b84:	c9                   	leave  
c0103b85:	c3                   	ret    

c0103b86 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103b86:	55                   	push   %ebp
c0103b87:	89 e5                	mov    %esp,%ebp
c0103b89:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103b8c:	e8 80 2a 00 00       	call   c0106611 <nr_free_pages>
c0103b91:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103b94:	e8 0f f7 ff ff       	call   c01032a8 <mm_create>
c0103b99:	a3 10 40 12 c0       	mov    %eax,0xc0124010
    assert(check_mm_struct != NULL);
c0103b9e:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0103ba3:	85 c0                	test   %eax,%eax
c0103ba5:	75 24                	jne    c0103bcb <check_pgfault+0x45>
c0103ba7:	c7 44 24 0c df 96 10 	movl   $0xc01096df,0xc(%esp)
c0103bae:	c0 
c0103baf:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103bb6:	c0 
c0103bb7:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0103bbe:	00 
c0103bbf:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103bc6:	e8 2d c8 ff ff       	call   c01003f8 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103bcb:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0103bd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103bd3:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c0103bd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bdc:	89 50 0c             	mov    %edx,0xc(%eax)
c0103bdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103be2:	8b 40 0c             	mov    0xc(%eax),%eax
c0103be5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103beb:	8b 00                	mov    (%eax),%eax
c0103bed:	85 c0                	test   %eax,%eax
c0103bef:	74 24                	je     c0103c15 <check_pgfault+0x8f>
c0103bf1:	c7 44 24 0c f7 96 10 	movl   $0xc01096f7,0xc(%esp)
c0103bf8:	c0 
c0103bf9:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103c00:	c0 
c0103c01:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103c08:	00 
c0103c09:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103c10:	e8 e3 c7 ff ff       	call   c01003f8 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103c15:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0103c1c:	00 
c0103c1d:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0103c24:	00 
c0103c25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0103c2c:	e8 ef f6 ff ff       	call   c0103320 <vma_create>
c0103c31:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103c34:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103c38:	75 24                	jne    c0103c5e <check_pgfault+0xd8>
c0103c3a:	c7 44 24 0c 86 95 10 	movl   $0xc0109586,0xc(%esp)
c0103c41:	c0 
c0103c42:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103c49:	c0 
c0103c4a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0103c51:	00 
c0103c52:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103c59:	e8 9a c7 ff ff       	call   c01003f8 <__panic>

    insert_vma_struct(mm, vma);
c0103c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c68:	89 04 24             	mov    %eax,(%esp)
c0103c6b:	e8 41 f8 ff ff       	call   c01034b1 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0103c70:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103c77:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c81:	89 04 24             	mov    %eax,(%esp)
c0103c84:	e8 d2 f6 ff ff       	call   c010335b <find_vma>
c0103c89:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103c8c:	74 24                	je     c0103cb2 <check_pgfault+0x12c>
c0103c8e:	c7 44 24 0c 05 97 10 	movl   $0xc0109705,0xc(%esp)
c0103c95:	c0 
c0103c96:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103c9d:	c0 
c0103c9e:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103ca5:	00 
c0103ca6:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103cad:	e8 46 c7 ff ff       	call   c01003f8 <__panic>

    int i, sum = 0;
c0103cb2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103cb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cc0:	eb 16                	jmp    c0103cd8 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0103cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cc8:	01 d0                	add    %edx,%eax
c0103cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ccd:	88 10                	mov    %dl,(%eax)
        sum += i;
c0103ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd2:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0103cd5:	ff 45 f4             	incl   -0xc(%ebp)
c0103cd8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103cdc:	7e e4                	jle    c0103cc2 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103cde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ce5:	eb 14                	jmp    c0103cfb <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0103ce7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ced:	01 d0                	add    %edx,%eax
c0103cef:	0f b6 00             	movzbl (%eax),%eax
c0103cf2:	0f be c0             	movsbl %al,%eax
c0103cf5:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103cf8:	ff 45 f4             	incl   -0xc(%ebp)
c0103cfb:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103cff:	7e e6                	jle    c0103ce7 <check_pgfault+0x161>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0103d01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d05:	74 24                	je     c0103d2b <check_pgfault+0x1a5>
c0103d07:	c7 44 24 0c 1f 97 10 	movl   $0xc010971f,0xc(%esp)
c0103d0e:	c0 
c0103d0f:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103d16:	c0 
c0103d17:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103d1e:	00 
c0103d1f:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103d26:	e8 cd c6 ff ff       	call   c01003f8 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103d2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103d31:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103d34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d40:	89 04 24             	mov    %eax,(%esp)
c0103d43:	e8 ec 30 00 00       	call   c0106e34 <page_remove>
    free_page(pde2page(pgdir[0]));
c0103d48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d4b:	8b 00                	mov    (%eax),%eax
c0103d4d:	89 04 24             	mov    %eax,(%esp)
c0103d50:	e8 3b f5 ff ff       	call   c0103290 <pde2page>
c0103d55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d5c:	00 
c0103d5d:	89 04 24             	mov    %eax,(%esp)
c0103d60:	e8 79 28 00 00       	call   c01065de <free_pages>
    pgdir[0] = 0;
c0103d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103d6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d71:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d7b:	89 04 24             	mov    %eax,(%esp)
c0103d7e:	e8 60 f8 ff ff       	call   c01035e3 <mm_destroy>
    check_mm_struct = NULL;
c0103d83:	c7 05 10 40 12 c0 00 	movl   $0x0,0xc0124010
c0103d8a:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103d8d:	e8 7f 28 00 00       	call   c0106611 <nr_free_pages>
c0103d92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103d95:	74 24                	je     c0103dbb <check_pgfault+0x235>
c0103d97:	c7 44 24 0c 3c 95 10 	movl   $0xc010953c,0xc(%esp)
c0103d9e:	c0 
c0103d9f:	c7 44 24 08 bb 94 10 	movl   $0xc01094bb,0x8(%esp)
c0103da6:	c0 
c0103da7:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0103dae:	00 
c0103daf:	c7 04 24 d0 94 10 c0 	movl   $0xc01094d0,(%esp)
c0103db6:	e8 3d c6 ff ff       	call   c01003f8 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103dbb:	c7 04 24 28 97 10 c0 	movl   $0xc0109728,(%esp)
c0103dc2:	e8 da c4 ff ff       	call   c01002a1 <cprintf>
}
c0103dc7:	90                   	nop
c0103dc8:	c9                   	leave  
c0103dc9:	c3                   	ret    

c0103dca <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103dca:	55                   	push   %ebp
c0103dcb:	89 e5                	mov    %esp,%ebp
c0103dcd:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0103dd0:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103dd7:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de1:	89 04 24             	mov    %eax,(%esp)
c0103de4:	e8 72 f5 ff ff       	call   c010335b <find_vma>
c0103de9:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103dec:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0103df1:	40                   	inc    %eax
c0103df2:	a3 64 3f 12 c0       	mov    %eax,0xc0123f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103df7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103dfb:	74 0b                	je     c0103e08 <do_pgfault+0x3e>
c0103dfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e00:	8b 40 04             	mov    0x4(%eax),%eax
c0103e03:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103e06:	76 18                	jbe    c0103e20 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103e08:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e0f:	c7 04 24 44 97 10 c0 	movl   $0xc0109744,(%esp)
c0103e16:	e8 86 c4 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0103e1b:	e9 ba 01 00 00       	jmp    c0103fda <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0103e20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e23:	83 e0 03             	and    $0x3,%eax
c0103e26:	85 c0                	test   %eax,%eax
c0103e28:	74 34                	je     c0103e5e <do_pgfault+0x94>
c0103e2a:	83 f8 01             	cmp    $0x1,%eax
c0103e2d:	74 1e                	je     c0103e4d <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103e2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e32:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e35:	83 e0 02             	and    $0x2,%eax
c0103e38:	85 c0                	test   %eax,%eax
c0103e3a:	75 40                	jne    c0103e7c <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103e3c:	c7 04 24 74 97 10 c0 	movl   $0xc0109774,(%esp)
c0103e43:	e8 59 c4 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103e48:	e9 8d 01 00 00       	jmp    c0103fda <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103e4d:	c7 04 24 d4 97 10 c0 	movl   $0xc01097d4,(%esp)
c0103e54:	e8 48 c4 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0103e59:	e9 7c 01 00 00       	jmp    c0103fda <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103e5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e61:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e64:	83 e0 05             	and    $0x5,%eax
c0103e67:	85 c0                	test   %eax,%eax
c0103e69:	75 12                	jne    c0103e7d <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103e6b:	c7 04 24 0c 98 10 c0 	movl   $0xc010980c,(%esp)
c0103e72:	e8 2a c4 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103e77:	e9 5e 01 00 00       	jmp    c0103fda <do_pgfault+0x210>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0103e7c:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103e7d:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103e84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e87:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e8a:	83 e0 02             	and    $0x2,%eax
c0103e8d:	85 c0                	test   %eax,%eax
c0103e8f:	74 04                	je     c0103e95 <do_pgfault+0xcb>
        perm |= PTE_W;
c0103e91:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103e95:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e98:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ea3:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103ea6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103ead:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
   if((ptep=get_pte(mm->pgdir,addr,1))==NULL)  
c0103eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eb7:	8b 40 0c             	mov    0xc(%eax),%eax
c0103eba:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103ec1:	00 
c0103ec2:	8b 55 10             	mov    0x10(%ebp),%edx
c0103ec5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ec9:	89 04 24             	mov    %eax,(%esp)
c0103ecc:	e8 6f 2d 00 00       	call   c0106c40 <get_pte>
c0103ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ed4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ed8:	75 11                	jne    c0103eeb <do_pgfault+0x121>
   {
      cprintf("do_pgfault failed: get_pte return NULL");
c0103eda:	c7 04 24 70 98 10 c0 	movl   $0xc0109870,(%esp)
c0103ee1:	e8 bb c3 ff ff       	call   c01002a1 <cprintf>
     goto failed;
c0103ee6:	e9 ef 00 00 00       	jmp    c0103fda <do_pgfault+0x210>
   }
   if(*ptep == 0)
c0103eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eee:	8b 00                	mov    (%eax),%eax
c0103ef0:	85 c0                	test   %eax,%eax
c0103ef2:	75 35                	jne    c0103f29 <do_pgfault+0x15f>
   {
      if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)
c0103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ef7:	8b 40 0c             	mov    0xc(%eax),%eax
c0103efa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103efd:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103f01:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f04:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f08:	89 04 24             	mov    %eax,(%esp)
c0103f0b:	e8 7e 30 00 00       	call   c0106f8e <pgdir_alloc_page>
c0103f10:	85 c0                	test   %eax,%eax
c0103f12:	0f 85 bb 00 00 00    	jne    c0103fd3 <do_pgfault+0x209>
      {
           cprintf("do_pgfault failed: pgdir_alloc_page return NULL");
c0103f18:	c7 04 24 98 98 10 c0 	movl   $0xc0109898,(%esp)
c0103f1f:	e8 7d c3 ff ff       	call   c01002a1 <cprintf>
           goto failed;
c0103f24:	e9 b1 00 00 00       	jmp    c0103fda <do_pgfault+0x210>

      }
   }
   else
   {
      if(swap_init_ok) {
c0103f29:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0103f2e:	85 c0                	test   %eax,%eax
c0103f30:	0f 84 86 00 00 00    	je     c0103fbc <do_pgfault+0x1f2>
            struct Page *page=NULL;
c0103f36:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
             if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103f3d:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103f40:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f44:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f4e:	89 04 24             	mov    %eax,(%esp)
c0103f51:	e8 8e 03 00 00       	call   c01042e4 <swap_in>
c0103f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103f59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f5d:	74 0e                	je     c0103f6d <do_pgfault+0x1a3>
                cprintf("do_pgfault failed: swap_in returned not 0\n");
c0103f5f:	c7 04 24 c8 98 10 c0 	movl   $0xc01098c8,(%esp)
c0103f66:	e8 36 c3 ff ff       	call   c01002a1 <cprintf>
c0103f6b:	eb 6d                	jmp    c0103fda <do_pgfault+0x210>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c0103f6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f70:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f73:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f76:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0103f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0103f7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103f80:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103f84:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f88:	89 04 24             	mov    %eax,(%esp)
c0103f8b:	e8 e9 2e 00 00       	call   c0106e79 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0103f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f93:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103f9a:	00 
c0103f9b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fa9:	89 04 24             	mov    %eax,(%esp)
c0103fac:	e8 71 01 00 00       	call   c0104122 <swap_map_swappable>
            page->pra_vaddr = addr;
c0103fb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fb4:	8b 55 10             	mov    0x10(%ebp),%edx
c0103fb7:	89 50 1c             	mov    %edx,0x1c(%eax)
c0103fba:	eb 17                	jmp    c0103fd3 <do_pgfault+0x209>
      }
      else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103fbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fbf:	8b 00                	mov    (%eax),%eax
c0103fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fc5:	c7 04 24 f4 98 10 c0 	movl   $0xc01098f4,(%esp)
c0103fcc:	e8 d0 c2 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103fd1:	eb 07                	jmp    c0103fda <do_pgfault+0x210>
        }
   }
   ret = 0;
c0103fd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103fdd:	c9                   	leave  
c0103fde:	c3                   	ret    

c0103fdf <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103fdf:	55                   	push   %ebp
c0103fe0:	89 e5                	mov    %esp,%ebp
c0103fe2:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fe8:	c1 e8 0c             	shr    $0xc,%eax
c0103feb:	89 c2                	mov    %eax,%edx
c0103fed:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0103ff2:	39 c2                	cmp    %eax,%edx
c0103ff4:	72 1c                	jb     c0104012 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103ff6:	c7 44 24 08 1c 99 10 	movl   $0xc010991c,0x8(%esp)
c0103ffd:	c0 
c0103ffe:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104005:	00 
c0104006:	c7 04 24 3b 99 10 c0 	movl   $0xc010993b,(%esp)
c010400d:	e8 e6 c3 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c0104012:	a1 00 41 12 c0       	mov    0xc0124100,%eax
c0104017:	8b 55 08             	mov    0x8(%ebp),%edx
c010401a:	c1 ea 0c             	shr    $0xc,%edx
c010401d:	c1 e2 05             	shl    $0x5,%edx
c0104020:	01 d0                	add    %edx,%eax
}
c0104022:	c9                   	leave  
c0104023:	c3                   	ret    

c0104024 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104024:	55                   	push   %ebp
c0104025:	89 e5                	mov    %esp,%ebp
c0104027:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010402a:	8b 45 08             	mov    0x8(%ebp),%eax
c010402d:	83 e0 01             	and    $0x1,%eax
c0104030:	85 c0                	test   %eax,%eax
c0104032:	75 1c                	jne    c0104050 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104034:	c7 44 24 08 4c 99 10 	movl   $0xc010994c,0x8(%esp)
c010403b:	c0 
c010403c:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104043:	00 
c0104044:	c7 04 24 3b 99 10 c0 	movl   $0xc010993b,(%esp)
c010404b:	e8 a8 c3 ff ff       	call   c01003f8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104050:	8b 45 08             	mov    0x8(%ebp),%eax
c0104053:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104058:	89 04 24             	mov    %eax,(%esp)
c010405b:	e8 7f ff ff ff       	call   c0103fdf <pa2page>
}
c0104060:	c9                   	leave  
c0104061:	c3                   	ret    

c0104062 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0104062:	55                   	push   %ebp
c0104063:	89 e5                	mov    %esp,%ebp
c0104065:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0104068:	e8 4c 3e 00 00       	call   c0107eb9 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010406d:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0104072:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0104077:	76 0c                	jbe    c0104085 <swap_init+0x23>
c0104079:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c010407e:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104083:	76 25                	jbe    c01040aa <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0104085:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c010408a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010408e:	c7 44 24 08 6d 99 10 	movl   $0xc010996d,0x8(%esp)
c0104095:	c0 
c0104096:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c010409d:	00 
c010409e:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01040a5:	e8 4e c3 ff ff       	call   c01003f8 <__panic>
     }
     

     sm = &swap_manager_fifo;
c01040aa:	c7 05 70 3f 12 c0 e0 	movl   $0xc01209e0,0xc0123f70
c01040b1:	09 12 c0 
     int r = sm->init();
c01040b4:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01040b9:	8b 40 04             	mov    0x4(%eax),%eax
c01040bc:	ff d0                	call   *%eax
c01040be:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01040c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01040c5:	75 26                	jne    c01040ed <swap_init+0x8b>
     {
          swap_init_ok = 1;
c01040c7:	c7 05 68 3f 12 c0 01 	movl   $0x1,0xc0123f68
c01040ce:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01040d1:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01040d6:	8b 00                	mov    (%eax),%eax
c01040d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040dc:	c7 04 24 97 99 10 c0 	movl   $0xc0109997,(%esp)
c01040e3:	e8 b9 c1 ff ff       	call   c01002a1 <cprintf>
          check_swap();
c01040e8:	e8 9e 04 00 00       	call   c010458b <check_swap>
     }

     return r;
c01040ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01040f0:	c9                   	leave  
c01040f1:	c3                   	ret    

c01040f2 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01040f2:	55                   	push   %ebp
c01040f3:	89 e5                	mov    %esp,%ebp
c01040f5:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01040f8:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01040fd:	8b 40 08             	mov    0x8(%eax),%eax
c0104100:	8b 55 08             	mov    0x8(%ebp),%edx
c0104103:	89 14 24             	mov    %edx,(%esp)
c0104106:	ff d0                	call   *%eax
}
c0104108:	c9                   	leave  
c0104109:	c3                   	ret    

c010410a <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010410a:	55                   	push   %ebp
c010410b:	89 e5                	mov    %esp,%ebp
c010410d:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0104110:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104115:	8b 40 0c             	mov    0xc(%eax),%eax
c0104118:	8b 55 08             	mov    0x8(%ebp),%edx
c010411b:	89 14 24             	mov    %edx,(%esp)
c010411e:	ff d0                	call   *%eax
}
c0104120:	c9                   	leave  
c0104121:	c3                   	ret    

c0104122 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104122:	55                   	push   %ebp
c0104123:	89 e5                	mov    %esp,%ebp
c0104125:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0104128:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010412d:	8b 40 10             	mov    0x10(%eax),%eax
c0104130:	8b 55 14             	mov    0x14(%ebp),%edx
c0104133:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104137:	8b 55 10             	mov    0x10(%ebp),%edx
c010413a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010413e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104141:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104145:	8b 55 08             	mov    0x8(%ebp),%edx
c0104148:	89 14 24             	mov    %edx,(%esp)
c010414b:	ff d0                	call   *%eax
}
c010414d:	c9                   	leave  
c010414e:	c3                   	ret    

c010414f <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010414f:	55                   	push   %ebp
c0104150:	89 e5                	mov    %esp,%ebp
c0104152:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0104155:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010415a:	8b 40 14             	mov    0x14(%eax),%eax
c010415d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104160:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104164:	8b 55 08             	mov    0x8(%ebp),%edx
c0104167:	89 14 24             	mov    %edx,(%esp)
c010416a:	ff d0                	call   *%eax
}
c010416c:	c9                   	leave  
c010416d:	c3                   	ret    

c010416e <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c010416e:	55                   	push   %ebp
c010416f:	89 e5                	mov    %esp,%ebp
c0104171:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104174:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010417b:	e9 53 01 00 00       	jmp    c01042d3 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104180:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104185:	8b 40 18             	mov    0x18(%eax),%eax
c0104188:	8b 55 10             	mov    0x10(%ebp),%edx
c010418b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010418f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104192:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104196:	8b 55 08             	mov    0x8(%ebp),%edx
c0104199:	89 14 24             	mov    %edx,(%esp)
c010419c:	ff d0                	call   *%eax
c010419e:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01041a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01041a5:	74 18                	je     c01041bf <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01041a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041ae:	c7 04 24 ac 99 10 c0 	movl   $0xc01099ac,(%esp)
c01041b5:	e8 e7 c0 ff ff       	call   c01002a1 <cprintf>
c01041ba:	e9 20 01 00 00       	jmp    c01042df <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01041bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041c2:	8b 40 1c             	mov    0x1c(%eax),%eax
c01041c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01041c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041cb:	8b 40 0c             	mov    0xc(%eax),%eax
c01041ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01041d5:	00 
c01041d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01041d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01041dd:	89 04 24             	mov    %eax,(%esp)
c01041e0:	e8 5b 2a 00 00       	call   c0106c40 <get_pte>
c01041e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01041e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041eb:	8b 00                	mov    (%eax),%eax
c01041ed:	83 e0 01             	and    $0x1,%eax
c01041f0:	85 c0                	test   %eax,%eax
c01041f2:	75 24                	jne    c0104218 <swap_out+0xaa>
c01041f4:	c7 44 24 0c d9 99 10 	movl   $0xc01099d9,0xc(%esp)
c01041fb:	c0 
c01041fc:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104203:	c0 
c0104204:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010420b:	00 
c010420c:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104213:	e8 e0 c1 ff ff       	call   c01003f8 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010421b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010421e:	8b 52 1c             	mov    0x1c(%edx),%edx
c0104221:	c1 ea 0c             	shr    $0xc,%edx
c0104224:	42                   	inc    %edx
c0104225:	c1 e2 08             	shl    $0x8,%edx
c0104228:	89 44 24 04          	mov    %eax,0x4(%esp)
c010422c:	89 14 24             	mov    %edx,(%esp)
c010422f:	e8 40 3d 00 00       	call   c0107f74 <swapfs_write>
c0104234:	85 c0                	test   %eax,%eax
c0104236:	74 34                	je     c010426c <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0104238:	c7 04 24 03 9a 10 c0 	movl   $0xc0109a03,(%esp)
c010423f:	e8 5d c0 ff ff       	call   c01002a1 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0104244:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104249:	8b 40 10             	mov    0x10(%eax),%eax
c010424c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010424f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104256:	00 
c0104257:	89 54 24 08          	mov    %edx,0x8(%esp)
c010425b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010425e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104262:	8b 55 08             	mov    0x8(%ebp),%edx
c0104265:	89 14 24             	mov    %edx,(%esp)
c0104268:	ff d0                	call   *%eax
c010426a:	eb 64                	jmp    c01042d0 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c010426c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010426f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104272:	c1 e8 0c             	shr    $0xc,%eax
c0104275:	40                   	inc    %eax
c0104276:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010427a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010427d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104281:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104284:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104288:	c7 04 24 1c 9a 10 c0 	movl   $0xc0109a1c,(%esp)
c010428f:	e8 0d c0 ff ff       	call   c01002a1 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104297:	8b 40 1c             	mov    0x1c(%eax),%eax
c010429a:	c1 e8 0c             	shr    $0xc,%eax
c010429d:	40                   	inc    %eax
c010429e:	c1 e0 08             	shl    $0x8,%eax
c01042a1:	89 c2                	mov    %eax,%edx
c01042a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042a6:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01042a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01042b2:	00 
c01042b3:	89 04 24             	mov    %eax,(%esp)
c01042b6:	e8 23 23 00 00       	call   c01065de <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c01042bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01042be:	8b 40 0c             	mov    0xc(%eax),%eax
c01042c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01042c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042c8:	89 04 24             	mov    %eax,(%esp)
c01042cb:	e8 62 2c 00 00       	call   c0106f32 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c01042d0:	ff 45 f4             	incl   -0xc(%ebp)
c01042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01042d9:	0f 85 a1 fe ff ff    	jne    c0104180 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c01042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01042e2:	c9                   	leave  
c01042e3:	c3                   	ret    

c01042e4 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01042e4:	55                   	push   %ebp
c01042e5:	89 e5                	mov    %esp,%ebp
c01042e7:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01042ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042f1:	e8 7d 22 00 00       	call   c0106573 <alloc_pages>
c01042f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01042f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042fd:	75 24                	jne    c0104323 <swap_in+0x3f>
c01042ff:	c7 44 24 0c 5c 9a 10 	movl   $0xc0109a5c,0xc(%esp)
c0104306:	c0 
c0104307:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c010430e:	c0 
c010430f:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0104316:	00 
c0104317:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c010431e:	e8 d5 c0 ff ff       	call   c01003f8 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104323:	8b 45 08             	mov    0x8(%ebp),%eax
c0104326:	8b 40 0c             	mov    0xc(%eax),%eax
c0104329:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104330:	00 
c0104331:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104334:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104338:	89 04 24             	mov    %eax,(%esp)
c010433b:	e8 00 29 00 00       	call   c0106c40 <get_pte>
c0104340:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104343:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104346:	8b 00                	mov    (%eax),%eax
c0104348:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010434b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010434f:	89 04 24             	mov    %eax,(%esp)
c0104352:	e8 ab 3b 00 00       	call   c0107f02 <swapfs_read>
c0104357:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010435a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010435e:	74 2a                	je     c010438a <swap_in+0xa6>
     {
        assert(r!=0);
c0104360:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104364:	75 24                	jne    c010438a <swap_in+0xa6>
c0104366:	c7 44 24 0c 69 9a 10 	movl   $0xc0109a69,0xc(%esp)
c010436d:	c0 
c010436e:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104375:	c0 
c0104376:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c010437d:	00 
c010437e:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104385:	e8 6e c0 ff ff       	call   c01003f8 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c010438a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010438d:	8b 00                	mov    (%eax),%eax
c010438f:	c1 e8 08             	shr    $0x8,%eax
c0104392:	89 c2                	mov    %eax,%edx
c0104394:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104397:	89 44 24 08          	mov    %eax,0x8(%esp)
c010439b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010439f:	c7 04 24 70 9a 10 c0 	movl   $0xc0109a70,(%esp)
c01043a6:	e8 f6 be ff ff       	call   c01002a1 <cprintf>
     *ptr_result=result;
c01043ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01043ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01043b1:	89 10                	mov    %edx,(%eax)
     return 0;
c01043b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01043b8:	c9                   	leave  
c01043b9:	c3                   	ret    

c01043ba <check_content_set>:



static inline void
check_content_set(void)
{
c01043ba:	55                   	push   %ebp
c01043bb:	89 e5                	mov    %esp,%ebp
c01043bd:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01043c0:	b8 00 10 00 00       	mov    $0x1000,%eax
c01043c5:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01043c8:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01043cd:	83 f8 01             	cmp    $0x1,%eax
c01043d0:	74 24                	je     c01043f6 <check_content_set+0x3c>
c01043d2:	c7 44 24 0c ae 9a 10 	movl   $0xc0109aae,0xc(%esp)
c01043d9:	c0 
c01043da:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01043e1:	c0 
c01043e2:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c01043e9:	00 
c01043ea:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01043f1:	e8 02 c0 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01043f6:	b8 10 10 00 00       	mov    $0x1010,%eax
c01043fb:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01043fe:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104403:	83 f8 01             	cmp    $0x1,%eax
c0104406:	74 24                	je     c010442c <check_content_set+0x72>
c0104408:	c7 44 24 0c ae 9a 10 	movl   $0xc0109aae,0xc(%esp)
c010440f:	c0 
c0104410:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104417:	c0 
c0104418:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c010441f:	00 
c0104420:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104427:	e8 cc bf ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c010442c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104431:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104434:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104439:	83 f8 02             	cmp    $0x2,%eax
c010443c:	74 24                	je     c0104462 <check_content_set+0xa8>
c010443e:	c7 44 24 0c bd 9a 10 	movl   $0xc0109abd,0xc(%esp)
c0104445:	c0 
c0104446:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c010444d:	c0 
c010444e:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0104455:	00 
c0104456:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c010445d:	e8 96 bf ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104462:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104467:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010446a:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010446f:	83 f8 02             	cmp    $0x2,%eax
c0104472:	74 24                	je     c0104498 <check_content_set+0xde>
c0104474:	c7 44 24 0c bd 9a 10 	movl   $0xc0109abd,0xc(%esp)
c010447b:	c0 
c010447c:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104483:	c0 
c0104484:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c010448b:	00 
c010448c:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104493:	e8 60 bf ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0104498:	b8 00 30 00 00       	mov    $0x3000,%eax
c010449d:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01044a0:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01044a5:	83 f8 03             	cmp    $0x3,%eax
c01044a8:	74 24                	je     c01044ce <check_content_set+0x114>
c01044aa:	c7 44 24 0c cc 9a 10 	movl   $0xc0109acc,0xc(%esp)
c01044b1:	c0 
c01044b2:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01044b9:	c0 
c01044ba:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01044c1:	00 
c01044c2:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01044c9:	e8 2a bf ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01044ce:	b8 10 30 00 00       	mov    $0x3010,%eax
c01044d3:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01044d6:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01044db:	83 f8 03             	cmp    $0x3,%eax
c01044de:	74 24                	je     c0104504 <check_content_set+0x14a>
c01044e0:	c7 44 24 0c cc 9a 10 	movl   $0xc0109acc,0xc(%esp)
c01044e7:	c0 
c01044e8:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01044ef:	c0 
c01044f0:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01044f7:	00 
c01044f8:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01044ff:	e8 f4 be ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104504:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104509:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010450c:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104511:	83 f8 04             	cmp    $0x4,%eax
c0104514:	74 24                	je     c010453a <check_content_set+0x180>
c0104516:	c7 44 24 0c db 9a 10 	movl   $0xc0109adb,0xc(%esp)
c010451d:	c0 
c010451e:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104525:	c0 
c0104526:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010452d:	00 
c010452e:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104535:	e8 be be ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010453a:	b8 10 40 00 00       	mov    $0x4010,%eax
c010453f:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104542:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104547:	83 f8 04             	cmp    $0x4,%eax
c010454a:	74 24                	je     c0104570 <check_content_set+0x1b6>
c010454c:	c7 44 24 0c db 9a 10 	movl   $0xc0109adb,0xc(%esp)
c0104553:	c0 
c0104554:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c010455b:	c0 
c010455c:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0104563:	00 
c0104564:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c010456b:	e8 88 be ff ff       	call   c01003f8 <__panic>
}
c0104570:	90                   	nop
c0104571:	c9                   	leave  
c0104572:	c3                   	ret    

c0104573 <check_content_access>:

static inline int
check_content_access(void)
{
c0104573:	55                   	push   %ebp
c0104574:	89 e5                	mov    %esp,%ebp
c0104576:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104579:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010457e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104581:	ff d0                	call   *%eax
c0104583:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104589:	c9                   	leave  
c010458a:	c3                   	ret    

c010458b <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010458b:	55                   	push   %ebp
c010458c:	89 e5                	mov    %esp,%ebp
c010458e:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104591:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104598:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010459f:	c7 45 e8 ec 40 12 c0 	movl   $0xc01240ec,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01045a6:	eb 6a                	jmp    c0104612 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c01045a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045ab:	83 e8 0c             	sub    $0xc,%eax
c01045ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c01045b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045b4:	83 c0 04             	add    $0x4,%eax
c01045b7:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01045be:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045c1:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01045c4:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01045c7:	0f a3 10             	bt     %edx,(%eax)
c01045ca:	19 c0                	sbb    %eax,%eax
c01045cc:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c01045cf:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c01045d3:	0f 95 c0             	setne  %al
c01045d6:	0f b6 c0             	movzbl %al,%eax
c01045d9:	85 c0                	test   %eax,%eax
c01045db:	75 24                	jne    c0104601 <check_swap+0x76>
c01045dd:	c7 44 24 0c ea 9a 10 	movl   $0xc0109aea,0xc(%esp)
c01045e4:	c0 
c01045e5:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01045ec:	c0 
c01045ed:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01045f4:	00 
c01045f5:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01045fc:	e8 f7 bd ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c0104601:	ff 45 f4             	incl   -0xc(%ebp)
c0104604:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104607:	8b 50 08             	mov    0x8(%eax),%edx
c010460a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010460d:	01 d0                	add    %edx,%eax
c010460f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104612:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104615:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104618:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010461b:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010461e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104621:	81 7d e8 ec 40 12 c0 	cmpl   $0xc01240ec,-0x18(%ebp)
c0104628:	0f 85 7a ff ff ff    	jne    c01045a8 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c010462e:	e8 de 1f 00 00       	call   c0106611 <nr_free_pages>
c0104633:	89 c2                	mov    %eax,%edx
c0104635:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104638:	39 c2                	cmp    %eax,%edx
c010463a:	74 24                	je     c0104660 <check_swap+0xd5>
c010463c:	c7 44 24 0c fa 9a 10 	movl   $0xc0109afa,0xc(%esp)
c0104643:	c0 
c0104644:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c010464b:	c0 
c010464c:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0104653:	00 
c0104654:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c010465b:	e8 98 bd ff ff       	call   c01003f8 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104660:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104663:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010466e:	c7 04 24 14 9b 10 c0 	movl   $0xc0109b14,(%esp)
c0104675:	e8 27 bc ff ff       	call   c01002a1 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c010467a:	e8 29 ec ff ff       	call   c01032a8 <mm_create>
c010467f:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c0104682:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104686:	75 24                	jne    c01046ac <check_swap+0x121>
c0104688:	c7 44 24 0c 3a 9b 10 	movl   $0xc0109b3a,0xc(%esp)
c010468f:	c0 
c0104690:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104697:	c0 
c0104698:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010469f:	00 
c01046a0:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01046a7:	e8 4c bd ff ff       	call   c01003f8 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01046ac:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01046b1:	85 c0                	test   %eax,%eax
c01046b3:	74 24                	je     c01046d9 <check_swap+0x14e>
c01046b5:	c7 44 24 0c 45 9b 10 	movl   $0xc0109b45,0xc(%esp)
c01046bc:	c0 
c01046bd:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01046c4:	c0 
c01046c5:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01046cc:	00 
c01046cd:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01046d4:	e8 1f bd ff ff       	call   c01003f8 <__panic>

     check_mm_struct = mm;
c01046d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046dc:	a3 10 40 12 c0       	mov    %eax,0xc0124010

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c01046e1:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c01046e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046ea:	89 50 0c             	mov    %edx,0xc(%eax)
c01046ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046f0:	8b 40 0c             	mov    0xc(%eax),%eax
c01046f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c01046f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046f9:	8b 00                	mov    (%eax),%eax
c01046fb:	85 c0                	test   %eax,%eax
c01046fd:	74 24                	je     c0104723 <check_swap+0x198>
c01046ff:	c7 44 24 0c 5d 9b 10 	movl   $0xc0109b5d,0xc(%esp)
c0104706:	c0 
c0104707:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c010470e:	c0 
c010470f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0104716:	00 
c0104717:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c010471e:	e8 d5 bc ff ff       	call   c01003f8 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0104723:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c010472a:	00 
c010472b:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0104732:	00 
c0104733:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c010473a:	e8 e1 eb ff ff       	call   c0103320 <vma_create>
c010473f:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c0104742:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0104746:	75 24                	jne    c010476c <check_swap+0x1e1>
c0104748:	c7 44 24 0c 6b 9b 10 	movl   $0xc0109b6b,0xc(%esp)
c010474f:	c0 
c0104750:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104757:	c0 
c0104758:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010475f:	00 
c0104760:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104767:	e8 8c bc ff ff       	call   c01003f8 <__panic>

     insert_vma_struct(mm, vma);
c010476c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010476f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104773:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104776:	89 04 24             	mov    %eax,(%esp)
c0104779:	e8 33 ed ff ff       	call   c01034b1 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010477e:	c7 04 24 78 9b 10 c0 	movl   $0xc0109b78,(%esp)
c0104785:	e8 17 bb ff ff       	call   c01002a1 <cprintf>
     pte_t *temp_ptep=NULL;
c010478a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104791:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104794:	8b 40 0c             	mov    0xc(%eax),%eax
c0104797:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010479e:	00 
c010479f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01047a6:	00 
c01047a7:	89 04 24             	mov    %eax,(%esp)
c01047aa:	e8 91 24 00 00       	call   c0106c40 <get_pte>
c01047af:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c01047b2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01047b6:	75 24                	jne    c01047dc <check_swap+0x251>
c01047b8:	c7 44 24 0c ac 9b 10 	movl   $0xc0109bac,0xc(%esp)
c01047bf:	c0 
c01047c0:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01047c7:	c0 
c01047c8:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01047cf:	00 
c01047d0:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01047d7:	e8 1c bc ff ff       	call   c01003f8 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01047dc:	c7 04 24 c0 9b 10 c0 	movl   $0xc0109bc0,(%esp)
c01047e3:	e8 b9 ba ff ff       	call   c01002a1 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01047e8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01047ef:	e9 a4 00 00 00       	jmp    c0104898 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c01047f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047fb:	e8 73 1d 00 00       	call   c0106573 <alloc_pages>
c0104800:	89 c2                	mov    %eax,%edx
c0104802:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104805:	89 14 85 20 40 12 c0 	mov    %edx,-0x3fedbfe0(,%eax,4)
          assert(check_rp[i] != NULL );
c010480c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010480f:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104816:	85 c0                	test   %eax,%eax
c0104818:	75 24                	jne    c010483e <check_swap+0x2b3>
c010481a:	c7 44 24 0c e4 9b 10 	movl   $0xc0109be4,0xc(%esp)
c0104821:	c0 
c0104822:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104829:	c0 
c010482a:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0104831:	00 
c0104832:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104839:	e8 ba bb ff ff       	call   c01003f8 <__panic>
          assert(!PageProperty(check_rp[i]));
c010483e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104841:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104848:	83 c0 04             	add    $0x4,%eax
c010484b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0104852:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104855:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104858:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010485b:	0f a3 10             	bt     %edx,(%eax)
c010485e:	19 c0                	sbb    %eax,%eax
c0104860:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104863:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104867:	0f 95 c0             	setne  %al
c010486a:	0f b6 c0             	movzbl %al,%eax
c010486d:	85 c0                	test   %eax,%eax
c010486f:	74 24                	je     c0104895 <check_swap+0x30a>
c0104871:	c7 44 24 0c f8 9b 10 	movl   $0xc0109bf8,0xc(%esp)
c0104878:	c0 
c0104879:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104880:	c0 
c0104881:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0104888:	00 
c0104889:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104890:	e8 63 bb ff ff       	call   c01003f8 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104895:	ff 45 ec             	incl   -0x14(%ebp)
c0104898:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010489c:	0f 8e 52 ff ff ff    	jle    c01047f4 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01048a2:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c01048a7:	8b 15 f0 40 12 c0    	mov    0xc01240f0,%edx
c01048ad:	89 45 98             	mov    %eax,-0x68(%ebp)
c01048b0:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01048b3:	c7 45 c0 ec 40 12 c0 	movl   $0xc01240ec,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01048ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01048bd:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01048c0:	89 50 04             	mov    %edx,0x4(%eax)
c01048c3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01048c6:	8b 50 04             	mov    0x4(%eax),%edx
c01048c9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01048cc:	89 10                	mov    %edx,(%eax)
c01048ce:	c7 45 c8 ec 40 12 c0 	movl   $0xc01240ec,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01048d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01048d8:	8b 40 04             	mov    0x4(%eax),%eax
c01048db:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c01048de:	0f 94 c0             	sete   %al
c01048e1:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01048e4:	85 c0                	test   %eax,%eax
c01048e6:	75 24                	jne    c010490c <check_swap+0x381>
c01048e8:	c7 44 24 0c 13 9c 10 	movl   $0xc0109c13,0xc(%esp)
c01048ef:	c0 
c01048f0:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01048f7:	c0 
c01048f8:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01048ff:	00 
c0104900:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104907:	e8 ec ba ff ff       	call   c01003f8 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010490c:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0104911:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0104914:	c7 05 f4 40 12 c0 00 	movl   $0x0,0xc01240f4
c010491b:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010491e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104925:	eb 1d                	jmp    c0104944 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0104927:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010492a:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104931:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104938:	00 
c0104939:	89 04 24             	mov    %eax,(%esp)
c010493c:	e8 9d 1c 00 00       	call   c01065de <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104941:	ff 45 ec             	incl   -0x14(%ebp)
c0104944:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104948:	7e dd                	jle    c0104927 <check_swap+0x39c>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010494a:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c010494f:	83 f8 04             	cmp    $0x4,%eax
c0104952:	74 24                	je     c0104978 <check_swap+0x3ed>
c0104954:	c7 44 24 0c 2c 9c 10 	movl   $0xc0109c2c,0xc(%esp)
c010495b:	c0 
c010495c:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104963:	c0 
c0104964:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010496b:	00 
c010496c:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104973:	e8 80 ba ff ff       	call   c01003f8 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0104978:	c7 04 24 50 9c 10 c0 	movl   $0xc0109c50,(%esp)
c010497f:	e8 1d b9 ff ff       	call   c01002a1 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0104984:	c7 05 64 3f 12 c0 00 	movl   $0x0,0xc0123f64
c010498b:	00 00 00 
     
     check_content_set();
c010498e:	e8 27 fa ff ff       	call   c01043ba <check_content_set>
     assert( nr_free == 0);         
c0104993:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0104998:	85 c0                	test   %eax,%eax
c010499a:	74 24                	je     c01049c0 <check_swap+0x435>
c010499c:	c7 44 24 0c 77 9c 10 	movl   $0xc0109c77,0xc(%esp)
c01049a3:	c0 
c01049a4:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c01049ab:	c0 
c01049ac:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01049b3:	00 
c01049b4:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c01049bb:	e8 38 ba ff ff       	call   c01003f8 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01049c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01049c7:	eb 25                	jmp    c01049ee <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01049c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049cc:	c7 04 85 40 40 12 c0 	movl   $0xffffffff,-0x3fedbfc0(,%eax,4)
c01049d3:	ff ff ff ff 
c01049d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049da:	8b 14 85 40 40 12 c0 	mov    -0x3fedbfc0(,%eax,4),%edx
c01049e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049e4:	89 14 85 80 40 12 c0 	mov    %edx,-0x3fedbf80(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01049eb:	ff 45 ec             	incl   -0x14(%ebp)
c01049ee:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01049f2:	7e d5                	jle    c01049c9 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01049f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01049fb:	e9 ec 00 00 00       	jmp    c0104aec <check_swap+0x561>
         check_ptep[i]=0;
c0104a00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a03:	c7 04 85 d4 40 12 c0 	movl   $0x0,-0x3fedbf2c(,%eax,4)
c0104a0a:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0104a0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a11:	40                   	inc    %eax
c0104a12:	c1 e0 0c             	shl    $0xc,%eax
c0104a15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a1c:	00 
c0104a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104a24:	89 04 24             	mov    %eax,(%esp)
c0104a27:	e8 14 22 00 00       	call   c0106c40 <get_pte>
c0104a2c:	89 c2                	mov    %eax,%edx
c0104a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a31:	89 14 85 d4 40 12 c0 	mov    %edx,-0x3fedbf2c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0104a38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a3b:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104a42:	85 c0                	test   %eax,%eax
c0104a44:	75 24                	jne    c0104a6a <check_swap+0x4df>
c0104a46:	c7 44 24 0c 84 9c 10 	movl   $0xc0109c84,0xc(%esp)
c0104a4d:	c0 
c0104a4e:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104a55:	c0 
c0104a56:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104a5d:	00 
c0104a5e:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104a65:	e8 8e b9 ff ff       	call   c01003f8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0104a6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a6d:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104a74:	8b 00                	mov    (%eax),%eax
c0104a76:	89 04 24             	mov    %eax,(%esp)
c0104a79:	e8 a6 f5 ff ff       	call   c0104024 <pte2page>
c0104a7e:	89 c2                	mov    %eax,%edx
c0104a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a83:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104a8a:	39 c2                	cmp    %eax,%edx
c0104a8c:	74 24                	je     c0104ab2 <check_swap+0x527>
c0104a8e:	c7 44 24 0c 9c 9c 10 	movl   $0xc0109c9c,0xc(%esp)
c0104a95:	c0 
c0104a96:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104a9d:	c0 
c0104a9e:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0104aa5:	00 
c0104aa6:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104aad:	e8 46 b9 ff ff       	call   c01003f8 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0104ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ab5:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104abc:	8b 00                	mov    (%eax),%eax
c0104abe:	83 e0 01             	and    $0x1,%eax
c0104ac1:	85 c0                	test   %eax,%eax
c0104ac3:	75 24                	jne    c0104ae9 <check_swap+0x55e>
c0104ac5:	c7 44 24 0c c4 9c 10 	movl   $0xc0109cc4,0xc(%esp)
c0104acc:	c0 
c0104acd:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104ad4:	c0 
c0104ad5:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104adc:	00 
c0104add:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104ae4:	e8 0f b9 ff ff       	call   c01003f8 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104ae9:	ff 45 ec             	incl   -0x14(%ebp)
c0104aec:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104af0:	0f 8e 0a ff ff ff    	jle    c0104a00 <check_swap+0x475>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0104af6:	c7 04 24 e0 9c 10 c0 	movl   $0xc0109ce0,(%esp)
c0104afd:	e8 9f b7 ff ff       	call   c01002a1 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0104b02:	e8 6c fa ff ff       	call   c0104573 <check_content_access>
c0104b07:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c0104b0a:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104b0e:	74 24                	je     c0104b34 <check_swap+0x5a9>
c0104b10:	c7 44 24 0c 06 9d 10 	movl   $0xc0109d06,0xc(%esp)
c0104b17:	c0 
c0104b18:	c7 44 24 08 ee 99 10 	movl   $0xc01099ee,0x8(%esp)
c0104b1f:	c0 
c0104b20:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0104b27:	00 
c0104b28:	c7 04 24 88 99 10 c0 	movl   $0xc0109988,(%esp)
c0104b2f:	e8 c4 b8 ff ff       	call   c01003f8 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104b34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104b3b:	eb 1d                	jmp    c0104b5a <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c0104b3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b40:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104b47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b4e:	00 
c0104b4f:	89 04 24             	mov    %eax,(%esp)
c0104b52:	e8 87 1a 00 00       	call   c01065de <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104b57:	ff 45 ec             	incl   -0x14(%ebp)
c0104b5a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104b5e:	7e dd                	jle    c0104b3d <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0104b60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104b63:	89 04 24             	mov    %eax,(%esp)
c0104b66:	e8 78 ea ff ff       	call   c01035e3 <mm_destroy>
         
     nr_free = nr_free_store;
c0104b6b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b6e:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
     free_list = free_list_store;
c0104b73:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b76:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b79:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
c0104b7e:	89 15 f0 40 12 c0    	mov    %edx,0xc01240f0

     
     le = &free_list;
c0104b84:	c7 45 e8 ec 40 12 c0 	movl   $0xc01240ec,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104b8b:	eb 1c                	jmp    c0104ba9 <check_swap+0x61e>
         struct Page *p = le2page(le, page_link);
c0104b8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b90:	83 e8 0c             	sub    $0xc,%eax
c0104b93:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0104b96:	ff 4d f4             	decl   -0xc(%ebp)
c0104b99:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b9c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104b9f:	8b 40 08             	mov    0x8(%eax),%eax
c0104ba2:	29 c2                	sub    %eax,%edx
c0104ba4:	89 d0                	mov    %edx,%eax
c0104ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ba9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104baf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104bb2:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0104bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104bb8:	81 7d e8 ec 40 12 c0 	cmpl   $0xc01240ec,-0x18(%ebp)
c0104bbf:	75 cc                	jne    c0104b8d <check_swap+0x602>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0104bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104bcf:	c7 04 24 0d 9d 10 c0 	movl   $0xc0109d0d,(%esp)
c0104bd6:	e8 c6 b6 ff ff       	call   c01002a1 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0104bdb:	c7 04 24 27 9d 10 c0 	movl   $0xc0109d27,(%esp)
c0104be2:	e8 ba b6 ff ff       	call   c01002a1 <cprintf>
}
c0104be7:	90                   	nop
c0104be8:	c9                   	leave  
c0104be9:	c3                   	ret    

c0104bea <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0104bea:	55                   	push   %ebp
c0104beb:	89 e5                	mov    %esp,%ebp
c0104bed:	83 ec 10             	sub    $0x10,%esp
c0104bf0:	c7 45 fc e4 40 12 c0 	movl   $0xc01240e4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104bfa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104bfd:	89 50 04             	mov    %edx,0x4(%eax)
c0104c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104c03:	8b 50 04             	mov    0x4(%eax),%edx
c0104c06:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104c09:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0104c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c0e:	c7 40 14 e4 40 12 c0 	movl   $0xc01240e4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0104c15:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104c1a:	c9                   	leave  
c0104c1b:	c3                   	ret    

c0104c1c <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104c1c:	55                   	push   %ebp
c0104c1d:	89 e5                	mov    %esp,%ebp
c0104c1f:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0104c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c25:	8b 40 14             	mov    0x14(%eax),%eax
c0104c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0104c2b:	8b 45 10             	mov    0x10(%ebp),%eax
c0104c2e:	83 c0 14             	add    $0x14,%eax
c0104c31:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0104c34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c38:	74 06                	je     c0104c40 <_fifo_map_swappable+0x24>
c0104c3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c3e:	75 24                	jne    c0104c64 <_fifo_map_swappable+0x48>
c0104c40:	c7 44 24 0c 40 9d 10 	movl   $0xc0109d40,0xc(%esp)
c0104c47:	c0 
c0104c48:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104c4f:	c0 
c0104c50:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0104c57:	00 
c0104c58:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104c5f:	e8 94 b7 ff ff       	call   c01003f8 <__panic>
c0104c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c67:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0104c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c7f:	8b 40 04             	mov    0x4(%eax),%eax
c0104c82:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104c85:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104c88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104c8b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104c8e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104c91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c94:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c97:	89 10                	mov    %edx,(%eax)
c0104c99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c9c:	8b 10                	mov    (%eax),%edx
c0104c9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ca1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104ca4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104ca7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104caa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104cad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104cb0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104cb3:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0104cb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cba:	c9                   	leave  
c0104cbb:	c3                   	ret    

c0104cbc <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0104cbc:	55                   	push   %ebp
c0104cbd:	89 e5                	mov    %esp,%ebp
c0104cbf:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cc5:	8b 40 14             	mov    0x14(%eax),%eax
c0104cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0104ccb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ccf:	75 24                	jne    c0104cf5 <_fifo_swap_out_victim+0x39>
c0104cd1:	c7 44 24 0c 87 9d 10 	movl   $0xc0109d87,0xc(%esp)
c0104cd8:	c0 
c0104cd9:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104ce0:	c0 
c0104ce1:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0104ce8:	00 
c0104ce9:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104cf0:	e8 03 b7 ff ff       	call   c01003f8 <__panic>
     assert(in_tick==0);
c0104cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104cf9:	74 24                	je     c0104d1f <_fifo_swap_out_victim+0x63>
c0104cfb:	c7 44 24 0c 94 9d 10 	movl   $0xc0109d94,0xc(%esp)
c0104d02:	c0 
c0104d03:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104d0a:	c0 
c0104d0b:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0104d12:	00 
c0104d13:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104d1a:	e8 d9 b6 ff ff       	call   c01003f8 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le = head->prev;
c0104d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d22:	8b 00                	mov    (%eax),%eax
c0104d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d2a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104d2d:	75 24                	jne    c0104d53 <_fifo_swap_out_victim+0x97>
c0104d2f:	c7 44 24 0c 9f 9d 10 	movl   $0xc0109d9f,0xc(%esp)
c0104d36:	c0 
c0104d37:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104d3e:	c0 
c0104d3f:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0104d46:	00 
c0104d47:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104d4e:	e8 a5 b6 ff ff       	call   c01003f8 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0104d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d56:	83 e8 14             	sub    $0x14,%eax
c0104d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104d62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d65:	8b 40 04             	mov    0x4(%eax),%eax
c0104d68:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104d6b:	8b 12                	mov    (%edx),%edx
c0104d6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0104d70:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d76:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104d79:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104d7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104d82:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0104d84:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d88:	75 24                	jne    c0104dae <_fifo_swap_out_victim+0xf2>
c0104d8a:	c7 44 24 0c a8 9d 10 	movl   $0xc0109da8,0xc(%esp)
c0104d91:	c0 
c0104d92:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104d99:	c0 
c0104d9a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0104da1:	00 
c0104da2:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104da9:	e8 4a b6 ff ff       	call   c01003f8 <__panic>
     *ptr_page = p;
c0104dae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104db1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104db4:	89 10                	mov    %edx,(%eax)
     return 0;
c0104db6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104dbb:	c9                   	leave  
c0104dbc:	c3                   	ret    

c0104dbd <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104dbd:	55                   	push   %ebp
c0104dbe:	89 e5                	mov    %esp,%ebp
c0104dc0:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104dc3:	c7 04 24 b4 9d 10 c0 	movl   $0xc0109db4,(%esp)
c0104dca:	e8 d2 b4 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104dcf:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104dd4:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0104dd7:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104ddc:	83 f8 04             	cmp    $0x4,%eax
c0104ddf:	74 24                	je     c0104e05 <_fifo_check_swap+0x48>
c0104de1:	c7 44 24 0c da 9d 10 	movl   $0xc0109dda,0xc(%esp)
c0104de8:	c0 
c0104de9:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104df0:	c0 
c0104df1:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0104df8:	00 
c0104df9:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104e00:	e8 f3 b5 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104e05:	c7 04 24 ec 9d 10 c0 	movl   $0xc0109dec,(%esp)
c0104e0c:	e8 90 b4 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104e11:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104e16:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0104e19:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104e1e:	83 f8 04             	cmp    $0x4,%eax
c0104e21:	74 24                	je     c0104e47 <_fifo_check_swap+0x8a>
c0104e23:	c7 44 24 0c da 9d 10 	movl   $0xc0109dda,0xc(%esp)
c0104e2a:	c0 
c0104e2b:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104e32:	c0 
c0104e33:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0104e3a:	00 
c0104e3b:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104e42:	e8 b1 b5 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104e47:	c7 04 24 14 9e 10 c0 	movl   $0xc0109e14,(%esp)
c0104e4e:	e8 4e b4 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104e53:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104e58:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104e5b:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104e60:	83 f8 04             	cmp    $0x4,%eax
c0104e63:	74 24                	je     c0104e89 <_fifo_check_swap+0xcc>
c0104e65:	c7 44 24 0c da 9d 10 	movl   $0xc0109dda,0xc(%esp)
c0104e6c:	c0 
c0104e6d:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104e74:	c0 
c0104e75:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0104e7c:	00 
c0104e7d:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104e84:	e8 6f b5 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104e89:	c7 04 24 3c 9e 10 c0 	movl   $0xc0109e3c,(%esp)
c0104e90:	e8 0c b4 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104e95:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104e9a:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0104e9d:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104ea2:	83 f8 04             	cmp    $0x4,%eax
c0104ea5:	74 24                	je     c0104ecb <_fifo_check_swap+0x10e>
c0104ea7:	c7 44 24 0c da 9d 10 	movl   $0xc0109dda,0xc(%esp)
c0104eae:	c0 
c0104eaf:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104eb6:	c0 
c0104eb7:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c0104ebe:	00 
c0104ebf:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104ec6:	e8 2d b5 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104ecb:	c7 04 24 64 9e 10 c0 	movl   $0xc0109e64,(%esp)
c0104ed2:	e8 ca b3 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104ed7:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104edc:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104edf:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104ee4:	83 f8 05             	cmp    $0x5,%eax
c0104ee7:	74 24                	je     c0104f0d <_fifo_check_swap+0x150>
c0104ee9:	c7 44 24 0c 8a 9e 10 	movl   $0xc0109e8a,0xc(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104ef8:	c0 
c0104ef9:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0104f00:	00 
c0104f01:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104f08:	e8 eb b4 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104f0d:	c7 04 24 3c 9e 10 c0 	movl   $0xc0109e3c,(%esp)
c0104f14:	e8 88 b3 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104f19:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104f1e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104f21:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104f26:	83 f8 05             	cmp    $0x5,%eax
c0104f29:	74 24                	je     c0104f4f <_fifo_check_swap+0x192>
c0104f2b:	c7 44 24 0c 8a 9e 10 	movl   $0xc0109e8a,0xc(%esp)
c0104f32:	c0 
c0104f33:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104f3a:	c0 
c0104f3b:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0104f42:	00 
c0104f43:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104f4a:	e8 a9 b4 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104f4f:	c7 04 24 ec 9d 10 c0 	movl   $0xc0109dec,(%esp)
c0104f56:	e8 46 b3 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104f5b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104f60:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104f63:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104f68:	83 f8 06             	cmp    $0x6,%eax
c0104f6b:	74 24                	je     c0104f91 <_fifo_check_swap+0x1d4>
c0104f6d:	c7 44 24 0c 99 9e 10 	movl   $0xc0109e99,0xc(%esp)
c0104f74:	c0 
c0104f75:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104f7c:	c0 
c0104f7d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104f84:	00 
c0104f85:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104f8c:	e8 67 b4 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104f91:	c7 04 24 3c 9e 10 c0 	movl   $0xc0109e3c,(%esp)
c0104f98:	e8 04 b3 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104f9d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104fa2:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0104fa5:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104faa:	83 f8 07             	cmp    $0x7,%eax
c0104fad:	74 24                	je     c0104fd3 <_fifo_check_swap+0x216>
c0104faf:	c7 44 24 0c a8 9e 10 	movl   $0xc0109ea8,0xc(%esp)
c0104fb6:	c0 
c0104fb7:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0104fbe:	c0 
c0104fbf:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0104fc6:	00 
c0104fc7:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0104fce:	e8 25 b4 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104fd3:	c7 04 24 b4 9d 10 c0 	movl   $0xc0109db4,(%esp)
c0104fda:	e8 c2 b2 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104fdf:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104fe4:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104fe7:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104fec:	83 f8 08             	cmp    $0x8,%eax
c0104fef:	74 24                	je     c0105015 <_fifo_check_swap+0x258>
c0104ff1:	c7 44 24 0c b7 9e 10 	movl   $0xc0109eb7,0xc(%esp)
c0104ff8:	c0 
c0104ff9:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0105000:	c0 
c0105001:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0105008:	00 
c0105009:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0105010:	e8 e3 b3 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105015:	c7 04 24 14 9e 10 c0 	movl   $0xc0109e14,(%esp)
c010501c:	e8 80 b2 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0105021:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105026:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0105029:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010502e:	83 f8 09             	cmp    $0x9,%eax
c0105031:	74 24                	je     c0105057 <_fifo_check_swap+0x29a>
c0105033:	c7 44 24 0c c6 9e 10 	movl   $0xc0109ec6,0xc(%esp)
c010503a:	c0 
c010503b:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0105042:	c0 
c0105043:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c010504a:	00 
c010504b:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0105052:	e8 a1 b3 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105057:	c7 04 24 64 9e 10 c0 	movl   $0xc0109e64,(%esp)
c010505e:	e8 3e b2 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0105063:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105068:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010506b:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0105070:	83 f8 0a             	cmp    $0xa,%eax
c0105073:	74 24                	je     c0105099 <_fifo_check_swap+0x2dc>
c0105075:	c7 44 24 0c d5 9e 10 	movl   $0xc0109ed5,0xc(%esp)
c010507c:	c0 
c010507d:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c0105084:	c0 
c0105085:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010508c:	00 
c010508d:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0105094:	e8 5f b3 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105099:	c7 04 24 ec 9d 10 c0 	movl   $0xc0109dec,(%esp)
c01050a0:	e8 fc b1 ff ff       	call   c01002a1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01050a5:	b8 00 10 00 00       	mov    $0x1000,%eax
c01050aa:	0f b6 00             	movzbl (%eax),%eax
c01050ad:	3c 0a                	cmp    $0xa,%al
c01050af:	74 24                	je     c01050d5 <_fifo_check_swap+0x318>
c01050b1:	c7 44 24 0c e8 9e 10 	movl   $0xc0109ee8,0xc(%esp)
c01050b8:	c0 
c01050b9:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c01050c0:	c0 
c01050c1:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01050c8:	00 
c01050c9:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c01050d0:	e8 23 b3 ff ff       	call   c01003f8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01050d5:	b8 00 10 00 00       	mov    $0x1000,%eax
c01050da:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01050dd:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01050e2:	83 f8 0b             	cmp    $0xb,%eax
c01050e5:	74 24                	je     c010510b <_fifo_check_swap+0x34e>
c01050e7:	c7 44 24 0c 09 9f 10 	movl   $0xc0109f09,0xc(%esp)
c01050ee:	c0 
c01050ef:	c7 44 24 08 5e 9d 10 	movl   $0xc0109d5e,0x8(%esp)
c01050f6:	c0 
c01050f7:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c01050fe:	00 
c01050ff:	c7 04 24 73 9d 10 c0 	movl   $0xc0109d73,(%esp)
c0105106:	e8 ed b2 ff ff       	call   c01003f8 <__panic>
    return 0;
c010510b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105110:	c9                   	leave  
c0105111:	c3                   	ret    

c0105112 <_fifo_init>:


static int
_fifo_init(void)
{
c0105112:	55                   	push   %ebp
c0105113:	89 e5                	mov    %esp,%ebp
    return 0;
c0105115:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010511a:	5d                   	pop    %ebp
c010511b:	c3                   	ret    

c010511c <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010511c:	55                   	push   %ebp
c010511d:	89 e5                	mov    %esp,%ebp
    return 0;
c010511f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105124:	5d                   	pop    %ebp
c0105125:	c3                   	ret    

c0105126 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0105126:	55                   	push   %ebp
c0105127:	89 e5                	mov    %esp,%ebp
c0105129:	b8 00 00 00 00       	mov    $0x0,%eax
c010512e:	5d                   	pop    %ebp
c010512f:	c3                   	ret    

c0105130 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0105130:	55                   	push   %ebp
c0105131:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105133:	8b 45 08             	mov    0x8(%ebp),%eax
c0105136:	8b 15 00 41 12 c0    	mov    0xc0124100,%edx
c010513c:	29 d0                	sub    %edx,%eax
c010513e:	c1 f8 05             	sar    $0x5,%eax
}
c0105141:	5d                   	pop    %ebp
c0105142:	c3                   	ret    

c0105143 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105143:	55                   	push   %ebp
c0105144:	89 e5                	mov    %esp,%ebp
c0105146:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105149:	8b 45 08             	mov    0x8(%ebp),%eax
c010514c:	89 04 24             	mov    %eax,(%esp)
c010514f:	e8 dc ff ff ff       	call   c0105130 <page2ppn>
c0105154:	c1 e0 0c             	shl    $0xc,%eax
}
c0105157:	c9                   	leave  
c0105158:	c3                   	ret    

c0105159 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0105159:	55                   	push   %ebp
c010515a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010515c:	8b 45 08             	mov    0x8(%ebp),%eax
c010515f:	8b 00                	mov    (%eax),%eax
}
c0105161:	5d                   	pop    %ebp
c0105162:	c3                   	ret    

c0105163 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0105163:	55                   	push   %ebp
c0105164:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105166:	8b 45 08             	mov    0x8(%ebp),%eax
c0105169:	8b 55 0c             	mov    0xc(%ebp),%edx
c010516c:	89 10                	mov    %edx,(%eax)
}
c010516e:	90                   	nop
c010516f:	5d                   	pop    %ebp
c0105170:	c3                   	ret    

c0105171 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0105171:	55                   	push   %ebp
c0105172:	89 e5                	mov    %esp,%ebp
c0105174:	83 ec 10             	sub    $0x10,%esp
c0105177:	c7 45 fc ec 40 12 c0 	movl   $0xc01240ec,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010517e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105181:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105184:	89 50 04             	mov    %edx,0x4(%eax)
c0105187:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010518a:	8b 50 04             	mov    0x4(%eax),%edx
c010518d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105190:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0105192:	c7 05 f4 40 12 c0 00 	movl   $0x0,0xc01240f4
c0105199:	00 00 00 
}
c010519c:	90                   	nop
c010519d:	c9                   	leave  
c010519e:	c3                   	ret    

c010519f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010519f:	55                   	push   %ebp
c01051a0:	89 e5                	mov    %esp,%ebp
c01051a2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01051a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01051a9:	75 24                	jne    c01051cf <default_init_memmap+0x30>
c01051ab:	c7 44 24 0c 2c 9f 10 	movl   $0xc0109f2c,0xc(%esp)
c01051b2:	c0 
c01051b3:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01051ba:	c0 
c01051bb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01051c2:	00 
c01051c3:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01051ca:	e8 29 b2 ff ff       	call   c01003f8 <__panic>
    struct Page *p = base;
c01051cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01051d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01051d5:	e9 de 00 00 00       	jmp    c01052b8 <default_init_memmap+0x119>
        assert(PageReserved(p));
c01051da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051dd:	83 c0 04             	add    $0x4,%eax
c01051e0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01051e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01051ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01051f0:	0f a3 10             	bt     %edx,(%eax)
c01051f3:	19 c0                	sbb    %eax,%eax
c01051f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01051f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01051fc:	0f 95 c0             	setne  %al
c01051ff:	0f b6 c0             	movzbl %al,%eax
c0105202:	85 c0                	test   %eax,%eax
c0105204:	75 24                	jne    c010522a <default_init_memmap+0x8b>
c0105206:	c7 44 24 0c 5d 9f 10 	movl   $0xc0109f5d,0xc(%esp)
c010520d:	c0 
c010520e:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105215:	c0 
c0105216:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010521d:	00 
c010521e:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105225:	e8 ce b1 ff ff       	call   c01003f8 <__panic>
        p->flags = p->property = 0;
c010522a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010522d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0105234:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105237:	8b 50 08             	mov    0x8(%eax),%edx
c010523a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010523d:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);
c0105240:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105243:	83 c0 04             	add    $0x4,%eax
c0105246:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c010524d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105250:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105253:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105256:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
c0105259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105260:	00 
c0105261:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105264:	89 04 24             	mov    %eax,(%esp)
c0105267:	e8 f7 fe ff ff       	call   c0105163 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c010526c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010526f:	83 c0 0c             	add    $0xc,%eax
c0105272:	c7 45 f0 ec 40 12 c0 	movl   $0xc01240ec,-0x10(%ebp)
c0105279:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010527c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010527f:	8b 00                	mov    (%eax),%eax
c0105281:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105284:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105287:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010528a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010528d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105290:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105293:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105296:	89 10                	mov    %edx,(%eax)
c0105298:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010529b:	8b 10                	mov    (%eax),%edx
c010529d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01052a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01052a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01052a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01052ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01052af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052b2:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01052b4:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01052b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052bb:	c1 e0 05             	shl    $0x5,%eax
c01052be:	89 c2                	mov    %eax,%edx
c01052c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01052c3:	01 d0                	add    %edx,%eax
c01052c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01052c8:	0f 85 0c ff ff ff    	jne    c01051da <default_init_memmap+0x3b>
        p->flags = p->property = 0;
        SetPageProperty(p);
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
c01052ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01052d1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01052d4:	89 50 08             	mov    %edx,0x8(%eax)
    // SetPageProperty(base);
    // list_add_before(&free_list, &(p->page_link));
    nr_free += n;
c01052d7:	8b 15 f4 40 12 c0    	mov    0xc01240f4,%edx
c01052dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052e0:	01 d0                	add    %edx,%eax
c01052e2:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
    // list_add(&free_list, &(base->page_link));
}
c01052e7:	90                   	nop
c01052e8:	c9                   	leave  
c01052e9:	c3                   	ret    

c01052ea <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01052ea:	55                   	push   %ebp
c01052eb:	89 e5                	mov    %esp,%ebp
c01052ed:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01052f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01052f4:	75 24                	jne    c010531a <default_alloc_pages+0x30>
c01052f6:	c7 44 24 0c 2c 9f 10 	movl   $0xc0109f2c,0xc(%esp)
c01052fd:	c0 
c01052fe:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105305:	c0 
c0105306:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c010530d:	00 
c010530e:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105315:	e8 de b0 ff ff       	call   c01003f8 <__panic>
    if (n > nr_free)     return NULL;
c010531a:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c010531f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105322:	73 0a                	jae    c010532e <default_alloc_pages+0x44>
c0105324:	b8 00 00 00 00       	mov    $0x0,%eax
c0105329:	e9 04 01 00 00       	jmp    c0105432 <default_alloc_pages+0x148>
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
c010532e:	c7 45 f4 ec 40 12 c0 	movl   $0xc01240ec,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105335:	e9 d7 00 00 00       	jmp    c0105411 <default_alloc_pages+0x127>
        struct Page *p = le2page(le, page_link);
c010533a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010533d:	83 e8 0c             	sub    $0xc,%eax
c0105340:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0105343:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105346:	8b 40 08             	mov    0x8(%eax),%eax
c0105349:	3b 45 08             	cmp    0x8(%ebp),%eax
c010534c:	0f 82 bf 00 00 00    	jb     c0105411 <default_alloc_pages+0x127>
            list_entry_t *next;
            for(int i=0;i<n;i++)
c0105352:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105359:	eb 7b                	jmp    c01053d6 <default_alloc_pages+0xec>
            {
                struct Page *page = le2page(le, page_link);
c010535b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010535e:	83 e8 0c             	sub    $0xc,%eax
c0105361:	89 45 e8             	mov    %eax,-0x18(%ebp)
                SetPageReserved(page);
c0105364:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105367:	83 c0 04             	add    $0x4,%eax
c010536a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105371:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0105374:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105377:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010537a:	0f ab 10             	bts    %edx,(%eax)
                ClearPageProperty(page);
c010537d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105380:	83 c0 04             	add    $0x4,%eax
c0105383:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c010538a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010538d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105390:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105393:	0f b3 10             	btr    %edx,(%eax)
c0105396:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105399:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010539c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010539f:	8b 40 04             	mov    0x4(%eax),%eax
                next=list_next(le);
c01053a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01053a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01053ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053ae:	8b 40 04             	mov    0x4(%eax),%eax
c01053b1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01053b4:	8b 12                	mov    (%edx),%edx
c01053b6:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01053b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01053bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01053bf:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01053c2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01053c5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01053c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01053cb:	89 10                	mov    %edx,(%eax)
                list_del(le);
                le = next;
c01053cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            list_entry_t *next;
            for(int i=0;i<n;i++)
c01053d3:	ff 45 f0             	incl   -0x10(%ebp)
c01053d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d9:	3b 45 08             	cmp    0x8(%ebp),%eax
c01053dc:	0f 82 79 ff ff ff    	jb     c010535b <default_alloc_pages+0x71>
                ClearPageProperty(page);
                next=list_next(le);
                list_del(le);
                le = next;
            }
            if(p->property > n)
c01053e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053e5:	8b 40 08             	mov    0x8(%eax),%eax
c01053e8:	3b 45 08             	cmp    0x8(%ebp),%eax
c01053eb:	76 12                	jbe    c01053ff <default_alloc_pages+0x115>
                (le2page(le,page_link))->property = p->property - n;
c01053ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053f0:	8d 50 f4             	lea    -0xc(%eax),%edx
c01053f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053f6:	8b 40 08             	mov    0x8(%eax),%eax
c01053f9:	2b 45 08             	sub    0x8(%ebp),%eax
c01053fc:	89 42 08             	mov    %eax,0x8(%edx)
            nr_free -= n;
c01053ff:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0105404:	2b 45 08             	sub    0x8(%ebp),%eax
c0105407:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
            return p;
c010540c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010540f:	eb 21                	jmp    c0105432 <default_alloc_pages+0x148>
c0105411:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010541a:	8b 40 04             	mov    0x4(%eax),%eax
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free)     return NULL;
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010541d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105420:	81 7d f4 ec 40 12 c0 	cmpl   $0xc01240ec,-0xc(%ebp)
c0105427:	0f 85 0d ff ff ff    	jne    c010533a <default_alloc_pages+0x50>
      }
          list_del(&(page->page_link));
          nr_free -= n;
          ClearPageProperty(page);
      } */
    return NULL;
c010542d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105432:	c9                   	leave  
c0105433:	c3                   	ret    

c0105434 <default_free_pages>:
        le = list_next(le);
    } //insert,if the freeing block is before one free block
    list_add_before(le, &(base->page_link));//insert before le
}*/
static void
default_free_pages(struct Page *base, size_t n) {
c0105434:	55                   	push   %ebp
c0105435:	89 e5                	mov    %esp,%ebp
c0105437:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
c010543a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010543e:	75 24                	jne    c0105464 <default_free_pages+0x30>
c0105440:	c7 44 24 0c 2c 9f 10 	movl   $0xc0109f2c,0xc(%esp)
c0105447:	c0 
c0105448:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010544f:	c0 
c0105450:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0105457:	00 
c0105458:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c010545f:	e8 94 af ff ff       	call   c01003f8 <__panic>
    assert(PageReserved(base));
c0105464:	8b 45 08             	mov    0x8(%ebp),%eax
c0105467:	83 c0 04             	add    $0x4,%eax
c010546a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
c0105471:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105474:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105477:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010547a:	0f a3 10             	bt     %edx,(%eax)
c010547d:	19 c0                	sbb    %eax,%eax
c010547f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105482:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105486:	0f 95 c0             	setne  %al
c0105489:	0f b6 c0             	movzbl %al,%eax
c010548c:	85 c0                	test   %eax,%eax
c010548e:	75 24                	jne    c01054b4 <default_free_pages+0x80>
c0105490:	c7 44 24 0c 6d 9f 10 	movl   $0xc0109f6d,0xc(%esp)
c0105497:	c0 
c0105498:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010549f:	c0 
c01054a0:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01054a7:	00 
c01054a8:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01054af:	e8 44 af ff ff       	call   c01003f8 <__panic>

    list_entry_t *le = &free_list;
c01054b4:	c7 45 f4 ec 40 12 c0 	movl   $0xc01240ec,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01054bb:	eb 0b                	jmp    c01054c8 <default_free_pages+0x94>
        if ((le2page(le, page_link)) > base) {
c01054bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054c0:	83 e8 0c             	sub    $0xc,%eax
c01054c3:	3b 45 08             	cmp    0x8(%ebp),%eax
c01054c6:	77 1a                	ja     c01054e2 <default_free_pages+0xae>
c01054c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054d1:	8b 40 04             	mov    0x4(%eax),%eax
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01054d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054d7:	81 7d f4 ec 40 12 c0 	cmpl   $0xc01240ec,-0xc(%ebp)
c01054de:	75 dd                	jne    c01054bd <default_free_pages+0x89>
c01054e0:	eb 01                	jmp    c01054e3 <default_free_pages+0xaf>
        if ((le2page(le, page_link)) > base) {
            break;
c01054e2:	90                   	nop
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
c01054e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c01054ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054f2:	8b 00                	mov    (%eax),%eax
c01054f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    while ((last_head = list_prev(last_head)) != &free_list) {
c01054f7:	eb 0d                	jmp    c0105506 <default_free_pages+0xd2>
        if ((le2page(last_head, page_link))->property > 0) {
c01054f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054fc:	83 e8 0c             	sub    $0xc,%eax
c01054ff:	8b 40 08             	mov    0x8(%eax),%eax
c0105502:	85 c0                	test   %eax,%eax
c0105504:	75 19                	jne    c010551f <default_free_pages+0xeb>
c0105506:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105509:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010550c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010550f:	8b 00                	mov    (%eax),%eax
        if ((le2page(le, page_link)) > base) {
            break;
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
    while ((last_head = list_prev(last_head)) != &free_list) {
c0105511:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105514:	81 7d f0 ec 40 12 c0 	cmpl   $0xc01240ec,-0x10(%ebp)
c010551b:	75 dc                	jne    c01054f9 <default_free_pages+0xc5>
c010551d:	eb 01                	jmp    c0105520 <default_free_pages+0xec>
        if ((le2page(last_head, page_link))->property > 0) {
            break;
c010551f:	90                   	nop
        }
    }

    struct Page *p = base, *block_header;
c0105520:	8b 45 08             	mov    0x8(%ebp),%eax
c0105523:	89 45 ec             	mov    %eax,-0x14(%ebp)
    set_page_ref(base, 0);
c0105526:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010552d:	00 
c010552e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105531:	89 04 24             	mov    %eax,(%esp)
c0105534:	e8 2a fc ff ff       	call   c0105163 <set_page_ref>
    for (; p != base + n; ++p) {
c0105539:	e9 87 00 00 00       	jmp    c01055c5 <default_free_pages+0x191>
        ClearPageReserved(p);
c010553e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105541:	83 c0 04             	add    $0x4,%eax
c0105544:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c010554b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010554e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105551:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105554:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
c0105557:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010555a:	83 c0 04             	add    $0x4,%eax
c010555d:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105564:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105567:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010556a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010556d:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0105570:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105573:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(le, &(p->page_link));
c010557a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010557d:	8d 50 0c             	lea    0xc(%eax),%edx
c0105580:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105583:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105586:	89 55 b8             	mov    %edx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0105589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010558c:	8b 00                	mov    (%eax),%eax
c010558e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105591:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0105594:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105597:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010559a:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010559d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01055a0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01055a3:	89 10                	mov    %edx,(%eax)
c01055a5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01055a8:	8b 10                	mov    (%eax),%edx
c01055aa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01055ad:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01055b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01055b3:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01055b6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01055b9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01055bc:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01055bf:	89 10                	mov    %edx,(%eax)
        }
    }

    struct Page *p = base, *block_header;
    set_page_ref(base, 0);
    for (; p != base + n; ++p) {
c01055c1:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c01055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055c8:	c1 e0 05             	shl    $0x5,%eax
c01055cb:	89 c2                	mov    %eax,%edx
c01055cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d0:	01 d0                	add    %edx,%eax
c01055d2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01055d5:	0f 85 63 ff ff ff    	jne    c010553e <default_free_pages+0x10a>
        ClearPageReserved(p);
        SetPageProperty(p);
        p->property = 0;
        list_add_before(le, &(p->page_link));
    }
    if ((last_head == &free_list) || ((le2page(insert_prev, page_link)) != base - 1)) {
c01055db:	81 7d f0 ec 40 12 c0 	cmpl   $0xc01240ec,-0x10(%ebp)
c01055e2:	74 10                	je     c01055f4 <default_free_pages+0x1c0>
c01055e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01055e7:	8d 50 f4             	lea    -0xc(%eax),%edx
c01055ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ed:	83 e8 20             	sub    $0x20,%eax
c01055f0:	39 c2                	cmp    %eax,%edx
c01055f2:	74 11                	je     c0105605 <default_free_pages+0x1d1>
        base->property = n;
c01055f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055fa:	89 50 08             	mov    %edx,0x8(%eax)
        block_header = base;
c01055fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105600:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105603:	eb 1a                	jmp    c010561f <default_free_pages+0x1eb>
    } else {
        block_header = le2page(last_head, page_link);
c0105605:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105608:	83 e8 0c             	sub    $0xc,%eax
c010560b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        block_header->property += n;
c010560e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105611:	8b 50 08             	mov    0x8(%eax),%edx
c0105614:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105617:	01 c2                	add    %eax,%edx
c0105619:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010561c:	89 50 08             	mov    %edx,0x8(%eax)
    }
    struct Page *le_page = le2page(le, page_link);
c010561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105622:	83 e8 0c             	sub    $0xc,%eax
c0105625:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if ((le != &free_list) && (le_page == base + n)) {
c0105628:	81 7d f4 ec 40 12 c0 	cmpl   $0xc01240ec,-0xc(%ebp)
c010562f:	74 30                	je     c0105661 <default_free_pages+0x22d>
c0105631:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105634:	c1 e0 05             	shl    $0x5,%eax
c0105637:	89 c2                	mov    %eax,%edx
c0105639:	8b 45 08             	mov    0x8(%ebp),%eax
c010563c:	01 d0                	add    %edx,%eax
c010563e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105641:	75 1e                	jne    c0105661 <default_free_pages+0x22d>
        block_header->property += le_page->property;
c0105643:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105646:	8b 50 08             	mov    0x8(%eax),%edx
c0105649:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010564c:	8b 40 08             	mov    0x8(%eax),%eax
c010564f:	01 c2                	add    %eax,%edx
c0105651:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105654:	89 50 08             	mov    %edx,0x8(%eax)
        le_page->property = 0;
c0105657:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010565a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    nr_free += n;
c0105661:	8b 15 f4 40 12 c0    	mov    0xc01240f4,%edx
c0105667:	8b 45 0c             	mov    0xc(%ebp),%eax
c010566a:	01 d0                	add    %edx,%eax
c010566c:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
}
c0105671:	90                   	nop
c0105672:	c9                   	leave  
c0105673:	c3                   	ret    

c0105674 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105674:	55                   	push   %ebp
c0105675:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105677:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
}
c010567c:	5d                   	pop    %ebp
c010567d:	c3                   	ret    

c010567e <basic_check>:

static void
basic_check(void) {
c010567e:	55                   	push   %ebp
c010567f:	89 e5                	mov    %esp,%ebp
c0105681:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010568e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105691:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105694:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010569e:	e8 d0 0e 00 00       	call   c0106573 <alloc_pages>
c01056a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01056aa:	75 24                	jne    c01056d0 <basic_check+0x52>
c01056ac:	c7 44 24 0c 80 9f 10 	movl   $0xc0109f80,0xc(%esp)
c01056b3:	c0 
c01056b4:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01056bb:	c0 
c01056bc:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01056c3:	00 
c01056c4:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01056cb:	e8 28 ad ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01056d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01056d7:	e8 97 0e 00 00       	call   c0106573 <alloc_pages>
c01056dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056e3:	75 24                	jne    c0105709 <basic_check+0x8b>
c01056e5:	c7 44 24 0c 9c 9f 10 	movl   $0xc0109f9c,0xc(%esp)
c01056ec:	c0 
c01056ed:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01056f4:	c0 
c01056f5:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c01056fc:	00 
c01056fd:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105704:	e8 ef ac ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105709:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105710:	e8 5e 0e 00 00       	call   c0106573 <alloc_pages>
c0105715:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010571c:	75 24                	jne    c0105742 <basic_check+0xc4>
c010571e:	c7 44 24 0c b8 9f 10 	movl   $0xc0109fb8,0xc(%esp)
c0105725:	c0 
c0105726:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010572d:	c0 
c010572e:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0105735:	00 
c0105736:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c010573d:	e8 b6 ac ff ff       	call   c01003f8 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105742:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105745:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105748:	74 10                	je     c010575a <basic_check+0xdc>
c010574a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010574d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105750:	74 08                	je     c010575a <basic_check+0xdc>
c0105752:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105755:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105758:	75 24                	jne    c010577e <basic_check+0x100>
c010575a:	c7 44 24 0c d4 9f 10 	movl   $0xc0109fd4,0xc(%esp)
c0105761:	c0 
c0105762:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105769:	c0 
c010576a:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0105771:	00 
c0105772:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105779:	e8 7a ac ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010577e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105781:	89 04 24             	mov    %eax,(%esp)
c0105784:	e8 d0 f9 ff ff       	call   c0105159 <page_ref>
c0105789:	85 c0                	test   %eax,%eax
c010578b:	75 1e                	jne    c01057ab <basic_check+0x12d>
c010578d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105790:	89 04 24             	mov    %eax,(%esp)
c0105793:	e8 c1 f9 ff ff       	call   c0105159 <page_ref>
c0105798:	85 c0                	test   %eax,%eax
c010579a:	75 0f                	jne    c01057ab <basic_check+0x12d>
c010579c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010579f:	89 04 24             	mov    %eax,(%esp)
c01057a2:	e8 b2 f9 ff ff       	call   c0105159 <page_ref>
c01057a7:	85 c0                	test   %eax,%eax
c01057a9:	74 24                	je     c01057cf <basic_check+0x151>
c01057ab:	c7 44 24 0c f8 9f 10 	movl   $0xc0109ff8,0xc(%esp)
c01057b2:	c0 
c01057b3:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01057ba:	c0 
c01057bb:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01057c2:	00 
c01057c3:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01057ca:	e8 29 ac ff ff       	call   c01003f8 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01057cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057d2:	89 04 24             	mov    %eax,(%esp)
c01057d5:	e8 69 f9 ff ff       	call   c0105143 <page2pa>
c01057da:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c01057e0:	c1 e2 0c             	shl    $0xc,%edx
c01057e3:	39 d0                	cmp    %edx,%eax
c01057e5:	72 24                	jb     c010580b <basic_check+0x18d>
c01057e7:	c7 44 24 0c 34 a0 10 	movl   $0xc010a034,0xc(%esp)
c01057ee:	c0 
c01057ef:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01057f6:	c0 
c01057f7:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01057fe:	00 
c01057ff:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105806:	e8 ed ab ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010580e:	89 04 24             	mov    %eax,(%esp)
c0105811:	e8 2d f9 ff ff       	call   c0105143 <page2pa>
c0105816:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c010581c:	c1 e2 0c             	shl    $0xc,%edx
c010581f:	39 d0                	cmp    %edx,%eax
c0105821:	72 24                	jb     c0105847 <basic_check+0x1c9>
c0105823:	c7 44 24 0c 51 a0 10 	movl   $0xc010a051,0xc(%esp)
c010582a:	c0 
c010582b:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105832:	c0 
c0105833:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c010583a:	00 
c010583b:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105842:	e8 b1 ab ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010584a:	89 04 24             	mov    %eax,(%esp)
c010584d:	e8 f1 f8 ff ff       	call   c0105143 <page2pa>
c0105852:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c0105858:	c1 e2 0c             	shl    $0xc,%edx
c010585b:	39 d0                	cmp    %edx,%eax
c010585d:	72 24                	jb     c0105883 <basic_check+0x205>
c010585f:	c7 44 24 0c 6e a0 10 	movl   $0xc010a06e,0xc(%esp)
c0105866:	c0 
c0105867:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010586e:	c0 
c010586f:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0105876:	00 
c0105877:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c010587e:	e8 75 ab ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c0105883:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105888:	8b 15 f0 40 12 c0    	mov    0xc01240f0,%edx
c010588e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105891:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105894:	c7 45 e4 ec 40 12 c0 	movl   $0xc01240ec,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010589b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010589e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01058a1:	89 50 04             	mov    %edx,0x4(%eax)
c01058a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058a7:	8b 50 04             	mov    0x4(%eax),%edx
c01058aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058ad:	89 10                	mov    %edx,(%eax)
c01058af:	c7 45 d8 ec 40 12 c0 	movl   $0xc01240ec,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01058b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058b9:	8b 40 04             	mov    0x4(%eax),%eax
c01058bc:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01058bf:	0f 94 c0             	sete   %al
c01058c2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01058c5:	85 c0                	test   %eax,%eax
c01058c7:	75 24                	jne    c01058ed <basic_check+0x26f>
c01058c9:	c7 44 24 0c 8b a0 10 	movl   $0xc010a08b,0xc(%esp)
c01058d0:	c0 
c01058d1:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01058d8:	c0 
c01058d9:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01058e0:	00 
c01058e1:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01058e8:	e8 0b ab ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c01058ed:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c01058f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01058f5:	c7 05 f4 40 12 c0 00 	movl   $0x0,0xc01240f4
c01058fc:	00 00 00 

    assert(alloc_page() == NULL);
c01058ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105906:	e8 68 0c 00 00       	call   c0106573 <alloc_pages>
c010590b:	85 c0                	test   %eax,%eax
c010590d:	74 24                	je     c0105933 <basic_check+0x2b5>
c010590f:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0105916:	c0 
c0105917:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010591e:	c0 
c010591f:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0105926:	00 
c0105927:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c010592e:	e8 c5 aa ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c0105933:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010593a:	00 
c010593b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010593e:	89 04 24             	mov    %eax,(%esp)
c0105941:	e8 98 0c 00 00       	call   c01065de <free_pages>
    free_page(p1);
c0105946:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010594d:	00 
c010594e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105951:	89 04 24             	mov    %eax,(%esp)
c0105954:	e8 85 0c 00 00       	call   c01065de <free_pages>
    free_page(p2);
c0105959:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105960:	00 
c0105961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105964:	89 04 24             	mov    %eax,(%esp)
c0105967:	e8 72 0c 00 00       	call   c01065de <free_pages>
    assert(nr_free == 3);
c010596c:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0105971:	83 f8 03             	cmp    $0x3,%eax
c0105974:	74 24                	je     c010599a <basic_check+0x31c>
c0105976:	c7 44 24 0c b7 a0 10 	movl   $0xc010a0b7,0xc(%esp)
c010597d:	c0 
c010597e:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105985:	c0 
c0105986:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c010598d:	00 
c010598e:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105995:	e8 5e aa ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010599a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059a1:	e8 cd 0b 00 00       	call   c0106573 <alloc_pages>
c01059a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01059a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01059ad:	75 24                	jne    c01059d3 <basic_check+0x355>
c01059af:	c7 44 24 0c 80 9f 10 	movl   $0xc0109f80,0xc(%esp)
c01059b6:	c0 
c01059b7:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01059be:	c0 
c01059bf:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01059c6:	00 
c01059c7:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01059ce:	e8 25 aa ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01059d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059da:	e8 94 0b 00 00       	call   c0106573 <alloc_pages>
c01059df:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01059e6:	75 24                	jne    c0105a0c <basic_check+0x38e>
c01059e8:	c7 44 24 0c 9c 9f 10 	movl   $0xc0109f9c,0xc(%esp)
c01059ef:	c0 
c01059f0:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01059f7:	c0 
c01059f8:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c01059ff:	00 
c0105a00:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105a07:	e8 ec a9 ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105a0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a13:	e8 5b 0b 00 00       	call   c0106573 <alloc_pages>
c0105a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a1f:	75 24                	jne    c0105a45 <basic_check+0x3c7>
c0105a21:	c7 44 24 0c b8 9f 10 	movl   $0xc0109fb8,0xc(%esp)
c0105a28:	c0 
c0105a29:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105a30:	c0 
c0105a31:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0105a38:	00 
c0105a39:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105a40:	e8 b3 a9 ff ff       	call   c01003f8 <__panic>

    assert(alloc_page() == NULL);
c0105a45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a4c:	e8 22 0b 00 00       	call   c0106573 <alloc_pages>
c0105a51:	85 c0                	test   %eax,%eax
c0105a53:	74 24                	je     c0105a79 <basic_check+0x3fb>
c0105a55:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0105a5c:	c0 
c0105a5d:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105a64:	c0 
c0105a65:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0105a6c:	00 
c0105a6d:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105a74:	e8 7f a9 ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c0105a79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a80:	00 
c0105a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a84:	89 04 24             	mov    %eax,(%esp)
c0105a87:	e8 52 0b 00 00       	call   c01065de <free_pages>
c0105a8c:	c7 45 e8 ec 40 12 c0 	movl   $0xc01240ec,-0x18(%ebp)
c0105a93:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a96:	8b 40 04             	mov    0x4(%eax),%eax
c0105a99:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105a9c:	0f 94 c0             	sete   %al
c0105a9f:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105aa2:	85 c0                	test   %eax,%eax
c0105aa4:	74 24                	je     c0105aca <basic_check+0x44c>
c0105aa6:	c7 44 24 0c c4 a0 10 	movl   $0xc010a0c4,0xc(%esp)
c0105aad:	c0 
c0105aae:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105ab5:	c0 
c0105ab6:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0105abd:	00 
c0105abe:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105ac5:	e8 2e a9 ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105aca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ad1:	e8 9d 0a 00 00       	call   c0106573 <alloc_pages>
c0105ad6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105ad9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105adc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105adf:	74 24                	je     c0105b05 <basic_check+0x487>
c0105ae1:	c7 44 24 0c dc a0 10 	movl   $0xc010a0dc,0xc(%esp)
c0105ae8:	c0 
c0105ae9:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105af0:	c0 
c0105af1:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0105af8:	00 
c0105af9:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105b00:	e8 f3 a8 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105b05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b0c:	e8 62 0a 00 00       	call   c0106573 <alloc_pages>
c0105b11:	85 c0                	test   %eax,%eax
c0105b13:	74 24                	je     c0105b39 <basic_check+0x4bb>
c0105b15:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0105b1c:	c0 
c0105b1d:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105b24:	c0 
c0105b25:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0105b2c:	00 
c0105b2d:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105b34:	e8 bf a8 ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c0105b39:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0105b3e:	85 c0                	test   %eax,%eax
c0105b40:	74 24                	je     c0105b66 <basic_check+0x4e8>
c0105b42:	c7 44 24 0c f5 a0 10 	movl   $0xc010a0f5,0xc(%esp)
c0105b49:	c0 
c0105b4a:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105b51:	c0 
c0105b52:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0105b59:	00 
c0105b5a:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105b61:	e8 92 a8 ff ff       	call   c01003f8 <__panic>
    free_list = free_list_store;
c0105b66:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105b69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105b6c:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
c0105b71:	89 15 f0 40 12 c0    	mov    %edx,0xc01240f0
    nr_free = nr_free_store;
c0105b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b7a:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4

    free_page(p);
c0105b7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b86:	00 
c0105b87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b8a:	89 04 24             	mov    %eax,(%esp)
c0105b8d:	e8 4c 0a 00 00       	call   c01065de <free_pages>
    free_page(p1);
c0105b92:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b99:	00 
c0105b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b9d:	89 04 24             	mov    %eax,(%esp)
c0105ba0:	e8 39 0a 00 00       	call   c01065de <free_pages>
    free_page(p2);
c0105ba5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105bac:	00 
c0105bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bb0:	89 04 24             	mov    %eax,(%esp)
c0105bb3:	e8 26 0a 00 00       	call   c01065de <free_pages>
}
c0105bb8:	90                   	nop
c0105bb9:	c9                   	leave  
c0105bba:	c3                   	ret    

c0105bbb <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105bbb:	55                   	push   %ebp
c0105bbc:	89 e5                	mov    %esp,%ebp
c0105bbe:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0105bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105bcb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105bd2:	c7 45 ec ec 40 12 c0 	movl   $0xc01240ec,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105bd9:	eb 6a                	jmp    c0105c45 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0105bdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bde:	83 e8 0c             	sub    $0xc,%eax
c0105be1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0105be4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105be7:	83 c0 04             	add    $0x4,%eax
c0105bea:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105bf1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105bf4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105bf7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105bfa:	0f a3 10             	bt     %edx,(%eax)
c0105bfd:	19 c0                	sbb    %eax,%eax
c0105bff:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105c02:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0105c06:	0f 95 c0             	setne  %al
c0105c09:	0f b6 c0             	movzbl %al,%eax
c0105c0c:	85 c0                	test   %eax,%eax
c0105c0e:	75 24                	jne    c0105c34 <default_check+0x79>
c0105c10:	c7 44 24 0c 02 a1 10 	movl   $0xc010a102,0xc(%esp)
c0105c17:	c0 
c0105c18:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105c1f:	c0 
c0105c20:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0105c27:	00 
c0105c28:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105c2f:	e8 c4 a7 ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c0105c34:	ff 45 f4             	incl   -0xc(%ebp)
c0105c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c3a:	8b 50 08             	mov    0x8(%eax),%edx
c0105c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c40:	01 d0                	add    %edx,%eax
c0105c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c48:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105c4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c4e:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c54:	81 7d ec ec 40 12 c0 	cmpl   $0xc01240ec,-0x14(%ebp)
c0105c5b:	0f 85 7a ff ff ff    	jne    c0105bdb <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105c61:	e8 ab 09 00 00       	call   c0106611 <nr_free_pages>
c0105c66:	89 c2                	mov    %eax,%edx
c0105c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c6b:	39 c2                	cmp    %eax,%edx
c0105c6d:	74 24                	je     c0105c93 <default_check+0xd8>
c0105c6f:	c7 44 24 0c 12 a1 10 	movl   $0xc010a112,0xc(%esp)
c0105c76:	c0 
c0105c77:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105c7e:	c0 
c0105c7f:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0105c86:	00 
c0105c87:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105c8e:	e8 65 a7 ff ff       	call   c01003f8 <__panic>

    basic_check();
c0105c93:	e8 e6 f9 ff ff       	call   c010567e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105c98:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105c9f:	e8 cf 08 00 00       	call   c0106573 <alloc_pages>
c0105ca4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0105ca7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105cab:	75 24                	jne    c0105cd1 <default_check+0x116>
c0105cad:	c7 44 24 0c 2b a1 10 	movl   $0xc010a12b,0xc(%esp)
c0105cb4:	c0 
c0105cb5:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105cbc:	c0 
c0105cbd:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0105cc4:	00 
c0105cc5:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105ccc:	e8 27 a7 ff ff       	call   c01003f8 <__panic>
    assert(!PageProperty(p0));
c0105cd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cd4:	83 c0 04             	add    $0x4,%eax
c0105cd7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0105cde:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105ce1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105ce4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105ce7:	0f a3 10             	bt     %edx,(%eax)
c0105cea:	19 c0                	sbb    %eax,%eax
c0105cec:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0105cef:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0105cf3:	0f 95 c0             	setne  %al
c0105cf6:	0f b6 c0             	movzbl %al,%eax
c0105cf9:	85 c0                	test   %eax,%eax
c0105cfb:	74 24                	je     c0105d21 <default_check+0x166>
c0105cfd:	c7 44 24 0c 36 a1 10 	movl   $0xc010a136,0xc(%esp)
c0105d04:	c0 
c0105d05:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105d0c:	c0 
c0105d0d:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0105d14:	00 
c0105d15:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105d1c:	e8 d7 a6 ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c0105d21:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105d26:	8b 15 f0 40 12 c0    	mov    0xc01240f0,%edx
c0105d2c:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105d2f:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105d32:	c7 45 d0 ec 40 12 c0 	movl   $0xc01240ec,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105d39:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d3c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105d3f:	89 50 04             	mov    %edx,0x4(%eax)
c0105d42:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d45:	8b 50 04             	mov    0x4(%eax),%edx
c0105d48:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d4b:	89 10                	mov    %edx,(%eax)
c0105d4d:	c7 45 d8 ec 40 12 c0 	movl   $0xc01240ec,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105d54:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105d57:	8b 40 04             	mov    0x4(%eax),%eax
c0105d5a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105d5d:	0f 94 c0             	sete   %al
c0105d60:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105d63:	85 c0                	test   %eax,%eax
c0105d65:	75 24                	jne    c0105d8b <default_check+0x1d0>
c0105d67:	c7 44 24 0c 8b a0 10 	movl   $0xc010a08b,0xc(%esp)
c0105d6e:	c0 
c0105d6f:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105d76:	c0 
c0105d77:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0105d7e:	00 
c0105d7f:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105d86:	e8 6d a6 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105d8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d92:	e8 dc 07 00 00       	call   c0106573 <alloc_pages>
c0105d97:	85 c0                	test   %eax,%eax
c0105d99:	74 24                	je     c0105dbf <default_check+0x204>
c0105d9b:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0105da2:	c0 
c0105da3:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105daa:	c0 
c0105dab:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0105db2:	00 
c0105db3:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105dba:	e8 39 a6 ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c0105dbf:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0105dc4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0105dc7:	c7 05 f4 40 12 c0 00 	movl   $0x0,0xc01240f4
c0105dce:	00 00 00 

    free_pages(p0 + 2, 3);
c0105dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105dd4:	83 c0 40             	add    $0x40,%eax
c0105dd7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105dde:	00 
c0105ddf:	89 04 24             	mov    %eax,(%esp)
c0105de2:	e8 f7 07 00 00       	call   c01065de <free_pages>
    assert(alloc_pages(4) == NULL);
c0105de7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105dee:	e8 80 07 00 00       	call   c0106573 <alloc_pages>
c0105df3:	85 c0                	test   %eax,%eax
c0105df5:	74 24                	je     c0105e1b <default_check+0x260>
c0105df7:	c7 44 24 0c 48 a1 10 	movl   $0xc010a148,0xc(%esp)
c0105dfe:	c0 
c0105dff:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105e06:	c0 
c0105e07:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
c0105e0e:	00 
c0105e0f:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105e16:	e8 dd a5 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105e1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e1e:	83 c0 40             	add    $0x40,%eax
c0105e21:	83 c0 04             	add    $0x4,%eax
c0105e24:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105e2b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e2e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105e31:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e34:	0f a3 10             	bt     %edx,(%eax)
c0105e37:	19 c0                	sbb    %eax,%eax
c0105e39:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105e3c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105e40:	0f 95 c0             	setne  %al
c0105e43:	0f b6 c0             	movzbl %al,%eax
c0105e46:	85 c0                	test   %eax,%eax
c0105e48:	74 0e                	je     c0105e58 <default_check+0x29d>
c0105e4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e4d:	83 c0 40             	add    $0x40,%eax
c0105e50:	8b 40 08             	mov    0x8(%eax),%eax
c0105e53:	83 f8 03             	cmp    $0x3,%eax
c0105e56:	74 24                	je     c0105e7c <default_check+0x2c1>
c0105e58:	c7 44 24 0c 60 a1 10 	movl   $0xc010a160,0xc(%esp)
c0105e5f:	c0 
c0105e60:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105e67:	c0 
c0105e68:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c0105e6f:	00 
c0105e70:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105e77:	e8 7c a5 ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105e7c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105e83:	e8 eb 06 00 00       	call   c0106573 <alloc_pages>
c0105e88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105e8b:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0105e8f:	75 24                	jne    c0105eb5 <default_check+0x2fa>
c0105e91:	c7 44 24 0c 8c a1 10 	movl   $0xc010a18c,0xc(%esp)
c0105e98:	c0 
c0105e99:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105ea0:	c0 
c0105ea1:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c0105ea8:	00 
c0105ea9:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105eb0:	e8 43 a5 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105eb5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ebc:	e8 b2 06 00 00       	call   c0106573 <alloc_pages>
c0105ec1:	85 c0                	test   %eax,%eax
c0105ec3:	74 24                	je     c0105ee9 <default_check+0x32e>
c0105ec5:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0105ecc:	c0 
c0105ecd:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105ed4:	c0 
c0105ed5:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0105edc:	00 
c0105edd:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105ee4:	e8 0f a5 ff ff       	call   c01003f8 <__panic>
    assert(p0 + 2 == p1);
c0105ee9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105eec:	83 c0 40             	add    $0x40,%eax
c0105eef:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0105ef2:	74 24                	je     c0105f18 <default_check+0x35d>
c0105ef4:	c7 44 24 0c aa a1 10 	movl   $0xc010a1aa,0xc(%esp)
c0105efb:	c0 
c0105efc:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105f03:	c0 
c0105f04:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0105f0b:	00 
c0105f0c:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105f13:	e8 e0 a4 ff ff       	call   c01003f8 <__panic>

    p2 = p0 + 1;
c0105f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f1b:	83 c0 20             	add    $0x20,%eax
c0105f1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0105f21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f28:	00 
c0105f29:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f2c:	89 04 24             	mov    %eax,(%esp)
c0105f2f:	e8 aa 06 00 00       	call   c01065de <free_pages>
    free_pages(p1, 3);
c0105f34:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105f3b:	00 
c0105f3c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105f3f:	89 04 24             	mov    %eax,(%esp)
c0105f42:	e8 97 06 00 00       	call   c01065de <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f4a:	83 c0 04             	add    $0x4,%eax
c0105f4d:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105f54:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105f57:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105f5a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105f5d:	0f a3 10             	bt     %edx,(%eax)
c0105f60:	19 c0                	sbb    %eax,%eax
c0105f62:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0105f65:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0105f69:	0f 95 c0             	setne  %al
c0105f6c:	0f b6 c0             	movzbl %al,%eax
c0105f6f:	85 c0                	test   %eax,%eax
c0105f71:	74 0b                	je     c0105f7e <default_check+0x3c3>
c0105f73:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f76:	8b 40 08             	mov    0x8(%eax),%eax
c0105f79:	83 f8 01             	cmp    $0x1,%eax
c0105f7c:	74 24                	je     c0105fa2 <default_check+0x3e7>
c0105f7e:	c7 44 24 0c b8 a1 10 	movl   $0xc010a1b8,0xc(%esp)
c0105f85:	c0 
c0105f86:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105f8d:	c0 
c0105f8e:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c0105f95:	00 
c0105f96:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105f9d:	e8 56 a4 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105fa2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105fa5:	83 c0 04             	add    $0x4,%eax
c0105fa8:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105faf:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105fb2:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105fb5:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105fb8:	0f a3 10             	bt     %edx,(%eax)
c0105fbb:	19 c0                	sbb    %eax,%eax
c0105fbd:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0105fc0:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0105fc4:	0f 95 c0             	setne  %al
c0105fc7:	0f b6 c0             	movzbl %al,%eax
c0105fca:	85 c0                	test   %eax,%eax
c0105fcc:	74 0b                	je     c0105fd9 <default_check+0x41e>
c0105fce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105fd1:	8b 40 08             	mov    0x8(%eax),%eax
c0105fd4:	83 f8 03             	cmp    $0x3,%eax
c0105fd7:	74 24                	je     c0105ffd <default_check+0x442>
c0105fd9:	c7 44 24 0c e0 a1 10 	movl   $0xc010a1e0,0xc(%esp)
c0105fe0:	c0 
c0105fe1:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0105fe8:	c0 
c0105fe9:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
c0105ff0:	00 
c0105ff1:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105ff8:	e8 fb a3 ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105ffd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106004:	e8 6a 05 00 00       	call   c0106573 <alloc_pages>
c0106009:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010600c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010600f:	83 e8 20             	sub    $0x20,%eax
c0106012:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106015:	74 24                	je     c010603b <default_check+0x480>
c0106017:	c7 44 24 0c 06 a2 10 	movl   $0xc010a206,0xc(%esp)
c010601e:	c0 
c010601f:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0106026:	c0 
c0106027:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c010602e:	00 
c010602f:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0106036:	e8 bd a3 ff ff       	call   c01003f8 <__panic>
    free_page(p0);
c010603b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106042:	00 
c0106043:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106046:	89 04 24             	mov    %eax,(%esp)
c0106049:	e8 90 05 00 00       	call   c01065de <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010604e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106055:	e8 19 05 00 00       	call   c0106573 <alloc_pages>
c010605a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010605d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106060:	83 c0 20             	add    $0x20,%eax
c0106063:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106066:	74 24                	je     c010608c <default_check+0x4d1>
c0106068:	c7 44 24 0c 24 a2 10 	movl   $0xc010a224,0xc(%esp)
c010606f:	c0 
c0106070:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0106077:	c0 
c0106078:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c010607f:	00 
c0106080:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0106087:	e8 6c a3 ff ff       	call   c01003f8 <__panic>

    free_pages(p0, 2);
c010608c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106093:	00 
c0106094:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106097:	89 04 24             	mov    %eax,(%esp)
c010609a:	e8 3f 05 00 00       	call   c01065de <free_pages>
    free_page(p2);
c010609f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060a6:	00 
c01060a7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01060aa:	89 04 24             	mov    %eax,(%esp)
c01060ad:	e8 2c 05 00 00       	call   c01065de <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01060b2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01060b9:	e8 b5 04 00 00       	call   c0106573 <alloc_pages>
c01060be:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01060c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01060c5:	75 24                	jne    c01060eb <default_check+0x530>
c01060c7:	c7 44 24 0c 44 a2 10 	movl   $0xc010a244,0xc(%esp)
c01060ce:	c0 
c01060cf:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01060d6:	c0 
c01060d7:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c01060de:	00 
c01060df:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01060e6:	e8 0d a3 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c01060eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060f2:	e8 7c 04 00 00       	call   c0106573 <alloc_pages>
c01060f7:	85 c0                	test   %eax,%eax
c01060f9:	74 24                	je     c010611f <default_check+0x564>
c01060fb:	c7 44 24 0c a2 a0 10 	movl   $0xc010a0a2,0xc(%esp)
c0106102:	c0 
c0106103:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c010610a:	c0 
c010610b:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c0106112:	00 
c0106113:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c010611a:	e8 d9 a2 ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c010611f:	a1 f4 40 12 c0       	mov    0xc01240f4,%eax
c0106124:	85 c0                	test   %eax,%eax
c0106126:	74 24                	je     c010614c <default_check+0x591>
c0106128:	c7 44 24 0c f5 a0 10 	movl   $0xc010a0f5,0xc(%esp)
c010612f:	c0 
c0106130:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c0106137:	c0 
c0106138:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
c010613f:	00 
c0106140:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0106147:	e8 ac a2 ff ff       	call   c01003f8 <__panic>
    nr_free = nr_free_store;
c010614c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010614f:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4

    free_list = free_list_store;
c0106154:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106157:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010615a:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
c010615f:	89 15 f0 40 12 c0    	mov    %edx,0xc01240f0
    free_pages(p0, 5);
c0106165:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010616c:	00 
c010616d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106170:	89 04 24             	mov    %eax,(%esp)
c0106173:	e8 66 04 00 00       	call   c01065de <free_pages>

    le = &free_list;
c0106178:	c7 45 ec ec 40 12 c0 	movl   $0xc01240ec,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010617f:	eb 1c                	jmp    c010619d <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0106181:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106184:	83 e8 0c             	sub    $0xc,%eax
c0106187:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c010618a:	ff 4d f4             	decl   -0xc(%ebp)
c010618d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106190:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106193:	8b 40 08             	mov    0x8(%eax),%eax
c0106196:	29 c2                	sub    %eax,%edx
c0106198:	89 d0                	mov    %edx,%eax
c010619a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010619d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061a0:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01061a3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01061a6:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01061a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01061ac:	81 7d ec ec 40 12 c0 	cmpl   $0xc01240ec,-0x14(%ebp)
c01061b3:	75 cc                	jne    c0106181 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01061b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01061b9:	74 24                	je     c01061df <default_check+0x624>
c01061bb:	c7 44 24 0c 62 a2 10 	movl   $0xc010a262,0xc(%esp)
c01061c2:	c0 
c01061c3:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01061ca:	c0 
c01061cb:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c01061d2:	00 
c01061d3:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c01061da:	e8 19 a2 ff ff       	call   c01003f8 <__panic>
    assert(total == 0);
c01061df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01061e3:	74 24                	je     c0106209 <default_check+0x64e>
c01061e5:	c7 44 24 0c 6d a2 10 	movl   $0xc010a26d,0xc(%esp)
c01061ec:	c0 
c01061ed:	c7 44 24 08 32 9f 10 	movl   $0xc0109f32,0x8(%esp)
c01061f4:	c0 
c01061f5:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c01061fc:	00 
c01061fd:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0106204:	e8 ef a1 ff ff       	call   c01003f8 <__panic>
}
c0106209:	90                   	nop
c010620a:	c9                   	leave  
c010620b:	c3                   	ret    

c010620c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010620c:	55                   	push   %ebp
c010620d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010620f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106212:	8b 15 00 41 12 c0    	mov    0xc0124100,%edx
c0106218:	29 d0                	sub    %edx,%eax
c010621a:	c1 f8 05             	sar    $0x5,%eax
}
c010621d:	5d                   	pop    %ebp
c010621e:	c3                   	ret    

c010621f <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010621f:	55                   	push   %ebp
c0106220:	89 e5                	mov    %esp,%ebp
c0106222:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106225:	8b 45 08             	mov    0x8(%ebp),%eax
c0106228:	89 04 24             	mov    %eax,(%esp)
c010622b:	e8 dc ff ff ff       	call   c010620c <page2ppn>
c0106230:	c1 e0 0c             	shl    $0xc,%eax
}
c0106233:	c9                   	leave  
c0106234:	c3                   	ret    

c0106235 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0106235:	55                   	push   %ebp
c0106236:	89 e5                	mov    %esp,%ebp
c0106238:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010623b:	8b 45 08             	mov    0x8(%ebp),%eax
c010623e:	c1 e8 0c             	shr    $0xc,%eax
c0106241:	89 c2                	mov    %eax,%edx
c0106243:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106248:	39 c2                	cmp    %eax,%edx
c010624a:	72 1c                	jb     c0106268 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010624c:	c7 44 24 08 a8 a2 10 	movl   $0xc010a2a8,0x8(%esp)
c0106253:	c0 
c0106254:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010625b:	00 
c010625c:	c7 04 24 c7 a2 10 c0 	movl   $0xc010a2c7,(%esp)
c0106263:	e8 90 a1 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c0106268:	a1 00 41 12 c0       	mov    0xc0124100,%eax
c010626d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106270:	c1 ea 0c             	shr    $0xc,%edx
c0106273:	c1 e2 05             	shl    $0x5,%edx
c0106276:	01 d0                	add    %edx,%eax
}
c0106278:	c9                   	leave  
c0106279:	c3                   	ret    

c010627a <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010627a:	55                   	push   %ebp
c010627b:	89 e5                	mov    %esp,%ebp
c010627d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0106280:	8b 45 08             	mov    0x8(%ebp),%eax
c0106283:	89 04 24             	mov    %eax,(%esp)
c0106286:	e8 94 ff ff ff       	call   c010621f <page2pa>
c010628b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106291:	c1 e8 0c             	shr    $0xc,%eax
c0106294:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106297:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010629c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010629f:	72 23                	jb     c01062c4 <page2kva+0x4a>
c01062a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062a8:	c7 44 24 08 d8 a2 10 	movl   $0xc010a2d8,0x8(%esp)
c01062af:	c0 
c01062b0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01062b7:	00 
c01062b8:	c7 04 24 c7 a2 10 c0 	movl   $0xc010a2c7,(%esp)
c01062bf:	e8 34 a1 ff ff       	call   c01003f8 <__panic>
c01062c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062c7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01062cc:	c9                   	leave  
c01062cd:	c3                   	ret    

c01062ce <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01062ce:	55                   	push   %ebp
c01062cf:	89 e5                	mov    %esp,%ebp
c01062d1:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01062d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062da:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01062e1:	77 23                	ja     c0106306 <kva2page+0x38>
c01062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062ea:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c01062f1:	c0 
c01062f2:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01062f9:	00 
c01062fa:	c7 04 24 c7 a2 10 c0 	movl   $0xc010a2c7,(%esp)
c0106301:	e8 f2 a0 ff ff       	call   c01003f8 <__panic>
c0106306:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106309:	05 00 00 00 40       	add    $0x40000000,%eax
c010630e:	89 04 24             	mov    %eax,(%esp)
c0106311:	e8 1f ff ff ff       	call   c0106235 <pa2page>
}
c0106316:	c9                   	leave  
c0106317:	c3                   	ret    

c0106318 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c0106318:	55                   	push   %ebp
c0106319:	89 e5                	mov    %esp,%ebp
c010631b:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010631e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106321:	83 e0 01             	and    $0x1,%eax
c0106324:	85 c0                	test   %eax,%eax
c0106326:	75 1c                	jne    c0106344 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106328:	c7 44 24 08 20 a3 10 	movl   $0xc010a320,0x8(%esp)
c010632f:	c0 
c0106330:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106337:	00 
c0106338:	c7 04 24 c7 a2 10 c0 	movl   $0xc010a2c7,(%esp)
c010633f:	e8 b4 a0 ff ff       	call   c01003f8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106344:	8b 45 08             	mov    0x8(%ebp),%eax
c0106347:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010634c:	89 04 24             	mov    %eax,(%esp)
c010634f:	e8 e1 fe ff ff       	call   c0106235 <pa2page>
}
c0106354:	c9                   	leave  
c0106355:	c3                   	ret    

c0106356 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106356:	55                   	push   %ebp
c0106357:	89 e5                	mov    %esp,%ebp
c0106359:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010635c:	8b 45 08             	mov    0x8(%ebp),%eax
c010635f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106364:	89 04 24             	mov    %eax,(%esp)
c0106367:	e8 c9 fe ff ff       	call   c0106235 <pa2page>
}
c010636c:	c9                   	leave  
c010636d:	c3                   	ret    

c010636e <page_ref>:

static inline int
page_ref(struct Page *page) {
c010636e:	55                   	push   %ebp
c010636f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106371:	8b 45 08             	mov    0x8(%ebp),%eax
c0106374:	8b 00                	mov    (%eax),%eax
}
c0106376:	5d                   	pop    %ebp
c0106377:	c3                   	ret    

c0106378 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106378:	55                   	push   %ebp
c0106379:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010637b:	8b 45 08             	mov    0x8(%ebp),%eax
c010637e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106381:	89 10                	mov    %edx,(%eax)
}
c0106383:	90                   	nop
c0106384:	5d                   	pop    %ebp
c0106385:	c3                   	ret    

c0106386 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0106386:	55                   	push   %ebp
c0106387:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0106389:	8b 45 08             	mov    0x8(%ebp),%eax
c010638c:	8b 00                	mov    (%eax),%eax
c010638e:	8d 50 01             	lea    0x1(%eax),%edx
c0106391:	8b 45 08             	mov    0x8(%ebp),%eax
c0106394:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106396:	8b 45 08             	mov    0x8(%ebp),%eax
c0106399:	8b 00                	mov    (%eax),%eax
}
c010639b:	5d                   	pop    %ebp
c010639c:	c3                   	ret    

c010639d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010639d:	55                   	push   %ebp
c010639e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01063a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a3:	8b 00                	mov    (%eax),%eax
c01063a5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01063a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ab:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01063ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b0:	8b 00                	mov    (%eax),%eax
}
c01063b2:	5d                   	pop    %ebp
c01063b3:	c3                   	ret    

c01063b4 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01063b4:	55                   	push   %ebp
c01063b5:	89 e5                	mov    %esp,%ebp
c01063b7:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01063ba:	9c                   	pushf  
c01063bb:	58                   	pop    %eax
c01063bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01063c2:	25 00 02 00 00       	and    $0x200,%eax
c01063c7:	85 c0                	test   %eax,%eax
c01063c9:	74 0c                	je     c01063d7 <__intr_save+0x23>
        intr_disable();
c01063cb:	e8 21 bd ff ff       	call   c01020f1 <intr_disable>
        return 1;
c01063d0:	b8 01 00 00 00       	mov    $0x1,%eax
c01063d5:	eb 05                	jmp    c01063dc <__intr_save+0x28>
    }
    return 0;
c01063d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063dc:	c9                   	leave  
c01063dd:	c3                   	ret    

c01063de <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01063de:	55                   	push   %ebp
c01063df:	89 e5                	mov    %esp,%ebp
c01063e1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01063e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01063e8:	74 05                	je     c01063ef <__intr_restore+0x11>
        intr_enable();
c01063ea:	e8 fb bc ff ff       	call   c01020ea <intr_enable>
    }
}
c01063ef:	90                   	nop
c01063f0:	c9                   	leave  
c01063f1:	c3                   	ret    

c01063f2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01063f2:	55                   	push   %ebp
c01063f3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01063f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01063fb:	b8 23 00 00 00       	mov    $0x23,%eax
c0106400:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0106402:	b8 23 00 00 00       	mov    $0x23,%eax
c0106407:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0106409:	b8 10 00 00 00       	mov    $0x10,%eax
c010640e:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0106410:	b8 10 00 00 00       	mov    $0x10,%eax
c0106415:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0106417:	b8 10 00 00 00       	mov    $0x10,%eax
c010641c:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c010641e:	ea 25 64 10 c0 08 00 	ljmp   $0x8,$0xc0106425
}
c0106425:	90                   	nop
c0106426:	5d                   	pop    %ebp
c0106427:	c3                   	ret    

c0106428 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0106428:	55                   	push   %ebp
c0106429:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010642b:	8b 45 08             	mov    0x8(%ebp),%eax
c010642e:	a3 a4 3f 12 c0       	mov    %eax,0xc0123fa4
}
c0106433:	90                   	nop
c0106434:	5d                   	pop    %ebp
c0106435:	c3                   	ret    

c0106436 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0106436:	55                   	push   %ebp
c0106437:	89 e5                	mov    %esp,%ebp
c0106439:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010643c:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c0106441:	89 04 24             	mov    %eax,(%esp)
c0106444:	e8 df ff ff ff       	call   c0106428 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0106449:	66 c7 05 a8 3f 12 c0 	movw   $0x10,0xc0123fa8
c0106450:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0106452:	66 c7 05 48 0a 12 c0 	movw   $0x68,0xc0120a48
c0106459:	68 00 
c010645b:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c0106460:	0f b7 c0             	movzwl %ax,%eax
c0106463:	66 a3 4a 0a 12 c0    	mov    %ax,0xc0120a4a
c0106469:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c010646e:	c1 e8 10             	shr    $0x10,%eax
c0106471:	a2 4c 0a 12 c0       	mov    %al,0xc0120a4c
c0106476:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010647d:	24 f0                	and    $0xf0,%al
c010647f:	0c 09                	or     $0x9,%al
c0106481:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106486:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010648d:	24 ef                	and    $0xef,%al
c010648f:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106494:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010649b:	24 9f                	and    $0x9f,%al
c010649d:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c01064a2:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c01064a9:	0c 80                	or     $0x80,%al
c01064ab:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c01064b0:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01064b7:	24 f0                	and    $0xf0,%al
c01064b9:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01064be:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01064c5:	24 ef                	and    $0xef,%al
c01064c7:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01064cc:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01064d3:	24 df                	and    $0xdf,%al
c01064d5:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01064da:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01064e1:	0c 40                	or     $0x40,%al
c01064e3:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01064e8:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01064ef:	24 7f                	and    $0x7f,%al
c01064f1:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01064f6:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c01064fb:	c1 e8 18             	shr    $0x18,%eax
c01064fe:	a2 4f 0a 12 c0       	mov    %al,0xc0120a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0106503:	c7 04 24 50 0a 12 c0 	movl   $0xc0120a50,(%esp)
c010650a:	e8 e3 fe ff ff       	call   c01063f2 <lgdt>
c010650f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0106515:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0106519:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c010651c:	90                   	nop
c010651d:	c9                   	leave  
c010651e:	c3                   	ret    

c010651f <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010651f:	55                   	push   %ebp
c0106520:	89 e5                	mov    %esp,%ebp
c0106522:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0106525:	c7 05 f8 40 12 c0 8c 	movl   $0xc010a28c,0xc01240f8
c010652c:	a2 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010652f:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0106534:	8b 00                	mov    (%eax),%eax
c0106536:	89 44 24 04          	mov    %eax,0x4(%esp)
c010653a:	c7 04 24 4c a3 10 c0 	movl   $0xc010a34c,(%esp)
c0106541:	e8 5b 9d ff ff       	call   c01002a1 <cprintf>
    pmm_manager->init();
c0106546:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c010654b:	8b 40 04             	mov    0x4(%eax),%eax
c010654e:	ff d0                	call   *%eax
}
c0106550:	90                   	nop
c0106551:	c9                   	leave  
c0106552:	c3                   	ret    

c0106553 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c0106553:	55                   	push   %ebp
c0106554:	89 e5                	mov    %esp,%ebp
c0106556:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0106559:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c010655e:	8b 40 08             	mov    0x8(%eax),%eax
c0106561:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106564:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106568:	8b 55 08             	mov    0x8(%ebp),%edx
c010656b:	89 14 24             	mov    %edx,(%esp)
c010656e:	ff d0                	call   *%eax
}
c0106570:	90                   	nop
c0106571:	c9                   	leave  
c0106572:	c3                   	ret    

c0106573 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n) {
c0106573:	55                   	push   %ebp
c0106574:	89 e5                	mov    %esp,%ebp
c0106576:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106579:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
c0106580:	e8 2f fe ff ff       	call   c01063b4 <__intr_save>
c0106585:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c0106588:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c010658d:	8b 40 0c             	mov    0xc(%eax),%eax
c0106590:	8b 55 08             	mov    0x8(%ebp),%edx
c0106593:	89 14 24             	mov    %edx,(%esp)
c0106596:	ff d0                	call   *%eax
c0106598:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c010659b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010659e:	89 04 24             	mov    %eax,(%esp)
c01065a1:	e8 38 fe ff ff       	call   c01063de <__intr_restore>

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01065a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01065aa:	75 2d                	jne    c01065d9 <alloc_pages+0x66>
c01065ac:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01065b0:	77 27                	ja     c01065d9 <alloc_pages+0x66>
c01065b2:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c01065b7:	85 c0                	test   %eax,%eax
c01065b9:	74 1e                	je     c01065d9 <alloc_pages+0x66>

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c01065bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01065be:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01065c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01065ca:	00 
c01065cb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065cf:	89 04 24             	mov    %eax,(%esp)
c01065d2:	e8 97 db ff ff       	call   c010416e <swap_out>
    }
c01065d7:	eb a7                	jmp    c0106580 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01065d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01065dc:	c9                   	leave  
c01065dd:	c3                   	ret    

c01065de <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void
free_pages(struct Page *base, size_t n) {
c01065de:	55                   	push   %ebp
c01065df:	89 e5                	mov    %esp,%ebp
c01065e1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01065e4:	e8 cb fd ff ff       	call   c01063b4 <__intr_save>
c01065e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01065ec:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01065f1:	8b 40 10             	mov    0x10(%eax),%eax
c01065f4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01065f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01065fe:	89 14 24             	mov    %edx,(%esp)
c0106601:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0106603:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106606:	89 04 24             	mov    %eax,(%esp)
c0106609:	e8 d0 fd ff ff       	call   c01063de <__intr_restore>
}
c010660e:	90                   	nop
c010660f:	c9                   	leave  
c0106610:	c3                   	ret    

c0106611 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void) {
c0106611:	55                   	push   %ebp
c0106612:	89 e5                	mov    %esp,%ebp
c0106614:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0106617:	e8 98 fd ff ff       	call   c01063b4 <__intr_save>
c010661c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010661f:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0106624:	8b 40 14             	mov    0x14(%eax),%eax
c0106627:	ff d0                	call   *%eax
c0106629:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010662c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010662f:	89 04 24             	mov    %eax,(%esp)
c0106632:	e8 a7 fd ff ff       	call   c01063de <__intr_restore>
    return ret;
c0106637:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010663a:	c9                   	leave  
c010663b:	c3                   	ret    

c010663c <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010663c:	55                   	push   %ebp
c010663d:	89 e5                	mov    %esp,%ebp
c010663f:	57                   	push   %edi
c0106640:	56                   	push   %esi
c0106641:	53                   	push   %ebx
c0106642:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106648:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010664f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106656:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010665d:	c7 04 24 63 a3 10 c0 	movl   $0xc010a363,(%esp)
c0106664:	e8 38 9c ff ff       	call   c01002a1 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106669:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106670:	e9 22 01 00 00       	jmp    c0106797 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106675:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106678:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010667b:	89 d0                	mov    %edx,%eax
c010667d:	c1 e0 02             	shl    $0x2,%eax
c0106680:	01 d0                	add    %edx,%eax
c0106682:	c1 e0 02             	shl    $0x2,%eax
c0106685:	01 c8                	add    %ecx,%eax
c0106687:	8b 50 08             	mov    0x8(%eax),%edx
c010668a:	8b 40 04             	mov    0x4(%eax),%eax
c010668d:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106690:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106693:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106696:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106699:	89 d0                	mov    %edx,%eax
c010669b:	c1 e0 02             	shl    $0x2,%eax
c010669e:	01 d0                	add    %edx,%eax
c01066a0:	c1 e0 02             	shl    $0x2,%eax
c01066a3:	01 c8                	add    %ecx,%eax
c01066a5:	8b 48 0c             	mov    0xc(%eax),%ecx
c01066a8:	8b 58 10             	mov    0x10(%eax),%ebx
c01066ab:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01066ae:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01066b1:	01 c8                	add    %ecx,%eax
c01066b3:	11 da                	adc    %ebx,%edx
c01066b5:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01066b8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01066bb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01066be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066c1:	89 d0                	mov    %edx,%eax
c01066c3:	c1 e0 02             	shl    $0x2,%eax
c01066c6:	01 d0                	add    %edx,%eax
c01066c8:	c1 e0 02             	shl    $0x2,%eax
c01066cb:	01 c8                	add    %ecx,%eax
c01066cd:	83 c0 14             	add    $0x14,%eax
c01066d0:	8b 00                	mov    (%eax),%eax
c01066d2:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01066d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01066d8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01066db:	83 c0 ff             	add    $0xffffffff,%eax
c01066de:	83 d2 ff             	adc    $0xffffffff,%edx
c01066e1:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c01066e7:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c01066ed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01066f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066f3:	89 d0                	mov    %edx,%eax
c01066f5:	c1 e0 02             	shl    $0x2,%eax
c01066f8:	01 d0                	add    %edx,%eax
c01066fa:	c1 e0 02             	shl    $0x2,%eax
c01066fd:	01 c8                	add    %ecx,%eax
c01066ff:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106702:	8b 58 10             	mov    0x10(%eax),%ebx
c0106705:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106708:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c010670c:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0106712:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0106718:	89 44 24 14          	mov    %eax,0x14(%esp)
c010671c:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106720:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106723:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106726:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010672a:	89 54 24 10          	mov    %edx,0x10(%esp)
c010672e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0106732:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0106736:	c7 04 24 70 a3 10 c0 	movl   $0xc010a370,(%esp)
c010673d:	e8 5f 9b ff ff       	call   c01002a1 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0106742:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106745:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106748:	89 d0                	mov    %edx,%eax
c010674a:	c1 e0 02             	shl    $0x2,%eax
c010674d:	01 d0                	add    %edx,%eax
c010674f:	c1 e0 02             	shl    $0x2,%eax
c0106752:	01 c8                	add    %ecx,%eax
c0106754:	83 c0 14             	add    $0x14,%eax
c0106757:	8b 00                	mov    (%eax),%eax
c0106759:	83 f8 01             	cmp    $0x1,%eax
c010675c:	75 36                	jne    c0106794 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c010675e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106761:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106764:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106767:	77 2b                	ja     c0106794 <page_init+0x158>
c0106769:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010676c:	72 05                	jb     c0106773 <page_init+0x137>
c010676e:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0106771:	73 21                	jae    c0106794 <page_init+0x158>
c0106773:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106777:	77 1b                	ja     c0106794 <page_init+0x158>
c0106779:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010677d:	72 09                	jb     c0106788 <page_init+0x14c>
c010677f:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0106786:	77 0c                	ja     c0106794 <page_init+0x158>
                maxpa = end;
c0106788:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010678b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010678e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106791:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106794:	ff 45 dc             	incl   -0x24(%ebp)
c0106797:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010679a:	8b 00                	mov    (%eax),%eax
c010679c:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010679f:	0f 8f d0 fe ff ff    	jg     c0106675 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01067a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01067a9:	72 1d                	jb     c01067c8 <page_init+0x18c>
c01067ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01067af:	77 09                	ja     c01067ba <page_init+0x17e>
c01067b1:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01067b8:	76 0e                	jbe    c01067c8 <page_init+0x18c>
        maxpa = KMEMSIZE;
c01067ba:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01067c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01067c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01067cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01067ce:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01067d2:	c1 ea 0c             	shr    $0xc,%edx
c01067d5:	a3 80 3f 12 c0       	mov    %eax,0xc0123f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01067da:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01067e1:	b8 04 41 12 c0       	mov    $0xc0124104,%eax
c01067e6:	8d 50 ff             	lea    -0x1(%eax),%edx
c01067e9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01067ec:	01 d0                	add    %edx,%eax
c01067ee:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01067f1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01067f4:	ba 00 00 00 00       	mov    $0x0,%edx
c01067f9:	f7 75 ac             	divl   -0x54(%ebp)
c01067fc:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01067ff:	29 d0                	sub    %edx,%eax
c0106801:	a3 00 41 12 c0       	mov    %eax,0xc0124100

    for (i = 0; i < npage; i ++) {
c0106806:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010680d:	eb 26                	jmp    c0106835 <page_init+0x1f9>
        SetPageReserved(pages + i);
c010680f:	a1 00 41 12 c0       	mov    0xc0124100,%eax
c0106814:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106817:	c1 e2 05             	shl    $0x5,%edx
c010681a:	01 d0                	add    %edx,%eax
c010681c:	83 c0 04             	add    $0x4,%eax
c010681f:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0106826:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106829:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010682c:	8b 55 90             	mov    -0x70(%ebp),%edx
c010682f:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0106832:	ff 45 dc             	incl   -0x24(%ebp)
c0106835:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106838:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010683d:	39 c2                	cmp    %eax,%edx
c010683f:	72 ce                	jb     c010680f <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0106841:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106846:	c1 e0 05             	shl    $0x5,%eax
c0106849:	89 c2                	mov    %eax,%edx
c010684b:	a1 00 41 12 c0       	mov    0xc0124100,%eax
c0106850:	01 d0                	add    %edx,%eax
c0106852:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106855:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010685c:	77 23                	ja     c0106881 <page_init+0x245>
c010685e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106861:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106865:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c010686c:	c0 
c010686d:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0106874:	00 
c0106875:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010687c:	e8 77 9b ff ff       	call   c01003f8 <__panic>
c0106881:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106884:	05 00 00 00 40       	add    $0x40000000,%eax
c0106889:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010688c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106893:	e9 61 01 00 00       	jmp    c01069f9 <page_init+0x3bd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106898:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010689b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010689e:	89 d0                	mov    %edx,%eax
c01068a0:	c1 e0 02             	shl    $0x2,%eax
c01068a3:	01 d0                	add    %edx,%eax
c01068a5:	c1 e0 02             	shl    $0x2,%eax
c01068a8:	01 c8                	add    %ecx,%eax
c01068aa:	8b 50 08             	mov    0x8(%eax),%edx
c01068ad:	8b 40 04             	mov    0x4(%eax),%eax
c01068b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01068b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01068b6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01068b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01068bc:	89 d0                	mov    %edx,%eax
c01068be:	c1 e0 02             	shl    $0x2,%eax
c01068c1:	01 d0                	add    %edx,%eax
c01068c3:	c1 e0 02             	shl    $0x2,%eax
c01068c6:	01 c8                	add    %ecx,%eax
c01068c8:	8b 48 0c             	mov    0xc(%eax),%ecx
c01068cb:	8b 58 10             	mov    0x10(%eax),%ebx
c01068ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01068d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01068d4:	01 c8                	add    %ecx,%eax
c01068d6:	11 da                	adc    %ebx,%edx
c01068d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01068db:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01068de:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01068e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01068e4:	89 d0                	mov    %edx,%eax
c01068e6:	c1 e0 02             	shl    $0x2,%eax
c01068e9:	01 d0                	add    %edx,%eax
c01068eb:	c1 e0 02             	shl    $0x2,%eax
c01068ee:	01 c8                	add    %ecx,%eax
c01068f0:	83 c0 14             	add    $0x14,%eax
c01068f3:	8b 00                	mov    (%eax),%eax
c01068f5:	83 f8 01             	cmp    $0x1,%eax
c01068f8:	0f 85 f8 00 00 00    	jne    c01069f6 <page_init+0x3ba>
            if (begin < freemem) {
c01068fe:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106901:	ba 00 00 00 00       	mov    $0x0,%edx
c0106906:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106909:	72 17                	jb     c0106922 <page_init+0x2e6>
c010690b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010690e:	77 05                	ja     c0106915 <page_init+0x2d9>
c0106910:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106913:	76 0d                	jbe    c0106922 <page_init+0x2e6>
                begin = freemem;
c0106915:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106918:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010691b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0106922:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106926:	72 1d                	jb     c0106945 <page_init+0x309>
c0106928:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010692c:	77 09                	ja     c0106937 <page_init+0x2fb>
c010692e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0106935:	76 0e                	jbe    c0106945 <page_init+0x309>
                end = KMEMSIZE;
c0106937:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010693e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106945:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106948:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010694b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010694e:	0f 87 a2 00 00 00    	ja     c01069f6 <page_init+0x3ba>
c0106954:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106957:	72 09                	jb     c0106962 <page_init+0x326>
c0106959:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010695c:	0f 83 94 00 00 00    	jae    c01069f6 <page_init+0x3ba>
                begin = ROUNDUP(begin, PGSIZE);
c0106962:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0106969:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010696c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010696f:	01 d0                	add    %edx,%eax
c0106971:	48                   	dec    %eax
c0106972:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106975:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106978:	ba 00 00 00 00       	mov    $0x0,%edx
c010697d:	f7 75 9c             	divl   -0x64(%ebp)
c0106980:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106983:	29 d0                	sub    %edx,%eax
c0106985:	ba 00 00 00 00       	mov    $0x0,%edx
c010698a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010698d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106990:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106993:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106996:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106999:	ba 00 00 00 00       	mov    $0x0,%edx
c010699e:	89 c3                	mov    %eax,%ebx
c01069a0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c01069a6:	89 de                	mov    %ebx,%esi
c01069a8:	89 d0                	mov    %edx,%eax
c01069aa:	83 e0 00             	and    $0x0,%eax
c01069ad:	89 c7                	mov    %eax,%edi
c01069af:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01069b2:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01069b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01069b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01069bb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01069be:	77 36                	ja     c01069f6 <page_init+0x3ba>
c01069c0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01069c3:	72 05                	jb     c01069ca <page_init+0x38e>
c01069c5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01069c8:	73 2c                	jae    c01069f6 <page_init+0x3ba>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01069ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01069cd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01069d0:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01069d3:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01069d6:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01069da:	c1 ea 0c             	shr    $0xc,%edx
c01069dd:	89 c3                	mov    %eax,%ebx
c01069df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01069e2:	89 04 24             	mov    %eax,(%esp)
c01069e5:	e8 4b f8 ff ff       	call   c0106235 <pa2page>
c01069ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01069ee:	89 04 24             	mov    %eax,(%esp)
c01069f1:	e8 5d fb ff ff       	call   c0106553 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01069f6:	ff 45 dc             	incl   -0x24(%ebp)
c01069f9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01069fc:	8b 00                	mov    (%eax),%eax
c01069fe:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106a01:	0f 8f 91 fe ff ff    	jg     c0106898 <page_init+0x25c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0106a07:	90                   	nop
c0106a08:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0106a0e:	5b                   	pop    %ebx
c0106a0f:	5e                   	pop    %esi
c0106a10:	5f                   	pop    %edi
c0106a11:	5d                   	pop    %ebp
c0106a12:	c3                   	ret    

c0106a13 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0106a13:	55                   	push   %ebp
c0106a14:	89 e5                	mov    %esp,%ebp
c0106a16:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0106a19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a1c:	33 45 14             	xor    0x14(%ebp),%eax
c0106a1f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106a24:	85 c0                	test   %eax,%eax
c0106a26:	74 24                	je     c0106a4c <boot_map_segment+0x39>
c0106a28:	c7 44 24 0c ae a3 10 	movl   $0xc010a3ae,0xc(%esp)
c0106a2f:	c0 
c0106a30:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0106a37:	c0 
c0106a38:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0106a3f:	00 
c0106a40:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106a47:	e8 ac 99 ff ff       	call   c01003f8 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106a4c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106a53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a56:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106a5b:	89 c2                	mov    %eax,%edx
c0106a5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a60:	01 c2                	add    %eax,%edx
c0106a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a65:	01 d0                	add    %edx,%eax
c0106a67:	48                   	dec    %eax
c0106a68:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a6e:	ba 00 00 00 00       	mov    $0x0,%edx
c0106a73:	f7 75 f0             	divl   -0x10(%ebp)
c0106a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a79:	29 d0                	sub    %edx,%eax
c0106a7b:	c1 e8 0c             	shr    $0xc,%eax
c0106a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106a81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a84:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106a87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a8f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0106a92:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106aa0:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106aa3:	eb 68                	jmp    c0106b0d <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106aa5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106aac:	00 
c0106aad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ab7:	89 04 24             	mov    %eax,(%esp)
c0106aba:	e8 81 01 00 00       	call   c0106c40 <get_pte>
c0106abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0106ac2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106ac6:	75 24                	jne    c0106aec <boot_map_segment+0xd9>
c0106ac8:	c7 44 24 0c da a3 10 	movl   $0xc010a3da,0xc(%esp)
c0106acf:	c0 
c0106ad0:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0106ad7:	c0 
c0106ad8:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0106adf:	00 
c0106ae0:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106ae7:	e8 0c 99 ff ff       	call   c01003f8 <__panic>
        *ptep = pa | PTE_P | perm;
c0106aec:	8b 45 14             	mov    0x14(%ebp),%eax
c0106aef:	0b 45 18             	or     0x18(%ebp),%eax
c0106af2:	83 c8 01             	or     $0x1,%eax
c0106af5:	89 c2                	mov    %eax,%edx
c0106af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106afa:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106afc:	ff 4d f4             	decl   -0xc(%ebp)
c0106aff:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106b06:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106b0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b11:	75 92                	jne    c0106aa5 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0106b13:	90                   	nop
c0106b14:	c9                   	leave  
c0106b15:	c3                   	ret    

c0106b16 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0106b16:	55                   	push   %ebp
c0106b17:	89 e5                	mov    %esp,%ebp
c0106b19:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0106b1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b23:	e8 4b fa ff ff       	call   c0106573 <alloc_pages>
c0106b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0106b2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b2f:	75 1c                	jne    c0106b4d <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0106b31:	c7 44 24 08 e7 a3 10 	movl   $0xc010a3e7,0x8(%esp)
c0106b38:	c0 
c0106b39:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0106b40:	00 
c0106b41:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106b48:	e8 ab 98 ff ff       	call   c01003f8 <__panic>
    }
    return page2kva(p);
c0106b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b50:	89 04 24             	mov    %eax,(%esp)
c0106b53:	e8 22 f7 ff ff       	call   c010627a <page2kva>
}
c0106b58:	c9                   	leave  
c0106b59:	c3                   	ret    

c0106b5a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0106b5a:	55                   	push   %ebp
c0106b5b:	89 e5                	mov    %esp,%ebp
c0106b5d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0106b60:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106b68:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106b6f:	77 23                	ja     c0106b94 <pmm_init+0x3a>
c0106b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b74:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b78:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c0106b7f:	c0 
c0106b80:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0106b87:	00 
c0106b88:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106b8f:	e8 64 98 ff ff       	call   c01003f8 <__panic>
c0106b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b97:	05 00 00 00 40       	add    $0x40000000,%eax
c0106b9c:	a3 fc 40 12 c0       	mov    %eax,0xc01240fc
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0106ba1:	e8 79 f9 ff ff       	call   c010651f <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0106ba6:	e8 91 fa ff ff       	call   c010663c <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0106bab:	e8 a9 04 00 00       	call   c0107059 <check_alloc_page>

    check_pgdir();
c0106bb0:	e8 c3 04 00 00       	call   c0107078 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0106bb5:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106bba:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0106bc0:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bc8:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106bcf:	77 23                	ja     c0106bf4 <pmm_init+0x9a>
c0106bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106bd8:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c0106bdf:	c0 
c0106be0:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0106be7:	00 
c0106be8:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106bef:	e8 04 98 ff ff       	call   c01003f8 <__panic>
c0106bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bf7:	05 00 00 00 40       	add    $0x40000000,%eax
c0106bfc:	83 c8 03             	or     $0x3,%eax
c0106bff:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0106c01:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c06:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0106c0d:	00 
c0106c0e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106c15:	00 
c0106c16:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0106c1d:	38 
c0106c1e:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0106c25:	c0 
c0106c26:	89 04 24             	mov    %eax,(%esp)
c0106c29:	e8 e5 fd ff ff       	call   c0106a13 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106c2e:	e8 03 f8 ff ff       	call   c0106436 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106c33:	e8 dc 0a 00 00       	call   c0107714 <check_boot_pgdir>

    print_pgdir();
c0106c38:	e8 55 0f 00 00       	call   c0107b92 <print_pgdir>

}
c0106c3d:	90                   	nop
c0106c3e:	c9                   	leave  
c0106c3f:	c3                   	ret    

c0106c40 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0106c40:	55                   	push   %ebp
c0106c41:	89 e5                	mov    %esp,%ebp
c0106c43:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep=&pgdir[PDX(la)];
c0106c46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c49:	c1 e8 16             	shr    $0x16,%eax
c0106c4c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c56:	01 d0                	add    %edx,%eax
c0106c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P))
c0106c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c5e:	8b 00                	mov    (%eax),%eax
c0106c60:	83 e0 01             	and    $0x1,%eax
c0106c63:	85 c0                	test   %eax,%eax
c0106c65:	0f 85 af 00 00 00    	jne    c0106d1a <get_pte+0xda>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0106c6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106c6f:	74 15                	je     c0106c86 <get_pte+0x46>
c0106c71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106c78:	e8 f6 f8 ff ff       	call   c0106573 <alloc_pages>
c0106c7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106c84:	75 0a                	jne    c0106c90 <get_pte+0x50>
            return NULL;
c0106c86:	b8 00 00 00 00       	mov    $0x0,%eax
c0106c8b:	e9 e7 00 00 00       	jmp    c0106d77 <get_pte+0x137>
        }
        set_page_ref(page,1);
c0106c90:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c97:	00 
c0106c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c9b:	89 04 24             	mov    %eax,(%esp)
c0106c9e:	e8 d5 f6 ff ff       	call   c0106378 <set_page_ref>
        uintptr_t pa=page2pa(page);
c0106ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ca6:	89 04 24             	mov    %eax,(%esp)
c0106ca9:	e8 71 f5 ff ff       	call   c010621f <page2pa>
c0106cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa),0,PGSIZE);
c0106cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106cb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106cba:	c1 e8 0c             	shr    $0xc,%eax
c0106cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106cc0:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106cc5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106cc8:	72 23                	jb     c0106ced <get_pte+0xad>
c0106cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ccd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cd1:	c7 44 24 08 d8 a2 10 	movl   $0xc010a2d8,0x8(%esp)
c0106cd8:	c0 
c0106cd9:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0106ce0:	00 
c0106ce1:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106ce8:	e8 0b 97 ff ff       	call   c01003f8 <__panic>
c0106ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106cf0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106cf5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106cfc:	00 
c0106cfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106d04:	00 
c0106d05:	89 04 24             	mov    %eax,(%esp)
c0106d08:	e8 f9 15 00 00       	call   c0108306 <memset>
        *pdep= pa|PTE_P|PTE_W|PTE_U;
c0106d0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d10:	83 c8 07             	or     $0x7,%eax
c0106d13:	89 c2                	mov    %eax,%edx
c0106d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d18:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d1d:	8b 00                	mov    (%eax),%eax
c0106d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d24:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d2a:	c1 e8 0c             	shr    $0xc,%eax
c0106d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106d30:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106d35:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106d38:	72 23                	jb     c0106d5d <get_pte+0x11d>
c0106d3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106d41:	c7 44 24 08 d8 a2 10 	movl   $0xc010a2d8,0x8(%esp)
c0106d48:	c0 
c0106d49:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0106d50:	00 
c0106d51:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106d58:	e8 9b 96 ff ff       	call   c01003f8 <__panic>
c0106d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d60:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106d65:	89 c2                	mov    %eax,%edx
c0106d67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d6a:	c1 e8 0c             	shr    $0xc,%eax
c0106d6d:	25 ff 03 00 00       	and    $0x3ff,%eax
c0106d72:	c1 e0 02             	shl    $0x2,%eax
c0106d75:	01 d0                	add    %edx,%eax
}
c0106d77:	c9                   	leave  
c0106d78:	c3                   	ret    

c0106d79 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0106d79:	55                   	push   %ebp
c0106d7a:	89 e5                	mov    %esp,%ebp
c0106d7c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106d7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106d86:	00 
c0106d87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d91:	89 04 24             	mov    %eax,(%esp)
c0106d94:	e8 a7 fe ff ff       	call   c0106c40 <get_pte>
c0106d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0106d9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106da0:	74 08                	je     c0106daa <get_page+0x31>
        *ptep_store = ptep;
c0106da2:	8b 45 10             	mov    0x10(%ebp),%eax
c0106da5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106da8:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106daa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106dae:	74 1b                	je     c0106dcb <get_page+0x52>
c0106db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106db3:	8b 00                	mov    (%eax),%eax
c0106db5:	83 e0 01             	and    $0x1,%eax
c0106db8:	85 c0                	test   %eax,%eax
c0106dba:	74 0f                	je     c0106dcb <get_page+0x52>
        return pte2page(*ptep);
c0106dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dbf:	8b 00                	mov    (%eax),%eax
c0106dc1:	89 04 24             	mov    %eax,(%esp)
c0106dc4:	e8 4f f5 ff ff       	call   c0106318 <pte2page>
c0106dc9:	eb 05                	jmp    c0106dd0 <get_page+0x57>
    }
    return NULL;
c0106dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106dd0:	c9                   	leave  
c0106dd1:	c3                   	ret    

c0106dd2 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106dd2:	55                   	push   %ebp
c0106dd3:	89 e5                	mov    %esp,%ebp
c0106dd5:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if(*ptep & PTE_P)
c0106dd8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ddb:	8b 00                	mov    (%eax),%eax
c0106ddd:	83 e0 01             	and    $0x1,%eax
c0106de0:	85 c0                	test   %eax,%eax
c0106de2:	74 4d                	je     c0106e31 <page_remove_pte+0x5f>
    {
        struct Page *page= pte2page(*ptep);
c0106de4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106de7:	8b 00                	mov    (%eax),%eax
c0106de9:	89 04 24             	mov    %eax,(%esp)
c0106dec:	e8 27 f5 ff ff       	call   c0106318 <pte2page>
c0106df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0)
c0106df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106df7:	89 04 24             	mov    %eax,(%esp)
c0106dfa:	e8 9e f5 ff ff       	call   c010639d <page_ref_dec>
c0106dff:	85 c0                	test   %eax,%eax
c0106e01:	75 13                	jne    c0106e16 <page_remove_pte+0x44>
            // if(i==0)
        {
            free_page(page);
c0106e03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106e0a:	00 
c0106e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e0e:	89 04 24             	mov    %eax,(%esp)
c0106e11:	e8 c8 f7 ff ff       	call   c01065de <free_pages>
        }
        *ptep=0;
c0106e16:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e29:	89 04 24             	mov    %eax,(%esp)
c0106e2c:	e8 01 01 00 00       	call   c0106f32 <tlb_invalidate>
    }
}
c0106e31:	90                   	nop
c0106e32:	c9                   	leave  
c0106e33:	c3                   	ret    

c0106e34 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106e34:	55                   	push   %ebp
c0106e35:	89 e5                	mov    %esp,%ebp
c0106e37:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106e3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106e41:	00 
c0106e42:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e4c:	89 04 24             	mov    %eax,(%esp)
c0106e4f:	e8 ec fd ff ff       	call   c0106c40 <get_pte>
c0106e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106e57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106e5b:	74 19                	je     c0106e76 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0106e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e60:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e6e:	89 04 24             	mov    %eax,(%esp)
c0106e71:	e8 5c ff ff ff       	call   c0106dd2 <page_remove_pte>
    }
}
c0106e76:	90                   	nop
c0106e77:	c9                   	leave  
c0106e78:	c3                   	ret    

c0106e79 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0106e79:	55                   	push   %ebp
c0106e7a:	89 e5                	mov    %esp,%ebp
c0106e7c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106e7f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106e86:	00 
c0106e87:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e91:	89 04 24             	mov    %eax,(%esp)
c0106e94:	e8 a7 fd ff ff       	call   c0106c40 <get_pte>
c0106e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106e9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ea0:	75 0a                	jne    c0106eac <page_insert+0x33>
        return -E_NO_MEM;
c0106ea2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0106ea7:	e9 84 00 00 00       	jmp    c0106f30 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106eac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106eaf:	89 04 24             	mov    %eax,(%esp)
c0106eb2:	e8 cf f4 ff ff       	call   c0106386 <page_ref_inc>
    if (*ptep & PTE_P) {
c0106eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106eba:	8b 00                	mov    (%eax),%eax
c0106ebc:	83 e0 01             	and    $0x1,%eax
c0106ebf:	85 c0                	test   %eax,%eax
c0106ec1:	74 3e                	je     c0106f01 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ec6:	8b 00                	mov    (%eax),%eax
c0106ec8:	89 04 24             	mov    %eax,(%esp)
c0106ecb:	e8 48 f4 ff ff       	call   c0106318 <pte2page>
c0106ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ed6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ed9:	75 0d                	jne    c0106ee8 <page_insert+0x6f>
            page_ref_dec(page);
c0106edb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ede:	89 04 24             	mov    %eax,(%esp)
c0106ee1:	e8 b7 f4 ff ff       	call   c010639d <page_ref_dec>
c0106ee6:	eb 19                	jmp    c0106f01 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106eeb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106eef:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ef6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ef9:	89 04 24             	mov    %eax,(%esp)
c0106efc:	e8 d1 fe ff ff       	call   c0106dd2 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f04:	89 04 24             	mov    %eax,(%esp)
c0106f07:	e8 13 f3 ff ff       	call   c010621f <page2pa>
c0106f0c:	0b 45 14             	or     0x14(%ebp),%eax
c0106f0f:	83 c8 01             	or     $0x1,%eax
c0106f12:	89 c2                	mov    %eax,%edx
c0106f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f17:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106f19:	8b 45 10             	mov    0x10(%ebp),%eax
c0106f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f20:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f23:	89 04 24             	mov    %eax,(%esp)
c0106f26:	e8 07 00 00 00       	call   c0106f32 <tlb_invalidate>
    return 0;
c0106f2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106f30:	c9                   	leave  
c0106f31:	c3                   	ret    

c0106f32 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106f32:	55                   	push   %ebp
c0106f33:	89 e5                	mov    %esp,%ebp
c0106f35:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106f38:	0f 20 d8             	mov    %cr3,%eax
c0106f3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0106f3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0106f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f47:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106f4e:	77 23                	ja     c0106f73 <tlb_invalidate+0x41>
c0106f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f57:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c0106f5e:	c0 
c0106f5f:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0106f66:	00 
c0106f67:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106f6e:	e8 85 94 ff ff       	call   c01003f8 <__panic>
c0106f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f76:	05 00 00 00 40       	add    $0x40000000,%eax
c0106f7b:	39 c2                	cmp    %eax,%edx
c0106f7d:	75 0c                	jne    c0106f8b <tlb_invalidate+0x59>
        invlpg((void *)la);
c0106f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f82:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0106f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f88:	0f 01 38             	invlpg (%eax)
    }
}
c0106f8b:	90                   	nop
c0106f8c:	c9                   	leave  
c0106f8d:	c3                   	ret    

c0106f8e <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106f8e:	55                   	push   %ebp
c0106f8f:	89 e5                	mov    %esp,%ebp
c0106f91:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0106f94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f9b:	e8 d3 f5 ff ff       	call   c0106573 <alloc_pages>
c0106fa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0106fa3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106fa7:	0f 84 a7 00 00 00    	je     c0107054 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106fad:	8b 45 10             	mov    0x10(%ebp),%eax
c0106fb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fc5:	89 04 24             	mov    %eax,(%esp)
c0106fc8:	e8 ac fe ff ff       	call   c0106e79 <page_insert>
c0106fcd:	85 c0                	test   %eax,%eax
c0106fcf:	74 1a                	je     c0106feb <pgdir_alloc_page+0x5d>
            free_page(page);
c0106fd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106fd8:	00 
c0106fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fdc:	89 04 24             	mov    %eax,(%esp)
c0106fdf:	e8 fa f5 ff ff       	call   c01065de <free_pages>
            return NULL;
c0106fe4:	b8 00 00 00 00       	mov    $0x0,%eax
c0106fe9:	eb 6c                	jmp    c0107057 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0106feb:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0106ff0:	85 c0                	test   %eax,%eax
c0106ff2:	74 60                	je     c0107054 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0106ff4:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0106ff9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107000:	00 
c0107001:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107004:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107008:	8b 55 0c             	mov    0xc(%ebp),%edx
c010700b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010700f:	89 04 24             	mov    %eax,(%esp)
c0107012:	e8 0b d1 ff ff       	call   c0104122 <swap_map_swappable>
            page->pra_vaddr=la;
c0107017:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010701a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010701d:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0107020:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107023:	89 04 24             	mov    %eax,(%esp)
c0107026:	e8 43 f3 ff ff       	call   c010636e <page_ref>
c010702b:	83 f8 01             	cmp    $0x1,%eax
c010702e:	74 24                	je     c0107054 <pgdir_alloc_page+0xc6>
c0107030:	c7 44 24 0c 00 a4 10 	movl   $0xc010a400,0xc(%esp)
c0107037:	c0 
c0107038:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010703f:	c0 
c0107040:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0107047:	00 
c0107048:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010704f:	e8 a4 93 ff ff       	call   c01003f8 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0107054:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107057:	c9                   	leave  
c0107058:	c3                   	ret    

c0107059 <check_alloc_page>:

static void
check_alloc_page(void) {
c0107059:	55                   	push   %ebp
c010705a:	89 e5                	mov    %esp,%ebp
c010705c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010705f:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0107064:	8b 40 18             	mov    0x18(%eax),%eax
c0107067:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0107069:	c7 04 24 14 a4 10 c0 	movl   $0xc010a414,(%esp)
c0107070:	e8 2c 92 ff ff       	call   c01002a1 <cprintf>
}
c0107075:	90                   	nop
c0107076:	c9                   	leave  
c0107077:	c3                   	ret    

c0107078 <check_pgdir>:

static void
check_pgdir(void) {
c0107078:	55                   	push   %ebp
c0107079:	89 e5                	mov    %esp,%ebp
c010707b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010707e:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0107083:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0107088:	76 24                	jbe    c01070ae <check_pgdir+0x36>
c010708a:	c7 44 24 0c 33 a4 10 	movl   $0xc010a433,0xc(%esp)
c0107091:	c0 
c0107092:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107099:	c0 
c010709a:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c01070a1:	00 
c01070a2:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01070a9:	e8 4a 93 ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01070ae:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01070b3:	85 c0                	test   %eax,%eax
c01070b5:	74 0e                	je     c01070c5 <check_pgdir+0x4d>
c01070b7:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01070bc:	25 ff 0f 00 00       	and    $0xfff,%eax
c01070c1:	85 c0                	test   %eax,%eax
c01070c3:	74 24                	je     c01070e9 <check_pgdir+0x71>
c01070c5:	c7 44 24 0c 50 a4 10 	movl   $0xc010a450,0xc(%esp)
c01070cc:	c0 
c01070cd:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01070d4:	c0 
c01070d5:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c01070dc:	00 
c01070dd:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01070e4:	e8 0f 93 ff ff       	call   c01003f8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01070e9:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01070ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01070f5:	00 
c01070f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01070fd:	00 
c01070fe:	89 04 24             	mov    %eax,(%esp)
c0107101:	e8 73 fc ff ff       	call   c0106d79 <get_page>
c0107106:	85 c0                	test   %eax,%eax
c0107108:	74 24                	je     c010712e <check_pgdir+0xb6>
c010710a:	c7 44 24 0c 88 a4 10 	movl   $0xc010a488,0xc(%esp)
c0107111:	c0 
c0107112:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107119:	c0 
c010711a:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0107121:	00 
c0107122:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107129:	e8 ca 92 ff ff       	call   c01003f8 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010712e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107135:	e8 39 f4 ff ff       	call   c0106573 <alloc_pages>
c010713a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010713d:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107142:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107149:	00 
c010714a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107151:	00 
c0107152:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107155:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107159:	89 04 24             	mov    %eax,(%esp)
c010715c:	e8 18 fd ff ff       	call   c0106e79 <page_insert>
c0107161:	85 c0                	test   %eax,%eax
c0107163:	74 24                	je     c0107189 <check_pgdir+0x111>
c0107165:	c7 44 24 0c b0 a4 10 	movl   $0xc010a4b0,0xc(%esp)
c010716c:	c0 
c010716d:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107174:	c0 
c0107175:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c010717c:	00 
c010717d:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107184:	e8 6f 92 ff ff       	call   c01003f8 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0107189:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010718e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107195:	00 
c0107196:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010719d:	00 
c010719e:	89 04 24             	mov    %eax,(%esp)
c01071a1:	e8 9a fa ff ff       	call   c0106c40 <get_pte>
c01071a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01071a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01071ad:	75 24                	jne    c01071d3 <check_pgdir+0x15b>
c01071af:	c7 44 24 0c dc a4 10 	movl   $0xc010a4dc,0xc(%esp)
c01071b6:	c0 
c01071b7:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01071be:	c0 
c01071bf:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c01071c6:	00 
c01071c7:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01071ce:	e8 25 92 ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c01071d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01071d6:	8b 00                	mov    (%eax),%eax
c01071d8:	89 04 24             	mov    %eax,(%esp)
c01071db:	e8 38 f1 ff ff       	call   c0106318 <pte2page>
c01071e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01071e3:	74 24                	je     c0107209 <check_pgdir+0x191>
c01071e5:	c7 44 24 0c 09 a5 10 	movl   $0xc010a509,0xc(%esp)
c01071ec:	c0 
c01071ed:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01071f4:	c0 
c01071f5:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c01071fc:	00 
c01071fd:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107204:	e8 ef 91 ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 1);
c0107209:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010720c:	89 04 24             	mov    %eax,(%esp)
c010720f:	e8 5a f1 ff ff       	call   c010636e <page_ref>
c0107214:	83 f8 01             	cmp    $0x1,%eax
c0107217:	74 24                	je     c010723d <check_pgdir+0x1c5>
c0107219:	c7 44 24 0c 1f a5 10 	movl   $0xc010a51f,0xc(%esp)
c0107220:	c0 
c0107221:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107228:	c0 
c0107229:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0107230:	00 
c0107231:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107238:	e8 bb 91 ff ff       	call   c01003f8 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010723d:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107242:	8b 00                	mov    (%eax),%eax
c0107244:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107249:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010724c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010724f:	c1 e8 0c             	shr    $0xc,%eax
c0107252:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107255:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010725a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010725d:	72 23                	jb     c0107282 <check_pgdir+0x20a>
c010725f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107262:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107266:	c7 44 24 08 d8 a2 10 	movl   $0xc010a2d8,0x8(%esp)
c010726d:	c0 
c010726e:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0107275:	00 
c0107276:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010727d:	e8 76 91 ff ff       	call   c01003f8 <__panic>
c0107282:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107285:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010728a:	83 c0 04             	add    $0x4,%eax
c010728d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0107290:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107295:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010729c:	00 
c010729d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01072a4:	00 
c01072a5:	89 04 24             	mov    %eax,(%esp)
c01072a8:	e8 93 f9 ff ff       	call   c0106c40 <get_pte>
c01072ad:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01072b0:	74 24                	je     c01072d6 <check_pgdir+0x25e>
c01072b2:	c7 44 24 0c 34 a5 10 	movl   $0xc010a534,0xc(%esp)
c01072b9:	c0 
c01072ba:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01072c1:	c0 
c01072c2:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c01072c9:	00 
c01072ca:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01072d1:	e8 22 91 ff ff       	call   c01003f8 <__panic>

    p2 = alloc_page();
c01072d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01072dd:	e8 91 f2 ff ff       	call   c0106573 <alloc_pages>
c01072e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01072e5:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01072ea:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01072f1:	00 
c01072f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01072f9:	00 
c01072fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01072fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107301:	89 04 24             	mov    %eax,(%esp)
c0107304:	e8 70 fb ff ff       	call   c0106e79 <page_insert>
c0107309:	85 c0                	test   %eax,%eax
c010730b:	74 24                	je     c0107331 <check_pgdir+0x2b9>
c010730d:	c7 44 24 0c 5c a5 10 	movl   $0xc010a55c,0xc(%esp)
c0107314:	c0 
c0107315:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010731c:	c0 
c010731d:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0107324:	00 
c0107325:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010732c:	e8 c7 90 ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107331:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107336:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010733d:	00 
c010733e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107345:	00 
c0107346:	89 04 24             	mov    %eax,(%esp)
c0107349:	e8 f2 f8 ff ff       	call   c0106c40 <get_pte>
c010734e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107351:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107355:	75 24                	jne    c010737b <check_pgdir+0x303>
c0107357:	c7 44 24 0c 94 a5 10 	movl   $0xc010a594,0xc(%esp)
c010735e:	c0 
c010735f:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107366:	c0 
c0107367:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c010736e:	00 
c010736f:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107376:	e8 7d 90 ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_U);
c010737b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010737e:	8b 00                	mov    (%eax),%eax
c0107380:	83 e0 04             	and    $0x4,%eax
c0107383:	85 c0                	test   %eax,%eax
c0107385:	75 24                	jne    c01073ab <check_pgdir+0x333>
c0107387:	c7 44 24 0c c4 a5 10 	movl   $0xc010a5c4,0xc(%esp)
c010738e:	c0 
c010738f:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107396:	c0 
c0107397:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c010739e:	00 
c010739f:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01073a6:	e8 4d 90 ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_W);
c01073ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073ae:	8b 00                	mov    (%eax),%eax
c01073b0:	83 e0 02             	and    $0x2,%eax
c01073b3:	85 c0                	test   %eax,%eax
c01073b5:	75 24                	jne    c01073db <check_pgdir+0x363>
c01073b7:	c7 44 24 0c d2 a5 10 	movl   $0xc010a5d2,0xc(%esp)
c01073be:	c0 
c01073bf:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01073c6:	c0 
c01073c7:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01073ce:	00 
c01073cf:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01073d6:	e8 1d 90 ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01073db:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01073e0:	8b 00                	mov    (%eax),%eax
c01073e2:	83 e0 04             	and    $0x4,%eax
c01073e5:	85 c0                	test   %eax,%eax
c01073e7:	75 24                	jne    c010740d <check_pgdir+0x395>
c01073e9:	c7 44 24 0c e0 a5 10 	movl   $0xc010a5e0,0xc(%esp)
c01073f0:	c0 
c01073f1:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01073f8:	c0 
c01073f9:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0107400:	00 
c0107401:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107408:	e8 eb 8f ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 1);
c010740d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107410:	89 04 24             	mov    %eax,(%esp)
c0107413:	e8 56 ef ff ff       	call   c010636e <page_ref>
c0107418:	83 f8 01             	cmp    $0x1,%eax
c010741b:	74 24                	je     c0107441 <check_pgdir+0x3c9>
c010741d:	c7 44 24 0c f6 a5 10 	movl   $0xc010a5f6,0xc(%esp)
c0107424:	c0 
c0107425:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010742c:	c0 
c010742d:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0107434:	00 
c0107435:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010743c:	e8 b7 8f ff ff       	call   c01003f8 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0107441:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107446:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010744d:	00 
c010744e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107455:	00 
c0107456:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107459:	89 54 24 04          	mov    %edx,0x4(%esp)
c010745d:	89 04 24             	mov    %eax,(%esp)
c0107460:	e8 14 fa ff ff       	call   c0106e79 <page_insert>
c0107465:	85 c0                	test   %eax,%eax
c0107467:	74 24                	je     c010748d <check_pgdir+0x415>
c0107469:	c7 44 24 0c 08 a6 10 	movl   $0xc010a608,0xc(%esp)
c0107470:	c0 
c0107471:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107478:	c0 
c0107479:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0107480:	00 
c0107481:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107488:	e8 6b 8f ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 2);
c010748d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107490:	89 04 24             	mov    %eax,(%esp)
c0107493:	e8 d6 ee ff ff       	call   c010636e <page_ref>
c0107498:	83 f8 02             	cmp    $0x2,%eax
c010749b:	74 24                	je     c01074c1 <check_pgdir+0x449>
c010749d:	c7 44 24 0c 34 a6 10 	movl   $0xc010a634,0xc(%esp)
c01074a4:	c0 
c01074a5:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01074ac:	c0 
c01074ad:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01074b4:	00 
c01074b5:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01074bc:	e8 37 8f ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c01074c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074c4:	89 04 24             	mov    %eax,(%esp)
c01074c7:	e8 a2 ee ff ff       	call   c010636e <page_ref>
c01074cc:	85 c0                	test   %eax,%eax
c01074ce:	74 24                	je     c01074f4 <check_pgdir+0x47c>
c01074d0:	c7 44 24 0c 46 a6 10 	movl   $0xc010a646,0xc(%esp)
c01074d7:	c0 
c01074d8:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01074df:	c0 
c01074e0:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c01074e7:	00 
c01074e8:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01074ef:	e8 04 8f ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01074f4:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01074f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107500:	00 
c0107501:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107508:	00 
c0107509:	89 04 24             	mov    %eax,(%esp)
c010750c:	e8 2f f7 ff ff       	call   c0106c40 <get_pte>
c0107511:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107514:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107518:	75 24                	jne    c010753e <check_pgdir+0x4c6>
c010751a:	c7 44 24 0c 94 a5 10 	movl   $0xc010a594,0xc(%esp)
c0107521:	c0 
c0107522:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107529:	c0 
c010752a:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0107531:	00 
c0107532:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107539:	e8 ba 8e ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c010753e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107541:	8b 00                	mov    (%eax),%eax
c0107543:	89 04 24             	mov    %eax,(%esp)
c0107546:	e8 cd ed ff ff       	call   c0106318 <pte2page>
c010754b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010754e:	74 24                	je     c0107574 <check_pgdir+0x4fc>
c0107550:	c7 44 24 0c 09 a5 10 	movl   $0xc010a509,0xc(%esp)
c0107557:	c0 
c0107558:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010755f:	c0 
c0107560:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0107567:	00 
c0107568:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010756f:	e8 84 8e ff ff       	call   c01003f8 <__panic>
    assert((*ptep & PTE_U) == 0);
c0107574:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107577:	8b 00                	mov    (%eax),%eax
c0107579:	83 e0 04             	and    $0x4,%eax
c010757c:	85 c0                	test   %eax,%eax
c010757e:	74 24                	je     c01075a4 <check_pgdir+0x52c>
c0107580:	c7 44 24 0c 58 a6 10 	movl   $0xc010a658,0xc(%esp)
c0107587:	c0 
c0107588:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010758f:	c0 
c0107590:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0107597:	00 
c0107598:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010759f:	e8 54 8e ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, 0x0);
c01075a4:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01075a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01075b0:	00 
c01075b1:	89 04 24             	mov    %eax,(%esp)
c01075b4:	e8 7b f8 ff ff       	call   c0106e34 <page_remove>
    assert(page_ref(p1) == 1);
c01075b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075bc:	89 04 24             	mov    %eax,(%esp)
c01075bf:	e8 aa ed ff ff       	call   c010636e <page_ref>
c01075c4:	83 f8 01             	cmp    $0x1,%eax
c01075c7:	74 24                	je     c01075ed <check_pgdir+0x575>
c01075c9:	c7 44 24 0c 1f a5 10 	movl   $0xc010a51f,0xc(%esp)
c01075d0:	c0 
c01075d1:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01075d8:	c0 
c01075d9:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c01075e0:	00 
c01075e1:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01075e8:	e8 0b 8e ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c01075ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075f0:	89 04 24             	mov    %eax,(%esp)
c01075f3:	e8 76 ed ff ff       	call   c010636e <page_ref>
c01075f8:	85 c0                	test   %eax,%eax
c01075fa:	74 24                	je     c0107620 <check_pgdir+0x5a8>
c01075fc:	c7 44 24 0c 46 a6 10 	movl   $0xc010a646,0xc(%esp)
c0107603:	c0 
c0107604:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010760b:	c0 
c010760c:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0107613:	00 
c0107614:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010761b:	e8 d8 8d ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0107620:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107625:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010762c:	00 
c010762d:	89 04 24             	mov    %eax,(%esp)
c0107630:	e8 ff f7 ff ff       	call   c0106e34 <page_remove>
    assert(page_ref(p1) == 0);
c0107635:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107638:	89 04 24             	mov    %eax,(%esp)
c010763b:	e8 2e ed ff ff       	call   c010636e <page_ref>
c0107640:	85 c0                	test   %eax,%eax
c0107642:	74 24                	je     c0107668 <check_pgdir+0x5f0>
c0107644:	c7 44 24 0c 6d a6 10 	movl   $0xc010a66d,0xc(%esp)
c010764b:	c0 
c010764c:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107653:	c0 
c0107654:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c010765b:	00 
c010765c:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107663:	e8 90 8d ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c0107668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010766b:	89 04 24             	mov    %eax,(%esp)
c010766e:	e8 fb ec ff ff       	call   c010636e <page_ref>
c0107673:	85 c0                	test   %eax,%eax
c0107675:	74 24                	je     c010769b <check_pgdir+0x623>
c0107677:	c7 44 24 0c 46 a6 10 	movl   $0xc010a646,0xc(%esp)
c010767e:	c0 
c010767f:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107686:	c0 
c0107687:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c010768e:	00 
c010768f:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107696:	e8 5d 8d ff ff       	call   c01003f8 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010769b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01076a0:	8b 00                	mov    (%eax),%eax
c01076a2:	89 04 24             	mov    %eax,(%esp)
c01076a5:	e8 ac ec ff ff       	call   c0106356 <pde2page>
c01076aa:	89 04 24             	mov    %eax,(%esp)
c01076ad:	e8 bc ec ff ff       	call   c010636e <page_ref>
c01076b2:	83 f8 01             	cmp    $0x1,%eax
c01076b5:	74 24                	je     c01076db <check_pgdir+0x663>
c01076b7:	c7 44 24 0c 80 a6 10 	movl   $0xc010a680,0xc(%esp)
c01076be:	c0 
c01076bf:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01076c6:	c0 
c01076c7:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c01076ce:	00 
c01076cf:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01076d6:	e8 1d 8d ff ff       	call   c01003f8 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01076db:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01076e0:	8b 00                	mov    (%eax),%eax
c01076e2:	89 04 24             	mov    %eax,(%esp)
c01076e5:	e8 6c ec ff ff       	call   c0106356 <pde2page>
c01076ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01076f1:	00 
c01076f2:	89 04 24             	mov    %eax,(%esp)
c01076f5:	e8 e4 ee ff ff       	call   c01065de <free_pages>
    boot_pgdir[0] = 0;
c01076fa:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01076ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107705:	c7 04 24 a7 a6 10 c0 	movl   $0xc010a6a7,(%esp)
c010770c:	e8 90 8b ff ff       	call   c01002a1 <cprintf>
}
c0107711:	90                   	nop
c0107712:	c9                   	leave  
c0107713:	c3                   	ret    

c0107714 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107714:	55                   	push   %ebp
c0107715:	89 e5                	mov    %esp,%ebp
c0107717:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010771a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107721:	e9 ca 00 00 00       	jmp    c01077f0 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107726:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107729:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010772c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010772f:	c1 e8 0c             	shr    $0xc,%eax
c0107732:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107735:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010773a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010773d:	72 23                	jb     c0107762 <check_boot_pgdir+0x4e>
c010773f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107742:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107746:	c7 44 24 08 d8 a2 10 	movl   $0xc010a2d8,0x8(%esp)
c010774d:	c0 
c010774e:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0107755:	00 
c0107756:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010775d:	e8 96 8c ff ff       	call   c01003f8 <__panic>
c0107762:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107765:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010776a:	89 c2                	mov    %eax,%edx
c010776c:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107771:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107778:	00 
c0107779:	89 54 24 04          	mov    %edx,0x4(%esp)
c010777d:	89 04 24             	mov    %eax,(%esp)
c0107780:	e8 bb f4 ff ff       	call   c0106c40 <get_pte>
c0107785:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107788:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010778c:	75 24                	jne    c01077b2 <check_boot_pgdir+0x9e>
c010778e:	c7 44 24 0c c4 a6 10 	movl   $0xc010a6c4,0xc(%esp)
c0107795:	c0 
c0107796:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010779d:	c0 
c010779e:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01077a5:	00 
c01077a6:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01077ad:	e8 46 8c ff ff       	call   c01003f8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01077b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077b5:	8b 00                	mov    (%eax),%eax
c01077b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01077bc:	89 c2                	mov    %eax,%edx
c01077be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077c1:	39 c2                	cmp    %eax,%edx
c01077c3:	74 24                	je     c01077e9 <check_boot_pgdir+0xd5>
c01077c5:	c7 44 24 0c 01 a7 10 	movl   $0xc010a701,0xc(%esp)
c01077cc:	c0 
c01077cd:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01077d4:	c0 
c01077d5:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01077dc:	00 
c01077dd:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01077e4:	e8 0f 8c ff ff       	call   c01003f8 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01077e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01077f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01077f3:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01077f8:	39 c2                	cmp    %eax,%edx
c01077fa:	0f 82 26 ff ff ff    	jb     c0107726 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0107800:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107805:	05 ac 0f 00 00       	add    $0xfac,%eax
c010780a:	8b 00                	mov    (%eax),%eax
c010780c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107811:	89 c2                	mov    %eax,%edx
c0107813:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107818:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010781b:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0107822:	77 23                	ja     c0107847 <check_boot_pgdir+0x133>
c0107824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107827:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010782b:	c7 44 24 08 fc a2 10 	movl   $0xc010a2fc,0x8(%esp)
c0107832:	c0 
c0107833:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010783a:	00 
c010783b:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107842:	e8 b1 8b ff ff       	call   c01003f8 <__panic>
c0107847:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010784a:	05 00 00 00 40       	add    $0x40000000,%eax
c010784f:	39 c2                	cmp    %eax,%edx
c0107851:	74 24                	je     c0107877 <check_boot_pgdir+0x163>
c0107853:	c7 44 24 0c 18 a7 10 	movl   $0xc010a718,0xc(%esp)
c010785a:	c0 
c010785b:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107862:	c0 
c0107863:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010786a:	00 
c010786b:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107872:	e8 81 8b ff ff       	call   c01003f8 <__panic>

    assert(boot_pgdir[0] == 0);
c0107877:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010787c:	8b 00                	mov    (%eax),%eax
c010787e:	85 c0                	test   %eax,%eax
c0107880:	74 24                	je     c01078a6 <check_boot_pgdir+0x192>
c0107882:	c7 44 24 0c 4c a7 10 	movl   $0xc010a74c,0xc(%esp)
c0107889:	c0 
c010788a:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107891:	c0 
c0107892:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c0107899:	00 
c010789a:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01078a1:	e8 52 8b ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    p = alloc_page();
c01078a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01078ad:	e8 c1 ec ff ff       	call   c0106573 <alloc_pages>
c01078b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01078b5:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01078ba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01078c1:	00 
c01078c2:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01078c9:	00 
c01078ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01078cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01078d1:	89 04 24             	mov    %eax,(%esp)
c01078d4:	e8 a0 f5 ff ff       	call   c0106e79 <page_insert>
c01078d9:	85 c0                	test   %eax,%eax
c01078db:	74 24                	je     c0107901 <check_boot_pgdir+0x1ed>
c01078dd:	c7 44 24 0c 60 a7 10 	movl   $0xc010a760,0xc(%esp)
c01078e4:	c0 
c01078e5:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01078ec:	c0 
c01078ed:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c01078f4:	00 
c01078f5:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01078fc:	e8 f7 8a ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 1);
c0107901:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107904:	89 04 24             	mov    %eax,(%esp)
c0107907:	e8 62 ea ff ff       	call   c010636e <page_ref>
c010790c:	83 f8 01             	cmp    $0x1,%eax
c010790f:	74 24                	je     c0107935 <check_boot_pgdir+0x221>
c0107911:	c7 44 24 0c 8e a7 10 	movl   $0xc010a78e,0xc(%esp)
c0107918:	c0 
c0107919:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107920:	c0 
c0107921:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c0107928:	00 
c0107929:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107930:	e8 c3 8a ff ff       	call   c01003f8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0107935:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010793a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107941:	00 
c0107942:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0107949:	00 
c010794a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010794d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107951:	89 04 24             	mov    %eax,(%esp)
c0107954:	e8 20 f5 ff ff       	call   c0106e79 <page_insert>
c0107959:	85 c0                	test   %eax,%eax
c010795b:	74 24                	je     c0107981 <check_boot_pgdir+0x26d>
c010795d:	c7 44 24 0c a0 a7 10 	movl   $0xc010a7a0,0xc(%esp)
c0107964:	c0 
c0107965:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c010796c:	c0 
c010796d:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c0107974:	00 
c0107975:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c010797c:	e8 77 8a ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 2);
c0107981:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107984:	89 04 24             	mov    %eax,(%esp)
c0107987:	e8 e2 e9 ff ff       	call   c010636e <page_ref>
c010798c:	83 f8 02             	cmp    $0x2,%eax
c010798f:	74 24                	je     c01079b5 <check_boot_pgdir+0x2a1>
c0107991:	c7 44 24 0c d7 a7 10 	movl   $0xc010a7d7,0xc(%esp)
c0107998:	c0 
c0107999:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01079a0:	c0 
c01079a1:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c01079a8:	00 
c01079a9:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c01079b0:	e8 43 8a ff ff       	call   c01003f8 <__panic>

    const char *str = "ucore: Hello world!!";
c01079b5:	c7 45 dc e8 a7 10 c0 	movl   $0xc010a7e8,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01079bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01079c3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01079ca:	e8 6d 06 00 00       	call   c010803c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01079cf:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01079d6:	00 
c01079d7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01079de:	e8 d0 06 00 00       	call   c01080b3 <strcmp>
c01079e3:	85 c0                	test   %eax,%eax
c01079e5:	74 24                	je     c0107a0b <check_boot_pgdir+0x2f7>
c01079e7:	c7 44 24 0c 00 a8 10 	movl   $0xc010a800,0xc(%esp)
c01079ee:	c0 
c01079ef:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c01079f6:	c0 
c01079f7:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c01079fe:	00 
c01079ff:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107a06:	e8 ed 89 ff ff       	call   c01003f8 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0107a0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a0e:	89 04 24             	mov    %eax,(%esp)
c0107a11:	e8 64 e8 ff ff       	call   c010627a <page2kva>
c0107a16:	05 00 01 00 00       	add    $0x100,%eax
c0107a1b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0107a1e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107a25:	e8 bc 05 00 00       	call   c0107fe6 <strlen>
c0107a2a:	85 c0                	test   %eax,%eax
c0107a2c:	74 24                	je     c0107a52 <check_boot_pgdir+0x33e>
c0107a2e:	c7 44 24 0c 38 a8 10 	movl   $0xc010a838,0xc(%esp)
c0107a35:	c0 
c0107a36:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107a3d:	c0 
c0107a3e:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0107a45:	00 
c0107a46:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107a4d:	e8 a6 89 ff ff       	call   c01003f8 <__panic>

    free_page(p);
c0107a52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a59:	00 
c0107a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a5d:	89 04 24             	mov    %eax,(%esp)
c0107a60:	e8 79 eb ff ff       	call   c01065de <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0107a65:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107a6a:	8b 00                	mov    (%eax),%eax
c0107a6c:	89 04 24             	mov    %eax,(%esp)
c0107a6f:	e8 e2 e8 ff ff       	call   c0106356 <pde2page>
c0107a74:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a7b:	00 
c0107a7c:	89 04 24             	mov    %eax,(%esp)
c0107a7f:	e8 5a eb ff ff       	call   c01065de <free_pages>
    boot_pgdir[0] = 0;
c0107a84:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0107a8f:	c7 04 24 5c a8 10 c0 	movl   $0xc010a85c,(%esp)
c0107a96:	e8 06 88 ff ff       	call   c01002a1 <cprintf>
}
c0107a9b:	90                   	nop
c0107a9c:	c9                   	leave  
c0107a9d:	c3                   	ret    

c0107a9e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0107a9e:	55                   	push   %ebp
c0107a9f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0107aa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107aa4:	83 e0 04             	and    $0x4,%eax
c0107aa7:	85 c0                	test   %eax,%eax
c0107aa9:	74 04                	je     c0107aaf <perm2str+0x11>
c0107aab:	b0 75                	mov    $0x75,%al
c0107aad:	eb 02                	jmp    c0107ab1 <perm2str+0x13>
c0107aaf:	b0 2d                	mov    $0x2d,%al
c0107ab1:	a2 08 40 12 c0       	mov    %al,0xc0124008
    str[1] = 'r';
c0107ab6:	c6 05 09 40 12 c0 72 	movb   $0x72,0xc0124009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0107abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ac0:	83 e0 02             	and    $0x2,%eax
c0107ac3:	85 c0                	test   %eax,%eax
c0107ac5:	74 04                	je     c0107acb <perm2str+0x2d>
c0107ac7:	b0 77                	mov    $0x77,%al
c0107ac9:	eb 02                	jmp    c0107acd <perm2str+0x2f>
c0107acb:	b0 2d                	mov    $0x2d,%al
c0107acd:	a2 0a 40 12 c0       	mov    %al,0xc012400a
    str[3] = '\0';
c0107ad2:	c6 05 0b 40 12 c0 00 	movb   $0x0,0xc012400b
    return str;
c0107ad9:	b8 08 40 12 c0       	mov    $0xc0124008,%eax
}
c0107ade:	5d                   	pop    %ebp
c0107adf:	c3                   	ret    

c0107ae0 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0107ae0:	55                   	push   %ebp
c0107ae1:	89 e5                	mov    %esp,%ebp
c0107ae3:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0107ae6:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ae9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107aec:	72 0d                	jb     c0107afb <get_pgtable_items+0x1b>
        return 0;
c0107aee:	b8 00 00 00 00       	mov    $0x0,%eax
c0107af3:	e9 98 00 00 00       	jmp    c0107b90 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0107af8:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107afb:	8b 45 10             	mov    0x10(%ebp),%eax
c0107afe:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107b01:	73 18                	jae    c0107b1b <get_pgtable_items+0x3b>
c0107b03:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107b0d:	8b 45 14             	mov    0x14(%ebp),%eax
c0107b10:	01 d0                	add    %edx,%eax
c0107b12:	8b 00                	mov    (%eax),%eax
c0107b14:	83 e0 01             	and    $0x1,%eax
c0107b17:	85 c0                	test   %eax,%eax
c0107b19:	74 dd                	je     c0107af8 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0107b1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b1e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107b21:	73 68                	jae    c0107b8b <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0107b23:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107b27:	74 08                	je     c0107b31 <get_pgtable_items+0x51>
            *left_store = start;
c0107b29:	8b 45 18             	mov    0x18(%ebp),%eax
c0107b2c:	8b 55 10             	mov    0x10(%ebp),%edx
c0107b2f:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0107b31:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b34:	8d 50 01             	lea    0x1(%eax),%edx
c0107b37:	89 55 10             	mov    %edx,0x10(%ebp)
c0107b3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107b41:	8b 45 14             	mov    0x14(%ebp),%eax
c0107b44:	01 d0                	add    %edx,%eax
c0107b46:	8b 00                	mov    (%eax),%eax
c0107b48:	83 e0 07             	and    $0x7,%eax
c0107b4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107b4e:	eb 03                	jmp    c0107b53 <get_pgtable_items+0x73>
            start ++;
c0107b50:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107b53:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b56:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107b59:	73 1d                	jae    c0107b78 <get_pgtable_items+0x98>
c0107b5b:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107b65:	8b 45 14             	mov    0x14(%ebp),%eax
c0107b68:	01 d0                	add    %edx,%eax
c0107b6a:	8b 00                	mov    (%eax),%eax
c0107b6c:	83 e0 07             	and    $0x7,%eax
c0107b6f:	89 c2                	mov    %eax,%edx
c0107b71:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b74:	39 c2                	cmp    %eax,%edx
c0107b76:	74 d8                	je     c0107b50 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c0107b78:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107b7c:	74 08                	je     c0107b86 <get_pgtable_items+0xa6>
            *right_store = start;
c0107b7e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107b81:	8b 55 10             	mov    0x10(%ebp),%edx
c0107b84:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0107b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b89:	eb 05                	jmp    c0107b90 <get_pgtable_items+0xb0>
    }
    return 0;
c0107b8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b90:	c9                   	leave  
c0107b91:	c3                   	ret    

c0107b92 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107b92:	55                   	push   %ebp
c0107b93:	89 e5                	mov    %esp,%ebp
c0107b95:	57                   	push   %edi
c0107b96:	56                   	push   %esi
c0107b97:	53                   	push   %ebx
c0107b98:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0107b9b:	c7 04 24 7c a8 10 c0 	movl   $0xc010a87c,(%esp)
c0107ba2:	e8 fa 86 ff ff       	call   c01002a1 <cprintf>
    size_t left, right = 0, perm;
c0107ba7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107bae:	e9 fa 00 00 00       	jmp    c0107cad <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bb6:	89 04 24             	mov    %eax,(%esp)
c0107bb9:	e8 e0 fe ff ff       	call   c0107a9e <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107bbe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107bc1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107bc4:	29 d1                	sub    %edx,%ecx
c0107bc6:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107bc8:	89 d6                	mov    %edx,%esi
c0107bca:	c1 e6 16             	shl    $0x16,%esi
c0107bcd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107bd0:	89 d3                	mov    %edx,%ebx
c0107bd2:	c1 e3 16             	shl    $0x16,%ebx
c0107bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107bd8:	89 d1                	mov    %edx,%ecx
c0107bda:	c1 e1 16             	shl    $0x16,%ecx
c0107bdd:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0107be0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107be3:	29 d7                	sub    %edx,%edi
c0107be5:	89 fa                	mov    %edi,%edx
c0107be7:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107beb:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107bef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107bf3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107bfb:	c7 04 24 ad a8 10 c0 	movl   $0xc010a8ad,(%esp)
c0107c02:	e8 9a 86 ff ff       	call   c01002a1 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0107c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c0a:	c1 e0 0a             	shl    $0xa,%eax
c0107c0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107c10:	eb 54                	jmp    c0107c66 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107c12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c15:	89 04 24             	mov    %eax,(%esp)
c0107c18:	e8 81 fe ff ff       	call   c0107a9e <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107c1d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0107c20:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c23:	29 d1                	sub    %edx,%ecx
c0107c25:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107c27:	89 d6                	mov    %edx,%esi
c0107c29:	c1 e6 0c             	shl    $0xc,%esi
c0107c2c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107c2f:	89 d3                	mov    %edx,%ebx
c0107c31:	c1 e3 0c             	shl    $0xc,%ebx
c0107c34:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c37:	89 d1                	mov    %edx,%ecx
c0107c39:	c1 e1 0c             	shl    $0xc,%ecx
c0107c3c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0107c3f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c42:	29 d7                	sub    %edx,%edi
c0107c44:	89 fa                	mov    %edi,%edx
c0107c46:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107c4a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107c4e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107c52:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107c56:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c5a:	c7 04 24 cc a8 10 c0 	movl   $0xc010a8cc,(%esp)
c0107c61:	e8 3b 86 ff ff       	call   c01002a1 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107c66:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0107c6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c71:	89 d3                	mov    %edx,%ebx
c0107c73:	c1 e3 0a             	shl    $0xa,%ebx
c0107c76:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c79:	89 d1                	mov    %edx,%ecx
c0107c7b:	c1 e1 0a             	shl    $0xa,%ecx
c0107c7e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0107c81:	89 54 24 14          	mov    %edx,0x14(%esp)
c0107c85:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0107c88:	89 54 24 10          	mov    %edx,0x10(%esp)
c0107c8c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0107c90:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107c94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0107c98:	89 0c 24             	mov    %ecx,(%esp)
c0107c9b:	e8 40 fe ff ff       	call   c0107ae0 <get_pgtable_items>
c0107ca0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ca3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107ca7:	0f 85 65 ff ff ff    	jne    c0107c12 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107cad:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0107cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107cb5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0107cb8:	89 54 24 14          	mov    %edx,0x14(%esp)
c0107cbc:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0107cbf:	89 54 24 10          	mov    %edx,0x10(%esp)
c0107cc3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0107cc7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107ccb:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0107cd2:	00 
c0107cd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107cda:	e8 01 fe ff ff       	call   c0107ae0 <get_pgtable_items>
c0107cdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ce2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107ce6:	0f 85 c7 fe ff ff    	jne    c0107bb3 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107cec:	c7 04 24 f0 a8 10 c0 	movl   $0xc010a8f0,(%esp)
c0107cf3:	e8 a9 85 ff ff       	call   c01002a1 <cprintf>
}
c0107cf8:	90                   	nop
c0107cf9:	83 c4 4c             	add    $0x4c,%esp
c0107cfc:	5b                   	pop    %ebx
c0107cfd:	5e                   	pop    %esi
c0107cfe:	5f                   	pop    %edi
c0107cff:	5d                   	pop    %ebp
c0107d00:	c3                   	ret    

c0107d01 <kmalloc>:

void *
kmalloc(size_t n) {
c0107d01:	55                   	push   %ebp
c0107d02:	89 e5                	mov    %esp,%ebp
c0107d04:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0107d07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0107d0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0107d15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107d19:	74 09                	je     c0107d24 <kmalloc+0x23>
c0107d1b:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0107d22:	76 24                	jbe    c0107d48 <kmalloc+0x47>
c0107d24:	c7 44 24 0c 21 a9 10 	movl   $0xc010a921,0xc(%esp)
c0107d2b:	c0 
c0107d2c:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107d33:	c0 
c0107d34:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c0107d3b:	00 
c0107d3c:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107d43:	e8 b0 86 ff ff       	call   c01003f8 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d4b:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107d50:	c1 e8 0c             	shr    $0xc,%eax
c0107d53:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0107d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d59:	89 04 24             	mov    %eax,(%esp)
c0107d5c:	e8 12 e8 ff ff       	call   c0106573 <alloc_pages>
c0107d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0107d64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107d68:	75 24                	jne    c0107d8e <kmalloc+0x8d>
c0107d6a:	c7 44 24 0c 38 a9 10 	movl   $0xc010a938,0xc(%esp)
c0107d71:	c0 
c0107d72:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107d79:	c0 
c0107d7a:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c0107d81:	00 
c0107d82:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107d89:	e8 6a 86 ff ff       	call   c01003f8 <__panic>
    ptr=page2kva(base);
c0107d8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d91:	89 04 24             	mov    %eax,(%esp)
c0107d94:	e8 e1 e4 ff ff       	call   c010627a <page2kva>
c0107d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0107d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107d9f:	c9                   	leave  
c0107da0:	c3                   	ret    

c0107da1 <kfree>:

void
kfree(void *ptr, size_t n) {
c0107da1:	55                   	push   %ebp
c0107da2:	89 e5                	mov    %esp,%ebp
c0107da4:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0107da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107dab:	74 09                	je     c0107db6 <kfree+0x15>
c0107dad:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0107db4:	76 24                	jbe    c0107dda <kfree+0x39>
c0107db6:	c7 44 24 0c 21 a9 10 	movl   $0xc010a921,0xc(%esp)
c0107dbd:	c0 
c0107dbe:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107dc5:	c0 
c0107dc6:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
c0107dcd:	00 
c0107dce:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107dd5:	e8 1e 86 ff ff       	call   c01003f8 <__panic>
    assert(ptr != NULL);
c0107dda:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107dde:	75 24                	jne    c0107e04 <kfree+0x63>
c0107de0:	c7 44 24 0c 45 a9 10 	movl   $0xc010a945,0xc(%esp)
c0107de7:	c0 
c0107de8:	c7 44 24 08 c5 a3 10 	movl   $0xc010a3c5,0x8(%esp)
c0107def:	c0 
c0107df0:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
c0107df7:	00 
c0107df8:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0107dff:	e8 f4 85 ff ff       	call   c01003f8 <__panic>
    struct Page *base=NULL;
c0107e04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e0e:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107e13:	c1 e8 0c             	shr    $0xc,%eax
c0107e16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0107e19:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e1c:	89 04 24             	mov    %eax,(%esp)
c0107e1f:	e8 aa e4 ff ff       	call   c01062ce <kva2page>
c0107e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0107e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e31:	89 04 24             	mov    %eax,(%esp)
c0107e34:	e8 a5 e7 ff ff       	call   c01065de <free_pages>
c0107e39:	90                   	nop
c0107e3a:	c9                   	leave  
c0107e3b:	c3                   	ret    

c0107e3c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107e3c:	55                   	push   %ebp
c0107e3d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107e3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e42:	8b 15 00 41 12 c0    	mov    0xc0124100,%edx
c0107e48:	29 d0                	sub    %edx,%eax
c0107e4a:	c1 f8 05             	sar    $0x5,%eax
}
c0107e4d:	5d                   	pop    %ebp
c0107e4e:	c3                   	ret    

c0107e4f <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107e4f:	55                   	push   %ebp
c0107e50:	89 e5                	mov    %esp,%ebp
c0107e52:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e58:	89 04 24             	mov    %eax,(%esp)
c0107e5b:	e8 dc ff ff ff       	call   c0107e3c <page2ppn>
c0107e60:	c1 e0 0c             	shl    $0xc,%eax
}
c0107e63:	c9                   	leave  
c0107e64:	c3                   	ret    

c0107e65 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0107e65:	55                   	push   %ebp
c0107e66:	89 e5                	mov    %esp,%ebp
c0107e68:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e6e:	89 04 24             	mov    %eax,(%esp)
c0107e71:	e8 d9 ff ff ff       	call   c0107e4f <page2pa>
c0107e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e7c:	c1 e8 0c             	shr    $0xc,%eax
c0107e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e82:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0107e87:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107e8a:	72 23                	jb     c0107eaf <page2kva+0x4a>
c0107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107e93:	c7 44 24 08 54 a9 10 	movl   $0xc010a954,0x8(%esp)
c0107e9a:	c0 
c0107e9b:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107ea2:	00 
c0107ea3:	c7 04 24 77 a9 10 c0 	movl   $0xc010a977,(%esp)
c0107eaa:	e8 49 85 ff ff       	call   c01003f8 <__panic>
c0107eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eb2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107eb7:	c9                   	leave  
c0107eb8:	c3                   	ret    

c0107eb9 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107eb9:	55                   	push   %ebp
c0107eba:	89 e5                	mov    %esp,%ebp
c0107ebc:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107ebf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107ec6:	e8 46 92 ff ff       	call   c0101111 <ide_device_valid>
c0107ecb:	85 c0                	test   %eax,%eax
c0107ecd:	75 1c                	jne    c0107eeb <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0107ecf:	c7 44 24 08 85 a9 10 	movl   $0xc010a985,0x8(%esp)
c0107ed6:	c0 
c0107ed7:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0107ede:	00 
c0107edf:	c7 04 24 9f a9 10 c0 	movl   $0xc010a99f,(%esp)
c0107ee6:	e8 0d 85 ff ff       	call   c01003f8 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107eeb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107ef2:	e8 5c 92 ff ff       	call   c0101153 <ide_device_size>
c0107ef7:	c1 e8 03             	shr    $0x3,%eax
c0107efa:	a3 bc 40 12 c0       	mov    %eax,0xc01240bc
}
c0107eff:	90                   	nop
c0107f00:	c9                   	leave  
c0107f01:	c3                   	ret    

c0107f02 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107f02:	55                   	push   %ebp
c0107f03:	89 e5                	mov    %esp,%ebp
c0107f05:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107f08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f0b:	89 04 24             	mov    %eax,(%esp)
c0107f0e:	e8 52 ff ff ff       	call   c0107e65 <page2kva>
c0107f13:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f16:	c1 ea 08             	shr    $0x8,%edx
c0107f19:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107f1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f20:	74 0b                	je     c0107f2d <swapfs_read+0x2b>
c0107f22:	8b 15 bc 40 12 c0    	mov    0xc01240bc,%edx
c0107f28:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107f2b:	72 23                	jb     c0107f50 <swapfs_read+0x4e>
c0107f2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f30:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107f34:	c7 44 24 08 b0 a9 10 	movl   $0xc010a9b0,0x8(%esp)
c0107f3b:	c0 
c0107f3c:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0107f43:	00 
c0107f44:	c7 04 24 9f a9 10 c0 	movl   $0xc010a99f,(%esp)
c0107f4b:	e8 a8 84 ff ff       	call   c01003f8 <__panic>
c0107f50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f53:	c1 e2 03             	shl    $0x3,%edx
c0107f56:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107f5d:	00 
c0107f5e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107f62:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107f66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f6d:	e8 20 92 ff ff       	call   c0101192 <ide_read_secs>
}
c0107f72:	c9                   	leave  
c0107f73:	c3                   	ret    

c0107f74 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0107f74:	55                   	push   %ebp
c0107f75:	89 e5                	mov    %esp,%ebp
c0107f77:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f7d:	89 04 24             	mov    %eax,(%esp)
c0107f80:	e8 e0 fe ff ff       	call   c0107e65 <page2kva>
c0107f85:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f88:	c1 ea 08             	shr    $0x8,%edx
c0107f8b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107f8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f92:	74 0b                	je     c0107f9f <swapfs_write+0x2b>
c0107f94:	8b 15 bc 40 12 c0    	mov    0xc01240bc,%edx
c0107f9a:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107f9d:	72 23                	jb     c0107fc2 <swapfs_write+0x4e>
c0107f9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107fa6:	c7 44 24 08 b0 a9 10 	movl   $0xc010a9b0,0x8(%esp)
c0107fad:	c0 
c0107fae:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0107fb5:	00 
c0107fb6:	c7 04 24 9f a9 10 c0 	movl   $0xc010a99f,(%esp)
c0107fbd:	e8 36 84 ff ff       	call   c01003f8 <__panic>
c0107fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107fc5:	c1 e2 03             	shl    $0x3,%edx
c0107fc8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107fcf:	00 
c0107fd0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107fd4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107fd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107fdf:	e8 e8 93 ff ff       	call   c01013cc <ide_write_secs>
}
c0107fe4:	c9                   	leave  
c0107fe5:	c3                   	ret    

c0107fe6 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0107fe6:	55                   	push   %ebp
c0107fe7:	89 e5                	mov    %esp,%ebp
c0107fe9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0107fec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0107ff3:	eb 03                	jmp    c0107ff8 <strlen+0x12>
        cnt ++;
c0107ff5:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0107ff8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ffb:	8d 50 01             	lea    0x1(%eax),%edx
c0107ffe:	89 55 08             	mov    %edx,0x8(%ebp)
c0108001:	0f b6 00             	movzbl (%eax),%eax
c0108004:	84 c0                	test   %al,%al
c0108006:	75 ed                	jne    c0107ff5 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0108008:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010800b:	c9                   	leave  
c010800c:	c3                   	ret    

c010800d <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010800d:	55                   	push   %ebp
c010800e:	89 e5                	mov    %esp,%ebp
c0108010:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108013:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010801a:	eb 03                	jmp    c010801f <strnlen+0x12>
        cnt ++;
c010801c:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010801f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108022:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108025:	73 10                	jae    c0108037 <strnlen+0x2a>
c0108027:	8b 45 08             	mov    0x8(%ebp),%eax
c010802a:	8d 50 01             	lea    0x1(%eax),%edx
c010802d:	89 55 08             	mov    %edx,0x8(%ebp)
c0108030:	0f b6 00             	movzbl (%eax),%eax
c0108033:	84 c0                	test   %al,%al
c0108035:	75 e5                	jne    c010801c <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0108037:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010803a:	c9                   	leave  
c010803b:	c3                   	ret    

c010803c <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010803c:	55                   	push   %ebp
c010803d:	89 e5                	mov    %esp,%ebp
c010803f:	57                   	push   %edi
c0108040:	56                   	push   %esi
c0108041:	83 ec 20             	sub    $0x20,%esp
c0108044:	8b 45 08             	mov    0x8(%ebp),%eax
c0108047:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010804a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010804d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108050:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108053:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108056:	89 d1                	mov    %edx,%ecx
c0108058:	89 c2                	mov    %eax,%edx
c010805a:	89 ce                	mov    %ecx,%esi
c010805c:	89 d7                	mov    %edx,%edi
c010805e:	ac                   	lods   %ds:(%esi),%al
c010805f:	aa                   	stos   %al,%es:(%edi)
c0108060:	84 c0                	test   %al,%al
c0108062:	75 fa                	jne    c010805e <strcpy+0x22>
c0108064:	89 fa                	mov    %edi,%edx
c0108066:	89 f1                	mov    %esi,%ecx
c0108068:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010806b:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010806e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0108074:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108075:	83 c4 20             	add    $0x20,%esp
c0108078:	5e                   	pop    %esi
c0108079:	5f                   	pop    %edi
c010807a:	5d                   	pop    %ebp
c010807b:	c3                   	ret    

c010807c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010807c:	55                   	push   %ebp
c010807d:	89 e5                	mov    %esp,%ebp
c010807f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108082:	8b 45 08             	mov    0x8(%ebp),%eax
c0108085:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108088:	eb 1e                	jmp    c01080a8 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010808a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010808d:	0f b6 10             	movzbl (%eax),%edx
c0108090:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108093:	88 10                	mov    %dl,(%eax)
c0108095:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108098:	0f b6 00             	movzbl (%eax),%eax
c010809b:	84 c0                	test   %al,%al
c010809d:	74 03                	je     c01080a2 <strncpy+0x26>
            src ++;
c010809f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01080a2:	ff 45 fc             	incl   -0x4(%ebp)
c01080a5:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c01080a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01080ac:	75 dc                	jne    c010808a <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c01080ae:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01080b1:	c9                   	leave  
c01080b2:	c3                   	ret    

c01080b3 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01080b3:	55                   	push   %ebp
c01080b4:	89 e5                	mov    %esp,%ebp
c01080b6:	57                   	push   %edi
c01080b7:	56                   	push   %esi
c01080b8:	83 ec 20             	sub    $0x20,%esp
c01080bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01080be:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c01080c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080cd:	89 d1                	mov    %edx,%ecx
c01080cf:	89 c2                	mov    %eax,%edx
c01080d1:	89 ce                	mov    %ecx,%esi
c01080d3:	89 d7                	mov    %edx,%edi
c01080d5:	ac                   	lods   %ds:(%esi),%al
c01080d6:	ae                   	scas   %es:(%edi),%al
c01080d7:	75 08                	jne    c01080e1 <strcmp+0x2e>
c01080d9:	84 c0                	test   %al,%al
c01080db:	75 f8                	jne    c01080d5 <strcmp+0x22>
c01080dd:	31 c0                	xor    %eax,%eax
c01080df:	eb 04                	jmp    c01080e5 <strcmp+0x32>
c01080e1:	19 c0                	sbb    %eax,%eax
c01080e3:	0c 01                	or     $0x1,%al
c01080e5:	89 fa                	mov    %edi,%edx
c01080e7:	89 f1                	mov    %esi,%ecx
c01080e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01080ec:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01080ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01080f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01080f5:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01080f6:	83 c4 20             	add    $0x20,%esp
c01080f9:	5e                   	pop    %esi
c01080fa:	5f                   	pop    %edi
c01080fb:	5d                   	pop    %ebp
c01080fc:	c3                   	ret    

c01080fd <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01080fd:	55                   	push   %ebp
c01080fe:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108100:	eb 09                	jmp    c010810b <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108102:	ff 4d 10             	decl   0x10(%ebp)
c0108105:	ff 45 08             	incl   0x8(%ebp)
c0108108:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010810b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010810f:	74 1a                	je     c010812b <strncmp+0x2e>
c0108111:	8b 45 08             	mov    0x8(%ebp),%eax
c0108114:	0f b6 00             	movzbl (%eax),%eax
c0108117:	84 c0                	test   %al,%al
c0108119:	74 10                	je     c010812b <strncmp+0x2e>
c010811b:	8b 45 08             	mov    0x8(%ebp),%eax
c010811e:	0f b6 10             	movzbl (%eax),%edx
c0108121:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108124:	0f b6 00             	movzbl (%eax),%eax
c0108127:	38 c2                	cmp    %al,%dl
c0108129:	74 d7                	je     c0108102 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010812b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010812f:	74 18                	je     c0108149 <strncmp+0x4c>
c0108131:	8b 45 08             	mov    0x8(%ebp),%eax
c0108134:	0f b6 00             	movzbl (%eax),%eax
c0108137:	0f b6 d0             	movzbl %al,%edx
c010813a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010813d:	0f b6 00             	movzbl (%eax),%eax
c0108140:	0f b6 c0             	movzbl %al,%eax
c0108143:	29 c2                	sub    %eax,%edx
c0108145:	89 d0                	mov    %edx,%eax
c0108147:	eb 05                	jmp    c010814e <strncmp+0x51>
c0108149:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010814e:	5d                   	pop    %ebp
c010814f:	c3                   	ret    

c0108150 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108150:	55                   	push   %ebp
c0108151:	89 e5                	mov    %esp,%ebp
c0108153:	83 ec 04             	sub    $0x4,%esp
c0108156:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108159:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010815c:	eb 13                	jmp    c0108171 <strchr+0x21>
        if (*s == c) {
c010815e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108161:	0f b6 00             	movzbl (%eax),%eax
c0108164:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108167:	75 05                	jne    c010816e <strchr+0x1e>
            return (char *)s;
c0108169:	8b 45 08             	mov    0x8(%ebp),%eax
c010816c:	eb 12                	jmp    c0108180 <strchr+0x30>
        }
        s ++;
c010816e:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0108171:	8b 45 08             	mov    0x8(%ebp),%eax
c0108174:	0f b6 00             	movzbl (%eax),%eax
c0108177:	84 c0                	test   %al,%al
c0108179:	75 e3                	jne    c010815e <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010817b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108180:	c9                   	leave  
c0108181:	c3                   	ret    

c0108182 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108182:	55                   	push   %ebp
c0108183:	89 e5                	mov    %esp,%ebp
c0108185:	83 ec 04             	sub    $0x4,%esp
c0108188:	8b 45 0c             	mov    0xc(%ebp),%eax
c010818b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010818e:	eb 0e                	jmp    c010819e <strfind+0x1c>
        if (*s == c) {
c0108190:	8b 45 08             	mov    0x8(%ebp),%eax
c0108193:	0f b6 00             	movzbl (%eax),%eax
c0108196:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108199:	74 0f                	je     c01081aa <strfind+0x28>
            break;
        }
        s ++;
c010819b:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010819e:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a1:	0f b6 00             	movzbl (%eax),%eax
c01081a4:	84 c0                	test   %al,%al
c01081a6:	75 e8                	jne    c0108190 <strfind+0xe>
c01081a8:	eb 01                	jmp    c01081ab <strfind+0x29>
        if (*s == c) {
            break;
c01081aa:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c01081ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01081ae:	c9                   	leave  
c01081af:	c3                   	ret    

c01081b0 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01081b0:	55                   	push   %ebp
c01081b1:	89 e5                	mov    %esp,%ebp
c01081b3:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01081b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01081bd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01081c4:	eb 03                	jmp    c01081c9 <strtol+0x19>
        s ++;
c01081c6:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01081c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01081cc:	0f b6 00             	movzbl (%eax),%eax
c01081cf:	3c 20                	cmp    $0x20,%al
c01081d1:	74 f3                	je     c01081c6 <strtol+0x16>
c01081d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01081d6:	0f b6 00             	movzbl (%eax),%eax
c01081d9:	3c 09                	cmp    $0x9,%al
c01081db:	74 e9                	je     c01081c6 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01081dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01081e0:	0f b6 00             	movzbl (%eax),%eax
c01081e3:	3c 2b                	cmp    $0x2b,%al
c01081e5:	75 05                	jne    c01081ec <strtol+0x3c>
        s ++;
c01081e7:	ff 45 08             	incl   0x8(%ebp)
c01081ea:	eb 14                	jmp    c0108200 <strtol+0x50>
    }
    else if (*s == '-') {
c01081ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ef:	0f b6 00             	movzbl (%eax),%eax
c01081f2:	3c 2d                	cmp    $0x2d,%al
c01081f4:	75 0a                	jne    c0108200 <strtol+0x50>
        s ++, neg = 1;
c01081f6:	ff 45 08             	incl   0x8(%ebp)
c01081f9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108200:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108204:	74 06                	je     c010820c <strtol+0x5c>
c0108206:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010820a:	75 22                	jne    c010822e <strtol+0x7e>
c010820c:	8b 45 08             	mov    0x8(%ebp),%eax
c010820f:	0f b6 00             	movzbl (%eax),%eax
c0108212:	3c 30                	cmp    $0x30,%al
c0108214:	75 18                	jne    c010822e <strtol+0x7e>
c0108216:	8b 45 08             	mov    0x8(%ebp),%eax
c0108219:	40                   	inc    %eax
c010821a:	0f b6 00             	movzbl (%eax),%eax
c010821d:	3c 78                	cmp    $0x78,%al
c010821f:	75 0d                	jne    c010822e <strtol+0x7e>
        s += 2, base = 16;
c0108221:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108225:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010822c:	eb 29                	jmp    c0108257 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010822e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108232:	75 16                	jne    c010824a <strtol+0x9a>
c0108234:	8b 45 08             	mov    0x8(%ebp),%eax
c0108237:	0f b6 00             	movzbl (%eax),%eax
c010823a:	3c 30                	cmp    $0x30,%al
c010823c:	75 0c                	jne    c010824a <strtol+0x9a>
        s ++, base = 8;
c010823e:	ff 45 08             	incl   0x8(%ebp)
c0108241:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108248:	eb 0d                	jmp    c0108257 <strtol+0xa7>
    }
    else if (base == 0) {
c010824a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010824e:	75 07                	jne    c0108257 <strtol+0xa7>
        base = 10;
c0108250:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108257:	8b 45 08             	mov    0x8(%ebp),%eax
c010825a:	0f b6 00             	movzbl (%eax),%eax
c010825d:	3c 2f                	cmp    $0x2f,%al
c010825f:	7e 1b                	jle    c010827c <strtol+0xcc>
c0108261:	8b 45 08             	mov    0x8(%ebp),%eax
c0108264:	0f b6 00             	movzbl (%eax),%eax
c0108267:	3c 39                	cmp    $0x39,%al
c0108269:	7f 11                	jg     c010827c <strtol+0xcc>
            dig = *s - '0';
c010826b:	8b 45 08             	mov    0x8(%ebp),%eax
c010826e:	0f b6 00             	movzbl (%eax),%eax
c0108271:	0f be c0             	movsbl %al,%eax
c0108274:	83 e8 30             	sub    $0x30,%eax
c0108277:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010827a:	eb 48                	jmp    c01082c4 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010827c:	8b 45 08             	mov    0x8(%ebp),%eax
c010827f:	0f b6 00             	movzbl (%eax),%eax
c0108282:	3c 60                	cmp    $0x60,%al
c0108284:	7e 1b                	jle    c01082a1 <strtol+0xf1>
c0108286:	8b 45 08             	mov    0x8(%ebp),%eax
c0108289:	0f b6 00             	movzbl (%eax),%eax
c010828c:	3c 7a                	cmp    $0x7a,%al
c010828e:	7f 11                	jg     c01082a1 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108290:	8b 45 08             	mov    0x8(%ebp),%eax
c0108293:	0f b6 00             	movzbl (%eax),%eax
c0108296:	0f be c0             	movsbl %al,%eax
c0108299:	83 e8 57             	sub    $0x57,%eax
c010829c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010829f:	eb 23                	jmp    c01082c4 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01082a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a4:	0f b6 00             	movzbl (%eax),%eax
c01082a7:	3c 40                	cmp    $0x40,%al
c01082a9:	7e 3b                	jle    c01082e6 <strtol+0x136>
c01082ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01082ae:	0f b6 00             	movzbl (%eax),%eax
c01082b1:	3c 5a                	cmp    $0x5a,%al
c01082b3:	7f 31                	jg     c01082e6 <strtol+0x136>
            dig = *s - 'A' + 10;
c01082b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b8:	0f b6 00             	movzbl (%eax),%eax
c01082bb:	0f be c0             	movsbl %al,%eax
c01082be:	83 e8 37             	sub    $0x37,%eax
c01082c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01082c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082c7:	3b 45 10             	cmp    0x10(%ebp),%eax
c01082ca:	7d 19                	jge    c01082e5 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01082cc:	ff 45 08             	incl   0x8(%ebp)
c01082cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01082d2:	0f af 45 10          	imul   0x10(%ebp),%eax
c01082d6:	89 c2                	mov    %eax,%edx
c01082d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082db:	01 d0                	add    %edx,%eax
c01082dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01082e0:	e9 72 ff ff ff       	jmp    c0108257 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c01082e5:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c01082e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01082ea:	74 08                	je     c01082f4 <strtol+0x144>
        *endptr = (char *) s;
c01082ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01082f2:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01082f4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01082f8:	74 07                	je     c0108301 <strtol+0x151>
c01082fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01082fd:	f7 d8                	neg    %eax
c01082ff:	eb 03                	jmp    c0108304 <strtol+0x154>
c0108301:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108304:	c9                   	leave  
c0108305:	c3                   	ret    

c0108306 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108306:	55                   	push   %ebp
c0108307:	89 e5                	mov    %esp,%ebp
c0108309:	57                   	push   %edi
c010830a:	83 ec 24             	sub    $0x24,%esp
c010830d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108310:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108313:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108317:	8b 55 08             	mov    0x8(%ebp),%edx
c010831a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010831d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108320:	8b 45 10             	mov    0x10(%ebp),%eax
c0108323:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108326:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108329:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010832d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108330:	89 d7                	mov    %edx,%edi
c0108332:	f3 aa                	rep stos %al,%es:(%edi)
c0108334:	89 fa                	mov    %edi,%edx
c0108336:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108339:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010833c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010833f:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108340:	83 c4 24             	add    $0x24,%esp
c0108343:	5f                   	pop    %edi
c0108344:	5d                   	pop    %ebp
c0108345:	c3                   	ret    

c0108346 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108346:	55                   	push   %ebp
c0108347:	89 e5                	mov    %esp,%ebp
c0108349:	57                   	push   %edi
c010834a:	56                   	push   %esi
c010834b:	53                   	push   %ebx
c010834c:	83 ec 30             	sub    $0x30,%esp
c010834f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108352:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108355:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108358:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010835b:	8b 45 10             	mov    0x10(%ebp),%eax
c010835e:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108361:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108364:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108367:	73 42                	jae    c01083ab <memmove+0x65>
c0108369:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010836c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010836f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108372:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108375:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108378:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010837b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010837e:	c1 e8 02             	shr    $0x2,%eax
c0108381:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108386:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108389:	89 d7                	mov    %edx,%edi
c010838b:	89 c6                	mov    %eax,%esi
c010838d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010838f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108392:	83 e1 03             	and    $0x3,%ecx
c0108395:	74 02                	je     c0108399 <memmove+0x53>
c0108397:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108399:	89 f0                	mov    %esi,%eax
c010839b:	89 fa                	mov    %edi,%edx
c010839d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01083a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01083a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01083a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01083a9:	eb 36                	jmp    c01083e1 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01083ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083ae:	8d 50 ff             	lea    -0x1(%eax),%edx
c01083b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083b4:	01 c2                	add    %eax,%edx
c01083b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083b9:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01083bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083bf:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c01083c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083c5:	89 c1                	mov    %eax,%ecx
c01083c7:	89 d8                	mov    %ebx,%eax
c01083c9:	89 d6                	mov    %edx,%esi
c01083cb:	89 c7                	mov    %eax,%edi
c01083cd:	fd                   	std    
c01083ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01083d0:	fc                   	cld    
c01083d1:	89 f8                	mov    %edi,%eax
c01083d3:	89 f2                	mov    %esi,%edx
c01083d5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01083d8:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01083db:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01083de:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01083e1:	83 c4 30             	add    $0x30,%esp
c01083e4:	5b                   	pop    %ebx
c01083e5:	5e                   	pop    %esi
c01083e6:	5f                   	pop    %edi
c01083e7:	5d                   	pop    %ebp
c01083e8:	c3                   	ret    

c01083e9 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01083e9:	55                   	push   %ebp
c01083ea:	89 e5                	mov    %esp,%ebp
c01083ec:	57                   	push   %edi
c01083ed:	56                   	push   %esi
c01083ee:	83 ec 20             	sub    $0x20,%esp
c01083f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01083f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01083fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108400:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108403:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108406:	c1 e8 02             	shr    $0x2,%eax
c0108409:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010840b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010840e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108411:	89 d7                	mov    %edx,%edi
c0108413:	89 c6                	mov    %eax,%esi
c0108415:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108417:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010841a:	83 e1 03             	and    $0x3,%ecx
c010841d:	74 02                	je     c0108421 <memcpy+0x38>
c010841f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108421:	89 f0                	mov    %esi,%eax
c0108423:	89 fa                	mov    %edi,%edx
c0108425:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108428:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010842b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010842e:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0108431:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108432:	83 c4 20             	add    $0x20,%esp
c0108435:	5e                   	pop    %esi
c0108436:	5f                   	pop    %edi
c0108437:	5d                   	pop    %ebp
c0108438:	c3                   	ret    

c0108439 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108439:	55                   	push   %ebp
c010843a:	89 e5                	mov    %esp,%ebp
c010843c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010843f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108442:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108445:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108448:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010844b:	eb 2e                	jmp    c010847b <memcmp+0x42>
        if (*s1 != *s2) {
c010844d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108450:	0f b6 10             	movzbl (%eax),%edx
c0108453:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108456:	0f b6 00             	movzbl (%eax),%eax
c0108459:	38 c2                	cmp    %al,%dl
c010845b:	74 18                	je     c0108475 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010845d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108460:	0f b6 00             	movzbl (%eax),%eax
c0108463:	0f b6 d0             	movzbl %al,%edx
c0108466:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108469:	0f b6 00             	movzbl (%eax),%eax
c010846c:	0f b6 c0             	movzbl %al,%eax
c010846f:	29 c2                	sub    %eax,%edx
c0108471:	89 d0                	mov    %edx,%eax
c0108473:	eb 18                	jmp    c010848d <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0108475:	ff 45 fc             	incl   -0x4(%ebp)
c0108478:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010847b:	8b 45 10             	mov    0x10(%ebp),%eax
c010847e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108481:	89 55 10             	mov    %edx,0x10(%ebp)
c0108484:	85 c0                	test   %eax,%eax
c0108486:	75 c5                	jne    c010844d <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0108488:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010848d:	c9                   	leave  
c010848e:	c3                   	ret    

c010848f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010848f:	55                   	push   %ebp
c0108490:	89 e5                	mov    %esp,%ebp
c0108492:	83 ec 58             	sub    $0x58,%esp
c0108495:	8b 45 10             	mov    0x10(%ebp),%eax
c0108498:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010849b:	8b 45 14             	mov    0x14(%ebp),%eax
c010849e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01084a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01084a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01084aa:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01084ad:	8b 45 18             	mov    0x18(%ebp),%eax
c01084b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01084b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01084b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01084bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01084bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01084c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01084c9:	74 1c                	je     c01084e7 <printnum+0x58>
c01084cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084ce:	ba 00 00 00 00       	mov    $0x0,%edx
c01084d3:	f7 75 e4             	divl   -0x1c(%ebp)
c01084d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01084d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084dc:	ba 00 00 00 00       	mov    $0x0,%edx
c01084e1:	f7 75 e4             	divl   -0x1c(%ebp)
c01084e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084ed:	f7 75 e4             	divl   -0x1c(%ebp)
c01084f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01084f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01084f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01084fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01084ff:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108502:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108505:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108508:	8b 45 18             	mov    0x18(%ebp),%eax
c010850b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108510:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108513:	77 56                	ja     c010856b <printnum+0xdc>
c0108515:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108518:	72 05                	jb     c010851f <printnum+0x90>
c010851a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010851d:	77 4c                	ja     c010856b <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010851f:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108522:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108525:	8b 45 20             	mov    0x20(%ebp),%eax
c0108528:	89 44 24 18          	mov    %eax,0x18(%esp)
c010852c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108530:	8b 45 18             	mov    0x18(%ebp),%eax
c0108533:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108537:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010853a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010853d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108541:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108548:	89 44 24 04          	mov    %eax,0x4(%esp)
c010854c:	8b 45 08             	mov    0x8(%ebp),%eax
c010854f:	89 04 24             	mov    %eax,(%esp)
c0108552:	e8 38 ff ff ff       	call   c010848f <printnum>
c0108557:	eb 1b                	jmp    c0108574 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010855c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108560:	8b 45 20             	mov    0x20(%ebp),%eax
c0108563:	89 04 24             	mov    %eax,(%esp)
c0108566:	8b 45 08             	mov    0x8(%ebp),%eax
c0108569:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010856b:	ff 4d 1c             	decl   0x1c(%ebp)
c010856e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108572:	7f e5                	jg     c0108559 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108574:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108577:	05 50 aa 10 c0       	add    $0xc010aa50,%eax
c010857c:	0f b6 00             	movzbl (%eax),%eax
c010857f:	0f be c0             	movsbl %al,%eax
c0108582:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108585:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108589:	89 04 24             	mov    %eax,(%esp)
c010858c:	8b 45 08             	mov    0x8(%ebp),%eax
c010858f:	ff d0                	call   *%eax
}
c0108591:	90                   	nop
c0108592:	c9                   	leave  
c0108593:	c3                   	ret    

c0108594 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108594:	55                   	push   %ebp
c0108595:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108597:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010859b:	7e 14                	jle    c01085b1 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010859d:	8b 45 08             	mov    0x8(%ebp),%eax
c01085a0:	8b 00                	mov    (%eax),%eax
c01085a2:	8d 48 08             	lea    0x8(%eax),%ecx
c01085a5:	8b 55 08             	mov    0x8(%ebp),%edx
c01085a8:	89 0a                	mov    %ecx,(%edx)
c01085aa:	8b 50 04             	mov    0x4(%eax),%edx
c01085ad:	8b 00                	mov    (%eax),%eax
c01085af:	eb 30                	jmp    c01085e1 <getuint+0x4d>
    }
    else if (lflag) {
c01085b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01085b5:	74 16                	je     c01085cd <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01085b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01085ba:	8b 00                	mov    (%eax),%eax
c01085bc:	8d 48 04             	lea    0x4(%eax),%ecx
c01085bf:	8b 55 08             	mov    0x8(%ebp),%edx
c01085c2:	89 0a                	mov    %ecx,(%edx)
c01085c4:	8b 00                	mov    (%eax),%eax
c01085c6:	ba 00 00 00 00       	mov    $0x0,%edx
c01085cb:	eb 14                	jmp    c01085e1 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01085cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01085d0:	8b 00                	mov    (%eax),%eax
c01085d2:	8d 48 04             	lea    0x4(%eax),%ecx
c01085d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01085d8:	89 0a                	mov    %ecx,(%edx)
c01085da:	8b 00                	mov    (%eax),%eax
c01085dc:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01085e1:	5d                   	pop    %ebp
c01085e2:	c3                   	ret    

c01085e3 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01085e3:	55                   	push   %ebp
c01085e4:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01085e6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01085ea:	7e 14                	jle    c0108600 <getint+0x1d>
        return va_arg(*ap, long long);
c01085ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01085ef:	8b 00                	mov    (%eax),%eax
c01085f1:	8d 48 08             	lea    0x8(%eax),%ecx
c01085f4:	8b 55 08             	mov    0x8(%ebp),%edx
c01085f7:	89 0a                	mov    %ecx,(%edx)
c01085f9:	8b 50 04             	mov    0x4(%eax),%edx
c01085fc:	8b 00                	mov    (%eax),%eax
c01085fe:	eb 28                	jmp    c0108628 <getint+0x45>
    }
    else if (lflag) {
c0108600:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108604:	74 12                	je     c0108618 <getint+0x35>
        return va_arg(*ap, long);
c0108606:	8b 45 08             	mov    0x8(%ebp),%eax
c0108609:	8b 00                	mov    (%eax),%eax
c010860b:	8d 48 04             	lea    0x4(%eax),%ecx
c010860e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108611:	89 0a                	mov    %ecx,(%edx)
c0108613:	8b 00                	mov    (%eax),%eax
c0108615:	99                   	cltd   
c0108616:	eb 10                	jmp    c0108628 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108618:	8b 45 08             	mov    0x8(%ebp),%eax
c010861b:	8b 00                	mov    (%eax),%eax
c010861d:	8d 48 04             	lea    0x4(%eax),%ecx
c0108620:	8b 55 08             	mov    0x8(%ebp),%edx
c0108623:	89 0a                	mov    %ecx,(%edx)
c0108625:	8b 00                	mov    (%eax),%eax
c0108627:	99                   	cltd   
    }
}
c0108628:	5d                   	pop    %ebp
c0108629:	c3                   	ret    

c010862a <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010862a:	55                   	push   %ebp
c010862b:	89 e5                	mov    %esp,%ebp
c010862d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0108630:	8d 45 14             	lea    0x14(%ebp),%eax
c0108633:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108636:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108639:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010863d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108640:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108644:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108647:	89 44 24 04          	mov    %eax,0x4(%esp)
c010864b:	8b 45 08             	mov    0x8(%ebp),%eax
c010864e:	89 04 24             	mov    %eax,(%esp)
c0108651:	e8 03 00 00 00       	call   c0108659 <vprintfmt>
    va_end(ap);
}
c0108656:	90                   	nop
c0108657:	c9                   	leave  
c0108658:	c3                   	ret    

c0108659 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108659:	55                   	push   %ebp
c010865a:	89 e5                	mov    %esp,%ebp
c010865c:	56                   	push   %esi
c010865d:	53                   	push   %ebx
c010865e:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108661:	eb 17                	jmp    c010867a <vprintfmt+0x21>
            if (ch == '\0') {
c0108663:	85 db                	test   %ebx,%ebx
c0108665:	0f 84 bf 03 00 00    	je     c0108a2a <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010866b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010866e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108672:	89 1c 24             	mov    %ebx,(%esp)
c0108675:	8b 45 08             	mov    0x8(%ebp),%eax
c0108678:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010867a:	8b 45 10             	mov    0x10(%ebp),%eax
c010867d:	8d 50 01             	lea    0x1(%eax),%edx
c0108680:	89 55 10             	mov    %edx,0x10(%ebp)
c0108683:	0f b6 00             	movzbl (%eax),%eax
c0108686:	0f b6 d8             	movzbl %al,%ebx
c0108689:	83 fb 25             	cmp    $0x25,%ebx
c010868c:	75 d5                	jne    c0108663 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010868e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108692:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010869c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010869f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01086a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01086a9:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01086ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01086af:	8d 50 01             	lea    0x1(%eax),%edx
c01086b2:	89 55 10             	mov    %edx,0x10(%ebp)
c01086b5:	0f b6 00             	movzbl (%eax),%eax
c01086b8:	0f b6 d8             	movzbl %al,%ebx
c01086bb:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01086be:	83 f8 55             	cmp    $0x55,%eax
c01086c1:	0f 87 37 03 00 00    	ja     c01089fe <vprintfmt+0x3a5>
c01086c7:	8b 04 85 74 aa 10 c0 	mov    -0x3fef558c(,%eax,4),%eax
c01086ce:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01086d0:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01086d4:	eb d6                	jmp    c01086ac <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01086d6:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01086da:	eb d0                	jmp    c01086ac <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01086dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01086e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01086e6:	89 d0                	mov    %edx,%eax
c01086e8:	c1 e0 02             	shl    $0x2,%eax
c01086eb:	01 d0                	add    %edx,%eax
c01086ed:	01 c0                	add    %eax,%eax
c01086ef:	01 d8                	add    %ebx,%eax
c01086f1:	83 e8 30             	sub    $0x30,%eax
c01086f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01086f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01086fa:	0f b6 00             	movzbl (%eax),%eax
c01086fd:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0108700:	83 fb 2f             	cmp    $0x2f,%ebx
c0108703:	7e 38                	jle    c010873d <vprintfmt+0xe4>
c0108705:	83 fb 39             	cmp    $0x39,%ebx
c0108708:	7f 33                	jg     c010873d <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010870a:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010870d:	eb d4                	jmp    c01086e3 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010870f:	8b 45 14             	mov    0x14(%ebp),%eax
c0108712:	8d 50 04             	lea    0x4(%eax),%edx
c0108715:	89 55 14             	mov    %edx,0x14(%ebp)
c0108718:	8b 00                	mov    (%eax),%eax
c010871a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010871d:	eb 1f                	jmp    c010873e <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010871f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108723:	79 87                	jns    c01086ac <vprintfmt+0x53>
                width = 0;
c0108725:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010872c:	e9 7b ff ff ff       	jmp    c01086ac <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0108731:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108738:	e9 6f ff ff ff       	jmp    c01086ac <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c010873d:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c010873e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108742:	0f 89 64 ff ff ff    	jns    c01086ac <vprintfmt+0x53>
                width = precision, precision = -1;
c0108748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010874b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010874e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108755:	e9 52 ff ff ff       	jmp    c01086ac <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010875a:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010875d:	e9 4a ff ff ff       	jmp    c01086ac <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108762:	8b 45 14             	mov    0x14(%ebp),%eax
c0108765:	8d 50 04             	lea    0x4(%eax),%edx
c0108768:	89 55 14             	mov    %edx,0x14(%ebp)
c010876b:	8b 00                	mov    (%eax),%eax
c010876d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108770:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108774:	89 04 24             	mov    %eax,(%esp)
c0108777:	8b 45 08             	mov    0x8(%ebp),%eax
c010877a:	ff d0                	call   *%eax
            break;
c010877c:	e9 a4 02 00 00       	jmp    c0108a25 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108781:	8b 45 14             	mov    0x14(%ebp),%eax
c0108784:	8d 50 04             	lea    0x4(%eax),%edx
c0108787:	89 55 14             	mov    %edx,0x14(%ebp)
c010878a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010878c:	85 db                	test   %ebx,%ebx
c010878e:	79 02                	jns    c0108792 <vprintfmt+0x139>
                err = -err;
c0108790:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108792:	83 fb 06             	cmp    $0x6,%ebx
c0108795:	7f 0b                	jg     c01087a2 <vprintfmt+0x149>
c0108797:	8b 34 9d 34 aa 10 c0 	mov    -0x3fef55cc(,%ebx,4),%esi
c010879e:	85 f6                	test   %esi,%esi
c01087a0:	75 23                	jne    c01087c5 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01087a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01087a6:	c7 44 24 08 61 aa 10 	movl   $0xc010aa61,0x8(%esp)
c01087ad:	c0 
c01087ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01087b8:	89 04 24             	mov    %eax,(%esp)
c01087bb:	e8 6a fe ff ff       	call   c010862a <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01087c0:	e9 60 02 00 00       	jmp    c0108a25 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01087c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01087c9:	c7 44 24 08 6a aa 10 	movl   $0xc010aa6a,0x8(%esp)
c01087d0:	c0 
c01087d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01087db:	89 04 24             	mov    %eax,(%esp)
c01087de:	e8 47 fe ff ff       	call   c010862a <printfmt>
            }
            break;
c01087e3:	e9 3d 02 00 00       	jmp    c0108a25 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01087e8:	8b 45 14             	mov    0x14(%ebp),%eax
c01087eb:	8d 50 04             	lea    0x4(%eax),%edx
c01087ee:	89 55 14             	mov    %edx,0x14(%ebp)
c01087f1:	8b 30                	mov    (%eax),%esi
c01087f3:	85 f6                	test   %esi,%esi
c01087f5:	75 05                	jne    c01087fc <vprintfmt+0x1a3>
                p = "(null)";
c01087f7:	be 6d aa 10 c0       	mov    $0xc010aa6d,%esi
            }
            if (width > 0 && padc != '-') {
c01087fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108800:	7e 76                	jle    c0108878 <vprintfmt+0x21f>
c0108802:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108806:	74 70                	je     c0108878 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010880b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010880f:	89 34 24             	mov    %esi,(%esp)
c0108812:	e8 f6 f7 ff ff       	call   c010800d <strnlen>
c0108817:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010881a:	29 c2                	sub    %eax,%edx
c010881c:	89 d0                	mov    %edx,%eax
c010881e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108821:	eb 16                	jmp    c0108839 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0108823:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0108827:	8b 55 0c             	mov    0xc(%ebp),%edx
c010882a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010882e:	89 04 24             	mov    %eax,(%esp)
c0108831:	8b 45 08             	mov    0x8(%ebp),%eax
c0108834:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108836:	ff 4d e8             	decl   -0x18(%ebp)
c0108839:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010883d:	7f e4                	jg     c0108823 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010883f:	eb 37                	jmp    c0108878 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108841:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108845:	74 1f                	je     c0108866 <vprintfmt+0x20d>
c0108847:	83 fb 1f             	cmp    $0x1f,%ebx
c010884a:	7e 05                	jle    c0108851 <vprintfmt+0x1f8>
c010884c:	83 fb 7e             	cmp    $0x7e,%ebx
c010884f:	7e 15                	jle    c0108866 <vprintfmt+0x20d>
                    putch('?', putdat);
c0108851:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108854:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108858:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010885f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108862:	ff d0                	call   *%eax
c0108864:	eb 0f                	jmp    c0108875 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0108866:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108869:	89 44 24 04          	mov    %eax,0x4(%esp)
c010886d:	89 1c 24             	mov    %ebx,(%esp)
c0108870:	8b 45 08             	mov    0x8(%ebp),%eax
c0108873:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108875:	ff 4d e8             	decl   -0x18(%ebp)
c0108878:	89 f0                	mov    %esi,%eax
c010887a:	8d 70 01             	lea    0x1(%eax),%esi
c010887d:	0f b6 00             	movzbl (%eax),%eax
c0108880:	0f be d8             	movsbl %al,%ebx
c0108883:	85 db                	test   %ebx,%ebx
c0108885:	74 27                	je     c01088ae <vprintfmt+0x255>
c0108887:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010888b:	78 b4                	js     c0108841 <vprintfmt+0x1e8>
c010888d:	ff 4d e4             	decl   -0x1c(%ebp)
c0108890:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108894:	79 ab                	jns    c0108841 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108896:	eb 16                	jmp    c01088ae <vprintfmt+0x255>
                putch(' ', putdat);
c0108898:	8b 45 0c             	mov    0xc(%ebp),%eax
c010889b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010889f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01088a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a9:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01088ab:	ff 4d e8             	decl   -0x18(%ebp)
c01088ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088b2:	7f e4                	jg     c0108898 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c01088b4:	e9 6c 01 00 00       	jmp    c0108a25 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01088b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01088bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088c0:	8d 45 14             	lea    0x14(%ebp),%eax
c01088c3:	89 04 24             	mov    %eax,(%esp)
c01088c6:	e8 18 fd ff ff       	call   c01085e3 <getint>
c01088cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01088d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088d7:	85 d2                	test   %edx,%edx
c01088d9:	79 26                	jns    c0108901 <vprintfmt+0x2a8>
                putch('-', putdat);
c01088db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088e2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01088e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ec:	ff d0                	call   *%eax
                num = -(long long)num;
c01088ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088f4:	f7 d8                	neg    %eax
c01088f6:	83 d2 00             	adc    $0x0,%edx
c01088f9:	f7 da                	neg    %edx
c01088fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0108901:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108908:	e9 a8 00 00 00       	jmp    c01089b5 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010890d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108910:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108914:	8d 45 14             	lea    0x14(%ebp),%eax
c0108917:	89 04 24             	mov    %eax,(%esp)
c010891a:	e8 75 fc ff ff       	call   c0108594 <getuint>
c010891f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108922:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0108925:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010892c:	e9 84 00 00 00       	jmp    c01089b5 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0108931:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108938:	8d 45 14             	lea    0x14(%ebp),%eax
c010893b:	89 04 24             	mov    %eax,(%esp)
c010893e:	e8 51 fc ff ff       	call   c0108594 <getuint>
c0108943:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108946:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108949:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108950:	eb 63                	jmp    c01089b5 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0108952:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108955:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108959:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108960:	8b 45 08             	mov    0x8(%ebp),%eax
c0108963:	ff d0                	call   *%eax
            putch('x', putdat);
c0108965:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010896c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108973:	8b 45 08             	mov    0x8(%ebp),%eax
c0108976:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108978:	8b 45 14             	mov    0x14(%ebp),%eax
c010897b:	8d 50 04             	lea    0x4(%eax),%edx
c010897e:	89 55 14             	mov    %edx,0x14(%ebp)
c0108981:	8b 00                	mov    (%eax),%eax
c0108983:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010898d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108994:	eb 1f                	jmp    c01089b5 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108996:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108999:	89 44 24 04          	mov    %eax,0x4(%esp)
c010899d:	8d 45 14             	lea    0x14(%ebp),%eax
c01089a0:	89 04 24             	mov    %eax,(%esp)
c01089a3:	e8 ec fb ff ff       	call   c0108594 <getuint>
c01089a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01089ae:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01089b5:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01089b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089bc:	89 54 24 18          	mov    %edx,0x18(%esp)
c01089c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01089c3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01089c7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01089cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089d1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01089d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01089d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01089e3:	89 04 24             	mov    %eax,(%esp)
c01089e6:	e8 a4 fa ff ff       	call   c010848f <printnum>
            break;
c01089eb:	eb 38                	jmp    c0108a25 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01089ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089f4:	89 1c 24             	mov    %ebx,(%esp)
c01089f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01089fa:	ff d0                	call   *%eax
            break;
c01089fc:	eb 27                	jmp    c0108a25 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01089fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a05:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a0f:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108a11:	ff 4d 10             	decl   0x10(%ebp)
c0108a14:	eb 03                	jmp    c0108a19 <vprintfmt+0x3c0>
c0108a16:	ff 4d 10             	decl   0x10(%ebp)
c0108a19:	8b 45 10             	mov    0x10(%ebp),%eax
c0108a1c:	48                   	dec    %eax
c0108a1d:	0f b6 00             	movzbl (%eax),%eax
c0108a20:	3c 25                	cmp    $0x25,%al
c0108a22:	75 f2                	jne    c0108a16 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0108a24:	90                   	nop
        }
    }
c0108a25:	e9 37 fc ff ff       	jmp    c0108661 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0108a2a:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0108a2b:	83 c4 40             	add    $0x40,%esp
c0108a2e:	5b                   	pop    %ebx
c0108a2f:	5e                   	pop    %esi
c0108a30:	5d                   	pop    %ebp
c0108a31:	c3                   	ret    

c0108a32 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108a32:	55                   	push   %ebp
c0108a33:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108a35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a38:	8b 40 08             	mov    0x8(%eax),%eax
c0108a3b:	8d 50 01             	lea    0x1(%eax),%edx
c0108a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a41:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108a44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a47:	8b 10                	mov    (%eax),%edx
c0108a49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a4c:	8b 40 04             	mov    0x4(%eax),%eax
c0108a4f:	39 c2                	cmp    %eax,%edx
c0108a51:	73 12                	jae    c0108a65 <sprintputch+0x33>
        *b->buf ++ = ch;
c0108a53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a56:	8b 00                	mov    (%eax),%eax
c0108a58:	8d 48 01             	lea    0x1(%eax),%ecx
c0108a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108a5e:	89 0a                	mov    %ecx,(%edx)
c0108a60:	8b 55 08             	mov    0x8(%ebp),%edx
c0108a63:	88 10                	mov    %dl,(%eax)
    }
}
c0108a65:	90                   	nop
c0108a66:	5d                   	pop    %ebp
c0108a67:	c3                   	ret    

c0108a68 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108a68:	55                   	push   %ebp
c0108a69:	89 e5                	mov    %esp,%ebp
c0108a6b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108a6e:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a71:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a77:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108a7b:	8b 45 10             	mov    0x10(%ebp),%eax
c0108a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108a82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a8c:	89 04 24             	mov    %eax,(%esp)
c0108a8f:	e8 08 00 00 00       	call   c0108a9c <vsnprintf>
c0108a94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108a9a:	c9                   	leave  
c0108a9b:	c3                   	ret    

c0108a9c <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108a9c:	55                   	push   %ebp
c0108a9d:	89 e5                	mov    %esp,%ebp
c0108a9f:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aab:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ab1:	01 d0                	add    %edx,%eax
c0108ab3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108abd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108ac1:	74 0a                	je     c0108acd <vsnprintf+0x31>
c0108ac3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ac9:	39 c2                	cmp    %eax,%edx
c0108acb:	76 07                	jbe    c0108ad4 <vsnprintf+0x38>
        return -E_INVAL;
c0108acd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108ad2:	eb 2a                	jmp    c0108afe <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108ad4:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ad7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108adb:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ade:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ae2:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ae9:	c7 04 24 32 8a 10 c0 	movl   $0xc0108a32,(%esp)
c0108af0:	e8 64 fb ff ff       	call   c0108659 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108af8:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108afe:	c9                   	leave  
c0108aff:	c3                   	ret    

c0108b00 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108b00:	55                   	push   %ebp
c0108b01:	89 e5                	mov    %esp,%ebp
c0108b03:	57                   	push   %edi
c0108b04:	56                   	push   %esi
c0108b05:	53                   	push   %ebx
c0108b06:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108b09:	a1 58 0a 12 c0       	mov    0xc0120a58,%eax
c0108b0e:	8b 15 5c 0a 12 c0    	mov    0xc0120a5c,%edx
c0108b14:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108b1a:	6b f0 05             	imul   $0x5,%eax,%esi
c0108b1d:	01 fe                	add    %edi,%esi
c0108b1f:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108b24:	f7 e7                	mul    %edi
c0108b26:	01 d6                	add    %edx,%esi
c0108b28:	89 f2                	mov    %esi,%edx
c0108b2a:	83 c0 0b             	add    $0xb,%eax
c0108b2d:	83 d2 00             	adc    $0x0,%edx
c0108b30:	89 c7                	mov    %eax,%edi
c0108b32:	83 e7 ff             	and    $0xffffffff,%edi
c0108b35:	89 f9                	mov    %edi,%ecx
c0108b37:	0f b7 da             	movzwl %dx,%ebx
c0108b3a:	89 0d 58 0a 12 c0    	mov    %ecx,0xc0120a58
c0108b40:	89 1d 5c 0a 12 c0    	mov    %ebx,0xc0120a5c
    unsigned long long result = (next >> 12);
c0108b46:	a1 58 0a 12 c0       	mov    0xc0120a58,%eax
c0108b4b:	8b 15 5c 0a 12 c0    	mov    0xc0120a5c,%edx
c0108b51:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108b55:	c1 ea 0c             	shr    $0xc,%edx
c0108b58:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108b5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108b5e:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108b65:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108b68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108b6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108b6e:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108b71:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108b7b:	74 1c                	je     c0108b99 <rand+0x99>
c0108b7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b80:	ba 00 00 00 00       	mov    $0x0,%edx
c0108b85:	f7 75 dc             	divl   -0x24(%ebp)
c0108b88:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108b8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b8e:	ba 00 00 00 00       	mov    $0x0,%edx
c0108b93:	f7 75 dc             	divl   -0x24(%ebp)
c0108b96:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108b99:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108b9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108b9f:	f7 75 dc             	divl   -0x24(%ebp)
c0108ba2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108ba5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108ba8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108bab:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108bae:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108bb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108bb4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108bb7:	83 c4 24             	add    $0x24,%esp
c0108bba:	5b                   	pop    %ebx
c0108bbb:	5e                   	pop    %esi
c0108bbc:	5f                   	pop    %edi
c0108bbd:	5d                   	pop    %ebp
c0108bbe:	c3                   	ret    

c0108bbf <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108bbf:	55                   	push   %ebp
c0108bc0:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108bc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bc5:	ba 00 00 00 00       	mov    $0x0,%edx
c0108bca:	a3 58 0a 12 c0       	mov    %eax,0xc0120a58
c0108bcf:	89 15 5c 0a 12 c0    	mov    %edx,0xc0120a5c
}
c0108bd5:	90                   	nop
c0108bd6:	5d                   	pop    %ebp
c0108bd7:	c3                   	ret    
