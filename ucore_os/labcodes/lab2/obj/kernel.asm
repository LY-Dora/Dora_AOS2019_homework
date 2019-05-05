
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
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
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 1f 56 00 00       	call   c0105681 <memset>

    cons_init();                // init the console
c0100062:	e8 75 15 00 00       	call   c01015dc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 5e 10 c0 	movl   $0xc0105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 5e 10 c0 	movl   $0xc0105e9c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 fe 30 00 00       	call   c010318e <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 ab 16 00 00       	call   c0101740 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 04 18 00 00       	call   c010189e <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 f0 0c 00 00       	call   c0100d8f <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 cf 17 00 00       	call   c0101873 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 b5 0c 00 00       	call   c0100d7d <mon_backtrace>
}
c01000c8:	90                   	nop
c01000c9:	c9                   	leave  
c01000ca:	c3                   	ret    

c01000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cb:	55                   	push   %ebp
c01000cc:	89 e5                	mov    %esp,%ebp
c01000ce:	53                   	push   %ebx
c01000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b4 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	83 c4 14             	add    $0x14,%esp
c01000f6:	5b                   	pop    %ebx
c01000f7:	5d                   	pop    %ebp
c01000f8:	c3                   	ret    

c01000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f9:	55                   	push   %ebp
c01000fa:	89 e5                	mov    %esp,%ebp
c01000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0100102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ba ff ff ff       	call   c01000cb <grade_backtrace1>
}
c0100111:	90                   	nop
c0100112:	c9                   	leave  
c0100113:	c3                   	ret    

c0100114 <grade_backtrace>:

void
grade_backtrace(void) {
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100126:	ff 
c0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100132:	e8 c2 ff ff ff       	call   c01000f9 <grade_backtrace0>
}
c0100137:	90                   	nop
c0100138:	c9                   	leave  
c0100139:	c3                   	ret    

c010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013a:	55                   	push   %ebp
c010013b:	89 e5                	mov    %esp,%ebp
c010013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100150:	83 e0 03             	and    $0x3,%eax
c0100153:	89 c2                	mov    %eax,%edx
c0100155:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 a1 5e 10 c0 	movl   $0xc0105ea1,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 5e 10 c0 	movl   $0xc0105eaf,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 bd 5e 10 c0 	movl   $0xc0105ebd,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 cb 5e 10 c0 	movl   $0xc0105ecb,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 d9 5e 10 c0 	movl   $0xc0105ed9,(%esp)
c01001e5:	e8 a8 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ea:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001f5:	90                   	nop
c01001f6:	c9                   	leave  
c01001f7:	c3                   	ret    

c01001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f8:	55                   	push   %ebp
c01001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001fb:	90                   	nop
c01001fc:	5d                   	pop    %ebp
c01001fd:	c3                   	ret    

c01001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001fe:	55                   	push   %ebp
c01001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100201:	90                   	nop
c0100202:	5d                   	pop    %ebp
c0100203:	c3                   	ret    

c0100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100204:	55                   	push   %ebp
c0100205:	89 e5                	mov    %esp,%ebp
c0100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020a:	e8 2b ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010020f:	c7 04 24 e8 5e 10 c0 	movl   $0xc0105ee8,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 08 5f 10 c0 	movl   $0xc0105f08,(%esp)
c010022c:	e8 61 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_kernel();
c0100231:	e8 c8 ff ff ff       	call   c01001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100236:	e8 ff fe ff ff       	call   c010013a <lab1_print_cur_status>
}
c010023b:	90                   	nop
c010023c:	c9                   	leave  
c010023d:	c3                   	ret    

c010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023e:	55                   	push   %ebp
c010023f:	89 e5                	mov    %esp,%ebp
c0100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100244:	8b 45 08             	mov    0x8(%ebp),%eax
c0100247:	89 04 24             	mov    %eax,(%esp)
c010024a:	e8 ba 13 00 00       	call   c0101609 <cons_putc>
    (*cnt) ++;
c010024f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100252:	8b 00                	mov    (%eax),%eax
c0100254:	8d 50 01             	lea    0x1(%eax),%edx
c0100257:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025a:	89 10                	mov    %edx,(%eax)
}
c010025c:	90                   	nop
c010025d:	c9                   	leave  
c010025e:	c3                   	ret    

c010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010025f:	55                   	push   %ebp
c0100260:	89 e5                	mov    %esp,%ebp
c0100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010027d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100281:	c7 04 24 3e 02 10 c0 	movl   $0xc010023e,(%esp)
c0100288:	e8 47 57 00 00       	call   c01059d4 <vprintfmt>
    return cnt;
c010028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100298:	8d 45 0c             	lea    0xc(%ebp),%eax
c010029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 af ff ff ff       	call   c010025f <vcprintf>
c01002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b6:	c9                   	leave  
c01002b7:	c3                   	ret    

c01002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b8:	55                   	push   %ebp
c01002b9:	89 e5                	mov    %esp,%ebp
c01002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002be:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c1:	89 04 24             	mov    %eax,(%esp)
c01002c4:	e8 40 13 00 00       	call   c0101609 <cons_putc>
}
c01002c9:	90                   	nop
c01002ca:	c9                   	leave  
c01002cb:	c3                   	ret    

c01002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002cc:	55                   	push   %ebp
c01002cd:	89 e5                	mov    %esp,%ebp
c01002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d9:	eb 13                	jmp    c01002ee <cputs+0x22>
        cputch(c, &cnt);
c01002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002e6:	89 04 24             	mov    %eax,(%esp)
c01002e9:	e8 50 ff ff ff       	call   c010023e <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f1:	8d 50 01             	lea    0x1(%eax),%edx
c01002f4:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f7:	0f b6 00             	movzbl (%eax),%eax
c01002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100301:	75 d8                	jne    c01002db <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100306:	89 44 24 04          	mov    %eax,0x4(%esp)
c010030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100311:	e8 28 ff ff ff       	call   c010023e <cputch>
    return cnt;
c0100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100319:	c9                   	leave  
c010031a:	c3                   	ret    

c010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010031b:	55                   	push   %ebp
c010031c:	89 e5                	mov    %esp,%ebp
c010031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100321:	e8 20 13 00 00       	call   c0101646 <cons_getc>
c0100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010032d:	74 f2                	je     c0100321 <getchar+0x6>
        /* do nothing */;
    return c;
c010032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100332:	c9                   	leave  
c0100333:	c3                   	ret    

c0100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100334:	55                   	push   %ebp
c0100335:	89 e5                	mov    %esp,%ebp
c0100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010033e:	74 13                	je     c0100353 <readline+0x1f>
        cprintf("%s", prompt);
c0100340:	8b 45 08             	mov    0x8(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 27 5f 10 c0 	movl   $0xc0105f27,(%esp)
c010034e:	e8 3f ff ff ff       	call   c0100292 <cprintf>
    }
    int i = 0, c;
c0100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010035a:	e8 bc ff ff ff       	call   c010031b <getchar>
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100366:	79 07                	jns    c010036f <readline+0x3b>
            return NULL;
c0100368:	b8 00 00 00 00       	mov    $0x0,%eax
c010036d:	eb 78                	jmp    c01003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100373:	7e 28                	jle    c010039d <readline+0x69>
c0100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010037c:	7f 1f                	jg     c010039d <readline+0x69>
            cputchar(c);
c010037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100381:	89 04 24             	mov    %eax,(%esp)
c0100384:	e8 2f ff ff ff       	call   c01002b8 <cputchar>
            buf[i ++] = c;
c0100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038c:	8d 50 01             	lea    0x1(%eax),%edx
c010038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100395:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c010039b:	eb 45                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c010039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a1:	75 16                	jne    c01003b9 <readline+0x85>
c01003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a7:	7e 10                	jle    c01003b9 <readline+0x85>
            cputchar(c);
c01003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ac:	89 04 24             	mov    %eax,(%esp)
c01003af:	e8 04 ff ff ff       	call   c01002b8 <cputchar>
            i --;
c01003b4:	ff 4d f4             	decl   -0xc(%ebp)
c01003b7:	eb 29                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003bd:	74 06                	je     c01003c5 <readline+0x91>
c01003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c3:	75 95                	jne    c010035a <readline+0x26>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 e8 fe ff ff       	call   c01002b8 <cputchar>
            buf[i] = '\0';
c01003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01003e0:	eb 05                	jmp    c01003e7 <readline+0xb3>
        }
    }
c01003e2:	e9 73 ff ff ff       	jmp    c010035a <readline+0x26>
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ef:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	75 5b                	jne    c0100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003f8:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c01003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100402:	8d 45 14             	lea    0x14(%ebp),%eax
c0100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010040f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100412:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100416:	c7 04 24 2a 5f 10 c0 	movl   $0xc0105f2a,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 46 5f 10 c0 	movl   $0xc0105f46,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 48 5f 10 c0 	movl   $0xc0105f48,(%esp)
c0100447:	e8 46 fe ff ff       	call   c0100292 <cprintf>
    print_stackframe();
c010044c:	e8 32 06 00 00       	call   c0100a83 <print_stackframe>
c0100451:	eb 01                	jmp    c0100454 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100453:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100454:	e8 21 14 00 00       	call   c010187a <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100460:	e8 4b 08 00 00       	call   c0100cb0 <kmonitor>
    }
c0100465:	eb f2                	jmp    c0100459 <__panic+0x70>

c0100467 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100467:	55                   	push   %ebp
c0100468:	89 e5                	mov    %esp,%ebp
c010046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010046d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100476:	89 44 24 08          	mov    %eax,0x8(%esp)
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	c7 04 24 5a 5f 10 c0 	movl   $0xc0105f5a,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 46 5f 10 c0 	movl   $0xc0105f46,(%esp)
c01004a6:	e8 e7 fd ff ff       	call   c0100292 <cprintf>
    va_end(ap);
}
c01004ab:	90                   	nop
c01004ac:	c9                   	leave  
c01004ad:	c3                   	ret    

c01004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ae:	55                   	push   %ebp
c01004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b1:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c01004b6:	5d                   	pop    %ebp
c01004b7:	c3                   	ret    

c01004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004b8:	55                   	push   %ebp
c01004b9:	89 e5                	mov    %esp,%ebp
c01004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c1:	8b 00                	mov    (%eax),%eax
c01004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	8b 00                	mov    (%eax),%eax
c01004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d5:	e9 ca 00 00 00       	jmp    c01005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e0:	01 d0                	add    %edx,%eax
c01004e2:	89 c2                	mov    %eax,%edx
c01004e4:	c1 ea 1f             	shr    $0x1f,%edx
c01004e7:	01 d0                	add    %edx,%eax
c01004e9:	d1 f8                	sar    %eax
c01004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f4:	eb 03                	jmp    c01004f9 <stab_binsearch+0x41>
            m --;
c01004f6:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004ff:	7c 1f                	jl     c0100520 <stab_binsearch+0x68>
c0100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100504:	89 d0                	mov    %edx,%eax
c0100506:	01 c0                	add    %eax,%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	c1 e0 02             	shl    $0x2,%eax
c010050d:	89 c2                	mov    %eax,%edx
c010050f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100512:	01 d0                	add    %edx,%eax
c0100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100518:	0f b6 c0             	movzbl %al,%eax
c010051b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010051e:	75 d6                	jne    c01004f6 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100526:	7d 09                	jge    c0100531 <stab_binsearch+0x79>
            l = true_m + 1;
c0100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052b:	40                   	inc    %eax
c010052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010052f:	eb 73                	jmp    c01005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053b:	89 d0                	mov    %edx,%eax
c010053d:	01 c0                	add    %eax,%eax
c010053f:	01 d0                	add    %edx,%eax
c0100541:	c1 e0 02             	shl    $0x2,%eax
c0100544:	89 c2                	mov    %eax,%edx
c0100546:	8b 45 08             	mov    0x8(%ebp),%eax
c0100549:	01 d0                	add    %edx,%eax
c010054b:	8b 40 08             	mov    0x8(%eax),%eax
c010054e:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100551:	73 11                	jae    c0100564 <stab_binsearch+0xac>
            *region_left = m;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010055e:	40                   	inc    %eax
c010055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100562:	eb 40                	jmp    c01005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100567:	89 d0                	mov    %edx,%eax
c0100569:	01 c0                	add    %eax,%eax
c010056b:	01 d0                	add    %edx,%eax
c010056d:	c1 e0 02             	shl    $0x2,%eax
c0100570:	89 c2                	mov    %eax,%edx
c0100572:	8b 45 08             	mov    0x8(%ebp),%eax
c0100575:	01 d0                	add    %edx,%eax
c0100577:	8b 40 08             	mov    0x8(%eax),%eax
c010057a:	3b 45 18             	cmp    0x18(%ebp),%eax
c010057d:	76 14                	jbe    c0100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100582:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100585:	8b 45 10             	mov    0x10(%ebp),%eax
c0100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058d:	48                   	dec    %eax
c010058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100591:	eb 11                	jmp    c01005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100593:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100599:	89 10                	mov    %edx,(%eax)
            l = m;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a1:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005aa:	0f 8e 2a ff ff ff    	jle    c01004da <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b4:	75 0f                	jne    c01005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b9:	8b 00                	mov    (%eax),%eax
c01005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005be:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c3:	eb 3e                	jmp    c0100603 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005cd:	eb 03                	jmp    c01005d2 <stab_binsearch+0x11a>
c01005cf:	ff 4d fc             	decl   -0x4(%ebp)
c01005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d5:	8b 00                	mov    (%eax),%eax
c01005d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005da:	7d 1f                	jge    c01005fb <stab_binsearch+0x143>
c01005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005df:	89 d0                	mov    %edx,%eax
c01005e1:	01 c0                	add    %eax,%eax
c01005e3:	01 d0                	add    %edx,%eax
c01005e5:	c1 e0 02             	shl    $0x2,%eax
c01005e8:	89 c2                	mov    %eax,%edx
c01005ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ed:	01 d0                	add    %edx,%eax
c01005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f3:	0f b6 c0             	movzbl %al,%eax
c01005f6:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005f9:	75 d4                	jne    c01005cf <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c01005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100601:	89 10                	mov    %edx,(%eax)
    }
}
c0100603:	90                   	nop
c0100604:	c9                   	leave  
c0100605:	c3                   	ret    

c0100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100606:	55                   	push   %ebp
c0100607:	89 e5                	mov    %esp,%ebp
c0100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060f:	c7 00 78 5f 10 c0    	movl   $0xc0105f78,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 78 5f 10 c0 	movl   $0xc0105f78,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100633:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100636:	8b 55 08             	mov    0x8(%ebp),%edx
c0100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100646:	c7 45 f4 70 71 10 c0 	movl   $0xc0107170,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 a0 1f 11 c0 	movl   $0xc0111fa0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec a1 1f 11 c0 	movl   $0xc0111fa1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 86 4a 11 c0 	movl   $0xc0114a86,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100668:	76 0b                	jbe    c0100675 <debuginfo_eip+0x6f>
c010066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066d:	48                   	dec    %eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x79>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 b7 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068c:	29 c2                	sub    %eax,%edx
c010068e:	89 d0                	mov    %edx,%eax
c0100690:	c1 f8 02             	sar    $0x2,%eax
c0100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100699:	48                   	dec    %eax
c010069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069d:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ab:	00 
c01006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006af:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bd:	89 04 24             	mov    %eax,(%esp)
c01006c0:	e8 f3 fd ff ff       	call   c01004b8 <stab_binsearch>
    if (lfile == 0)
c01006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c8:	85 c0                	test   %eax,%eax
c01006ca:	75 0a                	jne    c01006d6 <debuginfo_eip+0xd0>
        return -1;
c01006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d1:	e9 60 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006f0:	00 
c01006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	89 04 24             	mov    %eax,(%esp)
c0100705:	e8 ae fd ff ff       	call   c01004b8 <stab_binsearch>

    if (lfun <= rfun) {
c010070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100710:	39 c2                	cmp    %eax,%edx
c0100712:	7f 7c                	jg     c0100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100717:	89 c2                	mov    %eax,%edx
c0100719:	89 d0                	mov    %edx,%eax
c010071b:	01 c0                	add    %eax,%eax
c010071d:	01 d0                	add    %edx,%eax
c010071f:	c1 e0 02             	shl    $0x2,%eax
c0100722:	89 c2                	mov    %eax,%edx
c0100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100727:	01 d0                	add    %edx,%eax
c0100729:	8b 00                	mov    (%eax),%eax
c010072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100731:	29 d1                	sub    %edx,%ecx
c0100733:	89 ca                	mov    %ecx,%edx
c0100735:	39 d0                	cmp    %edx,%eax
c0100737:	73 22                	jae    c010075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	89 d0                	mov    %edx,%eax
c0100740:	01 c0                	add    %eax,%eax
c0100742:	01 d0                	add    %edx,%eax
c0100744:	c1 e0 02             	shl    $0x2,%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	8b 10                	mov    (%eax),%edx
c0100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100753:	01 c2                	add    %eax,%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	89 d0                	mov    %edx,%eax
c0100762:	01 c0                	add    %eax,%eax
c0100764:	01 d0                	add    %edx,%eax
c0100766:	c1 e0 02             	shl    $0x2,%eax
c0100769:	89 c2                	mov    %eax,%edx
c010076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	8b 50 08             	mov    0x8(%eax),%edx
c0100773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100779:	8b 45 0c             	mov    0xc(%ebp),%eax
c010077c:	8b 40 10             	mov    0x10(%eax),%eax
c010077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010078e:	eb 15                	jmp    c01007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 55 08             	mov    0x8(%ebp),%edx
c0100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	8b 40 08             	mov    0x8(%eax),%eax
c01007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007b2:	00 
c01007b3:	89 04 24             	mov    %eax,(%esp)
c01007b6:	e8 42 4d 00 00       	call   c01054fd <strfind>
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c0:	8b 40 08             	mov    0x8(%eax),%eax
c01007c3:	29 c2                	sub    %eax,%edx
c01007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007d9:	00 
c01007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007eb:	89 04 24             	mov    %eax,(%esp)
c01007ee:	e8 c5 fc ff ff       	call   c01004b8 <stab_binsearch>
    if (lline <= rline) {
c01007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007f9:	39 c2                	cmp    %eax,%edx
c01007fb:	7f 23                	jg     c0100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c01007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	89 d0                	mov    %edx,%eax
c0100804:	01 c0                	add    %eax,%eax
c0100806:	01 d0                	add    %edx,%eax
c0100808:	c1 e0 02             	shl    $0x2,%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100816:	89 c2                	mov    %eax,%edx
c0100818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010081e:	eb 11                	jmp    c0100831 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100825:	e9 0c 01 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082d:	48                   	dec    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100837:	39 c2                	cmp    %eax,%edx
c0100839:	7c 56                	jl     c0100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083e:	89 c2                	mov    %eax,%edx
c0100840:	89 d0                	mov    %edx,%eax
c0100842:	01 c0                	add    %eax,%eax
c0100844:	01 d0                	add    %edx,%eax
c0100846:	c1 e0 02             	shl    $0x2,%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100854:	3c 84                	cmp    $0x84,%al
c0100856:	74 39                	je     c0100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c 64                	cmp    $0x64,%al
c0100873:	75 b5                	jne    c010082a <debuginfo_eip+0x224>
c0100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	89 d0                	mov    %edx,%eax
c010087c:	01 c0                	add    %eax,%eax
c010087e:	01 d0                	add    %edx,%eax
c0100880:	c1 e0 02             	shl    $0x2,%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	01 d0                	add    %edx,%eax
c010088a:	8b 40 08             	mov    0x8(%eax),%eax
c010088d:	85 c0                	test   %eax,%eax
c010088f:	74 99                	je     c010082a <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100897:	39 c2                	cmp    %eax,%edx
c0100899:	7c 46                	jl     c01008e1 <debuginfo_eip+0x2db>
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	8b 00                	mov    (%eax),%eax
c01008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008b8:	29 d1                	sub    %edx,%ecx
c01008ba:	89 ca                	mov    %ecx,%edx
c01008bc:	39 d0                	cmp    %edx,%eax
c01008be:	73 21                	jae    c01008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c3:	89 c2                	mov    %eax,%edx
c01008c5:	89 d0                	mov    %edx,%eax
c01008c7:	01 c0                	add    %eax,%eax
c01008c9:	01 d0                	add    %edx,%eax
c01008cb:	c1 e0 02             	shl    $0x2,%eax
c01008ce:	89 c2                	mov    %eax,%edx
c01008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d3:	01 d0                	add    %edx,%eax
c01008d5:	8b 10                	mov    (%eax),%edx
c01008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008da:	01 c2                	add    %eax,%edx
c01008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008e7:	39 c2                	cmp    %eax,%edx
c01008e9:	7d 46                	jge    c0100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ee:	40                   	inc    %eax
c01008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008f2:	eb 16                	jmp    c010090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f7:	8b 40 14             	mov    0x14(%eax),%eax
c01008fa:	8d 50 01             	lea    0x1(%eax),%edx
c01008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100900:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100906:	40                   	inc    %eax
c0100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	7d 1d                	jge    c0100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010092d:	3c a0                	cmp    $0xa0,%al
c010092f:	74 c3                	je     c01008f4 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100936:	c9                   	leave  
c0100937:	c3                   	ret    

c0100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100938:	55                   	push   %ebp
c0100939:	89 e5                	mov    %esp,%ebp
c010093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010093e:	c7 04 24 82 5f 10 c0 	movl   $0xc0105f82,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 9b 5f 10 c0 	movl   $0xc0105f9b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 7b 5e 10 	movl   $0xc0105e7b,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 b3 5f 10 c0 	movl   $0xc0105fb3,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 cb 5f 10 c0 	movl   $0xc0105fcb,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 e3 5f 10 c0 	movl   $0xc0105fe3,(%esp)
c0100995:	e8 f8 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099a:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c010099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009aa:	29 c2                	sub    %eax,%edx
c01009ac:	89 d0                	mov    %edx,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	85 c0                	test   %eax,%eax
c01009b6:	0f 48 c2             	cmovs  %edx,%eax
c01009b9:	c1 f8 0a             	sar    $0xa,%eax
c01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c0:	c7 04 24 fc 5f 10 c0 	movl   $0xc0105ffc,(%esp)
c01009c7:	e8 c6 f8 ff ff       	call   c0100292 <cprintf>
}
c01009cc:	90                   	nop
c01009cd:	c9                   	leave  
c01009ce:	c3                   	ret    

c01009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009cf:	55                   	push   %ebp
c01009d0:	89 e5                	mov    %esp,%ebp
c01009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009df:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e2:	89 04 24             	mov    %eax,(%esp)
c01009e5:	e8 1c fc ff ff       	call   c0100606 <debuginfo_eip>
c01009ea:	85 c0                	test   %eax,%eax
c01009ec:	74 15                	je     c0100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f5:	c7 04 24 26 60 10 c0 	movl   $0xc0106026,(%esp)
c01009fc:	e8 91 f8 ff ff       	call   c0100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a01:	eb 6c                	jmp    c0100a6f <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a0a:	eb 1b                	jmp    c0100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a12:	01 d0                	add    %edx,%eax
c0100a14:	0f b6 00             	movzbl (%eax),%eax
c0100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a20:	01 ca                	add    %ecx,%edx
c0100a22:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a24:	ff 45 f4             	incl   -0xc(%ebp)
c0100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a2d:	7f dd                	jg     c0100a0c <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a38:	01 d0                	add    %edx,%eax
c0100a3a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a40:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a43:	89 d1                	mov    %edx,%ecx
c0100a45:	29 c1                	sub    %eax,%ecx
c0100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a63:	c7 04 24 42 60 10 c0 	movl   $0xc0106042,(%esp)
c0100a6a:	e8 23 f8 ff ff       	call   c0100292 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a6f:	90                   	nop
c0100a70:	c9                   	leave  
c0100a71:	c3                   	ret    

c0100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a72:	55                   	push   %ebp
c0100a73:	89 e5                	mov    %esp,%ebp
c0100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a78:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a81:	c9                   	leave  
c0100a82:	c3                   	ret    

c0100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a89:	89 e8                	mov    %ebp,%eax
c0100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
c0100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
c0100a94:	e8 d9 ff ff ff       	call   c0100a72 <read_eip>
c0100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aa3:	e9 88 00 00 00       	jmp    c0100b30 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 54 60 10 c0 	movl   $0xc0106054,(%esp)
c0100abd:	e8 d0 f7 ff ff       	call   c0100292 <cprintf>
        uint32_t *fun_stack = (uint32_t *)ebp ;
c0100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 2; j < 6; j ++) {
c0100ac8:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
c0100acf:	eb 24                	jmp    c0100af5 <print_stackframe+0x72>
            cprintf("0x%08x ", fun_stack[j]);
c0100ad1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ad4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ade:	01 d0                	add    %edx,%eax
c0100ae0:	8b 00                	mov    (%eax),%eax
c0100ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae6:	c7 04 24 70 60 10 c0 	movl   $0xc0106070,(%esp)
c0100aed:	e8 a0 f7 ff ff       	call   c0100292 <cprintf>
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *fun_stack = (uint32_t *)ebp ;
        for (int j = 2; j < 6; j ++) {
c0100af2:	ff 45 e8             	incl   -0x18(%ebp)
c0100af5:	83 7d e8 05          	cmpl   $0x5,-0x18(%ebp)
c0100af9:	7e d6                	jle    c0100ad1 <print_stackframe+0x4e>
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
c0100afb:	c7 04 24 78 60 10 c0 	movl   $0xc0106078,(%esp)
c0100b02:	e8 8b f7 ff ff       	call   c0100292 <cprintf>
        print_debuginfo(eip - 1);
c0100b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0a:	48                   	dec    %eax
c0100b0b:	89 04 24             	mov    %eax,(%esp)
c0100b0e:	e8 bc fe ff ff       	call   c01009cf <print_debuginfo>
        if(fun_stack[0]==0) break;
c0100b13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b16:	8b 00                	mov    (%eax),%eax
c0100b18:	85 c0                	test   %eax,%eax
c0100b1a:	74 20                	je     c0100b3c <print_stackframe+0xb9>
        eip = fun_stack[1];
c0100b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b1f:	8b 40 04             	mov    0x4(%eax),%eax
c0100b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = fun_stack[0];
c0100b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b28:	8b 00                	mov    (%eax),%eax
c0100b2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100b2d:	ff 45 ec             	incl   -0x14(%ebp)
c0100b30:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b34:	0f 8e 6e ff ff ff    	jle    c0100aa8 <print_stackframe+0x25>
        if(fun_stack[0]==0) break;
        eip = fun_stack[1];
        ebp = fun_stack[0];
      }

}
c0100b3a:	eb 01                	jmp    c0100b3d <print_stackframe+0xba>
        for (int j = 2; j < 6; j ++) {
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
c0100b3c:	90                   	nop
        eip = fun_stack[1];
        ebp = fun_stack[0];
      }

}
c0100b3d:	90                   	nop
c0100b3e:	c9                   	leave  
c0100b3f:	c3                   	ret    

c0100b40 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b40:	55                   	push   %ebp
c0100b41:	89 e5                	mov    %esp,%ebp
c0100b43:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4d:	eb 0c                	jmp    c0100b5b <parse+0x1b>
            *buf ++ = '\0';
c0100b4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b52:	8d 50 01             	lea    0x1(%eax),%edx
c0100b55:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b58:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5e:	0f b6 00             	movzbl (%eax),%eax
c0100b61:	84 c0                	test   %al,%al
c0100b63:	74 1d                	je     c0100b82 <parse+0x42>
c0100b65:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b68:	0f b6 00             	movzbl (%eax),%eax
c0100b6b:	0f be c0             	movsbl %al,%eax
c0100b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b72:	c7 04 24 fc 60 10 c0 	movl   $0xc01060fc,(%esp)
c0100b79:	e8 4d 49 00 00       	call   c01054cb <strchr>
c0100b7e:	85 c0                	test   %eax,%eax
c0100b80:	75 cd                	jne    c0100b4f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b82:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b85:	0f b6 00             	movzbl (%eax),%eax
c0100b88:	84 c0                	test   %al,%al
c0100b8a:	74 69                	je     c0100bf5 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b8c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b90:	75 14                	jne    c0100ba6 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b92:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b99:	00 
c0100b9a:	c7 04 24 01 61 10 c0 	movl   $0xc0106101,(%esp)
c0100ba1:	e8 ec f6 ff ff       	call   c0100292 <cprintf>
        }
        argv[argc ++] = buf;
c0100ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba9:	8d 50 01             	lea    0x1(%eax),%edx
c0100bac:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100baf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bb9:	01 c2                	add    %eax,%edx
c0100bbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbe:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc0:	eb 03                	jmp    c0100bc5 <parse+0x85>
            buf ++;
c0100bc2:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc8:	0f b6 00             	movzbl (%eax),%eax
c0100bcb:	84 c0                	test   %al,%al
c0100bcd:	0f 84 7a ff ff ff    	je     c0100b4d <parse+0xd>
c0100bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd6:	0f b6 00             	movzbl (%eax),%eax
c0100bd9:	0f be c0             	movsbl %al,%eax
c0100bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be0:	c7 04 24 fc 60 10 c0 	movl   $0xc01060fc,(%esp)
c0100be7:	e8 df 48 00 00       	call   c01054cb <strchr>
c0100bec:	85 c0                	test   %eax,%eax
c0100bee:	74 d2                	je     c0100bc2 <parse+0x82>
            buf ++;
        }
    }
c0100bf0:	e9 58 ff ff ff       	jmp    c0100b4d <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100bf5:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bf9:	c9                   	leave  
c0100bfa:	c3                   	ret    

c0100bfb <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bfb:	55                   	push   %ebp
c0100bfc:	89 e5                	mov    %esp,%ebp
c0100bfe:	53                   	push   %ebx
c0100bff:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c02:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0c:	89 04 24             	mov    %eax,(%esp)
c0100c0f:	e8 2c ff ff ff       	call   c0100b40 <parse>
c0100c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c1b:	75 0a                	jne    c0100c27 <runcmd+0x2c>
        return 0;
c0100c1d:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c22:	e9 83 00 00 00       	jmp    c0100caa <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c2e:	eb 5a                	jmp    c0100c8a <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c30:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c33:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c36:	89 d0                	mov    %edx,%eax
c0100c38:	01 c0                	add    %eax,%eax
c0100c3a:	01 d0                	add    %edx,%eax
c0100c3c:	c1 e0 02             	shl    $0x2,%eax
c0100c3f:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c44:	8b 00                	mov    (%eax),%eax
c0100c46:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c4a:	89 04 24             	mov    %eax,(%esp)
c0100c4d:	e8 dc 47 00 00       	call   c010542e <strcmp>
c0100c52:	85 c0                	test   %eax,%eax
c0100c54:	75 31                	jne    c0100c87 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c59:	89 d0                	mov    %edx,%eax
c0100c5b:	01 c0                	add    %eax,%eax
c0100c5d:	01 d0                	add    %edx,%eax
c0100c5f:	c1 e0 02             	shl    $0x2,%eax
c0100c62:	05 08 70 11 c0       	add    $0xc0117008,%eax
c0100c67:	8b 10                	mov    (%eax),%edx
c0100c69:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c6c:	83 c0 04             	add    $0x4,%eax
c0100c6f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c72:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c80:	89 1c 24             	mov    %ebx,(%esp)
c0100c83:	ff d2                	call   *%edx
c0100c85:	eb 23                	jmp    c0100caa <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c87:	ff 45 f4             	incl   -0xc(%ebp)
c0100c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8d:	83 f8 02             	cmp    $0x2,%eax
c0100c90:	76 9e                	jbe    c0100c30 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c92:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c99:	c7 04 24 1f 61 10 c0 	movl   $0xc010611f,(%esp)
c0100ca0:	e8 ed f5 ff ff       	call   c0100292 <cprintf>
    return 0;
c0100ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100caa:	83 c4 64             	add    $0x64,%esp
c0100cad:	5b                   	pop    %ebx
c0100cae:	5d                   	pop    %ebp
c0100caf:	c3                   	ret    

c0100cb0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cb0:	55                   	push   %ebp
c0100cb1:	89 e5                	mov    %esp,%ebp
c0100cb3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cb6:	c7 04 24 38 61 10 c0 	movl   $0xc0106138,(%esp)
c0100cbd:	e8 d0 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cc2:	c7 04 24 60 61 10 c0 	movl   $0xc0106160,(%esp)
c0100cc9:	e8 c4 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100cce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cd2:	74 0b                	je     c0100cdf <kmonitor+0x2f>
        print_trapframe(tf);
c0100cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd7:	89 04 24             	mov    %eax,(%esp)
c0100cda:	e8 7c 0d 00 00       	call   c0101a5b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cdf:	c7 04 24 85 61 10 c0 	movl   $0xc0106185,(%esp)
c0100ce6:	e8 49 f6 ff ff       	call   c0100334 <readline>
c0100ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cf2:	74 eb                	je     c0100cdf <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cfe:	89 04 24             	mov    %eax,(%esp)
c0100d01:	e8 f5 fe ff ff       	call   c0100bfb <runcmd>
c0100d06:	85 c0                	test   %eax,%eax
c0100d08:	78 02                	js     c0100d0c <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d0a:	eb d3                	jmp    c0100cdf <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d0c:	90                   	nop
            }
        }
    }
}
c0100d0d:	90                   	nop
c0100d0e:	c9                   	leave  
c0100d0f:	c3                   	ret    

c0100d10 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d10:	55                   	push   %ebp
c0100d11:	89 e5                	mov    %esp,%ebp
c0100d13:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d1d:	eb 3d                	jmp    c0100d5c <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d22:	89 d0                	mov    %edx,%eax
c0100d24:	01 c0                	add    %eax,%eax
c0100d26:	01 d0                	add    %edx,%eax
c0100d28:	c1 e0 02             	shl    $0x2,%eax
c0100d2b:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d30:	8b 08                	mov    (%eax),%ecx
c0100d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d35:	89 d0                	mov    %edx,%eax
c0100d37:	01 c0                	add    %eax,%eax
c0100d39:	01 d0                	add    %edx,%eax
c0100d3b:	c1 e0 02             	shl    $0x2,%eax
c0100d3e:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d43:	8b 00                	mov    (%eax),%eax
c0100d45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4d:	c7 04 24 89 61 10 c0 	movl   $0xc0106189,(%esp)
c0100d54:	e8 39 f5 ff ff       	call   c0100292 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d59:	ff 45 f4             	incl   -0xc(%ebp)
c0100d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5f:	83 f8 02             	cmp    $0x2,%eax
c0100d62:	76 bb                	jbe    c0100d1f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d69:	c9                   	leave  
c0100d6a:	c3                   	ret    

c0100d6b <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d6b:	55                   	push   %ebp
c0100d6c:	89 e5                	mov    %esp,%ebp
c0100d6e:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d71:	e8 c2 fb ff ff       	call   c0100938 <print_kerninfo>
    return 0;
c0100d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7b:	c9                   	leave  
c0100d7c:	c3                   	ret    

c0100d7d <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d7d:	55                   	push   %ebp
c0100d7e:	89 e5                	mov    %esp,%ebp
c0100d80:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d83:	e8 fb fc ff ff       	call   c0100a83 <print_stackframe>
    return 0;
c0100d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8d:	c9                   	leave  
c0100d8e:	c3                   	ret    

c0100d8f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8f:	55                   	push   %ebp
c0100d90:	89 e5                	mov    %esp,%ebp
c0100d92:	83 ec 28             	sub    $0x28,%esp
c0100d95:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d9b:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100da3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100da7:	ee                   	out    %al,(%dx)
c0100da8:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100dae:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100db2:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100db9:	ee                   	out    %al,(%dx)
c0100dba:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dc0:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100dc4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dcc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dcd:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dd4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd7:	c7 04 24 92 61 10 c0 	movl   $0xc0106192,(%esp)
c0100dde:	e8 af f4 ff ff       	call   c0100292 <cprintf>
    pic_enable(IRQ_TIMER);
c0100de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dea:	e8 1e 09 00 00       	call   c010170d <pic_enable>
}
c0100def:	90                   	nop
c0100df0:	c9                   	leave  
c0100df1:	c3                   	ret    

c0100df2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100df2:	55                   	push   %ebp
c0100df3:	89 e5                	mov    %esp,%ebp
c0100df5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df8:	9c                   	pushf  
c0100df9:	58                   	pop    %eax
c0100dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e00:	25 00 02 00 00       	and    $0x200,%eax
c0100e05:	85 c0                	test   %eax,%eax
c0100e07:	74 0c                	je     c0100e15 <__intr_save+0x23>
        intr_disable();
c0100e09:	e8 6c 0a 00 00       	call   c010187a <intr_disable>
        return 1;
c0100e0e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e13:	eb 05                	jmp    c0100e1a <__intr_save+0x28>
    }
    return 0;
c0100e15:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e1a:	c9                   	leave  
c0100e1b:	c3                   	ret    

c0100e1c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e1c:	55                   	push   %ebp
c0100e1d:	89 e5                	mov    %esp,%ebp
c0100e1f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e26:	74 05                	je     c0100e2d <__intr_restore+0x11>
        intr_enable();
c0100e28:	e8 46 0a 00 00       	call   c0101873 <intr_enable>
    }
}
c0100e2d:	90                   	nop
c0100e2e:	c9                   	leave  
c0100e2f:	c3                   	ret    

c0100e30 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e30:	55                   	push   %ebp
c0100e31:	89 e5                	mov    %esp,%ebp
c0100e33:	83 ec 10             	sub    $0x10,%esp
c0100e36:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e3c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e40:	89 c2                	mov    %eax,%edx
c0100e42:	ec                   	in     (%dx),%al
c0100e43:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e46:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e4f:	89 c2                	mov    %eax,%edx
c0100e51:	ec                   	in     (%dx),%al
c0100e52:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e65:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100e6e:	89 c2                	mov    %eax,%edx
c0100e70:	ec                   	in     (%dx),%al
c0100e71:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e74:	90                   	nop
c0100e75:	c9                   	leave  
c0100e76:	c3                   	ret    

c0100e77 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e77:	55                   	push   %ebp
c0100e78:	89 e5                	mov    %esp,%ebp
c0100e7a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e87:	0f b7 00             	movzwl (%eax),%eax
c0100e8a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e91:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e96:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e99:	0f b7 00             	movzwl (%eax),%eax
c0100e9c:	0f b7 c0             	movzwl %ax,%eax
c0100e9f:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ea4:	74 12                	je     c0100eb8 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea6:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ead:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100eb4:	b4 03 
c0100eb6:	eb 13                	jmp    c0100ecb <cga_init+0x54>
    } else {
        *cp = was;
c0100eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ebf:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec2:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ec9:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ecb:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ed2:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100ed6:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100eda:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100ede:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0100ee1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ee9:	40                   	inc    %eax
c0100eea:	0f b7 c0             	movzwl %ax,%eax
c0100eed:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ef5:	89 c2                	mov    %eax,%edx
c0100ef7:	ec                   	in     (%dx),%al
c0100ef8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100efb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100eff:	0f b6 c0             	movzbl %al,%eax
c0100f02:	c1 e0 08             	shl    $0x8,%eax
c0100f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f08:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f0f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f13:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f17:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f1f:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f26:	40                   	inc    %eax
c0100f27:	0f b7 c0             	movzwl %ax,%eax
c0100f2a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f2e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f32:	89 c2                	mov    %eax,%edx
c0100f34:	ec                   	in     (%dx),%al
c0100f35:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f38:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3c:	0f b6 c0             	movzbl %al,%eax
c0100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f45:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f4d:	0f b7 c0             	movzwl %ax,%eax
c0100f50:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f56:	90                   	nop
c0100f57:	c9                   	leave  
c0100f58:	c3                   	ret    

c0100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f59:	55                   	push   %ebp
c0100f5a:	89 e5                	mov    %esp,%ebp
c0100f5c:	83 ec 38             	sub    $0x38,%esp
c0100f5f:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f65:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f69:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f6d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f71:	ee                   	out    %al,(%dx)
c0100f72:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f78:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f7c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f83:	ee                   	out    %al,(%dx)
c0100f84:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100f8a:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100f8e:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100f92:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f96:	ee                   	out    %al,(%dx)
c0100f97:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100f9d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fa1:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100fa8:	ee                   	out    %al,(%dx)
c0100fa9:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100faf:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fb3:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fb7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fbb:	ee                   	out    %al,(%dx)
c0100fbc:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fc2:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fc6:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100fca:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fcd:	ee                   	out    %al,(%dx)
c0100fce:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd4:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100fd8:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100fdc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fe0:	ee                   	out    %al,(%dx)
c0100fe1:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100fea:	89 c2                	mov    %eax,%edx
c0100fec:	ec                   	in     (%dx),%al
c0100fed:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0100ff0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ff4:	3c ff                	cmp    $0xff,%al
c0100ff6:	0f 95 c0             	setne  %al
c0100ff9:	0f b6 c0             	movzbl %al,%eax
c0100ffc:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101001:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101007:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010100b:	89 c2                	mov    %eax,%edx
c010100d:	ec                   	in     (%dx),%al
c010100e:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101011:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101017:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010101a:	89 c2                	mov    %eax,%edx
c010101c:	ec                   	in     (%dx),%al
c010101d:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101020:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101025:	85 c0                	test   %eax,%eax
c0101027:	74 0c                	je     c0101035 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c0101029:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101030:	e8 d8 06 00 00       	call   c010170d <pic_enable>
    }
}
c0101035:	90                   	nop
c0101036:	c9                   	leave  
c0101037:	c3                   	ret    

c0101038 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101038:	55                   	push   %ebp
c0101039:	89 e5                	mov    %esp,%ebp
c010103b:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010103e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101045:	eb 08                	jmp    c010104f <lpt_putc_sub+0x17>
        delay();
c0101047:	e8 e4 fd ff ff       	call   c0100e30 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010104c:	ff 45 fc             	incl   -0x4(%ebp)
c010104f:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101055:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101058:	89 c2                	mov    %eax,%edx
c010105a:	ec                   	in     (%dx),%al
c010105b:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010105e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101062:	84 c0                	test   %al,%al
c0101064:	78 09                	js     c010106f <lpt_putc_sub+0x37>
c0101066:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010106d:	7e d8                	jle    c0101047 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010106f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101072:	0f b6 c0             	movzbl %al,%eax
c0101075:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010107b:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010107e:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101082:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101085:	ee                   	out    %al,(%dx)
c0101086:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010108c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101090:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101094:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101098:	ee                   	out    %al,(%dx)
c0101099:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c010109f:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01010a3:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01010a7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01010ab:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010ac:	90                   	nop
c01010ad:	c9                   	leave  
c01010ae:	c3                   	ret    

c01010af <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010af:	55                   	push   %ebp
c01010b0:	89 e5                	mov    %esp,%ebp
c01010b2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010b5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010b9:	74 0d                	je     c01010c8 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01010be:	89 04 24             	mov    %eax,(%esp)
c01010c1:	e8 72 ff ff ff       	call   c0101038 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010c6:	eb 24                	jmp    c01010ec <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010c8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010cf:	e8 64 ff ff ff       	call   c0101038 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010d4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010db:	e8 58 ff ff ff       	call   c0101038 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e7:	e8 4c ff ff ff       	call   c0101038 <lpt_putc_sub>
    }
}
c01010ec:	90                   	nop
c01010ed:	c9                   	leave  
c01010ee:	c3                   	ret    

c01010ef <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010ef:	55                   	push   %ebp
c01010f0:	89 e5                	mov    %esp,%ebp
c01010f2:	53                   	push   %ebx
c01010f3:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f9:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01010fe:	85 c0                	test   %eax,%eax
c0101100:	75 07                	jne    c0101109 <cga_putc+0x1a>
        c |= 0x0700;
c0101102:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101109:	8b 45 08             	mov    0x8(%ebp),%eax
c010110c:	0f b6 c0             	movzbl %al,%eax
c010110f:	83 f8 0a             	cmp    $0xa,%eax
c0101112:	74 54                	je     c0101168 <cga_putc+0x79>
c0101114:	83 f8 0d             	cmp    $0xd,%eax
c0101117:	74 62                	je     c010117b <cga_putc+0x8c>
c0101119:	83 f8 08             	cmp    $0x8,%eax
c010111c:	0f 85 93 00 00 00    	jne    c01011b5 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101122:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101129:	85 c0                	test   %eax,%eax
c010112b:	0f 84 ae 00 00 00    	je     c01011df <cga_putc+0xf0>
            crt_pos --;
c0101131:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101138:	48                   	dec    %eax
c0101139:	0f b7 c0             	movzwl %ax,%eax
c010113c:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101142:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101147:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010114e:	01 d2                	add    %edx,%edx
c0101150:	01 c2                	add    %eax,%edx
c0101152:	8b 45 08             	mov    0x8(%ebp),%eax
c0101155:	98                   	cwtl   
c0101156:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010115b:	98                   	cwtl   
c010115c:	83 c8 20             	or     $0x20,%eax
c010115f:	98                   	cwtl   
c0101160:	0f b7 c0             	movzwl %ax,%eax
c0101163:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101166:	eb 77                	jmp    c01011df <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c0101168:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010116f:	83 c0 50             	add    $0x50,%eax
c0101172:	0f b7 c0             	movzwl %ax,%eax
c0101175:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010117b:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c0101182:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101189:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010118e:	89 c8                	mov    %ecx,%eax
c0101190:	f7 e2                	mul    %edx
c0101192:	c1 ea 06             	shr    $0x6,%edx
c0101195:	89 d0                	mov    %edx,%eax
c0101197:	c1 e0 02             	shl    $0x2,%eax
c010119a:	01 d0                	add    %edx,%eax
c010119c:	c1 e0 04             	shl    $0x4,%eax
c010119f:	29 c1                	sub    %eax,%ecx
c01011a1:	89 c8                	mov    %ecx,%eax
c01011a3:	0f b7 c0             	movzwl %ax,%eax
c01011a6:	29 c3                	sub    %eax,%ebx
c01011a8:	89 d8                	mov    %ebx,%eax
c01011aa:	0f b7 c0             	movzwl %ax,%eax
c01011ad:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011b3:	eb 2b                	jmp    c01011e0 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011b5:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011bb:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011c2:	8d 50 01             	lea    0x1(%eax),%edx
c01011c5:	0f b7 d2             	movzwl %dx,%edx
c01011c8:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011cf:	01 c0                	add    %eax,%eax
c01011d1:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01011d7:	0f b7 c0             	movzwl %ax,%eax
c01011da:	66 89 02             	mov    %ax,(%edx)
        break;
c01011dd:	eb 01                	jmp    c01011e0 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c01011df:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e0:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011e7:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011ec:	76 5d                	jbe    c010124b <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011ee:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011f9:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011fe:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101205:	00 
c0101206:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120a:	89 04 24             	mov    %eax,(%esp)
c010120d:	e8 af 44 00 00       	call   c01056c1 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101212:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101219:	eb 14                	jmp    c010122f <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c010121b:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101220:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101223:	01 d2                	add    %edx,%edx
c0101225:	01 d0                	add    %edx,%eax
c0101227:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010122c:	ff 45 f4             	incl   -0xc(%ebp)
c010122f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101236:	7e e3                	jle    c010121b <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101238:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010123f:	83 e8 50             	sub    $0x50,%eax
c0101242:	0f b7 c0             	movzwl %ax,%eax
c0101245:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124b:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101252:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101256:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c010125a:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c010125e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101262:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101263:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010126a:	c1 e8 08             	shr    $0x8,%eax
c010126d:	0f b7 c0             	movzwl %ax,%eax
c0101270:	0f b6 c0             	movzbl %al,%eax
c0101273:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127a:	42                   	inc    %edx
c010127b:	0f b7 d2             	movzwl %dx,%edx
c010127e:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101282:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101285:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101289:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010128c:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010128d:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101294:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101298:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c010129c:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c01012a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012a5:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012ac:	0f b6 c0             	movzbl %al,%eax
c01012af:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012b6:	42                   	inc    %edx
c01012b7:	0f b7 d2             	movzwl %dx,%edx
c01012ba:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012be:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012c1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01012c8:	ee                   	out    %al,(%dx)
}
c01012c9:	90                   	nop
c01012ca:	83 c4 24             	add    $0x24,%esp
c01012cd:	5b                   	pop    %ebx
c01012ce:	5d                   	pop    %ebp
c01012cf:	c3                   	ret    

c01012d0 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012d0:	55                   	push   %ebp
c01012d1:	89 e5                	mov    %esp,%ebp
c01012d3:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012dd:	eb 08                	jmp    c01012e7 <serial_putc_sub+0x17>
        delay();
c01012df:	e8 4c fb ff ff       	call   c0100e30 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e4:	ff 45 fc             	incl   -0x4(%ebp)
c01012e7:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01012f0:	89 c2                	mov    %eax,%edx
c01012f2:	ec                   	in     (%dx),%al
c01012f3:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01012f6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01012fa:	0f b6 c0             	movzbl %al,%eax
c01012fd:	83 e0 20             	and    $0x20,%eax
c0101300:	85 c0                	test   %eax,%eax
c0101302:	75 09                	jne    c010130d <serial_putc_sub+0x3d>
c0101304:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010130b:	7e d2                	jle    c01012df <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010130d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101310:	0f b6 c0             	movzbl %al,%eax
c0101313:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101319:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131c:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101320:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101324:	ee                   	out    %al,(%dx)
}
c0101325:	90                   	nop
c0101326:	c9                   	leave  
c0101327:	c3                   	ret    

c0101328 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101328:	55                   	push   %ebp
c0101329:	89 e5                	mov    %esp,%ebp
c010132b:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010132e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101332:	74 0d                	je     c0101341 <serial_putc+0x19>
        serial_putc_sub(c);
c0101334:	8b 45 08             	mov    0x8(%ebp),%eax
c0101337:	89 04 24             	mov    %eax,(%esp)
c010133a:	e8 91 ff ff ff       	call   c01012d0 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010133f:	eb 24                	jmp    c0101365 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101341:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101348:	e8 83 ff ff ff       	call   c01012d0 <serial_putc_sub>
        serial_putc_sub(' ');
c010134d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101354:	e8 77 ff ff ff       	call   c01012d0 <serial_putc_sub>
        serial_putc_sub('\b');
c0101359:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101360:	e8 6b ff ff ff       	call   c01012d0 <serial_putc_sub>
    }
}
c0101365:	90                   	nop
c0101366:	c9                   	leave  
c0101367:	c3                   	ret    

c0101368 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101368:	55                   	push   %ebp
c0101369:	89 e5                	mov    %esp,%ebp
c010136b:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010136e:	eb 33                	jmp    c01013a3 <cons_intr+0x3b>
        if (c != 0) {
c0101370:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101374:	74 2d                	je     c01013a3 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101376:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010137b:	8d 50 01             	lea    0x1(%eax),%edx
c010137e:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101384:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101387:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010138d:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101392:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101397:	75 0a                	jne    c01013a3 <cons_intr+0x3b>
                cons.wpos = 0;
c0101399:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013a0:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a6:	ff d0                	call   *%eax
c01013a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013ab:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013af:	75 bf                	jne    c0101370 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013b1:	90                   	nop
c01013b2:	c9                   	leave  
c01013b3:	c3                   	ret    

c01013b4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013b4:	55                   	push   %ebp
c01013b5:	89 e5                	mov    %esp,%ebp
c01013b7:	83 ec 10             	sub    $0x10,%esp
c01013ba:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01013c3:	89 c2                	mov    %eax,%edx
c01013c5:	ec                   	in     (%dx),%al
c01013c6:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013cd:	0f b6 c0             	movzbl %al,%eax
c01013d0:	83 e0 01             	and    $0x1,%eax
c01013d3:	85 c0                	test   %eax,%eax
c01013d5:	75 07                	jne    c01013de <serial_proc_data+0x2a>
        return -1;
c01013d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013dc:	eb 2a                	jmp    c0101408 <serial_proc_data+0x54>
c01013de:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013e8:	89 c2                	mov    %eax,%edx
c01013ea:	ec                   	in     (%dx),%al
c01013eb:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c01013ee:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013f2:	0f b6 c0             	movzbl %al,%eax
c01013f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013f8:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013fc:	75 07                	jne    c0101405 <serial_proc_data+0x51>
        c = '\b';
c01013fe:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101405:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101408:	c9                   	leave  
c0101409:	c3                   	ret    

c010140a <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010140a:	55                   	push   %ebp
c010140b:	89 e5                	mov    %esp,%ebp
c010140d:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101410:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101415:	85 c0                	test   %eax,%eax
c0101417:	74 0c                	je     c0101425 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101419:	c7 04 24 b4 13 10 c0 	movl   $0xc01013b4,(%esp)
c0101420:	e8 43 ff ff ff       	call   c0101368 <cons_intr>
    }
}
c0101425:	90                   	nop
c0101426:	c9                   	leave  
c0101427:	c3                   	ret    

c0101428 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101428:	55                   	push   %ebp
c0101429:	89 e5                	mov    %esp,%ebp
c010142b:	83 ec 28             	sub    $0x28,%esp
c010142e:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101434:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101437:	89 c2                	mov    %eax,%edx
c0101439:	ec                   	in     (%dx),%al
c010143a:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010143d:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101441:	0f b6 c0             	movzbl %al,%eax
c0101444:	83 e0 01             	and    $0x1,%eax
c0101447:	85 c0                	test   %eax,%eax
c0101449:	75 0a                	jne    c0101455 <kbd_proc_data+0x2d>
        return -1;
c010144b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101450:	e9 56 01 00 00       	jmp    c01015ab <kbd_proc_data+0x183>
c0101455:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010145e:	89 c2                	mov    %eax,%edx
c0101460:	ec                   	in     (%dx),%al
c0101461:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101464:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101468:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010146b:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010146f:	75 17                	jne    c0101488 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101471:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101476:	83 c8 40             	or     $0x40,%eax
c0101479:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010147e:	b8 00 00 00 00       	mov    $0x0,%eax
c0101483:	e9 23 01 00 00       	jmp    c01015ab <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101488:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148c:	84 c0                	test   %al,%al
c010148e:	79 45                	jns    c01014d5 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101490:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101495:	83 e0 40             	and    $0x40,%eax
c0101498:	85 c0                	test   %eax,%eax
c010149a:	75 08                	jne    c01014a4 <kbd_proc_data+0x7c>
c010149c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a0:	24 7f                	and    $0x7f,%al
c01014a2:	eb 04                	jmp    c01014a8 <kbd_proc_data+0x80>
c01014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a8:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014ab:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014af:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014b6:	0c 40                	or     $0x40,%al
c01014b8:	0f b6 c0             	movzbl %al,%eax
c01014bb:	f7 d0                	not    %eax
c01014bd:	89 c2                	mov    %eax,%edx
c01014bf:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014c4:	21 d0                	and    %edx,%eax
c01014c6:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014cb:	b8 00 00 00 00       	mov    $0x0,%eax
c01014d0:	e9 d6 00 00 00       	jmp    c01015ab <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c01014d5:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014da:	83 e0 40             	and    $0x40,%eax
c01014dd:	85 c0                	test   %eax,%eax
c01014df:	74 11                	je     c01014f2 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014e1:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014e5:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014ea:	83 e0 bf             	and    $0xffffffbf,%eax
c01014ed:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014f2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f6:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014fd:	0f b6 d0             	movzbl %al,%edx
c0101500:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101505:	09 d0                	or     %edx,%eax
c0101507:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010150c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101510:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101517:	0f b6 d0             	movzbl %al,%edx
c010151a:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010151f:	31 d0                	xor    %edx,%eax
c0101521:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101526:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152b:	83 e0 03             	and    $0x3,%eax
c010152e:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101539:	01 d0                	add    %edx,%eax
c010153b:	0f b6 00             	movzbl (%eax),%eax
c010153e:	0f b6 c0             	movzbl %al,%eax
c0101541:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101544:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101549:	83 e0 08             	and    $0x8,%eax
c010154c:	85 c0                	test   %eax,%eax
c010154e:	74 22                	je     c0101572 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101550:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101554:	7e 0c                	jle    c0101562 <kbd_proc_data+0x13a>
c0101556:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010155a:	7f 06                	jg     c0101562 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c010155c:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101560:	eb 10                	jmp    c0101572 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101562:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101566:	7e 0a                	jle    c0101572 <kbd_proc_data+0x14a>
c0101568:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010156c:	7f 04                	jg     c0101572 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010156e:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101572:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101577:	f7 d0                	not    %eax
c0101579:	83 e0 06             	and    $0x6,%eax
c010157c:	85 c0                	test   %eax,%eax
c010157e:	75 28                	jne    c01015a8 <kbd_proc_data+0x180>
c0101580:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101587:	75 1f                	jne    c01015a8 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101589:	c7 04 24 ad 61 10 c0 	movl   $0xc01061ad,(%esp)
c0101590:	e8 fd ec ff ff       	call   c0100292 <cprintf>
c0101595:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010159b:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010159f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015a3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015a7:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ab:	c9                   	leave  
c01015ac:	c3                   	ret    

c01015ad <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015ad:	55                   	push   %ebp
c01015ae:	89 e5                	mov    %esp,%ebp
c01015b0:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015b3:	c7 04 24 28 14 10 c0 	movl   $0xc0101428,(%esp)
c01015ba:	e8 a9 fd ff ff       	call   c0101368 <cons_intr>
}
c01015bf:	90                   	nop
c01015c0:	c9                   	leave  
c01015c1:	c3                   	ret    

c01015c2 <kbd_init>:

static void
kbd_init(void) {
c01015c2:	55                   	push   %ebp
c01015c3:	89 e5                	mov    %esp,%ebp
c01015c5:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015c8:	e8 e0 ff ff ff       	call   c01015ad <kbd_intr>
    pic_enable(IRQ_KBD);
c01015cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015d4:	e8 34 01 00 00       	call   c010170d <pic_enable>
}
c01015d9:	90                   	nop
c01015da:	c9                   	leave  
c01015db:	c3                   	ret    

c01015dc <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015dc:	55                   	push   %ebp
c01015dd:	89 e5                	mov    %esp,%ebp
c01015df:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015e2:	e8 90 f8 ff ff       	call   c0100e77 <cga_init>
    serial_init();
c01015e7:	e8 6d f9 ff ff       	call   c0100f59 <serial_init>
    kbd_init();
c01015ec:	e8 d1 ff ff ff       	call   c01015c2 <kbd_init>
    if (!serial_exists) {
c01015f1:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01015f6:	85 c0                	test   %eax,%eax
c01015f8:	75 0c                	jne    c0101606 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015fa:	c7 04 24 b9 61 10 c0 	movl   $0xc01061b9,(%esp)
c0101601:	e8 8c ec ff ff       	call   c0100292 <cprintf>
    }
}
c0101606:	90                   	nop
c0101607:	c9                   	leave  
c0101608:	c3                   	ret    

c0101609 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101609:	55                   	push   %ebp
c010160a:	89 e5                	mov    %esp,%ebp
c010160c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010160f:	e8 de f7 ff ff       	call   c0100df2 <__intr_save>
c0101614:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101617:	8b 45 08             	mov    0x8(%ebp),%eax
c010161a:	89 04 24             	mov    %eax,(%esp)
c010161d:	e8 8d fa ff ff       	call   c01010af <lpt_putc>
        cga_putc(c);
c0101622:	8b 45 08             	mov    0x8(%ebp),%eax
c0101625:	89 04 24             	mov    %eax,(%esp)
c0101628:	e8 c2 fa ff ff       	call   c01010ef <cga_putc>
        serial_putc(c);
c010162d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101630:	89 04 24             	mov    %eax,(%esp)
c0101633:	e8 f0 fc ff ff       	call   c0101328 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101638:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 d9 f7 ff ff       	call   c0100e1c <__intr_restore>
}
c0101643:	90                   	nop
c0101644:	c9                   	leave  
c0101645:	c3                   	ret    

c0101646 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101646:	55                   	push   %ebp
c0101647:	89 e5                	mov    %esp,%ebp
c0101649:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010164c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101653:	e8 9a f7 ff ff       	call   c0100df2 <__intr_save>
c0101658:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010165b:	e8 aa fd ff ff       	call   c010140a <serial_intr>
        kbd_intr();
c0101660:	e8 48 ff ff ff       	call   c01015ad <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101665:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c010166b:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101670:	39 c2                	cmp    %eax,%edx
c0101672:	74 31                	je     c01016a5 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101674:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101679:	8d 50 01             	lea    0x1(%eax),%edx
c010167c:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101682:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101689:	0f b6 c0             	movzbl %al,%eax
c010168c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010168f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101694:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101699:	75 0a                	jne    c01016a5 <cons_getc+0x5f>
                cons.rpos = 0;
c010169b:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016a2:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016a8:	89 04 24             	mov    %eax,(%esp)
c01016ab:	e8 6c f7 ff ff       	call   c0100e1c <__intr_restore>
    return c;
c01016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016b3:	c9                   	leave  
c01016b4:	c3                   	ret    

c01016b5 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016b5:	55                   	push   %ebp
c01016b6:	89 e5                	mov    %esp,%ebp
c01016b8:	83 ec 14             	sub    $0x14,%esp
c01016bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01016be:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016c5:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016cb:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016d0:	85 c0                	test   %eax,%eax
c01016d2:	74 36                	je     c010170a <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c01016d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016d7:	0f b6 c0             	movzbl %al,%eax
c01016da:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016e0:	88 45 fa             	mov    %al,-0x6(%ebp)
c01016e3:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01016e7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016eb:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f0:	c1 e8 08             	shr    $0x8,%eax
c01016f3:	0f b7 c0             	movzwl %ax,%eax
c01016f6:	0f b6 c0             	movzbl %al,%eax
c01016f9:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01016ff:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101702:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101706:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101709:	ee                   	out    %al,(%dx)
    }
}
c010170a:	90                   	nop
c010170b:	c9                   	leave  
c010170c:	c3                   	ret    

c010170d <pic_enable>:

void
pic_enable(unsigned int irq) {
c010170d:	55                   	push   %ebp
c010170e:	89 e5                	mov    %esp,%ebp
c0101710:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101713:	8b 45 08             	mov    0x8(%ebp),%eax
c0101716:	ba 01 00 00 00       	mov    $0x1,%edx
c010171b:	88 c1                	mov    %al,%cl
c010171d:	d3 e2                	shl    %cl,%edx
c010171f:	89 d0                	mov    %edx,%eax
c0101721:	98                   	cwtl   
c0101722:	f7 d0                	not    %eax
c0101724:	0f bf d0             	movswl %ax,%edx
c0101727:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010172e:	98                   	cwtl   
c010172f:	21 d0                	and    %edx,%eax
c0101731:	98                   	cwtl   
c0101732:	0f b7 c0             	movzwl %ax,%eax
c0101735:	89 04 24             	mov    %eax,(%esp)
c0101738:	e8 78 ff ff ff       	call   c01016b5 <pic_setmask>
}
c010173d:	90                   	nop
c010173e:	c9                   	leave  
c010173f:	c3                   	ret    

c0101740 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101740:	55                   	push   %ebp
c0101741:	89 e5                	mov    %esp,%ebp
c0101743:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101746:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010174d:	00 00 00 
c0101750:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101756:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010175a:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c010175e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101762:	ee                   	out    %al,(%dx)
c0101763:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101769:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c010176d:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101771:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101774:	ee                   	out    %al,(%dx)
c0101775:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c010177b:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c010177f:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
c0101788:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c010178e:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101792:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101796:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101799:	ee                   	out    %al,(%dx)
c010179a:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c01017a0:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017a4:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017a8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017ac:	ee                   	out    %al,(%dx)
c01017ad:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017b3:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017b7:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017be:	ee                   	out    %al,(%dx)
c01017bf:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017c5:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017c9:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017d1:	ee                   	out    %al,(%dx)
c01017d2:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017d8:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017dc:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01017e3:	ee                   	out    %al,(%dx)
c01017e4:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01017ea:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01017ee:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017f2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017f6:	ee                   	out    %al,(%dx)
c01017f7:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c01017fd:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101801:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101805:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101808:	ee                   	out    %al,(%dx)
c0101809:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c010180f:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0101813:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101817:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010181b:	ee                   	out    %al,(%dx)
c010181c:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0101822:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c0101826:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010182a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010182d:	ee                   	out    %al,(%dx)
c010182e:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101834:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101838:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c010183c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101840:	ee                   	out    %al,(%dx)
c0101841:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101847:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c010184b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c010184f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101852:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101853:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010185a:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010185f:	74 0f                	je     c0101870 <pic_init+0x130>
        pic_setmask(irq_mask);
c0101861:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101868:	89 04 24             	mov    %eax,(%esp)
c010186b:	e8 45 fe ff ff       	call   c01016b5 <pic_setmask>
    }
}
c0101870:	90                   	nop
c0101871:	c9                   	leave  
c0101872:	c3                   	ret    

c0101873 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101873:	55                   	push   %ebp
c0101874:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101876:	fb                   	sti    
    sti();
}
c0101877:	90                   	nop
c0101878:	5d                   	pop    %ebp
c0101879:	c3                   	ret    

c010187a <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010187a:	55                   	push   %ebp
c010187b:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010187d:	fa                   	cli    
    cli();
}
c010187e:	90                   	nop
c010187f:	5d                   	pop    %ebp
c0101880:	c3                   	ret    

c0101881 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101881:	55                   	push   %ebp
c0101882:	89 e5                	mov    %esp,%ebp
c0101884:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101887:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010188e:	00 
c010188f:	c7 04 24 e0 61 10 c0 	movl   $0xc01061e0,(%esp)
c0101896:	e8 f7 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010189b:	90                   	nop
c010189c:	c9                   	leave  
c010189d:	c3                   	ret    

c010189e <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010189e:	55                   	push   %ebp
c010189f:	89 e5                	mov    %esp,%ebp
c01018a1:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
c01018a4:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
      for(int i=0;i<length;i++)
c01018ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b2:	e9 c4 00 00 00       	jmp    c010197b <idt_init+0xdd>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ba:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c1:	0f b7 d0             	movzwl %ax,%edx
c01018c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c7:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018ce:	c0 
c01018cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d2:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018d9:	c0 08 00 
c01018dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018df:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018e6:	c0 
c01018e7:	80 e2 e0             	and    $0xe0,%dl
c01018ea:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f4:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018fb:	c0 
c01018fc:	80 e2 1f             	and    $0x1f,%dl
c01018ff:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101906:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101909:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101910:	c0 
c0101911:	80 e2 f0             	and    $0xf0,%dl
c0101914:	80 ca 0e             	or     $0xe,%dl
c0101917:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010191e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101921:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101928:	c0 
c0101929:	80 e2 ef             	and    $0xef,%dl
c010192c:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101933:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101936:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010193d:	c0 
c010193e:	80 e2 9f             	and    $0x9f,%dl
c0101941:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101948:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194b:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101952:	c0 
c0101953:	80 ca 80             	or     $0x80,%dl
c0101956:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010195d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101960:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101967:	c1 e8 10             	shr    $0x10,%eax
c010196a:	0f b7 d0             	movzwl %ax,%edx
c010196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101970:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c0101977:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
      for(int i=0;i<length;i++)
c0101978:	ff 45 fc             	incl   -0x4(%ebp)
c010197b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101981:	0f 8c 30 ff ff ff    	jl     c01018b7 <idt_init+0x19>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
      SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101987:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c010198c:	0f b7 c0             	movzwl %ax,%eax
c010198f:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c0101995:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c010199c:	08 00 
c010199e:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019a5:	24 e0                	and    $0xe0,%al
c01019a7:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019ac:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019b3:	24 1f                	and    $0x1f,%al
c01019b5:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019ba:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019c1:	24 f0                	and    $0xf0,%al
c01019c3:	0c 0e                	or     $0xe,%al
c01019c5:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019ca:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019d1:	24 ef                	and    $0xef,%al
c01019d3:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019d8:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019df:	0c 60                	or     $0x60,%al
c01019e1:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019e6:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019ed:	0c 80                	or     $0x80,%al
c01019ef:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019f4:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019f9:	c1 e8 10             	shr    $0x10,%eax
c01019fc:	0f b7 c0             	movzwl %ax,%eax
c01019ff:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a05:	c7 45 f4 60 75 11 c0 	movl   $0xc0117560,-0xc(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a0f:	0f 01 18             	lidtl  (%eax)
      lidt(&idt_pd);

}
c0101a12:	90                   	nop
c0101a13:	c9                   	leave  
c0101a14:	c3                   	ret    

c0101a15 <trapname>:

static const char *
trapname(int trapno) {
c0101a15:	55                   	push   %ebp
c0101a16:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a18:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1b:	83 f8 13             	cmp    $0x13,%eax
c0101a1e:	77 0c                	ja     c0101a2c <trapname+0x17>
        return excnames[trapno];
c0101a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a23:	8b 04 85 40 65 10 c0 	mov    -0x3fef9ac0(,%eax,4),%eax
c0101a2a:	eb 18                	jmp    c0101a44 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a2c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a30:	7e 0d                	jle    c0101a3f <trapname+0x2a>
c0101a32:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a36:	7f 07                	jg     c0101a3f <trapname+0x2a>
        return "Hardware Interrupt";
c0101a38:	b8 ea 61 10 c0       	mov    $0xc01061ea,%eax
c0101a3d:	eb 05                	jmp    c0101a44 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a3f:	b8 fd 61 10 c0       	mov    $0xc01061fd,%eax
}
c0101a44:	5d                   	pop    %ebp
c0101a45:	c3                   	ret    

c0101a46 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a46:	55                   	push   %ebp
c0101a47:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a50:	83 f8 08             	cmp    $0x8,%eax
c0101a53:	0f 94 c0             	sete   %al
c0101a56:	0f b6 c0             	movzbl %al,%eax
}
c0101a59:	5d                   	pop    %ebp
c0101a5a:	c3                   	ret    

c0101a5b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a5b:	55                   	push   %ebp
c0101a5c:	89 e5                	mov    %esp,%ebp
c0101a5e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a68:	c7 04 24 3e 62 10 c0 	movl   $0xc010623e,(%esp)
c0101a6f:	e8 1e e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a77:	89 04 24             	mov    %eax,(%esp)
c0101a7a:	e8 91 01 00 00       	call   c0101c10 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a82:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a8a:	c7 04 24 4f 62 10 c0 	movl   $0xc010624f,(%esp)
c0101a91:	e8 fc e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a99:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa1:	c7 04 24 62 62 10 c0 	movl   $0xc0106262,(%esp)
c0101aa8:	e8 e5 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab0:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab8:	c7 04 24 75 62 10 c0 	movl   $0xc0106275,(%esp)
c0101abf:	e8 ce e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac7:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acf:	c7 04 24 88 62 10 c0 	movl   $0xc0106288,(%esp)
c0101ad6:	e8 b7 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ade:	8b 40 30             	mov    0x30(%eax),%eax
c0101ae1:	89 04 24             	mov    %eax,(%esp)
c0101ae4:	e8 2c ff ff ff       	call   c0101a15 <trapname>
c0101ae9:	89 c2                	mov    %eax,%edx
c0101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aee:	8b 40 30             	mov    0x30(%eax),%eax
c0101af1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101af5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af9:	c7 04 24 9b 62 10 c0 	movl   $0xc010629b,(%esp)
c0101b00:	e8 8d e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b08:	8b 40 34             	mov    0x34(%eax),%eax
c0101b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0f:	c7 04 24 ad 62 10 c0 	movl   $0xc01062ad,(%esp)
c0101b16:	e8 77 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1e:	8b 40 38             	mov    0x38(%eax),%eax
c0101b21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b25:	c7 04 24 bc 62 10 c0 	movl   $0xc01062bc,(%esp)
c0101b2c:	e8 61 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b34:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3c:	c7 04 24 cb 62 10 c0 	movl   $0xc01062cb,(%esp)
c0101b43:	e8 4a e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4b:	8b 40 40             	mov    0x40(%eax),%eax
c0101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b52:	c7 04 24 de 62 10 c0 	movl   $0xc01062de,(%esp)
c0101b59:	e8 34 e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b65:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b6c:	eb 3d                	jmp    c0101bab <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b71:	8b 50 40             	mov    0x40(%eax),%edx
c0101b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b77:	21 d0                	and    %edx,%eax
c0101b79:	85 c0                	test   %eax,%eax
c0101b7b:	74 28                	je     c0101ba5 <print_trapframe+0x14a>
c0101b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b80:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b87:	85 c0                	test   %eax,%eax
c0101b89:	74 1a                	je     c0101ba5 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b8e:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b99:	c7 04 24 ed 62 10 c0 	movl   $0xc01062ed,(%esp)
c0101ba0:	e8 ed e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ba5:	ff 45 f4             	incl   -0xc(%ebp)
c0101ba8:	d1 65 f0             	shll   -0x10(%ebp)
c0101bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bae:	83 f8 17             	cmp    $0x17,%eax
c0101bb1:	76 bb                	jbe    c0101b6e <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb6:	8b 40 40             	mov    0x40(%eax),%eax
c0101bb9:	25 00 30 00 00       	and    $0x3000,%eax
c0101bbe:	c1 e8 0c             	shr    $0xc,%eax
c0101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc5:	c7 04 24 f1 62 10 c0 	movl   $0xc01062f1,(%esp)
c0101bcc:	e8 c1 e6 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd4:	89 04 24             	mov    %eax,(%esp)
c0101bd7:	e8 6a fe ff ff       	call   c0101a46 <trap_in_kernel>
c0101bdc:	85 c0                	test   %eax,%eax
c0101bde:	75 2d                	jne    c0101c0d <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be3:	8b 40 44             	mov    0x44(%eax),%eax
c0101be6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bea:	c7 04 24 fa 62 10 c0 	movl   $0xc01062fa,(%esp)
c0101bf1:	e8 9c e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf9:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c01:	c7 04 24 09 63 10 c0 	movl   $0xc0106309,(%esp)
c0101c08:	e8 85 e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101c0d:	90                   	nop
c0101c0e:	c9                   	leave  
c0101c0f:	c3                   	ret    

c0101c10 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c10:	55                   	push   %ebp
c0101c11:	89 e5                	mov    %esp,%ebp
c0101c13:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c19:	8b 00                	mov    (%eax),%eax
c0101c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1f:	c7 04 24 1c 63 10 c0 	movl   $0xc010631c,(%esp)
c0101c26:	e8 67 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2e:	8b 40 04             	mov    0x4(%eax),%eax
c0101c31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c35:	c7 04 24 2b 63 10 c0 	movl   $0xc010632b,(%esp)
c0101c3c:	e8 51 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c44:	8b 40 08             	mov    0x8(%eax),%eax
c0101c47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4b:	c7 04 24 3a 63 10 c0 	movl   $0xc010633a,(%esp)
c0101c52:	e8 3b e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5a:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c61:	c7 04 24 49 63 10 c0 	movl   $0xc0106349,(%esp)
c0101c68:	e8 25 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c70:	8b 40 10             	mov    0x10(%eax),%eax
c0101c73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c77:	c7 04 24 58 63 10 c0 	movl   $0xc0106358,(%esp)
c0101c7e:	e8 0f e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c86:	8b 40 14             	mov    0x14(%eax),%eax
c0101c89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c8d:	c7 04 24 67 63 10 c0 	movl   $0xc0106367,(%esp)
c0101c94:	e8 f9 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9c:	8b 40 18             	mov    0x18(%eax),%eax
c0101c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca3:	c7 04 24 76 63 10 c0 	movl   $0xc0106376,(%esp)
c0101caa:	e8 e3 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb2:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb9:	c7 04 24 85 63 10 c0 	movl   $0xc0106385,(%esp)
c0101cc0:	e8 cd e5 ff ff       	call   c0100292 <cprintf>
}
c0101cc5:	90                   	nop
c0101cc6:	c9                   	leave  
c0101cc7:	c3                   	ret    

c0101cc8 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cc8:	55                   	push   %ebp
c0101cc9:	89 e5                	mov    %esp,%ebp
c0101ccb:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd1:	8b 40 30             	mov    0x30(%eax),%eax
c0101cd4:	83 f8 2f             	cmp    $0x2f,%eax
c0101cd7:	77 21                	ja     c0101cfa <trap_dispatch+0x32>
c0101cd9:	83 f8 2e             	cmp    $0x2e,%eax
c0101cdc:	0f 83 0c 01 00 00    	jae    c0101dee <trap_dispatch+0x126>
c0101ce2:	83 f8 21             	cmp    $0x21,%eax
c0101ce5:	0f 84 8c 00 00 00    	je     c0101d77 <trap_dispatch+0xaf>
c0101ceb:	83 f8 24             	cmp    $0x24,%eax
c0101cee:	74 61                	je     c0101d51 <trap_dispatch+0x89>
c0101cf0:	83 f8 20             	cmp    $0x20,%eax
c0101cf3:	74 16                	je     c0101d0b <trap_dispatch+0x43>
c0101cf5:	e9 bf 00 00 00       	jmp    c0101db9 <trap_dispatch+0xf1>
c0101cfa:	83 e8 78             	sub    $0x78,%eax
c0101cfd:	83 f8 01             	cmp    $0x1,%eax
c0101d00:	0f 87 b3 00 00 00    	ja     c0101db9 <trap_dispatch+0xf1>
c0101d06:	e9 92 00 00 00       	jmp    c0101d9d <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d0b:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d10:	40                   	inc    %eax
c0101d11:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if(ticks % TICK_NUM==0)  print_ticks();
c0101d16:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d1c:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d21:	89 c8                	mov    %ecx,%eax
c0101d23:	f7 e2                	mul    %edx
c0101d25:	c1 ea 05             	shr    $0x5,%edx
c0101d28:	89 d0                	mov    %edx,%eax
c0101d2a:	c1 e0 02             	shl    $0x2,%eax
c0101d2d:	01 d0                	add    %edx,%eax
c0101d2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d36:	01 d0                	add    %edx,%eax
c0101d38:	c1 e0 02             	shl    $0x2,%eax
c0101d3b:	29 c1                	sub    %eax,%ecx
c0101d3d:	89 ca                	mov    %ecx,%edx
c0101d3f:	85 d2                	test   %edx,%edx
c0101d41:	0f 85 aa 00 00 00    	jne    c0101df1 <trap_dispatch+0x129>
c0101d47:	e8 35 fb ff ff       	call   c0101881 <print_ticks>
        break;
c0101d4c:	e9 a0 00 00 00       	jmp    c0101df1 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d51:	e8 f0 f8 ff ff       	call   c0101646 <cons_getc>
c0101d56:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d59:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d5d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d61:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d69:	c7 04 24 94 63 10 c0 	movl   $0xc0106394,(%esp)
c0101d70:	e8 1d e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d75:	eb 7b                	jmp    c0101df2 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d77:	e8 ca f8 ff ff       	call   c0101646 <cons_getc>
c0101d7c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d7f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d83:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d87:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d8f:	c7 04 24 a6 63 10 c0 	movl   $0xc01063a6,(%esp)
c0101d96:	e8 f7 e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101d9b:	eb 55                	jmp    c0101df2 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d9d:	c7 44 24 08 b5 63 10 	movl   $0xc01063b5,0x8(%esp)
c0101da4:	c0 
c0101da5:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0101dac:	00 
c0101dad:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
c0101db4:	e8 30 e6 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101db9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dbc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dc0:	83 e0 03             	and    $0x3,%eax
c0101dc3:	85 c0                	test   %eax,%eax
c0101dc5:	75 2b                	jne    c0101df2 <trap_dispatch+0x12a>
            print_trapframe(tf);
c0101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dca:	89 04 24             	mov    %eax,(%esp)
c0101dcd:	e8 89 fc ff ff       	call   c0101a5b <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101dd2:	c7 44 24 08 d6 63 10 	movl   $0xc01063d6,0x8(%esp)
c0101dd9:	c0 
c0101dda:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0101de1:	00 
c0101de2:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
c0101de9:	e8 fb e5 ff ff       	call   c01003e9 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101dee:	90                   	nop
c0101def:	eb 01                	jmp    c0101df2 <trap_dispatch+0x12a>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
        if(ticks % TICK_NUM==0)  print_ticks();
        break;
c0101df1:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101df2:	90                   	nop
c0101df3:	c9                   	leave  
c0101df4:	c3                   	ret    

c0101df5 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101df5:	55                   	push   %ebp
c0101df6:	89 e5                	mov    %esp,%ebp
c0101df8:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dfe:	89 04 24             	mov    %eax,(%esp)
c0101e01:	e8 c2 fe ff ff       	call   c0101cc8 <trap_dispatch>
}
c0101e06:	90                   	nop
c0101e07:	c9                   	leave  
c0101e08:	c3                   	ret    

c0101e09 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e09:	6a 00                	push   $0x0
  pushl $0
c0101e0b:	6a 00                	push   $0x0
  jmp __alltraps
c0101e0d:	e9 69 0a 00 00       	jmp    c010287b <__alltraps>

c0101e12 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e12:	6a 00                	push   $0x0
  pushl $1
c0101e14:	6a 01                	push   $0x1
  jmp __alltraps
c0101e16:	e9 60 0a 00 00       	jmp    c010287b <__alltraps>

c0101e1b <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e1b:	6a 00                	push   $0x0
  pushl $2
c0101e1d:	6a 02                	push   $0x2
  jmp __alltraps
c0101e1f:	e9 57 0a 00 00       	jmp    c010287b <__alltraps>

c0101e24 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e24:	6a 00                	push   $0x0
  pushl $3
c0101e26:	6a 03                	push   $0x3
  jmp __alltraps
c0101e28:	e9 4e 0a 00 00       	jmp    c010287b <__alltraps>

c0101e2d <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e2d:	6a 00                	push   $0x0
  pushl $4
c0101e2f:	6a 04                	push   $0x4
  jmp __alltraps
c0101e31:	e9 45 0a 00 00       	jmp    c010287b <__alltraps>

c0101e36 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e36:	6a 00                	push   $0x0
  pushl $5
c0101e38:	6a 05                	push   $0x5
  jmp __alltraps
c0101e3a:	e9 3c 0a 00 00       	jmp    c010287b <__alltraps>

c0101e3f <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e3f:	6a 00                	push   $0x0
  pushl $6
c0101e41:	6a 06                	push   $0x6
  jmp __alltraps
c0101e43:	e9 33 0a 00 00       	jmp    c010287b <__alltraps>

c0101e48 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e48:	6a 00                	push   $0x0
  pushl $7
c0101e4a:	6a 07                	push   $0x7
  jmp __alltraps
c0101e4c:	e9 2a 0a 00 00       	jmp    c010287b <__alltraps>

c0101e51 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e51:	6a 08                	push   $0x8
  jmp __alltraps
c0101e53:	e9 23 0a 00 00       	jmp    c010287b <__alltraps>

c0101e58 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e58:	6a 00                	push   $0x0
  pushl $9
c0101e5a:	6a 09                	push   $0x9
  jmp __alltraps
c0101e5c:	e9 1a 0a 00 00       	jmp    c010287b <__alltraps>

c0101e61 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e61:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e63:	e9 13 0a 00 00       	jmp    c010287b <__alltraps>

c0101e68 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e68:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e6a:	e9 0c 0a 00 00       	jmp    c010287b <__alltraps>

c0101e6f <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e6f:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e71:	e9 05 0a 00 00       	jmp    c010287b <__alltraps>

c0101e76 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e76:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e78:	e9 fe 09 00 00       	jmp    c010287b <__alltraps>

c0101e7d <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e7d:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e7f:	e9 f7 09 00 00       	jmp    c010287b <__alltraps>

c0101e84 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e84:	6a 00                	push   $0x0
  pushl $15
c0101e86:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e88:	e9 ee 09 00 00       	jmp    c010287b <__alltraps>

c0101e8d <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e8d:	6a 00                	push   $0x0
  pushl $16
c0101e8f:	6a 10                	push   $0x10
  jmp __alltraps
c0101e91:	e9 e5 09 00 00       	jmp    c010287b <__alltraps>

c0101e96 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e96:	6a 11                	push   $0x11
  jmp __alltraps
c0101e98:	e9 de 09 00 00       	jmp    c010287b <__alltraps>

c0101e9d <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e9d:	6a 00                	push   $0x0
  pushl $18
c0101e9f:	6a 12                	push   $0x12
  jmp __alltraps
c0101ea1:	e9 d5 09 00 00       	jmp    c010287b <__alltraps>

c0101ea6 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ea6:	6a 00                	push   $0x0
  pushl $19
c0101ea8:	6a 13                	push   $0x13
  jmp __alltraps
c0101eaa:	e9 cc 09 00 00       	jmp    c010287b <__alltraps>

c0101eaf <vector20>:
.globl vector20
vector20:
  pushl $0
c0101eaf:	6a 00                	push   $0x0
  pushl $20
c0101eb1:	6a 14                	push   $0x14
  jmp __alltraps
c0101eb3:	e9 c3 09 00 00       	jmp    c010287b <__alltraps>

c0101eb8 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101eb8:	6a 00                	push   $0x0
  pushl $21
c0101eba:	6a 15                	push   $0x15
  jmp __alltraps
c0101ebc:	e9 ba 09 00 00       	jmp    c010287b <__alltraps>

c0101ec1 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101ec1:	6a 00                	push   $0x0
  pushl $22
c0101ec3:	6a 16                	push   $0x16
  jmp __alltraps
c0101ec5:	e9 b1 09 00 00       	jmp    c010287b <__alltraps>

c0101eca <vector23>:
.globl vector23
vector23:
  pushl $0
c0101eca:	6a 00                	push   $0x0
  pushl $23
c0101ecc:	6a 17                	push   $0x17
  jmp __alltraps
c0101ece:	e9 a8 09 00 00       	jmp    c010287b <__alltraps>

c0101ed3 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101ed3:	6a 00                	push   $0x0
  pushl $24
c0101ed5:	6a 18                	push   $0x18
  jmp __alltraps
c0101ed7:	e9 9f 09 00 00       	jmp    c010287b <__alltraps>

c0101edc <vector25>:
.globl vector25
vector25:
  pushl $0
c0101edc:	6a 00                	push   $0x0
  pushl $25
c0101ede:	6a 19                	push   $0x19
  jmp __alltraps
c0101ee0:	e9 96 09 00 00       	jmp    c010287b <__alltraps>

c0101ee5 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101ee5:	6a 00                	push   $0x0
  pushl $26
c0101ee7:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101ee9:	e9 8d 09 00 00       	jmp    c010287b <__alltraps>

c0101eee <vector27>:
.globl vector27
vector27:
  pushl $0
c0101eee:	6a 00                	push   $0x0
  pushl $27
c0101ef0:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ef2:	e9 84 09 00 00       	jmp    c010287b <__alltraps>

c0101ef7 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101ef7:	6a 00                	push   $0x0
  pushl $28
c0101ef9:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101efb:	e9 7b 09 00 00       	jmp    c010287b <__alltraps>

c0101f00 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f00:	6a 00                	push   $0x0
  pushl $29
c0101f02:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f04:	e9 72 09 00 00       	jmp    c010287b <__alltraps>

c0101f09 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f09:	6a 00                	push   $0x0
  pushl $30
c0101f0b:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f0d:	e9 69 09 00 00       	jmp    c010287b <__alltraps>

c0101f12 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f12:	6a 00                	push   $0x0
  pushl $31
c0101f14:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f16:	e9 60 09 00 00       	jmp    c010287b <__alltraps>

c0101f1b <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f1b:	6a 00                	push   $0x0
  pushl $32
c0101f1d:	6a 20                	push   $0x20
  jmp __alltraps
c0101f1f:	e9 57 09 00 00       	jmp    c010287b <__alltraps>

c0101f24 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f24:	6a 00                	push   $0x0
  pushl $33
c0101f26:	6a 21                	push   $0x21
  jmp __alltraps
c0101f28:	e9 4e 09 00 00       	jmp    c010287b <__alltraps>

c0101f2d <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f2d:	6a 00                	push   $0x0
  pushl $34
c0101f2f:	6a 22                	push   $0x22
  jmp __alltraps
c0101f31:	e9 45 09 00 00       	jmp    c010287b <__alltraps>

c0101f36 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f36:	6a 00                	push   $0x0
  pushl $35
c0101f38:	6a 23                	push   $0x23
  jmp __alltraps
c0101f3a:	e9 3c 09 00 00       	jmp    c010287b <__alltraps>

c0101f3f <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f3f:	6a 00                	push   $0x0
  pushl $36
c0101f41:	6a 24                	push   $0x24
  jmp __alltraps
c0101f43:	e9 33 09 00 00       	jmp    c010287b <__alltraps>

c0101f48 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f48:	6a 00                	push   $0x0
  pushl $37
c0101f4a:	6a 25                	push   $0x25
  jmp __alltraps
c0101f4c:	e9 2a 09 00 00       	jmp    c010287b <__alltraps>

c0101f51 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f51:	6a 00                	push   $0x0
  pushl $38
c0101f53:	6a 26                	push   $0x26
  jmp __alltraps
c0101f55:	e9 21 09 00 00       	jmp    c010287b <__alltraps>

c0101f5a <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f5a:	6a 00                	push   $0x0
  pushl $39
c0101f5c:	6a 27                	push   $0x27
  jmp __alltraps
c0101f5e:	e9 18 09 00 00       	jmp    c010287b <__alltraps>

c0101f63 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f63:	6a 00                	push   $0x0
  pushl $40
c0101f65:	6a 28                	push   $0x28
  jmp __alltraps
c0101f67:	e9 0f 09 00 00       	jmp    c010287b <__alltraps>

c0101f6c <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f6c:	6a 00                	push   $0x0
  pushl $41
c0101f6e:	6a 29                	push   $0x29
  jmp __alltraps
c0101f70:	e9 06 09 00 00       	jmp    c010287b <__alltraps>

c0101f75 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f75:	6a 00                	push   $0x0
  pushl $42
c0101f77:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f79:	e9 fd 08 00 00       	jmp    c010287b <__alltraps>

c0101f7e <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f7e:	6a 00                	push   $0x0
  pushl $43
c0101f80:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f82:	e9 f4 08 00 00       	jmp    c010287b <__alltraps>

c0101f87 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $44
c0101f89:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f8b:	e9 eb 08 00 00       	jmp    c010287b <__alltraps>

c0101f90 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $45
c0101f92:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f94:	e9 e2 08 00 00       	jmp    c010287b <__alltraps>

c0101f99 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $46
c0101f9b:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f9d:	e9 d9 08 00 00       	jmp    c010287b <__alltraps>

c0101fa2 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $47
c0101fa4:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fa6:	e9 d0 08 00 00       	jmp    c010287b <__alltraps>

c0101fab <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $48
c0101fad:	6a 30                	push   $0x30
  jmp __alltraps
c0101faf:	e9 c7 08 00 00       	jmp    c010287b <__alltraps>

c0101fb4 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $49
c0101fb6:	6a 31                	push   $0x31
  jmp __alltraps
c0101fb8:	e9 be 08 00 00       	jmp    c010287b <__alltraps>

c0101fbd <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $50
c0101fbf:	6a 32                	push   $0x32
  jmp __alltraps
c0101fc1:	e9 b5 08 00 00       	jmp    c010287b <__alltraps>

c0101fc6 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $51
c0101fc8:	6a 33                	push   $0x33
  jmp __alltraps
c0101fca:	e9 ac 08 00 00       	jmp    c010287b <__alltraps>

c0101fcf <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $52
c0101fd1:	6a 34                	push   $0x34
  jmp __alltraps
c0101fd3:	e9 a3 08 00 00       	jmp    c010287b <__alltraps>

c0101fd8 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $53
c0101fda:	6a 35                	push   $0x35
  jmp __alltraps
c0101fdc:	e9 9a 08 00 00       	jmp    c010287b <__alltraps>

c0101fe1 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $54
c0101fe3:	6a 36                	push   $0x36
  jmp __alltraps
c0101fe5:	e9 91 08 00 00       	jmp    c010287b <__alltraps>

c0101fea <vector55>:
.globl vector55
vector55:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $55
c0101fec:	6a 37                	push   $0x37
  jmp __alltraps
c0101fee:	e9 88 08 00 00       	jmp    c010287b <__alltraps>

c0101ff3 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $56
c0101ff5:	6a 38                	push   $0x38
  jmp __alltraps
c0101ff7:	e9 7f 08 00 00       	jmp    c010287b <__alltraps>

c0101ffc <vector57>:
.globl vector57
vector57:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $57
c0101ffe:	6a 39                	push   $0x39
  jmp __alltraps
c0102000:	e9 76 08 00 00       	jmp    c010287b <__alltraps>

c0102005 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $58
c0102007:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102009:	e9 6d 08 00 00       	jmp    c010287b <__alltraps>

c010200e <vector59>:
.globl vector59
vector59:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $59
c0102010:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102012:	e9 64 08 00 00       	jmp    c010287b <__alltraps>

c0102017 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $60
c0102019:	6a 3c                	push   $0x3c
  jmp __alltraps
c010201b:	e9 5b 08 00 00       	jmp    c010287b <__alltraps>

c0102020 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $61
c0102022:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102024:	e9 52 08 00 00       	jmp    c010287b <__alltraps>

c0102029 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $62
c010202b:	6a 3e                	push   $0x3e
  jmp __alltraps
c010202d:	e9 49 08 00 00       	jmp    c010287b <__alltraps>

c0102032 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $63
c0102034:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102036:	e9 40 08 00 00       	jmp    c010287b <__alltraps>

c010203b <vector64>:
.globl vector64
vector64:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $64
c010203d:	6a 40                	push   $0x40
  jmp __alltraps
c010203f:	e9 37 08 00 00       	jmp    c010287b <__alltraps>

c0102044 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $65
c0102046:	6a 41                	push   $0x41
  jmp __alltraps
c0102048:	e9 2e 08 00 00       	jmp    c010287b <__alltraps>

c010204d <vector66>:
.globl vector66
vector66:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $66
c010204f:	6a 42                	push   $0x42
  jmp __alltraps
c0102051:	e9 25 08 00 00       	jmp    c010287b <__alltraps>

c0102056 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $67
c0102058:	6a 43                	push   $0x43
  jmp __alltraps
c010205a:	e9 1c 08 00 00       	jmp    c010287b <__alltraps>

c010205f <vector68>:
.globl vector68
vector68:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $68
c0102061:	6a 44                	push   $0x44
  jmp __alltraps
c0102063:	e9 13 08 00 00       	jmp    c010287b <__alltraps>

c0102068 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $69
c010206a:	6a 45                	push   $0x45
  jmp __alltraps
c010206c:	e9 0a 08 00 00       	jmp    c010287b <__alltraps>

c0102071 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $70
c0102073:	6a 46                	push   $0x46
  jmp __alltraps
c0102075:	e9 01 08 00 00       	jmp    c010287b <__alltraps>

c010207a <vector71>:
.globl vector71
vector71:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $71
c010207c:	6a 47                	push   $0x47
  jmp __alltraps
c010207e:	e9 f8 07 00 00       	jmp    c010287b <__alltraps>

c0102083 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $72
c0102085:	6a 48                	push   $0x48
  jmp __alltraps
c0102087:	e9 ef 07 00 00       	jmp    c010287b <__alltraps>

c010208c <vector73>:
.globl vector73
vector73:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $73
c010208e:	6a 49                	push   $0x49
  jmp __alltraps
c0102090:	e9 e6 07 00 00       	jmp    c010287b <__alltraps>

c0102095 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $74
c0102097:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102099:	e9 dd 07 00 00       	jmp    c010287b <__alltraps>

c010209e <vector75>:
.globl vector75
vector75:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $75
c01020a0:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020a2:	e9 d4 07 00 00       	jmp    c010287b <__alltraps>

c01020a7 <vector76>:
.globl vector76
vector76:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $76
c01020a9:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020ab:	e9 cb 07 00 00       	jmp    c010287b <__alltraps>

c01020b0 <vector77>:
.globl vector77
vector77:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $77
c01020b2:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020b4:	e9 c2 07 00 00       	jmp    c010287b <__alltraps>

c01020b9 <vector78>:
.globl vector78
vector78:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $78
c01020bb:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020bd:	e9 b9 07 00 00       	jmp    c010287b <__alltraps>

c01020c2 <vector79>:
.globl vector79
vector79:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $79
c01020c4:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020c6:	e9 b0 07 00 00       	jmp    c010287b <__alltraps>

c01020cb <vector80>:
.globl vector80
vector80:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $80
c01020cd:	6a 50                	push   $0x50
  jmp __alltraps
c01020cf:	e9 a7 07 00 00       	jmp    c010287b <__alltraps>

c01020d4 <vector81>:
.globl vector81
vector81:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $81
c01020d6:	6a 51                	push   $0x51
  jmp __alltraps
c01020d8:	e9 9e 07 00 00       	jmp    c010287b <__alltraps>

c01020dd <vector82>:
.globl vector82
vector82:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $82
c01020df:	6a 52                	push   $0x52
  jmp __alltraps
c01020e1:	e9 95 07 00 00       	jmp    c010287b <__alltraps>

c01020e6 <vector83>:
.globl vector83
vector83:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $83
c01020e8:	6a 53                	push   $0x53
  jmp __alltraps
c01020ea:	e9 8c 07 00 00       	jmp    c010287b <__alltraps>

c01020ef <vector84>:
.globl vector84
vector84:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $84
c01020f1:	6a 54                	push   $0x54
  jmp __alltraps
c01020f3:	e9 83 07 00 00       	jmp    c010287b <__alltraps>

c01020f8 <vector85>:
.globl vector85
vector85:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $85
c01020fa:	6a 55                	push   $0x55
  jmp __alltraps
c01020fc:	e9 7a 07 00 00       	jmp    c010287b <__alltraps>

c0102101 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $86
c0102103:	6a 56                	push   $0x56
  jmp __alltraps
c0102105:	e9 71 07 00 00       	jmp    c010287b <__alltraps>

c010210a <vector87>:
.globl vector87
vector87:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $87
c010210c:	6a 57                	push   $0x57
  jmp __alltraps
c010210e:	e9 68 07 00 00       	jmp    c010287b <__alltraps>

c0102113 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $88
c0102115:	6a 58                	push   $0x58
  jmp __alltraps
c0102117:	e9 5f 07 00 00       	jmp    c010287b <__alltraps>

c010211c <vector89>:
.globl vector89
vector89:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $89
c010211e:	6a 59                	push   $0x59
  jmp __alltraps
c0102120:	e9 56 07 00 00       	jmp    c010287b <__alltraps>

c0102125 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $90
c0102127:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102129:	e9 4d 07 00 00       	jmp    c010287b <__alltraps>

c010212e <vector91>:
.globl vector91
vector91:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $91
c0102130:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102132:	e9 44 07 00 00       	jmp    c010287b <__alltraps>

c0102137 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $92
c0102139:	6a 5c                	push   $0x5c
  jmp __alltraps
c010213b:	e9 3b 07 00 00       	jmp    c010287b <__alltraps>

c0102140 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $93
c0102142:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102144:	e9 32 07 00 00       	jmp    c010287b <__alltraps>

c0102149 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $94
c010214b:	6a 5e                	push   $0x5e
  jmp __alltraps
c010214d:	e9 29 07 00 00       	jmp    c010287b <__alltraps>

c0102152 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $95
c0102154:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102156:	e9 20 07 00 00       	jmp    c010287b <__alltraps>

c010215b <vector96>:
.globl vector96
vector96:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $96
c010215d:	6a 60                	push   $0x60
  jmp __alltraps
c010215f:	e9 17 07 00 00       	jmp    c010287b <__alltraps>

c0102164 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $97
c0102166:	6a 61                	push   $0x61
  jmp __alltraps
c0102168:	e9 0e 07 00 00       	jmp    c010287b <__alltraps>

c010216d <vector98>:
.globl vector98
vector98:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $98
c010216f:	6a 62                	push   $0x62
  jmp __alltraps
c0102171:	e9 05 07 00 00       	jmp    c010287b <__alltraps>

c0102176 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $99
c0102178:	6a 63                	push   $0x63
  jmp __alltraps
c010217a:	e9 fc 06 00 00       	jmp    c010287b <__alltraps>

c010217f <vector100>:
.globl vector100
vector100:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $100
c0102181:	6a 64                	push   $0x64
  jmp __alltraps
c0102183:	e9 f3 06 00 00       	jmp    c010287b <__alltraps>

c0102188 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $101
c010218a:	6a 65                	push   $0x65
  jmp __alltraps
c010218c:	e9 ea 06 00 00       	jmp    c010287b <__alltraps>

c0102191 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $102
c0102193:	6a 66                	push   $0x66
  jmp __alltraps
c0102195:	e9 e1 06 00 00       	jmp    c010287b <__alltraps>

c010219a <vector103>:
.globl vector103
vector103:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $103
c010219c:	6a 67                	push   $0x67
  jmp __alltraps
c010219e:	e9 d8 06 00 00       	jmp    c010287b <__alltraps>

c01021a3 <vector104>:
.globl vector104
vector104:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $104
c01021a5:	6a 68                	push   $0x68
  jmp __alltraps
c01021a7:	e9 cf 06 00 00       	jmp    c010287b <__alltraps>

c01021ac <vector105>:
.globl vector105
vector105:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $105
c01021ae:	6a 69                	push   $0x69
  jmp __alltraps
c01021b0:	e9 c6 06 00 00       	jmp    c010287b <__alltraps>

c01021b5 <vector106>:
.globl vector106
vector106:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $106
c01021b7:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021b9:	e9 bd 06 00 00       	jmp    c010287b <__alltraps>

c01021be <vector107>:
.globl vector107
vector107:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $107
c01021c0:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021c2:	e9 b4 06 00 00       	jmp    c010287b <__alltraps>

c01021c7 <vector108>:
.globl vector108
vector108:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $108
c01021c9:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021cb:	e9 ab 06 00 00       	jmp    c010287b <__alltraps>

c01021d0 <vector109>:
.globl vector109
vector109:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $109
c01021d2:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021d4:	e9 a2 06 00 00       	jmp    c010287b <__alltraps>

c01021d9 <vector110>:
.globl vector110
vector110:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $110
c01021db:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021dd:	e9 99 06 00 00       	jmp    c010287b <__alltraps>

c01021e2 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $111
c01021e4:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021e6:	e9 90 06 00 00       	jmp    c010287b <__alltraps>

c01021eb <vector112>:
.globl vector112
vector112:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $112
c01021ed:	6a 70                	push   $0x70
  jmp __alltraps
c01021ef:	e9 87 06 00 00       	jmp    c010287b <__alltraps>

c01021f4 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $113
c01021f6:	6a 71                	push   $0x71
  jmp __alltraps
c01021f8:	e9 7e 06 00 00       	jmp    c010287b <__alltraps>

c01021fd <vector114>:
.globl vector114
vector114:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $114
c01021ff:	6a 72                	push   $0x72
  jmp __alltraps
c0102201:	e9 75 06 00 00       	jmp    c010287b <__alltraps>

c0102206 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $115
c0102208:	6a 73                	push   $0x73
  jmp __alltraps
c010220a:	e9 6c 06 00 00       	jmp    c010287b <__alltraps>

c010220f <vector116>:
.globl vector116
vector116:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $116
c0102211:	6a 74                	push   $0x74
  jmp __alltraps
c0102213:	e9 63 06 00 00       	jmp    c010287b <__alltraps>

c0102218 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $117
c010221a:	6a 75                	push   $0x75
  jmp __alltraps
c010221c:	e9 5a 06 00 00       	jmp    c010287b <__alltraps>

c0102221 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $118
c0102223:	6a 76                	push   $0x76
  jmp __alltraps
c0102225:	e9 51 06 00 00       	jmp    c010287b <__alltraps>

c010222a <vector119>:
.globl vector119
vector119:
  pushl $0
c010222a:	6a 00                	push   $0x0
  pushl $119
c010222c:	6a 77                	push   $0x77
  jmp __alltraps
c010222e:	e9 48 06 00 00       	jmp    c010287b <__alltraps>

c0102233 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102233:	6a 00                	push   $0x0
  pushl $120
c0102235:	6a 78                	push   $0x78
  jmp __alltraps
c0102237:	e9 3f 06 00 00       	jmp    c010287b <__alltraps>

c010223c <vector121>:
.globl vector121
vector121:
  pushl $0
c010223c:	6a 00                	push   $0x0
  pushl $121
c010223e:	6a 79                	push   $0x79
  jmp __alltraps
c0102240:	e9 36 06 00 00       	jmp    c010287b <__alltraps>

c0102245 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $122
c0102247:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102249:	e9 2d 06 00 00       	jmp    c010287b <__alltraps>

c010224e <vector123>:
.globl vector123
vector123:
  pushl $0
c010224e:	6a 00                	push   $0x0
  pushl $123
c0102250:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102252:	e9 24 06 00 00       	jmp    c010287b <__alltraps>

c0102257 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102257:	6a 00                	push   $0x0
  pushl $124
c0102259:	6a 7c                	push   $0x7c
  jmp __alltraps
c010225b:	e9 1b 06 00 00       	jmp    c010287b <__alltraps>

c0102260 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102260:	6a 00                	push   $0x0
  pushl $125
c0102262:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102264:	e9 12 06 00 00       	jmp    c010287b <__alltraps>

c0102269 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $126
c010226b:	6a 7e                	push   $0x7e
  jmp __alltraps
c010226d:	e9 09 06 00 00       	jmp    c010287b <__alltraps>

c0102272 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102272:	6a 00                	push   $0x0
  pushl $127
c0102274:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102276:	e9 00 06 00 00       	jmp    c010287b <__alltraps>

c010227b <vector128>:
.globl vector128
vector128:
  pushl $0
c010227b:	6a 00                	push   $0x0
  pushl $128
c010227d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102282:	e9 f4 05 00 00       	jmp    c010287b <__alltraps>

c0102287 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102287:	6a 00                	push   $0x0
  pushl $129
c0102289:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010228e:	e9 e8 05 00 00       	jmp    c010287b <__alltraps>

c0102293 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102293:	6a 00                	push   $0x0
  pushl $130
c0102295:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010229a:	e9 dc 05 00 00       	jmp    c010287b <__alltraps>

c010229f <vector131>:
.globl vector131
vector131:
  pushl $0
c010229f:	6a 00                	push   $0x0
  pushl $131
c01022a1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022a6:	e9 d0 05 00 00       	jmp    c010287b <__alltraps>

c01022ab <vector132>:
.globl vector132
vector132:
  pushl $0
c01022ab:	6a 00                	push   $0x0
  pushl $132
c01022ad:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022b2:	e9 c4 05 00 00       	jmp    c010287b <__alltraps>

c01022b7 <vector133>:
.globl vector133
vector133:
  pushl $0
c01022b7:	6a 00                	push   $0x0
  pushl $133
c01022b9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022be:	e9 b8 05 00 00       	jmp    c010287b <__alltraps>

c01022c3 <vector134>:
.globl vector134
vector134:
  pushl $0
c01022c3:	6a 00                	push   $0x0
  pushl $134
c01022c5:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022ca:	e9 ac 05 00 00       	jmp    c010287b <__alltraps>

c01022cf <vector135>:
.globl vector135
vector135:
  pushl $0
c01022cf:	6a 00                	push   $0x0
  pushl $135
c01022d1:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022d6:	e9 a0 05 00 00       	jmp    c010287b <__alltraps>

c01022db <vector136>:
.globl vector136
vector136:
  pushl $0
c01022db:	6a 00                	push   $0x0
  pushl $136
c01022dd:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022e2:	e9 94 05 00 00       	jmp    c010287b <__alltraps>

c01022e7 <vector137>:
.globl vector137
vector137:
  pushl $0
c01022e7:	6a 00                	push   $0x0
  pushl $137
c01022e9:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022ee:	e9 88 05 00 00       	jmp    c010287b <__alltraps>

c01022f3 <vector138>:
.globl vector138
vector138:
  pushl $0
c01022f3:	6a 00                	push   $0x0
  pushl $138
c01022f5:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022fa:	e9 7c 05 00 00       	jmp    c010287b <__alltraps>

c01022ff <vector139>:
.globl vector139
vector139:
  pushl $0
c01022ff:	6a 00                	push   $0x0
  pushl $139
c0102301:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102306:	e9 70 05 00 00       	jmp    c010287b <__alltraps>

c010230b <vector140>:
.globl vector140
vector140:
  pushl $0
c010230b:	6a 00                	push   $0x0
  pushl $140
c010230d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102312:	e9 64 05 00 00       	jmp    c010287b <__alltraps>

c0102317 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102317:	6a 00                	push   $0x0
  pushl $141
c0102319:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010231e:	e9 58 05 00 00       	jmp    c010287b <__alltraps>

c0102323 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102323:	6a 00                	push   $0x0
  pushl $142
c0102325:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010232a:	e9 4c 05 00 00       	jmp    c010287b <__alltraps>

c010232f <vector143>:
.globl vector143
vector143:
  pushl $0
c010232f:	6a 00                	push   $0x0
  pushl $143
c0102331:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102336:	e9 40 05 00 00       	jmp    c010287b <__alltraps>

c010233b <vector144>:
.globl vector144
vector144:
  pushl $0
c010233b:	6a 00                	push   $0x0
  pushl $144
c010233d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102342:	e9 34 05 00 00       	jmp    c010287b <__alltraps>

c0102347 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102347:	6a 00                	push   $0x0
  pushl $145
c0102349:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010234e:	e9 28 05 00 00       	jmp    c010287b <__alltraps>

c0102353 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102353:	6a 00                	push   $0x0
  pushl $146
c0102355:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010235a:	e9 1c 05 00 00       	jmp    c010287b <__alltraps>

c010235f <vector147>:
.globl vector147
vector147:
  pushl $0
c010235f:	6a 00                	push   $0x0
  pushl $147
c0102361:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102366:	e9 10 05 00 00       	jmp    c010287b <__alltraps>

c010236b <vector148>:
.globl vector148
vector148:
  pushl $0
c010236b:	6a 00                	push   $0x0
  pushl $148
c010236d:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102372:	e9 04 05 00 00       	jmp    c010287b <__alltraps>

c0102377 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102377:	6a 00                	push   $0x0
  pushl $149
c0102379:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010237e:	e9 f8 04 00 00       	jmp    c010287b <__alltraps>

c0102383 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102383:	6a 00                	push   $0x0
  pushl $150
c0102385:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010238a:	e9 ec 04 00 00       	jmp    c010287b <__alltraps>

c010238f <vector151>:
.globl vector151
vector151:
  pushl $0
c010238f:	6a 00                	push   $0x0
  pushl $151
c0102391:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102396:	e9 e0 04 00 00       	jmp    c010287b <__alltraps>

c010239b <vector152>:
.globl vector152
vector152:
  pushl $0
c010239b:	6a 00                	push   $0x0
  pushl $152
c010239d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023a2:	e9 d4 04 00 00       	jmp    c010287b <__alltraps>

c01023a7 <vector153>:
.globl vector153
vector153:
  pushl $0
c01023a7:	6a 00                	push   $0x0
  pushl $153
c01023a9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023ae:	e9 c8 04 00 00       	jmp    c010287b <__alltraps>

c01023b3 <vector154>:
.globl vector154
vector154:
  pushl $0
c01023b3:	6a 00                	push   $0x0
  pushl $154
c01023b5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023ba:	e9 bc 04 00 00       	jmp    c010287b <__alltraps>

c01023bf <vector155>:
.globl vector155
vector155:
  pushl $0
c01023bf:	6a 00                	push   $0x0
  pushl $155
c01023c1:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023c6:	e9 b0 04 00 00       	jmp    c010287b <__alltraps>

c01023cb <vector156>:
.globl vector156
vector156:
  pushl $0
c01023cb:	6a 00                	push   $0x0
  pushl $156
c01023cd:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023d2:	e9 a4 04 00 00       	jmp    c010287b <__alltraps>

c01023d7 <vector157>:
.globl vector157
vector157:
  pushl $0
c01023d7:	6a 00                	push   $0x0
  pushl $157
c01023d9:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023de:	e9 98 04 00 00       	jmp    c010287b <__alltraps>

c01023e3 <vector158>:
.globl vector158
vector158:
  pushl $0
c01023e3:	6a 00                	push   $0x0
  pushl $158
c01023e5:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01023ea:	e9 8c 04 00 00       	jmp    c010287b <__alltraps>

c01023ef <vector159>:
.globl vector159
vector159:
  pushl $0
c01023ef:	6a 00                	push   $0x0
  pushl $159
c01023f1:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023f6:	e9 80 04 00 00       	jmp    c010287b <__alltraps>

c01023fb <vector160>:
.globl vector160
vector160:
  pushl $0
c01023fb:	6a 00                	push   $0x0
  pushl $160
c01023fd:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102402:	e9 74 04 00 00       	jmp    c010287b <__alltraps>

c0102407 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102407:	6a 00                	push   $0x0
  pushl $161
c0102409:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010240e:	e9 68 04 00 00       	jmp    c010287b <__alltraps>

c0102413 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102413:	6a 00                	push   $0x0
  pushl $162
c0102415:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010241a:	e9 5c 04 00 00       	jmp    c010287b <__alltraps>

c010241f <vector163>:
.globl vector163
vector163:
  pushl $0
c010241f:	6a 00                	push   $0x0
  pushl $163
c0102421:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102426:	e9 50 04 00 00       	jmp    c010287b <__alltraps>

c010242b <vector164>:
.globl vector164
vector164:
  pushl $0
c010242b:	6a 00                	push   $0x0
  pushl $164
c010242d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102432:	e9 44 04 00 00       	jmp    c010287b <__alltraps>

c0102437 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102437:	6a 00                	push   $0x0
  pushl $165
c0102439:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010243e:	e9 38 04 00 00       	jmp    c010287b <__alltraps>

c0102443 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102443:	6a 00                	push   $0x0
  pushl $166
c0102445:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010244a:	e9 2c 04 00 00       	jmp    c010287b <__alltraps>

c010244f <vector167>:
.globl vector167
vector167:
  pushl $0
c010244f:	6a 00                	push   $0x0
  pushl $167
c0102451:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102456:	e9 20 04 00 00       	jmp    c010287b <__alltraps>

c010245b <vector168>:
.globl vector168
vector168:
  pushl $0
c010245b:	6a 00                	push   $0x0
  pushl $168
c010245d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102462:	e9 14 04 00 00       	jmp    c010287b <__alltraps>

c0102467 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102467:	6a 00                	push   $0x0
  pushl $169
c0102469:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010246e:	e9 08 04 00 00       	jmp    c010287b <__alltraps>

c0102473 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102473:	6a 00                	push   $0x0
  pushl $170
c0102475:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010247a:	e9 fc 03 00 00       	jmp    c010287b <__alltraps>

c010247f <vector171>:
.globl vector171
vector171:
  pushl $0
c010247f:	6a 00                	push   $0x0
  pushl $171
c0102481:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102486:	e9 f0 03 00 00       	jmp    c010287b <__alltraps>

c010248b <vector172>:
.globl vector172
vector172:
  pushl $0
c010248b:	6a 00                	push   $0x0
  pushl $172
c010248d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102492:	e9 e4 03 00 00       	jmp    c010287b <__alltraps>

c0102497 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102497:	6a 00                	push   $0x0
  pushl $173
c0102499:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010249e:	e9 d8 03 00 00       	jmp    c010287b <__alltraps>

c01024a3 <vector174>:
.globl vector174
vector174:
  pushl $0
c01024a3:	6a 00                	push   $0x0
  pushl $174
c01024a5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024aa:	e9 cc 03 00 00       	jmp    c010287b <__alltraps>

c01024af <vector175>:
.globl vector175
vector175:
  pushl $0
c01024af:	6a 00                	push   $0x0
  pushl $175
c01024b1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024b6:	e9 c0 03 00 00       	jmp    c010287b <__alltraps>

c01024bb <vector176>:
.globl vector176
vector176:
  pushl $0
c01024bb:	6a 00                	push   $0x0
  pushl $176
c01024bd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024c2:	e9 b4 03 00 00       	jmp    c010287b <__alltraps>

c01024c7 <vector177>:
.globl vector177
vector177:
  pushl $0
c01024c7:	6a 00                	push   $0x0
  pushl $177
c01024c9:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024ce:	e9 a8 03 00 00       	jmp    c010287b <__alltraps>

c01024d3 <vector178>:
.globl vector178
vector178:
  pushl $0
c01024d3:	6a 00                	push   $0x0
  pushl $178
c01024d5:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024da:	e9 9c 03 00 00       	jmp    c010287b <__alltraps>

c01024df <vector179>:
.globl vector179
vector179:
  pushl $0
c01024df:	6a 00                	push   $0x0
  pushl $179
c01024e1:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024e6:	e9 90 03 00 00       	jmp    c010287b <__alltraps>

c01024eb <vector180>:
.globl vector180
vector180:
  pushl $0
c01024eb:	6a 00                	push   $0x0
  pushl $180
c01024ed:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024f2:	e9 84 03 00 00       	jmp    c010287b <__alltraps>

c01024f7 <vector181>:
.globl vector181
vector181:
  pushl $0
c01024f7:	6a 00                	push   $0x0
  pushl $181
c01024f9:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024fe:	e9 78 03 00 00       	jmp    c010287b <__alltraps>

c0102503 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102503:	6a 00                	push   $0x0
  pushl $182
c0102505:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010250a:	e9 6c 03 00 00       	jmp    c010287b <__alltraps>

c010250f <vector183>:
.globl vector183
vector183:
  pushl $0
c010250f:	6a 00                	push   $0x0
  pushl $183
c0102511:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102516:	e9 60 03 00 00       	jmp    c010287b <__alltraps>

c010251b <vector184>:
.globl vector184
vector184:
  pushl $0
c010251b:	6a 00                	push   $0x0
  pushl $184
c010251d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102522:	e9 54 03 00 00       	jmp    c010287b <__alltraps>

c0102527 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102527:	6a 00                	push   $0x0
  pushl $185
c0102529:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010252e:	e9 48 03 00 00       	jmp    c010287b <__alltraps>

c0102533 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102533:	6a 00                	push   $0x0
  pushl $186
c0102535:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010253a:	e9 3c 03 00 00       	jmp    c010287b <__alltraps>

c010253f <vector187>:
.globl vector187
vector187:
  pushl $0
c010253f:	6a 00                	push   $0x0
  pushl $187
c0102541:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102546:	e9 30 03 00 00       	jmp    c010287b <__alltraps>

c010254b <vector188>:
.globl vector188
vector188:
  pushl $0
c010254b:	6a 00                	push   $0x0
  pushl $188
c010254d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102552:	e9 24 03 00 00       	jmp    c010287b <__alltraps>

c0102557 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102557:	6a 00                	push   $0x0
  pushl $189
c0102559:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010255e:	e9 18 03 00 00       	jmp    c010287b <__alltraps>

c0102563 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102563:	6a 00                	push   $0x0
  pushl $190
c0102565:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010256a:	e9 0c 03 00 00       	jmp    c010287b <__alltraps>

c010256f <vector191>:
.globl vector191
vector191:
  pushl $0
c010256f:	6a 00                	push   $0x0
  pushl $191
c0102571:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102576:	e9 00 03 00 00       	jmp    c010287b <__alltraps>

c010257b <vector192>:
.globl vector192
vector192:
  pushl $0
c010257b:	6a 00                	push   $0x0
  pushl $192
c010257d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102582:	e9 f4 02 00 00       	jmp    c010287b <__alltraps>

c0102587 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102587:	6a 00                	push   $0x0
  pushl $193
c0102589:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010258e:	e9 e8 02 00 00       	jmp    c010287b <__alltraps>

c0102593 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102593:	6a 00                	push   $0x0
  pushl $194
c0102595:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010259a:	e9 dc 02 00 00       	jmp    c010287b <__alltraps>

c010259f <vector195>:
.globl vector195
vector195:
  pushl $0
c010259f:	6a 00                	push   $0x0
  pushl $195
c01025a1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025a6:	e9 d0 02 00 00       	jmp    c010287b <__alltraps>

c01025ab <vector196>:
.globl vector196
vector196:
  pushl $0
c01025ab:	6a 00                	push   $0x0
  pushl $196
c01025ad:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025b2:	e9 c4 02 00 00       	jmp    c010287b <__alltraps>

c01025b7 <vector197>:
.globl vector197
vector197:
  pushl $0
c01025b7:	6a 00                	push   $0x0
  pushl $197
c01025b9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025be:	e9 b8 02 00 00       	jmp    c010287b <__alltraps>

c01025c3 <vector198>:
.globl vector198
vector198:
  pushl $0
c01025c3:	6a 00                	push   $0x0
  pushl $198
c01025c5:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025ca:	e9 ac 02 00 00       	jmp    c010287b <__alltraps>

c01025cf <vector199>:
.globl vector199
vector199:
  pushl $0
c01025cf:	6a 00                	push   $0x0
  pushl $199
c01025d1:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025d6:	e9 a0 02 00 00       	jmp    c010287b <__alltraps>

c01025db <vector200>:
.globl vector200
vector200:
  pushl $0
c01025db:	6a 00                	push   $0x0
  pushl $200
c01025dd:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025e2:	e9 94 02 00 00       	jmp    c010287b <__alltraps>

c01025e7 <vector201>:
.globl vector201
vector201:
  pushl $0
c01025e7:	6a 00                	push   $0x0
  pushl $201
c01025e9:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025ee:	e9 88 02 00 00       	jmp    c010287b <__alltraps>

c01025f3 <vector202>:
.globl vector202
vector202:
  pushl $0
c01025f3:	6a 00                	push   $0x0
  pushl $202
c01025f5:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025fa:	e9 7c 02 00 00       	jmp    c010287b <__alltraps>

c01025ff <vector203>:
.globl vector203
vector203:
  pushl $0
c01025ff:	6a 00                	push   $0x0
  pushl $203
c0102601:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102606:	e9 70 02 00 00       	jmp    c010287b <__alltraps>

c010260b <vector204>:
.globl vector204
vector204:
  pushl $0
c010260b:	6a 00                	push   $0x0
  pushl $204
c010260d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102612:	e9 64 02 00 00       	jmp    c010287b <__alltraps>

c0102617 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102617:	6a 00                	push   $0x0
  pushl $205
c0102619:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010261e:	e9 58 02 00 00       	jmp    c010287b <__alltraps>

c0102623 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102623:	6a 00                	push   $0x0
  pushl $206
c0102625:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010262a:	e9 4c 02 00 00       	jmp    c010287b <__alltraps>

c010262f <vector207>:
.globl vector207
vector207:
  pushl $0
c010262f:	6a 00                	push   $0x0
  pushl $207
c0102631:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102636:	e9 40 02 00 00       	jmp    c010287b <__alltraps>

c010263b <vector208>:
.globl vector208
vector208:
  pushl $0
c010263b:	6a 00                	push   $0x0
  pushl $208
c010263d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102642:	e9 34 02 00 00       	jmp    c010287b <__alltraps>

c0102647 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102647:	6a 00                	push   $0x0
  pushl $209
c0102649:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010264e:	e9 28 02 00 00       	jmp    c010287b <__alltraps>

c0102653 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102653:	6a 00                	push   $0x0
  pushl $210
c0102655:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010265a:	e9 1c 02 00 00       	jmp    c010287b <__alltraps>

c010265f <vector211>:
.globl vector211
vector211:
  pushl $0
c010265f:	6a 00                	push   $0x0
  pushl $211
c0102661:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102666:	e9 10 02 00 00       	jmp    c010287b <__alltraps>

c010266b <vector212>:
.globl vector212
vector212:
  pushl $0
c010266b:	6a 00                	push   $0x0
  pushl $212
c010266d:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102672:	e9 04 02 00 00       	jmp    c010287b <__alltraps>

c0102677 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102677:	6a 00                	push   $0x0
  pushl $213
c0102679:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010267e:	e9 f8 01 00 00       	jmp    c010287b <__alltraps>

c0102683 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102683:	6a 00                	push   $0x0
  pushl $214
c0102685:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010268a:	e9 ec 01 00 00       	jmp    c010287b <__alltraps>

c010268f <vector215>:
.globl vector215
vector215:
  pushl $0
c010268f:	6a 00                	push   $0x0
  pushl $215
c0102691:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102696:	e9 e0 01 00 00       	jmp    c010287b <__alltraps>

c010269b <vector216>:
.globl vector216
vector216:
  pushl $0
c010269b:	6a 00                	push   $0x0
  pushl $216
c010269d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026a2:	e9 d4 01 00 00       	jmp    c010287b <__alltraps>

c01026a7 <vector217>:
.globl vector217
vector217:
  pushl $0
c01026a7:	6a 00                	push   $0x0
  pushl $217
c01026a9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026ae:	e9 c8 01 00 00       	jmp    c010287b <__alltraps>

c01026b3 <vector218>:
.globl vector218
vector218:
  pushl $0
c01026b3:	6a 00                	push   $0x0
  pushl $218
c01026b5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026ba:	e9 bc 01 00 00       	jmp    c010287b <__alltraps>

c01026bf <vector219>:
.globl vector219
vector219:
  pushl $0
c01026bf:	6a 00                	push   $0x0
  pushl $219
c01026c1:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026c6:	e9 b0 01 00 00       	jmp    c010287b <__alltraps>

c01026cb <vector220>:
.globl vector220
vector220:
  pushl $0
c01026cb:	6a 00                	push   $0x0
  pushl $220
c01026cd:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026d2:	e9 a4 01 00 00       	jmp    c010287b <__alltraps>

c01026d7 <vector221>:
.globl vector221
vector221:
  pushl $0
c01026d7:	6a 00                	push   $0x0
  pushl $221
c01026d9:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026de:	e9 98 01 00 00       	jmp    c010287b <__alltraps>

c01026e3 <vector222>:
.globl vector222
vector222:
  pushl $0
c01026e3:	6a 00                	push   $0x0
  pushl $222
c01026e5:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01026ea:	e9 8c 01 00 00       	jmp    c010287b <__alltraps>

c01026ef <vector223>:
.globl vector223
vector223:
  pushl $0
c01026ef:	6a 00                	push   $0x0
  pushl $223
c01026f1:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026f6:	e9 80 01 00 00       	jmp    c010287b <__alltraps>

c01026fb <vector224>:
.globl vector224
vector224:
  pushl $0
c01026fb:	6a 00                	push   $0x0
  pushl $224
c01026fd:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102702:	e9 74 01 00 00       	jmp    c010287b <__alltraps>

c0102707 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102707:	6a 00                	push   $0x0
  pushl $225
c0102709:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010270e:	e9 68 01 00 00       	jmp    c010287b <__alltraps>

c0102713 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102713:	6a 00                	push   $0x0
  pushl $226
c0102715:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010271a:	e9 5c 01 00 00       	jmp    c010287b <__alltraps>

c010271f <vector227>:
.globl vector227
vector227:
  pushl $0
c010271f:	6a 00                	push   $0x0
  pushl $227
c0102721:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102726:	e9 50 01 00 00       	jmp    c010287b <__alltraps>

c010272b <vector228>:
.globl vector228
vector228:
  pushl $0
c010272b:	6a 00                	push   $0x0
  pushl $228
c010272d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102732:	e9 44 01 00 00       	jmp    c010287b <__alltraps>

c0102737 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102737:	6a 00                	push   $0x0
  pushl $229
c0102739:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010273e:	e9 38 01 00 00       	jmp    c010287b <__alltraps>

c0102743 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102743:	6a 00                	push   $0x0
  pushl $230
c0102745:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010274a:	e9 2c 01 00 00       	jmp    c010287b <__alltraps>

c010274f <vector231>:
.globl vector231
vector231:
  pushl $0
c010274f:	6a 00                	push   $0x0
  pushl $231
c0102751:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102756:	e9 20 01 00 00       	jmp    c010287b <__alltraps>

c010275b <vector232>:
.globl vector232
vector232:
  pushl $0
c010275b:	6a 00                	push   $0x0
  pushl $232
c010275d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102762:	e9 14 01 00 00       	jmp    c010287b <__alltraps>

c0102767 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102767:	6a 00                	push   $0x0
  pushl $233
c0102769:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010276e:	e9 08 01 00 00       	jmp    c010287b <__alltraps>

c0102773 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102773:	6a 00                	push   $0x0
  pushl $234
c0102775:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010277a:	e9 fc 00 00 00       	jmp    c010287b <__alltraps>

c010277f <vector235>:
.globl vector235
vector235:
  pushl $0
c010277f:	6a 00                	push   $0x0
  pushl $235
c0102781:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102786:	e9 f0 00 00 00       	jmp    c010287b <__alltraps>

c010278b <vector236>:
.globl vector236
vector236:
  pushl $0
c010278b:	6a 00                	push   $0x0
  pushl $236
c010278d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102792:	e9 e4 00 00 00       	jmp    c010287b <__alltraps>

c0102797 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102797:	6a 00                	push   $0x0
  pushl $237
c0102799:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010279e:	e9 d8 00 00 00       	jmp    c010287b <__alltraps>

c01027a3 <vector238>:
.globl vector238
vector238:
  pushl $0
c01027a3:	6a 00                	push   $0x0
  pushl $238
c01027a5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027aa:	e9 cc 00 00 00       	jmp    c010287b <__alltraps>

c01027af <vector239>:
.globl vector239
vector239:
  pushl $0
c01027af:	6a 00                	push   $0x0
  pushl $239
c01027b1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027b6:	e9 c0 00 00 00       	jmp    c010287b <__alltraps>

c01027bb <vector240>:
.globl vector240
vector240:
  pushl $0
c01027bb:	6a 00                	push   $0x0
  pushl $240
c01027bd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027c2:	e9 b4 00 00 00       	jmp    c010287b <__alltraps>

c01027c7 <vector241>:
.globl vector241
vector241:
  pushl $0
c01027c7:	6a 00                	push   $0x0
  pushl $241
c01027c9:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027ce:	e9 a8 00 00 00       	jmp    c010287b <__alltraps>

c01027d3 <vector242>:
.globl vector242
vector242:
  pushl $0
c01027d3:	6a 00                	push   $0x0
  pushl $242
c01027d5:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027da:	e9 9c 00 00 00       	jmp    c010287b <__alltraps>

c01027df <vector243>:
.globl vector243
vector243:
  pushl $0
c01027df:	6a 00                	push   $0x0
  pushl $243
c01027e1:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027e6:	e9 90 00 00 00       	jmp    c010287b <__alltraps>

c01027eb <vector244>:
.globl vector244
vector244:
  pushl $0
c01027eb:	6a 00                	push   $0x0
  pushl $244
c01027ed:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027f2:	e9 84 00 00 00       	jmp    c010287b <__alltraps>

c01027f7 <vector245>:
.globl vector245
vector245:
  pushl $0
c01027f7:	6a 00                	push   $0x0
  pushl $245
c01027f9:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027fe:	e9 78 00 00 00       	jmp    c010287b <__alltraps>

c0102803 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102803:	6a 00                	push   $0x0
  pushl $246
c0102805:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010280a:	e9 6c 00 00 00       	jmp    c010287b <__alltraps>

c010280f <vector247>:
.globl vector247
vector247:
  pushl $0
c010280f:	6a 00                	push   $0x0
  pushl $247
c0102811:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102816:	e9 60 00 00 00       	jmp    c010287b <__alltraps>

c010281b <vector248>:
.globl vector248
vector248:
  pushl $0
c010281b:	6a 00                	push   $0x0
  pushl $248
c010281d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102822:	e9 54 00 00 00       	jmp    c010287b <__alltraps>

c0102827 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102827:	6a 00                	push   $0x0
  pushl $249
c0102829:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010282e:	e9 48 00 00 00       	jmp    c010287b <__alltraps>

c0102833 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102833:	6a 00                	push   $0x0
  pushl $250
c0102835:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010283a:	e9 3c 00 00 00       	jmp    c010287b <__alltraps>

c010283f <vector251>:
.globl vector251
vector251:
  pushl $0
c010283f:	6a 00                	push   $0x0
  pushl $251
c0102841:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102846:	e9 30 00 00 00       	jmp    c010287b <__alltraps>

c010284b <vector252>:
.globl vector252
vector252:
  pushl $0
c010284b:	6a 00                	push   $0x0
  pushl $252
c010284d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102852:	e9 24 00 00 00       	jmp    c010287b <__alltraps>

c0102857 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102857:	6a 00                	push   $0x0
  pushl $253
c0102859:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010285e:	e9 18 00 00 00       	jmp    c010287b <__alltraps>

c0102863 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102863:	6a 00                	push   $0x0
  pushl $254
c0102865:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010286a:	e9 0c 00 00 00       	jmp    c010287b <__alltraps>

c010286f <vector255>:
.globl vector255
vector255:
  pushl $0
c010286f:	6a 00                	push   $0x0
  pushl $255
c0102871:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102876:	e9 00 00 00 00       	jmp    c010287b <__alltraps>

c010287b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010287b:	1e                   	push   %ds
    pushl %es
c010287c:	06                   	push   %es
    pushl %fs
c010287d:	0f a0                	push   %fs
    pushl %gs
c010287f:	0f a8                	push   %gs
    pushal
c0102881:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102882:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102887:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102889:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010288b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010288c:	e8 64 f5 ff ff       	call   c0101df5 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102891:	5c                   	pop    %esp

c0102892 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102892:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102893:	0f a9                	pop    %gs
    popl %fs
c0102895:	0f a1                	pop    %fs
    popl %es
c0102897:	07                   	pop    %es
    popl %ds
c0102898:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102899:	83 c4 08             	add    $0x8,%esp
    iret
c010289c:	cf                   	iret   

c010289d <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010289d:	55                   	push   %ebp
c010289e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a3:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c01028a9:	29 d0                	sub    %edx,%eax
c01028ab:	c1 f8 02             	sar    $0x2,%eax
c01028ae:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028b4:	5d                   	pop    %ebp
c01028b5:	c3                   	ret    

c01028b6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028b6:	55                   	push   %ebp
c01028b7:	89 e5                	mov    %esp,%ebp
c01028b9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01028bf:	89 04 24             	mov    %eax,(%esp)
c01028c2:	e8 d6 ff ff ff       	call   c010289d <page2ppn>
c01028c7:	c1 e0 0c             	shl    $0xc,%eax
}
c01028ca:	c9                   	leave  
c01028cb:	c3                   	ret    

c01028cc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01028cc:	55                   	push   %ebp
c01028cd:	89 e5                	mov    %esp,%ebp
c01028cf:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01028d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028d5:	c1 e8 0c             	shr    $0xc,%eax
c01028d8:	89 c2                	mov    %eax,%edx
c01028da:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01028df:	39 c2                	cmp    %eax,%edx
c01028e1:	72 1c                	jb     c01028ff <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01028e3:	c7 44 24 08 90 65 10 	movl   $0xc0106590,0x8(%esp)
c01028ea:	c0 
c01028eb:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c01028f2:	00 
c01028f3:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
c01028fa:	e8 ea da ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c01028ff:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102905:	8b 45 08             	mov    0x8(%ebp),%eax
c0102908:	c1 e8 0c             	shr    $0xc,%eax
c010290b:	89 c2                	mov    %eax,%edx
c010290d:	89 d0                	mov    %edx,%eax
c010290f:	c1 e0 02             	shl    $0x2,%eax
c0102912:	01 d0                	add    %edx,%eax
c0102914:	c1 e0 02             	shl    $0x2,%eax
c0102917:	01 c8                	add    %ecx,%eax
}
c0102919:	c9                   	leave  
c010291a:	c3                   	ret    

c010291b <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010291b:	55                   	push   %ebp
c010291c:	89 e5                	mov    %esp,%ebp
c010291e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102921:	8b 45 08             	mov    0x8(%ebp),%eax
c0102924:	89 04 24             	mov    %eax,(%esp)
c0102927:	e8 8a ff ff ff       	call   c01028b6 <page2pa>
c010292c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010292f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102932:	c1 e8 0c             	shr    $0xc,%eax
c0102935:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102938:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010293d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102940:	72 23                	jb     c0102965 <page2kva+0x4a>
c0102942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102945:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102949:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c0102950:	c0 
c0102951:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102958:	00 
c0102959:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
c0102960:	e8 84 da ff ff       	call   c01003e9 <__panic>
c0102965:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102968:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010296d:	c9                   	leave  
c010296e:	c3                   	ret    

c010296f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010296f:	55                   	push   %ebp
c0102970:	89 e5                	mov    %esp,%ebp
c0102972:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102975:	8b 45 08             	mov    0x8(%ebp),%eax
c0102978:	83 e0 01             	and    $0x1,%eax
c010297b:	85 c0                	test   %eax,%eax
c010297d:	75 1c                	jne    c010299b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010297f:	c7 44 24 08 e4 65 10 	movl   $0xc01065e4,0x8(%esp)
c0102986:	c0 
c0102987:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010298e:	00 
c010298f:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
c0102996:	e8 4e da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010299b:	8b 45 08             	mov    0x8(%ebp),%eax
c010299e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029a3:	89 04 24             	mov    %eax,(%esp)
c01029a6:	e8 21 ff ff ff       	call   c01028cc <pa2page>
}
c01029ab:	c9                   	leave  
c01029ac:	c3                   	ret    

c01029ad <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01029ad:	55                   	push   %ebp
c01029ae:	89 e5                	mov    %esp,%ebp
c01029b0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01029b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029bb:	89 04 24             	mov    %eax,(%esp)
c01029be:	e8 09 ff ff ff       	call   c01028cc <pa2page>
}
c01029c3:	c9                   	leave  
c01029c4:	c3                   	ret    

c01029c5 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01029c5:	55                   	push   %ebp
c01029c6:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01029c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029cb:	8b 00                	mov    (%eax),%eax
}
c01029cd:	5d                   	pop    %ebp
c01029ce:	c3                   	ret    

c01029cf <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01029cf:	55                   	push   %ebp
c01029d0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01029d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029d8:	89 10                	mov    %edx,(%eax)
}
c01029da:	90                   	nop
c01029db:	5d                   	pop    %ebp
c01029dc:	c3                   	ret    

c01029dd <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01029dd:	55                   	push   %ebp
c01029de:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01029e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e3:	8b 00                	mov    (%eax),%eax
c01029e5:	8d 50 01             	lea    0x1(%eax),%edx
c01029e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029eb:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f0:	8b 00                	mov    (%eax),%eax
}
c01029f2:	5d                   	pop    %ebp
c01029f3:	c3                   	ret    

c01029f4 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01029f4:	55                   	push   %ebp
c01029f5:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01029f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01029fa:	8b 00                	mov    (%eax),%eax
c01029fc:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a02:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a04:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a07:	8b 00                	mov    (%eax),%eax
}
c0102a09:	5d                   	pop    %ebp
c0102a0a:	c3                   	ret    

c0102a0b <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102a0b:	55                   	push   %ebp
c0102a0c:	89 e5                	mov    %esp,%ebp
c0102a0e:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a11:	9c                   	pushf  
c0102a12:	58                   	pop    %eax
c0102a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a19:	25 00 02 00 00       	and    $0x200,%eax
c0102a1e:	85 c0                	test   %eax,%eax
c0102a20:	74 0c                	je     c0102a2e <__intr_save+0x23>
        intr_disable();
c0102a22:	e8 53 ee ff ff       	call   c010187a <intr_disable>
        return 1;
c0102a27:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a2c:	eb 05                	jmp    c0102a33 <__intr_save+0x28>
    }
    return 0;
c0102a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a33:	c9                   	leave  
c0102a34:	c3                   	ret    

c0102a35 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102a35:	55                   	push   %ebp
c0102a36:	89 e5                	mov    %esp,%ebp
c0102a38:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a3f:	74 05                	je     c0102a46 <__intr_restore+0x11>
        intr_enable();
c0102a41:	e8 2d ee ff ff       	call   c0101873 <intr_enable>
    }
}
c0102a46:	90                   	nop
c0102a47:	c9                   	leave  
c0102a48:	c3                   	ret    

c0102a49 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a49:	55                   	push   %ebp
c0102a4a:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a4f:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a52:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a57:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a59:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a5e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a60:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a65:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a67:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a6c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a6e:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a73:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a75:	ea 7c 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a7c
}
c0102a7c:	90                   	nop
c0102a7d:	5d                   	pop    %ebp
c0102a7e:	c3                   	ret    

c0102a7f <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a7f:	55                   	push   %ebp
c0102a80:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a85:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102a8a:	90                   	nop
c0102a8b:	5d                   	pop    %ebp
c0102a8c:	c3                   	ret    

c0102a8d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a8d:	55                   	push   %ebp
c0102a8e:	89 e5                	mov    %esp,%ebp
c0102a90:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a93:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102a98:	89 04 24             	mov    %eax,(%esp)
c0102a9b:	e8 df ff ff ff       	call   c0102a7f <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102aa0:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102aa7:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102aa9:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102ab0:	68 00 
c0102ab2:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102ab7:	0f b7 c0             	movzwl %ax,%eax
c0102aba:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102ac0:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102ac5:	c1 e8 10             	shr    $0x10,%eax
c0102ac8:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102acd:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ad4:	24 f0                	and    $0xf0,%al
c0102ad6:	0c 09                	or     $0x9,%al
c0102ad8:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102add:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ae4:	24 ef                	and    $0xef,%al
c0102ae6:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102aeb:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102af2:	24 9f                	and    $0x9f,%al
c0102af4:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102af9:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b00:	0c 80                	or     $0x80,%al
c0102b02:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b07:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b0e:	24 f0                	and    $0xf0,%al
c0102b10:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b15:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b1c:	24 ef                	and    $0xef,%al
c0102b1e:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b23:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b2a:	24 df                	and    $0xdf,%al
c0102b2c:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b31:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b38:	0c 40                	or     $0x40,%al
c0102b3a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b3f:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b46:	24 7f                	and    $0x7f,%al
c0102b48:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b4d:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102b52:	c1 e8 18             	shr    $0x18,%eax
c0102b55:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b5a:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102b61:	e8 e3 fe ff ff       	call   c0102a49 <lgdt>
c0102b66:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b6c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b70:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b73:	90                   	nop
c0102b74:	c9                   	leave  
c0102b75:	c3                   	ret    

c0102b76 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b76:	55                   	push   %ebp
c0102b77:	89 e5                	mov    %esp,%ebp
c0102b79:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b7c:	c7 05 10 af 11 c0 58 	movl   $0xc0106f58,0xc011af10
c0102b83:	6f 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b86:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b8b:	8b 00                	mov    (%eax),%eax
c0102b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b91:	c7 04 24 10 66 10 c0 	movl   $0xc0106610,(%esp)
c0102b98:	e8 f5 d6 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102b9d:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102ba2:	8b 40 04             	mov    0x4(%eax),%eax
c0102ba5:	ff d0                	call   *%eax
}
c0102ba7:	90                   	nop
c0102ba8:	c9                   	leave  
c0102ba9:	c3                   	ret    

c0102baa <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102baa:	55                   	push   %ebp
c0102bab:	89 e5                	mov    %esp,%ebp
c0102bad:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102bb0:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bb5:	8b 40 08             	mov    0x8(%eax),%eax
c0102bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bbb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bbf:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bc2:	89 14 24             	mov    %edx,(%esp)
c0102bc5:	ff d0                	call   *%eax
}
c0102bc7:	90                   	nop
c0102bc8:	c9                   	leave  
c0102bc9:	c3                   	ret    

c0102bca <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102bca:	55                   	push   %ebp
c0102bcb:	89 e5                	mov    %esp,%ebp
c0102bcd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102bd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bd7:	e8 2f fe ff ff       	call   c0102a0b <__intr_save>
c0102bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102bdf:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102be4:	8b 40 0c             	mov    0xc(%eax),%eax
c0102be7:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bea:	89 14 24             	mov    %edx,(%esp)
c0102bed:	ff d0                	call   *%eax
c0102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bf5:	89 04 24             	mov    %eax,(%esp)
c0102bf8:	e8 38 fe ff ff       	call   c0102a35 <__intr_restore>
    return page;
c0102bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c00:	c9                   	leave  
c0102c01:	c3                   	ret    

c0102c02 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102c02:	55                   	push   %ebp
c0102c03:	89 e5                	mov    %esp,%ebp
c0102c05:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c08:	e8 fe fd ff ff       	call   c0102a0b <__intr_save>
c0102c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102c10:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c15:	8b 40 10             	mov    0x10(%eax),%eax
c0102c18:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c1b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102c1f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c22:	89 14 24             	mov    %edx,(%esp)
c0102c25:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c2a:	89 04 24             	mov    %eax,(%esp)
c0102c2d:	e8 03 fe ff ff       	call   c0102a35 <__intr_restore>
}
c0102c32:	90                   	nop
c0102c33:	c9                   	leave  
c0102c34:	c3                   	ret    

c0102c35 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c35:	55                   	push   %ebp
c0102c36:	89 e5                	mov    %esp,%ebp
c0102c38:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c3b:	e8 cb fd ff ff       	call   c0102a0b <__intr_save>
c0102c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c43:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c48:	8b 40 14             	mov    0x14(%eax),%eax
c0102c4b:	ff d0                	call   *%eax
c0102c4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c53:	89 04 24             	mov    %eax,(%esp)
c0102c56:	e8 da fd ff ff       	call   c0102a35 <__intr_restore>
    return ret;
c0102c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c5e:	c9                   	leave  
c0102c5f:	c3                   	ret    

c0102c60 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c60:	55                   	push   %ebp
c0102c61:	89 e5                	mov    %esp,%ebp
c0102c63:	57                   	push   %edi
c0102c64:	56                   	push   %esi
c0102c65:	53                   	push   %ebx
c0102c66:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c6c:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c73:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c81:	c7 04 24 27 66 10 c0 	movl   $0xc0106627,(%esp)
c0102c88:	e8 05 d6 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c8d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c94:	e9 22 01 00 00       	jmp    c0102dbb <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c99:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c9f:	89 d0                	mov    %edx,%eax
c0102ca1:	c1 e0 02             	shl    $0x2,%eax
c0102ca4:	01 d0                	add    %edx,%eax
c0102ca6:	c1 e0 02             	shl    $0x2,%eax
c0102ca9:	01 c8                	add    %ecx,%eax
c0102cab:	8b 50 08             	mov    0x8(%eax),%edx
c0102cae:	8b 40 04             	mov    0x4(%eax),%eax
c0102cb1:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102cb4:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102cb7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cbd:	89 d0                	mov    %edx,%eax
c0102cbf:	c1 e0 02             	shl    $0x2,%eax
c0102cc2:	01 d0                	add    %edx,%eax
c0102cc4:	c1 e0 02             	shl    $0x2,%eax
c0102cc7:	01 c8                	add    %ecx,%eax
c0102cc9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ccc:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ccf:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102cd2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102cd5:	01 c8                	add    %ecx,%eax
c0102cd7:	11 da                	adc    %ebx,%edx
c0102cd9:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102cdc:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102cdf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ce2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ce5:	89 d0                	mov    %edx,%eax
c0102ce7:	c1 e0 02             	shl    $0x2,%eax
c0102cea:	01 d0                	add    %edx,%eax
c0102cec:	c1 e0 02             	shl    $0x2,%eax
c0102cef:	01 c8                	add    %ecx,%eax
c0102cf1:	83 c0 14             	add    $0x14,%eax
c0102cf4:	8b 00                	mov    (%eax),%eax
c0102cf6:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102cf9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102cfc:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102cff:	83 c0 ff             	add    $0xffffffff,%eax
c0102d02:	83 d2 ff             	adc    $0xffffffff,%edx
c0102d05:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102d0b:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102d11:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d17:	89 d0                	mov    %edx,%eax
c0102d19:	c1 e0 02             	shl    $0x2,%eax
c0102d1c:	01 d0                	add    %edx,%eax
c0102d1e:	c1 e0 02             	shl    $0x2,%eax
c0102d21:	01 c8                	add    %ecx,%eax
c0102d23:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d26:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d29:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102d2c:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102d30:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102d36:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102d3c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102d40:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102d44:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d47:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d4e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d5a:	c7 04 24 34 66 10 c0 	movl   $0xc0106634,(%esp)
c0102d61:	e8 2c d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d66:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d69:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d6c:	89 d0                	mov    %edx,%eax
c0102d6e:	c1 e0 02             	shl    $0x2,%eax
c0102d71:	01 d0                	add    %edx,%eax
c0102d73:	c1 e0 02             	shl    $0x2,%eax
c0102d76:	01 c8                	add    %ecx,%eax
c0102d78:	83 c0 14             	add    $0x14,%eax
c0102d7b:	8b 00                	mov    (%eax),%eax
c0102d7d:	83 f8 01             	cmp    $0x1,%eax
c0102d80:	75 36                	jne    c0102db8 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d88:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d8b:	77 2b                	ja     c0102db8 <page_init+0x158>
c0102d8d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d90:	72 05                	jb     c0102d97 <page_init+0x137>
c0102d92:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102d95:	73 21                	jae    c0102db8 <page_init+0x158>
c0102d97:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d9b:	77 1b                	ja     c0102db8 <page_init+0x158>
c0102d9d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102da1:	72 09                	jb     c0102dac <page_init+0x14c>
c0102da3:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102daa:	77 0c                	ja     c0102db8 <page_init+0x158>
                maxpa = end;
c0102dac:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102daf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102db2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102db5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102db8:	ff 45 dc             	incl   -0x24(%ebp)
c0102dbb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102dbe:	8b 00                	mov    (%eax),%eax
c0102dc0:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102dc3:	0f 8f d0 fe ff ff    	jg     c0102c99 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102dc9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dcd:	72 1d                	jb     c0102dec <page_init+0x18c>
c0102dcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dd3:	77 09                	ja     c0102dde <page_init+0x17e>
c0102dd5:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102ddc:	76 0e                	jbe    c0102dec <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102dde:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102de5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102dec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102def:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102df2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102df6:	c1 ea 0c             	shr    $0xc,%edx
c0102df9:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102dfe:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102e05:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102e0a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e0d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102e10:	01 d0                	add    %edx,%eax
c0102e12:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102e15:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e18:	ba 00 00 00 00       	mov    $0x0,%edx
c0102e1d:	f7 75 ac             	divl   -0x54(%ebp)
c0102e20:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e23:	29 d0                	sub    %edx,%eax
c0102e25:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102e2a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e31:	eb 2e                	jmp    c0102e61 <page_init+0x201>
        SetPageReserved(pages + i);
c0102e33:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102e39:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e3c:	89 d0                	mov    %edx,%eax
c0102e3e:	c1 e0 02             	shl    $0x2,%eax
c0102e41:	01 d0                	add    %edx,%eax
c0102e43:	c1 e0 02             	shl    $0x2,%eax
c0102e46:	01 c8                	add    %ecx,%eax
c0102e48:	83 c0 04             	add    $0x4,%eax
c0102e4b:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102e52:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e55:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e58:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e5b:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0102e5e:	ff 45 dc             	incl   -0x24(%ebp)
c0102e61:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e64:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102e69:	39 c2                	cmp    %eax,%edx
c0102e6b:	72 c6                	jb     c0102e33 <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e6d:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102e73:	89 d0                	mov    %edx,%eax
c0102e75:	c1 e0 02             	shl    $0x2,%eax
c0102e78:	01 d0                	add    %edx,%eax
c0102e7a:	c1 e0 02             	shl    $0x2,%eax
c0102e7d:	89 c2                	mov    %eax,%edx
c0102e7f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102e84:	01 d0                	add    %edx,%eax
c0102e86:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102e89:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102e90:	77 23                	ja     c0102eb5 <page_init+0x255>
c0102e92:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e95:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e99:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0102ea0:	c0 
c0102ea1:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0102ea8:	00 
c0102ea9:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0102eb0:	e8 34 d5 ff ff       	call   c01003e9 <__panic>
c0102eb5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102eb8:	05 00 00 00 40       	add    $0x40000000,%eax
c0102ebd:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102ec0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ec7:	e9 61 01 00 00       	jmp    c010302d <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102ecc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ecf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ed2:	89 d0                	mov    %edx,%eax
c0102ed4:	c1 e0 02             	shl    $0x2,%eax
c0102ed7:	01 d0                	add    %edx,%eax
c0102ed9:	c1 e0 02             	shl    $0x2,%eax
c0102edc:	01 c8                	add    %ecx,%eax
c0102ede:	8b 50 08             	mov    0x8(%eax),%edx
c0102ee1:	8b 40 04             	mov    0x4(%eax),%eax
c0102ee4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ee7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102eea:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102eed:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ef0:	89 d0                	mov    %edx,%eax
c0102ef2:	c1 e0 02             	shl    $0x2,%eax
c0102ef5:	01 d0                	add    %edx,%eax
c0102ef7:	c1 e0 02             	shl    $0x2,%eax
c0102efa:	01 c8                	add    %ecx,%eax
c0102efc:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102eff:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f02:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f05:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f08:	01 c8                	add    %ecx,%eax
c0102f0a:	11 da                	adc    %ebx,%edx
c0102f0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102f0f:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102f12:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f15:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f18:	89 d0                	mov    %edx,%eax
c0102f1a:	c1 e0 02             	shl    $0x2,%eax
c0102f1d:	01 d0                	add    %edx,%eax
c0102f1f:	c1 e0 02             	shl    $0x2,%eax
c0102f22:	01 c8                	add    %ecx,%eax
c0102f24:	83 c0 14             	add    $0x14,%eax
c0102f27:	8b 00                	mov    (%eax),%eax
c0102f29:	83 f8 01             	cmp    $0x1,%eax
c0102f2c:	0f 85 f8 00 00 00    	jne    c010302a <page_init+0x3ca>
            if (begin < freemem) {
c0102f32:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f35:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f3a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f3d:	72 17                	jb     c0102f56 <page_init+0x2f6>
c0102f3f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f42:	77 05                	ja     c0102f49 <page_init+0x2e9>
c0102f44:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102f47:	76 0d                	jbe    c0102f56 <page_init+0x2f6>
                begin = freemem;
c0102f49:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f4f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f56:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f5a:	72 1d                	jb     c0102f79 <page_init+0x319>
c0102f5c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f60:	77 09                	ja     c0102f6b <page_init+0x30b>
c0102f62:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f69:	76 0e                	jbe    c0102f79 <page_init+0x319>
                end = KMEMSIZE;
c0102f6b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f72:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f7c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f7f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f82:	0f 87 a2 00 00 00    	ja     c010302a <page_init+0x3ca>
c0102f88:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f8b:	72 09                	jb     c0102f96 <page_init+0x336>
c0102f8d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f90:	0f 83 94 00 00 00    	jae    c010302a <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
c0102f96:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102f9d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102fa0:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102fa3:	01 d0                	add    %edx,%eax
c0102fa5:	48                   	dec    %eax
c0102fa6:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102fa9:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fac:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fb1:	f7 75 9c             	divl   -0x64(%ebp)
c0102fb4:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fb7:	29 d0                	sub    %edx,%eax
c0102fb9:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fbe:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fc1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102fc4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fc7:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102fca:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102fcd:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fd2:	89 c3                	mov    %eax,%ebx
c0102fd4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102fda:	89 de                	mov    %ebx,%esi
c0102fdc:	89 d0                	mov    %edx,%eax
c0102fde:	83 e0 00             	and    $0x0,%eax
c0102fe1:	89 c7                	mov    %eax,%edi
c0102fe3:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102fe6:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102fe9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fef:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102ff2:	77 36                	ja     c010302a <page_init+0x3ca>
c0102ff4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102ff7:	72 05                	jb     c0102ffe <page_init+0x39e>
c0102ff9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102ffc:	73 2c                	jae    c010302a <page_init+0x3ca>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102ffe:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103001:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103004:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103007:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010300a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010300e:	c1 ea 0c             	shr    $0xc,%edx
c0103011:	89 c3                	mov    %eax,%ebx
c0103013:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103016:	89 04 24             	mov    %eax,(%esp)
c0103019:	e8 ae f8 ff ff       	call   c01028cc <pa2page>
c010301e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103022:	89 04 24             	mov    %eax,(%esp)
c0103025:	e8 80 fb ff ff       	call   c0102baa <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010302a:	ff 45 dc             	incl   -0x24(%ebp)
c010302d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103030:	8b 00                	mov    (%eax),%eax
c0103032:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103035:	0f 8f 91 fe ff ff    	jg     c0102ecc <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c010303b:	90                   	nop
c010303c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103042:	5b                   	pop    %ebx
c0103043:	5e                   	pop    %esi
c0103044:	5f                   	pop    %edi
c0103045:	5d                   	pop    %ebp
c0103046:	c3                   	ret    

c0103047 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103047:	55                   	push   %ebp
c0103048:	89 e5                	mov    %esp,%ebp
c010304a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010304d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103050:	33 45 14             	xor    0x14(%ebp),%eax
c0103053:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103058:	85 c0                	test   %eax,%eax
c010305a:	74 24                	je     c0103080 <boot_map_segment+0x39>
c010305c:	c7 44 24 0c 96 66 10 	movl   $0xc0106696,0xc(%esp)
c0103063:	c0 
c0103064:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010306b:	c0 
c010306c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0103073:	00 
c0103074:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010307b:	e8 69 d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103080:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103087:	8b 45 0c             	mov    0xc(%ebp),%eax
c010308a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010308f:	89 c2                	mov    %eax,%edx
c0103091:	8b 45 10             	mov    0x10(%ebp),%eax
c0103094:	01 c2                	add    %eax,%edx
c0103096:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103099:	01 d0                	add    %edx,%eax
c010309b:	48                   	dec    %eax
c010309c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010309f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030a2:	ba 00 00 00 00       	mov    $0x0,%edx
c01030a7:	f7 75 f0             	divl   -0x10(%ebp)
c01030aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030ad:	29 d0                	sub    %edx,%eax
c01030af:	c1 e8 0c             	shr    $0xc,%eax
c01030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01030b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01030bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01030be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030c3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01030c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01030c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01030cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01030cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030d4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030d7:	eb 68                	jmp    c0103141 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01030d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01030e0:	00 
c01030e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01030e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01030eb:	89 04 24             	mov    %eax,(%esp)
c01030ee:	e8 81 01 00 00       	call   c0103274 <get_pte>
c01030f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01030f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01030fa:	75 24                	jne    c0103120 <boot_map_segment+0xd9>
c01030fc:	c7 44 24 0c c2 66 10 	movl   $0xc01066c2,0xc(%esp)
c0103103:	c0 
c0103104:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010310b:	c0 
c010310c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103113:	00 
c0103114:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010311b:	e8 c9 d2 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103120:	8b 45 14             	mov    0x14(%ebp),%eax
c0103123:	0b 45 18             	or     0x18(%ebp),%eax
c0103126:	83 c8 01             	or     $0x1,%eax
c0103129:	89 c2                	mov    %eax,%edx
c010312b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010312e:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103130:	ff 4d f4             	decl   -0xc(%ebp)
c0103133:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010313a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103141:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103145:	75 92                	jne    c01030d9 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0103147:	90                   	nop
c0103148:	c9                   	leave  
c0103149:	c3                   	ret    

c010314a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010314a:	55                   	push   %ebp
c010314b:	89 e5                	mov    %esp,%ebp
c010314d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103150:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103157:	e8 6e fa ff ff       	call   c0102bca <alloc_pages>
c010315c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010315f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103163:	75 1c                	jne    c0103181 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103165:	c7 44 24 08 cf 66 10 	movl   $0xc01066cf,0x8(%esp)
c010316c:	c0 
c010316d:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103174:	00 
c0103175:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010317c:	e8 68 d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c0103181:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103184:	89 04 24             	mov    %eax,(%esp)
c0103187:	e8 8f f7 ff ff       	call   c010291b <page2kva>
}
c010318c:	c9                   	leave  
c010318d:	c3                   	ret    

c010318e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010318e:	55                   	push   %ebp
c010318f:	89 e5                	mov    %esp,%ebp
c0103191:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103194:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103199:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010319c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01031a3:	77 23                	ja     c01031c8 <pmm_init+0x3a>
c01031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031ac:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c01031b3:	c0 
c01031b4:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01031bb:	00 
c01031bc:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01031c3:	e8 21 d2 ff ff       	call   c01003e9 <__panic>
c01031c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031cb:	05 00 00 00 40       	add    $0x40000000,%eax
c01031d0:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01031d5:	e8 9c f9 ff ff       	call   c0102b76 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01031da:	e8 81 fa ff ff       	call   c0102c60 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01031df:	e8 de 03 00 00       	call   c01035c2 <check_alloc_page>

    check_pgdir();
c01031e4:	e8 f8 03 00 00       	call   c01035e1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01031e9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031ee:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01031f4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031fc:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103203:	77 23                	ja     c0103228 <pmm_init+0x9a>
c0103205:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103208:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010320c:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0103213:	c0 
c0103214:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010321b:	00 
c010321c:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103223:	e8 c1 d1 ff ff       	call   c01003e9 <__panic>
c0103228:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010322b:	05 00 00 00 40       	add    $0x40000000,%eax
c0103230:	83 c8 03             	or     $0x3,%eax
c0103233:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103235:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010323a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103241:	00 
c0103242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103249:	00 
c010324a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103251:	38 
c0103252:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103259:	c0 
c010325a:	89 04 24             	mov    %eax,(%esp)
c010325d:	e8 e5 fd ff ff       	call   c0103047 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103262:	e8 26 f8 ff ff       	call   c0102a8d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103267:	e8 11 0a 00 00       	call   c0103c7d <check_boot_pgdir>

    print_pgdir();
c010326c:	e8 8a 0e 00 00       	call   c01040fb <print_pgdir>

}
c0103271:	90                   	nop
c0103272:	c9                   	leave  
c0103273:	c3                   	ret    

c0103274 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103274:	55                   	push   %ebp
c0103275:	89 e5                	mov    %esp,%ebp
c0103277:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep=&pgdir[PDX(la)];
c010327a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010327d:	c1 e8 16             	shr    $0x16,%eax
c0103280:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103287:	8b 45 08             	mov    0x8(%ebp),%eax
c010328a:	01 d0                	add    %edx,%eax
c010328c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P))
c010328f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103292:	8b 00                	mov    (%eax),%eax
c0103294:	83 e0 01             	and    $0x1,%eax
c0103297:	85 c0                	test   %eax,%eax
c0103299:	0f 85 af 00 00 00    	jne    c010334e <get_pte+0xda>
    {
       struct Page *page;
       if (!create || (page = alloc_page()) == NULL) {
c010329f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01032a3:	74 15                	je     c01032ba <get_pte+0x46>
c01032a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032ac:	e8 19 f9 ff ff       	call   c0102bca <alloc_pages>
c01032b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01032b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01032b8:	75 0a                	jne    c01032c4 <get_pte+0x50>
            return NULL;
c01032ba:	b8 00 00 00 00       	mov    $0x0,%eax
c01032bf:	e9 e7 00 00 00       	jmp    c01033ab <get_pte+0x137>
        }
       set_page_ref(page,1);
c01032c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032cb:	00 
c01032cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032cf:	89 04 24             	mov    %eax,(%esp)
c01032d2:	e8 f8 f6 ff ff       	call   c01029cf <set_page_ref>
       uintptr_t pa=page2pa(page);
c01032d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032da:	89 04 24             	mov    %eax,(%esp)
c01032dd:	e8 d4 f5 ff ff       	call   c01028b6 <page2pa>
c01032e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
       memset(KADDR(pa),0,PGSIZE);
c01032e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01032eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032ee:	c1 e8 0c             	shr    $0xc,%eax
c01032f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01032f4:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01032f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01032fc:	72 23                	jb     c0103321 <get_pte+0xad>
c01032fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103301:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103305:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c010330c:	c0 
c010330d:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c0103314:	00 
c0103315:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010331c:	e8 c8 d0 ff ff       	call   c01003e9 <__panic>
c0103321:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103324:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103329:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103330:	00 
c0103331:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103338:	00 
c0103339:	89 04 24             	mov    %eax,(%esp)
c010333c:	e8 40 23 00 00       	call   c0105681 <memset>
       *pdep= pa|PTE_P|PTE_W|PTE_U;
c0103341:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103344:	83 c8 07             	or     $0x7,%eax
c0103347:	89 c2                	mov    %eax,%edx
c0103349:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010334c:	89 10                	mov    %edx,(%eax)
    }
     return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010334e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103351:	8b 00                	mov    (%eax),%eax
c0103353:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103358:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010335b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010335e:	c1 e8 0c             	shr    $0xc,%eax
c0103361:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103364:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103369:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010336c:	72 23                	jb     c0103391 <get_pte+0x11d>
c010336e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103371:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103375:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c010337c:	c0 
c010337d:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
c0103384:	00 
c0103385:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010338c:	e8 58 d0 ff ff       	call   c01003e9 <__panic>
c0103391:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103394:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103399:	89 c2                	mov    %eax,%edx
c010339b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010339e:	c1 e8 0c             	shr    $0xc,%eax
c01033a1:	25 ff 03 00 00       	and    $0x3ff,%eax
c01033a6:	c1 e0 02             	shl    $0x2,%eax
c01033a9:	01 d0                	add    %edx,%eax

}
c01033ab:	c9                   	leave  
c01033ac:	c3                   	ret    

c01033ad <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01033ad:	55                   	push   %ebp
c01033ae:	89 e5                	mov    %esp,%ebp
c01033b0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01033b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01033ba:	00 
c01033bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01033c5:	89 04 24             	mov    %eax,(%esp)
c01033c8:	e8 a7 fe ff ff       	call   c0103274 <get_pte>
c01033cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01033d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01033d4:	74 08                	je     c01033de <get_page+0x31>
        *ptep_store = ptep;
c01033d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01033d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01033dc:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01033de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033e2:	74 1b                	je     c01033ff <get_page+0x52>
c01033e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e7:	8b 00                	mov    (%eax),%eax
c01033e9:	83 e0 01             	and    $0x1,%eax
c01033ec:	85 c0                	test   %eax,%eax
c01033ee:	74 0f                	je     c01033ff <get_page+0x52>
        return pte2page(*ptep);
c01033f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f3:	8b 00                	mov    (%eax),%eax
c01033f5:	89 04 24             	mov    %eax,(%esp)
c01033f8:	e8 72 f5 ff ff       	call   c010296f <pte2page>
c01033fd:	eb 05                	jmp    c0103404 <get_page+0x57>
    }
    return NULL;
c01033ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103404:	c9                   	leave  
c0103405:	c3                   	ret    

c0103406 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103406:	55                   	push   %ebp
c0103407:	89 e5                	mov    %esp,%ebp
c0103409:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if(*ptep & PTE_P)
c010340c:	8b 45 10             	mov    0x10(%ebp),%eax
c010340f:	8b 00                	mov    (%eax),%eax
c0103411:	83 e0 01             	and    $0x1,%eax
c0103414:	85 c0                	test   %eax,%eax
c0103416:	74 4d                	je     c0103465 <page_remove_pte+0x5f>
    {
        struct Page *page= pte2page(*ptep);
c0103418:	8b 45 10             	mov    0x10(%ebp),%eax
c010341b:	8b 00                	mov    (%eax),%eax
c010341d:	89 04 24             	mov    %eax,(%esp)
c0103420:	e8 4a f5 ff ff       	call   c010296f <pte2page>
c0103425:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0)
c0103428:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342b:	89 04 24             	mov    %eax,(%esp)
c010342e:	e8 c1 f5 ff ff       	call   c01029f4 <page_ref_dec>
c0103433:	85 c0                	test   %eax,%eax
c0103435:	75 13                	jne    c010344a <page_remove_pte+0x44>
       // if(i==0)
        {
           free_page(page);
c0103437:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010343e:	00 
c010343f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103442:	89 04 24             	mov    %eax,(%esp)
c0103445:	e8 b8 f7 ff ff       	call   c0102c02 <free_pages>
        }
        *ptep=0;
c010344a:	8b 45 10             	mov    0x10(%ebp),%eax
c010344d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0103453:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103456:	89 44 24 04          	mov    %eax,0x4(%esp)
c010345a:	8b 45 08             	mov    0x8(%ebp),%eax
c010345d:	89 04 24             	mov    %eax,(%esp)
c0103460:	e8 01 01 00 00       	call   c0103566 <tlb_invalidate>
    }
}
c0103465:	90                   	nop
c0103466:	c9                   	leave  
c0103467:	c3                   	ret    

c0103468 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103468:	55                   	push   %ebp
c0103469:	89 e5                	mov    %esp,%ebp
c010346b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010346e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103475:	00 
c0103476:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103479:	89 44 24 04          	mov    %eax,0x4(%esp)
c010347d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103480:	89 04 24             	mov    %eax,(%esp)
c0103483:	e8 ec fd ff ff       	call   c0103274 <get_pte>
c0103488:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010348b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010348f:	74 19                	je     c01034aa <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103491:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103494:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103498:	8b 45 0c             	mov    0xc(%ebp),%eax
c010349b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010349f:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a2:	89 04 24             	mov    %eax,(%esp)
c01034a5:	e8 5c ff ff ff       	call   c0103406 <page_remove_pte>
    }
}
c01034aa:	90                   	nop
c01034ab:	c9                   	leave  
c01034ac:	c3                   	ret    

c01034ad <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01034ad:	55                   	push   %ebp
c01034ae:	89 e5                	mov    %esp,%ebp
c01034b0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01034b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01034ba:	00 
c01034bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01034be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01034c5:	89 04 24             	mov    %eax,(%esp)
c01034c8:	e8 a7 fd ff ff       	call   c0103274 <get_pte>
c01034cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01034d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034d4:	75 0a                	jne    c01034e0 <page_insert+0x33>
        return -E_NO_MEM;
c01034d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01034db:	e9 84 00 00 00       	jmp    c0103564 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01034e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034e3:	89 04 24             	mov    %eax,(%esp)
c01034e6:	e8 f2 f4 ff ff       	call   c01029dd <page_ref_inc>
    if (*ptep & PTE_P) {
c01034eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ee:	8b 00                	mov    (%eax),%eax
c01034f0:	83 e0 01             	and    $0x1,%eax
c01034f3:	85 c0                	test   %eax,%eax
c01034f5:	74 3e                	je     c0103535 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01034f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034fa:	8b 00                	mov    (%eax),%eax
c01034fc:	89 04 24             	mov    %eax,(%esp)
c01034ff:	e8 6b f4 ff ff       	call   c010296f <pte2page>
c0103504:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103507:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010350a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010350d:	75 0d                	jne    c010351c <page_insert+0x6f>
            page_ref_dec(page);
c010350f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103512:	89 04 24             	mov    %eax,(%esp)
c0103515:	e8 da f4 ff ff       	call   c01029f4 <page_ref_dec>
c010351a:	eb 19                	jmp    c0103535 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010351c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010351f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103523:	8b 45 10             	mov    0x10(%ebp),%eax
c0103526:	89 44 24 04          	mov    %eax,0x4(%esp)
c010352a:	8b 45 08             	mov    0x8(%ebp),%eax
c010352d:	89 04 24             	mov    %eax,(%esp)
c0103530:	e8 d1 fe ff ff       	call   c0103406 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103538:	89 04 24             	mov    %eax,(%esp)
c010353b:	e8 76 f3 ff ff       	call   c01028b6 <page2pa>
c0103540:	0b 45 14             	or     0x14(%ebp),%eax
c0103543:	83 c8 01             	or     $0x1,%eax
c0103546:	89 c2                	mov    %eax,%edx
c0103548:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010354d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103550:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103554:	8b 45 08             	mov    0x8(%ebp),%eax
c0103557:	89 04 24             	mov    %eax,(%esp)
c010355a:	e8 07 00 00 00       	call   c0103566 <tlb_invalidate>
    return 0;
c010355f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103564:	c9                   	leave  
c0103565:	c3                   	ret    

c0103566 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103566:	55                   	push   %ebp
c0103567:	89 e5                	mov    %esp,%ebp
c0103569:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010356c:	0f 20 d8             	mov    %cr3,%eax
c010356f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0103572:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103575:	8b 45 08             	mov    0x8(%ebp),%eax
c0103578:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010357b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103582:	77 23                	ja     c01035a7 <tlb_invalidate+0x41>
c0103584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103587:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010358b:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0103592:	c0 
c0103593:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c010359a:	00 
c010359b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01035a2:	e8 42 ce ff ff       	call   c01003e9 <__panic>
c01035a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035aa:	05 00 00 00 40       	add    $0x40000000,%eax
c01035af:	39 c2                	cmp    %eax,%edx
c01035b1:	75 0c                	jne    c01035bf <tlb_invalidate+0x59>
        invlpg((void *)la);
c01035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01035b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035bc:	0f 01 38             	invlpg (%eax)
    }
}
c01035bf:	90                   	nop
c01035c0:	c9                   	leave  
c01035c1:	c3                   	ret    

c01035c2 <check_alloc_page>:

static void
check_alloc_page(void) {
c01035c2:	55                   	push   %ebp
c01035c3:	89 e5                	mov    %esp,%ebp
c01035c5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01035c8:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01035cd:	8b 40 18             	mov    0x18(%eax),%eax
c01035d0:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01035d2:	c7 04 24 e8 66 10 c0 	movl   $0xc01066e8,(%esp)
c01035d9:	e8 b4 cc ff ff       	call   c0100292 <cprintf>
}
c01035de:	90                   	nop
c01035df:	c9                   	leave  
c01035e0:	c3                   	ret    

c01035e1 <check_pgdir>:

static void
check_pgdir(void) {
c01035e1:	55                   	push   %ebp
c01035e2:	89 e5                	mov    %esp,%ebp
c01035e4:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01035e7:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01035ec:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01035f1:	76 24                	jbe    c0103617 <check_pgdir+0x36>
c01035f3:	c7 44 24 0c 07 67 10 	movl   $0xc0106707,0xc(%esp)
c01035fa:	c0 
c01035fb:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103602:	c0 
c0103603:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c010360a:	00 
c010360b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103612:	e8 d2 cd ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103617:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010361c:	85 c0                	test   %eax,%eax
c010361e:	74 0e                	je     c010362e <check_pgdir+0x4d>
c0103620:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103625:	25 ff 0f 00 00       	and    $0xfff,%eax
c010362a:	85 c0                	test   %eax,%eax
c010362c:	74 24                	je     c0103652 <check_pgdir+0x71>
c010362e:	c7 44 24 0c 24 67 10 	movl   $0xc0106724,0xc(%esp)
c0103635:	c0 
c0103636:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010363d:	c0 
c010363e:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103645:	00 
c0103646:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010364d:	e8 97 cd ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103652:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103657:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010365e:	00 
c010365f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103666:	00 
c0103667:	89 04 24             	mov    %eax,(%esp)
c010366a:	e8 3e fd ff ff       	call   c01033ad <get_page>
c010366f:	85 c0                	test   %eax,%eax
c0103671:	74 24                	je     c0103697 <check_pgdir+0xb6>
c0103673:	c7 44 24 0c 5c 67 10 	movl   $0xc010675c,0xc(%esp)
c010367a:	c0 
c010367b:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103682:	c0 
c0103683:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c010368a:	00 
c010368b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103692:	e8 52 cd ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010369e:	e8 27 f5 ff ff       	call   c0102bca <alloc_pages>
c01036a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01036a6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01036b2:	00 
c01036b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036ba:	00 
c01036bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036be:	89 54 24 04          	mov    %edx,0x4(%esp)
c01036c2:	89 04 24             	mov    %eax,(%esp)
c01036c5:	e8 e3 fd ff ff       	call   c01034ad <page_insert>
c01036ca:	85 c0                	test   %eax,%eax
c01036cc:	74 24                	je     c01036f2 <check_pgdir+0x111>
c01036ce:	c7 44 24 0c 84 67 10 	movl   $0xc0106784,0xc(%esp)
c01036d5:	c0 
c01036d6:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01036dd:	c0 
c01036de:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c01036e5:	00 
c01036e6:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01036ed:	e8 f7 cc ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01036f2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036fe:	00 
c01036ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103706:	00 
c0103707:	89 04 24             	mov    %eax,(%esp)
c010370a:	e8 65 fb ff ff       	call   c0103274 <get_pte>
c010370f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103712:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103716:	75 24                	jne    c010373c <check_pgdir+0x15b>
c0103718:	c7 44 24 0c b0 67 10 	movl   $0xc01067b0,0xc(%esp)
c010371f:	c0 
c0103720:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103727:	c0 
c0103728:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c010372f:	00 
c0103730:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103737:	e8 ad cc ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c010373c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010373f:	8b 00                	mov    (%eax),%eax
c0103741:	89 04 24             	mov    %eax,(%esp)
c0103744:	e8 26 f2 ff ff       	call   c010296f <pte2page>
c0103749:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010374c:	74 24                	je     c0103772 <check_pgdir+0x191>
c010374e:	c7 44 24 0c dd 67 10 	movl   $0xc01067dd,0xc(%esp)
c0103755:	c0 
c0103756:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010375d:	c0 
c010375e:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0103765:	00 
c0103766:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010376d:	e8 77 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c0103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103775:	89 04 24             	mov    %eax,(%esp)
c0103778:	e8 48 f2 ff ff       	call   c01029c5 <page_ref>
c010377d:	83 f8 01             	cmp    $0x1,%eax
c0103780:	74 24                	je     c01037a6 <check_pgdir+0x1c5>
c0103782:	c7 44 24 0c f3 67 10 	movl   $0xc01067f3,0xc(%esp)
c0103789:	c0 
c010378a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103791:	c0 
c0103792:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103799:	00 
c010379a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01037a1:	e8 43 cc ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01037a6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037ab:	8b 00                	mov    (%eax),%eax
c01037ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01037b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01037b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037b8:	c1 e8 0c             	shr    $0xc,%eax
c01037bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01037be:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01037c3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01037c6:	72 23                	jb     c01037eb <check_pgdir+0x20a>
c01037c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01037cf:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c01037d6:	c0 
c01037d7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01037de:	00 
c01037df:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01037e6:	e8 fe cb ff ff       	call   c01003e9 <__panic>
c01037eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ee:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01037f3:	83 c0 04             	add    $0x4,%eax
c01037f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01037f9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103805:	00 
c0103806:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010380d:	00 
c010380e:	89 04 24             	mov    %eax,(%esp)
c0103811:	e8 5e fa ff ff       	call   c0103274 <get_pte>
c0103816:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103819:	74 24                	je     c010383f <check_pgdir+0x25e>
c010381b:	c7 44 24 0c 08 68 10 	movl   $0xc0106808,0xc(%esp)
c0103822:	c0 
c0103823:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010382a:	c0 
c010382b:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103832:	00 
c0103833:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010383a:	e8 aa cb ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c010383f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103846:	e8 7f f3 ff ff       	call   c0102bca <alloc_pages>
c010384b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010384e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103853:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010385a:	00 
c010385b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103862:	00 
c0103863:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103866:	89 54 24 04          	mov    %edx,0x4(%esp)
c010386a:	89 04 24             	mov    %eax,(%esp)
c010386d:	e8 3b fc ff ff       	call   c01034ad <page_insert>
c0103872:	85 c0                	test   %eax,%eax
c0103874:	74 24                	je     c010389a <check_pgdir+0x2b9>
c0103876:	c7 44 24 0c 30 68 10 	movl   $0xc0106830,0xc(%esp)
c010387d:	c0 
c010387e:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103885:	c0 
c0103886:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c010388d:	00 
c010388e:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103895:	e8 4f cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010389a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010389f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038a6:	00 
c01038a7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01038ae:	00 
c01038af:	89 04 24             	mov    %eax,(%esp)
c01038b2:	e8 bd f9 ff ff       	call   c0103274 <get_pte>
c01038b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038be:	75 24                	jne    c01038e4 <check_pgdir+0x303>
c01038c0:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c01038c7:	c0 
c01038c8:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01038cf:	c0 
c01038d0:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01038d7:	00 
c01038d8:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01038df:	e8 05 cb ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c01038e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e7:	8b 00                	mov    (%eax),%eax
c01038e9:	83 e0 04             	and    $0x4,%eax
c01038ec:	85 c0                	test   %eax,%eax
c01038ee:	75 24                	jne    c0103914 <check_pgdir+0x333>
c01038f0:	c7 44 24 0c 98 68 10 	movl   $0xc0106898,0xc(%esp)
c01038f7:	c0 
c01038f8:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01038ff:	c0 
c0103900:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0103907:	00 
c0103908:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010390f:	e8 d5 ca ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c0103914:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103917:	8b 00                	mov    (%eax),%eax
c0103919:	83 e0 02             	and    $0x2,%eax
c010391c:	85 c0                	test   %eax,%eax
c010391e:	75 24                	jne    c0103944 <check_pgdir+0x363>
c0103920:	c7 44 24 0c a6 68 10 	movl   $0xc01068a6,0xc(%esp)
c0103927:	c0 
c0103928:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010392f:	c0 
c0103930:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103937:	00 
c0103938:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010393f:	e8 a5 ca ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103944:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103949:	8b 00                	mov    (%eax),%eax
c010394b:	83 e0 04             	and    $0x4,%eax
c010394e:	85 c0                	test   %eax,%eax
c0103950:	75 24                	jne    c0103976 <check_pgdir+0x395>
c0103952:	c7 44 24 0c b4 68 10 	movl   $0xc01068b4,0xc(%esp)
c0103959:	c0 
c010395a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103961:	c0 
c0103962:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103969:	00 
c010396a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103971:	e8 73 ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c0103976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103979:	89 04 24             	mov    %eax,(%esp)
c010397c:	e8 44 f0 ff ff       	call   c01029c5 <page_ref>
c0103981:	83 f8 01             	cmp    $0x1,%eax
c0103984:	74 24                	je     c01039aa <check_pgdir+0x3c9>
c0103986:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c010398d:	c0 
c010398e:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103995:	c0 
c0103996:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c010399d:	00 
c010399e:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01039a5:	e8 3f ca ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01039aa:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01039af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01039b6:	00 
c01039b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01039be:	00 
c01039bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01039c2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039c6:	89 04 24             	mov    %eax,(%esp)
c01039c9:	e8 df fa ff ff       	call   c01034ad <page_insert>
c01039ce:	85 c0                	test   %eax,%eax
c01039d0:	74 24                	je     c01039f6 <check_pgdir+0x415>
c01039d2:	c7 44 24 0c dc 68 10 	movl   $0xc01068dc,0xc(%esp)
c01039d9:	c0 
c01039da:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01039e1:	c0 
c01039e2:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c01039e9:	00 
c01039ea:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01039f1:	e8 f3 c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c01039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039f9:	89 04 24             	mov    %eax,(%esp)
c01039fc:	e8 c4 ef ff ff       	call   c01029c5 <page_ref>
c0103a01:	83 f8 02             	cmp    $0x2,%eax
c0103a04:	74 24                	je     c0103a2a <check_pgdir+0x449>
c0103a06:	c7 44 24 0c 08 69 10 	movl   $0xc0106908,0xc(%esp)
c0103a0d:	c0 
c0103a0e:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103a15:	c0 
c0103a16:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0103a1d:	00 
c0103a1e:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103a25:	e8 bf c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a2d:	89 04 24             	mov    %eax,(%esp)
c0103a30:	e8 90 ef ff ff       	call   c01029c5 <page_ref>
c0103a35:	85 c0                	test   %eax,%eax
c0103a37:	74 24                	je     c0103a5d <check_pgdir+0x47c>
c0103a39:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c0103a40:	c0 
c0103a41:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103a48:	c0 
c0103a49:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103a50:	00 
c0103a51:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103a58:	e8 8c c9 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a5d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a69:	00 
c0103a6a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a71:	00 
c0103a72:	89 04 24             	mov    %eax,(%esp)
c0103a75:	e8 fa f7 ff ff       	call   c0103274 <get_pte>
c0103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a81:	75 24                	jne    c0103aa7 <check_pgdir+0x4c6>
c0103a83:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c0103a8a:	c0 
c0103a8b:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103a92:	c0 
c0103a93:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103a9a:	00 
c0103a9b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103aa2:	e8 42 c9 ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103aaa:	8b 00                	mov    (%eax),%eax
c0103aac:	89 04 24             	mov    %eax,(%esp)
c0103aaf:	e8 bb ee ff ff       	call   c010296f <pte2page>
c0103ab4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ab7:	74 24                	je     c0103add <check_pgdir+0x4fc>
c0103ab9:	c7 44 24 0c dd 67 10 	movl   $0xc01067dd,0xc(%esp)
c0103ac0:	c0 
c0103ac1:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103ac8:	c0 
c0103ac9:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103ad0:	00 
c0103ad1:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103ad8:	e8 0c c9 ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103add:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ae0:	8b 00                	mov    (%eax),%eax
c0103ae2:	83 e0 04             	and    $0x4,%eax
c0103ae5:	85 c0                	test   %eax,%eax
c0103ae7:	74 24                	je     c0103b0d <check_pgdir+0x52c>
c0103ae9:	c7 44 24 0c 2c 69 10 	movl   $0xc010692c,0xc(%esp)
c0103af0:	c0 
c0103af1:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103af8:	c0 
c0103af9:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103b00:	00 
c0103b01:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103b08:	e8 dc c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103b0d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103b19:	00 
c0103b1a:	89 04 24             	mov    %eax,(%esp)
c0103b1d:	e8 46 f9 ff ff       	call   c0103468 <page_remove>
    assert(page_ref(p1) == 1);
c0103b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b25:	89 04 24             	mov    %eax,(%esp)
c0103b28:	e8 98 ee ff ff       	call   c01029c5 <page_ref>
c0103b2d:	83 f8 01             	cmp    $0x1,%eax
c0103b30:	74 24                	je     c0103b56 <check_pgdir+0x575>
c0103b32:	c7 44 24 0c f3 67 10 	movl   $0xc01067f3,0xc(%esp)
c0103b39:	c0 
c0103b3a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103b41:	c0 
c0103b42:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103b49:	00 
c0103b4a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103b51:	e8 93 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103b56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b59:	89 04 24             	mov    %eax,(%esp)
c0103b5c:	e8 64 ee ff ff       	call   c01029c5 <page_ref>
c0103b61:	85 c0                	test   %eax,%eax
c0103b63:	74 24                	je     c0103b89 <check_pgdir+0x5a8>
c0103b65:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c0103b6c:	c0 
c0103b6d:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103b74:	c0 
c0103b75:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103b7c:	00 
c0103b7d:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103b84:	e8 60 c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103b89:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b95:	00 
c0103b96:	89 04 24             	mov    %eax,(%esp)
c0103b99:	e8 ca f8 ff ff       	call   c0103468 <page_remove>
    assert(page_ref(p1) == 0);
c0103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ba1:	89 04 24             	mov    %eax,(%esp)
c0103ba4:	e8 1c ee ff ff       	call   c01029c5 <page_ref>
c0103ba9:	85 c0                	test   %eax,%eax
c0103bab:	74 24                	je     c0103bd1 <check_pgdir+0x5f0>
c0103bad:	c7 44 24 0c 41 69 10 	movl   $0xc0106941,0xc(%esp)
c0103bb4:	c0 
c0103bb5:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103bbc:	c0 
c0103bbd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103bc4:	00 
c0103bc5:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103bcc:	e8 18 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bd4:	89 04 24             	mov    %eax,(%esp)
c0103bd7:	e8 e9 ed ff ff       	call   c01029c5 <page_ref>
c0103bdc:	85 c0                	test   %eax,%eax
c0103bde:	74 24                	je     c0103c04 <check_pgdir+0x623>
c0103be0:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c0103be7:	c0 
c0103be8:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103bef:	c0 
c0103bf0:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103bf7:	00 
c0103bf8:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103bff:	e8 e5 c7 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103c04:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c09:	8b 00                	mov    (%eax),%eax
c0103c0b:	89 04 24             	mov    %eax,(%esp)
c0103c0e:	e8 9a ed ff ff       	call   c01029ad <pde2page>
c0103c13:	89 04 24             	mov    %eax,(%esp)
c0103c16:	e8 aa ed ff ff       	call   c01029c5 <page_ref>
c0103c1b:	83 f8 01             	cmp    $0x1,%eax
c0103c1e:	74 24                	je     c0103c44 <check_pgdir+0x663>
c0103c20:	c7 44 24 0c 54 69 10 	movl   $0xc0106954,0xc(%esp)
c0103c27:	c0 
c0103c28:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103c2f:	c0 
c0103c30:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103c37:	00 
c0103c38:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103c3f:	e8 a5 c7 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103c44:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c49:	8b 00                	mov    (%eax),%eax
c0103c4b:	89 04 24             	mov    %eax,(%esp)
c0103c4e:	e8 5a ed ff ff       	call   c01029ad <pde2page>
c0103c53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c5a:	00 
c0103c5b:	89 04 24             	mov    %eax,(%esp)
c0103c5e:	e8 9f ef ff ff       	call   c0102c02 <free_pages>
    boot_pgdir[0] = 0;
c0103c63:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103c6e:	c7 04 24 7b 69 10 c0 	movl   $0xc010697b,(%esp)
c0103c75:	e8 18 c6 ff ff       	call   c0100292 <cprintf>
}
c0103c7a:	90                   	nop
c0103c7b:	c9                   	leave  
c0103c7c:	c3                   	ret    

c0103c7d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103c7d:	55                   	push   %ebp
c0103c7e:	89 e5                	mov    %esp,%ebp
c0103c80:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103c83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c8a:	e9 ca 00 00 00       	jmp    c0103d59 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c98:	c1 e8 0c             	shr    $0xc,%eax
c0103c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c9e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103ca3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103ca6:	72 23                	jb     c0103ccb <check_boot_pgdir+0x4e>
c0103ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103caf:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c0103cb6:	c0 
c0103cb7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103cbe:	00 
c0103cbf:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103cc6:	e8 1e c7 ff ff       	call   c01003e9 <__panic>
c0103ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cce:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103cd3:	89 c2                	mov    %eax,%edx
c0103cd5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103cda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ce1:	00 
c0103ce2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ce6:	89 04 24             	mov    %eax,(%esp)
c0103ce9:	e8 86 f5 ff ff       	call   c0103274 <get_pte>
c0103cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103cf1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103cf5:	75 24                	jne    c0103d1b <check_boot_pgdir+0x9e>
c0103cf7:	c7 44 24 0c 98 69 10 	movl   $0xc0106998,0xc(%esp)
c0103cfe:	c0 
c0103cff:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103d06:	c0 
c0103d07:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103d0e:	00 
c0103d0f:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103d16:	e8 ce c6 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103d1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d1e:	8b 00                	mov    (%eax),%eax
c0103d20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d25:	89 c2                	mov    %eax,%edx
c0103d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d2a:	39 c2                	cmp    %eax,%edx
c0103d2c:	74 24                	je     c0103d52 <check_boot_pgdir+0xd5>
c0103d2e:	c7 44 24 0c d5 69 10 	movl   $0xc01069d5,0xc(%esp)
c0103d35:	c0 
c0103d36:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103d3d:	c0 
c0103d3e:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0103d45:	00 
c0103d46:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103d4d:	e8 97 c6 ff ff       	call   c01003e9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103d52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d5c:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103d61:	39 c2                	cmp    %eax,%edx
c0103d63:	0f 82 26 ff ff ff    	jb     c0103c8f <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103d69:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d6e:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d73:	8b 00                	mov    (%eax),%eax
c0103d75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d7a:	89 c2                	mov    %eax,%edx
c0103d7c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103d84:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103d8b:	77 23                	ja     c0103db0 <check_boot_pgdir+0x133>
c0103d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d94:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0103d9b:	c0 
c0103d9c:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0103da3:	00 
c0103da4:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103dab:	e8 39 c6 ff ff       	call   c01003e9 <__panic>
c0103db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103db3:	05 00 00 00 40       	add    $0x40000000,%eax
c0103db8:	39 c2                	cmp    %eax,%edx
c0103dba:	74 24                	je     c0103de0 <check_boot_pgdir+0x163>
c0103dbc:	c7 44 24 0c ec 69 10 	movl   $0xc01069ec,0xc(%esp)
c0103dc3:	c0 
c0103dc4:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103dcb:	c0 
c0103dcc:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0103dd3:	00 
c0103dd4:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103ddb:	e8 09 c6 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103de0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103de5:	8b 00                	mov    (%eax),%eax
c0103de7:	85 c0                	test   %eax,%eax
c0103de9:	74 24                	je     c0103e0f <check_boot_pgdir+0x192>
c0103deb:	c7 44 24 0c 20 6a 10 	movl   $0xc0106a20,0xc(%esp)
c0103df2:	c0 
c0103df3:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103dfa:	c0 
c0103dfb:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103e02:	00 
c0103e03:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103e0a:	e8 da c5 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103e0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e16:	e8 af ed ff ff       	call   c0102bca <alloc_pages>
c0103e1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103e1e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e23:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e2a:	00 
c0103e2b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103e32:	00 
c0103e33:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e3a:	89 04 24             	mov    %eax,(%esp)
c0103e3d:	e8 6b f6 ff ff       	call   c01034ad <page_insert>
c0103e42:	85 c0                	test   %eax,%eax
c0103e44:	74 24                	je     c0103e6a <check_boot_pgdir+0x1ed>
c0103e46:	c7 44 24 0c 34 6a 10 	movl   $0xc0106a34,0xc(%esp)
c0103e4d:	c0 
c0103e4e:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103e55:	c0 
c0103e56:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0103e5d:	00 
c0103e5e:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103e65:	e8 7f c5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103e6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e6d:	89 04 24             	mov    %eax,(%esp)
c0103e70:	e8 50 eb ff ff       	call   c01029c5 <page_ref>
c0103e75:	83 f8 01             	cmp    $0x1,%eax
c0103e78:	74 24                	je     c0103e9e <check_boot_pgdir+0x221>
c0103e7a:	c7 44 24 0c 62 6a 10 	movl   $0xc0106a62,0xc(%esp)
c0103e81:	c0 
c0103e82:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103e89:	c0 
c0103e8a:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0103e91:	00 
c0103e92:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103e99:	e8 4b c5 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103e9e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ea3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103eaa:	00 
c0103eab:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103eb2:	00 
c0103eb3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103eba:	89 04 24             	mov    %eax,(%esp)
c0103ebd:	e8 eb f5 ff ff       	call   c01034ad <page_insert>
c0103ec2:	85 c0                	test   %eax,%eax
c0103ec4:	74 24                	je     c0103eea <check_boot_pgdir+0x26d>
c0103ec6:	c7 44 24 0c 74 6a 10 	movl   $0xc0106a74,0xc(%esp)
c0103ecd:	c0 
c0103ece:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103ed5:	c0 
c0103ed6:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0103edd:	00 
c0103ede:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103ee5:	e8 ff c4 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eed:	89 04 24             	mov    %eax,(%esp)
c0103ef0:	e8 d0 ea ff ff       	call   c01029c5 <page_ref>
c0103ef5:	83 f8 02             	cmp    $0x2,%eax
c0103ef8:	74 24                	je     c0103f1e <check_boot_pgdir+0x2a1>
c0103efa:	c7 44 24 0c ab 6a 10 	movl   $0xc0106aab,0xc(%esp)
c0103f01:	c0 
c0103f02:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103f09:	c0 
c0103f0a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0103f11:	00 
c0103f12:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103f19:	e8 cb c4 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103f1e:	c7 45 dc bc 6a 10 c0 	movl   $0xc0106abc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103f25:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f2c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f33:	e8 7f 14 00 00       	call   c01053b7 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103f38:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103f3f:	00 
c0103f40:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f47:	e8 e2 14 00 00       	call   c010542e <strcmp>
c0103f4c:	85 c0                	test   %eax,%eax
c0103f4e:	74 24                	je     c0103f74 <check_boot_pgdir+0x2f7>
c0103f50:	c7 44 24 0c d4 6a 10 	movl   $0xc0106ad4,0xc(%esp)
c0103f57:	c0 
c0103f58:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103f5f:	c0 
c0103f60:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0103f67:	00 
c0103f68:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103f6f:	e8 75 c4 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f77:	89 04 24             	mov    %eax,(%esp)
c0103f7a:	e8 9c e9 ff ff       	call   c010291b <page2kva>
c0103f7f:	05 00 01 00 00       	add    $0x100,%eax
c0103f84:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103f87:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f8e:	e8 ce 13 00 00       	call   c0105361 <strlen>
c0103f93:	85 c0                	test   %eax,%eax
c0103f95:	74 24                	je     c0103fbb <check_boot_pgdir+0x33e>
c0103f97:	c7 44 24 0c 0c 6b 10 	movl   $0xc0106b0c,0xc(%esp)
c0103f9e:	c0 
c0103f9f:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103fa6:	c0 
c0103fa7:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0103fae:	00 
c0103faf:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103fb6:	e8 2e c4 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103fbb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fc2:	00 
c0103fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fc6:	89 04 24             	mov    %eax,(%esp)
c0103fc9:	e8 34 ec ff ff       	call   c0102c02 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103fce:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103fd3:	8b 00                	mov    (%eax),%eax
c0103fd5:	89 04 24             	mov    %eax,(%esp)
c0103fd8:	e8 d0 e9 ff ff       	call   c01029ad <pde2page>
c0103fdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fe4:	00 
c0103fe5:	89 04 24             	mov    %eax,(%esp)
c0103fe8:	e8 15 ec ff ff       	call   c0102c02 <free_pages>
    boot_pgdir[0] = 0;
c0103fed:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ff2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103ff8:	c7 04 24 30 6b 10 c0 	movl   $0xc0106b30,(%esp)
c0103fff:	e8 8e c2 ff ff       	call   c0100292 <cprintf>
}
c0104004:	90                   	nop
c0104005:	c9                   	leave  
c0104006:	c3                   	ret    

c0104007 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104007:	55                   	push   %ebp
c0104008:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010400a:	8b 45 08             	mov    0x8(%ebp),%eax
c010400d:	83 e0 04             	and    $0x4,%eax
c0104010:	85 c0                	test   %eax,%eax
c0104012:	74 04                	je     c0104018 <perm2str+0x11>
c0104014:	b0 75                	mov    $0x75,%al
c0104016:	eb 02                	jmp    c010401a <perm2str+0x13>
c0104018:	b0 2d                	mov    $0x2d,%al
c010401a:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c010401f:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104026:	8b 45 08             	mov    0x8(%ebp),%eax
c0104029:	83 e0 02             	and    $0x2,%eax
c010402c:	85 c0                	test   %eax,%eax
c010402e:	74 04                	je     c0104034 <perm2str+0x2d>
c0104030:	b0 77                	mov    $0x77,%al
c0104032:	eb 02                	jmp    c0104036 <perm2str+0x2f>
c0104034:	b0 2d                	mov    $0x2d,%al
c0104036:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c010403b:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0104042:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0104047:	5d                   	pop    %ebp
c0104048:	c3                   	ret    

c0104049 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104049:	55                   	push   %ebp
c010404a:	89 e5                	mov    %esp,%ebp
c010404c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010404f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104052:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104055:	72 0d                	jb     c0104064 <get_pgtable_items+0x1b>
        return 0;
c0104057:	b8 00 00 00 00       	mov    $0x0,%eax
c010405c:	e9 98 00 00 00       	jmp    c01040f9 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104061:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0104064:	8b 45 10             	mov    0x10(%ebp),%eax
c0104067:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010406a:	73 18                	jae    c0104084 <get_pgtable_items+0x3b>
c010406c:	8b 45 10             	mov    0x10(%ebp),%eax
c010406f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104076:	8b 45 14             	mov    0x14(%ebp),%eax
c0104079:	01 d0                	add    %edx,%eax
c010407b:	8b 00                	mov    (%eax),%eax
c010407d:	83 e0 01             	and    $0x1,%eax
c0104080:	85 c0                	test   %eax,%eax
c0104082:	74 dd                	je     c0104061 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0104084:	8b 45 10             	mov    0x10(%ebp),%eax
c0104087:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010408a:	73 68                	jae    c01040f4 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c010408c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104090:	74 08                	je     c010409a <get_pgtable_items+0x51>
            *left_store = start;
c0104092:	8b 45 18             	mov    0x18(%ebp),%eax
c0104095:	8b 55 10             	mov    0x10(%ebp),%edx
c0104098:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010409a:	8b 45 10             	mov    0x10(%ebp),%eax
c010409d:	8d 50 01             	lea    0x1(%eax),%edx
c01040a0:	89 55 10             	mov    %edx,0x10(%ebp)
c01040a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040aa:	8b 45 14             	mov    0x14(%ebp),%eax
c01040ad:	01 d0                	add    %edx,%eax
c01040af:	8b 00                	mov    (%eax),%eax
c01040b1:	83 e0 07             	and    $0x7,%eax
c01040b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01040b7:	eb 03                	jmp    c01040bc <get_pgtable_items+0x73>
            start ++;
c01040b9:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01040bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01040bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040c2:	73 1d                	jae    c01040e1 <get_pgtable_items+0x98>
c01040c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01040c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01040d1:	01 d0                	add    %edx,%eax
c01040d3:	8b 00                	mov    (%eax),%eax
c01040d5:	83 e0 07             	and    $0x7,%eax
c01040d8:	89 c2                	mov    %eax,%edx
c01040da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040dd:	39 c2                	cmp    %eax,%edx
c01040df:	74 d8                	je     c01040b9 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c01040e1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01040e5:	74 08                	je     c01040ef <get_pgtable_items+0xa6>
            *right_store = start;
c01040e7:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01040ea:	8b 55 10             	mov    0x10(%ebp),%edx
c01040ed:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01040ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040f2:	eb 05                	jmp    c01040f9 <get_pgtable_items+0xb0>
    }
    return 0;
c01040f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040f9:	c9                   	leave  
c01040fa:	c3                   	ret    

c01040fb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01040fb:	55                   	push   %ebp
c01040fc:	89 e5                	mov    %esp,%ebp
c01040fe:	57                   	push   %edi
c01040ff:	56                   	push   %esi
c0104100:	53                   	push   %ebx
c0104101:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104104:	c7 04 24 50 6b 10 c0 	movl   $0xc0106b50,(%esp)
c010410b:	e8 82 c1 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0104110:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104117:	e9 fa 00 00 00       	jmp    c0104216 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010411c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010411f:	89 04 24             	mov    %eax,(%esp)
c0104122:	e8 e0 fe ff ff       	call   c0104007 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104127:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010412a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010412d:	29 d1                	sub    %edx,%ecx
c010412f:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104131:	89 d6                	mov    %edx,%esi
c0104133:	c1 e6 16             	shl    $0x16,%esi
c0104136:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104139:	89 d3                	mov    %edx,%ebx
c010413b:	c1 e3 16             	shl    $0x16,%ebx
c010413e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104141:	89 d1                	mov    %edx,%ecx
c0104143:	c1 e1 16             	shl    $0x16,%ecx
c0104146:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104149:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010414c:	29 d7                	sub    %edx,%edi
c010414e:	89 fa                	mov    %edi,%edx
c0104150:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104154:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104158:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010415c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104160:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104164:	c7 04 24 81 6b 10 c0 	movl   $0xc0106b81,(%esp)
c010416b:	e8 22 c1 ff ff       	call   c0100292 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0104170:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104173:	c1 e0 0a             	shl    $0xa,%eax
c0104176:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104179:	eb 54                	jmp    c01041cf <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010417b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010417e:	89 04 24             	mov    %eax,(%esp)
c0104181:	e8 81 fe ff ff       	call   c0104007 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104186:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104189:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010418c:	29 d1                	sub    %edx,%ecx
c010418e:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104190:	89 d6                	mov    %edx,%esi
c0104192:	c1 e6 0c             	shl    $0xc,%esi
c0104195:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104198:	89 d3                	mov    %edx,%ebx
c010419a:	c1 e3 0c             	shl    $0xc,%ebx
c010419d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041a0:	89 d1                	mov    %edx,%ecx
c01041a2:	c1 e1 0c             	shl    $0xc,%ecx
c01041a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01041a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041ab:	29 d7                	sub    %edx,%edi
c01041ad:	89 fa                	mov    %edi,%edx
c01041af:	89 44 24 14          	mov    %eax,0x14(%esp)
c01041b3:	89 74 24 10          	mov    %esi,0x10(%esp)
c01041b7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01041bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01041bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01041c3:	c7 04 24 a0 6b 10 c0 	movl   $0xc0106ba0,(%esp)
c01041ca:	e8 c3 c0 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01041cf:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01041d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041da:	89 d3                	mov    %edx,%ebx
c01041dc:	c1 e3 0a             	shl    $0xa,%ebx
c01041df:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041e2:	89 d1                	mov    %edx,%ecx
c01041e4:	c1 e1 0a             	shl    $0xa,%ecx
c01041e7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01041ea:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041ee:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01041f1:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01041f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104201:	89 0c 24             	mov    %ecx,(%esp)
c0104204:	e8 40 fe ff ff       	call   c0104049 <get_pgtable_items>
c0104209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010420c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104210:	0f 85 65 ff ff ff    	jne    c010417b <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104216:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010421b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010421e:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104221:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104225:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104228:	89 54 24 10          	mov    %edx,0x10(%esp)
c010422c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104230:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104234:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010423b:	00 
c010423c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104243:	e8 01 fe ff ff       	call   c0104049 <get_pgtable_items>
c0104248:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010424b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010424f:	0f 85 c7 fe ff ff    	jne    c010411c <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104255:	c7 04 24 c4 6b 10 c0 	movl   $0xc0106bc4,(%esp)
c010425c:	e8 31 c0 ff ff       	call   c0100292 <cprintf>
}
c0104261:	90                   	nop
c0104262:	83 c4 4c             	add    $0x4c,%esp
c0104265:	5b                   	pop    %ebx
c0104266:	5e                   	pop    %esi
c0104267:	5f                   	pop    %edi
c0104268:	5d                   	pop    %ebp
c0104269:	c3                   	ret    

c010426a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010426a:	55                   	push   %ebp
c010426b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010426d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104270:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0104276:	29 d0                	sub    %edx,%eax
c0104278:	c1 f8 02             	sar    $0x2,%eax
c010427b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104281:	5d                   	pop    %ebp
c0104282:	c3                   	ret    

c0104283 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104283:	55                   	push   %ebp
c0104284:	89 e5                	mov    %esp,%ebp
c0104286:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104289:	8b 45 08             	mov    0x8(%ebp),%eax
c010428c:	89 04 24             	mov    %eax,(%esp)
c010428f:	e8 d6 ff ff ff       	call   c010426a <page2ppn>
c0104294:	c1 e0 0c             	shl    $0xc,%eax
}
c0104297:	c9                   	leave  
c0104298:	c3                   	ret    

c0104299 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104299:	55                   	push   %ebp
c010429a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010429c:	8b 45 08             	mov    0x8(%ebp),%eax
c010429f:	8b 00                	mov    (%eax),%eax
}
c01042a1:	5d                   	pop    %ebp
c01042a2:	c3                   	ret    

c01042a3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01042a3:	55                   	push   %ebp
c01042a4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01042a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01042a9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042ac:	89 10                	mov    %edx,(%eax)
}
c01042ae:	90                   	nop
c01042af:	5d                   	pop    %ebp
c01042b0:	c3                   	ret    

c01042b1 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01042b1:	55                   	push   %ebp
c01042b2:	89 e5                	mov    %esp,%ebp
c01042b4:	83 ec 10             	sub    $0x10,%esp
c01042b7:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01042be:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01042c4:	89 50 04             	mov    %edx,0x4(%eax)
c01042c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042ca:	8b 50 04             	mov    0x4(%eax),%edx
c01042cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042d0:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01042d2:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c01042d9:	00 00 00 
}
c01042dc:	90                   	nop
c01042dd:	c9                   	leave  
c01042de:	c3                   	ret    

c01042df <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01042df:	55                   	push   %ebp
c01042e0:	89 e5                	mov    %esp,%ebp
c01042e2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01042e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01042e9:	75 24                	jne    c010430f <default_init_memmap+0x30>
c01042eb:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c01042f2:	c0 
c01042f3:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01042fa:	c0 
c01042fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104302:	00 
c0104303:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010430a:	e8 da c0 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010430f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104312:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104315:	e9 de 00 00 00       	jmp    c01043f8 <default_init_memmap+0x119>
        assert(PageReserved(p));
c010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010431d:	83 c0 04             	add    $0x4,%eax
c0104320:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010432a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010432d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104330:	0f a3 10             	bt     %edx,(%eax)
c0104333:	19 c0                	sbb    %eax,%eax
c0104335:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0104338:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010433c:	0f 95 c0             	setne  %al
c010433f:	0f b6 c0             	movzbl %al,%eax
c0104342:	85 c0                	test   %eax,%eax
c0104344:	75 24                	jne    c010436a <default_init_memmap+0x8b>
c0104346:	c7 44 24 0c 29 6c 10 	movl   $0xc0106c29,0xc(%esp)
c010434d:	c0 
c010434e:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104355:	c0 
c0104356:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010435d:	00 
c010435e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104365:	e8 7f c0 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010436d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104377:	8b 50 08             	mov    0x8(%eax),%edx
c010437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010437d:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);
c0104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104383:	83 c0 04             	add    $0x4,%eax
c0104386:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c010438d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104390:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104393:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104396:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
c0104399:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01043a0:	00 
c01043a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043a4:	89 04 24             	mov    %eax,(%esp)
c01043a7:	e8 f7 fe ff ff       	call   c01042a3 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043af:	83 c0 0c             	add    $0xc,%eax
c01043b2:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
c01043b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01043bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043bf:	8b 00                	mov    (%eax),%eax
c01043c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043c4:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01043c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01043ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01043d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043d6:	89 10                	mov    %edx,(%eax)
c01043d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043db:	8b 10                	mov    (%eax),%edx
c01043dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043e9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01043ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043f2:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01043f4:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01043f8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01043fb:	89 d0                	mov    %edx,%eax
c01043fd:	c1 e0 02             	shl    $0x2,%eax
c0104400:	01 d0                	add    %edx,%eax
c0104402:	c1 e0 02             	shl    $0x2,%eax
c0104405:	89 c2                	mov    %eax,%edx
c0104407:	8b 45 08             	mov    0x8(%ebp),%eax
c010440a:	01 d0                	add    %edx,%eax
c010440c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010440f:	0f 85 05 ff ff ff    	jne    c010431a <default_init_memmap+0x3b>
        p->flags = p->property = 0;
        SetPageProperty(p);
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
c0104415:	8b 45 08             	mov    0x8(%ebp),%eax
c0104418:	8b 55 0c             	mov    0xc(%ebp),%edx
c010441b:	89 50 08             	mov    %edx,0x8(%eax)
   // SetPageProperty(base);
   // list_add_before(&free_list, &(p->page_link));
    nr_free += n;
c010441e:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c0104424:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104427:	01 d0                	add    %edx,%eax
c0104429:	a3 24 af 11 c0       	mov    %eax,0xc011af24
   // list_add(&free_list, &(base->page_link));
}
c010442e:	90                   	nop
c010442f:	c9                   	leave  
c0104430:	c3                   	ret    

c0104431 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104431:	55                   	push   %ebp
c0104432:	89 e5                	mov    %esp,%ebp
c0104434:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0104437:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010443b:	75 24                	jne    c0104461 <default_alloc_pages+0x30>
c010443d:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c0104444:	c0 
c0104445:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010444c:	c0 
c010444d:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0104454:	00 
c0104455:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010445c:	e8 88 bf ff ff       	call   c01003e9 <__panic>
    if (n > nr_free)     return NULL;
c0104461:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104466:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104469:	73 0a                	jae    c0104475 <default_alloc_pages+0x44>
c010446b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104470:	e9 04 01 00 00       	jmp    c0104579 <default_alloc_pages+0x148>
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
c0104475:	c7 45 f4 1c af 11 c0 	movl   $0xc011af1c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010447c:	e9 d7 00 00 00       	jmp    c0104558 <default_alloc_pages+0x127>
        struct Page *p = le2page(le, page_link);
c0104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104484:	83 e8 0c             	sub    $0xc,%eax
c0104487:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010448a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010448d:	8b 40 08             	mov    0x8(%eax),%eax
c0104490:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104493:	0f 82 bf 00 00 00    	jb     c0104558 <default_alloc_pages+0x127>
            list_entry_t *next;
            for(int i=0;i<n;i++)
c0104499:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01044a0:	eb 7b                	jmp    c010451d <default_alloc_pages+0xec>
            {
                 struct Page *page = le2page(le, page_link);
c01044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a5:	83 e8 0c             	sub    $0xc,%eax
c01044a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
                 SetPageReserved(page);
c01044ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044ae:	83 c0 04             	add    $0x4,%eax
c01044b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01044b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01044bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01044be:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01044c1:	0f ab 10             	bts    %edx,(%eax)
                 ClearPageProperty(page);
c01044c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044c7:	83 c0 04             	add    $0x4,%eax
c01044ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c01044d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01044d4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01044d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044da:	0f b3 10             	btr    %edx,(%eax)
c01044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01044e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044e6:	8b 40 04             	mov    0x4(%eax),%eax
                 next=list_next(le);
c01044e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01044ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01044f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01044f5:	8b 40 04             	mov    0x4(%eax),%eax
c01044f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01044fb:	8b 12                	mov    (%edx),%edx
c01044fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104500:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104503:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104506:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104509:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010450c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010450f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104512:	89 10                	mov    %edx,(%eax)
                 list_del(le);
                 le = next;
c0104514:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104517:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            list_entry_t *next;
            for(int i=0;i<n;i++)
c010451a:	ff 45 f0             	incl   -0x10(%ebp)
c010451d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104520:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104523:	0f 82 79 ff ff ff    	jb     c01044a2 <default_alloc_pages+0x71>
                 ClearPageProperty(page);
                 next=list_next(le);
                 list_del(le);
                 le = next;
            }
            if(p->property > n)
c0104529:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010452c:	8b 40 08             	mov    0x8(%eax),%eax
c010452f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104532:	76 12                	jbe    c0104546 <default_alloc_pages+0x115>
                 (le2page(le,page_link))->property = p->property - n;
c0104534:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104537:	8d 50 f4             	lea    -0xc(%eax),%edx
c010453a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010453d:	8b 40 08             	mov    0x8(%eax),%eax
c0104540:	2b 45 08             	sub    0x8(%ebp),%eax
c0104543:	89 42 08             	mov    %eax,0x8(%edx)
            nr_free -= n;
c0104546:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010454b:	2b 45 08             	sub    0x8(%ebp),%eax
c010454e:	a3 24 af 11 c0       	mov    %eax,0xc011af24
            return p;
c0104553:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104556:	eb 21                	jmp    c0104579 <default_alloc_pages+0x148>
c0104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010455b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010455e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104561:	8b 40 04             	mov    0x4(%eax),%eax
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free)     return NULL;
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104564:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104567:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c010456e:	0f 85 0d ff ff ff    	jne    c0104481 <default_alloc_pages+0x50>
    }
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    } */
    return NULL;
c0104574:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104579:	c9                   	leave  
c010457a:	c3                   	ret    

c010457b <default_free_pages>:
        le = list_next(le);
    } //insert,if the freeing block is before one free block
    list_add_before(le, &(base->page_link));//insert before le
}*/
static void
default_free_pages(struct Page *base, size_t n) {
c010457b:	55                   	push   %ebp
c010457c:	89 e5                	mov    %esp,%ebp
c010457e:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
c0104581:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104585:	75 24                	jne    c01045ab <default_free_pages+0x30>
c0104587:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c010458e:	c0 
c010458f:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104596:	c0 
c0104597:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010459e:	00 
c010459f:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01045a6:	e8 3e be ff ff       	call   c01003e9 <__panic>
    assert(PageReserved(base));
c01045ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ae:	83 c0 04             	add    $0x4,%eax
c01045b1:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
c01045b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01045be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01045c1:	0f a3 10             	bt     %edx,(%eax)
c01045c4:	19 c0                	sbb    %eax,%eax
c01045c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01045c9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01045cd:	0f 95 c0             	setne  %al
c01045d0:	0f b6 c0             	movzbl %al,%eax
c01045d3:	85 c0                	test   %eax,%eax
c01045d5:	75 24                	jne    c01045fb <default_free_pages+0x80>
c01045d7:	c7 44 24 0c 39 6c 10 	movl   $0xc0106c39,0xc(%esp)
c01045de:	c0 
c01045df:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01045e6:	c0 
c01045e7:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01045ee:	00 
c01045ef:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01045f6:	e8 ee bd ff ff       	call   c01003e9 <__panic>

    list_entry_t *le = &free_list;
c01045fb:	c7 45 f4 1c af 11 c0 	movl   $0xc011af1c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104602:	eb 0b                	jmp    c010460f <default_free_pages+0x94>
        if ((le2page(le, page_link)) > base) {
c0104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104607:	83 e8 0c             	sub    $0xc,%eax
c010460a:	3b 45 08             	cmp    0x8(%ebp),%eax
c010460d:	77 1a                	ja     c0104629 <default_free_pages+0xae>
c010460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104618:	8b 40 04             	mov    0x4(%eax),%eax
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010461b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010461e:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c0104625:	75 dd                	jne    c0104604 <default_free_pages+0x89>
c0104627:	eb 01                	jmp    c010462a <default_free_pages+0xaf>
        if ((le2page(le, page_link)) > base) {
            break;
c0104629:	90                   	nop
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
c010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104633:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0104636:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104639:	8b 00                	mov    (%eax),%eax
c010463b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    while ((last_head = list_prev(last_head)) != &free_list) {
c010463e:	eb 0d                	jmp    c010464d <default_free_pages+0xd2>
        if ((le2page(last_head, page_link))->property > 0) {
c0104640:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104643:	83 e8 0c             	sub    $0xc,%eax
c0104646:	8b 40 08             	mov    0x8(%eax),%eax
c0104649:	85 c0                	test   %eax,%eax
c010464b:	75 19                	jne    c0104666 <default_free_pages+0xeb>
c010464d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104650:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104653:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104656:	8b 00                	mov    (%eax),%eax
        if ((le2page(le, page_link)) > base) {
            break;
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
    while ((last_head = list_prev(last_head)) != &free_list) {
c0104658:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010465b:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c0104662:	75 dc                	jne    c0104640 <default_free_pages+0xc5>
c0104664:	eb 01                	jmp    c0104667 <default_free_pages+0xec>
        if ((le2page(last_head, page_link))->property > 0) {
            break;
c0104666:	90                   	nop
        }
    }

    struct Page *p = base, *block_header;
c0104667:	8b 45 08             	mov    0x8(%ebp),%eax
c010466a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    set_page_ref(base, 0);
c010466d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104674:	00 
c0104675:	8b 45 08             	mov    0x8(%ebp),%eax
c0104678:	89 04 24             	mov    %eax,(%esp)
c010467b:	e8 23 fc ff ff       	call   c01042a3 <set_page_ref>
    for (; p != base + n; ++p) {
c0104680:	e9 87 00 00 00       	jmp    c010470c <default_free_pages+0x191>
        ClearPageReserved(p);
c0104685:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104688:	83 c0 04             	add    $0x4,%eax
c010468b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0104692:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104695:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104698:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010469b:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
c010469e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046a1:	83 c0 04             	add    $0x4,%eax
c01046a4:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01046ab:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01046ae:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01046b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01046b4:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01046b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(le, &(p->page_link));
c01046c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046c4:	8d 50 0c             	lea    0xc(%eax),%edx
c01046c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01046cd:	89 55 b8             	mov    %edx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01046d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046d3:	8b 00                	mov    (%eax),%eax
c01046d5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01046d8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01046db:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01046de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046e1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01046e4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01046e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01046ea:	89 10                	mov    %edx,(%eax)
c01046ec:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01046ef:	8b 10                	mov    (%eax),%edx
c01046f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01046f4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046f7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01046fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01046fd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104700:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104703:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104706:	89 10                	mov    %edx,(%eax)
        }
    }

    struct Page *p = base, *block_header;
    set_page_ref(base, 0);
    for (; p != base + n; ++p) {
c0104708:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c010470c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010470f:	89 d0                	mov    %edx,%eax
c0104711:	c1 e0 02             	shl    $0x2,%eax
c0104714:	01 d0                	add    %edx,%eax
c0104716:	c1 e0 02             	shl    $0x2,%eax
c0104719:	89 c2                	mov    %eax,%edx
c010471b:	8b 45 08             	mov    0x8(%ebp),%eax
c010471e:	01 d0                	add    %edx,%eax
c0104720:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104723:	0f 85 5c ff ff ff    	jne    c0104685 <default_free_pages+0x10a>
        ClearPageReserved(p);
        SetPageProperty(p);
        p->property = 0;
        list_add_before(le, &(p->page_link));
    }
    if ((last_head == &free_list) || ((le2page(insert_prev, page_link)) != base - 1)) {
c0104729:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c0104730:	74 10                	je     c0104742 <default_free_pages+0x1c7>
c0104732:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104735:	8d 50 f4             	lea    -0xc(%eax),%edx
c0104738:	8b 45 08             	mov    0x8(%ebp),%eax
c010473b:	83 e8 14             	sub    $0x14,%eax
c010473e:	39 c2                	cmp    %eax,%edx
c0104740:	74 11                	je     c0104753 <default_free_pages+0x1d8>
        base->property = n;
c0104742:	8b 45 08             	mov    0x8(%ebp),%eax
c0104745:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104748:	89 50 08             	mov    %edx,0x8(%eax)
        block_header = base;
c010474b:	8b 45 08             	mov    0x8(%ebp),%eax
c010474e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104751:	eb 1a                	jmp    c010476d <default_free_pages+0x1f2>
    } else {
        block_header = le2page(last_head, page_link);
c0104753:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104756:	83 e8 0c             	sub    $0xc,%eax
c0104759:	89 45 e8             	mov    %eax,-0x18(%ebp)
        block_header->property += n;
c010475c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010475f:	8b 50 08             	mov    0x8(%eax),%edx
c0104762:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104765:	01 c2                	add    %eax,%edx
c0104767:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010476a:	89 50 08             	mov    %edx,0x8(%eax)
    }
    struct Page *le_page = le2page(le, page_link);
c010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104770:	83 e8 0c             	sub    $0xc,%eax
c0104773:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if ((le != &free_list) && (le_page == base + n)) {
c0104776:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c010477d:	74 37                	je     c01047b6 <default_free_pages+0x23b>
c010477f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104782:	89 d0                	mov    %edx,%eax
c0104784:	c1 e0 02             	shl    $0x2,%eax
c0104787:	01 d0                	add    %edx,%eax
c0104789:	c1 e0 02             	shl    $0x2,%eax
c010478c:	89 c2                	mov    %eax,%edx
c010478e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104791:	01 d0                	add    %edx,%eax
c0104793:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104796:	75 1e                	jne    c01047b6 <default_free_pages+0x23b>
        block_header->property += le_page->property;
c0104798:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010479b:	8b 50 08             	mov    0x8(%eax),%edx
c010479e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01047a1:	8b 40 08             	mov    0x8(%eax),%eax
c01047a4:	01 c2                	add    %eax,%edx
c01047a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047a9:	89 50 08             	mov    %edx,0x8(%eax)
        le_page->property = 0;
c01047ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01047af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    nr_free += n;
c01047b6:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047bf:	01 d0                	add    %edx,%eax
c01047c1:	a3 24 af 11 c0       	mov    %eax,0xc011af24
}
c01047c6:	90                   	nop
c01047c7:	c9                   	leave  
c01047c8:	c3                   	ret    

c01047c9 <default_nr_free_pages>:
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
}*/
static size_t
default_nr_free_pages(void) {
c01047c9:	55                   	push   %ebp
c01047ca:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01047cc:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c01047d1:	5d                   	pop    %ebp
c01047d2:	c3                   	ret    

c01047d3 <basic_check>:

static void
basic_check(void) {
c01047d3:	55                   	push   %ebp
c01047d4:	89 e5                	mov    %esp,%ebp
c01047d6:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01047d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01047ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047f3:	e8 d2 e3 ff ff       	call   c0102bca <alloc_pages>
c01047f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01047fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01047ff:	75 24                	jne    c0104825 <basic_check+0x52>
c0104801:	c7 44 24 0c 4c 6c 10 	movl   $0xc0106c4c,0xc(%esp)
c0104808:	c0 
c0104809:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104810:	c0 
c0104811:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104818:	00 
c0104819:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104820:	e8 c4 bb ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104825:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010482c:	e8 99 e3 ff ff       	call   c0102bca <alloc_pages>
c0104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104834:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104838:	75 24                	jne    c010485e <basic_check+0x8b>
c010483a:	c7 44 24 0c 68 6c 10 	movl   $0xc0106c68,0xc(%esp)
c0104841:	c0 
c0104842:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104849:	c0 
c010484a:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0104851:	00 
c0104852:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104859:	e8 8b bb ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010485e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104865:	e8 60 e3 ff ff       	call   c0102bca <alloc_pages>
c010486a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010486d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104871:	75 24                	jne    c0104897 <basic_check+0xc4>
c0104873:	c7 44 24 0c 84 6c 10 	movl   $0xc0106c84,0xc(%esp)
c010487a:	c0 
c010487b:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104882:	c0 
c0104883:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c010488a:	00 
c010488b:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104892:	e8 52 bb ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104897:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010489a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010489d:	74 10                	je     c01048af <basic_check+0xdc>
c010489f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048a5:	74 08                	je     c01048af <basic_check+0xdc>
c01048a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048aa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048ad:	75 24                	jne    c01048d3 <basic_check+0x100>
c01048af:	c7 44 24 0c a0 6c 10 	movl   $0xc0106ca0,0xc(%esp)
c01048b6:	c0 
c01048b7:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01048be:	c0 
c01048bf:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c01048c6:	00 
c01048c7:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01048ce:	e8 16 bb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01048d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048d6:	89 04 24             	mov    %eax,(%esp)
c01048d9:	e8 bb f9 ff ff       	call   c0104299 <page_ref>
c01048de:	85 c0                	test   %eax,%eax
c01048e0:	75 1e                	jne    c0104900 <basic_check+0x12d>
c01048e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048e5:	89 04 24             	mov    %eax,(%esp)
c01048e8:	e8 ac f9 ff ff       	call   c0104299 <page_ref>
c01048ed:	85 c0                	test   %eax,%eax
c01048ef:	75 0f                	jne    c0104900 <basic_check+0x12d>
c01048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f4:	89 04 24             	mov    %eax,(%esp)
c01048f7:	e8 9d f9 ff ff       	call   c0104299 <page_ref>
c01048fc:	85 c0                	test   %eax,%eax
c01048fe:	74 24                	je     c0104924 <basic_check+0x151>
c0104900:	c7 44 24 0c c4 6c 10 	movl   $0xc0106cc4,0xc(%esp)
c0104907:	c0 
c0104908:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010490f:	c0 
c0104910:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0104917:	00 
c0104918:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010491f:	e8 c5 ba ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104924:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104927:	89 04 24             	mov    %eax,(%esp)
c010492a:	e8 54 f9 ff ff       	call   c0104283 <page2pa>
c010492f:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104935:	c1 e2 0c             	shl    $0xc,%edx
c0104938:	39 d0                	cmp    %edx,%eax
c010493a:	72 24                	jb     c0104960 <basic_check+0x18d>
c010493c:	c7 44 24 0c 00 6d 10 	movl   $0xc0106d00,0xc(%esp)
c0104943:	c0 
c0104944:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010494b:	c0 
c010494c:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0104953:	00 
c0104954:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010495b:	e8 89 ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104960:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104963:	89 04 24             	mov    %eax,(%esp)
c0104966:	e8 18 f9 ff ff       	call   c0104283 <page2pa>
c010496b:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104971:	c1 e2 0c             	shl    $0xc,%edx
c0104974:	39 d0                	cmp    %edx,%eax
c0104976:	72 24                	jb     c010499c <basic_check+0x1c9>
c0104978:	c7 44 24 0c 1d 6d 10 	movl   $0xc0106d1d,0xc(%esp)
c010497f:	c0 
c0104980:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104987:	c0 
c0104988:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c010498f:	00 
c0104990:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104997:	e8 4d ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499f:	89 04 24             	mov    %eax,(%esp)
c01049a2:	e8 dc f8 ff ff       	call   c0104283 <page2pa>
c01049a7:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01049ad:	c1 e2 0c             	shl    $0xc,%edx
c01049b0:	39 d0                	cmp    %edx,%eax
c01049b2:	72 24                	jb     c01049d8 <basic_check+0x205>
c01049b4:	c7 44 24 0c 3a 6d 10 	movl   $0xc0106d3a,0xc(%esp)
c01049bb:	c0 
c01049bc:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01049c3:	c0 
c01049c4:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c01049cb:	00 
c01049cc:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01049d3:	e8 11 ba ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c01049d8:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c01049dd:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c01049e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01049e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01049e9:	c7 45 e4 1c af 11 c0 	movl   $0xc011af1c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01049f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01049f6:	89 50 04             	mov    %edx,0x4(%eax)
c01049f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049fc:	8b 50 04             	mov    0x4(%eax),%edx
c01049ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a02:	89 10                	mov    %edx,(%eax)
c0104a04:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104a0e:	8b 40 04             	mov    0x4(%eax),%eax
c0104a11:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104a14:	0f 94 c0             	sete   %al
c0104a17:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104a1a:	85 c0                	test   %eax,%eax
c0104a1c:	75 24                	jne    c0104a42 <basic_check+0x26f>
c0104a1e:	c7 44 24 0c 57 6d 10 	movl   $0xc0106d57,0xc(%esp)
c0104a25:	c0 
c0104a26:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104a2d:	c0 
c0104a2e:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c0104a35:	00 
c0104a36:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104a3d:	e8 a7 b9 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104a42:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104a47:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0104a4a:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104a51:	00 00 00 

    assert(alloc_page() == NULL);
c0104a54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a5b:	e8 6a e1 ff ff       	call   c0102bca <alloc_pages>
c0104a60:	85 c0                	test   %eax,%eax
c0104a62:	74 24                	je     c0104a88 <basic_check+0x2b5>
c0104a64:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0104a6b:	c0 
c0104a6c:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104a73:	c0 
c0104a74:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0104a7b:	00 
c0104a7c:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104a83:	e8 61 b9 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104a88:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a8f:	00 
c0104a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a93:	89 04 24             	mov    %eax,(%esp)
c0104a96:	e8 67 e1 ff ff       	call   c0102c02 <free_pages>
    free_page(p1);
c0104a9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104aa2:	00 
c0104aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa6:	89 04 24             	mov    %eax,(%esp)
c0104aa9:	e8 54 e1 ff ff       	call   c0102c02 <free_pages>
    free_page(p2);
c0104aae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ab5:	00 
c0104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ab9:	89 04 24             	mov    %eax,(%esp)
c0104abc:	e8 41 e1 ff ff       	call   c0102c02 <free_pages>
    assert(nr_free == 3);
c0104ac1:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104ac6:	83 f8 03             	cmp    $0x3,%eax
c0104ac9:	74 24                	je     c0104aef <basic_check+0x31c>
c0104acb:	c7 44 24 0c 83 6d 10 	movl   $0xc0106d83,0xc(%esp)
c0104ad2:	c0 
c0104ad3:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104ada:	c0 
c0104adb:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0104ae2:	00 
c0104ae3:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104aea:	e8 fa b8 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104af6:	e8 cf e0 ff ff       	call   c0102bca <alloc_pages>
c0104afb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104afe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b02:	75 24                	jne    c0104b28 <basic_check+0x355>
c0104b04:	c7 44 24 0c 4c 6c 10 	movl   $0xc0106c4c,0xc(%esp)
c0104b0b:	c0 
c0104b0c:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104b13:	c0 
c0104b14:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
c0104b1b:	00 
c0104b1c:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b23:	e8 c1 b8 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104b28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b2f:	e8 96 e0 ff ff       	call   c0102bca <alloc_pages>
c0104b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b3b:	75 24                	jne    c0104b61 <basic_check+0x38e>
c0104b3d:	c7 44 24 0c 68 6c 10 	movl   $0xc0106c68,0xc(%esp)
c0104b44:	c0 
c0104b45:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104b4c:	c0 
c0104b4d:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c0104b54:	00 
c0104b55:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b5c:	e8 88 b8 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b68:	e8 5d e0 ff ff       	call   c0102bca <alloc_pages>
c0104b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b74:	75 24                	jne    c0104b9a <basic_check+0x3c7>
c0104b76:	c7 44 24 0c 84 6c 10 	movl   $0xc0106c84,0xc(%esp)
c0104b7d:	c0 
c0104b7e:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104b85:	c0 
c0104b86:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0104b8d:	00 
c0104b8e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b95:	e8 4f b8 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104b9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ba1:	e8 24 e0 ff ff       	call   c0102bca <alloc_pages>
c0104ba6:	85 c0                	test   %eax,%eax
c0104ba8:	74 24                	je     c0104bce <basic_check+0x3fb>
c0104baa:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0104bb1:	c0 
c0104bb2:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104bb9:	c0 
c0104bba:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0104bc1:	00 
c0104bc2:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104bc9:	e8 1b b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104bce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bd5:	00 
c0104bd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bd9:	89 04 24             	mov    %eax,(%esp)
c0104bdc:	e8 21 e0 ff ff       	call   c0102c02 <free_pages>
c0104be1:	c7 45 e8 1c af 11 c0 	movl   $0xc011af1c,-0x18(%ebp)
c0104be8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104beb:	8b 40 04             	mov    0x4(%eax),%eax
c0104bee:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104bf1:	0f 94 c0             	sete   %al
c0104bf4:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104bf7:	85 c0                	test   %eax,%eax
c0104bf9:	74 24                	je     c0104c1f <basic_check+0x44c>
c0104bfb:	c7 44 24 0c 90 6d 10 	movl   $0xc0106d90,0xc(%esp)
c0104c02:	c0 
c0104c03:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104c0a:	c0 
c0104c0b:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c0104c12:	00 
c0104c13:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104c1a:	e8 ca b7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104c1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c26:	e8 9f df ff ff       	call   c0102bca <alloc_pages>
c0104c2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104c2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c31:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104c34:	74 24                	je     c0104c5a <basic_check+0x487>
c0104c36:	c7 44 24 0c a8 6d 10 	movl   $0xc0106da8,0xc(%esp)
c0104c3d:	c0 
c0104c3e:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104c45:	c0 
c0104c46:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
c0104c4d:	00 
c0104c4e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104c55:	e8 8f b7 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104c5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c61:	e8 64 df ff ff       	call   c0102bca <alloc_pages>
c0104c66:	85 c0                	test   %eax,%eax
c0104c68:	74 24                	je     c0104c8e <basic_check+0x4bb>
c0104c6a:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0104c71:	c0 
c0104c72:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104c79:	c0 
c0104c7a:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c0104c81:	00 
c0104c82:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104c89:	e8 5b b7 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104c8e:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104c93:	85 c0                	test   %eax,%eax
c0104c95:	74 24                	je     c0104cbb <basic_check+0x4e8>
c0104c97:	c7 44 24 0c c1 6d 10 	movl   $0xc0106dc1,0xc(%esp)
c0104c9e:	c0 
c0104c9f:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104ca6:	c0 
c0104ca7:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0104cae:	00 
c0104caf:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104cb6:	e8 2e b7 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104cbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cbe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104cc1:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104cc6:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c0104ccc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ccf:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104cd4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cdb:	00 
c0104cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104cdf:	89 04 24             	mov    %eax,(%esp)
c0104ce2:	e8 1b df ff ff       	call   c0102c02 <free_pages>
    free_page(p1);
c0104ce7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cee:	00 
c0104cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cf2:	89 04 24             	mov    %eax,(%esp)
c0104cf5:	e8 08 df ff ff       	call   c0102c02 <free_pages>
    free_page(p2);
c0104cfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d01:	00 
c0104d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d05:	89 04 24             	mov    %eax,(%esp)
c0104d08:	e8 f5 de ff ff       	call   c0102c02 <free_pages>
}
c0104d0d:	90                   	nop
c0104d0e:	c9                   	leave  
c0104d0f:	c3                   	ret    

c0104d10 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104d10:	55                   	push   %ebp
c0104d11:	89 e5                	mov    %esp,%ebp
c0104d13:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104d19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104d27:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104d2e:	eb 6a                	jmp    c0104d9a <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d33:	83 e8 0c             	sub    $0xc,%eax
c0104d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0104d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d3c:	83 c0 04             	add    $0x4,%eax
c0104d3f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104d46:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d49:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d4c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104d4f:	0f a3 10             	bt     %edx,(%eax)
c0104d52:	19 c0                	sbb    %eax,%eax
c0104d54:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104d57:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104d5b:	0f 95 c0             	setne  %al
c0104d5e:	0f b6 c0             	movzbl %al,%eax
c0104d61:	85 c0                	test   %eax,%eax
c0104d63:	75 24                	jne    c0104d89 <default_check+0x79>
c0104d65:	c7 44 24 0c ce 6d 10 	movl   $0xc0106dce,0xc(%esp)
c0104d6c:	c0 
c0104d6d:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104d74:	c0 
c0104d75:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c0104d7c:	00 
c0104d7d:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104d84:	e8 60 b6 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104d89:	ff 45 f4             	incl   -0xc(%ebp)
c0104d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d8f:	8b 50 08             	mov    0x8(%eax),%edx
c0104d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d95:	01 d0                	add    %edx,%eax
c0104d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104da3:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104da6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104da9:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104db0:	0f 85 7a ff ff ff    	jne    c0104d30 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104db6:	e8 7a de ff ff       	call   c0102c35 <nr_free_pages>
c0104dbb:	89 c2                	mov    %eax,%edx
c0104dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dc0:	39 c2                	cmp    %eax,%edx
c0104dc2:	74 24                	je     c0104de8 <default_check+0xd8>
c0104dc4:	c7 44 24 0c de 6d 10 	movl   $0xc0106dde,0xc(%esp)
c0104dcb:	c0 
c0104dcc:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104dd3:	c0 
c0104dd4:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c0104ddb:	00 
c0104ddc:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104de3:	e8 01 b6 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104de8:	e8 e6 f9 ff ff       	call   c01047d3 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104ded:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104df4:	e8 d1 dd ff ff       	call   c0102bca <alloc_pages>
c0104df9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0104dfc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104e00:	75 24                	jne    c0104e26 <default_check+0x116>
c0104e02:	c7 44 24 0c f7 6d 10 	movl   $0xc0106df7,0xc(%esp)
c0104e09:	c0 
c0104e0a:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c0104e19:	00 
c0104e1a:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104e21:	e8 c3 b5 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104e26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e29:	83 c0 04             	add    $0x4,%eax
c0104e2c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0104e33:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e36:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104e39:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104e3c:	0f a3 10             	bt     %edx,(%eax)
c0104e3f:	19 c0                	sbb    %eax,%eax
c0104e41:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104e44:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104e48:	0f 95 c0             	setne  %al
c0104e4b:	0f b6 c0             	movzbl %al,%eax
c0104e4e:	85 c0                	test   %eax,%eax
c0104e50:	74 24                	je     c0104e76 <default_check+0x166>
c0104e52:	c7 44 24 0c 02 6e 10 	movl   $0xc0106e02,0xc(%esp)
c0104e59:	c0 
c0104e5a:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104e61:	c0 
c0104e62:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
c0104e69:	00 
c0104e6a:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104e71:	e8 73 b5 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104e76:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104e7b:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104e81:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104e84:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104e87:	c7 45 d0 1c af 11 c0 	movl   $0xc011af1c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104e8e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e91:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104e94:	89 50 04             	mov    %edx,0x4(%eax)
c0104e97:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e9a:	8b 50 04             	mov    0x4(%eax),%edx
c0104e9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ea0:	89 10                	mov    %edx,(%eax)
c0104ea2:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104ea9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104eac:	8b 40 04             	mov    0x4(%eax),%eax
c0104eaf:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104eb2:	0f 94 c0             	sete   %al
c0104eb5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104eb8:	85 c0                	test   %eax,%eax
c0104eba:	75 24                	jne    c0104ee0 <default_check+0x1d0>
c0104ebc:	c7 44 24 0c 57 6d 10 	movl   $0xc0106d57,0xc(%esp)
c0104ec3:	c0 
c0104ec4:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104ecb:	c0 
c0104ecc:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0104ed3:	00 
c0104ed4:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104edb:	e8 09 b5 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ee0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ee7:	e8 de dc ff ff       	call   c0102bca <alloc_pages>
c0104eec:	85 c0                	test   %eax,%eax
c0104eee:	74 24                	je     c0104f14 <default_check+0x204>
c0104ef0:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0104ef7:	c0 
c0104ef8:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104eff:	c0 
c0104f00:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0104f07:	00 
c0104f08:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104f0f:	e8 d5 b4 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104f14:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104f19:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0104f1c:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104f23:	00 00 00 

    free_pages(p0 + 2, 3);
c0104f26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f29:	83 c0 28             	add    $0x28,%eax
c0104f2c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104f33:	00 
c0104f34:	89 04 24             	mov    %eax,(%esp)
c0104f37:	e8 c6 dc ff ff       	call   c0102c02 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104f3c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104f43:	e8 82 dc ff ff       	call   c0102bca <alloc_pages>
c0104f48:	85 c0                	test   %eax,%eax
c0104f4a:	74 24                	je     c0104f70 <default_check+0x260>
c0104f4c:	c7 44 24 0c 14 6e 10 	movl   $0xc0106e14,0xc(%esp)
c0104f53:	c0 
c0104f54:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104f5b:	c0 
c0104f5c:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c0104f63:	00 
c0104f64:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104f6b:	e8 79 b4 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104f70:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f73:	83 c0 28             	add    $0x28,%eax
c0104f76:	83 c0 04             	add    $0x4,%eax
c0104f79:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104f80:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104f83:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104f86:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f89:	0f a3 10             	bt     %edx,(%eax)
c0104f8c:	19 c0                	sbb    %eax,%eax
c0104f8e:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104f91:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104f95:	0f 95 c0             	setne  %al
c0104f98:	0f b6 c0             	movzbl %al,%eax
c0104f9b:	85 c0                	test   %eax,%eax
c0104f9d:	74 0e                	je     c0104fad <default_check+0x29d>
c0104f9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fa2:	83 c0 28             	add    $0x28,%eax
c0104fa5:	8b 40 08             	mov    0x8(%eax),%eax
c0104fa8:	83 f8 03             	cmp    $0x3,%eax
c0104fab:	74 24                	je     c0104fd1 <default_check+0x2c1>
c0104fad:	c7 44 24 0c 2c 6e 10 	movl   $0xc0106e2c,0xc(%esp)
c0104fb4:	c0 
c0104fb5:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104fbc:	c0 
c0104fbd:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0104fc4:	00 
c0104fc5:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104fcc:	e8 18 b4 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104fd1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104fd8:	e8 ed db ff ff       	call   c0102bca <alloc_pages>
c0104fdd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104fe0:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0104fe4:	75 24                	jne    c010500a <default_check+0x2fa>
c0104fe6:	c7 44 24 0c 58 6e 10 	movl   $0xc0106e58,0xc(%esp)
c0104fed:	c0 
c0104fee:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104ff5:	c0 
c0104ff6:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0104ffd:	00 
c0104ffe:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105005:	e8 df b3 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c010500a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105011:	e8 b4 db ff ff       	call   c0102bca <alloc_pages>
c0105016:	85 c0                	test   %eax,%eax
c0105018:	74 24                	je     c010503e <default_check+0x32e>
c010501a:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0105021:	c0 
c0105022:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105029:	c0 
c010502a:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c0105031:	00 
c0105032:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105039:	e8 ab b3 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c010503e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105041:	83 c0 28             	add    $0x28,%eax
c0105044:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0105047:	74 24                	je     c010506d <default_check+0x35d>
c0105049:	c7 44 24 0c 76 6e 10 	movl   $0xc0106e76,0xc(%esp)
c0105050:	c0 
c0105051:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105058:	c0 
c0105059:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c0105060:	00 
c0105061:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105068:	e8 7c b3 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c010506d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105070:	83 c0 14             	add    $0x14,%eax
c0105073:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0105076:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010507d:	00 
c010507e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105081:	89 04 24             	mov    %eax,(%esp)
c0105084:	e8 79 db ff ff       	call   c0102c02 <free_pages>
    free_pages(p1, 3);
c0105089:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105090:	00 
c0105091:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105094:	89 04 24             	mov    %eax,(%esp)
c0105097:	e8 66 db ff ff       	call   c0102c02 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010509c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010509f:	83 c0 04             	add    $0x4,%eax
c01050a2:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01050a9:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01050ac:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01050af:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01050b2:	0f a3 10             	bt     %edx,(%eax)
c01050b5:	19 c0                	sbb    %eax,%eax
c01050b7:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c01050ba:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c01050be:	0f 95 c0             	setne  %al
c01050c1:	0f b6 c0             	movzbl %al,%eax
c01050c4:	85 c0                	test   %eax,%eax
c01050c6:	74 0b                	je     c01050d3 <default_check+0x3c3>
c01050c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050cb:	8b 40 08             	mov    0x8(%eax),%eax
c01050ce:	83 f8 01             	cmp    $0x1,%eax
c01050d1:	74 24                	je     c01050f7 <default_check+0x3e7>
c01050d3:	c7 44 24 0c 84 6e 10 	movl   $0xc0106e84,0xc(%esp)
c01050da:	c0 
c01050db:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01050e2:	c0 
c01050e3:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c01050ea:	00 
c01050eb:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01050f2:	e8 f2 b2 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01050f7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01050fa:	83 c0 04             	add    $0x4,%eax
c01050fd:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105104:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105107:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010510a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010510d:	0f a3 10             	bt     %edx,(%eax)
c0105110:	19 c0                	sbb    %eax,%eax
c0105112:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0105115:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0105119:	0f 95 c0             	setne  %al
c010511c:	0f b6 c0             	movzbl %al,%eax
c010511f:	85 c0                	test   %eax,%eax
c0105121:	74 0b                	je     c010512e <default_check+0x41e>
c0105123:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105126:	8b 40 08             	mov    0x8(%eax),%eax
c0105129:	83 f8 03             	cmp    $0x3,%eax
c010512c:	74 24                	je     c0105152 <default_check+0x442>
c010512e:	c7 44 24 0c ac 6e 10 	movl   $0xc0106eac,0xc(%esp)
c0105135:	c0 
c0105136:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010513d:	c0 
c010513e:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
c0105145:	00 
c0105146:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010514d:	e8 97 b2 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105152:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105159:	e8 6c da ff ff       	call   c0102bca <alloc_pages>
c010515e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105161:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105164:	83 e8 14             	sub    $0x14,%eax
c0105167:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010516a:	74 24                	je     c0105190 <default_check+0x480>
c010516c:	c7 44 24 0c d2 6e 10 	movl   $0xc0106ed2,0xc(%esp)
c0105173:	c0 
c0105174:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010517b:	c0 
c010517c:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
c0105183:	00 
c0105184:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010518b:	e8 59 b2 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c0105190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105197:	00 
c0105198:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010519b:	89 04 24             	mov    %eax,(%esp)
c010519e:	e8 5f da ff ff       	call   c0102c02 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01051a3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01051aa:	e8 1b da ff ff       	call   c0102bca <alloc_pages>
c01051af:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01051b2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01051b5:	83 c0 14             	add    $0x14,%eax
c01051b8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01051bb:	74 24                	je     c01051e1 <default_check+0x4d1>
c01051bd:	c7 44 24 0c f0 6e 10 	movl   $0xc0106ef0,0xc(%esp)
c01051c4:	c0 
c01051c5:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01051cc:	c0 
c01051cd:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c01051d4:	00 
c01051d5:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01051dc:	e8 08 b2 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c01051e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01051e8:	00 
c01051e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051ec:	89 04 24             	mov    %eax,(%esp)
c01051ef:	e8 0e da ff ff       	call   c0102c02 <free_pages>
    free_page(p2);
c01051f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051fb:	00 
c01051fc:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01051ff:	89 04 24             	mov    %eax,(%esp)
c0105202:	e8 fb d9 ff ff       	call   c0102c02 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105207:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010520e:	e8 b7 d9 ff ff       	call   c0102bca <alloc_pages>
c0105213:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105216:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010521a:	75 24                	jne    c0105240 <default_check+0x530>
c010521c:	c7 44 24 0c 10 6f 10 	movl   $0xc0106f10,0xc(%esp)
c0105223:	c0 
c0105224:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010522b:	c0 
c010522c:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
c0105233:	00 
c0105234:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010523b:	e8 a9 b1 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105240:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105247:	e8 7e d9 ff ff       	call   c0102bca <alloc_pages>
c010524c:	85 c0                	test   %eax,%eax
c010524e:	74 24                	je     c0105274 <default_check+0x564>
c0105250:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c0105257:	c0 
c0105258:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010525f:	c0 
c0105260:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c0105267:	00 
c0105268:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010526f:	e8 75 b1 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0105274:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0105279:	85 c0                	test   %eax,%eax
c010527b:	74 24                	je     c01052a1 <default_check+0x591>
c010527d:	c7 44 24 0c c1 6d 10 	movl   $0xc0106dc1,0xc(%esp)
c0105284:	c0 
c0105285:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010528c:	c0 
c010528d:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
c0105294:	00 
c0105295:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010529c:	e8 48 b1 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c01052a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01052a4:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c01052a9:	8b 45 80             	mov    -0x80(%ebp),%eax
c01052ac:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01052af:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c01052b4:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c01052ba:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01052c1:	00 
c01052c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052c5:	89 04 24             	mov    %eax,(%esp)
c01052c8:	e8 35 d9 ff ff       	call   c0102c02 <free_pages>

    le = &free_list;
c01052cd:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01052d4:	eb 1c                	jmp    c01052f2 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c01052d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052d9:	83 e8 0c             	sub    $0xc,%eax
c01052dc:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c01052df:	ff 4d f4             	decl   -0xc(%ebp)
c01052e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01052e5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01052e8:	8b 40 08             	mov    0x8(%eax),%eax
c01052eb:	29 c2                	sub    %eax,%edx
c01052ed:	89 d0                	mov    %edx,%eax
c01052ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052f5:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01052f8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01052fb:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01052fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105301:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0105308:	75 cc                	jne    c01052d6 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010530a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010530e:	74 24                	je     c0105334 <default_check+0x624>
c0105310:	c7 44 24 0c 2e 6f 10 	movl   $0xc0106f2e,0xc(%esp)
c0105317:	c0 
c0105318:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010531f:	c0 
c0105320:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c0105327:	00 
c0105328:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010532f:	e8 b5 b0 ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c0105334:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105338:	74 24                	je     c010535e <default_check+0x64e>
c010533a:	c7 44 24 0c 39 6f 10 	movl   $0xc0106f39,0xc(%esp)
c0105341:	c0 
c0105342:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105349:	c0 
c010534a:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0105351:	00 
c0105352:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105359:	e8 8b b0 ff ff       	call   c01003e9 <__panic>
}
c010535e:	90                   	nop
c010535f:	c9                   	leave  
c0105360:	c3                   	ret    

c0105361 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105361:	55                   	push   %ebp
c0105362:	89 e5                	mov    %esp,%ebp
c0105364:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105367:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010536e:	eb 03                	jmp    c0105373 <strlen+0x12>
        cnt ++;
c0105370:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105373:	8b 45 08             	mov    0x8(%ebp),%eax
c0105376:	8d 50 01             	lea    0x1(%eax),%edx
c0105379:	89 55 08             	mov    %edx,0x8(%ebp)
c010537c:	0f b6 00             	movzbl (%eax),%eax
c010537f:	84 c0                	test   %al,%al
c0105381:	75 ed                	jne    c0105370 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105386:	c9                   	leave  
c0105387:	c3                   	ret    

c0105388 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105388:	55                   	push   %ebp
c0105389:	89 e5                	mov    %esp,%ebp
c010538b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010538e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105395:	eb 03                	jmp    c010539a <strnlen+0x12>
        cnt ++;
c0105397:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010539a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010539d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053a0:	73 10                	jae    c01053b2 <strnlen+0x2a>
c01053a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01053a5:	8d 50 01             	lea    0x1(%eax),%edx
c01053a8:	89 55 08             	mov    %edx,0x8(%ebp)
c01053ab:	0f b6 00             	movzbl (%eax),%eax
c01053ae:	84 c0                	test   %al,%al
c01053b0:	75 e5                	jne    c0105397 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c01053b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01053b5:	c9                   	leave  
c01053b6:	c3                   	ret    

c01053b7 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01053b7:	55                   	push   %ebp
c01053b8:	89 e5                	mov    %esp,%ebp
c01053ba:	57                   	push   %edi
c01053bb:	56                   	push   %esi
c01053bc:	83 ec 20             	sub    $0x20,%esp
c01053bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01053cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053d1:	89 d1                	mov    %edx,%ecx
c01053d3:	89 c2                	mov    %eax,%edx
c01053d5:	89 ce                	mov    %ecx,%esi
c01053d7:	89 d7                	mov    %edx,%edi
c01053d9:	ac                   	lods   %ds:(%esi),%al
c01053da:	aa                   	stos   %al,%es:(%edi)
c01053db:	84 c0                	test   %al,%al
c01053dd:	75 fa                	jne    c01053d9 <strcpy+0x22>
c01053df:	89 fa                	mov    %edi,%edx
c01053e1:	89 f1                	mov    %esi,%ecx
c01053e3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01053e6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01053e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01053ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01053ef:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01053f0:	83 c4 20             	add    $0x20,%esp
c01053f3:	5e                   	pop    %esi
c01053f4:	5f                   	pop    %edi
c01053f5:	5d                   	pop    %ebp
c01053f6:	c3                   	ret    

c01053f7 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01053f7:	55                   	push   %ebp
c01053f8:	89 e5                	mov    %esp,%ebp
c01053fa:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01053fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105400:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105403:	eb 1e                	jmp    c0105423 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105405:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105408:	0f b6 10             	movzbl (%eax),%edx
c010540b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010540e:	88 10                	mov    %dl,(%eax)
c0105410:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105413:	0f b6 00             	movzbl (%eax),%eax
c0105416:	84 c0                	test   %al,%al
c0105418:	74 03                	je     c010541d <strncpy+0x26>
            src ++;
c010541a:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010541d:	ff 45 fc             	incl   -0x4(%ebp)
c0105420:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105423:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105427:	75 dc                	jne    c0105405 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105429:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010542c:	c9                   	leave  
c010542d:	c3                   	ret    

c010542e <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010542e:	55                   	push   %ebp
c010542f:	89 e5                	mov    %esp,%ebp
c0105431:	57                   	push   %edi
c0105432:	56                   	push   %esi
c0105433:	83 ec 20             	sub    $0x20,%esp
c0105436:	8b 45 08             	mov    0x8(%ebp),%eax
c0105439:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010543c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010543f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105442:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105445:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105448:	89 d1                	mov    %edx,%ecx
c010544a:	89 c2                	mov    %eax,%edx
c010544c:	89 ce                	mov    %ecx,%esi
c010544e:	89 d7                	mov    %edx,%edi
c0105450:	ac                   	lods   %ds:(%esi),%al
c0105451:	ae                   	scas   %es:(%edi),%al
c0105452:	75 08                	jne    c010545c <strcmp+0x2e>
c0105454:	84 c0                	test   %al,%al
c0105456:	75 f8                	jne    c0105450 <strcmp+0x22>
c0105458:	31 c0                	xor    %eax,%eax
c010545a:	eb 04                	jmp    c0105460 <strcmp+0x32>
c010545c:	19 c0                	sbb    %eax,%eax
c010545e:	0c 01                	or     $0x1,%al
c0105460:	89 fa                	mov    %edi,%edx
c0105462:	89 f1                	mov    %esi,%ecx
c0105464:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105467:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010546a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010546d:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0105470:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105471:	83 c4 20             	add    $0x20,%esp
c0105474:	5e                   	pop    %esi
c0105475:	5f                   	pop    %edi
c0105476:	5d                   	pop    %ebp
c0105477:	c3                   	ret    

c0105478 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105478:	55                   	push   %ebp
c0105479:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010547b:	eb 09                	jmp    c0105486 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010547d:	ff 4d 10             	decl   0x10(%ebp)
c0105480:	ff 45 08             	incl   0x8(%ebp)
c0105483:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010548a:	74 1a                	je     c01054a6 <strncmp+0x2e>
c010548c:	8b 45 08             	mov    0x8(%ebp),%eax
c010548f:	0f b6 00             	movzbl (%eax),%eax
c0105492:	84 c0                	test   %al,%al
c0105494:	74 10                	je     c01054a6 <strncmp+0x2e>
c0105496:	8b 45 08             	mov    0x8(%ebp),%eax
c0105499:	0f b6 10             	movzbl (%eax),%edx
c010549c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010549f:	0f b6 00             	movzbl (%eax),%eax
c01054a2:	38 c2                	cmp    %al,%dl
c01054a4:	74 d7                	je     c010547d <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01054a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01054aa:	74 18                	je     c01054c4 <strncmp+0x4c>
c01054ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01054af:	0f b6 00             	movzbl (%eax),%eax
c01054b2:	0f b6 d0             	movzbl %al,%edx
c01054b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054b8:	0f b6 00             	movzbl (%eax),%eax
c01054bb:	0f b6 c0             	movzbl %al,%eax
c01054be:	29 c2                	sub    %eax,%edx
c01054c0:	89 d0                	mov    %edx,%eax
c01054c2:	eb 05                	jmp    c01054c9 <strncmp+0x51>
c01054c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054c9:	5d                   	pop    %ebp
c01054ca:	c3                   	ret    

c01054cb <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01054cb:	55                   	push   %ebp
c01054cc:	89 e5                	mov    %esp,%ebp
c01054ce:	83 ec 04             	sub    $0x4,%esp
c01054d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054d4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01054d7:	eb 13                	jmp    c01054ec <strchr+0x21>
        if (*s == c) {
c01054d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01054dc:	0f b6 00             	movzbl (%eax),%eax
c01054df:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01054e2:	75 05                	jne    c01054e9 <strchr+0x1e>
            return (char *)s;
c01054e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e7:	eb 12                	jmp    c01054fb <strchr+0x30>
        }
        s ++;
c01054e9:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c01054ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ef:	0f b6 00             	movzbl (%eax),%eax
c01054f2:	84 c0                	test   %al,%al
c01054f4:	75 e3                	jne    c01054d9 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c01054f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054fb:	c9                   	leave  
c01054fc:	c3                   	ret    

c01054fd <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01054fd:	55                   	push   %ebp
c01054fe:	89 e5                	mov    %esp,%ebp
c0105500:	83 ec 04             	sub    $0x4,%esp
c0105503:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105506:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105509:	eb 0e                	jmp    c0105519 <strfind+0x1c>
        if (*s == c) {
c010550b:	8b 45 08             	mov    0x8(%ebp),%eax
c010550e:	0f b6 00             	movzbl (%eax),%eax
c0105511:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105514:	74 0f                	je     c0105525 <strfind+0x28>
            break;
        }
        s ++;
c0105516:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105519:	8b 45 08             	mov    0x8(%ebp),%eax
c010551c:	0f b6 00             	movzbl (%eax),%eax
c010551f:	84 c0                	test   %al,%al
c0105521:	75 e8                	jne    c010550b <strfind+0xe>
c0105523:	eb 01                	jmp    c0105526 <strfind+0x29>
        if (*s == c) {
            break;
c0105525:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0105526:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105529:	c9                   	leave  
c010552a:	c3                   	ret    

c010552b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010552b:	55                   	push   %ebp
c010552c:	89 e5                	mov    %esp,%ebp
c010552e:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105531:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105538:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010553f:	eb 03                	jmp    c0105544 <strtol+0x19>
        s ++;
c0105541:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105544:	8b 45 08             	mov    0x8(%ebp),%eax
c0105547:	0f b6 00             	movzbl (%eax),%eax
c010554a:	3c 20                	cmp    $0x20,%al
c010554c:	74 f3                	je     c0105541 <strtol+0x16>
c010554e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105551:	0f b6 00             	movzbl (%eax),%eax
c0105554:	3c 09                	cmp    $0x9,%al
c0105556:	74 e9                	je     c0105541 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105558:	8b 45 08             	mov    0x8(%ebp),%eax
c010555b:	0f b6 00             	movzbl (%eax),%eax
c010555e:	3c 2b                	cmp    $0x2b,%al
c0105560:	75 05                	jne    c0105567 <strtol+0x3c>
        s ++;
c0105562:	ff 45 08             	incl   0x8(%ebp)
c0105565:	eb 14                	jmp    c010557b <strtol+0x50>
    }
    else if (*s == '-') {
c0105567:	8b 45 08             	mov    0x8(%ebp),%eax
c010556a:	0f b6 00             	movzbl (%eax),%eax
c010556d:	3c 2d                	cmp    $0x2d,%al
c010556f:	75 0a                	jne    c010557b <strtol+0x50>
        s ++, neg = 1;
c0105571:	ff 45 08             	incl   0x8(%ebp)
c0105574:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010557b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010557f:	74 06                	je     c0105587 <strtol+0x5c>
c0105581:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105585:	75 22                	jne    c01055a9 <strtol+0x7e>
c0105587:	8b 45 08             	mov    0x8(%ebp),%eax
c010558a:	0f b6 00             	movzbl (%eax),%eax
c010558d:	3c 30                	cmp    $0x30,%al
c010558f:	75 18                	jne    c01055a9 <strtol+0x7e>
c0105591:	8b 45 08             	mov    0x8(%ebp),%eax
c0105594:	40                   	inc    %eax
c0105595:	0f b6 00             	movzbl (%eax),%eax
c0105598:	3c 78                	cmp    $0x78,%al
c010559a:	75 0d                	jne    c01055a9 <strtol+0x7e>
        s += 2, base = 16;
c010559c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01055a0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01055a7:	eb 29                	jmp    c01055d2 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c01055a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055ad:	75 16                	jne    c01055c5 <strtol+0x9a>
c01055af:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b2:	0f b6 00             	movzbl (%eax),%eax
c01055b5:	3c 30                	cmp    $0x30,%al
c01055b7:	75 0c                	jne    c01055c5 <strtol+0x9a>
        s ++, base = 8;
c01055b9:	ff 45 08             	incl   0x8(%ebp)
c01055bc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01055c3:	eb 0d                	jmp    c01055d2 <strtol+0xa7>
    }
    else if (base == 0) {
c01055c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055c9:	75 07                	jne    c01055d2 <strtol+0xa7>
        base = 10;
c01055cb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01055d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d5:	0f b6 00             	movzbl (%eax),%eax
c01055d8:	3c 2f                	cmp    $0x2f,%al
c01055da:	7e 1b                	jle    c01055f7 <strtol+0xcc>
c01055dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01055df:	0f b6 00             	movzbl (%eax),%eax
c01055e2:	3c 39                	cmp    $0x39,%al
c01055e4:	7f 11                	jg     c01055f7 <strtol+0xcc>
            dig = *s - '0';
c01055e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e9:	0f b6 00             	movzbl (%eax),%eax
c01055ec:	0f be c0             	movsbl %al,%eax
c01055ef:	83 e8 30             	sub    $0x30,%eax
c01055f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055f5:	eb 48                	jmp    c010563f <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01055f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055fa:	0f b6 00             	movzbl (%eax),%eax
c01055fd:	3c 60                	cmp    $0x60,%al
c01055ff:	7e 1b                	jle    c010561c <strtol+0xf1>
c0105601:	8b 45 08             	mov    0x8(%ebp),%eax
c0105604:	0f b6 00             	movzbl (%eax),%eax
c0105607:	3c 7a                	cmp    $0x7a,%al
c0105609:	7f 11                	jg     c010561c <strtol+0xf1>
            dig = *s - 'a' + 10;
c010560b:	8b 45 08             	mov    0x8(%ebp),%eax
c010560e:	0f b6 00             	movzbl (%eax),%eax
c0105611:	0f be c0             	movsbl %al,%eax
c0105614:	83 e8 57             	sub    $0x57,%eax
c0105617:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010561a:	eb 23                	jmp    c010563f <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010561c:	8b 45 08             	mov    0x8(%ebp),%eax
c010561f:	0f b6 00             	movzbl (%eax),%eax
c0105622:	3c 40                	cmp    $0x40,%al
c0105624:	7e 3b                	jle    c0105661 <strtol+0x136>
c0105626:	8b 45 08             	mov    0x8(%ebp),%eax
c0105629:	0f b6 00             	movzbl (%eax),%eax
c010562c:	3c 5a                	cmp    $0x5a,%al
c010562e:	7f 31                	jg     c0105661 <strtol+0x136>
            dig = *s - 'A' + 10;
c0105630:	8b 45 08             	mov    0x8(%ebp),%eax
c0105633:	0f b6 00             	movzbl (%eax),%eax
c0105636:	0f be c0             	movsbl %al,%eax
c0105639:	83 e8 37             	sub    $0x37,%eax
c010563c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105642:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105645:	7d 19                	jge    c0105660 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0105647:	ff 45 08             	incl   0x8(%ebp)
c010564a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010564d:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105651:	89 c2                	mov    %eax,%edx
c0105653:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105656:	01 d0                	add    %edx,%eax
c0105658:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010565b:	e9 72 ff ff ff       	jmp    c01055d2 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c0105660:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105661:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105665:	74 08                	je     c010566f <strtol+0x144>
        *endptr = (char *) s;
c0105667:	8b 45 0c             	mov    0xc(%ebp),%eax
c010566a:	8b 55 08             	mov    0x8(%ebp),%edx
c010566d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010566f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105673:	74 07                	je     c010567c <strtol+0x151>
c0105675:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105678:	f7 d8                	neg    %eax
c010567a:	eb 03                	jmp    c010567f <strtol+0x154>
c010567c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010567f:	c9                   	leave  
c0105680:	c3                   	ret    

c0105681 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105681:	55                   	push   %ebp
c0105682:	89 e5                	mov    %esp,%ebp
c0105684:	57                   	push   %edi
c0105685:	83 ec 24             	sub    $0x24,%esp
c0105688:	8b 45 0c             	mov    0xc(%ebp),%eax
c010568b:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010568e:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105692:	8b 55 08             	mov    0x8(%ebp),%edx
c0105695:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105698:	88 45 f7             	mov    %al,-0x9(%ebp)
c010569b:	8b 45 10             	mov    0x10(%ebp),%eax
c010569e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01056a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01056a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01056a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01056ab:	89 d7                	mov    %edx,%edi
c01056ad:	f3 aa                	rep stos %al,%es:(%edi)
c01056af:	89 fa                	mov    %edi,%edx
c01056b1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01056b4:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01056b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056ba:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01056bb:	83 c4 24             	add    $0x24,%esp
c01056be:	5f                   	pop    %edi
c01056bf:	5d                   	pop    %ebp
c01056c0:	c3                   	ret    

c01056c1 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01056c1:	55                   	push   %ebp
c01056c2:	89 e5                	mov    %esp,%ebp
c01056c4:	57                   	push   %edi
c01056c5:	56                   	push   %esi
c01056c6:	53                   	push   %ebx
c01056c7:	83 ec 30             	sub    $0x30,%esp
c01056ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01056cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056d9:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01056dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01056e2:	73 42                	jae    c0105726 <memmove+0x65>
c01056e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01056f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01056f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056f9:	c1 e8 02             	shr    $0x2,%eax
c01056fc:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01056fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105701:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105704:	89 d7                	mov    %edx,%edi
c0105706:	89 c6                	mov    %eax,%esi
c0105708:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010570a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010570d:	83 e1 03             	and    $0x3,%ecx
c0105710:	74 02                	je     c0105714 <memmove+0x53>
c0105712:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105714:	89 f0                	mov    %esi,%eax
c0105716:	89 fa                	mov    %edi,%edx
c0105718:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010571b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010571e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0105724:	eb 36                	jmp    c010575c <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105726:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105729:	8d 50 ff             	lea    -0x1(%eax),%edx
c010572c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010572f:	01 c2                	add    %eax,%edx
c0105731:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105734:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105737:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010573a:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010573d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105740:	89 c1                	mov    %eax,%ecx
c0105742:	89 d8                	mov    %ebx,%eax
c0105744:	89 d6                	mov    %edx,%esi
c0105746:	89 c7                	mov    %eax,%edi
c0105748:	fd                   	std    
c0105749:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010574b:	fc                   	cld    
c010574c:	89 f8                	mov    %edi,%eax
c010574e:	89 f2                	mov    %esi,%edx
c0105750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105753:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105756:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105759:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010575c:	83 c4 30             	add    $0x30,%esp
c010575f:	5b                   	pop    %ebx
c0105760:	5e                   	pop    %esi
c0105761:	5f                   	pop    %edi
c0105762:	5d                   	pop    %ebp
c0105763:	c3                   	ret    

c0105764 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105764:	55                   	push   %ebp
c0105765:	89 e5                	mov    %esp,%ebp
c0105767:	57                   	push   %edi
c0105768:	56                   	push   %esi
c0105769:	83 ec 20             	sub    $0x20,%esp
c010576c:	8b 45 08             	mov    0x8(%ebp),%eax
c010576f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105772:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105775:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105778:	8b 45 10             	mov    0x10(%ebp),%eax
c010577b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010577e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105781:	c1 e8 02             	shr    $0x2,%eax
c0105784:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105786:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105789:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010578c:	89 d7                	mov    %edx,%edi
c010578e:	89 c6                	mov    %eax,%esi
c0105790:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105792:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105795:	83 e1 03             	and    $0x3,%ecx
c0105798:	74 02                	je     c010579c <memcpy+0x38>
c010579a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010579c:	89 f0                	mov    %esi,%eax
c010579e:	89 fa                	mov    %edi,%edx
c01057a0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01057a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01057a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01057a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c01057ac:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01057ad:	83 c4 20             	add    $0x20,%esp
c01057b0:	5e                   	pop    %esi
c01057b1:	5f                   	pop    %edi
c01057b2:	5d                   	pop    %ebp
c01057b3:	c3                   	ret    

c01057b4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01057b4:	55                   	push   %ebp
c01057b5:	89 e5                	mov    %esp,%ebp
c01057b7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01057ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01057bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01057c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01057c6:	eb 2e                	jmp    c01057f6 <memcmp+0x42>
        if (*s1 != *s2) {
c01057c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01057cb:	0f b6 10             	movzbl (%eax),%edx
c01057ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057d1:	0f b6 00             	movzbl (%eax),%eax
c01057d4:	38 c2                	cmp    %al,%dl
c01057d6:	74 18                	je     c01057f0 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01057d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01057db:	0f b6 00             	movzbl (%eax),%eax
c01057de:	0f b6 d0             	movzbl %al,%edx
c01057e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057e4:	0f b6 00             	movzbl (%eax),%eax
c01057e7:	0f b6 c0             	movzbl %al,%eax
c01057ea:	29 c2                	sub    %eax,%edx
c01057ec:	89 d0                	mov    %edx,%eax
c01057ee:	eb 18                	jmp    c0105808 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01057f0:	ff 45 fc             	incl   -0x4(%ebp)
c01057f3:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c01057f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01057f9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01057fc:	89 55 10             	mov    %edx,0x10(%ebp)
c01057ff:	85 c0                	test   %eax,%eax
c0105801:	75 c5                	jne    c01057c8 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105803:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105808:	c9                   	leave  
c0105809:	c3                   	ret    

c010580a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010580a:	55                   	push   %ebp
c010580b:	89 e5                	mov    %esp,%ebp
c010580d:	83 ec 58             	sub    $0x58,%esp
c0105810:	8b 45 10             	mov    0x10(%ebp),%eax
c0105813:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105816:	8b 45 14             	mov    0x14(%ebp),%eax
c0105819:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010581c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010581f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105822:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105825:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105828:	8b 45 18             	mov    0x18(%ebp),%eax
c010582b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010582e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105831:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105834:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105837:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010583a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010583d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105844:	74 1c                	je     c0105862 <printnum+0x58>
c0105846:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105849:	ba 00 00 00 00       	mov    $0x0,%edx
c010584e:	f7 75 e4             	divl   -0x1c(%ebp)
c0105851:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105854:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105857:	ba 00 00 00 00       	mov    $0x0,%edx
c010585c:	f7 75 e4             	divl   -0x1c(%ebp)
c010585f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105862:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105865:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105868:	f7 75 e4             	divl   -0x1c(%ebp)
c010586b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010586e:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105871:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105874:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105877:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010587a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010587d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105880:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105883:	8b 45 18             	mov    0x18(%ebp),%eax
c0105886:	ba 00 00 00 00       	mov    $0x0,%edx
c010588b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010588e:	77 56                	ja     c01058e6 <printnum+0xdc>
c0105890:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105893:	72 05                	jb     c010589a <printnum+0x90>
c0105895:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105898:	77 4c                	ja     c01058e6 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010589a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010589d:	8d 50 ff             	lea    -0x1(%eax),%edx
c01058a0:	8b 45 20             	mov    0x20(%ebp),%eax
c01058a3:	89 44 24 18          	mov    %eax,0x18(%esp)
c01058a7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01058ab:	8b 45 18             	mov    0x18(%ebp),%eax
c01058ae:	89 44 24 10          	mov    %eax,0x10(%esp)
c01058b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01058b8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ca:	89 04 24             	mov    %eax,(%esp)
c01058cd:	e8 38 ff ff ff       	call   c010580a <printnum>
c01058d2:	eb 1b                	jmp    c01058ef <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01058d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058db:	8b 45 20             	mov    0x20(%ebp),%eax
c01058de:	89 04 24             	mov    %eax,(%esp)
c01058e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e4:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01058e6:	ff 4d 1c             	decl   0x1c(%ebp)
c01058e9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01058ed:	7f e5                	jg     c01058d4 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01058ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058f2:	05 f4 6f 10 c0       	add    $0xc0106ff4,%eax
c01058f7:	0f b6 00             	movzbl (%eax),%eax
c01058fa:	0f be c0             	movsbl %al,%eax
c01058fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105900:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105904:	89 04 24             	mov    %eax,(%esp)
c0105907:	8b 45 08             	mov    0x8(%ebp),%eax
c010590a:	ff d0                	call   *%eax
}
c010590c:	90                   	nop
c010590d:	c9                   	leave  
c010590e:	c3                   	ret    

c010590f <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010590f:	55                   	push   %ebp
c0105910:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105912:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105916:	7e 14                	jle    c010592c <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105918:	8b 45 08             	mov    0x8(%ebp),%eax
c010591b:	8b 00                	mov    (%eax),%eax
c010591d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105920:	8b 55 08             	mov    0x8(%ebp),%edx
c0105923:	89 0a                	mov    %ecx,(%edx)
c0105925:	8b 50 04             	mov    0x4(%eax),%edx
c0105928:	8b 00                	mov    (%eax),%eax
c010592a:	eb 30                	jmp    c010595c <getuint+0x4d>
    }
    else if (lflag) {
c010592c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105930:	74 16                	je     c0105948 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105932:	8b 45 08             	mov    0x8(%ebp),%eax
c0105935:	8b 00                	mov    (%eax),%eax
c0105937:	8d 48 04             	lea    0x4(%eax),%ecx
c010593a:	8b 55 08             	mov    0x8(%ebp),%edx
c010593d:	89 0a                	mov    %ecx,(%edx)
c010593f:	8b 00                	mov    (%eax),%eax
c0105941:	ba 00 00 00 00       	mov    $0x0,%edx
c0105946:	eb 14                	jmp    c010595c <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105948:	8b 45 08             	mov    0x8(%ebp),%eax
c010594b:	8b 00                	mov    (%eax),%eax
c010594d:	8d 48 04             	lea    0x4(%eax),%ecx
c0105950:	8b 55 08             	mov    0x8(%ebp),%edx
c0105953:	89 0a                	mov    %ecx,(%edx)
c0105955:	8b 00                	mov    (%eax),%eax
c0105957:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010595c:	5d                   	pop    %ebp
c010595d:	c3                   	ret    

c010595e <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010595e:	55                   	push   %ebp
c010595f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105961:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105965:	7e 14                	jle    c010597b <getint+0x1d>
        return va_arg(*ap, long long);
c0105967:	8b 45 08             	mov    0x8(%ebp),%eax
c010596a:	8b 00                	mov    (%eax),%eax
c010596c:	8d 48 08             	lea    0x8(%eax),%ecx
c010596f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105972:	89 0a                	mov    %ecx,(%edx)
c0105974:	8b 50 04             	mov    0x4(%eax),%edx
c0105977:	8b 00                	mov    (%eax),%eax
c0105979:	eb 28                	jmp    c01059a3 <getint+0x45>
    }
    else if (lflag) {
c010597b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010597f:	74 12                	je     c0105993 <getint+0x35>
        return va_arg(*ap, long);
c0105981:	8b 45 08             	mov    0x8(%ebp),%eax
c0105984:	8b 00                	mov    (%eax),%eax
c0105986:	8d 48 04             	lea    0x4(%eax),%ecx
c0105989:	8b 55 08             	mov    0x8(%ebp),%edx
c010598c:	89 0a                	mov    %ecx,(%edx)
c010598e:	8b 00                	mov    (%eax),%eax
c0105990:	99                   	cltd   
c0105991:	eb 10                	jmp    c01059a3 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105993:	8b 45 08             	mov    0x8(%ebp),%eax
c0105996:	8b 00                	mov    (%eax),%eax
c0105998:	8d 48 04             	lea    0x4(%eax),%ecx
c010599b:	8b 55 08             	mov    0x8(%ebp),%edx
c010599e:	89 0a                	mov    %ecx,(%edx)
c01059a0:	8b 00                	mov    (%eax),%eax
c01059a2:	99                   	cltd   
    }
}
c01059a3:	5d                   	pop    %ebp
c01059a4:	c3                   	ret    

c01059a5 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01059a5:	55                   	push   %ebp
c01059a6:	89 e5                	mov    %esp,%ebp
c01059a8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01059ab:	8d 45 14             	lea    0x14(%ebp),%eax
c01059ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01059bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c9:	89 04 24             	mov    %eax,(%esp)
c01059cc:	e8 03 00 00 00       	call   c01059d4 <vprintfmt>
    va_end(ap);
}
c01059d1:	90                   	nop
c01059d2:	c9                   	leave  
c01059d3:	c3                   	ret    

c01059d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01059d4:	55                   	push   %ebp
c01059d5:	89 e5                	mov    %esp,%ebp
c01059d7:	56                   	push   %esi
c01059d8:	53                   	push   %ebx
c01059d9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059dc:	eb 17                	jmp    c01059f5 <vprintfmt+0x21>
            if (ch == '\0') {
c01059de:	85 db                	test   %ebx,%ebx
c01059e0:	0f 84 bf 03 00 00    	je     c0105da5 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01059e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ed:	89 1c 24             	mov    %ebx,(%esp)
c01059f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059f3:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01059f8:	8d 50 01             	lea    0x1(%eax),%edx
c01059fb:	89 55 10             	mov    %edx,0x10(%ebp)
c01059fe:	0f b6 00             	movzbl (%eax),%eax
c0105a01:	0f b6 d8             	movzbl %al,%ebx
c0105a04:	83 fb 25             	cmp    $0x25,%ebx
c0105a07:	75 d5                	jne    c01059de <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105a09:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105a0d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105a14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a17:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105a1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105a21:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a24:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105a27:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a2a:	8d 50 01             	lea    0x1(%eax),%edx
c0105a2d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a30:	0f b6 00             	movzbl (%eax),%eax
c0105a33:	0f b6 d8             	movzbl %al,%ebx
c0105a36:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105a39:	83 f8 55             	cmp    $0x55,%eax
c0105a3c:	0f 87 37 03 00 00    	ja     c0105d79 <vprintfmt+0x3a5>
c0105a42:	8b 04 85 18 70 10 c0 	mov    -0x3fef8fe8(,%eax,4),%eax
c0105a49:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105a4b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105a4f:	eb d6                	jmp    c0105a27 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105a51:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105a55:	eb d0                	jmp    c0105a27 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105a57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105a5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105a61:	89 d0                	mov    %edx,%eax
c0105a63:	c1 e0 02             	shl    $0x2,%eax
c0105a66:	01 d0                	add    %edx,%eax
c0105a68:	01 c0                	add    %eax,%eax
c0105a6a:	01 d8                	add    %ebx,%eax
c0105a6c:	83 e8 30             	sub    $0x30,%eax
c0105a6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105a72:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a75:	0f b6 00             	movzbl (%eax),%eax
c0105a78:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105a7b:	83 fb 2f             	cmp    $0x2f,%ebx
c0105a7e:	7e 38                	jle    c0105ab8 <vprintfmt+0xe4>
c0105a80:	83 fb 39             	cmp    $0x39,%ebx
c0105a83:	7f 33                	jg     c0105ab8 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105a85:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105a88:	eb d4                	jmp    c0105a5e <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105a8a:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a8d:	8d 50 04             	lea    0x4(%eax),%edx
c0105a90:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a93:	8b 00                	mov    (%eax),%eax
c0105a95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105a98:	eb 1f                	jmp    c0105ab9 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105a9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a9e:	79 87                	jns    c0105a27 <vprintfmt+0x53>
                width = 0;
c0105aa0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105aa7:	e9 7b ff ff ff       	jmp    c0105a27 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105aac:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105ab3:	e9 6f ff ff ff       	jmp    c0105a27 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0105ab8:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0105ab9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105abd:	0f 89 64 ff ff ff    	jns    c0105a27 <vprintfmt+0x53>
                width = precision, precision = -1;
c0105ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ac6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ac9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105ad0:	e9 52 ff ff ff       	jmp    c0105a27 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105ad5:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105ad8:	e9 4a ff ff ff       	jmp    c0105a27 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105add:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ae0:	8d 50 04             	lea    0x4(%eax),%edx
c0105ae3:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ae6:	8b 00                	mov    (%eax),%eax
c0105ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105aeb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105aef:	89 04 24             	mov    %eax,(%esp)
c0105af2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105af5:	ff d0                	call   *%eax
            break;
c0105af7:	e9 a4 02 00 00       	jmp    c0105da0 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105afc:	8b 45 14             	mov    0x14(%ebp),%eax
c0105aff:	8d 50 04             	lea    0x4(%eax),%edx
c0105b02:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b05:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105b07:	85 db                	test   %ebx,%ebx
c0105b09:	79 02                	jns    c0105b0d <vprintfmt+0x139>
                err = -err;
c0105b0b:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105b0d:	83 fb 06             	cmp    $0x6,%ebx
c0105b10:	7f 0b                	jg     c0105b1d <vprintfmt+0x149>
c0105b12:	8b 34 9d d8 6f 10 c0 	mov    -0x3fef9028(,%ebx,4),%esi
c0105b19:	85 f6                	test   %esi,%esi
c0105b1b:	75 23                	jne    c0105b40 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105b1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105b21:	c7 44 24 08 05 70 10 	movl   $0xc0107005,0x8(%esp)
c0105b28:	c0 
c0105b29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b33:	89 04 24             	mov    %eax,(%esp)
c0105b36:	e8 6a fe ff ff       	call   c01059a5 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105b3b:	e9 60 02 00 00       	jmp    c0105da0 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105b40:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105b44:	c7 44 24 08 0e 70 10 	movl   $0xc010700e,0x8(%esp)
c0105b4b:	c0 
c0105b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b56:	89 04 24             	mov    %eax,(%esp)
c0105b59:	e8 47 fe ff ff       	call   c01059a5 <printfmt>
            }
            break;
c0105b5e:	e9 3d 02 00 00       	jmp    c0105da0 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105b63:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b66:	8d 50 04             	lea    0x4(%eax),%edx
c0105b69:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b6c:	8b 30                	mov    (%eax),%esi
c0105b6e:	85 f6                	test   %esi,%esi
c0105b70:	75 05                	jne    c0105b77 <vprintfmt+0x1a3>
                p = "(null)";
c0105b72:	be 11 70 10 c0       	mov    $0xc0107011,%esi
            }
            if (width > 0 && padc != '-') {
c0105b77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b7b:	7e 76                	jle    c0105bf3 <vprintfmt+0x21f>
c0105b7d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105b81:	74 70                	je     c0105bf3 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b8a:	89 34 24             	mov    %esi,(%esp)
c0105b8d:	e8 f6 f7 ff ff       	call   c0105388 <strnlen>
c0105b92:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105b95:	29 c2                	sub    %eax,%edx
c0105b97:	89 d0                	mov    %edx,%eax
c0105b99:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b9c:	eb 16                	jmp    c0105bb4 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105b9e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ba5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ba9:	89 04 24             	mov    %eax,(%esp)
c0105bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0105baf:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105bb1:	ff 4d e8             	decl   -0x18(%ebp)
c0105bb4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105bb8:	7f e4                	jg     c0105b9e <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105bba:	eb 37                	jmp    c0105bf3 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105bbc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105bc0:	74 1f                	je     c0105be1 <vprintfmt+0x20d>
c0105bc2:	83 fb 1f             	cmp    $0x1f,%ebx
c0105bc5:	7e 05                	jle    c0105bcc <vprintfmt+0x1f8>
c0105bc7:	83 fb 7e             	cmp    $0x7e,%ebx
c0105bca:	7e 15                	jle    c0105be1 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bd3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105bda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bdd:	ff d0                	call   *%eax
c0105bdf:	eb 0f                	jmp    c0105bf0 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105be1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105be4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105be8:	89 1c 24             	mov    %ebx,(%esp)
c0105beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bee:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105bf0:	ff 4d e8             	decl   -0x18(%ebp)
c0105bf3:	89 f0                	mov    %esi,%eax
c0105bf5:	8d 70 01             	lea    0x1(%eax),%esi
c0105bf8:	0f b6 00             	movzbl (%eax),%eax
c0105bfb:	0f be d8             	movsbl %al,%ebx
c0105bfe:	85 db                	test   %ebx,%ebx
c0105c00:	74 27                	je     c0105c29 <vprintfmt+0x255>
c0105c02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c06:	78 b4                	js     c0105bbc <vprintfmt+0x1e8>
c0105c08:	ff 4d e4             	decl   -0x1c(%ebp)
c0105c0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c0f:	79 ab                	jns    c0105bbc <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105c11:	eb 16                	jmp    c0105c29 <vprintfmt+0x255>
                putch(' ', putdat);
c0105c13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c1a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105c21:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c24:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105c26:	ff 4d e8             	decl   -0x18(%ebp)
c0105c29:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c2d:	7f e4                	jg     c0105c13 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0105c2f:	e9 6c 01 00 00       	jmp    c0105da0 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105c34:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c3b:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c3e:	89 04 24             	mov    %eax,(%esp)
c0105c41:	e8 18 fd ff ff       	call   c010595e <getint>
c0105c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c49:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c52:	85 d2                	test   %edx,%edx
c0105c54:	79 26                	jns    c0105c7c <vprintfmt+0x2a8>
                putch('-', putdat);
c0105c56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c5d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105c64:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c67:	ff d0                	call   *%eax
                num = -(long long)num;
c0105c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c6f:	f7 d8                	neg    %eax
c0105c71:	83 d2 00             	adc    $0x0,%edx
c0105c74:	f7 da                	neg    %edx
c0105c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c79:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105c7c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105c83:	e9 a8 00 00 00       	jmp    c0105d30 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c8f:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c92:	89 04 24             	mov    %eax,(%esp)
c0105c95:	e8 75 fc ff ff       	call   c010590f <getuint>
c0105c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c9d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105ca0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105ca7:	e9 84 00 00 00       	jmp    c0105d30 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105caf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb3:	8d 45 14             	lea    0x14(%ebp),%eax
c0105cb6:	89 04 24             	mov    %eax,(%esp)
c0105cb9:	e8 51 fc ff ff       	call   c010590f <getuint>
c0105cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cc1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105cc4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105ccb:	eb 63                	jmp    c0105d30 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cd4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105cdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cde:	ff d0                	call   *%eax
            putch('x', putdat);
c0105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ce7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf1:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105cf3:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cf6:	8d 50 04             	lea    0x4(%eax),%edx
c0105cf9:	89 55 14             	mov    %edx,0x14(%ebp)
c0105cfc:	8b 00                	mov    (%eax),%eax
c0105cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105d08:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105d0f:	eb 1f                	jmp    c0105d30 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d18:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d1b:	89 04 24             	mov    %eax,(%esp)
c0105d1e:	e8 ec fb ff ff       	call   c010590f <getuint>
c0105d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d26:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105d29:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105d30:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d37:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105d3b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105d3e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105d42:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105d54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5e:	89 04 24             	mov    %eax,(%esp)
c0105d61:	e8 a4 fa ff ff       	call   c010580a <printnum>
            break;
c0105d66:	eb 38                	jmp    c0105da0 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105d68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d6f:	89 1c 24             	mov    %ebx,(%esp)
c0105d72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d75:	ff d0                	call   *%eax
            break;
c0105d77:	eb 27                	jmp    c0105da0 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105d79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d80:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105d87:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8a:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105d8c:	ff 4d 10             	decl   0x10(%ebp)
c0105d8f:	eb 03                	jmp    c0105d94 <vprintfmt+0x3c0>
c0105d91:	ff 4d 10             	decl   0x10(%ebp)
c0105d94:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d97:	48                   	dec    %eax
c0105d98:	0f b6 00             	movzbl (%eax),%eax
c0105d9b:	3c 25                	cmp    $0x25,%al
c0105d9d:	75 f2                	jne    c0105d91 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105d9f:	90                   	nop
        }
    }
c0105da0:	e9 37 fc ff ff       	jmp    c01059dc <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0105da5:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105da6:	83 c4 40             	add    $0x40,%esp
c0105da9:	5b                   	pop    %ebx
c0105daa:	5e                   	pop    %esi
c0105dab:	5d                   	pop    %ebp
c0105dac:	c3                   	ret    

c0105dad <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105dad:	55                   	push   %ebp
c0105dae:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105db0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db3:	8b 40 08             	mov    0x8(%eax),%eax
c0105db6:	8d 50 01             	lea    0x1(%eax),%edx
c0105db9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dbc:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc2:	8b 10                	mov    (%eax),%edx
c0105dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc7:	8b 40 04             	mov    0x4(%eax),%eax
c0105dca:	39 c2                	cmp    %eax,%edx
c0105dcc:	73 12                	jae    c0105de0 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105dce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dd1:	8b 00                	mov    (%eax),%eax
c0105dd3:	8d 48 01             	lea    0x1(%eax),%ecx
c0105dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105dd9:	89 0a                	mov    %ecx,(%edx)
c0105ddb:	8b 55 08             	mov    0x8(%ebp),%edx
c0105dde:	88 10                	mov    %dl,(%eax)
    }
}
c0105de0:	90                   	nop
c0105de1:	5d                   	pop    %ebp
c0105de2:	c3                   	ret    

c0105de3 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105de3:	55                   	push   %ebp
c0105de4:	89 e5                	mov    %esp,%ebp
c0105de6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105de9:	8d 45 14             	lea    0x14(%ebp),%eax
c0105dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105df6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105df9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e07:	89 04 24             	mov    %eax,(%esp)
c0105e0a:	e8 08 00 00 00       	call   c0105e17 <vsnprintf>
c0105e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e15:	c9                   	leave  
c0105e16:	c3                   	ret    

c0105e17 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105e17:	55                   	push   %ebp
c0105e18:	89 e5                	mov    %esp,%ebp
c0105e1a:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e20:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e26:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e29:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e2c:	01 d0                	add    %edx,%eax
c0105e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105e38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105e3c:	74 0a                	je     c0105e48 <vsnprintf+0x31>
c0105e3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e44:	39 c2                	cmp    %eax,%edx
c0105e46:	76 07                	jbe    c0105e4f <vsnprintf+0x38>
        return -E_INVAL;
c0105e48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105e4d:	eb 2a                	jmp    c0105e79 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105e4f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e56:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e59:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105e60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e64:	c7 04 24 ad 5d 10 c0 	movl   $0xc0105dad,(%esp)
c0105e6b:	e8 64 fb ff ff       	call   c01059d4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e73:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e79:	c9                   	leave  
c0105e7a:	c3                   	ret    
