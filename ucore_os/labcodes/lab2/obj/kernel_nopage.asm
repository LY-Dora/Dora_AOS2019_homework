
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 1f 56 00 00       	call   105681 <memset>

    cons_init();                // init the console
  100062:	e8 75 15 00 00       	call   1015dc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 5e 10 00 	movl   $0x105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 5e 10 00 	movl   $0x105e9c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 fe 30 00 00       	call   10318e <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 ab 16 00 00       	call   101740 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 04 18 00 00       	call   10189e <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 f0 0c 00 00       	call   100d8f <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 cf 17 00 00       	call   101873 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 b5 0c 00 00       	call   100d7d <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	c9                   	leave  
  1000ca:	c3                   	ret    

001000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cb:	55                   	push   %ebp
  1000cc:	89 e5                	mov    %esp,%ebp
  1000ce:	53                   	push   %ebx
  1000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b4 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	83 c4 14             	add    $0x14,%esp
  1000f6:	5b                   	pop    %ebx
  1000f7:	5d                   	pop    %ebp
  1000f8:	c3                   	ret    

001000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ff:	8b 45 10             	mov    0x10(%ebp),%eax
  100102:	89 44 24 04          	mov    %eax,0x4(%esp)
  100106:	8b 45 08             	mov    0x8(%ebp),%eax
  100109:	89 04 24             	mov    %eax,(%esp)
  10010c:	e8 ba ff ff ff       	call   1000cb <grade_backtrace1>
}
  100111:	90                   	nop
  100112:	c9                   	leave  
  100113:	c3                   	ret    

00100114 <grade_backtrace>:

void
grade_backtrace(void) {
  100114:	55                   	push   %ebp
  100115:	89 e5                	mov    %esp,%ebp
  100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011a:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100126:	ff 
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100132:	e8 c2 ff ff ff       	call   1000f9 <grade_backtrace0>
}
  100137:	90                   	nop
  100138:	c9                   	leave  
  100139:	c3                   	ret    

0010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013a:	55                   	push   %ebp
  10013b:	89 e5                	mov    %esp,%ebp
  10013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100150:	83 e0 03             	and    $0x3,%eax
  100153:	89 c2                	mov    %eax,%edx
  100155:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 a1 5e 10 00 	movl   $0x105ea1,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 5e 10 00 	movl   $0x105eaf,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 bd 5e 10 00 	movl   $0x105ebd,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 cb 5e 10 00 	movl   $0x105ecb,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 d9 5e 10 00 	movl   $0x105ed9,(%esp)
  1001e5:	e8 a8 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ea:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001f5:	90                   	nop
  1001f6:	c9                   	leave  
  1001f7:	c3                   	ret    

001001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f8:	55                   	push   %ebp
  1001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001fb:	90                   	nop
  1001fc:	5d                   	pop    %ebp
  1001fd:	c3                   	ret    

001001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100201:	90                   	nop
  100202:	5d                   	pop    %ebp
  100203:	c3                   	ret    

00100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100204:	55                   	push   %ebp
  100205:	89 e5                	mov    %esp,%ebp
  100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020a:	e8 2b ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10020f:	c7 04 24 e8 5e 10 00 	movl   $0x105ee8,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 08 5f 10 00 	movl   $0x105f08,(%esp)
  10022c:	e8 61 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_kernel();
  100231:	e8 c8 ff ff ff       	call   1001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100236:	e8 ff fe ff ff       	call   10013a <lab1_print_cur_status>
}
  10023b:	90                   	nop
  10023c:	c9                   	leave  
  10023d:	c3                   	ret    

0010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10023e:	55                   	push   %ebp
  10023f:	89 e5                	mov    %esp,%ebp
  100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100244:	8b 45 08             	mov    0x8(%ebp),%eax
  100247:	89 04 24             	mov    %eax,(%esp)
  10024a:	e8 ba 13 00 00       	call   101609 <cons_putc>
    (*cnt) ++;
  10024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100252:	8b 00                	mov    (%eax),%eax
  100254:	8d 50 01             	lea    0x1(%eax),%edx
  100257:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025a:	89 10                	mov    %edx,(%eax)
}
  10025c:	90                   	nop
  10025d:	c9                   	leave  
  10025e:	c3                   	ret    

0010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025f:	55                   	push   %ebp
  100260:	89 e5                	mov    %esp,%ebp
  100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100273:	8b 45 08             	mov    0x8(%ebp),%eax
  100276:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100281:	c7 04 24 3e 02 10 00 	movl   $0x10023e,(%esp)
  100288:	e8 47 57 00 00       	call   1059d4 <vprintfmt>
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100298:	8d 45 0c             	lea    0xc(%ebp),%eax
  10029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 af ff ff ff       	call   10025f <vcprintf>
  1002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002be:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c1:	89 04 24             	mov    %eax,(%esp)
  1002c4:	e8 40 13 00 00       	call   101609 <cons_putc>
}
  1002c9:	90                   	nop
  1002ca:	c9                   	leave  
  1002cb:	c3                   	ret    

001002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002cc:	55                   	push   %ebp
  1002cd:	89 e5                	mov    %esp,%ebp
  1002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002d9:	eb 13                	jmp    1002ee <cputs+0x22>
        cputch(c, &cnt);
  1002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002e6:	89 04 24             	mov    %eax,(%esp)
  1002e9:	e8 50 ff ff ff       	call   10023e <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f1:	8d 50 01             	lea    0x1(%eax),%edx
  1002f4:	89 55 08             	mov    %edx,0x8(%ebp)
  1002f7:	0f b6 00             	movzbl (%eax),%eax
  1002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100301:	75 d8                	jne    1002db <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100306:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100311:	e8 28 ff ff ff       	call   10023e <cputch>
    return cnt;
  100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100319:	c9                   	leave  
  10031a:	c3                   	ret    

0010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10031b:	55                   	push   %ebp
  10031c:	89 e5                	mov    %esp,%ebp
  10031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100321:	e8 20 13 00 00       	call   101646 <cons_getc>
  100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10032d:	74 f2                	je     100321 <getchar+0x6>
        /* do nothing */;
    return c;
  10032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100332:	c9                   	leave  
  100333:	c3                   	ret    

00100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100334:	55                   	push   %ebp
  100335:	89 e5                	mov    %esp,%ebp
  100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10033e:	74 13                	je     100353 <readline+0x1f>
        cprintf("%s", prompt);
  100340:	8b 45 08             	mov    0x8(%ebp),%eax
  100343:	89 44 24 04          	mov    %eax,0x4(%esp)
  100347:	c7 04 24 27 5f 10 00 	movl   $0x105f27,(%esp)
  10034e:	e8 3f ff ff ff       	call   100292 <cprintf>
    }
    int i = 0, c;
  100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10035a:	e8 bc ff ff ff       	call   10031b <getchar>
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100366:	79 07                	jns    10036f <readline+0x3b>
            return NULL;
  100368:	b8 00 00 00 00       	mov    $0x0,%eax
  10036d:	eb 78                	jmp    1003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100373:	7e 28                	jle    10039d <readline+0x69>
  100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10037c:	7f 1f                	jg     10039d <readline+0x69>
            cputchar(c);
  10037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100381:	89 04 24             	mov    %eax,(%esp)
  100384:	e8 2f ff ff ff       	call   1002b8 <cputchar>
            buf[i ++] = c;
  100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038c:	8d 50 01             	lea    0x1(%eax),%edx
  10038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100395:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  10039b:	eb 45                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  10039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a1:	75 16                	jne    1003b9 <readline+0x85>
  1003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003a7:	7e 10                	jle    1003b9 <readline+0x85>
            cputchar(c);
  1003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ac:	89 04 24             	mov    %eax,(%esp)
  1003af:	e8 04 ff ff ff       	call   1002b8 <cputchar>
            i --;
  1003b4:	ff 4d f4             	decl   -0xc(%ebp)
  1003b7:	eb 29                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003bd:	74 06                	je     1003c5 <readline+0x91>
  1003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c3:	75 95                	jne    10035a <readline+0x26>
            cputchar(c);
  1003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c8:	89 04 24             	mov    %eax,(%esp)
  1003cb:	e8 e8 fe ff ff       	call   1002b8 <cputchar>
            buf[i] = '\0';
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1003e0:	eb 05                	jmp    1003e7 <readline+0xb3>
        }
    }
  1003e2:	e9 73 ff ff ff       	jmp    10035a <readline+0x26>
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ef:	a1 20 a4 11 00       	mov    0x11a420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	75 5b                	jne    100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003f8:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  1003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100402:	8d 45 14             	lea    0x14(%ebp),%eax
  100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100408:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10040f:	8b 45 08             	mov    0x8(%ebp),%eax
  100412:	89 44 24 04          	mov    %eax,0x4(%esp)
  100416:	c7 04 24 2a 5f 10 00 	movl   $0x105f2a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 46 5f 10 00 	movl   $0x105f46,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 48 5f 10 00 	movl   $0x105f48,(%esp)
  100447:	e8 46 fe ff ff       	call   100292 <cprintf>
    print_stackframe();
  10044c:	e8 32 06 00 00       	call   100a83 <print_stackframe>
  100451:	eb 01                	jmp    100454 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100453:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100454:	e8 21 14 00 00       	call   10187a <intr_disable>
    while (1) {
        kmonitor(NULL);
  100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100460:	e8 4b 08 00 00       	call   100cb0 <kmonitor>
    }
  100465:	eb f2                	jmp    100459 <__panic+0x70>

00100467 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100467:	55                   	push   %ebp
  100468:	89 e5                	mov    %esp,%ebp
  10046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10046d:	8d 45 14             	lea    0x14(%ebp),%eax
  100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100473:	8b 45 0c             	mov    0xc(%ebp),%eax
  100476:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100481:	c7 04 24 5a 5f 10 00 	movl   $0x105f5a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 46 5f 10 00 	movl   $0x105f46,(%esp)
  1004a6:	e8 e7 fd ff ff       	call   100292 <cprintf>
    va_end(ap);
}
  1004ab:	90                   	nop
  1004ac:	c9                   	leave  
  1004ad:	c3                   	ret    

001004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004ae:	55                   	push   %ebp
  1004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004b1:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  1004b6:	5d                   	pop    %ebp
  1004b7:	c3                   	ret    

001004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004b8:	55                   	push   %ebp
  1004b9:	89 e5                	mov    %esp,%ebp
  1004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c1:	8b 00                	mov    (%eax),%eax
  1004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	8b 00                	mov    (%eax),%eax
  1004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004d5:	e9 ca 00 00 00       	jmp    1005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004e0:	01 d0                	add    %edx,%eax
  1004e2:	89 c2                	mov    %eax,%edx
  1004e4:	c1 ea 1f             	shr    $0x1f,%edx
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	d1 f8                	sar    %eax
  1004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f4:	eb 03                	jmp    1004f9 <stab_binsearch+0x41>
            m --;
  1004f6:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ff:	7c 1f                	jl     100520 <stab_binsearch+0x68>
  100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100504:	89 d0                	mov    %edx,%eax
  100506:	01 c0                	add    %eax,%eax
  100508:	01 d0                	add    %edx,%eax
  10050a:	c1 e0 02             	shl    $0x2,%eax
  10050d:	89 c2                	mov    %eax,%edx
  10050f:	8b 45 08             	mov    0x8(%ebp),%eax
  100512:	01 d0                	add    %edx,%eax
  100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100518:	0f b6 c0             	movzbl %al,%eax
  10051b:	3b 45 14             	cmp    0x14(%ebp),%eax
  10051e:	75 d6                	jne    1004f6 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100526:	7d 09                	jge    100531 <stab_binsearch+0x79>
            l = true_m + 1;
  100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052b:	40                   	inc    %eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10052f:	eb 73                	jmp    1005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053b:	89 d0                	mov    %edx,%eax
  10053d:	01 c0                	add    %eax,%eax
  10053f:	01 d0                	add    %edx,%eax
  100541:	c1 e0 02             	shl    $0x2,%eax
  100544:	89 c2                	mov    %eax,%edx
  100546:	8b 45 08             	mov    0x8(%ebp),%eax
  100549:	01 d0                	add    %edx,%eax
  10054b:	8b 40 08             	mov    0x8(%eax),%eax
  10054e:	3b 45 18             	cmp    0x18(%ebp),%eax
  100551:	73 11                	jae    100564 <stab_binsearch+0xac>
            *region_left = m;
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10055e:	40                   	inc    %eax
  10055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100562:	eb 40                	jmp    1005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100567:	89 d0                	mov    %edx,%eax
  100569:	01 c0                	add    %eax,%eax
  10056b:	01 d0                	add    %edx,%eax
  10056d:	c1 e0 02             	shl    $0x2,%eax
  100570:	89 c2                	mov    %eax,%edx
  100572:	8b 45 08             	mov    0x8(%ebp),%eax
  100575:	01 d0                	add    %edx,%eax
  100577:	8b 40 08             	mov    0x8(%eax),%eax
  10057a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10057d:	76 14                	jbe    100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100582:	8d 50 ff             	lea    -0x1(%eax),%edx
  100585:	8b 45 10             	mov    0x10(%ebp),%eax
  100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10058d:	48                   	dec    %eax
  10058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100591:	eb 11                	jmp    1005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100593:	8b 45 0c             	mov    0xc(%ebp),%eax
  100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100599:	89 10                	mov    %edx,(%eax)
            l = m;
  10059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a1:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005aa:	0f 8e 2a ff ff ff    	jle    1004da <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b4:	75 0f                	jne    1005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b9:	8b 00                	mov    (%eax),%eax
  1005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005be:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c3:	eb 3e                	jmp    100603 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c8:	8b 00                	mov    (%eax),%eax
  1005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005cd:	eb 03                	jmp    1005d2 <stab_binsearch+0x11a>
  1005cf:	ff 4d fc             	decl   -0x4(%ebp)
  1005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d5:	8b 00                	mov    (%eax),%eax
  1005d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005da:	7d 1f                	jge    1005fb <stab_binsearch+0x143>
  1005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005df:	89 d0                	mov    %edx,%eax
  1005e1:	01 c0                	add    %eax,%eax
  1005e3:	01 d0                	add    %edx,%eax
  1005e5:	c1 e0 02             	shl    $0x2,%eax
  1005e8:	89 c2                	mov    %eax,%edx
  1005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ed:	01 d0                	add    %edx,%eax
  1005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f3:	0f b6 c0             	movzbl %al,%eax
  1005f6:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005f9:	75 d4                	jne    1005cf <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  1005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100601:	89 10                	mov    %edx,(%eax)
    }
}
  100603:	90                   	nop
  100604:	c9                   	leave  
  100605:	c3                   	ret    

00100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100606:	55                   	push   %ebp
  100607:	89 e5                	mov    %esp,%ebp
  100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060f:	c7 00 78 5f 10 00    	movl   $0x105f78,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 78 5f 10 00 	movl   $0x105f78,0x8(%eax)
    info->eip_fn_namelen = 9;
  100629:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100633:	8b 45 0c             	mov    0xc(%ebp),%eax
  100636:	8b 55 08             	mov    0x8(%ebp),%edx
  100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100646:	c7 45 f4 70 71 10 00 	movl   $0x107170,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 a0 1f 11 00 	movl   $0x111fa0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec a1 1f 11 00 	movl   $0x111fa1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 86 4a 11 00 	movl   $0x114a86,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100668:	76 0b                	jbe    100675 <debuginfo_eip+0x6f>
  10066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066d:	48                   	dec    %eax
  10066e:	0f b6 00             	movzbl (%eax),%eax
  100671:	84 c0                	test   %al,%al
  100673:	74 0a                	je     10067f <debuginfo_eip+0x79>
        return -1;
  100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067a:	e9 b7 02 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068c:	29 c2                	sub    %eax,%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 f8 02             	sar    $0x2,%eax
  100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100699:	48                   	dec    %eax
  10069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10069d:	8b 45 08             	mov    0x8(%ebp),%eax
  1006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006ab:	00 
  1006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006af:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006bd:	89 04 24             	mov    %eax,(%esp)
  1006c0:	e8 f3 fd ff ff       	call   1004b8 <stab_binsearch>
    if (lfile == 0)
  1006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006c8:	85 c0                	test   %eax,%eax
  1006ca:	75 0a                	jne    1006d6 <debuginfo_eip+0xd0>
        return -1;
  1006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006d1:	e9 60 02 00 00       	jmp    100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 ae fd ff ff       	call   1004b8 <stab_binsearch>

    if (lfun <= rfun) {
  10070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 7c                	jg     100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	8b 00                	mov    (%eax),%eax
  10072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100731:	29 d1                	sub    %edx,%ecx
  100733:	89 ca                	mov    %ecx,%edx
  100735:	39 d0                	cmp    %edx,%eax
  100737:	73 22                	jae    10075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10073c:	89 c2                	mov    %eax,%edx
  10073e:	89 d0                	mov    %edx,%eax
  100740:	01 c0                	add    %eax,%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	c1 e0 02             	shl    $0x2,%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	8b 10                	mov    (%eax),%edx
  100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100753:	01 c2                	add    %eax,%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075e:	89 c2                	mov    %eax,%edx
  100760:	89 d0                	mov    %edx,%eax
  100762:	01 c0                	add    %eax,%eax
  100764:	01 d0                	add    %edx,%eax
  100766:	c1 e0 02             	shl    $0x2,%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	8b 50 08             	mov    0x8(%eax),%edx
  100773:	8b 45 0c             	mov    0xc(%ebp),%eax
  100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077c:	8b 40 10             	mov    0x10(%eax),%eax
  10077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10078e:	eb 15                	jmp    1007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100790:	8b 45 0c             	mov    0xc(%ebp),%eax
  100793:	8b 55 08             	mov    0x8(%ebp),%edx
  100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a8:	8b 40 08             	mov    0x8(%eax),%eax
  1007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007b2:	00 
  1007b3:	89 04 24             	mov    %eax,(%esp)
  1007b6:	e8 42 4d 00 00       	call   1054fd <strfind>
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c0:	8b 40 08             	mov    0x8(%eax),%eax
  1007c3:	29 c2                	sub    %eax,%edx
  1007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007d9:	00 
  1007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007eb:	89 04 24             	mov    %eax,(%esp)
  1007ee:	e8 c5 fc ff ff       	call   1004b8 <stab_binsearch>
    if (lline <= rline) {
  1007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007f9:	39 c2                	cmp    %eax,%edx
  1007fb:	7f 23                	jg     100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100800:	89 c2                	mov    %eax,%edx
  100802:	89 d0                	mov    %edx,%eax
  100804:	01 c0                	add    %eax,%eax
  100806:	01 d0                	add    %edx,%eax
  100808:	c1 e0 02             	shl    $0x2,%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10081e:	eb 11                	jmp    100831 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100825:	e9 0c 01 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10082d:	48                   	dec    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7c 56                	jl     100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083e:	89 c2                	mov    %eax,%edx
  100840:	89 d0                	mov    %edx,%eax
  100842:	01 c0                	add    %eax,%eax
  100844:	01 d0                	add    %edx,%eax
  100846:	c1 e0 02             	shl    $0x2,%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10084e:	01 d0                	add    %edx,%eax
  100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100854:	3c 84                	cmp    $0x84,%al
  100856:	74 39                	je     100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c 64                	cmp    $0x64,%al
  100873:	75 b5                	jne    10082a <debuginfo_eip+0x224>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 40 08             	mov    0x8(%eax),%eax
  10088d:	85 c0                	test   %eax,%eax
  10088f:	74 99                	je     10082a <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7c 46                	jl     1008e1 <debuginfo_eip+0x2db>
  10089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089e:	89 c2                	mov    %eax,%edx
  1008a0:	89 d0                	mov    %edx,%eax
  1008a2:	01 c0                	add    %eax,%eax
  1008a4:	01 d0                	add    %edx,%eax
  1008a6:	c1 e0 02             	shl    $0x2,%eax
  1008a9:	89 c2                	mov    %eax,%edx
  1008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ae:	01 d0                	add    %edx,%eax
  1008b0:	8b 00                	mov    (%eax),%eax
  1008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008b8:	29 d1                	sub    %edx,%ecx
  1008ba:	89 ca                	mov    %ecx,%edx
  1008bc:	39 d0                	cmp    %edx,%eax
  1008be:	73 21                	jae    1008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c3:	89 c2                	mov    %eax,%edx
  1008c5:	89 d0                	mov    %edx,%eax
  1008c7:	01 c0                	add    %eax,%eax
  1008c9:	01 d0                	add    %edx,%eax
  1008cb:	c1 e0 02             	shl    $0x2,%eax
  1008ce:	89 c2                	mov    %eax,%edx
  1008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d3:	01 d0                	add    %edx,%eax
  1008d5:	8b 10                	mov    (%eax),%edx
  1008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008da:	01 c2                	add    %eax,%edx
  1008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008e7:	39 c2                	cmp    %eax,%edx
  1008e9:	7d 46                	jge    100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008ee:	40                   	inc    %eax
  1008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008f2:	eb 16                	jmp    10090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f7:	8b 40 14             	mov    0x14(%eax),%eax
  1008fa:	8d 50 01             	lea    0x1(%eax),%edx
  1008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100900:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100906:	40                   	inc    %eax
  100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100910:	39 c2                	cmp    %eax,%edx
  100912:	7d 1d                	jge    100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100917:	89 c2                	mov    %eax,%edx
  100919:	89 d0                	mov    %edx,%eax
  10091b:	01 c0                	add    %eax,%eax
  10091d:	01 d0                	add    %edx,%eax
  10091f:	c1 e0 02             	shl    $0x2,%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100927:	01 d0                	add    %edx,%eax
  100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10092d:	3c a0                	cmp    $0xa0,%al
  10092f:	74 c3                	je     1008f4 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100936:	c9                   	leave  
  100937:	c3                   	ret    

00100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100938:	55                   	push   %ebp
  100939:	89 e5                	mov    %esp,%ebp
  10093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10093e:	c7 04 24 82 5f 10 00 	movl   $0x105f82,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 9b 5f 10 00 	movl   $0x105f9b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 7b 5e 10 	movl   $0x105e7b,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 b3 5f 10 00 	movl   $0x105fb3,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 cb 5f 10 00 	movl   $0x105fcb,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 e3 5f 10 00 	movl   $0x105fe3,(%esp)
  100995:	e8 f8 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099a:	b8 28 af 11 00       	mov    $0x11af28,%eax
  10099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009aa:	29 c2                	sub    %eax,%edx
  1009ac:	89 d0                	mov    %edx,%eax
  1009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b4:	85 c0                	test   %eax,%eax
  1009b6:	0f 48 c2             	cmovs  %edx,%eax
  1009b9:	c1 f8 0a             	sar    $0xa,%eax
  1009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c0:	c7 04 24 fc 5f 10 00 	movl   $0x105ffc,(%esp)
  1009c7:	e8 c6 f8 ff ff       	call   100292 <cprintf>
}
  1009cc:	90                   	nop
  1009cd:	c9                   	leave  
  1009ce:	c3                   	ret    

001009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009cf:	55                   	push   %ebp
  1009d0:	89 e5                	mov    %esp,%ebp
  1009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009df:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e2:	89 04 24             	mov    %eax,(%esp)
  1009e5:	e8 1c fc ff ff       	call   100606 <debuginfo_eip>
  1009ea:	85 c0                	test   %eax,%eax
  1009ec:	74 15                	je     100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f5:	c7 04 24 26 60 10 00 	movl   $0x106026,(%esp)
  1009fc:	e8 91 f8 ff ff       	call   100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a01:	eb 6c                	jmp    100a6f <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a0a:	eb 1b                	jmp    100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	0f b6 00             	movzbl (%eax),%eax
  100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a20:	01 ca                	add    %ecx,%edx
  100a22:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a24:	ff 45 f4             	incl   -0xc(%ebp)
  100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a2d:	7f dd                	jg     100a0c <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a38:	01 d0                	add    %edx,%eax
  100a3a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a40:	8b 55 08             	mov    0x8(%ebp),%edx
  100a43:	89 d1                	mov    %edx,%ecx
  100a45:	29 c1                	sub    %eax,%ecx
  100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a63:	c7 04 24 42 60 10 00 	movl   $0x106042,(%esp)
  100a6a:	e8 23 f8 ff ff       	call   100292 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a6f:	90                   	nop
  100a70:	c9                   	leave  
  100a71:	c3                   	ret    

00100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a72:	55                   	push   %ebp
  100a73:	89 e5                	mov    %esp,%ebp
  100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a78:	8b 45 04             	mov    0x4(%ebp),%eax
  100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a81:	c9                   	leave  
  100a82:	c3                   	ret    

00100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a89:	89 e8                	mov    %ebp,%eax
  100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
  100a94:	e8 d9 ff ff ff       	call   100a72 <read_eip>
  100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
  100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aa3:	e9 88 00 00 00       	jmp    100b30 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab6:	c7 04 24 54 60 10 00 	movl   $0x106054,(%esp)
  100abd:	e8 d0 f7 ff ff       	call   100292 <cprintf>
        uint32_t *fun_stack = (uint32_t *)ebp ;
  100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 2; j < 6; j ++) {
  100ac8:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
  100acf:	eb 24                	jmp    100af5 <print_stackframe+0x72>
            cprintf("0x%08x ", fun_stack[j]);
  100ad1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ad4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ade:	01 d0                	add    %edx,%eax
  100ae0:	8b 00                	mov    (%eax),%eax
  100ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae6:	c7 04 24 70 60 10 00 	movl   $0x106070,(%esp)
  100aed:	e8 a0 f7 ff ff       	call   100292 <cprintf>
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *fun_stack = (uint32_t *)ebp ;
        for (int j = 2; j < 6; j ++) {
  100af2:	ff 45 e8             	incl   -0x18(%ebp)
  100af5:	83 7d e8 05          	cmpl   $0x5,-0x18(%ebp)
  100af9:	7e d6                	jle    100ad1 <print_stackframe+0x4e>
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
  100afb:	c7 04 24 78 60 10 00 	movl   $0x106078,(%esp)
  100b02:	e8 8b f7 ff ff       	call   100292 <cprintf>
        print_debuginfo(eip - 1);
  100b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0a:	48                   	dec    %eax
  100b0b:	89 04 24             	mov    %eax,(%esp)
  100b0e:	e8 bc fe ff ff       	call   1009cf <print_debuginfo>
        if(fun_stack[0]==0) break;
  100b13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b16:	8b 00                	mov    (%eax),%eax
  100b18:	85 c0                	test   %eax,%eax
  100b1a:	74 20                	je     100b3c <print_stackframe+0xb9>
        eip = fun_stack[1];
  100b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b1f:	8b 40 04             	mov    0x4(%eax),%eax
  100b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = fun_stack[0];
  100b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b28:	8b 00                	mov    (%eax),%eax
  100b2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
  100b2d:	ff 45 ec             	incl   -0x14(%ebp)
  100b30:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b34:	0f 8e 6e ff ff ff    	jle    100aa8 <print_stackframe+0x25>
        if(fun_stack[0]==0) break;
        eip = fun_stack[1];
        ebp = fun_stack[0];
      }

}
  100b3a:	eb 01                	jmp    100b3d <print_stackframe+0xba>
        for (int j = 2; j < 6; j ++) {
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
  100b3c:	90                   	nop
        eip = fun_stack[1];
        ebp = fun_stack[0];
      }

}
  100b3d:	90                   	nop
  100b3e:	c9                   	leave  
  100b3f:	c3                   	ret    

00100b40 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b40:	55                   	push   %ebp
  100b41:	89 e5                	mov    %esp,%ebp
  100b43:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4d:	eb 0c                	jmp    100b5b <parse+0x1b>
            *buf ++ = '\0';
  100b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  100b52:	8d 50 01             	lea    0x1(%eax),%edx
  100b55:	89 55 08             	mov    %edx,0x8(%ebp)
  100b58:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5e:	0f b6 00             	movzbl (%eax),%eax
  100b61:	84 c0                	test   %al,%al
  100b63:	74 1d                	je     100b82 <parse+0x42>
  100b65:	8b 45 08             	mov    0x8(%ebp),%eax
  100b68:	0f b6 00             	movzbl (%eax),%eax
  100b6b:	0f be c0             	movsbl %al,%eax
  100b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b72:	c7 04 24 fc 60 10 00 	movl   $0x1060fc,(%esp)
  100b79:	e8 4d 49 00 00       	call   1054cb <strchr>
  100b7e:	85 c0                	test   %eax,%eax
  100b80:	75 cd                	jne    100b4f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b82:	8b 45 08             	mov    0x8(%ebp),%eax
  100b85:	0f b6 00             	movzbl (%eax),%eax
  100b88:	84 c0                	test   %al,%al
  100b8a:	74 69                	je     100bf5 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b8c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b90:	75 14                	jne    100ba6 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b92:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b99:	00 
  100b9a:	c7 04 24 01 61 10 00 	movl   $0x106101,(%esp)
  100ba1:	e8 ec f6 ff ff       	call   100292 <cprintf>
        }
        argv[argc ++] = buf;
  100ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ba9:	8d 50 01             	lea    0x1(%eax),%edx
  100bac:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100baf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bb9:	01 c2                	add    %eax,%edx
  100bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbe:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc0:	eb 03                	jmp    100bc5 <parse+0x85>
            buf ++;
  100bc2:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc8:	0f b6 00             	movzbl (%eax),%eax
  100bcb:	84 c0                	test   %al,%al
  100bcd:	0f 84 7a ff ff ff    	je     100b4d <parse+0xd>
  100bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd6:	0f b6 00             	movzbl (%eax),%eax
  100bd9:	0f be c0             	movsbl %al,%eax
  100bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be0:	c7 04 24 fc 60 10 00 	movl   $0x1060fc,(%esp)
  100be7:	e8 df 48 00 00       	call   1054cb <strchr>
  100bec:	85 c0                	test   %eax,%eax
  100bee:	74 d2                	je     100bc2 <parse+0x82>
            buf ++;
        }
    }
  100bf0:	e9 58 ff ff ff       	jmp    100b4d <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bf5:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bf9:	c9                   	leave  
  100bfa:	c3                   	ret    

00100bfb <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bfb:	55                   	push   %ebp
  100bfc:	89 e5                	mov    %esp,%ebp
  100bfe:	53                   	push   %ebx
  100bff:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c02:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c09:	8b 45 08             	mov    0x8(%ebp),%eax
  100c0c:	89 04 24             	mov    %eax,(%esp)
  100c0f:	e8 2c ff ff ff       	call   100b40 <parse>
  100c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c1b:	75 0a                	jne    100c27 <runcmd+0x2c>
        return 0;
  100c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  100c22:	e9 83 00 00 00       	jmp    100caa <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c2e:	eb 5a                	jmp    100c8a <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c30:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c36:	89 d0                	mov    %edx,%eax
  100c38:	01 c0                	add    %eax,%eax
  100c3a:	01 d0                	add    %edx,%eax
  100c3c:	c1 e0 02             	shl    $0x2,%eax
  100c3f:	05 00 70 11 00       	add    $0x117000,%eax
  100c44:	8b 00                	mov    (%eax),%eax
  100c46:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c4a:	89 04 24             	mov    %eax,(%esp)
  100c4d:	e8 dc 47 00 00       	call   10542e <strcmp>
  100c52:	85 c0                	test   %eax,%eax
  100c54:	75 31                	jne    100c87 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c59:	89 d0                	mov    %edx,%eax
  100c5b:	01 c0                	add    %eax,%eax
  100c5d:	01 d0                	add    %edx,%eax
  100c5f:	c1 e0 02             	shl    $0x2,%eax
  100c62:	05 08 70 11 00       	add    $0x117008,%eax
  100c67:	8b 10                	mov    (%eax),%edx
  100c69:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c6c:	83 c0 04             	add    $0x4,%eax
  100c6f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c72:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c80:	89 1c 24             	mov    %ebx,(%esp)
  100c83:	ff d2                	call   *%edx
  100c85:	eb 23                	jmp    100caa <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c87:	ff 45 f4             	incl   -0xc(%ebp)
  100c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c8d:	83 f8 02             	cmp    $0x2,%eax
  100c90:	76 9e                	jbe    100c30 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c92:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c99:	c7 04 24 1f 61 10 00 	movl   $0x10611f,(%esp)
  100ca0:	e8 ed f5 ff ff       	call   100292 <cprintf>
    return 0;
  100ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caa:	83 c4 64             	add    $0x64,%esp
  100cad:	5b                   	pop    %ebx
  100cae:	5d                   	pop    %ebp
  100caf:	c3                   	ret    

00100cb0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cb0:	55                   	push   %ebp
  100cb1:	89 e5                	mov    %esp,%ebp
  100cb3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cb6:	c7 04 24 38 61 10 00 	movl   $0x106138,(%esp)
  100cbd:	e8 d0 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cc2:	c7 04 24 60 61 10 00 	movl   $0x106160,(%esp)
  100cc9:	e8 c4 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100cce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cd2:	74 0b                	je     100cdf <kmonitor+0x2f>
        print_trapframe(tf);
  100cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd7:	89 04 24             	mov    %eax,(%esp)
  100cda:	e8 7c 0d 00 00       	call   101a5b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cdf:	c7 04 24 85 61 10 00 	movl   $0x106185,(%esp)
  100ce6:	e8 49 f6 ff ff       	call   100334 <readline>
  100ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cf2:	74 eb                	je     100cdf <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cfe:	89 04 24             	mov    %eax,(%esp)
  100d01:	e8 f5 fe ff ff       	call   100bfb <runcmd>
  100d06:	85 c0                	test   %eax,%eax
  100d08:	78 02                	js     100d0c <kmonitor+0x5c>
                break;
            }
        }
    }
  100d0a:	eb d3                	jmp    100cdf <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100d0c:	90                   	nop
            }
        }
    }
}
  100d0d:	90                   	nop
  100d0e:	c9                   	leave  
  100d0f:	c3                   	ret    

00100d10 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d10:	55                   	push   %ebp
  100d11:	89 e5                	mov    %esp,%ebp
  100d13:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d1d:	eb 3d                	jmp    100d5c <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d22:	89 d0                	mov    %edx,%eax
  100d24:	01 c0                	add    %eax,%eax
  100d26:	01 d0                	add    %edx,%eax
  100d28:	c1 e0 02             	shl    $0x2,%eax
  100d2b:	05 04 70 11 00       	add    $0x117004,%eax
  100d30:	8b 08                	mov    (%eax),%ecx
  100d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d35:	89 d0                	mov    %edx,%eax
  100d37:	01 c0                	add    %eax,%eax
  100d39:	01 d0                	add    %edx,%eax
  100d3b:	c1 e0 02             	shl    $0x2,%eax
  100d3e:	05 00 70 11 00       	add    $0x117000,%eax
  100d43:	8b 00                	mov    (%eax),%eax
  100d45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d4d:	c7 04 24 89 61 10 00 	movl   $0x106189,(%esp)
  100d54:	e8 39 f5 ff ff       	call   100292 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d59:	ff 45 f4             	incl   -0xc(%ebp)
  100d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5f:	83 f8 02             	cmp    $0x2,%eax
  100d62:	76 bb                	jbe    100d1f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d69:	c9                   	leave  
  100d6a:	c3                   	ret    

00100d6b <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d6b:	55                   	push   %ebp
  100d6c:	89 e5                	mov    %esp,%ebp
  100d6e:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d71:	e8 c2 fb ff ff       	call   100938 <print_kerninfo>
    return 0;
  100d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d7b:	c9                   	leave  
  100d7c:	c3                   	ret    

00100d7d <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d7d:	55                   	push   %ebp
  100d7e:	89 e5                	mov    %esp,%ebp
  100d80:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d83:	e8 fb fc ff ff       	call   100a83 <print_stackframe>
    return 0;
  100d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d8d:	c9                   	leave  
  100d8e:	c3                   	ret    

00100d8f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8f:	55                   	push   %ebp
  100d90:	89 e5                	mov    %esp,%ebp
  100d92:	83 ec 28             	sub    $0x28,%esp
  100d95:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d9b:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100da3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100da7:	ee                   	out    %al,(%dx)
  100da8:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100dae:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100db2:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100db9:	ee                   	out    %al,(%dx)
  100dba:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dc0:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100dc4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dcc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dcd:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100dd4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd7:	c7 04 24 92 61 10 00 	movl   $0x106192,(%esp)
  100dde:	e8 af f4 ff ff       	call   100292 <cprintf>
    pic_enable(IRQ_TIMER);
  100de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dea:	e8 1e 09 00 00       	call   10170d <pic_enable>
}
  100def:	90                   	nop
  100df0:	c9                   	leave  
  100df1:	c3                   	ret    

00100df2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100df2:	55                   	push   %ebp
  100df3:	89 e5                	mov    %esp,%ebp
  100df5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df8:	9c                   	pushf  
  100df9:	58                   	pop    %eax
  100dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e00:	25 00 02 00 00       	and    $0x200,%eax
  100e05:	85 c0                	test   %eax,%eax
  100e07:	74 0c                	je     100e15 <__intr_save+0x23>
        intr_disable();
  100e09:	e8 6c 0a 00 00       	call   10187a <intr_disable>
        return 1;
  100e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  100e13:	eb 05                	jmp    100e1a <__intr_save+0x28>
    }
    return 0;
  100e15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e1a:	c9                   	leave  
  100e1b:	c3                   	ret    

00100e1c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e1c:	55                   	push   %ebp
  100e1d:	89 e5                	mov    %esp,%ebp
  100e1f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e26:	74 05                	je     100e2d <__intr_restore+0x11>
        intr_enable();
  100e28:	e8 46 0a 00 00       	call   101873 <intr_enable>
    }
}
  100e2d:	90                   	nop
  100e2e:	c9                   	leave  
  100e2f:	c3                   	ret    

00100e30 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e30:	55                   	push   %ebp
  100e31:	89 e5                	mov    %esp,%ebp
  100e33:	83 ec 10             	sub    $0x10,%esp
  100e36:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e3c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e40:	89 c2                	mov    %eax,%edx
  100e42:	ec                   	in     (%dx),%al
  100e43:	88 45 f4             	mov    %al,-0xc(%ebp)
  100e46:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e4f:	89 c2                	mov    %eax,%edx
  100e51:	ec                   	in     (%dx),%al
  100e52:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5f:	89 c2                	mov    %eax,%edx
  100e61:	ec                   	in     (%dx),%al
  100e62:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e65:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e6e:	89 c2                	mov    %eax,%edx
  100e70:	ec                   	in     (%dx),%al
  100e71:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e74:	90                   	nop
  100e75:	c9                   	leave  
  100e76:	c3                   	ret    

00100e77 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e77:	55                   	push   %ebp
  100e78:	89 e5                	mov    %esp,%ebp
  100e7a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e87:	0f b7 00             	movzwl (%eax),%eax
  100e8a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e91:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e96:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e99:	0f b7 00             	movzwl (%eax),%eax
  100e9c:	0f b7 c0             	movzwl %ax,%eax
  100e9f:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ea4:	74 12                	je     100eb8 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea6:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ead:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100eb4:	b4 03 
  100eb6:	eb 13                	jmp    100ecb <cga_init+0x54>
    } else {
        *cp = was;
  100eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ebf:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec2:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ec9:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ecb:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ed2:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100ed6:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100eda:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100ede:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100ee1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee2:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ee9:	40                   	inc    %eax
  100eea:	0f b7 c0             	movzwl %ax,%eax
  100eed:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ef5:	89 c2                	mov    %eax,%edx
  100ef7:	ec                   	in     (%dx),%al
  100ef8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100efb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100eff:	0f b6 c0             	movzbl %al,%eax
  100f02:	c1 e0 08             	shl    $0x8,%eax
  100f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f08:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f0f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100f13:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f17:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f1f:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f26:	40                   	inc    %eax
  100f27:	0f b7 c0             	movzwl %ax,%eax
  100f2a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f2e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f32:	89 c2                	mov    %eax,%edx
  100f34:	ec                   	in     (%dx),%al
  100f35:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f38:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3c:	0f b6 c0             	movzbl %al,%eax
  100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f45:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f4d:	0f b7 c0             	movzwl %ax,%eax
  100f50:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f56:	90                   	nop
  100f57:	c9                   	leave  
  100f58:	c3                   	ret    

00100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f59:	55                   	push   %ebp
  100f5a:	89 e5                	mov    %esp,%ebp
  100f5c:	83 ec 38             	sub    $0x38,%esp
  100f5f:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f65:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f69:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f6d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f71:	ee                   	out    %al,(%dx)
  100f72:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f78:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f7c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100f83:	ee                   	out    %al,(%dx)
  100f84:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f8a:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f8e:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f92:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f96:	ee                   	out    %al,(%dx)
  100f97:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f9d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fa1:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100fa8:	ee                   	out    %al,(%dx)
  100fa9:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100faf:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100fb3:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100fb7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fbb:	ee                   	out    %al,(%dx)
  100fbc:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100fc2:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100fc6:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100fca:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100fcd:	ee                   	out    %al,(%dx)
  100fce:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd4:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100fd8:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100fdc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fe0:	ee                   	out    %al,(%dx)
  100fe1:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100fea:	89 c2                	mov    %eax,%edx
  100fec:	ec                   	in     (%dx),%al
  100fed:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100ff0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ff4:	3c ff                	cmp    $0xff,%al
  100ff6:	0f 95 c0             	setne  %al
  100ff9:	0f b6 c0             	movzbl %al,%eax
  100ffc:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101001:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101007:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  10100b:	89 c2                	mov    %eax,%edx
  10100d:	ec                   	in     (%dx),%al
  10100e:	88 45 e2             	mov    %al,-0x1e(%ebp)
  101011:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  101017:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10101a:	89 c2                	mov    %eax,%edx
  10101c:	ec                   	in     (%dx),%al
  10101d:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101020:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101025:	85 c0                	test   %eax,%eax
  101027:	74 0c                	je     101035 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  101029:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101030:	e8 d8 06 00 00       	call   10170d <pic_enable>
    }
}
  101035:	90                   	nop
  101036:	c9                   	leave  
  101037:	c3                   	ret    

00101038 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101038:	55                   	push   %ebp
  101039:	89 e5                	mov    %esp,%ebp
  10103b:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10103e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101045:	eb 08                	jmp    10104f <lpt_putc_sub+0x17>
        delay();
  101047:	e8 e4 fd ff ff       	call   100e30 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10104c:	ff 45 fc             	incl   -0x4(%ebp)
  10104f:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101058:	89 c2                	mov    %eax,%edx
  10105a:	ec                   	in     (%dx),%al
  10105b:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  10105e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101062:	84 c0                	test   %al,%al
  101064:	78 09                	js     10106f <lpt_putc_sub+0x37>
  101066:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10106d:	7e d8                	jle    101047 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10106f:	8b 45 08             	mov    0x8(%ebp),%eax
  101072:	0f b6 c0             	movzbl %al,%eax
  101075:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10107b:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10107e:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101082:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101085:	ee                   	out    %al,(%dx)
  101086:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10108c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101090:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101094:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101098:	ee                   	out    %al,(%dx)
  101099:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  10109f:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  1010a3:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1010a7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1010ab:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010ac:	90                   	nop
  1010ad:	c9                   	leave  
  1010ae:	c3                   	ret    

001010af <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010af:	55                   	push   %ebp
  1010b0:	89 e5                	mov    %esp,%ebp
  1010b2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010b5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010b9:	74 0d                	je     1010c8 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1010be:	89 04 24             	mov    %eax,(%esp)
  1010c1:	e8 72 ff ff ff       	call   101038 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010c6:	eb 24                	jmp    1010ec <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  1010c8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010cf:	e8 64 ff ff ff       	call   101038 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010d4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010db:	e8 58 ff ff ff       	call   101038 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e7:	e8 4c ff ff ff       	call   101038 <lpt_putc_sub>
    }
}
  1010ec:	90                   	nop
  1010ed:	c9                   	leave  
  1010ee:	c3                   	ret    

001010ef <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010ef:	55                   	push   %ebp
  1010f0:	89 e5                	mov    %esp,%ebp
  1010f2:	53                   	push   %ebx
  1010f3:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f9:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010fe:	85 c0                	test   %eax,%eax
  101100:	75 07                	jne    101109 <cga_putc+0x1a>
        c |= 0x0700;
  101102:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101109:	8b 45 08             	mov    0x8(%ebp),%eax
  10110c:	0f b6 c0             	movzbl %al,%eax
  10110f:	83 f8 0a             	cmp    $0xa,%eax
  101112:	74 54                	je     101168 <cga_putc+0x79>
  101114:	83 f8 0d             	cmp    $0xd,%eax
  101117:	74 62                	je     10117b <cga_putc+0x8c>
  101119:	83 f8 08             	cmp    $0x8,%eax
  10111c:	0f 85 93 00 00 00    	jne    1011b5 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  101122:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101129:	85 c0                	test   %eax,%eax
  10112b:	0f 84 ae 00 00 00    	je     1011df <cga_putc+0xf0>
            crt_pos --;
  101131:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101138:	48                   	dec    %eax
  101139:	0f b7 c0             	movzwl %ax,%eax
  10113c:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101142:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101147:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10114e:	01 d2                	add    %edx,%edx
  101150:	01 c2                	add    %eax,%edx
  101152:	8b 45 08             	mov    0x8(%ebp),%eax
  101155:	98                   	cwtl   
  101156:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10115b:	98                   	cwtl   
  10115c:	83 c8 20             	or     $0x20,%eax
  10115f:	98                   	cwtl   
  101160:	0f b7 c0             	movzwl %ax,%eax
  101163:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101166:	eb 77                	jmp    1011df <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  101168:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10116f:	83 c0 50             	add    $0x50,%eax
  101172:	0f b7 c0             	movzwl %ax,%eax
  101175:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10117b:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  101182:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101189:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  10118e:	89 c8                	mov    %ecx,%eax
  101190:	f7 e2                	mul    %edx
  101192:	c1 ea 06             	shr    $0x6,%edx
  101195:	89 d0                	mov    %edx,%eax
  101197:	c1 e0 02             	shl    $0x2,%eax
  10119a:	01 d0                	add    %edx,%eax
  10119c:	c1 e0 04             	shl    $0x4,%eax
  10119f:	29 c1                	sub    %eax,%ecx
  1011a1:	89 c8                	mov    %ecx,%eax
  1011a3:	0f b7 c0             	movzwl %ax,%eax
  1011a6:	29 c3                	sub    %eax,%ebx
  1011a8:	89 d8                	mov    %ebx,%eax
  1011aa:	0f b7 c0             	movzwl %ax,%eax
  1011ad:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011b3:	eb 2b                	jmp    1011e0 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011b5:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011bb:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011c2:	8d 50 01             	lea    0x1(%eax),%edx
  1011c5:	0f b7 d2             	movzwl %dx,%edx
  1011c8:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011cf:	01 c0                	add    %eax,%eax
  1011d1:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1011d7:	0f b7 c0             	movzwl %ax,%eax
  1011da:	66 89 02             	mov    %ax,(%edx)
        break;
  1011dd:	eb 01                	jmp    1011e0 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  1011df:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e0:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011e7:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011ec:	76 5d                	jbe    10124b <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011ee:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011f9:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011fe:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101205:	00 
  101206:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120a:	89 04 24             	mov    %eax,(%esp)
  10120d:	e8 af 44 00 00       	call   1056c1 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101212:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101219:	eb 14                	jmp    10122f <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  10121b:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101220:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101223:	01 d2                	add    %edx,%edx
  101225:	01 d0                	add    %edx,%eax
  101227:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122c:	ff 45 f4             	incl   -0xc(%ebp)
  10122f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101236:	7e e3                	jle    10121b <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101238:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10123f:	83 e8 50             	sub    $0x50,%eax
  101242:	0f b7 c0             	movzwl %ax,%eax
  101245:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124b:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101252:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101256:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  10125a:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  10125e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101262:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101263:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10126a:	c1 e8 08             	shr    $0x8,%eax
  10126d:	0f b7 c0             	movzwl %ax,%eax
  101270:	0f b6 c0             	movzbl %al,%eax
  101273:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10127a:	42                   	inc    %edx
  10127b:	0f b7 d2             	movzwl %dx,%edx
  10127e:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101282:	88 45 e9             	mov    %al,-0x17(%ebp)
  101285:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101289:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10128c:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10128d:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101294:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101298:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  10129c:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  1012a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012a4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012a5:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012ac:	0f b6 c0             	movzbl %al,%eax
  1012af:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012b6:	42                   	inc    %edx
  1012b7:	0f b7 d2             	movzwl %dx,%edx
  1012ba:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  1012be:	88 45 eb             	mov    %al,-0x15(%ebp)
  1012c1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1012c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1012c8:	ee                   	out    %al,(%dx)
}
  1012c9:	90                   	nop
  1012ca:	83 c4 24             	add    $0x24,%esp
  1012cd:	5b                   	pop    %ebx
  1012ce:	5d                   	pop    %ebp
  1012cf:	c3                   	ret    

001012d0 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012d0:	55                   	push   %ebp
  1012d1:	89 e5                	mov    %esp,%ebp
  1012d3:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012dd:	eb 08                	jmp    1012e7 <serial_putc_sub+0x17>
        delay();
  1012df:	e8 4c fb ff ff       	call   100e30 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e4:	ff 45 fc             	incl   -0x4(%ebp)
  1012e7:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1012f0:	89 c2                	mov    %eax,%edx
  1012f2:	ec                   	in     (%dx),%al
  1012f3:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1012f6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1012fa:	0f b6 c0             	movzbl %al,%eax
  1012fd:	83 e0 20             	and    $0x20,%eax
  101300:	85 c0                	test   %eax,%eax
  101302:	75 09                	jne    10130d <serial_putc_sub+0x3d>
  101304:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10130b:	7e d2                	jle    1012df <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10130d:	8b 45 08             	mov    0x8(%ebp),%eax
  101310:	0f b6 c0             	movzbl %al,%eax
  101313:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  101319:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10131c:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  101320:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101324:	ee                   	out    %al,(%dx)
}
  101325:	90                   	nop
  101326:	c9                   	leave  
  101327:	c3                   	ret    

00101328 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101328:	55                   	push   %ebp
  101329:	89 e5                	mov    %esp,%ebp
  10132b:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10132e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101332:	74 0d                	je     101341 <serial_putc+0x19>
        serial_putc_sub(c);
  101334:	8b 45 08             	mov    0x8(%ebp),%eax
  101337:	89 04 24             	mov    %eax,(%esp)
  10133a:	e8 91 ff ff ff       	call   1012d0 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10133f:	eb 24                	jmp    101365 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  101341:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101348:	e8 83 ff ff ff       	call   1012d0 <serial_putc_sub>
        serial_putc_sub(' ');
  10134d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101354:	e8 77 ff ff ff       	call   1012d0 <serial_putc_sub>
        serial_putc_sub('\b');
  101359:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101360:	e8 6b ff ff ff       	call   1012d0 <serial_putc_sub>
    }
}
  101365:	90                   	nop
  101366:	c9                   	leave  
  101367:	c3                   	ret    

00101368 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101368:	55                   	push   %ebp
  101369:	89 e5                	mov    %esp,%ebp
  10136b:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10136e:	eb 33                	jmp    1013a3 <cons_intr+0x3b>
        if (c != 0) {
  101370:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101374:	74 2d                	je     1013a3 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101376:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10137b:	8d 50 01             	lea    0x1(%eax),%edx
  10137e:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101384:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101387:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10138d:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101392:	3d 00 02 00 00       	cmp    $0x200,%eax
  101397:	75 0a                	jne    1013a3 <cons_intr+0x3b>
                cons.wpos = 0;
  101399:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013a0:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1013a6:	ff d0                	call   *%eax
  1013a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013ab:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013af:	75 bf                	jne    101370 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013b1:	90                   	nop
  1013b2:	c9                   	leave  
  1013b3:	c3                   	ret    

001013b4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013b4:	55                   	push   %ebp
  1013b5:	89 e5                	mov    %esp,%ebp
  1013b7:	83 ec 10             	sub    $0x10,%esp
  1013ba:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1013c3:	89 c2                	mov    %eax,%edx
  1013c5:	ec                   	in     (%dx),%al
  1013c6:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1013c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013cd:	0f b6 c0             	movzbl %al,%eax
  1013d0:	83 e0 01             	and    $0x1,%eax
  1013d3:	85 c0                	test   %eax,%eax
  1013d5:	75 07                	jne    1013de <serial_proc_data+0x2a>
        return -1;
  1013d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013dc:	eb 2a                	jmp    101408 <serial_proc_data+0x54>
  1013de:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013e8:	89 c2                	mov    %eax,%edx
  1013ea:	ec                   	in     (%dx),%al
  1013eb:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  1013ee:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013f2:	0f b6 c0             	movzbl %al,%eax
  1013f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013f8:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013fc:	75 07                	jne    101405 <serial_proc_data+0x51>
        c = '\b';
  1013fe:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101405:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101408:	c9                   	leave  
  101409:	c3                   	ret    

0010140a <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10140a:	55                   	push   %ebp
  10140b:	89 e5                	mov    %esp,%ebp
  10140d:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101410:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101415:	85 c0                	test   %eax,%eax
  101417:	74 0c                	je     101425 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101419:	c7 04 24 b4 13 10 00 	movl   $0x1013b4,(%esp)
  101420:	e8 43 ff ff ff       	call   101368 <cons_intr>
    }
}
  101425:	90                   	nop
  101426:	c9                   	leave  
  101427:	c3                   	ret    

00101428 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101428:	55                   	push   %ebp
  101429:	89 e5                	mov    %esp,%ebp
  10142b:	83 ec 28             	sub    $0x28,%esp
  10142e:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101434:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101437:	89 c2                	mov    %eax,%edx
  101439:	ec                   	in     (%dx),%al
  10143a:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10143d:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101441:	0f b6 c0             	movzbl %al,%eax
  101444:	83 e0 01             	and    $0x1,%eax
  101447:	85 c0                	test   %eax,%eax
  101449:	75 0a                	jne    101455 <kbd_proc_data+0x2d>
        return -1;
  10144b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101450:	e9 56 01 00 00       	jmp    1015ab <kbd_proc_data+0x183>
  101455:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10145e:	89 c2                	mov    %eax,%edx
  101460:	ec                   	in     (%dx),%al
  101461:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  101464:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  101468:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10146b:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10146f:	75 17                	jne    101488 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101471:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101476:	83 c8 40             	or     $0x40,%eax
  101479:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10147e:	b8 00 00 00 00       	mov    $0x0,%eax
  101483:	e9 23 01 00 00       	jmp    1015ab <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  101488:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148c:	84 c0                	test   %al,%al
  10148e:	79 45                	jns    1014d5 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101490:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101495:	83 e0 40             	and    $0x40,%eax
  101498:	85 c0                	test   %eax,%eax
  10149a:	75 08                	jne    1014a4 <kbd_proc_data+0x7c>
  10149c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a0:	24 7f                	and    $0x7f,%al
  1014a2:	eb 04                	jmp    1014a8 <kbd_proc_data+0x80>
  1014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a8:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014ab:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014af:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014b6:	0c 40                	or     $0x40,%al
  1014b8:	0f b6 c0             	movzbl %al,%eax
  1014bb:	f7 d0                	not    %eax
  1014bd:	89 c2                	mov    %eax,%edx
  1014bf:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014c4:	21 d0                	and    %edx,%eax
  1014c6:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014cb:	b8 00 00 00 00       	mov    $0x0,%eax
  1014d0:	e9 d6 00 00 00       	jmp    1015ab <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014d5:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014da:	83 e0 40             	and    $0x40,%eax
  1014dd:	85 c0                	test   %eax,%eax
  1014df:	74 11                	je     1014f2 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014e1:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014e5:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014ea:	83 e0 bf             	and    $0xffffffbf,%eax
  1014ed:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  1014f2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f6:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014fd:	0f b6 d0             	movzbl %al,%edx
  101500:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101505:	09 d0                	or     %edx,%eax
  101507:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10150c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101510:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101517:	0f b6 d0             	movzbl %al,%edx
  10151a:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10151f:	31 d0                	xor    %edx,%eax
  101521:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101526:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152b:	83 e0 03             	and    $0x3,%eax
  10152e:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101539:	01 d0                	add    %edx,%eax
  10153b:	0f b6 00             	movzbl (%eax),%eax
  10153e:	0f b6 c0             	movzbl %al,%eax
  101541:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101544:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101549:	83 e0 08             	and    $0x8,%eax
  10154c:	85 c0                	test   %eax,%eax
  10154e:	74 22                	je     101572 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101550:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101554:	7e 0c                	jle    101562 <kbd_proc_data+0x13a>
  101556:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10155a:	7f 06                	jg     101562 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  10155c:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101560:	eb 10                	jmp    101572 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101562:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101566:	7e 0a                	jle    101572 <kbd_proc_data+0x14a>
  101568:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10156c:	7f 04                	jg     101572 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10156e:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101572:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101577:	f7 d0                	not    %eax
  101579:	83 e0 06             	and    $0x6,%eax
  10157c:	85 c0                	test   %eax,%eax
  10157e:	75 28                	jne    1015a8 <kbd_proc_data+0x180>
  101580:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101587:	75 1f                	jne    1015a8 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101589:	c7 04 24 ad 61 10 00 	movl   $0x1061ad,(%esp)
  101590:	e8 fd ec ff ff       	call   100292 <cprintf>
  101595:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  10159b:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10159f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1015a3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1015a7:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015ab:	c9                   	leave  
  1015ac:	c3                   	ret    

001015ad <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015ad:	55                   	push   %ebp
  1015ae:	89 e5                	mov    %esp,%ebp
  1015b0:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015b3:	c7 04 24 28 14 10 00 	movl   $0x101428,(%esp)
  1015ba:	e8 a9 fd ff ff       	call   101368 <cons_intr>
}
  1015bf:	90                   	nop
  1015c0:	c9                   	leave  
  1015c1:	c3                   	ret    

001015c2 <kbd_init>:

static void
kbd_init(void) {
  1015c2:	55                   	push   %ebp
  1015c3:	89 e5                	mov    %esp,%ebp
  1015c5:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015c8:	e8 e0 ff ff ff       	call   1015ad <kbd_intr>
    pic_enable(IRQ_KBD);
  1015cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015d4:	e8 34 01 00 00       	call   10170d <pic_enable>
}
  1015d9:	90                   	nop
  1015da:	c9                   	leave  
  1015db:	c3                   	ret    

001015dc <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015dc:	55                   	push   %ebp
  1015dd:	89 e5                	mov    %esp,%ebp
  1015df:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015e2:	e8 90 f8 ff ff       	call   100e77 <cga_init>
    serial_init();
  1015e7:	e8 6d f9 ff ff       	call   100f59 <serial_init>
    kbd_init();
  1015ec:	e8 d1 ff ff ff       	call   1015c2 <kbd_init>
    if (!serial_exists) {
  1015f1:	a1 48 a4 11 00       	mov    0x11a448,%eax
  1015f6:	85 c0                	test   %eax,%eax
  1015f8:	75 0c                	jne    101606 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015fa:	c7 04 24 b9 61 10 00 	movl   $0x1061b9,(%esp)
  101601:	e8 8c ec ff ff       	call   100292 <cprintf>
    }
}
  101606:	90                   	nop
  101607:	c9                   	leave  
  101608:	c3                   	ret    

00101609 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101609:	55                   	push   %ebp
  10160a:	89 e5                	mov    %esp,%ebp
  10160c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10160f:	e8 de f7 ff ff       	call   100df2 <__intr_save>
  101614:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101617:	8b 45 08             	mov    0x8(%ebp),%eax
  10161a:	89 04 24             	mov    %eax,(%esp)
  10161d:	e8 8d fa ff ff       	call   1010af <lpt_putc>
        cga_putc(c);
  101622:	8b 45 08             	mov    0x8(%ebp),%eax
  101625:	89 04 24             	mov    %eax,(%esp)
  101628:	e8 c2 fa ff ff       	call   1010ef <cga_putc>
        serial_putc(c);
  10162d:	8b 45 08             	mov    0x8(%ebp),%eax
  101630:	89 04 24             	mov    %eax,(%esp)
  101633:	e8 f0 fc ff ff       	call   101328 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 d9 f7 ff ff       	call   100e1c <__intr_restore>
}
  101643:	90                   	nop
  101644:	c9                   	leave  
  101645:	c3                   	ret    

00101646 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101646:	55                   	push   %ebp
  101647:	89 e5                	mov    %esp,%ebp
  101649:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10164c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101653:	e8 9a f7 ff ff       	call   100df2 <__intr_save>
  101658:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  10165b:	e8 aa fd ff ff       	call   10140a <serial_intr>
        kbd_intr();
  101660:	e8 48 ff ff ff       	call   1015ad <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101665:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  10166b:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101670:	39 c2                	cmp    %eax,%edx
  101672:	74 31                	je     1016a5 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101674:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101679:	8d 50 01             	lea    0x1(%eax),%edx
  10167c:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  101682:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101689:	0f b6 c0             	movzbl %al,%eax
  10168c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10168f:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101694:	3d 00 02 00 00       	cmp    $0x200,%eax
  101699:	75 0a                	jne    1016a5 <cons_getc+0x5f>
                cons.rpos = 0;
  10169b:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016a2:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016a8:	89 04 24             	mov    %eax,(%esp)
  1016ab:	e8 6c f7 ff ff       	call   100e1c <__intr_restore>
    return c;
  1016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016b3:	c9                   	leave  
  1016b4:	c3                   	ret    

001016b5 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016b5:	55                   	push   %ebp
  1016b6:	89 e5                	mov    %esp,%ebp
  1016b8:	83 ec 14             	sub    $0x14,%esp
  1016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1016be:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016c5:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016cb:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016d0:	85 c0                	test   %eax,%eax
  1016d2:	74 36                	je     10170a <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  1016d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d7:	0f b6 c0             	movzbl %al,%eax
  1016da:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e0:	88 45 fa             	mov    %al,-0x6(%ebp)
  1016e3:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  1016e7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016eb:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f0:	c1 e8 08             	shr    $0x8,%eax
  1016f3:	0f b7 c0             	movzwl %ax,%eax
  1016f6:	0f b6 c0             	movzbl %al,%eax
  1016f9:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  1016ff:	88 45 fb             	mov    %al,-0x5(%ebp)
  101702:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101706:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101709:	ee                   	out    %al,(%dx)
    }
}
  10170a:	90                   	nop
  10170b:	c9                   	leave  
  10170c:	c3                   	ret    

0010170d <pic_enable>:

void
pic_enable(unsigned int irq) {
  10170d:	55                   	push   %ebp
  10170e:	89 e5                	mov    %esp,%ebp
  101710:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101713:	8b 45 08             	mov    0x8(%ebp),%eax
  101716:	ba 01 00 00 00       	mov    $0x1,%edx
  10171b:	88 c1                	mov    %al,%cl
  10171d:	d3 e2                	shl    %cl,%edx
  10171f:	89 d0                	mov    %edx,%eax
  101721:	98                   	cwtl   
  101722:	f7 d0                	not    %eax
  101724:	0f bf d0             	movswl %ax,%edx
  101727:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10172e:	98                   	cwtl   
  10172f:	21 d0                	and    %edx,%eax
  101731:	98                   	cwtl   
  101732:	0f b7 c0             	movzwl %ax,%eax
  101735:	89 04 24             	mov    %eax,(%esp)
  101738:	e8 78 ff ff ff       	call   1016b5 <pic_setmask>
}
  10173d:	90                   	nop
  10173e:	c9                   	leave  
  10173f:	c3                   	ret    

00101740 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101740:	55                   	push   %ebp
  101741:	89 e5                	mov    %esp,%ebp
  101743:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
  101746:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10174d:	00 00 00 
  101750:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101756:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  10175a:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  10175e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101762:	ee                   	out    %al,(%dx)
  101763:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101769:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  10176d:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  101771:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101774:	ee                   	out    %al,(%dx)
  101775:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  10177b:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  10177f:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101787:	ee                   	out    %al,(%dx)
  101788:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  10178e:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101792:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101796:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101799:	ee                   	out    %al,(%dx)
  10179a:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  1017a0:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  1017a4:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  1017a8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017ac:	ee                   	out    %al,(%dx)
  1017ad:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  1017b3:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  1017b7:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1017be:	ee                   	out    %al,(%dx)
  1017bf:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  1017c5:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  1017c9:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1017cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017d1:	ee                   	out    %al,(%dx)
  1017d2:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  1017d8:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  1017dc:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1017e3:	ee                   	out    %al,(%dx)
  1017e4:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1017ea:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  1017ee:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  1017f2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017f6:	ee                   	out    %al,(%dx)
  1017f7:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  1017fd:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101801:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101805:	8b 55 ec             	mov    -0x14(%ebp),%edx
  101808:	ee                   	out    %al,(%dx)
  101809:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  10180f:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101813:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  101817:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10181b:	ee                   	out    %al,(%dx)
  10181c:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101822:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  101826:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10182a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10182d:	ee                   	out    %al,(%dx)
  10182e:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101834:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  101838:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  10183c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101840:	ee                   	out    %al,(%dx)
  101841:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  101847:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  10184b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10184f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101852:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101853:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10185a:	3d ff ff 00 00       	cmp    $0xffff,%eax
  10185f:	74 0f                	je     101870 <pic_init+0x130>
        pic_setmask(irq_mask);
  101861:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101868:	89 04 24             	mov    %eax,(%esp)
  10186b:	e8 45 fe ff ff       	call   1016b5 <pic_setmask>
    }
}
  101870:	90                   	nop
  101871:	c9                   	leave  
  101872:	c3                   	ret    

00101873 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101873:	55                   	push   %ebp
  101874:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101876:	fb                   	sti    
    sti();
}
  101877:	90                   	nop
  101878:	5d                   	pop    %ebp
  101879:	c3                   	ret    

0010187a <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10187a:	55                   	push   %ebp
  10187b:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10187d:	fa                   	cli    
    cli();
}
  10187e:	90                   	nop
  10187f:	5d                   	pop    %ebp
  101880:	c3                   	ret    

00101881 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101881:	55                   	push   %ebp
  101882:	89 e5                	mov    %esp,%ebp
  101884:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101887:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10188e:	00 
  10188f:	c7 04 24 e0 61 10 00 	movl   $0x1061e0,(%esp)
  101896:	e8 f7 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  10189b:	90                   	nop
  10189c:	c9                   	leave  
  10189d:	c3                   	ret    

0010189e <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10189e:	55                   	push   %ebp
  10189f:	89 e5                	mov    %esp,%ebp
  1018a1:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
  1018a4:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
      for(int i=0;i<length;i++)
  1018ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018b2:	e9 c4 00 00 00       	jmp    10197b <idt_init+0xdd>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ba:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018c1:	0f b7 d0             	movzwl %ax,%edx
  1018c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c7:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018ce:	00 
  1018cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d2:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018d9:	00 08 00 
  1018dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018df:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018e6:	00 
  1018e7:	80 e2 e0             	and    $0xe0,%dl
  1018ea:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f4:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018fb:	00 
  1018fc:	80 e2 1f             	and    $0x1f,%dl
  1018ff:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101906:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101909:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101910:	00 
  101911:	80 e2 f0             	and    $0xf0,%dl
  101914:	80 ca 0e             	or     $0xe,%dl
  101917:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10191e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101921:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101928:	00 
  101929:	80 e2 ef             	and    $0xef,%dl
  10192c:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101933:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101936:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10193d:	00 
  10193e:	80 e2 9f             	and    $0x9f,%dl
  101941:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101948:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194b:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101952:	00 
  101953:	80 ca 80             	or     $0x80,%dl
  101956:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10195d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101960:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101967:	c1 e8 10             	shr    $0x10,%eax
  10196a:	0f b7 d0             	movzwl %ax,%edx
  10196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101970:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101977:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
      for(int i=0;i<length;i++)
  101978:	ff 45 fc             	incl   -0x4(%ebp)
  10197b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  101981:	0f 8c 30 ff ff ff    	jl     1018b7 <idt_init+0x19>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
      SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101987:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  10198c:	0f b7 c0             	movzwl %ax,%eax
  10198f:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  101995:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  10199c:	08 00 
  10199e:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019a5:	24 e0                	and    $0xe0,%al
  1019a7:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019ac:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019b3:	24 1f                	and    $0x1f,%al
  1019b5:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019ba:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019c1:	24 f0                	and    $0xf0,%al
  1019c3:	0c 0e                	or     $0xe,%al
  1019c5:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019ca:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019d1:	24 ef                	and    $0xef,%al
  1019d3:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019d8:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019df:	0c 60                	or     $0x60,%al
  1019e1:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019e6:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019ed:	0c 80                	or     $0x80,%al
  1019ef:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019f4:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019f9:	c1 e8 10             	shr    $0x10,%eax
  1019fc:	0f b7 c0             	movzwl %ax,%eax
  1019ff:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a05:	c7 45 f4 60 75 11 00 	movl   $0x117560,-0xc(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101a0f:	0f 01 18             	lidtl  (%eax)
      lidt(&idt_pd);

}
  101a12:	90                   	nop
  101a13:	c9                   	leave  
  101a14:	c3                   	ret    

00101a15 <trapname>:

static const char *
trapname(int trapno) {
  101a15:	55                   	push   %ebp
  101a16:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a18:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1b:	83 f8 13             	cmp    $0x13,%eax
  101a1e:	77 0c                	ja     101a2c <trapname+0x17>
        return excnames[trapno];
  101a20:	8b 45 08             	mov    0x8(%ebp),%eax
  101a23:	8b 04 85 40 65 10 00 	mov    0x106540(,%eax,4),%eax
  101a2a:	eb 18                	jmp    101a44 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a2c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a30:	7e 0d                	jle    101a3f <trapname+0x2a>
  101a32:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a36:	7f 07                	jg     101a3f <trapname+0x2a>
        return "Hardware Interrupt";
  101a38:	b8 ea 61 10 00       	mov    $0x1061ea,%eax
  101a3d:	eb 05                	jmp    101a44 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a3f:	b8 fd 61 10 00       	mov    $0x1061fd,%eax
}
  101a44:	5d                   	pop    %ebp
  101a45:	c3                   	ret    

00101a46 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a46:	55                   	push   %ebp
  101a47:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a49:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a50:	83 f8 08             	cmp    $0x8,%eax
  101a53:	0f 94 c0             	sete   %al
  101a56:	0f b6 c0             	movzbl %al,%eax
}
  101a59:	5d                   	pop    %ebp
  101a5a:	c3                   	ret    

00101a5b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a5b:	55                   	push   %ebp
  101a5c:	89 e5                	mov    %esp,%ebp
  101a5e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a61:	8b 45 08             	mov    0x8(%ebp),%eax
  101a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a68:	c7 04 24 3e 62 10 00 	movl   $0x10623e,(%esp)
  101a6f:	e8 1e e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a74:	8b 45 08             	mov    0x8(%ebp),%eax
  101a77:	89 04 24             	mov    %eax,(%esp)
  101a7a:	e8 91 01 00 00       	call   101c10 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a82:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a8a:	c7 04 24 4f 62 10 00 	movl   $0x10624f,(%esp)
  101a91:	e8 fc e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a96:	8b 45 08             	mov    0x8(%ebp),%eax
  101a99:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa1:	c7 04 24 62 62 10 00 	movl   $0x106262,(%esp)
  101aa8:	e8 e5 e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aad:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab0:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab8:	c7 04 24 75 62 10 00 	movl   $0x106275,(%esp)
  101abf:	e8 ce e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac7:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acf:	c7 04 24 88 62 10 00 	movl   $0x106288,(%esp)
  101ad6:	e8 b7 e7 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101adb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ade:	8b 40 30             	mov    0x30(%eax),%eax
  101ae1:	89 04 24             	mov    %eax,(%esp)
  101ae4:	e8 2c ff ff ff       	call   101a15 <trapname>
  101ae9:	89 c2                	mov    %eax,%edx
  101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  101aee:	8b 40 30             	mov    0x30(%eax),%eax
  101af1:	89 54 24 08          	mov    %edx,0x8(%esp)
  101af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af9:	c7 04 24 9b 62 10 00 	movl   $0x10629b,(%esp)
  101b00:	e8 8d e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b05:	8b 45 08             	mov    0x8(%ebp),%eax
  101b08:	8b 40 34             	mov    0x34(%eax),%eax
  101b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0f:	c7 04 24 ad 62 10 00 	movl   $0x1062ad,(%esp)
  101b16:	e8 77 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1e:	8b 40 38             	mov    0x38(%eax),%eax
  101b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b25:	c7 04 24 bc 62 10 00 	movl   $0x1062bc,(%esp)
  101b2c:	e8 61 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b31:	8b 45 08             	mov    0x8(%ebp),%eax
  101b34:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3c:	c7 04 24 cb 62 10 00 	movl   $0x1062cb,(%esp)
  101b43:	e8 4a e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b48:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4b:	8b 40 40             	mov    0x40(%eax),%eax
  101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b52:	c7 04 24 de 62 10 00 	movl   $0x1062de,(%esp)
  101b59:	e8 34 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b65:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b6c:	eb 3d                	jmp    101bab <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	8b 50 40             	mov    0x40(%eax),%edx
  101b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b77:	21 d0                	and    %edx,%eax
  101b79:	85 c0                	test   %eax,%eax
  101b7b:	74 28                	je     101ba5 <print_trapframe+0x14a>
  101b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b80:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b87:	85 c0                	test   %eax,%eax
  101b89:	74 1a                	je     101ba5 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b8e:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b99:	c7 04 24 ed 62 10 00 	movl   $0x1062ed,(%esp)
  101ba0:	e8 ed e6 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba5:	ff 45 f4             	incl   -0xc(%ebp)
  101ba8:	d1 65 f0             	shll   -0x10(%ebp)
  101bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bae:	83 f8 17             	cmp    $0x17,%eax
  101bb1:	76 bb                	jbe    101b6e <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb6:	8b 40 40             	mov    0x40(%eax),%eax
  101bb9:	25 00 30 00 00       	and    $0x3000,%eax
  101bbe:	c1 e8 0c             	shr    $0xc,%eax
  101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc5:	c7 04 24 f1 62 10 00 	movl   $0x1062f1,(%esp)
  101bcc:	e8 c1 e6 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd4:	89 04 24             	mov    %eax,(%esp)
  101bd7:	e8 6a fe ff ff       	call   101a46 <trap_in_kernel>
  101bdc:	85 c0                	test   %eax,%eax
  101bde:	75 2d                	jne    101c0d <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101be0:	8b 45 08             	mov    0x8(%ebp),%eax
  101be3:	8b 40 44             	mov    0x44(%eax),%eax
  101be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bea:	c7 04 24 fa 62 10 00 	movl   $0x1062fa,(%esp)
  101bf1:	e8 9c e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf9:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c01:	c7 04 24 09 63 10 00 	movl   $0x106309,(%esp)
  101c08:	e8 85 e6 ff ff       	call   100292 <cprintf>
    }
}
  101c0d:	90                   	nop
  101c0e:	c9                   	leave  
  101c0f:	c3                   	ret    

00101c10 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c10:	55                   	push   %ebp
  101c11:	89 e5                	mov    %esp,%ebp
  101c13:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c16:	8b 45 08             	mov    0x8(%ebp),%eax
  101c19:	8b 00                	mov    (%eax),%eax
  101c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1f:	c7 04 24 1c 63 10 00 	movl   $0x10631c,(%esp)
  101c26:	e8 67 e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2e:	8b 40 04             	mov    0x4(%eax),%eax
  101c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c35:	c7 04 24 2b 63 10 00 	movl   $0x10632b,(%esp)
  101c3c:	e8 51 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c41:	8b 45 08             	mov    0x8(%ebp),%eax
  101c44:	8b 40 08             	mov    0x8(%eax),%eax
  101c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4b:	c7 04 24 3a 63 10 00 	movl   $0x10633a,(%esp)
  101c52:	e8 3b e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c57:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5a:	8b 40 0c             	mov    0xc(%eax),%eax
  101c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c61:	c7 04 24 49 63 10 00 	movl   $0x106349,(%esp)
  101c68:	e8 25 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c70:	8b 40 10             	mov    0x10(%eax),%eax
  101c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c77:	c7 04 24 58 63 10 00 	movl   $0x106358,(%esp)
  101c7e:	e8 0f e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c83:	8b 45 08             	mov    0x8(%ebp),%eax
  101c86:	8b 40 14             	mov    0x14(%eax),%eax
  101c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c8d:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  101c94:	e8 f9 e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c99:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9c:	8b 40 18             	mov    0x18(%eax),%eax
  101c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca3:	c7 04 24 76 63 10 00 	movl   $0x106376,(%esp)
  101caa:	e8 e3 e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101caf:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb2:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb9:	c7 04 24 85 63 10 00 	movl   $0x106385,(%esp)
  101cc0:	e8 cd e5 ff ff       	call   100292 <cprintf>
}
  101cc5:	90                   	nop
  101cc6:	c9                   	leave  
  101cc7:	c3                   	ret    

00101cc8 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cc8:	55                   	push   %ebp
  101cc9:	89 e5                	mov    %esp,%ebp
  101ccb:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101cce:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd1:	8b 40 30             	mov    0x30(%eax),%eax
  101cd4:	83 f8 2f             	cmp    $0x2f,%eax
  101cd7:	77 21                	ja     101cfa <trap_dispatch+0x32>
  101cd9:	83 f8 2e             	cmp    $0x2e,%eax
  101cdc:	0f 83 0c 01 00 00    	jae    101dee <trap_dispatch+0x126>
  101ce2:	83 f8 21             	cmp    $0x21,%eax
  101ce5:	0f 84 8c 00 00 00    	je     101d77 <trap_dispatch+0xaf>
  101ceb:	83 f8 24             	cmp    $0x24,%eax
  101cee:	74 61                	je     101d51 <trap_dispatch+0x89>
  101cf0:	83 f8 20             	cmp    $0x20,%eax
  101cf3:	74 16                	je     101d0b <trap_dispatch+0x43>
  101cf5:	e9 bf 00 00 00       	jmp    101db9 <trap_dispatch+0xf1>
  101cfa:	83 e8 78             	sub    $0x78,%eax
  101cfd:	83 f8 01             	cmp    $0x1,%eax
  101d00:	0f 87 b3 00 00 00    	ja     101db9 <trap_dispatch+0xf1>
  101d06:	e9 92 00 00 00       	jmp    101d9d <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d0b:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d10:	40                   	inc    %eax
  101d11:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if(ticks % TICK_NUM==0)  print_ticks();
  101d16:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d1c:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d21:	89 c8                	mov    %ecx,%eax
  101d23:	f7 e2                	mul    %edx
  101d25:	c1 ea 05             	shr    $0x5,%edx
  101d28:	89 d0                	mov    %edx,%eax
  101d2a:	c1 e0 02             	shl    $0x2,%eax
  101d2d:	01 d0                	add    %edx,%eax
  101d2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d36:	01 d0                	add    %edx,%eax
  101d38:	c1 e0 02             	shl    $0x2,%eax
  101d3b:	29 c1                	sub    %eax,%ecx
  101d3d:	89 ca                	mov    %ecx,%edx
  101d3f:	85 d2                	test   %edx,%edx
  101d41:	0f 85 aa 00 00 00    	jne    101df1 <trap_dispatch+0x129>
  101d47:	e8 35 fb ff ff       	call   101881 <print_ticks>
        break;
  101d4c:	e9 a0 00 00 00       	jmp    101df1 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d51:	e8 f0 f8 ff ff       	call   101646 <cons_getc>
  101d56:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d59:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d5d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d61:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d69:	c7 04 24 94 63 10 00 	movl   $0x106394,(%esp)
  101d70:	e8 1d e5 ff ff       	call   100292 <cprintf>
        break;
  101d75:	eb 7b                	jmp    101df2 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d77:	e8 ca f8 ff ff       	call   101646 <cons_getc>
  101d7c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d7f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d83:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d87:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d8f:	c7 04 24 a6 63 10 00 	movl   $0x1063a6,(%esp)
  101d96:	e8 f7 e4 ff ff       	call   100292 <cprintf>
        break;
  101d9b:	eb 55                	jmp    101df2 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d9d:	c7 44 24 08 b5 63 10 	movl   $0x1063b5,0x8(%esp)
  101da4:	00 
  101da5:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
  101dac:	00 
  101dad:	c7 04 24 c5 63 10 00 	movl   $0x1063c5,(%esp)
  101db4:	e8 30 e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101db9:	8b 45 08             	mov    0x8(%ebp),%eax
  101dbc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dc0:	83 e0 03             	and    $0x3,%eax
  101dc3:	85 c0                	test   %eax,%eax
  101dc5:	75 2b                	jne    101df2 <trap_dispatch+0x12a>
            print_trapframe(tf);
  101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dca:	89 04 24             	mov    %eax,(%esp)
  101dcd:	e8 89 fc ff ff       	call   101a5b <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101dd2:	c7 44 24 08 d6 63 10 	movl   $0x1063d6,0x8(%esp)
  101dd9:	00 
  101dda:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  101de1:	00 
  101de2:	c7 04 24 c5 63 10 00 	movl   $0x1063c5,(%esp)
  101de9:	e8 fb e5 ff ff       	call   1003e9 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101dee:	90                   	nop
  101def:	eb 01                	jmp    101df2 <trap_dispatch+0x12a>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
        if(ticks % TICK_NUM==0)  print_ticks();
        break;
  101df1:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101df2:	90                   	nop
  101df3:	c9                   	leave  
  101df4:	c3                   	ret    

00101df5 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101df5:	55                   	push   %ebp
  101df6:	89 e5                	mov    %esp,%ebp
  101df8:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfe:	89 04 24             	mov    %eax,(%esp)
  101e01:	e8 c2 fe ff ff       	call   101cc8 <trap_dispatch>
}
  101e06:	90                   	nop
  101e07:	c9                   	leave  
  101e08:	c3                   	ret    

00101e09 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e09:	6a 00                	push   $0x0
  pushl $0
  101e0b:	6a 00                	push   $0x0
  jmp __alltraps
  101e0d:	e9 69 0a 00 00       	jmp    10287b <__alltraps>

00101e12 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $1
  101e14:	6a 01                	push   $0x1
  jmp __alltraps
  101e16:	e9 60 0a 00 00       	jmp    10287b <__alltraps>

00101e1b <vector2>:
.globl vector2
vector2:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $2
  101e1d:	6a 02                	push   $0x2
  jmp __alltraps
  101e1f:	e9 57 0a 00 00       	jmp    10287b <__alltraps>

00101e24 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e24:	6a 00                	push   $0x0
  pushl $3
  101e26:	6a 03                	push   $0x3
  jmp __alltraps
  101e28:	e9 4e 0a 00 00       	jmp    10287b <__alltraps>

00101e2d <vector4>:
.globl vector4
vector4:
  pushl $0
  101e2d:	6a 00                	push   $0x0
  pushl $4
  101e2f:	6a 04                	push   $0x4
  jmp __alltraps
  101e31:	e9 45 0a 00 00       	jmp    10287b <__alltraps>

00101e36 <vector5>:
.globl vector5
vector5:
  pushl $0
  101e36:	6a 00                	push   $0x0
  pushl $5
  101e38:	6a 05                	push   $0x5
  jmp __alltraps
  101e3a:	e9 3c 0a 00 00       	jmp    10287b <__alltraps>

00101e3f <vector6>:
.globl vector6
vector6:
  pushl $0
  101e3f:	6a 00                	push   $0x0
  pushl $6
  101e41:	6a 06                	push   $0x6
  jmp __alltraps
  101e43:	e9 33 0a 00 00       	jmp    10287b <__alltraps>

00101e48 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e48:	6a 00                	push   $0x0
  pushl $7
  101e4a:	6a 07                	push   $0x7
  jmp __alltraps
  101e4c:	e9 2a 0a 00 00       	jmp    10287b <__alltraps>

00101e51 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e51:	6a 08                	push   $0x8
  jmp __alltraps
  101e53:	e9 23 0a 00 00       	jmp    10287b <__alltraps>

00101e58 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e58:	6a 00                	push   $0x0
  pushl $9
  101e5a:	6a 09                	push   $0x9
  jmp __alltraps
  101e5c:	e9 1a 0a 00 00       	jmp    10287b <__alltraps>

00101e61 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e61:	6a 0a                	push   $0xa
  jmp __alltraps
  101e63:	e9 13 0a 00 00       	jmp    10287b <__alltraps>

00101e68 <vector11>:
.globl vector11
vector11:
  pushl $11
  101e68:	6a 0b                	push   $0xb
  jmp __alltraps
  101e6a:	e9 0c 0a 00 00       	jmp    10287b <__alltraps>

00101e6f <vector12>:
.globl vector12
vector12:
  pushl $12
  101e6f:	6a 0c                	push   $0xc
  jmp __alltraps
  101e71:	e9 05 0a 00 00       	jmp    10287b <__alltraps>

00101e76 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e76:	6a 0d                	push   $0xd
  jmp __alltraps
  101e78:	e9 fe 09 00 00       	jmp    10287b <__alltraps>

00101e7d <vector14>:
.globl vector14
vector14:
  pushl $14
  101e7d:	6a 0e                	push   $0xe
  jmp __alltraps
  101e7f:	e9 f7 09 00 00       	jmp    10287b <__alltraps>

00101e84 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e84:	6a 00                	push   $0x0
  pushl $15
  101e86:	6a 0f                	push   $0xf
  jmp __alltraps
  101e88:	e9 ee 09 00 00       	jmp    10287b <__alltraps>

00101e8d <vector16>:
.globl vector16
vector16:
  pushl $0
  101e8d:	6a 00                	push   $0x0
  pushl $16
  101e8f:	6a 10                	push   $0x10
  jmp __alltraps
  101e91:	e9 e5 09 00 00       	jmp    10287b <__alltraps>

00101e96 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e96:	6a 11                	push   $0x11
  jmp __alltraps
  101e98:	e9 de 09 00 00       	jmp    10287b <__alltraps>

00101e9d <vector18>:
.globl vector18
vector18:
  pushl $0
  101e9d:	6a 00                	push   $0x0
  pushl $18
  101e9f:	6a 12                	push   $0x12
  jmp __alltraps
  101ea1:	e9 d5 09 00 00       	jmp    10287b <__alltraps>

00101ea6 <vector19>:
.globl vector19
vector19:
  pushl $0
  101ea6:	6a 00                	push   $0x0
  pushl $19
  101ea8:	6a 13                	push   $0x13
  jmp __alltraps
  101eaa:	e9 cc 09 00 00       	jmp    10287b <__alltraps>

00101eaf <vector20>:
.globl vector20
vector20:
  pushl $0
  101eaf:	6a 00                	push   $0x0
  pushl $20
  101eb1:	6a 14                	push   $0x14
  jmp __alltraps
  101eb3:	e9 c3 09 00 00       	jmp    10287b <__alltraps>

00101eb8 <vector21>:
.globl vector21
vector21:
  pushl $0
  101eb8:	6a 00                	push   $0x0
  pushl $21
  101eba:	6a 15                	push   $0x15
  jmp __alltraps
  101ebc:	e9 ba 09 00 00       	jmp    10287b <__alltraps>

00101ec1 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ec1:	6a 00                	push   $0x0
  pushl $22
  101ec3:	6a 16                	push   $0x16
  jmp __alltraps
  101ec5:	e9 b1 09 00 00       	jmp    10287b <__alltraps>

00101eca <vector23>:
.globl vector23
vector23:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $23
  101ecc:	6a 17                	push   $0x17
  jmp __alltraps
  101ece:	e9 a8 09 00 00       	jmp    10287b <__alltraps>

00101ed3 <vector24>:
.globl vector24
vector24:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $24
  101ed5:	6a 18                	push   $0x18
  jmp __alltraps
  101ed7:	e9 9f 09 00 00       	jmp    10287b <__alltraps>

00101edc <vector25>:
.globl vector25
vector25:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $25
  101ede:	6a 19                	push   $0x19
  jmp __alltraps
  101ee0:	e9 96 09 00 00       	jmp    10287b <__alltraps>

00101ee5 <vector26>:
.globl vector26
vector26:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $26
  101ee7:	6a 1a                	push   $0x1a
  jmp __alltraps
  101ee9:	e9 8d 09 00 00       	jmp    10287b <__alltraps>

00101eee <vector27>:
.globl vector27
vector27:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $27
  101ef0:	6a 1b                	push   $0x1b
  jmp __alltraps
  101ef2:	e9 84 09 00 00       	jmp    10287b <__alltraps>

00101ef7 <vector28>:
.globl vector28
vector28:
  pushl $0
  101ef7:	6a 00                	push   $0x0
  pushl $28
  101ef9:	6a 1c                	push   $0x1c
  jmp __alltraps
  101efb:	e9 7b 09 00 00       	jmp    10287b <__alltraps>

00101f00 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f00:	6a 00                	push   $0x0
  pushl $29
  101f02:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f04:	e9 72 09 00 00       	jmp    10287b <__alltraps>

00101f09 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $30
  101f0b:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f0d:	e9 69 09 00 00       	jmp    10287b <__alltraps>

00101f12 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f12:	6a 00                	push   $0x0
  pushl $31
  101f14:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f16:	e9 60 09 00 00       	jmp    10287b <__alltraps>

00101f1b <vector32>:
.globl vector32
vector32:
  pushl $0
  101f1b:	6a 00                	push   $0x0
  pushl $32
  101f1d:	6a 20                	push   $0x20
  jmp __alltraps
  101f1f:	e9 57 09 00 00       	jmp    10287b <__alltraps>

00101f24 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f24:	6a 00                	push   $0x0
  pushl $33
  101f26:	6a 21                	push   $0x21
  jmp __alltraps
  101f28:	e9 4e 09 00 00       	jmp    10287b <__alltraps>

00101f2d <vector34>:
.globl vector34
vector34:
  pushl $0
  101f2d:	6a 00                	push   $0x0
  pushl $34
  101f2f:	6a 22                	push   $0x22
  jmp __alltraps
  101f31:	e9 45 09 00 00       	jmp    10287b <__alltraps>

00101f36 <vector35>:
.globl vector35
vector35:
  pushl $0
  101f36:	6a 00                	push   $0x0
  pushl $35
  101f38:	6a 23                	push   $0x23
  jmp __alltraps
  101f3a:	e9 3c 09 00 00       	jmp    10287b <__alltraps>

00101f3f <vector36>:
.globl vector36
vector36:
  pushl $0
  101f3f:	6a 00                	push   $0x0
  pushl $36
  101f41:	6a 24                	push   $0x24
  jmp __alltraps
  101f43:	e9 33 09 00 00       	jmp    10287b <__alltraps>

00101f48 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f48:	6a 00                	push   $0x0
  pushl $37
  101f4a:	6a 25                	push   $0x25
  jmp __alltraps
  101f4c:	e9 2a 09 00 00       	jmp    10287b <__alltraps>

00101f51 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f51:	6a 00                	push   $0x0
  pushl $38
  101f53:	6a 26                	push   $0x26
  jmp __alltraps
  101f55:	e9 21 09 00 00       	jmp    10287b <__alltraps>

00101f5a <vector39>:
.globl vector39
vector39:
  pushl $0
  101f5a:	6a 00                	push   $0x0
  pushl $39
  101f5c:	6a 27                	push   $0x27
  jmp __alltraps
  101f5e:	e9 18 09 00 00       	jmp    10287b <__alltraps>

00101f63 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f63:	6a 00                	push   $0x0
  pushl $40
  101f65:	6a 28                	push   $0x28
  jmp __alltraps
  101f67:	e9 0f 09 00 00       	jmp    10287b <__alltraps>

00101f6c <vector41>:
.globl vector41
vector41:
  pushl $0
  101f6c:	6a 00                	push   $0x0
  pushl $41
  101f6e:	6a 29                	push   $0x29
  jmp __alltraps
  101f70:	e9 06 09 00 00       	jmp    10287b <__alltraps>

00101f75 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $42
  101f77:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f79:	e9 fd 08 00 00       	jmp    10287b <__alltraps>

00101f7e <vector43>:
.globl vector43
vector43:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $43
  101f80:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f82:	e9 f4 08 00 00       	jmp    10287b <__alltraps>

00101f87 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $44
  101f89:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f8b:	e9 eb 08 00 00       	jmp    10287b <__alltraps>

00101f90 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $45
  101f92:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f94:	e9 e2 08 00 00       	jmp    10287b <__alltraps>

00101f99 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $46
  101f9b:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f9d:	e9 d9 08 00 00       	jmp    10287b <__alltraps>

00101fa2 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $47
  101fa4:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fa6:	e9 d0 08 00 00       	jmp    10287b <__alltraps>

00101fab <vector48>:
.globl vector48
vector48:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $48
  101fad:	6a 30                	push   $0x30
  jmp __alltraps
  101faf:	e9 c7 08 00 00       	jmp    10287b <__alltraps>

00101fb4 <vector49>:
.globl vector49
vector49:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $49
  101fb6:	6a 31                	push   $0x31
  jmp __alltraps
  101fb8:	e9 be 08 00 00       	jmp    10287b <__alltraps>

00101fbd <vector50>:
.globl vector50
vector50:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $50
  101fbf:	6a 32                	push   $0x32
  jmp __alltraps
  101fc1:	e9 b5 08 00 00       	jmp    10287b <__alltraps>

00101fc6 <vector51>:
.globl vector51
vector51:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $51
  101fc8:	6a 33                	push   $0x33
  jmp __alltraps
  101fca:	e9 ac 08 00 00       	jmp    10287b <__alltraps>

00101fcf <vector52>:
.globl vector52
vector52:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $52
  101fd1:	6a 34                	push   $0x34
  jmp __alltraps
  101fd3:	e9 a3 08 00 00       	jmp    10287b <__alltraps>

00101fd8 <vector53>:
.globl vector53
vector53:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $53
  101fda:	6a 35                	push   $0x35
  jmp __alltraps
  101fdc:	e9 9a 08 00 00       	jmp    10287b <__alltraps>

00101fe1 <vector54>:
.globl vector54
vector54:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $54
  101fe3:	6a 36                	push   $0x36
  jmp __alltraps
  101fe5:	e9 91 08 00 00       	jmp    10287b <__alltraps>

00101fea <vector55>:
.globl vector55
vector55:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $55
  101fec:	6a 37                	push   $0x37
  jmp __alltraps
  101fee:	e9 88 08 00 00       	jmp    10287b <__alltraps>

00101ff3 <vector56>:
.globl vector56
vector56:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $56
  101ff5:	6a 38                	push   $0x38
  jmp __alltraps
  101ff7:	e9 7f 08 00 00       	jmp    10287b <__alltraps>

00101ffc <vector57>:
.globl vector57
vector57:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $57
  101ffe:	6a 39                	push   $0x39
  jmp __alltraps
  102000:	e9 76 08 00 00       	jmp    10287b <__alltraps>

00102005 <vector58>:
.globl vector58
vector58:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $58
  102007:	6a 3a                	push   $0x3a
  jmp __alltraps
  102009:	e9 6d 08 00 00       	jmp    10287b <__alltraps>

0010200e <vector59>:
.globl vector59
vector59:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $59
  102010:	6a 3b                	push   $0x3b
  jmp __alltraps
  102012:	e9 64 08 00 00       	jmp    10287b <__alltraps>

00102017 <vector60>:
.globl vector60
vector60:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $60
  102019:	6a 3c                	push   $0x3c
  jmp __alltraps
  10201b:	e9 5b 08 00 00       	jmp    10287b <__alltraps>

00102020 <vector61>:
.globl vector61
vector61:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $61
  102022:	6a 3d                	push   $0x3d
  jmp __alltraps
  102024:	e9 52 08 00 00       	jmp    10287b <__alltraps>

00102029 <vector62>:
.globl vector62
vector62:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $62
  10202b:	6a 3e                	push   $0x3e
  jmp __alltraps
  10202d:	e9 49 08 00 00       	jmp    10287b <__alltraps>

00102032 <vector63>:
.globl vector63
vector63:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $63
  102034:	6a 3f                	push   $0x3f
  jmp __alltraps
  102036:	e9 40 08 00 00       	jmp    10287b <__alltraps>

0010203b <vector64>:
.globl vector64
vector64:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $64
  10203d:	6a 40                	push   $0x40
  jmp __alltraps
  10203f:	e9 37 08 00 00       	jmp    10287b <__alltraps>

00102044 <vector65>:
.globl vector65
vector65:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $65
  102046:	6a 41                	push   $0x41
  jmp __alltraps
  102048:	e9 2e 08 00 00       	jmp    10287b <__alltraps>

0010204d <vector66>:
.globl vector66
vector66:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $66
  10204f:	6a 42                	push   $0x42
  jmp __alltraps
  102051:	e9 25 08 00 00       	jmp    10287b <__alltraps>

00102056 <vector67>:
.globl vector67
vector67:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $67
  102058:	6a 43                	push   $0x43
  jmp __alltraps
  10205a:	e9 1c 08 00 00       	jmp    10287b <__alltraps>

0010205f <vector68>:
.globl vector68
vector68:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $68
  102061:	6a 44                	push   $0x44
  jmp __alltraps
  102063:	e9 13 08 00 00       	jmp    10287b <__alltraps>

00102068 <vector69>:
.globl vector69
vector69:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $69
  10206a:	6a 45                	push   $0x45
  jmp __alltraps
  10206c:	e9 0a 08 00 00       	jmp    10287b <__alltraps>

00102071 <vector70>:
.globl vector70
vector70:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $70
  102073:	6a 46                	push   $0x46
  jmp __alltraps
  102075:	e9 01 08 00 00       	jmp    10287b <__alltraps>

0010207a <vector71>:
.globl vector71
vector71:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $71
  10207c:	6a 47                	push   $0x47
  jmp __alltraps
  10207e:	e9 f8 07 00 00       	jmp    10287b <__alltraps>

00102083 <vector72>:
.globl vector72
vector72:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $72
  102085:	6a 48                	push   $0x48
  jmp __alltraps
  102087:	e9 ef 07 00 00       	jmp    10287b <__alltraps>

0010208c <vector73>:
.globl vector73
vector73:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $73
  10208e:	6a 49                	push   $0x49
  jmp __alltraps
  102090:	e9 e6 07 00 00       	jmp    10287b <__alltraps>

00102095 <vector74>:
.globl vector74
vector74:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $74
  102097:	6a 4a                	push   $0x4a
  jmp __alltraps
  102099:	e9 dd 07 00 00       	jmp    10287b <__alltraps>

0010209e <vector75>:
.globl vector75
vector75:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $75
  1020a0:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020a2:	e9 d4 07 00 00       	jmp    10287b <__alltraps>

001020a7 <vector76>:
.globl vector76
vector76:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $76
  1020a9:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020ab:	e9 cb 07 00 00       	jmp    10287b <__alltraps>

001020b0 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $77
  1020b2:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020b4:	e9 c2 07 00 00       	jmp    10287b <__alltraps>

001020b9 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $78
  1020bb:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020bd:	e9 b9 07 00 00       	jmp    10287b <__alltraps>

001020c2 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $79
  1020c4:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020c6:	e9 b0 07 00 00       	jmp    10287b <__alltraps>

001020cb <vector80>:
.globl vector80
vector80:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $80
  1020cd:	6a 50                	push   $0x50
  jmp __alltraps
  1020cf:	e9 a7 07 00 00       	jmp    10287b <__alltraps>

001020d4 <vector81>:
.globl vector81
vector81:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $81
  1020d6:	6a 51                	push   $0x51
  jmp __alltraps
  1020d8:	e9 9e 07 00 00       	jmp    10287b <__alltraps>

001020dd <vector82>:
.globl vector82
vector82:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $82
  1020df:	6a 52                	push   $0x52
  jmp __alltraps
  1020e1:	e9 95 07 00 00       	jmp    10287b <__alltraps>

001020e6 <vector83>:
.globl vector83
vector83:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $83
  1020e8:	6a 53                	push   $0x53
  jmp __alltraps
  1020ea:	e9 8c 07 00 00       	jmp    10287b <__alltraps>

001020ef <vector84>:
.globl vector84
vector84:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $84
  1020f1:	6a 54                	push   $0x54
  jmp __alltraps
  1020f3:	e9 83 07 00 00       	jmp    10287b <__alltraps>

001020f8 <vector85>:
.globl vector85
vector85:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $85
  1020fa:	6a 55                	push   $0x55
  jmp __alltraps
  1020fc:	e9 7a 07 00 00       	jmp    10287b <__alltraps>

00102101 <vector86>:
.globl vector86
vector86:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $86
  102103:	6a 56                	push   $0x56
  jmp __alltraps
  102105:	e9 71 07 00 00       	jmp    10287b <__alltraps>

0010210a <vector87>:
.globl vector87
vector87:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $87
  10210c:	6a 57                	push   $0x57
  jmp __alltraps
  10210e:	e9 68 07 00 00       	jmp    10287b <__alltraps>

00102113 <vector88>:
.globl vector88
vector88:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $88
  102115:	6a 58                	push   $0x58
  jmp __alltraps
  102117:	e9 5f 07 00 00       	jmp    10287b <__alltraps>

0010211c <vector89>:
.globl vector89
vector89:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $89
  10211e:	6a 59                	push   $0x59
  jmp __alltraps
  102120:	e9 56 07 00 00       	jmp    10287b <__alltraps>

00102125 <vector90>:
.globl vector90
vector90:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $90
  102127:	6a 5a                	push   $0x5a
  jmp __alltraps
  102129:	e9 4d 07 00 00       	jmp    10287b <__alltraps>

0010212e <vector91>:
.globl vector91
vector91:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $91
  102130:	6a 5b                	push   $0x5b
  jmp __alltraps
  102132:	e9 44 07 00 00       	jmp    10287b <__alltraps>

00102137 <vector92>:
.globl vector92
vector92:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $92
  102139:	6a 5c                	push   $0x5c
  jmp __alltraps
  10213b:	e9 3b 07 00 00       	jmp    10287b <__alltraps>

00102140 <vector93>:
.globl vector93
vector93:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $93
  102142:	6a 5d                	push   $0x5d
  jmp __alltraps
  102144:	e9 32 07 00 00       	jmp    10287b <__alltraps>

00102149 <vector94>:
.globl vector94
vector94:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $94
  10214b:	6a 5e                	push   $0x5e
  jmp __alltraps
  10214d:	e9 29 07 00 00       	jmp    10287b <__alltraps>

00102152 <vector95>:
.globl vector95
vector95:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $95
  102154:	6a 5f                	push   $0x5f
  jmp __alltraps
  102156:	e9 20 07 00 00       	jmp    10287b <__alltraps>

0010215b <vector96>:
.globl vector96
vector96:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $96
  10215d:	6a 60                	push   $0x60
  jmp __alltraps
  10215f:	e9 17 07 00 00       	jmp    10287b <__alltraps>

00102164 <vector97>:
.globl vector97
vector97:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $97
  102166:	6a 61                	push   $0x61
  jmp __alltraps
  102168:	e9 0e 07 00 00       	jmp    10287b <__alltraps>

0010216d <vector98>:
.globl vector98
vector98:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $98
  10216f:	6a 62                	push   $0x62
  jmp __alltraps
  102171:	e9 05 07 00 00       	jmp    10287b <__alltraps>

00102176 <vector99>:
.globl vector99
vector99:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $99
  102178:	6a 63                	push   $0x63
  jmp __alltraps
  10217a:	e9 fc 06 00 00       	jmp    10287b <__alltraps>

0010217f <vector100>:
.globl vector100
vector100:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $100
  102181:	6a 64                	push   $0x64
  jmp __alltraps
  102183:	e9 f3 06 00 00       	jmp    10287b <__alltraps>

00102188 <vector101>:
.globl vector101
vector101:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $101
  10218a:	6a 65                	push   $0x65
  jmp __alltraps
  10218c:	e9 ea 06 00 00       	jmp    10287b <__alltraps>

00102191 <vector102>:
.globl vector102
vector102:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $102
  102193:	6a 66                	push   $0x66
  jmp __alltraps
  102195:	e9 e1 06 00 00       	jmp    10287b <__alltraps>

0010219a <vector103>:
.globl vector103
vector103:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $103
  10219c:	6a 67                	push   $0x67
  jmp __alltraps
  10219e:	e9 d8 06 00 00       	jmp    10287b <__alltraps>

001021a3 <vector104>:
.globl vector104
vector104:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $104
  1021a5:	6a 68                	push   $0x68
  jmp __alltraps
  1021a7:	e9 cf 06 00 00       	jmp    10287b <__alltraps>

001021ac <vector105>:
.globl vector105
vector105:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $105
  1021ae:	6a 69                	push   $0x69
  jmp __alltraps
  1021b0:	e9 c6 06 00 00       	jmp    10287b <__alltraps>

001021b5 <vector106>:
.globl vector106
vector106:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $106
  1021b7:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021b9:	e9 bd 06 00 00       	jmp    10287b <__alltraps>

001021be <vector107>:
.globl vector107
vector107:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $107
  1021c0:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021c2:	e9 b4 06 00 00       	jmp    10287b <__alltraps>

001021c7 <vector108>:
.globl vector108
vector108:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $108
  1021c9:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021cb:	e9 ab 06 00 00       	jmp    10287b <__alltraps>

001021d0 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $109
  1021d2:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021d4:	e9 a2 06 00 00       	jmp    10287b <__alltraps>

001021d9 <vector110>:
.globl vector110
vector110:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $110
  1021db:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021dd:	e9 99 06 00 00       	jmp    10287b <__alltraps>

001021e2 <vector111>:
.globl vector111
vector111:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $111
  1021e4:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021e6:	e9 90 06 00 00       	jmp    10287b <__alltraps>

001021eb <vector112>:
.globl vector112
vector112:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $112
  1021ed:	6a 70                	push   $0x70
  jmp __alltraps
  1021ef:	e9 87 06 00 00       	jmp    10287b <__alltraps>

001021f4 <vector113>:
.globl vector113
vector113:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $113
  1021f6:	6a 71                	push   $0x71
  jmp __alltraps
  1021f8:	e9 7e 06 00 00       	jmp    10287b <__alltraps>

001021fd <vector114>:
.globl vector114
vector114:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $114
  1021ff:	6a 72                	push   $0x72
  jmp __alltraps
  102201:	e9 75 06 00 00       	jmp    10287b <__alltraps>

00102206 <vector115>:
.globl vector115
vector115:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $115
  102208:	6a 73                	push   $0x73
  jmp __alltraps
  10220a:	e9 6c 06 00 00       	jmp    10287b <__alltraps>

0010220f <vector116>:
.globl vector116
vector116:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $116
  102211:	6a 74                	push   $0x74
  jmp __alltraps
  102213:	e9 63 06 00 00       	jmp    10287b <__alltraps>

00102218 <vector117>:
.globl vector117
vector117:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $117
  10221a:	6a 75                	push   $0x75
  jmp __alltraps
  10221c:	e9 5a 06 00 00       	jmp    10287b <__alltraps>

00102221 <vector118>:
.globl vector118
vector118:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $118
  102223:	6a 76                	push   $0x76
  jmp __alltraps
  102225:	e9 51 06 00 00       	jmp    10287b <__alltraps>

0010222a <vector119>:
.globl vector119
vector119:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $119
  10222c:	6a 77                	push   $0x77
  jmp __alltraps
  10222e:	e9 48 06 00 00       	jmp    10287b <__alltraps>

00102233 <vector120>:
.globl vector120
vector120:
  pushl $0
  102233:	6a 00                	push   $0x0
  pushl $120
  102235:	6a 78                	push   $0x78
  jmp __alltraps
  102237:	e9 3f 06 00 00       	jmp    10287b <__alltraps>

0010223c <vector121>:
.globl vector121
vector121:
  pushl $0
  10223c:	6a 00                	push   $0x0
  pushl $121
  10223e:	6a 79                	push   $0x79
  jmp __alltraps
  102240:	e9 36 06 00 00       	jmp    10287b <__alltraps>

00102245 <vector122>:
.globl vector122
vector122:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $122
  102247:	6a 7a                	push   $0x7a
  jmp __alltraps
  102249:	e9 2d 06 00 00       	jmp    10287b <__alltraps>

0010224e <vector123>:
.globl vector123
vector123:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $123
  102250:	6a 7b                	push   $0x7b
  jmp __alltraps
  102252:	e9 24 06 00 00       	jmp    10287b <__alltraps>

00102257 <vector124>:
.globl vector124
vector124:
  pushl $0
  102257:	6a 00                	push   $0x0
  pushl $124
  102259:	6a 7c                	push   $0x7c
  jmp __alltraps
  10225b:	e9 1b 06 00 00       	jmp    10287b <__alltraps>

00102260 <vector125>:
.globl vector125
vector125:
  pushl $0
  102260:	6a 00                	push   $0x0
  pushl $125
  102262:	6a 7d                	push   $0x7d
  jmp __alltraps
  102264:	e9 12 06 00 00       	jmp    10287b <__alltraps>

00102269 <vector126>:
.globl vector126
vector126:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $126
  10226b:	6a 7e                	push   $0x7e
  jmp __alltraps
  10226d:	e9 09 06 00 00       	jmp    10287b <__alltraps>

00102272 <vector127>:
.globl vector127
vector127:
  pushl $0
  102272:	6a 00                	push   $0x0
  pushl $127
  102274:	6a 7f                	push   $0x7f
  jmp __alltraps
  102276:	e9 00 06 00 00       	jmp    10287b <__alltraps>

0010227b <vector128>:
.globl vector128
vector128:
  pushl $0
  10227b:	6a 00                	push   $0x0
  pushl $128
  10227d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102282:	e9 f4 05 00 00       	jmp    10287b <__alltraps>

00102287 <vector129>:
.globl vector129
vector129:
  pushl $0
  102287:	6a 00                	push   $0x0
  pushl $129
  102289:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10228e:	e9 e8 05 00 00       	jmp    10287b <__alltraps>

00102293 <vector130>:
.globl vector130
vector130:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $130
  102295:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10229a:	e9 dc 05 00 00       	jmp    10287b <__alltraps>

0010229f <vector131>:
.globl vector131
vector131:
  pushl $0
  10229f:	6a 00                	push   $0x0
  pushl $131
  1022a1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022a6:	e9 d0 05 00 00       	jmp    10287b <__alltraps>

001022ab <vector132>:
.globl vector132
vector132:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $132
  1022ad:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022b2:	e9 c4 05 00 00       	jmp    10287b <__alltraps>

001022b7 <vector133>:
.globl vector133
vector133:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $133
  1022b9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022be:	e9 b8 05 00 00       	jmp    10287b <__alltraps>

001022c3 <vector134>:
.globl vector134
vector134:
  pushl $0
  1022c3:	6a 00                	push   $0x0
  pushl $134
  1022c5:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022ca:	e9 ac 05 00 00       	jmp    10287b <__alltraps>

001022cf <vector135>:
.globl vector135
vector135:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $135
  1022d1:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022d6:	e9 a0 05 00 00       	jmp    10287b <__alltraps>

001022db <vector136>:
.globl vector136
vector136:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $136
  1022dd:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022e2:	e9 94 05 00 00       	jmp    10287b <__alltraps>

001022e7 <vector137>:
.globl vector137
vector137:
  pushl $0
  1022e7:	6a 00                	push   $0x0
  pushl $137
  1022e9:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1022ee:	e9 88 05 00 00       	jmp    10287b <__alltraps>

001022f3 <vector138>:
.globl vector138
vector138:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $138
  1022f5:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022fa:	e9 7c 05 00 00       	jmp    10287b <__alltraps>

001022ff <vector139>:
.globl vector139
vector139:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $139
  102301:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102306:	e9 70 05 00 00       	jmp    10287b <__alltraps>

0010230b <vector140>:
.globl vector140
vector140:
  pushl $0
  10230b:	6a 00                	push   $0x0
  pushl $140
  10230d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102312:	e9 64 05 00 00       	jmp    10287b <__alltraps>

00102317 <vector141>:
.globl vector141
vector141:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $141
  102319:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10231e:	e9 58 05 00 00       	jmp    10287b <__alltraps>

00102323 <vector142>:
.globl vector142
vector142:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $142
  102325:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10232a:	e9 4c 05 00 00       	jmp    10287b <__alltraps>

0010232f <vector143>:
.globl vector143
vector143:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $143
  102331:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102336:	e9 40 05 00 00       	jmp    10287b <__alltraps>

0010233b <vector144>:
.globl vector144
vector144:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $144
  10233d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102342:	e9 34 05 00 00       	jmp    10287b <__alltraps>

00102347 <vector145>:
.globl vector145
vector145:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $145
  102349:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10234e:	e9 28 05 00 00       	jmp    10287b <__alltraps>

00102353 <vector146>:
.globl vector146
vector146:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $146
  102355:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10235a:	e9 1c 05 00 00       	jmp    10287b <__alltraps>

0010235f <vector147>:
.globl vector147
vector147:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $147
  102361:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102366:	e9 10 05 00 00       	jmp    10287b <__alltraps>

0010236b <vector148>:
.globl vector148
vector148:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $148
  10236d:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102372:	e9 04 05 00 00       	jmp    10287b <__alltraps>

00102377 <vector149>:
.globl vector149
vector149:
  pushl $0
  102377:	6a 00                	push   $0x0
  pushl $149
  102379:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10237e:	e9 f8 04 00 00       	jmp    10287b <__alltraps>

00102383 <vector150>:
.globl vector150
vector150:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $150
  102385:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10238a:	e9 ec 04 00 00       	jmp    10287b <__alltraps>

0010238f <vector151>:
.globl vector151
vector151:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $151
  102391:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102396:	e9 e0 04 00 00       	jmp    10287b <__alltraps>

0010239b <vector152>:
.globl vector152
vector152:
  pushl $0
  10239b:	6a 00                	push   $0x0
  pushl $152
  10239d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023a2:	e9 d4 04 00 00       	jmp    10287b <__alltraps>

001023a7 <vector153>:
.globl vector153
vector153:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $153
  1023a9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023ae:	e9 c8 04 00 00       	jmp    10287b <__alltraps>

001023b3 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $154
  1023b5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023ba:	e9 bc 04 00 00       	jmp    10287b <__alltraps>

001023bf <vector155>:
.globl vector155
vector155:
  pushl $0
  1023bf:	6a 00                	push   $0x0
  pushl $155
  1023c1:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023c6:	e9 b0 04 00 00       	jmp    10287b <__alltraps>

001023cb <vector156>:
.globl vector156
vector156:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $156
  1023cd:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023d2:	e9 a4 04 00 00       	jmp    10287b <__alltraps>

001023d7 <vector157>:
.globl vector157
vector157:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $157
  1023d9:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023de:	e9 98 04 00 00       	jmp    10287b <__alltraps>

001023e3 <vector158>:
.globl vector158
vector158:
  pushl $0
  1023e3:	6a 00                	push   $0x0
  pushl $158
  1023e5:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1023ea:	e9 8c 04 00 00       	jmp    10287b <__alltraps>

001023ef <vector159>:
.globl vector159
vector159:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $159
  1023f1:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023f6:	e9 80 04 00 00       	jmp    10287b <__alltraps>

001023fb <vector160>:
.globl vector160
vector160:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $160
  1023fd:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102402:	e9 74 04 00 00       	jmp    10287b <__alltraps>

00102407 <vector161>:
.globl vector161
vector161:
  pushl $0
  102407:	6a 00                	push   $0x0
  pushl $161
  102409:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10240e:	e9 68 04 00 00       	jmp    10287b <__alltraps>

00102413 <vector162>:
.globl vector162
vector162:
  pushl $0
  102413:	6a 00                	push   $0x0
  pushl $162
  102415:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10241a:	e9 5c 04 00 00       	jmp    10287b <__alltraps>

0010241f <vector163>:
.globl vector163
vector163:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $163
  102421:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102426:	e9 50 04 00 00       	jmp    10287b <__alltraps>

0010242b <vector164>:
.globl vector164
vector164:
  pushl $0
  10242b:	6a 00                	push   $0x0
  pushl $164
  10242d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102432:	e9 44 04 00 00       	jmp    10287b <__alltraps>

00102437 <vector165>:
.globl vector165
vector165:
  pushl $0
  102437:	6a 00                	push   $0x0
  pushl $165
  102439:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10243e:	e9 38 04 00 00       	jmp    10287b <__alltraps>

00102443 <vector166>:
.globl vector166
vector166:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $166
  102445:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10244a:	e9 2c 04 00 00       	jmp    10287b <__alltraps>

0010244f <vector167>:
.globl vector167
vector167:
  pushl $0
  10244f:	6a 00                	push   $0x0
  pushl $167
  102451:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102456:	e9 20 04 00 00       	jmp    10287b <__alltraps>

0010245b <vector168>:
.globl vector168
vector168:
  pushl $0
  10245b:	6a 00                	push   $0x0
  pushl $168
  10245d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102462:	e9 14 04 00 00       	jmp    10287b <__alltraps>

00102467 <vector169>:
.globl vector169
vector169:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $169
  102469:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10246e:	e9 08 04 00 00       	jmp    10287b <__alltraps>

00102473 <vector170>:
.globl vector170
vector170:
  pushl $0
  102473:	6a 00                	push   $0x0
  pushl $170
  102475:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10247a:	e9 fc 03 00 00       	jmp    10287b <__alltraps>

0010247f <vector171>:
.globl vector171
vector171:
  pushl $0
  10247f:	6a 00                	push   $0x0
  pushl $171
  102481:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102486:	e9 f0 03 00 00       	jmp    10287b <__alltraps>

0010248b <vector172>:
.globl vector172
vector172:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $172
  10248d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102492:	e9 e4 03 00 00       	jmp    10287b <__alltraps>

00102497 <vector173>:
.globl vector173
vector173:
  pushl $0
  102497:	6a 00                	push   $0x0
  pushl $173
  102499:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10249e:	e9 d8 03 00 00       	jmp    10287b <__alltraps>

001024a3 <vector174>:
.globl vector174
vector174:
  pushl $0
  1024a3:	6a 00                	push   $0x0
  pushl $174
  1024a5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024aa:	e9 cc 03 00 00       	jmp    10287b <__alltraps>

001024af <vector175>:
.globl vector175
vector175:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $175
  1024b1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024b6:	e9 c0 03 00 00       	jmp    10287b <__alltraps>

001024bb <vector176>:
.globl vector176
vector176:
  pushl $0
  1024bb:	6a 00                	push   $0x0
  pushl $176
  1024bd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024c2:	e9 b4 03 00 00       	jmp    10287b <__alltraps>

001024c7 <vector177>:
.globl vector177
vector177:
  pushl $0
  1024c7:	6a 00                	push   $0x0
  pushl $177
  1024c9:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024ce:	e9 a8 03 00 00       	jmp    10287b <__alltraps>

001024d3 <vector178>:
.globl vector178
vector178:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $178
  1024d5:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024da:	e9 9c 03 00 00       	jmp    10287b <__alltraps>

001024df <vector179>:
.globl vector179
vector179:
  pushl $0
  1024df:	6a 00                	push   $0x0
  pushl $179
  1024e1:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024e6:	e9 90 03 00 00       	jmp    10287b <__alltraps>

001024eb <vector180>:
.globl vector180
vector180:
  pushl $0
  1024eb:	6a 00                	push   $0x0
  pushl $180
  1024ed:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1024f2:	e9 84 03 00 00       	jmp    10287b <__alltraps>

001024f7 <vector181>:
.globl vector181
vector181:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $181
  1024f9:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024fe:	e9 78 03 00 00       	jmp    10287b <__alltraps>

00102503 <vector182>:
.globl vector182
vector182:
  pushl $0
  102503:	6a 00                	push   $0x0
  pushl $182
  102505:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10250a:	e9 6c 03 00 00       	jmp    10287b <__alltraps>

0010250f <vector183>:
.globl vector183
vector183:
  pushl $0
  10250f:	6a 00                	push   $0x0
  pushl $183
  102511:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102516:	e9 60 03 00 00       	jmp    10287b <__alltraps>

0010251b <vector184>:
.globl vector184
vector184:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $184
  10251d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102522:	e9 54 03 00 00       	jmp    10287b <__alltraps>

00102527 <vector185>:
.globl vector185
vector185:
  pushl $0
  102527:	6a 00                	push   $0x0
  pushl $185
  102529:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10252e:	e9 48 03 00 00       	jmp    10287b <__alltraps>

00102533 <vector186>:
.globl vector186
vector186:
  pushl $0
  102533:	6a 00                	push   $0x0
  pushl $186
  102535:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10253a:	e9 3c 03 00 00       	jmp    10287b <__alltraps>

0010253f <vector187>:
.globl vector187
vector187:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $187
  102541:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102546:	e9 30 03 00 00       	jmp    10287b <__alltraps>

0010254b <vector188>:
.globl vector188
vector188:
  pushl $0
  10254b:	6a 00                	push   $0x0
  pushl $188
  10254d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102552:	e9 24 03 00 00       	jmp    10287b <__alltraps>

00102557 <vector189>:
.globl vector189
vector189:
  pushl $0
  102557:	6a 00                	push   $0x0
  pushl $189
  102559:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10255e:	e9 18 03 00 00       	jmp    10287b <__alltraps>

00102563 <vector190>:
.globl vector190
vector190:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $190
  102565:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10256a:	e9 0c 03 00 00       	jmp    10287b <__alltraps>

0010256f <vector191>:
.globl vector191
vector191:
  pushl $0
  10256f:	6a 00                	push   $0x0
  pushl $191
  102571:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102576:	e9 00 03 00 00       	jmp    10287b <__alltraps>

0010257b <vector192>:
.globl vector192
vector192:
  pushl $0
  10257b:	6a 00                	push   $0x0
  pushl $192
  10257d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102582:	e9 f4 02 00 00       	jmp    10287b <__alltraps>

00102587 <vector193>:
.globl vector193
vector193:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $193
  102589:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10258e:	e9 e8 02 00 00       	jmp    10287b <__alltraps>

00102593 <vector194>:
.globl vector194
vector194:
  pushl $0
  102593:	6a 00                	push   $0x0
  pushl $194
  102595:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10259a:	e9 dc 02 00 00       	jmp    10287b <__alltraps>

0010259f <vector195>:
.globl vector195
vector195:
  pushl $0
  10259f:	6a 00                	push   $0x0
  pushl $195
  1025a1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025a6:	e9 d0 02 00 00       	jmp    10287b <__alltraps>

001025ab <vector196>:
.globl vector196
vector196:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $196
  1025ad:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025b2:	e9 c4 02 00 00       	jmp    10287b <__alltraps>

001025b7 <vector197>:
.globl vector197
vector197:
  pushl $0
  1025b7:	6a 00                	push   $0x0
  pushl $197
  1025b9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025be:	e9 b8 02 00 00       	jmp    10287b <__alltraps>

001025c3 <vector198>:
.globl vector198
vector198:
  pushl $0
  1025c3:	6a 00                	push   $0x0
  pushl $198
  1025c5:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025ca:	e9 ac 02 00 00       	jmp    10287b <__alltraps>

001025cf <vector199>:
.globl vector199
vector199:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $199
  1025d1:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025d6:	e9 a0 02 00 00       	jmp    10287b <__alltraps>

001025db <vector200>:
.globl vector200
vector200:
  pushl $0
  1025db:	6a 00                	push   $0x0
  pushl $200
  1025dd:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025e2:	e9 94 02 00 00       	jmp    10287b <__alltraps>

001025e7 <vector201>:
.globl vector201
vector201:
  pushl $0
  1025e7:	6a 00                	push   $0x0
  pushl $201
  1025e9:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1025ee:	e9 88 02 00 00       	jmp    10287b <__alltraps>

001025f3 <vector202>:
.globl vector202
vector202:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $202
  1025f5:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025fa:	e9 7c 02 00 00       	jmp    10287b <__alltraps>

001025ff <vector203>:
.globl vector203
vector203:
  pushl $0
  1025ff:	6a 00                	push   $0x0
  pushl $203
  102601:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102606:	e9 70 02 00 00       	jmp    10287b <__alltraps>

0010260b <vector204>:
.globl vector204
vector204:
  pushl $0
  10260b:	6a 00                	push   $0x0
  pushl $204
  10260d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102612:	e9 64 02 00 00       	jmp    10287b <__alltraps>

00102617 <vector205>:
.globl vector205
vector205:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $205
  102619:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10261e:	e9 58 02 00 00       	jmp    10287b <__alltraps>

00102623 <vector206>:
.globl vector206
vector206:
  pushl $0
  102623:	6a 00                	push   $0x0
  pushl $206
  102625:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10262a:	e9 4c 02 00 00       	jmp    10287b <__alltraps>

0010262f <vector207>:
.globl vector207
vector207:
  pushl $0
  10262f:	6a 00                	push   $0x0
  pushl $207
  102631:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102636:	e9 40 02 00 00       	jmp    10287b <__alltraps>

0010263b <vector208>:
.globl vector208
vector208:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $208
  10263d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102642:	e9 34 02 00 00       	jmp    10287b <__alltraps>

00102647 <vector209>:
.globl vector209
vector209:
  pushl $0
  102647:	6a 00                	push   $0x0
  pushl $209
  102649:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10264e:	e9 28 02 00 00       	jmp    10287b <__alltraps>

00102653 <vector210>:
.globl vector210
vector210:
  pushl $0
  102653:	6a 00                	push   $0x0
  pushl $210
  102655:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10265a:	e9 1c 02 00 00       	jmp    10287b <__alltraps>

0010265f <vector211>:
.globl vector211
vector211:
  pushl $0
  10265f:	6a 00                	push   $0x0
  pushl $211
  102661:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102666:	e9 10 02 00 00       	jmp    10287b <__alltraps>

0010266b <vector212>:
.globl vector212
vector212:
  pushl $0
  10266b:	6a 00                	push   $0x0
  pushl $212
  10266d:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102672:	e9 04 02 00 00       	jmp    10287b <__alltraps>

00102677 <vector213>:
.globl vector213
vector213:
  pushl $0
  102677:	6a 00                	push   $0x0
  pushl $213
  102679:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10267e:	e9 f8 01 00 00       	jmp    10287b <__alltraps>

00102683 <vector214>:
.globl vector214
vector214:
  pushl $0
  102683:	6a 00                	push   $0x0
  pushl $214
  102685:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10268a:	e9 ec 01 00 00       	jmp    10287b <__alltraps>

0010268f <vector215>:
.globl vector215
vector215:
  pushl $0
  10268f:	6a 00                	push   $0x0
  pushl $215
  102691:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102696:	e9 e0 01 00 00       	jmp    10287b <__alltraps>

0010269b <vector216>:
.globl vector216
vector216:
  pushl $0
  10269b:	6a 00                	push   $0x0
  pushl $216
  10269d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026a2:	e9 d4 01 00 00       	jmp    10287b <__alltraps>

001026a7 <vector217>:
.globl vector217
vector217:
  pushl $0
  1026a7:	6a 00                	push   $0x0
  pushl $217
  1026a9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026ae:	e9 c8 01 00 00       	jmp    10287b <__alltraps>

001026b3 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026b3:	6a 00                	push   $0x0
  pushl $218
  1026b5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026ba:	e9 bc 01 00 00       	jmp    10287b <__alltraps>

001026bf <vector219>:
.globl vector219
vector219:
  pushl $0
  1026bf:	6a 00                	push   $0x0
  pushl $219
  1026c1:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026c6:	e9 b0 01 00 00       	jmp    10287b <__alltraps>

001026cb <vector220>:
.globl vector220
vector220:
  pushl $0
  1026cb:	6a 00                	push   $0x0
  pushl $220
  1026cd:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026d2:	e9 a4 01 00 00       	jmp    10287b <__alltraps>

001026d7 <vector221>:
.globl vector221
vector221:
  pushl $0
  1026d7:	6a 00                	push   $0x0
  pushl $221
  1026d9:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026de:	e9 98 01 00 00       	jmp    10287b <__alltraps>

001026e3 <vector222>:
.globl vector222
vector222:
  pushl $0
  1026e3:	6a 00                	push   $0x0
  pushl $222
  1026e5:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1026ea:	e9 8c 01 00 00       	jmp    10287b <__alltraps>

001026ef <vector223>:
.globl vector223
vector223:
  pushl $0
  1026ef:	6a 00                	push   $0x0
  pushl $223
  1026f1:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026f6:	e9 80 01 00 00       	jmp    10287b <__alltraps>

001026fb <vector224>:
.globl vector224
vector224:
  pushl $0
  1026fb:	6a 00                	push   $0x0
  pushl $224
  1026fd:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102702:	e9 74 01 00 00       	jmp    10287b <__alltraps>

00102707 <vector225>:
.globl vector225
vector225:
  pushl $0
  102707:	6a 00                	push   $0x0
  pushl $225
  102709:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10270e:	e9 68 01 00 00       	jmp    10287b <__alltraps>

00102713 <vector226>:
.globl vector226
vector226:
  pushl $0
  102713:	6a 00                	push   $0x0
  pushl $226
  102715:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10271a:	e9 5c 01 00 00       	jmp    10287b <__alltraps>

0010271f <vector227>:
.globl vector227
vector227:
  pushl $0
  10271f:	6a 00                	push   $0x0
  pushl $227
  102721:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102726:	e9 50 01 00 00       	jmp    10287b <__alltraps>

0010272b <vector228>:
.globl vector228
vector228:
  pushl $0
  10272b:	6a 00                	push   $0x0
  pushl $228
  10272d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102732:	e9 44 01 00 00       	jmp    10287b <__alltraps>

00102737 <vector229>:
.globl vector229
vector229:
  pushl $0
  102737:	6a 00                	push   $0x0
  pushl $229
  102739:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10273e:	e9 38 01 00 00       	jmp    10287b <__alltraps>

00102743 <vector230>:
.globl vector230
vector230:
  pushl $0
  102743:	6a 00                	push   $0x0
  pushl $230
  102745:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10274a:	e9 2c 01 00 00       	jmp    10287b <__alltraps>

0010274f <vector231>:
.globl vector231
vector231:
  pushl $0
  10274f:	6a 00                	push   $0x0
  pushl $231
  102751:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102756:	e9 20 01 00 00       	jmp    10287b <__alltraps>

0010275b <vector232>:
.globl vector232
vector232:
  pushl $0
  10275b:	6a 00                	push   $0x0
  pushl $232
  10275d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102762:	e9 14 01 00 00       	jmp    10287b <__alltraps>

00102767 <vector233>:
.globl vector233
vector233:
  pushl $0
  102767:	6a 00                	push   $0x0
  pushl $233
  102769:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10276e:	e9 08 01 00 00       	jmp    10287b <__alltraps>

00102773 <vector234>:
.globl vector234
vector234:
  pushl $0
  102773:	6a 00                	push   $0x0
  pushl $234
  102775:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10277a:	e9 fc 00 00 00       	jmp    10287b <__alltraps>

0010277f <vector235>:
.globl vector235
vector235:
  pushl $0
  10277f:	6a 00                	push   $0x0
  pushl $235
  102781:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102786:	e9 f0 00 00 00       	jmp    10287b <__alltraps>

0010278b <vector236>:
.globl vector236
vector236:
  pushl $0
  10278b:	6a 00                	push   $0x0
  pushl $236
  10278d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102792:	e9 e4 00 00 00       	jmp    10287b <__alltraps>

00102797 <vector237>:
.globl vector237
vector237:
  pushl $0
  102797:	6a 00                	push   $0x0
  pushl $237
  102799:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10279e:	e9 d8 00 00 00       	jmp    10287b <__alltraps>

001027a3 <vector238>:
.globl vector238
vector238:
  pushl $0
  1027a3:	6a 00                	push   $0x0
  pushl $238
  1027a5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027aa:	e9 cc 00 00 00       	jmp    10287b <__alltraps>

001027af <vector239>:
.globl vector239
vector239:
  pushl $0
  1027af:	6a 00                	push   $0x0
  pushl $239
  1027b1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027b6:	e9 c0 00 00 00       	jmp    10287b <__alltraps>

001027bb <vector240>:
.globl vector240
vector240:
  pushl $0
  1027bb:	6a 00                	push   $0x0
  pushl $240
  1027bd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027c2:	e9 b4 00 00 00       	jmp    10287b <__alltraps>

001027c7 <vector241>:
.globl vector241
vector241:
  pushl $0
  1027c7:	6a 00                	push   $0x0
  pushl $241
  1027c9:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027ce:	e9 a8 00 00 00       	jmp    10287b <__alltraps>

001027d3 <vector242>:
.globl vector242
vector242:
  pushl $0
  1027d3:	6a 00                	push   $0x0
  pushl $242
  1027d5:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027da:	e9 9c 00 00 00       	jmp    10287b <__alltraps>

001027df <vector243>:
.globl vector243
vector243:
  pushl $0
  1027df:	6a 00                	push   $0x0
  pushl $243
  1027e1:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027e6:	e9 90 00 00 00       	jmp    10287b <__alltraps>

001027eb <vector244>:
.globl vector244
vector244:
  pushl $0
  1027eb:	6a 00                	push   $0x0
  pushl $244
  1027ed:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1027f2:	e9 84 00 00 00       	jmp    10287b <__alltraps>

001027f7 <vector245>:
.globl vector245
vector245:
  pushl $0
  1027f7:	6a 00                	push   $0x0
  pushl $245
  1027f9:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027fe:	e9 78 00 00 00       	jmp    10287b <__alltraps>

00102803 <vector246>:
.globl vector246
vector246:
  pushl $0
  102803:	6a 00                	push   $0x0
  pushl $246
  102805:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  10280a:	e9 6c 00 00 00       	jmp    10287b <__alltraps>

0010280f <vector247>:
.globl vector247
vector247:
  pushl $0
  10280f:	6a 00                	push   $0x0
  pushl $247
  102811:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102816:	e9 60 00 00 00       	jmp    10287b <__alltraps>

0010281b <vector248>:
.globl vector248
vector248:
  pushl $0
  10281b:	6a 00                	push   $0x0
  pushl $248
  10281d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102822:	e9 54 00 00 00       	jmp    10287b <__alltraps>

00102827 <vector249>:
.globl vector249
vector249:
  pushl $0
  102827:	6a 00                	push   $0x0
  pushl $249
  102829:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10282e:	e9 48 00 00 00       	jmp    10287b <__alltraps>

00102833 <vector250>:
.globl vector250
vector250:
  pushl $0
  102833:	6a 00                	push   $0x0
  pushl $250
  102835:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10283a:	e9 3c 00 00 00       	jmp    10287b <__alltraps>

0010283f <vector251>:
.globl vector251
vector251:
  pushl $0
  10283f:	6a 00                	push   $0x0
  pushl $251
  102841:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102846:	e9 30 00 00 00       	jmp    10287b <__alltraps>

0010284b <vector252>:
.globl vector252
vector252:
  pushl $0
  10284b:	6a 00                	push   $0x0
  pushl $252
  10284d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102852:	e9 24 00 00 00       	jmp    10287b <__alltraps>

00102857 <vector253>:
.globl vector253
vector253:
  pushl $0
  102857:	6a 00                	push   $0x0
  pushl $253
  102859:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10285e:	e9 18 00 00 00       	jmp    10287b <__alltraps>

00102863 <vector254>:
.globl vector254
vector254:
  pushl $0
  102863:	6a 00                	push   $0x0
  pushl $254
  102865:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10286a:	e9 0c 00 00 00       	jmp    10287b <__alltraps>

0010286f <vector255>:
.globl vector255
vector255:
  pushl $0
  10286f:	6a 00                	push   $0x0
  pushl $255
  102871:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102876:	e9 00 00 00 00       	jmp    10287b <__alltraps>

0010287b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  10287b:	1e                   	push   %ds
    pushl %es
  10287c:	06                   	push   %es
    pushl %fs
  10287d:	0f a0                	push   %fs
    pushl %gs
  10287f:	0f a8                	push   %gs
    pushal
  102881:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102882:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102887:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102889:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10288b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10288c:	e8 64 f5 ff ff       	call   101df5 <trap>

    # pop the pushed stack pointer
    popl %esp
  102891:	5c                   	pop    %esp

00102892 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102892:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102893:	0f a9                	pop    %gs
    popl %fs
  102895:	0f a1                	pop    %fs
    popl %es
  102897:	07                   	pop    %es
    popl %ds
  102898:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102899:	83 c4 08             	add    $0x8,%esp
    iret
  10289c:	cf                   	iret   

0010289d <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10289d:	55                   	push   %ebp
  10289e:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1028a3:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1028a9:	29 d0                	sub    %edx,%eax
  1028ab:	c1 f8 02             	sar    $0x2,%eax
  1028ae:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028b4:	5d                   	pop    %ebp
  1028b5:	c3                   	ret    

001028b6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028b6:	55                   	push   %ebp
  1028b7:	89 e5                	mov    %esp,%ebp
  1028b9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1028bf:	89 04 24             	mov    %eax,(%esp)
  1028c2:	e8 d6 ff ff ff       	call   10289d <page2ppn>
  1028c7:	c1 e0 0c             	shl    $0xc,%eax
}
  1028ca:	c9                   	leave  
  1028cb:	c3                   	ret    

001028cc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1028cc:	55                   	push   %ebp
  1028cd:	89 e5                	mov    %esp,%ebp
  1028cf:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1028d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028d5:	c1 e8 0c             	shr    $0xc,%eax
  1028d8:	89 c2                	mov    %eax,%edx
  1028da:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1028df:	39 c2                	cmp    %eax,%edx
  1028e1:	72 1c                	jb     1028ff <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1028e3:	c7 44 24 08 90 65 10 	movl   $0x106590,0x8(%esp)
  1028ea:	00 
  1028eb:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1028f2:	00 
  1028f3:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
  1028fa:	e8 ea da ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  1028ff:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102905:	8b 45 08             	mov    0x8(%ebp),%eax
  102908:	c1 e8 0c             	shr    $0xc,%eax
  10290b:	89 c2                	mov    %eax,%edx
  10290d:	89 d0                	mov    %edx,%eax
  10290f:	c1 e0 02             	shl    $0x2,%eax
  102912:	01 d0                	add    %edx,%eax
  102914:	c1 e0 02             	shl    $0x2,%eax
  102917:	01 c8                	add    %ecx,%eax
}
  102919:	c9                   	leave  
  10291a:	c3                   	ret    

0010291b <page2kva>:

static inline void *
page2kva(struct Page *page) {
  10291b:	55                   	push   %ebp
  10291c:	89 e5                	mov    %esp,%ebp
  10291e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102921:	8b 45 08             	mov    0x8(%ebp),%eax
  102924:	89 04 24             	mov    %eax,(%esp)
  102927:	e8 8a ff ff ff       	call   1028b6 <page2pa>
  10292c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10292f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102932:	c1 e8 0c             	shr    $0xc,%eax
  102935:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102938:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10293d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102940:	72 23                	jb     102965 <page2kva+0x4a>
  102942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102945:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102949:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  102950:	00 
  102951:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102958:	00 
  102959:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
  102960:	e8 84 da ff ff       	call   1003e9 <__panic>
  102965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102968:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  10296d:	c9                   	leave  
  10296e:	c3                   	ret    

0010296f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  10296f:	55                   	push   %ebp
  102970:	89 e5                	mov    %esp,%ebp
  102972:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102975:	8b 45 08             	mov    0x8(%ebp),%eax
  102978:	83 e0 01             	and    $0x1,%eax
  10297b:	85 c0                	test   %eax,%eax
  10297d:	75 1c                	jne    10299b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  10297f:	c7 44 24 08 e4 65 10 	movl   $0x1065e4,0x8(%esp)
  102986:	00 
  102987:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  10298e:	00 
  10298f:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
  102996:	e8 4e da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  10299b:	8b 45 08             	mov    0x8(%ebp),%eax
  10299e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029a3:	89 04 24             	mov    %eax,(%esp)
  1029a6:	e8 21 ff ff ff       	call   1028cc <pa2page>
}
  1029ab:	c9                   	leave  
  1029ac:	c3                   	ret    

001029ad <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029ad:	55                   	push   %ebp
  1029ae:	89 e5                	mov    %esp,%ebp
  1029b0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1029b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029bb:	89 04 24             	mov    %eax,(%esp)
  1029be:	e8 09 ff ff ff       	call   1028cc <pa2page>
}
  1029c3:	c9                   	leave  
  1029c4:	c3                   	ret    

001029c5 <page_ref>:

static inline int
page_ref(struct Page *page) {
  1029c5:	55                   	push   %ebp
  1029c6:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029cb:	8b 00                	mov    (%eax),%eax
}
  1029cd:	5d                   	pop    %ebp
  1029ce:	c3                   	ret    

001029cf <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029cf:	55                   	push   %ebp
  1029d0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029d8:	89 10                	mov    %edx,(%eax)
}
  1029da:	90                   	nop
  1029db:	5d                   	pop    %ebp
  1029dc:	c3                   	ret    

001029dd <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1029dd:	55                   	push   %ebp
  1029de:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e3:	8b 00                	mov    (%eax),%eax
  1029e5:	8d 50 01             	lea    0x1(%eax),%edx
  1029e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029eb:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f0:	8b 00                	mov    (%eax),%eax
}
  1029f2:	5d                   	pop    %ebp
  1029f3:	c3                   	ret    

001029f4 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029f4:	55                   	push   %ebp
  1029f5:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1029fa:	8b 00                	mov    (%eax),%eax
  1029fc:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029ff:	8b 45 08             	mov    0x8(%ebp),%eax
  102a02:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a04:	8b 45 08             	mov    0x8(%ebp),%eax
  102a07:	8b 00                	mov    (%eax),%eax
}
  102a09:	5d                   	pop    %ebp
  102a0a:	c3                   	ret    

00102a0b <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  102a0b:	55                   	push   %ebp
  102a0c:	89 e5                	mov    %esp,%ebp
  102a0e:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a11:	9c                   	pushf  
  102a12:	58                   	pop    %eax
  102a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a19:	25 00 02 00 00       	and    $0x200,%eax
  102a1e:	85 c0                	test   %eax,%eax
  102a20:	74 0c                	je     102a2e <__intr_save+0x23>
        intr_disable();
  102a22:	e8 53 ee ff ff       	call   10187a <intr_disable>
        return 1;
  102a27:	b8 01 00 00 00       	mov    $0x1,%eax
  102a2c:	eb 05                	jmp    102a33 <__intr_save+0x28>
    }
    return 0;
  102a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a33:	c9                   	leave  
  102a34:	c3                   	ret    

00102a35 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  102a35:	55                   	push   %ebp
  102a36:	89 e5                	mov    %esp,%ebp
  102a38:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a3f:	74 05                	je     102a46 <__intr_restore+0x11>
        intr_enable();
  102a41:	e8 2d ee ff ff       	call   101873 <intr_enable>
    }
}
  102a46:	90                   	nop
  102a47:	c9                   	leave  
  102a48:	c3                   	ret    

00102a49 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a49:	55                   	push   %ebp
  102a4a:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  102a4f:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a52:	b8 23 00 00 00       	mov    $0x23,%eax
  102a57:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a59:	b8 23 00 00 00       	mov    $0x23,%eax
  102a5e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a60:	b8 10 00 00 00       	mov    $0x10,%eax
  102a65:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a67:	b8 10 00 00 00       	mov    $0x10,%eax
  102a6c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a6e:	b8 10 00 00 00       	mov    $0x10,%eax
  102a73:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a75:	ea 7c 2a 10 00 08 00 	ljmp   $0x8,$0x102a7c
}
  102a7c:	90                   	nop
  102a7d:	5d                   	pop    %ebp
  102a7e:	c3                   	ret    

00102a7f <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a7f:	55                   	push   %ebp
  102a80:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a82:	8b 45 08             	mov    0x8(%ebp),%eax
  102a85:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102a8a:	90                   	nop
  102a8b:	5d                   	pop    %ebp
  102a8c:	c3                   	ret    

00102a8d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a8d:	55                   	push   %ebp
  102a8e:	89 e5                	mov    %esp,%ebp
  102a90:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a93:	b8 00 70 11 00       	mov    $0x117000,%eax
  102a98:	89 04 24             	mov    %eax,(%esp)
  102a9b:	e8 df ff ff ff       	call   102a7f <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102aa0:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102aa7:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102aa9:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102ab0:	68 00 
  102ab2:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ab7:	0f b7 c0             	movzwl %ax,%eax
  102aba:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102ac0:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ac5:	c1 e8 10             	shr    $0x10,%eax
  102ac8:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102acd:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ad4:	24 f0                	and    $0xf0,%al
  102ad6:	0c 09                	or     $0x9,%al
  102ad8:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102add:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ae4:	24 ef                	and    $0xef,%al
  102ae6:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102aeb:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102af2:	24 9f                	and    $0x9f,%al
  102af4:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102af9:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b00:	0c 80                	or     $0x80,%al
  102b02:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b07:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b0e:	24 f0                	and    $0xf0,%al
  102b10:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b15:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b1c:	24 ef                	and    $0xef,%al
  102b1e:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b23:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b2a:	24 df                	and    $0xdf,%al
  102b2c:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b31:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b38:	0c 40                	or     $0x40,%al
  102b3a:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b3f:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b46:	24 7f                	and    $0x7f,%al
  102b48:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b4d:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b52:	c1 e8 18             	shr    $0x18,%eax
  102b55:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b5a:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b61:	e8 e3 fe ff ff       	call   102a49 <lgdt>
  102b66:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b6c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b70:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b73:	90                   	nop
  102b74:	c9                   	leave  
  102b75:	c3                   	ret    

00102b76 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b76:	55                   	push   %ebp
  102b77:	89 e5                	mov    %esp,%ebp
  102b79:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b7c:	c7 05 10 af 11 00 58 	movl   $0x106f58,0x11af10
  102b83:	6f 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b86:	a1 10 af 11 00       	mov    0x11af10,%eax
  102b8b:	8b 00                	mov    (%eax),%eax
  102b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b91:	c7 04 24 10 66 10 00 	movl   $0x106610,(%esp)
  102b98:	e8 f5 d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102b9d:	a1 10 af 11 00       	mov    0x11af10,%eax
  102ba2:	8b 40 04             	mov    0x4(%eax),%eax
  102ba5:	ff d0                	call   *%eax
}
  102ba7:	90                   	nop
  102ba8:	c9                   	leave  
  102ba9:	c3                   	ret    

00102baa <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102baa:	55                   	push   %ebp
  102bab:	89 e5                	mov    %esp,%ebp
  102bad:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102bb0:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bb5:	8b 40 08             	mov    0x8(%eax),%eax
  102bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bbb:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  102bc2:	89 14 24             	mov    %edx,(%esp)
  102bc5:	ff d0                	call   *%eax
}
  102bc7:	90                   	nop
  102bc8:	c9                   	leave  
  102bc9:	c3                   	ret    

00102bca <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bca:	55                   	push   %ebp
  102bcb:	89 e5                	mov    %esp,%ebp
  102bcd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102bd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bd7:	e8 2f fe ff ff       	call   102a0b <__intr_save>
  102bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102bdf:	a1 10 af 11 00       	mov    0x11af10,%eax
  102be4:	8b 40 0c             	mov    0xc(%eax),%eax
  102be7:	8b 55 08             	mov    0x8(%ebp),%edx
  102bea:	89 14 24             	mov    %edx,(%esp)
  102bed:	ff d0                	call   *%eax
  102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bf5:	89 04 24             	mov    %eax,(%esp)
  102bf8:	e8 38 fe ff ff       	call   102a35 <__intr_restore>
    return page;
  102bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c00:	c9                   	leave  
  102c01:	c3                   	ret    

00102c02 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c02:	55                   	push   %ebp
  102c03:	89 e5                	mov    %esp,%ebp
  102c05:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c08:	e8 fe fd ff ff       	call   102a0b <__intr_save>
  102c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c10:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c15:	8b 40 10             	mov    0x10(%eax),%eax
  102c18:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  102c22:	89 14 24             	mov    %edx,(%esp)
  102c25:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c2a:	89 04 24             	mov    %eax,(%esp)
  102c2d:	e8 03 fe ff ff       	call   102a35 <__intr_restore>
}
  102c32:	90                   	nop
  102c33:	c9                   	leave  
  102c34:	c3                   	ret    

00102c35 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c35:	55                   	push   %ebp
  102c36:	89 e5                	mov    %esp,%ebp
  102c38:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c3b:	e8 cb fd ff ff       	call   102a0b <__intr_save>
  102c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c43:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c48:	8b 40 14             	mov    0x14(%eax),%eax
  102c4b:	ff d0                	call   *%eax
  102c4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c53:	89 04 24             	mov    %eax,(%esp)
  102c56:	e8 da fd ff ff       	call   102a35 <__intr_restore>
    return ret;
  102c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c5e:	c9                   	leave  
  102c5f:	c3                   	ret    

00102c60 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c60:	55                   	push   %ebp
  102c61:	89 e5                	mov    %esp,%ebp
  102c63:	57                   	push   %edi
  102c64:	56                   	push   %esi
  102c65:	53                   	push   %ebx
  102c66:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c6c:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c73:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c81:	c7 04 24 27 66 10 00 	movl   $0x106627,(%esp)
  102c88:	e8 05 d6 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c8d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c94:	e9 22 01 00 00       	jmp    102dbb <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c99:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c9f:	89 d0                	mov    %edx,%eax
  102ca1:	c1 e0 02             	shl    $0x2,%eax
  102ca4:	01 d0                	add    %edx,%eax
  102ca6:	c1 e0 02             	shl    $0x2,%eax
  102ca9:	01 c8                	add    %ecx,%eax
  102cab:	8b 50 08             	mov    0x8(%eax),%edx
  102cae:	8b 40 04             	mov    0x4(%eax),%eax
  102cb1:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102cb4:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102cb7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cbd:	89 d0                	mov    %edx,%eax
  102cbf:	c1 e0 02             	shl    $0x2,%eax
  102cc2:	01 d0                	add    %edx,%eax
  102cc4:	c1 e0 02             	shl    $0x2,%eax
  102cc7:	01 c8                	add    %ecx,%eax
  102cc9:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ccc:	8b 58 10             	mov    0x10(%eax),%ebx
  102ccf:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102cd2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102cd5:	01 c8                	add    %ecx,%eax
  102cd7:	11 da                	adc    %ebx,%edx
  102cd9:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102cdc:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cdf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ce2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ce5:	89 d0                	mov    %edx,%eax
  102ce7:	c1 e0 02             	shl    $0x2,%eax
  102cea:	01 d0                	add    %edx,%eax
  102cec:	c1 e0 02             	shl    $0x2,%eax
  102cef:	01 c8                	add    %ecx,%eax
  102cf1:	83 c0 14             	add    $0x14,%eax
  102cf4:	8b 00                	mov    (%eax),%eax
  102cf6:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102cf9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102cfc:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102cff:	83 c0 ff             	add    $0xffffffff,%eax
  102d02:	83 d2 ff             	adc    $0xffffffff,%edx
  102d05:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102d0b:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102d11:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d14:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d17:	89 d0                	mov    %edx,%eax
  102d19:	c1 e0 02             	shl    $0x2,%eax
  102d1c:	01 d0                	add    %edx,%eax
  102d1e:	c1 e0 02             	shl    $0x2,%eax
  102d21:	01 c8                	add    %ecx,%eax
  102d23:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d26:	8b 58 10             	mov    0x10(%eax),%ebx
  102d29:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102d2c:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102d30:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102d36:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102d3c:	89 44 24 14          	mov    %eax,0x14(%esp)
  102d40:	89 54 24 18          	mov    %edx,0x18(%esp)
  102d44:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d47:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d5a:	c7 04 24 34 66 10 00 	movl   $0x106634,(%esp)
  102d61:	e8 2c d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d66:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d69:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d6c:	89 d0                	mov    %edx,%eax
  102d6e:	c1 e0 02             	shl    $0x2,%eax
  102d71:	01 d0                	add    %edx,%eax
  102d73:	c1 e0 02             	shl    $0x2,%eax
  102d76:	01 c8                	add    %ecx,%eax
  102d78:	83 c0 14             	add    $0x14,%eax
  102d7b:	8b 00                	mov    (%eax),%eax
  102d7d:	83 f8 01             	cmp    $0x1,%eax
  102d80:	75 36                	jne    102db8 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d88:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d8b:	77 2b                	ja     102db8 <page_init+0x158>
  102d8d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d90:	72 05                	jb     102d97 <page_init+0x137>
  102d92:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d95:	73 21                	jae    102db8 <page_init+0x158>
  102d97:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d9b:	77 1b                	ja     102db8 <page_init+0x158>
  102d9d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102da1:	72 09                	jb     102dac <page_init+0x14c>
  102da3:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102daa:	77 0c                	ja     102db8 <page_init+0x158>
                maxpa = end;
  102dac:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102daf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102db2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102db5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102db8:	ff 45 dc             	incl   -0x24(%ebp)
  102dbb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102dbe:	8b 00                	mov    (%eax),%eax
  102dc0:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102dc3:	0f 8f d0 fe ff ff    	jg     102c99 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102dc9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dcd:	72 1d                	jb     102dec <page_init+0x18c>
  102dcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dd3:	77 09                	ja     102dde <page_init+0x17e>
  102dd5:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102ddc:	76 0e                	jbe    102dec <page_init+0x18c>
        maxpa = KMEMSIZE;
  102dde:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102de5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102dec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102def:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102df2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102df6:	c1 ea 0c             	shr    $0xc,%edx
  102df9:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102dfe:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102e05:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102e0a:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e0d:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e10:	01 d0                	add    %edx,%eax
  102e12:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102e15:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e18:	ba 00 00 00 00       	mov    $0x0,%edx
  102e1d:	f7 75 ac             	divl   -0x54(%ebp)
  102e20:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e23:	29 d0                	sub    %edx,%eax
  102e25:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e2a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e31:	eb 2e                	jmp    102e61 <page_init+0x201>
        SetPageReserved(pages + i);
  102e33:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e39:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e3c:	89 d0                	mov    %edx,%eax
  102e3e:	c1 e0 02             	shl    $0x2,%eax
  102e41:	01 d0                	add    %edx,%eax
  102e43:	c1 e0 02             	shl    $0x2,%eax
  102e46:	01 c8                	add    %ecx,%eax
  102e48:	83 c0 04             	add    $0x4,%eax
  102e4b:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e52:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e55:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e58:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e5b:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  102e5e:	ff 45 dc             	incl   -0x24(%ebp)
  102e61:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e64:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e69:	39 c2                	cmp    %eax,%edx
  102e6b:	72 c6                	jb     102e33 <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e6d:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102e73:	89 d0                	mov    %edx,%eax
  102e75:	c1 e0 02             	shl    $0x2,%eax
  102e78:	01 d0                	add    %edx,%eax
  102e7a:	c1 e0 02             	shl    $0x2,%eax
  102e7d:	89 c2                	mov    %eax,%edx
  102e7f:	a1 18 af 11 00       	mov    0x11af18,%eax
  102e84:	01 d0                	add    %edx,%eax
  102e86:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e89:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102e90:	77 23                	ja     102eb5 <page_init+0x255>
  102e92:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e99:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  102ea0:	00 
  102ea1:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102ea8:	00 
  102ea9:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  102eb0:	e8 34 d5 ff ff       	call   1003e9 <__panic>
  102eb5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102eb8:	05 00 00 00 40       	add    $0x40000000,%eax
  102ebd:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ec0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ec7:	e9 61 01 00 00       	jmp    10302d <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102ecc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ecf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ed2:	89 d0                	mov    %edx,%eax
  102ed4:	c1 e0 02             	shl    $0x2,%eax
  102ed7:	01 d0                	add    %edx,%eax
  102ed9:	c1 e0 02             	shl    $0x2,%eax
  102edc:	01 c8                	add    %ecx,%eax
  102ede:	8b 50 08             	mov    0x8(%eax),%edx
  102ee1:	8b 40 04             	mov    0x4(%eax),%eax
  102ee4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ee7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102eea:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ef0:	89 d0                	mov    %edx,%eax
  102ef2:	c1 e0 02             	shl    $0x2,%eax
  102ef5:	01 d0                	add    %edx,%eax
  102ef7:	c1 e0 02             	shl    $0x2,%eax
  102efa:	01 c8                	add    %ecx,%eax
  102efc:	8b 48 0c             	mov    0xc(%eax),%ecx
  102eff:	8b 58 10             	mov    0x10(%eax),%ebx
  102f02:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f05:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f08:	01 c8                	add    %ecx,%eax
  102f0a:	11 da                	adc    %ebx,%edx
  102f0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f0f:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102f12:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f15:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f18:	89 d0                	mov    %edx,%eax
  102f1a:	c1 e0 02             	shl    $0x2,%eax
  102f1d:	01 d0                	add    %edx,%eax
  102f1f:	c1 e0 02             	shl    $0x2,%eax
  102f22:	01 c8                	add    %ecx,%eax
  102f24:	83 c0 14             	add    $0x14,%eax
  102f27:	8b 00                	mov    (%eax),%eax
  102f29:	83 f8 01             	cmp    $0x1,%eax
  102f2c:	0f 85 f8 00 00 00    	jne    10302a <page_init+0x3ca>
            if (begin < freemem) {
  102f32:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f35:	ba 00 00 00 00       	mov    $0x0,%edx
  102f3a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f3d:	72 17                	jb     102f56 <page_init+0x2f6>
  102f3f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f42:	77 05                	ja     102f49 <page_init+0x2e9>
  102f44:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f47:	76 0d                	jbe    102f56 <page_init+0x2f6>
                begin = freemem;
  102f49:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f4f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f56:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f5a:	72 1d                	jb     102f79 <page_init+0x319>
  102f5c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f60:	77 09                	ja     102f6b <page_init+0x30b>
  102f62:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f69:	76 0e                	jbe    102f79 <page_init+0x319>
                end = KMEMSIZE;
  102f6b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f72:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f7c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f7f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f82:	0f 87 a2 00 00 00    	ja     10302a <page_init+0x3ca>
  102f88:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f8b:	72 09                	jb     102f96 <page_init+0x336>
  102f8d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f90:	0f 83 94 00 00 00    	jae    10302a <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
  102f96:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f9d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102fa0:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102fa3:	01 d0                	add    %edx,%eax
  102fa5:	48                   	dec    %eax
  102fa6:	89 45 98             	mov    %eax,-0x68(%ebp)
  102fa9:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fac:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb1:	f7 75 9c             	divl   -0x64(%ebp)
  102fb4:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fb7:	29 d0                	sub    %edx,%eax
  102fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  102fbe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fc1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fc4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fc7:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102fca:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  102fd2:	89 c3                	mov    %eax,%ebx
  102fd4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102fda:	89 de                	mov    %ebx,%esi
  102fdc:	89 d0                	mov    %edx,%eax
  102fde:	83 e0 00             	and    $0x0,%eax
  102fe1:	89 c7                	mov    %eax,%edi
  102fe3:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102fe6:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102fe9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fef:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102ff2:	77 36                	ja     10302a <page_init+0x3ca>
  102ff4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102ff7:	72 05                	jb     102ffe <page_init+0x39e>
  102ff9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102ffc:	73 2c                	jae    10302a <page_init+0x3ca>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102ffe:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103001:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103004:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103007:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10300a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10300e:	c1 ea 0c             	shr    $0xc,%edx
  103011:	89 c3                	mov    %eax,%ebx
  103013:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103016:	89 04 24             	mov    %eax,(%esp)
  103019:	e8 ae f8 ff ff       	call   1028cc <pa2page>
  10301e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103022:	89 04 24             	mov    %eax,(%esp)
  103025:	e8 80 fb ff ff       	call   102baa <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  10302a:	ff 45 dc             	incl   -0x24(%ebp)
  10302d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103030:	8b 00                	mov    (%eax),%eax
  103032:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103035:	0f 8f 91 fe ff ff    	jg     102ecc <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  10303b:	90                   	nop
  10303c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103042:	5b                   	pop    %ebx
  103043:	5e                   	pop    %esi
  103044:	5f                   	pop    %edi
  103045:	5d                   	pop    %ebp
  103046:	c3                   	ret    

00103047 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  103047:	55                   	push   %ebp
  103048:	89 e5                	mov    %esp,%ebp
  10304a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10304d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103050:	33 45 14             	xor    0x14(%ebp),%eax
  103053:	25 ff 0f 00 00       	and    $0xfff,%eax
  103058:	85 c0                	test   %eax,%eax
  10305a:	74 24                	je     103080 <boot_map_segment+0x39>
  10305c:	c7 44 24 0c 96 66 10 	movl   $0x106696,0xc(%esp)
  103063:	00 
  103064:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10306b:	00 
  10306c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103073:	00 
  103074:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10307b:	e8 69 d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103080:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103087:	8b 45 0c             	mov    0xc(%ebp),%eax
  10308a:	25 ff 0f 00 00       	and    $0xfff,%eax
  10308f:	89 c2                	mov    %eax,%edx
  103091:	8b 45 10             	mov    0x10(%ebp),%eax
  103094:	01 c2                	add    %eax,%edx
  103096:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103099:	01 d0                	add    %edx,%eax
  10309b:	48                   	dec    %eax
  10309c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10309f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030a2:	ba 00 00 00 00       	mov    $0x0,%edx
  1030a7:	f7 75 f0             	divl   -0x10(%ebp)
  1030aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030ad:	29 d0                	sub    %edx,%eax
  1030af:	c1 e8 0c             	shr    $0xc,%eax
  1030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030c3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1030c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030d4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030d7:	eb 68                	jmp    103141 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1030d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1030e0:	00 
  1030e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1030eb:	89 04 24             	mov    %eax,(%esp)
  1030ee:	e8 81 01 00 00       	call   103274 <get_pte>
  1030f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1030f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1030fa:	75 24                	jne    103120 <boot_map_segment+0xd9>
  1030fc:	c7 44 24 0c c2 66 10 	movl   $0x1066c2,0xc(%esp)
  103103:	00 
  103104:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10310b:	00 
  10310c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103113:	00 
  103114:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10311b:	e8 c9 d2 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103120:	8b 45 14             	mov    0x14(%ebp),%eax
  103123:	0b 45 18             	or     0x18(%ebp),%eax
  103126:	83 c8 01             	or     $0x1,%eax
  103129:	89 c2                	mov    %eax,%edx
  10312b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10312e:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103130:	ff 4d f4             	decl   -0xc(%ebp)
  103133:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10313a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103141:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103145:	75 92                	jne    1030d9 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  103147:	90                   	nop
  103148:	c9                   	leave  
  103149:	c3                   	ret    

0010314a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10314a:	55                   	push   %ebp
  10314b:	89 e5                	mov    %esp,%ebp
  10314d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103150:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103157:	e8 6e fa ff ff       	call   102bca <alloc_pages>
  10315c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10315f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103163:	75 1c                	jne    103181 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103165:	c7 44 24 08 cf 66 10 	movl   $0x1066cf,0x8(%esp)
  10316c:	00 
  10316d:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  103174:	00 
  103175:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10317c:	e8 68 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  103181:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103184:	89 04 24             	mov    %eax,(%esp)
  103187:	e8 8f f7 ff ff       	call   10291b <page2kva>
}
  10318c:	c9                   	leave  
  10318d:	c3                   	ret    

0010318e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10318e:	55                   	push   %ebp
  10318f:	89 e5                	mov    %esp,%ebp
  103191:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103194:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103199:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10319c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1031a3:	77 23                	ja     1031c8 <pmm_init+0x3a>
  1031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031ac:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  1031b3:	00 
  1031b4:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1031bb:	00 
  1031bc:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1031c3:	e8 21 d2 ff ff       	call   1003e9 <__panic>
  1031c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031cb:	05 00 00 00 40       	add    $0x40000000,%eax
  1031d0:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1031d5:	e8 9c f9 ff ff       	call   102b76 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1031da:	e8 81 fa ff ff       	call   102c60 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1031df:	e8 de 03 00 00       	call   1035c2 <check_alloc_page>

    check_pgdir();
  1031e4:	e8 f8 03 00 00       	call   1035e1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1031e9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031ee:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1031f4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031fc:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103203:	77 23                	ja     103228 <pmm_init+0x9a>
  103205:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103208:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10320c:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  103213:	00 
  103214:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  10321b:	00 
  10321c:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103223:	e8 c1 d1 ff ff       	call   1003e9 <__panic>
  103228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10322b:	05 00 00 00 40       	add    $0x40000000,%eax
  103230:	83 c8 03             	or     $0x3,%eax
  103233:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103235:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10323a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103241:	00 
  103242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103249:	00 
  10324a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103251:	38 
  103252:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  103259:	c0 
  10325a:	89 04 24             	mov    %eax,(%esp)
  10325d:	e8 e5 fd ff ff       	call   103047 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103262:	e8 26 f8 ff ff       	call   102a8d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  103267:	e8 11 0a 00 00       	call   103c7d <check_boot_pgdir>

    print_pgdir();
  10326c:	e8 8a 0e 00 00       	call   1040fb <print_pgdir>

}
  103271:	90                   	nop
  103272:	c9                   	leave  
  103273:	c3                   	ret    

00103274 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103274:	55                   	push   %ebp
  103275:	89 e5                	mov    %esp,%ebp
  103277:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep=&pgdir[PDX(la)];
  10327a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10327d:	c1 e8 16             	shr    $0x16,%eax
  103280:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103287:	8b 45 08             	mov    0x8(%ebp),%eax
  10328a:	01 d0                	add    %edx,%eax
  10328c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P))
  10328f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103292:	8b 00                	mov    (%eax),%eax
  103294:	83 e0 01             	and    $0x1,%eax
  103297:	85 c0                	test   %eax,%eax
  103299:	0f 85 af 00 00 00    	jne    10334e <get_pte+0xda>
    {
       struct Page *page;
       if (!create || (page = alloc_page()) == NULL) {
  10329f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032a3:	74 15                	je     1032ba <get_pte+0x46>
  1032a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032ac:	e8 19 f9 ff ff       	call   102bca <alloc_pages>
  1032b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1032b8:	75 0a                	jne    1032c4 <get_pte+0x50>
            return NULL;
  1032ba:	b8 00 00 00 00       	mov    $0x0,%eax
  1032bf:	e9 e7 00 00 00       	jmp    1033ab <get_pte+0x137>
        }
       set_page_ref(page,1);
  1032c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032cb:	00 
  1032cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032cf:	89 04 24             	mov    %eax,(%esp)
  1032d2:	e8 f8 f6 ff ff       	call   1029cf <set_page_ref>
       uintptr_t pa=page2pa(page);
  1032d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032da:	89 04 24             	mov    %eax,(%esp)
  1032dd:	e8 d4 f5 ff ff       	call   1028b6 <page2pa>
  1032e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
       memset(KADDR(pa),0,PGSIZE);
  1032e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032ee:	c1 e8 0c             	shr    $0xc,%eax
  1032f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032f4:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1032f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1032fc:	72 23                	jb     103321 <get_pte+0xad>
  1032fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103305:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  10330c:	00 
  10330d:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
  103314:	00 
  103315:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10331c:	e8 c8 d0 ff ff       	call   1003e9 <__panic>
  103321:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103324:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103329:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103330:	00 
  103331:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103338:	00 
  103339:	89 04 24             	mov    %eax,(%esp)
  10333c:	e8 40 23 00 00       	call   105681 <memset>
       *pdep= pa|PTE_P|PTE_W|PTE_U;
  103341:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103344:	83 c8 07             	or     $0x7,%eax
  103347:	89 c2                	mov    %eax,%edx
  103349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10334c:	89 10                	mov    %edx,(%eax)
    }
     return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10334e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103351:	8b 00                	mov    (%eax),%eax
  103353:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103358:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10335b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10335e:	c1 e8 0c             	shr    $0xc,%eax
  103361:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103364:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103369:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10336c:	72 23                	jb     103391 <get_pte+0x11d>
  10336e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103375:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  10337c:	00 
  10337d:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
  103384:	00 
  103385:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10338c:	e8 58 d0 ff ff       	call   1003e9 <__panic>
  103391:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103394:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103399:	89 c2                	mov    %eax,%edx
  10339b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10339e:	c1 e8 0c             	shr    $0xc,%eax
  1033a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  1033a6:	c1 e0 02             	shl    $0x2,%eax
  1033a9:	01 d0                	add    %edx,%eax

}
  1033ab:	c9                   	leave  
  1033ac:	c3                   	ret    

001033ad <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1033ad:	55                   	push   %ebp
  1033ae:	89 e5                	mov    %esp,%ebp
  1033b0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1033b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1033ba:	00 
  1033bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1033c5:	89 04 24             	mov    %eax,(%esp)
  1033c8:	e8 a7 fe ff ff       	call   103274 <get_pte>
  1033cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1033d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1033d4:	74 08                	je     1033de <get_page+0x31>
        *ptep_store = ptep;
  1033d6:	8b 45 10             	mov    0x10(%ebp),%eax
  1033d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1033dc:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1033de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033e2:	74 1b                	je     1033ff <get_page+0x52>
  1033e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e7:	8b 00                	mov    (%eax),%eax
  1033e9:	83 e0 01             	and    $0x1,%eax
  1033ec:	85 c0                	test   %eax,%eax
  1033ee:	74 0f                	je     1033ff <get_page+0x52>
        return pte2page(*ptep);
  1033f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033f3:	8b 00                	mov    (%eax),%eax
  1033f5:	89 04 24             	mov    %eax,(%esp)
  1033f8:	e8 72 f5 ff ff       	call   10296f <pte2page>
  1033fd:	eb 05                	jmp    103404 <get_page+0x57>
    }
    return NULL;
  1033ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103404:	c9                   	leave  
  103405:	c3                   	ret    

00103406 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103406:	55                   	push   %ebp
  103407:	89 e5                	mov    %esp,%ebp
  103409:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if(*ptep & PTE_P)
  10340c:	8b 45 10             	mov    0x10(%ebp),%eax
  10340f:	8b 00                	mov    (%eax),%eax
  103411:	83 e0 01             	and    $0x1,%eax
  103414:	85 c0                	test   %eax,%eax
  103416:	74 4d                	je     103465 <page_remove_pte+0x5f>
    {
        struct Page *page= pte2page(*ptep);
  103418:	8b 45 10             	mov    0x10(%ebp),%eax
  10341b:	8b 00                	mov    (%eax),%eax
  10341d:	89 04 24             	mov    %eax,(%esp)
  103420:	e8 4a f5 ff ff       	call   10296f <pte2page>
  103425:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0)
  103428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10342b:	89 04 24             	mov    %eax,(%esp)
  10342e:	e8 c1 f5 ff ff       	call   1029f4 <page_ref_dec>
  103433:	85 c0                	test   %eax,%eax
  103435:	75 13                	jne    10344a <page_remove_pte+0x44>
       // if(i==0)
        {
           free_page(page);
  103437:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10343e:	00 
  10343f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103442:	89 04 24             	mov    %eax,(%esp)
  103445:	e8 b8 f7 ff ff       	call   102c02 <free_pages>
        }
        *ptep=0;
  10344a:	8b 45 10             	mov    0x10(%ebp),%eax
  10344d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  103453:	8b 45 0c             	mov    0xc(%ebp),%eax
  103456:	89 44 24 04          	mov    %eax,0x4(%esp)
  10345a:	8b 45 08             	mov    0x8(%ebp),%eax
  10345d:	89 04 24             	mov    %eax,(%esp)
  103460:	e8 01 01 00 00       	call   103566 <tlb_invalidate>
    }
}
  103465:	90                   	nop
  103466:	c9                   	leave  
  103467:	c3                   	ret    

00103468 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103468:	55                   	push   %ebp
  103469:	89 e5                	mov    %esp,%ebp
  10346b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10346e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103475:	00 
  103476:	8b 45 0c             	mov    0xc(%ebp),%eax
  103479:	89 44 24 04          	mov    %eax,0x4(%esp)
  10347d:	8b 45 08             	mov    0x8(%ebp),%eax
  103480:	89 04 24             	mov    %eax,(%esp)
  103483:	e8 ec fd ff ff       	call   103274 <get_pte>
  103488:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10348b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10348f:	74 19                	je     1034aa <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103494:	89 44 24 08          	mov    %eax,0x8(%esp)
  103498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10349f:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a2:	89 04 24             	mov    %eax,(%esp)
  1034a5:	e8 5c ff ff ff       	call   103406 <page_remove_pte>
    }
}
  1034aa:	90                   	nop
  1034ab:	c9                   	leave  
  1034ac:	c3                   	ret    

001034ad <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1034ad:	55                   	push   %ebp
  1034ae:	89 e5                	mov    %esp,%ebp
  1034b0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1034b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1034ba:	00 
  1034bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1034be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c5:	89 04 24             	mov    %eax,(%esp)
  1034c8:	e8 a7 fd ff ff       	call   103274 <get_pte>
  1034cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1034d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034d4:	75 0a                	jne    1034e0 <page_insert+0x33>
        return -E_NO_MEM;
  1034d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1034db:	e9 84 00 00 00       	jmp    103564 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1034e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034e3:	89 04 24             	mov    %eax,(%esp)
  1034e6:	e8 f2 f4 ff ff       	call   1029dd <page_ref_inc>
    if (*ptep & PTE_P) {
  1034eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034ee:	8b 00                	mov    (%eax),%eax
  1034f0:	83 e0 01             	and    $0x1,%eax
  1034f3:	85 c0                	test   %eax,%eax
  1034f5:	74 3e                	je     103535 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1034f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034fa:	8b 00                	mov    (%eax),%eax
  1034fc:	89 04 24             	mov    %eax,(%esp)
  1034ff:	e8 6b f4 ff ff       	call   10296f <pte2page>
  103504:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10350a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10350d:	75 0d                	jne    10351c <page_insert+0x6f>
            page_ref_dec(page);
  10350f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103512:	89 04 24             	mov    %eax,(%esp)
  103515:	e8 da f4 ff ff       	call   1029f4 <page_ref_dec>
  10351a:	eb 19                	jmp    103535 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  10351c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10351f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103523:	8b 45 10             	mov    0x10(%ebp),%eax
  103526:	89 44 24 04          	mov    %eax,0x4(%esp)
  10352a:	8b 45 08             	mov    0x8(%ebp),%eax
  10352d:	89 04 24             	mov    %eax,(%esp)
  103530:	e8 d1 fe ff ff       	call   103406 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103535:	8b 45 0c             	mov    0xc(%ebp),%eax
  103538:	89 04 24             	mov    %eax,(%esp)
  10353b:	e8 76 f3 ff ff       	call   1028b6 <page2pa>
  103540:	0b 45 14             	or     0x14(%ebp),%eax
  103543:	83 c8 01             	or     $0x1,%eax
  103546:	89 c2                	mov    %eax,%edx
  103548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10354b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10354d:	8b 45 10             	mov    0x10(%ebp),%eax
  103550:	89 44 24 04          	mov    %eax,0x4(%esp)
  103554:	8b 45 08             	mov    0x8(%ebp),%eax
  103557:	89 04 24             	mov    %eax,(%esp)
  10355a:	e8 07 00 00 00       	call   103566 <tlb_invalidate>
    return 0;
  10355f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103564:	c9                   	leave  
  103565:	c3                   	ret    

00103566 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103566:	55                   	push   %ebp
  103567:	89 e5                	mov    %esp,%ebp
  103569:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10356c:	0f 20 d8             	mov    %cr3,%eax
  10356f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
  103572:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103575:	8b 45 08             	mov    0x8(%ebp),%eax
  103578:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10357b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103582:	77 23                	ja     1035a7 <tlb_invalidate+0x41>
  103584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103587:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10358b:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  103592:	00 
  103593:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
  10359a:	00 
  10359b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1035a2:	e8 42 ce ff ff       	call   1003e9 <__panic>
  1035a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035aa:	05 00 00 00 40       	add    $0x40000000,%eax
  1035af:	39 c2                	cmp    %eax,%edx
  1035b1:	75 0c                	jne    1035bf <tlb_invalidate+0x59>
        invlpg((void *)la);
  1035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1035b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035bc:	0f 01 38             	invlpg (%eax)
    }
}
  1035bf:	90                   	nop
  1035c0:	c9                   	leave  
  1035c1:	c3                   	ret    

001035c2 <check_alloc_page>:

static void
check_alloc_page(void) {
  1035c2:	55                   	push   %ebp
  1035c3:	89 e5                	mov    %esp,%ebp
  1035c5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1035c8:	a1 10 af 11 00       	mov    0x11af10,%eax
  1035cd:	8b 40 18             	mov    0x18(%eax),%eax
  1035d0:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1035d2:	c7 04 24 e8 66 10 00 	movl   $0x1066e8,(%esp)
  1035d9:	e8 b4 cc ff ff       	call   100292 <cprintf>
}
  1035de:	90                   	nop
  1035df:	c9                   	leave  
  1035e0:	c3                   	ret    

001035e1 <check_pgdir>:

static void
check_pgdir(void) {
  1035e1:	55                   	push   %ebp
  1035e2:	89 e5                	mov    %esp,%ebp
  1035e4:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1035e7:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1035ec:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1035f1:	76 24                	jbe    103617 <check_pgdir+0x36>
  1035f3:	c7 44 24 0c 07 67 10 	movl   $0x106707,0xc(%esp)
  1035fa:	00 
  1035fb:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103602:	00 
  103603:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  10360a:	00 
  10360b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103612:	e8 d2 cd ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103617:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10361c:	85 c0                	test   %eax,%eax
  10361e:	74 0e                	je     10362e <check_pgdir+0x4d>
  103620:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103625:	25 ff 0f 00 00       	and    $0xfff,%eax
  10362a:	85 c0                	test   %eax,%eax
  10362c:	74 24                	je     103652 <check_pgdir+0x71>
  10362e:	c7 44 24 0c 24 67 10 	movl   $0x106724,0xc(%esp)
  103635:	00 
  103636:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10363d:	00 
  10363e:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103645:	00 
  103646:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10364d:	e8 97 cd ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103652:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103657:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10365e:	00 
  10365f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103666:	00 
  103667:	89 04 24             	mov    %eax,(%esp)
  10366a:	e8 3e fd ff ff       	call   1033ad <get_page>
  10366f:	85 c0                	test   %eax,%eax
  103671:	74 24                	je     103697 <check_pgdir+0xb6>
  103673:	c7 44 24 0c 5c 67 10 	movl   $0x10675c,0xc(%esp)
  10367a:	00 
  10367b:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103682:	00 
  103683:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  10368a:	00 
  10368b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103692:	e8 52 cd ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10369e:	e8 27 f5 ff ff       	call   102bca <alloc_pages>
  1036a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1036a6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1036b2:	00 
  1036b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036ba:	00 
  1036bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1036be:	89 54 24 04          	mov    %edx,0x4(%esp)
  1036c2:	89 04 24             	mov    %eax,(%esp)
  1036c5:	e8 e3 fd ff ff       	call   1034ad <page_insert>
  1036ca:	85 c0                	test   %eax,%eax
  1036cc:	74 24                	je     1036f2 <check_pgdir+0x111>
  1036ce:	c7 44 24 0c 84 67 10 	movl   $0x106784,0xc(%esp)
  1036d5:	00 
  1036d6:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1036dd:	00 
  1036de:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  1036e5:	00 
  1036e6:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1036ed:	e8 f7 cc ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1036f2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036fe:	00 
  1036ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103706:	00 
  103707:	89 04 24             	mov    %eax,(%esp)
  10370a:	e8 65 fb ff ff       	call   103274 <get_pte>
  10370f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103712:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103716:	75 24                	jne    10373c <check_pgdir+0x15b>
  103718:	c7 44 24 0c b0 67 10 	movl   $0x1067b0,0xc(%esp)
  10371f:	00 
  103720:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103727:	00 
  103728:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  10372f:	00 
  103730:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103737:	e8 ad cc ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  10373c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10373f:	8b 00                	mov    (%eax),%eax
  103741:	89 04 24             	mov    %eax,(%esp)
  103744:	e8 26 f2 ff ff       	call   10296f <pte2page>
  103749:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10374c:	74 24                	je     103772 <check_pgdir+0x191>
  10374e:	c7 44 24 0c dd 67 10 	movl   $0x1067dd,0xc(%esp)
  103755:	00 
  103756:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10375d:	00 
  10375e:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  103765:	00 
  103766:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10376d:	e8 77 cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103775:	89 04 24             	mov    %eax,(%esp)
  103778:	e8 48 f2 ff ff       	call   1029c5 <page_ref>
  10377d:	83 f8 01             	cmp    $0x1,%eax
  103780:	74 24                	je     1037a6 <check_pgdir+0x1c5>
  103782:	c7 44 24 0c f3 67 10 	movl   $0x1067f3,0xc(%esp)
  103789:	00 
  10378a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103791:	00 
  103792:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103799:	00 
  10379a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1037a1:	e8 43 cc ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1037a6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037ab:	8b 00                	mov    (%eax),%eax
  1037ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1037b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1037b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037b8:	c1 e8 0c             	shr    $0xc,%eax
  1037bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1037be:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1037c3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1037c6:	72 23                	jb     1037eb <check_pgdir+0x20a>
  1037c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1037cf:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  1037d6:	00 
  1037d7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  1037de:	00 
  1037df:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1037e6:	e8 fe cb ff ff       	call   1003e9 <__panic>
  1037eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037ee:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1037f3:	83 c0 04             	add    $0x4,%eax
  1037f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1037f9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103805:	00 
  103806:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10380d:	00 
  10380e:	89 04 24             	mov    %eax,(%esp)
  103811:	e8 5e fa ff ff       	call   103274 <get_pte>
  103816:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103819:	74 24                	je     10383f <check_pgdir+0x25e>
  10381b:	c7 44 24 0c 08 68 10 	movl   $0x106808,0xc(%esp)
  103822:	00 
  103823:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10382a:	00 
  10382b:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103832:	00 
  103833:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10383a:	e8 aa cb ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  10383f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103846:	e8 7f f3 ff ff       	call   102bca <alloc_pages>
  10384b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10384e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103853:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  10385a:	00 
  10385b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103862:	00 
  103863:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103866:	89 54 24 04          	mov    %edx,0x4(%esp)
  10386a:	89 04 24             	mov    %eax,(%esp)
  10386d:	e8 3b fc ff ff       	call   1034ad <page_insert>
  103872:	85 c0                	test   %eax,%eax
  103874:	74 24                	je     10389a <check_pgdir+0x2b9>
  103876:	c7 44 24 0c 30 68 10 	movl   $0x106830,0xc(%esp)
  10387d:	00 
  10387e:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103885:	00 
  103886:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  10388d:	00 
  10388e:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103895:	e8 4f cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  10389a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10389f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038a6:	00 
  1038a7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038ae:	00 
  1038af:	89 04 24             	mov    %eax,(%esp)
  1038b2:	e8 bd f9 ff ff       	call   103274 <get_pte>
  1038b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1038ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1038be:	75 24                	jne    1038e4 <check_pgdir+0x303>
  1038c0:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  1038c7:	00 
  1038c8:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1038cf:	00 
  1038d0:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  1038d7:	00 
  1038d8:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1038df:	e8 05 cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  1038e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038e7:	8b 00                	mov    (%eax),%eax
  1038e9:	83 e0 04             	and    $0x4,%eax
  1038ec:	85 c0                	test   %eax,%eax
  1038ee:	75 24                	jne    103914 <check_pgdir+0x333>
  1038f0:	c7 44 24 0c 98 68 10 	movl   $0x106898,0xc(%esp)
  1038f7:	00 
  1038f8:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1038ff:	00 
  103900:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  103907:	00 
  103908:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10390f:	e8 d5 ca ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  103914:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103917:	8b 00                	mov    (%eax),%eax
  103919:	83 e0 02             	and    $0x2,%eax
  10391c:	85 c0                	test   %eax,%eax
  10391e:	75 24                	jne    103944 <check_pgdir+0x363>
  103920:	c7 44 24 0c a6 68 10 	movl   $0x1068a6,0xc(%esp)
  103927:	00 
  103928:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10392f:	00 
  103930:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  103937:	00 
  103938:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10393f:	e8 a5 ca ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103944:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103949:	8b 00                	mov    (%eax),%eax
  10394b:	83 e0 04             	and    $0x4,%eax
  10394e:	85 c0                	test   %eax,%eax
  103950:	75 24                	jne    103976 <check_pgdir+0x395>
  103952:	c7 44 24 0c b4 68 10 	movl   $0x1068b4,0xc(%esp)
  103959:	00 
  10395a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103961:	00 
  103962:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103969:	00 
  10396a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103971:	e8 73 ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  103976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103979:	89 04 24             	mov    %eax,(%esp)
  10397c:	e8 44 f0 ff ff       	call   1029c5 <page_ref>
  103981:	83 f8 01             	cmp    $0x1,%eax
  103984:	74 24                	je     1039aa <check_pgdir+0x3c9>
  103986:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  10398d:	00 
  10398e:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103995:	00 
  103996:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  10399d:	00 
  10399e:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1039a5:	e8 3f ca ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1039aa:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1039af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1039b6:	00 
  1039b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1039be:	00 
  1039bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1039c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1039c6:	89 04 24             	mov    %eax,(%esp)
  1039c9:	e8 df fa ff ff       	call   1034ad <page_insert>
  1039ce:	85 c0                	test   %eax,%eax
  1039d0:	74 24                	je     1039f6 <check_pgdir+0x415>
  1039d2:	c7 44 24 0c dc 68 10 	movl   $0x1068dc,0xc(%esp)
  1039d9:	00 
  1039da:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1039e1:	00 
  1039e2:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  1039e9:	00 
  1039ea:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1039f1:	e8 f3 c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  1039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039f9:	89 04 24             	mov    %eax,(%esp)
  1039fc:	e8 c4 ef ff ff       	call   1029c5 <page_ref>
  103a01:	83 f8 02             	cmp    $0x2,%eax
  103a04:	74 24                	je     103a2a <check_pgdir+0x449>
  103a06:	c7 44 24 0c 08 69 10 	movl   $0x106908,0xc(%esp)
  103a0d:	00 
  103a0e:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103a15:	00 
  103a16:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  103a1d:	00 
  103a1e:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103a25:	e8 bf c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a2d:	89 04 24             	mov    %eax,(%esp)
  103a30:	e8 90 ef ff ff       	call   1029c5 <page_ref>
  103a35:	85 c0                	test   %eax,%eax
  103a37:	74 24                	je     103a5d <check_pgdir+0x47c>
  103a39:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  103a40:	00 
  103a41:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103a48:	00 
  103a49:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103a50:	00 
  103a51:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103a58:	e8 8c c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a5d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a69:	00 
  103a6a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a71:	00 
  103a72:	89 04 24             	mov    %eax,(%esp)
  103a75:	e8 fa f7 ff ff       	call   103274 <get_pte>
  103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a81:	75 24                	jne    103aa7 <check_pgdir+0x4c6>
  103a83:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  103a8a:	00 
  103a8b:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103a92:	00 
  103a93:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103a9a:	00 
  103a9b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103aa2:	e8 42 c9 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103aaa:	8b 00                	mov    (%eax),%eax
  103aac:	89 04 24             	mov    %eax,(%esp)
  103aaf:	e8 bb ee ff ff       	call   10296f <pte2page>
  103ab4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103ab7:	74 24                	je     103add <check_pgdir+0x4fc>
  103ab9:	c7 44 24 0c dd 67 10 	movl   $0x1067dd,0xc(%esp)
  103ac0:	00 
  103ac1:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103ac8:	00 
  103ac9:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103ad0:	00 
  103ad1:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103ad8:	e8 0c c9 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103add:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ae0:	8b 00                	mov    (%eax),%eax
  103ae2:	83 e0 04             	and    $0x4,%eax
  103ae5:	85 c0                	test   %eax,%eax
  103ae7:	74 24                	je     103b0d <check_pgdir+0x52c>
  103ae9:	c7 44 24 0c 2c 69 10 	movl   $0x10692c,0xc(%esp)
  103af0:	00 
  103af1:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103af8:	00 
  103af9:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103b00:	00 
  103b01:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103b08:	e8 dc c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103b0d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103b19:	00 
  103b1a:	89 04 24             	mov    %eax,(%esp)
  103b1d:	e8 46 f9 ff ff       	call   103468 <page_remove>
    assert(page_ref(p1) == 1);
  103b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b25:	89 04 24             	mov    %eax,(%esp)
  103b28:	e8 98 ee ff ff       	call   1029c5 <page_ref>
  103b2d:	83 f8 01             	cmp    $0x1,%eax
  103b30:	74 24                	je     103b56 <check_pgdir+0x575>
  103b32:	c7 44 24 0c f3 67 10 	movl   $0x1067f3,0xc(%esp)
  103b39:	00 
  103b3a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103b41:	00 
  103b42:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103b49:	00 
  103b4a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103b51:	e8 93 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b59:	89 04 24             	mov    %eax,(%esp)
  103b5c:	e8 64 ee ff ff       	call   1029c5 <page_ref>
  103b61:	85 c0                	test   %eax,%eax
  103b63:	74 24                	je     103b89 <check_pgdir+0x5a8>
  103b65:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  103b6c:	00 
  103b6d:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103b74:	00 
  103b75:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  103b7c:	00 
  103b7d:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103b84:	e8 60 c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103b89:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b95:	00 
  103b96:	89 04 24             	mov    %eax,(%esp)
  103b99:	e8 ca f8 ff ff       	call   103468 <page_remove>
    assert(page_ref(p1) == 0);
  103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ba1:	89 04 24             	mov    %eax,(%esp)
  103ba4:	e8 1c ee ff ff       	call   1029c5 <page_ref>
  103ba9:	85 c0                	test   %eax,%eax
  103bab:	74 24                	je     103bd1 <check_pgdir+0x5f0>
  103bad:	c7 44 24 0c 41 69 10 	movl   $0x106941,0xc(%esp)
  103bb4:	00 
  103bb5:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103bbc:	00 
  103bbd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103bc4:	00 
  103bc5:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103bcc:	e8 18 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bd4:	89 04 24             	mov    %eax,(%esp)
  103bd7:	e8 e9 ed ff ff       	call   1029c5 <page_ref>
  103bdc:	85 c0                	test   %eax,%eax
  103bde:	74 24                	je     103c04 <check_pgdir+0x623>
  103be0:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  103be7:	00 
  103be8:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103bef:	00 
  103bf0:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103bf7:	00 
  103bf8:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103bff:	e8 e5 c7 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103c04:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c09:	8b 00                	mov    (%eax),%eax
  103c0b:	89 04 24             	mov    %eax,(%esp)
  103c0e:	e8 9a ed ff ff       	call   1029ad <pde2page>
  103c13:	89 04 24             	mov    %eax,(%esp)
  103c16:	e8 aa ed ff ff       	call   1029c5 <page_ref>
  103c1b:	83 f8 01             	cmp    $0x1,%eax
  103c1e:	74 24                	je     103c44 <check_pgdir+0x663>
  103c20:	c7 44 24 0c 54 69 10 	movl   $0x106954,0xc(%esp)
  103c27:	00 
  103c28:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103c2f:	00 
  103c30:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103c37:	00 
  103c38:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103c3f:	e8 a5 c7 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c44:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c49:	8b 00                	mov    (%eax),%eax
  103c4b:	89 04 24             	mov    %eax,(%esp)
  103c4e:	e8 5a ed ff ff       	call   1029ad <pde2page>
  103c53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c5a:	00 
  103c5b:	89 04 24             	mov    %eax,(%esp)
  103c5e:	e8 9f ef ff ff       	call   102c02 <free_pages>
    boot_pgdir[0] = 0;
  103c63:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c6e:	c7 04 24 7b 69 10 00 	movl   $0x10697b,(%esp)
  103c75:	e8 18 c6 ff ff       	call   100292 <cprintf>
}
  103c7a:	90                   	nop
  103c7b:	c9                   	leave  
  103c7c:	c3                   	ret    

00103c7d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103c7d:	55                   	push   %ebp
  103c7e:	89 e5                	mov    %esp,%ebp
  103c80:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103c83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c8a:	e9 ca 00 00 00       	jmp    103d59 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c98:	c1 e8 0c             	shr    $0xc,%eax
  103c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103c9e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103ca3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103ca6:	72 23                	jb     103ccb <check_boot_pgdir+0x4e>
  103ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103caf:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  103cb6:	00 
  103cb7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103cbe:	00 
  103cbf:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103cc6:	e8 1e c7 ff ff       	call   1003e9 <__panic>
  103ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cce:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103cd3:	89 c2                	mov    %eax,%edx
  103cd5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103cda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ce1:	00 
  103ce2:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ce6:	89 04 24             	mov    %eax,(%esp)
  103ce9:	e8 86 f5 ff ff       	call   103274 <get_pte>
  103cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103cf1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103cf5:	75 24                	jne    103d1b <check_boot_pgdir+0x9e>
  103cf7:	c7 44 24 0c 98 69 10 	movl   $0x106998,0xc(%esp)
  103cfe:	00 
  103cff:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103d06:	00 
  103d07:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103d0e:	00 
  103d0f:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103d16:	e8 ce c6 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103d1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103d1e:	8b 00                	mov    (%eax),%eax
  103d20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d25:	89 c2                	mov    %eax,%edx
  103d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d2a:	39 c2                	cmp    %eax,%edx
  103d2c:	74 24                	je     103d52 <check_boot_pgdir+0xd5>
  103d2e:	c7 44 24 0c d5 69 10 	movl   $0x1069d5,0xc(%esp)
  103d35:	00 
  103d36:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103d3d:	00 
  103d3e:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  103d45:	00 
  103d46:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103d4d:	e8 97 c6 ff ff       	call   1003e9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103d52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d5c:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103d61:	39 c2                	cmp    %eax,%edx
  103d63:	0f 82 26 ff ff ff    	jb     103c8f <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d69:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d6e:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d73:	8b 00                	mov    (%eax),%eax
  103d75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d7a:	89 c2                	mov    %eax,%edx
  103d7c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103d84:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103d8b:	77 23                	ja     103db0 <check_boot_pgdir+0x133>
  103d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d94:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  103d9b:	00 
  103d9c:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  103da3:	00 
  103da4:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103dab:	e8 39 c6 ff ff       	call   1003e9 <__panic>
  103db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103db3:	05 00 00 00 40       	add    $0x40000000,%eax
  103db8:	39 c2                	cmp    %eax,%edx
  103dba:	74 24                	je     103de0 <check_boot_pgdir+0x163>
  103dbc:	c7 44 24 0c ec 69 10 	movl   $0x1069ec,0xc(%esp)
  103dc3:	00 
  103dc4:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103dcb:	00 
  103dcc:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  103dd3:	00 
  103dd4:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103ddb:	e8 09 c6 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103de0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103de5:	8b 00                	mov    (%eax),%eax
  103de7:	85 c0                	test   %eax,%eax
  103de9:	74 24                	je     103e0f <check_boot_pgdir+0x192>
  103deb:	c7 44 24 0c 20 6a 10 	movl   $0x106a20,0xc(%esp)
  103df2:	00 
  103df3:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103dfa:	00 
  103dfb:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103e02:	00 
  103e03:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103e0a:	e8 da c5 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103e0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e16:	e8 af ed ff ff       	call   102bca <alloc_pages>
  103e1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103e1e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e23:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e2a:	00 
  103e2b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103e32:	00 
  103e33:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103e36:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e3a:	89 04 24             	mov    %eax,(%esp)
  103e3d:	e8 6b f6 ff ff       	call   1034ad <page_insert>
  103e42:	85 c0                	test   %eax,%eax
  103e44:	74 24                	je     103e6a <check_boot_pgdir+0x1ed>
  103e46:	c7 44 24 0c 34 6a 10 	movl   $0x106a34,0xc(%esp)
  103e4d:	00 
  103e4e:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103e55:	00 
  103e56:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  103e5d:	00 
  103e5e:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103e65:	e8 7f c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103e6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e6d:	89 04 24             	mov    %eax,(%esp)
  103e70:	e8 50 eb ff ff       	call   1029c5 <page_ref>
  103e75:	83 f8 01             	cmp    $0x1,%eax
  103e78:	74 24                	je     103e9e <check_boot_pgdir+0x221>
  103e7a:	c7 44 24 0c 62 6a 10 	movl   $0x106a62,0xc(%esp)
  103e81:	00 
  103e82:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103e89:	00 
  103e8a:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  103e91:	00 
  103e92:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103e99:	e8 4b c5 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103e9e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ea3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103eaa:	00 
  103eab:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103eb2:	00 
  103eb3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  103eba:	89 04 24             	mov    %eax,(%esp)
  103ebd:	e8 eb f5 ff ff       	call   1034ad <page_insert>
  103ec2:	85 c0                	test   %eax,%eax
  103ec4:	74 24                	je     103eea <check_boot_pgdir+0x26d>
  103ec6:	c7 44 24 0c 74 6a 10 	movl   $0x106a74,0xc(%esp)
  103ecd:	00 
  103ece:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103ed5:	00 
  103ed6:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  103edd:	00 
  103ede:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103ee5:	e8 ff c4 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103eed:	89 04 24             	mov    %eax,(%esp)
  103ef0:	e8 d0 ea ff ff       	call   1029c5 <page_ref>
  103ef5:	83 f8 02             	cmp    $0x2,%eax
  103ef8:	74 24                	je     103f1e <check_boot_pgdir+0x2a1>
  103efa:	c7 44 24 0c ab 6a 10 	movl   $0x106aab,0xc(%esp)
  103f01:	00 
  103f02:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103f09:	00 
  103f0a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  103f11:	00 
  103f12:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103f19:	e8 cb c4 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103f1e:	c7 45 dc bc 6a 10 00 	movl   $0x106abc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103f25:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  103f2c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f33:	e8 7f 14 00 00       	call   1053b7 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103f38:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103f3f:	00 
  103f40:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f47:	e8 e2 14 00 00       	call   10542e <strcmp>
  103f4c:	85 c0                	test   %eax,%eax
  103f4e:	74 24                	je     103f74 <check_boot_pgdir+0x2f7>
  103f50:	c7 44 24 0c d4 6a 10 	movl   $0x106ad4,0xc(%esp)
  103f57:	00 
  103f58:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103f5f:	00 
  103f60:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  103f67:	00 
  103f68:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103f6f:	e8 75 c4 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f77:	89 04 24             	mov    %eax,(%esp)
  103f7a:	e8 9c e9 ff ff       	call   10291b <page2kva>
  103f7f:	05 00 01 00 00       	add    $0x100,%eax
  103f84:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103f87:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f8e:	e8 ce 13 00 00       	call   105361 <strlen>
  103f93:	85 c0                	test   %eax,%eax
  103f95:	74 24                	je     103fbb <check_boot_pgdir+0x33e>
  103f97:	c7 44 24 0c 0c 6b 10 	movl   $0x106b0c,0xc(%esp)
  103f9e:	00 
  103f9f:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103fa6:	00 
  103fa7:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  103fae:	00 
  103faf:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103fb6:	e8 2e c4 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103fbb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fc2:	00 
  103fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fc6:	89 04 24             	mov    %eax,(%esp)
  103fc9:	e8 34 ec ff ff       	call   102c02 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103fce:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103fd3:	8b 00                	mov    (%eax),%eax
  103fd5:	89 04 24             	mov    %eax,(%esp)
  103fd8:	e8 d0 e9 ff ff       	call   1029ad <pde2page>
  103fdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fe4:	00 
  103fe5:	89 04 24             	mov    %eax,(%esp)
  103fe8:	e8 15 ec ff ff       	call   102c02 <free_pages>
    boot_pgdir[0] = 0;
  103fed:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ff2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103ff8:	c7 04 24 30 6b 10 00 	movl   $0x106b30,(%esp)
  103fff:	e8 8e c2 ff ff       	call   100292 <cprintf>
}
  104004:	90                   	nop
  104005:	c9                   	leave  
  104006:	c3                   	ret    

00104007 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  104007:	55                   	push   %ebp
  104008:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10400a:	8b 45 08             	mov    0x8(%ebp),%eax
  10400d:	83 e0 04             	and    $0x4,%eax
  104010:	85 c0                	test   %eax,%eax
  104012:	74 04                	je     104018 <perm2str+0x11>
  104014:	b0 75                	mov    $0x75,%al
  104016:	eb 02                	jmp    10401a <perm2str+0x13>
  104018:	b0 2d                	mov    $0x2d,%al
  10401a:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  10401f:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  104026:	8b 45 08             	mov    0x8(%ebp),%eax
  104029:	83 e0 02             	and    $0x2,%eax
  10402c:	85 c0                	test   %eax,%eax
  10402e:	74 04                	je     104034 <perm2str+0x2d>
  104030:	b0 77                	mov    $0x77,%al
  104032:	eb 02                	jmp    104036 <perm2str+0x2f>
  104034:	b0 2d                	mov    $0x2d,%al
  104036:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  10403b:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  104042:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  104047:	5d                   	pop    %ebp
  104048:	c3                   	ret    

00104049 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104049:	55                   	push   %ebp
  10404a:	89 e5                	mov    %esp,%ebp
  10404c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10404f:	8b 45 10             	mov    0x10(%ebp),%eax
  104052:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104055:	72 0d                	jb     104064 <get_pgtable_items+0x1b>
        return 0;
  104057:	b8 00 00 00 00       	mov    $0x0,%eax
  10405c:	e9 98 00 00 00       	jmp    1040f9 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104061:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  104064:	8b 45 10             	mov    0x10(%ebp),%eax
  104067:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10406a:	73 18                	jae    104084 <get_pgtable_items+0x3b>
  10406c:	8b 45 10             	mov    0x10(%ebp),%eax
  10406f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104076:	8b 45 14             	mov    0x14(%ebp),%eax
  104079:	01 d0                	add    %edx,%eax
  10407b:	8b 00                	mov    (%eax),%eax
  10407d:	83 e0 01             	and    $0x1,%eax
  104080:	85 c0                	test   %eax,%eax
  104082:	74 dd                	je     104061 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
  104084:	8b 45 10             	mov    0x10(%ebp),%eax
  104087:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10408a:	73 68                	jae    1040f4 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  10408c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104090:	74 08                	je     10409a <get_pgtable_items+0x51>
            *left_store = start;
  104092:	8b 45 18             	mov    0x18(%ebp),%eax
  104095:	8b 55 10             	mov    0x10(%ebp),%edx
  104098:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10409a:	8b 45 10             	mov    0x10(%ebp),%eax
  10409d:	8d 50 01             	lea    0x1(%eax),%edx
  1040a0:	89 55 10             	mov    %edx,0x10(%ebp)
  1040a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040aa:	8b 45 14             	mov    0x14(%ebp),%eax
  1040ad:	01 d0                	add    %edx,%eax
  1040af:	8b 00                	mov    (%eax),%eax
  1040b1:	83 e0 07             	and    $0x7,%eax
  1040b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1040b7:	eb 03                	jmp    1040bc <get_pgtable_items+0x73>
            start ++;
  1040b9:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  1040bc:	8b 45 10             	mov    0x10(%ebp),%eax
  1040bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040c2:	73 1d                	jae    1040e1 <get_pgtable_items+0x98>
  1040c4:	8b 45 10             	mov    0x10(%ebp),%eax
  1040c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1040d1:	01 d0                	add    %edx,%eax
  1040d3:	8b 00                	mov    (%eax),%eax
  1040d5:	83 e0 07             	and    $0x7,%eax
  1040d8:	89 c2                	mov    %eax,%edx
  1040da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040dd:	39 c2                	cmp    %eax,%edx
  1040df:	74 d8                	je     1040b9 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
  1040e1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1040e5:	74 08                	je     1040ef <get_pgtable_items+0xa6>
            *right_store = start;
  1040e7:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1040ea:	8b 55 10             	mov    0x10(%ebp),%edx
  1040ed:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1040ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040f2:	eb 05                	jmp    1040f9 <get_pgtable_items+0xb0>
    }
    return 0;
  1040f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1040f9:	c9                   	leave  
  1040fa:	c3                   	ret    

001040fb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1040fb:	55                   	push   %ebp
  1040fc:	89 e5                	mov    %esp,%ebp
  1040fe:	57                   	push   %edi
  1040ff:	56                   	push   %esi
  104100:	53                   	push   %ebx
  104101:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104104:	c7 04 24 50 6b 10 00 	movl   $0x106b50,(%esp)
  10410b:	e8 82 c1 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  104110:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104117:	e9 fa 00 00 00       	jmp    104216 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10411c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10411f:	89 04 24             	mov    %eax,(%esp)
  104122:	e8 e0 fe ff ff       	call   104007 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104127:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10412a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10412d:	29 d1                	sub    %edx,%ecx
  10412f:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104131:	89 d6                	mov    %edx,%esi
  104133:	c1 e6 16             	shl    $0x16,%esi
  104136:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104139:	89 d3                	mov    %edx,%ebx
  10413b:	c1 e3 16             	shl    $0x16,%ebx
  10413e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104141:	89 d1                	mov    %edx,%ecx
  104143:	c1 e1 16             	shl    $0x16,%ecx
  104146:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104149:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10414c:	29 d7                	sub    %edx,%edi
  10414e:	89 fa                	mov    %edi,%edx
  104150:	89 44 24 14          	mov    %eax,0x14(%esp)
  104154:	89 74 24 10          	mov    %esi,0x10(%esp)
  104158:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10415c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104160:	89 54 24 04          	mov    %edx,0x4(%esp)
  104164:	c7 04 24 81 6b 10 00 	movl   $0x106b81,(%esp)
  10416b:	e8 22 c1 ff ff       	call   100292 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  104170:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104173:	c1 e0 0a             	shl    $0xa,%eax
  104176:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104179:	eb 54                	jmp    1041cf <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10417b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10417e:	89 04 24             	mov    %eax,(%esp)
  104181:	e8 81 fe ff ff       	call   104007 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104186:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104189:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10418c:	29 d1                	sub    %edx,%ecx
  10418e:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104190:	89 d6                	mov    %edx,%esi
  104192:	c1 e6 0c             	shl    $0xc,%esi
  104195:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104198:	89 d3                	mov    %edx,%ebx
  10419a:	c1 e3 0c             	shl    $0xc,%ebx
  10419d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041a0:	89 d1                	mov    %edx,%ecx
  1041a2:	c1 e1 0c             	shl    $0xc,%ecx
  1041a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1041a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041ab:	29 d7                	sub    %edx,%edi
  1041ad:	89 fa                	mov    %edi,%edx
  1041af:	89 44 24 14          	mov    %eax,0x14(%esp)
  1041b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  1041b7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1041bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1041bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1041c3:	c7 04 24 a0 6b 10 00 	movl   $0x106ba0,(%esp)
  1041ca:	e8 c3 c0 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1041cf:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1041d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1041d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041da:	89 d3                	mov    %edx,%ebx
  1041dc:	c1 e3 0a             	shl    $0xa,%ebx
  1041df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041e2:	89 d1                	mov    %edx,%ecx
  1041e4:	c1 e1 0a             	shl    $0xa,%ecx
  1041e7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1041ea:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041ee:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1041f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1041f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104201:	89 0c 24             	mov    %ecx,(%esp)
  104204:	e8 40 fe ff ff       	call   104049 <get_pgtable_items>
  104209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10420c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104210:	0f 85 65 ff ff ff    	jne    10417b <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104216:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10421b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10421e:	8d 55 dc             	lea    -0x24(%ebp),%edx
  104221:	89 54 24 14          	mov    %edx,0x14(%esp)
  104225:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104228:	89 54 24 10          	mov    %edx,0x10(%esp)
  10422c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  104230:	89 44 24 08          	mov    %eax,0x8(%esp)
  104234:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10423b:	00 
  10423c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104243:	e8 01 fe ff ff       	call   104049 <get_pgtable_items>
  104248:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10424b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10424f:	0f 85 c7 fe ff ff    	jne    10411c <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104255:	c7 04 24 c4 6b 10 00 	movl   $0x106bc4,(%esp)
  10425c:	e8 31 c0 ff ff       	call   100292 <cprintf>
}
  104261:	90                   	nop
  104262:	83 c4 4c             	add    $0x4c,%esp
  104265:	5b                   	pop    %ebx
  104266:	5e                   	pop    %esi
  104267:	5f                   	pop    %edi
  104268:	5d                   	pop    %ebp
  104269:	c3                   	ret    

0010426a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10426a:	55                   	push   %ebp
  10426b:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10426d:	8b 45 08             	mov    0x8(%ebp),%eax
  104270:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  104276:	29 d0                	sub    %edx,%eax
  104278:	c1 f8 02             	sar    $0x2,%eax
  10427b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104281:	5d                   	pop    %ebp
  104282:	c3                   	ret    

00104283 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  104283:	55                   	push   %ebp
  104284:	89 e5                	mov    %esp,%ebp
  104286:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104289:	8b 45 08             	mov    0x8(%ebp),%eax
  10428c:	89 04 24             	mov    %eax,(%esp)
  10428f:	e8 d6 ff ff ff       	call   10426a <page2ppn>
  104294:	c1 e0 0c             	shl    $0xc,%eax
}
  104297:	c9                   	leave  
  104298:	c3                   	ret    

00104299 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  104299:	55                   	push   %ebp
  10429a:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10429c:	8b 45 08             	mov    0x8(%ebp),%eax
  10429f:	8b 00                	mov    (%eax),%eax
}
  1042a1:	5d                   	pop    %ebp
  1042a2:	c3                   	ret    

001042a3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1042a3:	55                   	push   %ebp
  1042a4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1042a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1042a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1042ac:	89 10                	mov    %edx,(%eax)
}
  1042ae:	90                   	nop
  1042af:	5d                   	pop    %ebp
  1042b0:	c3                   	ret    

001042b1 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1042b1:	55                   	push   %ebp
  1042b2:	89 e5                	mov    %esp,%ebp
  1042b4:	83 ec 10             	sub    $0x10,%esp
  1042b7:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1042be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1042c4:	89 50 04             	mov    %edx,0x4(%eax)
  1042c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042ca:	8b 50 04             	mov    0x4(%eax),%edx
  1042cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042d0:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1042d2:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1042d9:	00 00 00 
}
  1042dc:	90                   	nop
  1042dd:	c9                   	leave  
  1042de:	c3                   	ret    

001042df <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1042df:	55                   	push   %ebp
  1042e0:	89 e5                	mov    %esp,%ebp
  1042e2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1042e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1042e9:	75 24                	jne    10430f <default_init_memmap+0x30>
  1042eb:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  1042f2:	00 
  1042f3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1042fa:	00 
  1042fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104302:	00 
  104303:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10430a:	e8 da c0 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10430f:	8b 45 08             	mov    0x8(%ebp),%eax
  104312:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104315:	e9 de 00 00 00       	jmp    1043f8 <default_init_memmap+0x119>
        assert(PageReserved(p));
  10431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10431d:	83 c0 04             	add    $0x4,%eax
  104320:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10432a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10432d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104330:	0f a3 10             	bt     %edx,(%eax)
  104333:	19 c0                	sbb    %eax,%eax
  104335:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  104338:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10433c:	0f 95 c0             	setne  %al
  10433f:	0f b6 c0             	movzbl %al,%eax
  104342:	85 c0                	test   %eax,%eax
  104344:	75 24                	jne    10436a <default_init_memmap+0x8b>
  104346:	c7 44 24 0c 29 6c 10 	movl   $0x106c29,0xc(%esp)
  10434d:	00 
  10434e:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104355:	00 
  104356:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10435d:	00 
  10435e:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104365:	e8 7f c0 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  10436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10436d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104377:	8b 50 08             	mov    0x8(%eax),%edx
  10437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10437d:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);
  104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104383:	83 c0 04             	add    $0x4,%eax
  104386:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  10438d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104390:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104393:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104396:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
  104399:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1043a0:	00 
  1043a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043a4:	89 04 24             	mov    %eax,(%esp)
  1043a7:	e8 f7 fe ff ff       	call   1042a3 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
  1043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043af:	83 c0 0c             	add    $0xc,%eax
  1043b2:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
  1043b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1043bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043bf:	8b 00                	mov    (%eax),%eax
  1043c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043c4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  1043c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1043ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043d6:	89 10                	mov    %edx,(%eax)
  1043d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043db:	8b 10                	mov    (%eax),%edx
  1043dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1043e9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1043ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043f2:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1043f4:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1043f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1043fb:	89 d0                	mov    %edx,%eax
  1043fd:	c1 e0 02             	shl    $0x2,%eax
  104400:	01 d0                	add    %edx,%eax
  104402:	c1 e0 02             	shl    $0x2,%eax
  104405:	89 c2                	mov    %eax,%edx
  104407:	8b 45 08             	mov    0x8(%ebp),%eax
  10440a:	01 d0                	add    %edx,%eax
  10440c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10440f:	0f 85 05 ff ff ff    	jne    10431a <default_init_memmap+0x3b>
        p->flags = p->property = 0;
        SetPageProperty(p);
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
  104415:	8b 45 08             	mov    0x8(%ebp),%eax
  104418:	8b 55 0c             	mov    0xc(%ebp),%edx
  10441b:	89 50 08             	mov    %edx,0x8(%eax)
   // SetPageProperty(base);
   // list_add_before(&free_list, &(p->page_link));
    nr_free += n;
  10441e:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  104424:	8b 45 0c             	mov    0xc(%ebp),%eax
  104427:	01 d0                	add    %edx,%eax
  104429:	a3 24 af 11 00       	mov    %eax,0x11af24
   // list_add(&free_list, &(base->page_link));
}
  10442e:	90                   	nop
  10442f:	c9                   	leave  
  104430:	c3                   	ret    

00104431 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  104431:	55                   	push   %ebp
  104432:	89 e5                	mov    %esp,%ebp
  104434:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  104437:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10443b:	75 24                	jne    104461 <default_alloc_pages+0x30>
  10443d:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  104444:	00 
  104445:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10444c:	00 
  10444d:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  104454:	00 
  104455:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10445c:	e8 88 bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free)     return NULL;
  104461:	a1 24 af 11 00       	mov    0x11af24,%eax
  104466:	3b 45 08             	cmp    0x8(%ebp),%eax
  104469:	73 0a                	jae    104475 <default_alloc_pages+0x44>
  10446b:	b8 00 00 00 00       	mov    $0x0,%eax
  104470:	e9 04 01 00 00       	jmp    104579 <default_alloc_pages+0x148>
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
  104475:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10447c:	e9 d7 00 00 00       	jmp    104558 <default_alloc_pages+0x127>
        struct Page *p = le2page(le, page_link);
  104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104484:	83 e8 0c             	sub    $0xc,%eax
  104487:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  10448a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10448d:	8b 40 08             	mov    0x8(%eax),%eax
  104490:	3b 45 08             	cmp    0x8(%ebp),%eax
  104493:	0f 82 bf 00 00 00    	jb     104558 <default_alloc_pages+0x127>
            list_entry_t *next;
            for(int i=0;i<n;i++)
  104499:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1044a0:	eb 7b                	jmp    10451d <default_alloc_pages+0xec>
            {
                 struct Page *page = le2page(le, page_link);
  1044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a5:	83 e8 0c             	sub    $0xc,%eax
  1044a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
                 SetPageReserved(page);
  1044ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044ae:	83 c0 04             	add    $0x4,%eax
  1044b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  1044b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
  1044bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1044be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1044c1:	0f ab 10             	bts    %edx,(%eax)
                 ClearPageProperty(page);
  1044c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044c7:	83 c0 04             	add    $0x4,%eax
  1044ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  1044d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1044d4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1044d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044da:	0f b3 10             	btr    %edx,(%eax)
  1044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1044e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1044e6:	8b 40 04             	mov    0x4(%eax),%eax
                 next=list_next(le);
  1044e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1044ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1044f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1044f5:	8b 40 04             	mov    0x4(%eax),%eax
  1044f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1044fb:	8b 12                	mov    (%edx),%edx
  1044fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104500:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104503:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104506:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104509:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10450c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10450f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104512:	89 10                	mov    %edx,(%eax)
                 list_del(le);
                 le = next;
  104514:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104517:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            list_entry_t *next;
            for(int i=0;i<n;i++)
  10451a:	ff 45 f0             	incl   -0x10(%ebp)
  10451d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104520:	3b 45 08             	cmp    0x8(%ebp),%eax
  104523:	0f 82 79 ff ff ff    	jb     1044a2 <default_alloc_pages+0x71>
                 ClearPageProperty(page);
                 next=list_next(le);
                 list_del(le);
                 le = next;
            }
            if(p->property > n)
  104529:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10452c:	8b 40 08             	mov    0x8(%eax),%eax
  10452f:	3b 45 08             	cmp    0x8(%ebp),%eax
  104532:	76 12                	jbe    104546 <default_alloc_pages+0x115>
                 (le2page(le,page_link))->property = p->property - n;
  104534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104537:	8d 50 f4             	lea    -0xc(%eax),%edx
  10453a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10453d:	8b 40 08             	mov    0x8(%eax),%eax
  104540:	2b 45 08             	sub    0x8(%ebp),%eax
  104543:	89 42 08             	mov    %eax,0x8(%edx)
            nr_free -= n;
  104546:	a1 24 af 11 00       	mov    0x11af24,%eax
  10454b:	2b 45 08             	sub    0x8(%ebp),%eax
  10454e:	a3 24 af 11 00       	mov    %eax,0x11af24
            return p;
  104553:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104556:	eb 21                	jmp    104579 <default_alloc_pages+0x148>
  104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10455b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10455e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104561:	8b 40 04             	mov    0x4(%eax),%eax
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free)     return NULL;
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104564:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104567:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  10456e:	0f 85 0d ff ff ff    	jne    104481 <default_alloc_pages+0x50>
    }
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    } */
    return NULL;
  104574:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104579:	c9                   	leave  
  10457a:	c3                   	ret    

0010457b <default_free_pages>:
        le = list_next(le);
    } //insert,if the freeing block is before one free block
    list_add_before(le, &(base->page_link));//insert before le
}*/
static void
default_free_pages(struct Page *base, size_t n) {
  10457b:	55                   	push   %ebp
  10457c:	89 e5                	mov    %esp,%ebp
  10457e:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
  104581:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104585:	75 24                	jne    1045ab <default_free_pages+0x30>
  104587:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  10458e:	00 
  10458f:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104596:	00 
  104597:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  10459e:	00 
  10459f:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1045a6:	e8 3e be ff ff       	call   1003e9 <__panic>
    assert(PageReserved(base));
  1045ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1045ae:	83 c0 04             	add    $0x4,%eax
  1045b1:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  1045b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1045be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1045c1:	0f a3 10             	bt     %edx,(%eax)
  1045c4:	19 c0                	sbb    %eax,%eax
  1045c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
  1045c9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  1045cd:	0f 95 c0             	setne  %al
  1045d0:	0f b6 c0             	movzbl %al,%eax
  1045d3:	85 c0                	test   %eax,%eax
  1045d5:	75 24                	jne    1045fb <default_free_pages+0x80>
  1045d7:	c7 44 24 0c 39 6c 10 	movl   $0x106c39,0xc(%esp)
  1045de:	00 
  1045df:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1045e6:	00 
  1045e7:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  1045ee:	00 
  1045ef:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1045f6:	e8 ee bd ff ff       	call   1003e9 <__panic>

    list_entry_t *le = &free_list;
  1045fb:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104602:	eb 0b                	jmp    10460f <default_free_pages+0x94>
        if ((le2page(le, page_link)) > base) {
  104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104607:	83 e8 0c             	sub    $0xc,%eax
  10460a:	3b 45 08             	cmp    0x8(%ebp),%eax
  10460d:	77 1a                	ja     104629 <default_free_pages+0xae>
  10460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104618:	8b 40 04             	mov    0x4(%eax),%eax
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10461b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10461e:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  104625:	75 dd                	jne    104604 <default_free_pages+0x89>
  104627:	eb 01                	jmp    10462a <default_free_pages+0xaf>
        if ((le2page(le, page_link)) > base) {
            break;
  104629:	90                   	nop
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
  10462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10462d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104633:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
  104636:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104639:	8b 00                	mov    (%eax),%eax
  10463b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    while ((last_head = list_prev(last_head)) != &free_list) {
  10463e:	eb 0d                	jmp    10464d <default_free_pages+0xd2>
        if ((le2page(last_head, page_link))->property > 0) {
  104640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104643:	83 e8 0c             	sub    $0xc,%eax
  104646:	8b 40 08             	mov    0x8(%eax),%eax
  104649:	85 c0                	test   %eax,%eax
  10464b:	75 19                	jne    104666 <default_free_pages+0xeb>
  10464d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104650:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104653:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104656:	8b 00                	mov    (%eax),%eax
        if ((le2page(le, page_link)) > base) {
            break;
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
    while ((last_head = list_prev(last_head)) != &free_list) {
  104658:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10465b:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104662:	75 dc                	jne    104640 <default_free_pages+0xc5>
  104664:	eb 01                	jmp    104667 <default_free_pages+0xec>
        if ((le2page(last_head, page_link))->property > 0) {
            break;
  104666:	90                   	nop
        }
    }

    struct Page *p = base, *block_header;
  104667:	8b 45 08             	mov    0x8(%ebp),%eax
  10466a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    set_page_ref(base, 0);
  10466d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104674:	00 
  104675:	8b 45 08             	mov    0x8(%ebp),%eax
  104678:	89 04 24             	mov    %eax,(%esp)
  10467b:	e8 23 fc ff ff       	call   1042a3 <set_page_ref>
    for (; p != base + n; ++p) {
  104680:	e9 87 00 00 00       	jmp    10470c <default_free_pages+0x191>
        ClearPageReserved(p);
  104685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104688:	83 c0 04             	add    $0x4,%eax
  10468b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  104692:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104695:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104698:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10469b:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
  10469e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046a1:	83 c0 04             	add    $0x4,%eax
  1046a4:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  1046ab:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1046ae:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1046b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1046b4:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
  1046b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(le, &(p->page_link));
  1046c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046c4:	8d 50 0c             	lea    0xc(%eax),%edx
  1046c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1046cd:	89 55 b8             	mov    %edx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1046d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046d3:	8b 00                	mov    (%eax),%eax
  1046d5:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1046d8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  1046db:	89 45 b0             	mov    %eax,-0x50(%ebp)
  1046de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046e1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1046e4:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1046e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1046ea:	89 10                	mov    %edx,(%eax)
  1046ec:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1046ef:	8b 10                	mov    (%eax),%edx
  1046f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1046f4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1046f7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1046fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1046fd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104700:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104703:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104706:	89 10                	mov    %edx,(%eax)
        }
    }

    struct Page *p = base, *block_header;
    set_page_ref(base, 0);
    for (; p != base + n; ++p) {
  104708:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  10470c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10470f:	89 d0                	mov    %edx,%eax
  104711:	c1 e0 02             	shl    $0x2,%eax
  104714:	01 d0                	add    %edx,%eax
  104716:	c1 e0 02             	shl    $0x2,%eax
  104719:	89 c2                	mov    %eax,%edx
  10471b:	8b 45 08             	mov    0x8(%ebp),%eax
  10471e:	01 d0                	add    %edx,%eax
  104720:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104723:	0f 85 5c ff ff ff    	jne    104685 <default_free_pages+0x10a>
        ClearPageReserved(p);
        SetPageProperty(p);
        p->property = 0;
        list_add_before(le, &(p->page_link));
    }
    if ((last_head == &free_list) || ((le2page(insert_prev, page_link)) != base - 1)) {
  104729:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104730:	74 10                	je     104742 <default_free_pages+0x1c7>
  104732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104735:	8d 50 f4             	lea    -0xc(%eax),%edx
  104738:	8b 45 08             	mov    0x8(%ebp),%eax
  10473b:	83 e8 14             	sub    $0x14,%eax
  10473e:	39 c2                	cmp    %eax,%edx
  104740:	74 11                	je     104753 <default_free_pages+0x1d8>
        base->property = n;
  104742:	8b 45 08             	mov    0x8(%ebp),%eax
  104745:	8b 55 0c             	mov    0xc(%ebp),%edx
  104748:	89 50 08             	mov    %edx,0x8(%eax)
        block_header = base;
  10474b:	8b 45 08             	mov    0x8(%ebp),%eax
  10474e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104751:	eb 1a                	jmp    10476d <default_free_pages+0x1f2>
    } else {
        block_header = le2page(last_head, page_link);
  104753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104756:	83 e8 0c             	sub    $0xc,%eax
  104759:	89 45 e8             	mov    %eax,-0x18(%ebp)
        block_header->property += n;
  10475c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10475f:	8b 50 08             	mov    0x8(%eax),%edx
  104762:	8b 45 0c             	mov    0xc(%ebp),%eax
  104765:	01 c2                	add    %eax,%edx
  104767:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10476a:	89 50 08             	mov    %edx,0x8(%eax)
    }
    struct Page *le_page = le2page(le, page_link);
  10476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104770:	83 e8 0c             	sub    $0xc,%eax
  104773:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if ((le != &free_list) && (le_page == base + n)) {
  104776:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  10477d:	74 37                	je     1047b6 <default_free_pages+0x23b>
  10477f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104782:	89 d0                	mov    %edx,%eax
  104784:	c1 e0 02             	shl    $0x2,%eax
  104787:	01 d0                	add    %edx,%eax
  104789:	c1 e0 02             	shl    $0x2,%eax
  10478c:	89 c2                	mov    %eax,%edx
  10478e:	8b 45 08             	mov    0x8(%ebp),%eax
  104791:	01 d0                	add    %edx,%eax
  104793:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104796:	75 1e                	jne    1047b6 <default_free_pages+0x23b>
        block_header->property += le_page->property;
  104798:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10479b:	8b 50 08             	mov    0x8(%eax),%edx
  10479e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1047a1:	8b 40 08             	mov    0x8(%eax),%eax
  1047a4:	01 c2                	add    %eax,%edx
  1047a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047a9:	89 50 08             	mov    %edx,0x8(%eax)
        le_page->property = 0;
  1047ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1047af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    nr_free += n;
  1047b6:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047bf:	01 d0                	add    %edx,%eax
  1047c1:	a3 24 af 11 00       	mov    %eax,0x11af24
}
  1047c6:	90                   	nop
  1047c7:	c9                   	leave  
  1047c8:	c3                   	ret    

001047c9 <default_nr_free_pages>:
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
}*/
static size_t
default_nr_free_pages(void) {
  1047c9:	55                   	push   %ebp
  1047ca:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1047cc:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  1047d1:	5d                   	pop    %ebp
  1047d2:	c3                   	ret    

001047d3 <basic_check>:

static void
basic_check(void) {
  1047d3:	55                   	push   %ebp
  1047d4:	89 e5                	mov    %esp,%ebp
  1047d6:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1047d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1047e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1047ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047f3:	e8 d2 e3 ff ff       	call   102bca <alloc_pages>
  1047f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1047fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1047ff:	75 24                	jne    104825 <basic_check+0x52>
  104801:	c7 44 24 0c 4c 6c 10 	movl   $0x106c4c,0xc(%esp)
  104808:	00 
  104809:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104810:	00 
  104811:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  104818:	00 
  104819:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104820:	e8 c4 bb ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104825:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10482c:	e8 99 e3 ff ff       	call   102bca <alloc_pages>
  104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104834:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104838:	75 24                	jne    10485e <basic_check+0x8b>
  10483a:	c7 44 24 0c 68 6c 10 	movl   $0x106c68,0xc(%esp)
  104841:	00 
  104842:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104849:	00 
  10484a:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  104851:	00 
  104852:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104859:	e8 8b bb ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10485e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104865:	e8 60 e3 ff ff       	call   102bca <alloc_pages>
  10486a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10486d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104871:	75 24                	jne    104897 <basic_check+0xc4>
  104873:	c7 44 24 0c 84 6c 10 	movl   $0x106c84,0xc(%esp)
  10487a:	00 
  10487b:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104882:	00 
  104883:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  10488a:	00 
  10488b:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104892:	e8 52 bb ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10489a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10489d:	74 10                	je     1048af <basic_check+0xdc>
  10489f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1048a5:	74 08                	je     1048af <basic_check+0xdc>
  1048a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048aa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1048ad:	75 24                	jne    1048d3 <basic_check+0x100>
  1048af:	c7 44 24 0c a0 6c 10 	movl   $0x106ca0,0xc(%esp)
  1048b6:	00 
  1048b7:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1048be:	00 
  1048bf:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  1048c6:	00 
  1048c7:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1048ce:	e8 16 bb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1048d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048d6:	89 04 24             	mov    %eax,(%esp)
  1048d9:	e8 bb f9 ff ff       	call   104299 <page_ref>
  1048de:	85 c0                	test   %eax,%eax
  1048e0:	75 1e                	jne    104900 <basic_check+0x12d>
  1048e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048e5:	89 04 24             	mov    %eax,(%esp)
  1048e8:	e8 ac f9 ff ff       	call   104299 <page_ref>
  1048ed:	85 c0                	test   %eax,%eax
  1048ef:	75 0f                	jne    104900 <basic_check+0x12d>
  1048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048f4:	89 04 24             	mov    %eax,(%esp)
  1048f7:	e8 9d f9 ff ff       	call   104299 <page_ref>
  1048fc:	85 c0                	test   %eax,%eax
  1048fe:	74 24                	je     104924 <basic_check+0x151>
  104900:	c7 44 24 0c c4 6c 10 	movl   $0x106cc4,0xc(%esp)
  104907:	00 
  104908:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10490f:	00 
  104910:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
  104917:	00 
  104918:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10491f:	e8 c5 ba ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104924:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104927:	89 04 24             	mov    %eax,(%esp)
  10492a:	e8 54 f9 ff ff       	call   104283 <page2pa>
  10492f:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104935:	c1 e2 0c             	shl    $0xc,%edx
  104938:	39 d0                	cmp    %edx,%eax
  10493a:	72 24                	jb     104960 <basic_check+0x18d>
  10493c:	c7 44 24 0c 00 6d 10 	movl   $0x106d00,0xc(%esp)
  104943:	00 
  104944:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10494b:	00 
  10494c:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  104953:	00 
  104954:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10495b:	e8 89 ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104963:	89 04 24             	mov    %eax,(%esp)
  104966:	e8 18 f9 ff ff       	call   104283 <page2pa>
  10496b:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104971:	c1 e2 0c             	shl    $0xc,%edx
  104974:	39 d0                	cmp    %edx,%eax
  104976:	72 24                	jb     10499c <basic_check+0x1c9>
  104978:	c7 44 24 0c 1d 6d 10 	movl   $0x106d1d,0xc(%esp)
  10497f:	00 
  104980:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104987:	00 
  104988:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  10498f:	00 
  104990:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104997:	e8 4d ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  10499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10499f:	89 04 24             	mov    %eax,(%esp)
  1049a2:	e8 dc f8 ff ff       	call   104283 <page2pa>
  1049a7:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1049ad:	c1 e2 0c             	shl    $0xc,%edx
  1049b0:	39 d0                	cmp    %edx,%eax
  1049b2:	72 24                	jb     1049d8 <basic_check+0x205>
  1049b4:	c7 44 24 0c 3a 6d 10 	movl   $0x106d3a,0xc(%esp)
  1049bb:	00 
  1049bc:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1049c3:	00 
  1049c4:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  1049cb:	00 
  1049cc:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1049d3:	e8 11 ba ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  1049d8:	a1 1c af 11 00       	mov    0x11af1c,%eax
  1049dd:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  1049e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1049e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1049e9:	c7 45 e4 1c af 11 00 	movl   $0x11af1c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1049f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1049f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1049f6:	89 50 04             	mov    %edx,0x4(%eax)
  1049f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1049fc:	8b 50 04             	mov    0x4(%eax),%edx
  1049ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a02:	89 10                	mov    %edx,(%eax)
  104a04:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  104a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104a0e:	8b 40 04             	mov    0x4(%eax),%eax
  104a11:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104a14:	0f 94 c0             	sete   %al
  104a17:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104a1a:	85 c0                	test   %eax,%eax
  104a1c:	75 24                	jne    104a42 <basic_check+0x26f>
  104a1e:	c7 44 24 0c 57 6d 10 	movl   $0x106d57,0xc(%esp)
  104a25:	00 
  104a26:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104a2d:	00 
  104a2e:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  104a35:	00 
  104a36:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104a3d:	e8 a7 b9 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104a42:	a1 24 af 11 00       	mov    0x11af24,%eax
  104a47:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104a4a:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104a51:	00 00 00 

    assert(alloc_page() == NULL);
  104a54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a5b:	e8 6a e1 ff ff       	call   102bca <alloc_pages>
  104a60:	85 c0                	test   %eax,%eax
  104a62:	74 24                	je     104a88 <basic_check+0x2b5>
  104a64:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  104a6b:	00 
  104a6c:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104a73:	00 
  104a74:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  104a7b:	00 
  104a7c:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104a83:	e8 61 b9 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104a88:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104a8f:	00 
  104a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a93:	89 04 24             	mov    %eax,(%esp)
  104a96:	e8 67 e1 ff ff       	call   102c02 <free_pages>
    free_page(p1);
  104a9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104aa2:	00 
  104aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aa6:	89 04 24             	mov    %eax,(%esp)
  104aa9:	e8 54 e1 ff ff       	call   102c02 <free_pages>
    free_page(p2);
  104aae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ab5:	00 
  104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ab9:	89 04 24             	mov    %eax,(%esp)
  104abc:	e8 41 e1 ff ff       	call   102c02 <free_pages>
    assert(nr_free == 3);
  104ac1:	a1 24 af 11 00       	mov    0x11af24,%eax
  104ac6:	83 f8 03             	cmp    $0x3,%eax
  104ac9:	74 24                	je     104aef <basic_check+0x31c>
  104acb:	c7 44 24 0c 83 6d 10 	movl   $0x106d83,0xc(%esp)
  104ad2:	00 
  104ad3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104ada:	00 
  104adb:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
  104ae2:	00 
  104ae3:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104aea:	e8 fa b8 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104af6:	e8 cf e0 ff ff       	call   102bca <alloc_pages>
  104afb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104afe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104b02:	75 24                	jne    104b28 <basic_check+0x355>
  104b04:	c7 44 24 0c 4c 6c 10 	movl   $0x106c4c,0xc(%esp)
  104b0b:	00 
  104b0c:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104b13:	00 
  104b14:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
  104b1b:	00 
  104b1c:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b23:	e8 c1 b8 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104b28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b2f:	e8 96 e0 ff ff       	call   102bca <alloc_pages>
  104b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b3b:	75 24                	jne    104b61 <basic_check+0x38e>
  104b3d:	c7 44 24 0c 68 6c 10 	movl   $0x106c68,0xc(%esp)
  104b44:	00 
  104b45:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104b4c:	00 
  104b4d:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
  104b54:	00 
  104b55:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b5c:	e8 88 b8 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b68:	e8 5d e0 ff ff       	call   102bca <alloc_pages>
  104b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104b70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104b74:	75 24                	jne    104b9a <basic_check+0x3c7>
  104b76:	c7 44 24 0c 84 6c 10 	movl   $0x106c84,0xc(%esp)
  104b7d:	00 
  104b7e:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104b85:	00 
  104b86:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  104b8d:	00 
  104b8e:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b95:	e8 4f b8 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104b9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ba1:	e8 24 e0 ff ff       	call   102bca <alloc_pages>
  104ba6:	85 c0                	test   %eax,%eax
  104ba8:	74 24                	je     104bce <basic_check+0x3fb>
  104baa:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  104bb1:	00 
  104bb2:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104bb9:	00 
  104bba:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  104bc1:	00 
  104bc2:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104bc9:	e8 1b b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104bce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bd5:	00 
  104bd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bd9:	89 04 24             	mov    %eax,(%esp)
  104bdc:	e8 21 e0 ff ff       	call   102c02 <free_pages>
  104be1:	c7 45 e8 1c af 11 00 	movl   $0x11af1c,-0x18(%ebp)
  104be8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104beb:	8b 40 04             	mov    0x4(%eax),%eax
  104bee:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104bf1:	0f 94 c0             	sete   %al
  104bf4:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104bf7:	85 c0                	test   %eax,%eax
  104bf9:	74 24                	je     104c1f <basic_check+0x44c>
  104bfb:	c7 44 24 0c 90 6d 10 	movl   $0x106d90,0xc(%esp)
  104c02:	00 
  104c03:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104c0a:	00 
  104c0b:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
  104c12:	00 
  104c13:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c1a:	e8 ca b7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104c1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c26:	e8 9f df ff ff       	call   102bca <alloc_pages>
  104c2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104c2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c31:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104c34:	74 24                	je     104c5a <basic_check+0x487>
  104c36:	c7 44 24 0c a8 6d 10 	movl   $0x106da8,0xc(%esp)
  104c3d:	00 
  104c3e:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104c45:	00 
  104c46:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
  104c4d:	00 
  104c4e:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c55:	e8 8f b7 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104c5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c61:	e8 64 df ff ff       	call   102bca <alloc_pages>
  104c66:	85 c0                	test   %eax,%eax
  104c68:	74 24                	je     104c8e <basic_check+0x4bb>
  104c6a:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  104c71:	00 
  104c72:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104c79:	00 
  104c7a:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
  104c81:	00 
  104c82:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c89:	e8 5b b7 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104c8e:	a1 24 af 11 00       	mov    0x11af24,%eax
  104c93:	85 c0                	test   %eax,%eax
  104c95:	74 24                	je     104cbb <basic_check+0x4e8>
  104c97:	c7 44 24 0c c1 6d 10 	movl   $0x106dc1,0xc(%esp)
  104c9e:	00 
  104c9f:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104ca6:	00 
  104ca7:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
  104cae:	00 
  104caf:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104cb6:	e8 2e b7 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104cbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104cbe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104cc1:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104cc6:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104ccc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ccf:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104cd4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cdb:	00 
  104cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104cdf:	89 04 24             	mov    %eax,(%esp)
  104ce2:	e8 1b df ff ff       	call   102c02 <free_pages>
    free_page(p1);
  104ce7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cee:	00 
  104cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cf2:	89 04 24             	mov    %eax,(%esp)
  104cf5:	e8 08 df ff ff       	call   102c02 <free_pages>
    free_page(p2);
  104cfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d01:	00 
  104d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d05:	89 04 24             	mov    %eax,(%esp)
  104d08:	e8 f5 de ff ff       	call   102c02 <free_pages>
}
  104d0d:	90                   	nop
  104d0e:	c9                   	leave  
  104d0f:	c3                   	ret    

00104d10 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104d10:	55                   	push   %ebp
  104d11:	89 e5                	mov    %esp,%ebp
  104d13:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104d19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104d20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104d27:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104d2e:	eb 6a                	jmp    104d9a <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d33:	83 e8 0c             	sub    $0xc,%eax
  104d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
  104d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d3c:	83 c0 04             	add    $0x4,%eax
  104d3f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  104d46:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104d49:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104d4c:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104d4f:	0f a3 10             	bt     %edx,(%eax)
  104d52:	19 c0                	sbb    %eax,%eax
  104d54:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  104d57:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  104d5b:	0f 95 c0             	setne  %al
  104d5e:	0f b6 c0             	movzbl %al,%eax
  104d61:	85 c0                	test   %eax,%eax
  104d63:	75 24                	jne    104d89 <default_check+0x79>
  104d65:	c7 44 24 0c ce 6d 10 	movl   $0x106dce,0xc(%esp)
  104d6c:	00 
  104d6d:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104d74:	00 
  104d75:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  104d7c:	00 
  104d7d:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104d84:	e8 60 b6 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104d89:	ff 45 f4             	incl   -0xc(%ebp)
  104d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d8f:	8b 50 08             	mov    0x8(%eax),%edx
  104d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d95:	01 d0                	add    %edx,%eax
  104d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104da3:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104da6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104da9:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104db0:	0f 85 7a ff ff ff    	jne    104d30 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  104db6:	e8 7a de ff ff       	call   102c35 <nr_free_pages>
  104dbb:	89 c2                	mov    %eax,%edx
  104dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dc0:	39 c2                	cmp    %eax,%edx
  104dc2:	74 24                	je     104de8 <default_check+0xd8>
  104dc4:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104dcb:	00 
  104dcc:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104dd3:	00 
  104dd4:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  104ddb:	00 
  104ddc:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104de3:	e8 01 b6 ff ff       	call   1003e9 <__panic>

    basic_check();
  104de8:	e8 e6 f9 ff ff       	call   1047d3 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104ded:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104df4:	e8 d1 dd ff ff       	call   102bca <alloc_pages>
  104df9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  104dfc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104e00:	75 24                	jne    104e26 <default_check+0x116>
  104e02:	c7 44 24 0c f7 6d 10 	movl   $0x106df7,0xc(%esp)
  104e09:	00 
  104e0a:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104e11:	00 
  104e12:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
  104e19:	00 
  104e1a:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104e21:	e8 c3 b5 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104e26:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104e29:	83 c0 04             	add    $0x4,%eax
  104e2c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  104e33:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e36:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104e39:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104e3c:	0f a3 10             	bt     %edx,(%eax)
  104e3f:	19 c0                	sbb    %eax,%eax
  104e41:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
  104e44:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  104e48:	0f 95 c0             	setne  %al
  104e4b:	0f b6 c0             	movzbl %al,%eax
  104e4e:	85 c0                	test   %eax,%eax
  104e50:	74 24                	je     104e76 <default_check+0x166>
  104e52:	c7 44 24 0c 02 6e 10 	movl   $0x106e02,0xc(%esp)
  104e59:	00 
  104e5a:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104e61:	00 
  104e62:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
  104e69:	00 
  104e6a:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104e71:	e8 73 b5 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104e76:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104e7b:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104e81:	89 45 80             	mov    %eax,-0x80(%ebp)
  104e84:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104e87:	c7 45 d0 1c af 11 00 	movl   $0x11af1c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104e8e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e91:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104e94:	89 50 04             	mov    %edx,0x4(%eax)
  104e97:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e9a:	8b 50 04             	mov    0x4(%eax),%edx
  104e9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104ea0:	89 10                	mov    %edx,(%eax)
  104ea2:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  104ea9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104eac:	8b 40 04             	mov    0x4(%eax),%eax
  104eaf:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104eb2:	0f 94 c0             	sete   %al
  104eb5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104eb8:	85 c0                	test   %eax,%eax
  104eba:	75 24                	jne    104ee0 <default_check+0x1d0>
  104ebc:	c7 44 24 0c 57 6d 10 	movl   $0x106d57,0xc(%esp)
  104ec3:	00 
  104ec4:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104ecb:	00 
  104ecc:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
  104ed3:	00 
  104ed4:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104edb:	e8 09 b5 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104ee0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ee7:	e8 de dc ff ff       	call   102bca <alloc_pages>
  104eec:	85 c0                	test   %eax,%eax
  104eee:	74 24                	je     104f14 <default_check+0x204>
  104ef0:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  104ef7:	00 
  104ef8:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104eff:	00 
  104f00:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
  104f07:	00 
  104f08:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104f0f:	e8 d5 b4 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104f14:	a1 24 af 11 00       	mov    0x11af24,%eax
  104f19:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
  104f1c:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104f23:	00 00 00 

    free_pages(p0 + 2, 3);
  104f26:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f29:	83 c0 28             	add    $0x28,%eax
  104f2c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104f33:	00 
  104f34:	89 04 24             	mov    %eax,(%esp)
  104f37:	e8 c6 dc ff ff       	call   102c02 <free_pages>
    assert(alloc_pages(4) == NULL);
  104f3c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104f43:	e8 82 dc ff ff       	call   102bca <alloc_pages>
  104f48:	85 c0                	test   %eax,%eax
  104f4a:	74 24                	je     104f70 <default_check+0x260>
  104f4c:	c7 44 24 0c 14 6e 10 	movl   $0x106e14,0xc(%esp)
  104f53:	00 
  104f54:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104f5b:	00 
  104f5c:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
  104f63:	00 
  104f64:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104f6b:	e8 79 b4 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104f70:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f73:	83 c0 28             	add    $0x28,%eax
  104f76:	83 c0 04             	add    $0x4,%eax
  104f79:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104f80:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104f83:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104f86:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104f89:	0f a3 10             	bt     %edx,(%eax)
  104f8c:	19 c0                	sbb    %eax,%eax
  104f8e:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  104f91:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  104f95:	0f 95 c0             	setne  %al
  104f98:	0f b6 c0             	movzbl %al,%eax
  104f9b:	85 c0                	test   %eax,%eax
  104f9d:	74 0e                	je     104fad <default_check+0x29d>
  104f9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104fa2:	83 c0 28             	add    $0x28,%eax
  104fa5:	8b 40 08             	mov    0x8(%eax),%eax
  104fa8:	83 f8 03             	cmp    $0x3,%eax
  104fab:	74 24                	je     104fd1 <default_check+0x2c1>
  104fad:	c7 44 24 0c 2c 6e 10 	movl   $0x106e2c,0xc(%esp)
  104fb4:	00 
  104fb5:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104fbc:	00 
  104fbd:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
  104fc4:	00 
  104fc5:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104fcc:	e8 18 b4 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104fd1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104fd8:	e8 ed db ff ff       	call   102bca <alloc_pages>
  104fdd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  104fe0:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  104fe4:	75 24                	jne    10500a <default_check+0x2fa>
  104fe6:	c7 44 24 0c 58 6e 10 	movl   $0x106e58,0xc(%esp)
  104fed:	00 
  104fee:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104ff5:	00 
  104ff6:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
  104ffd:	00 
  104ffe:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105005:	e8 df b3 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  10500a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105011:	e8 b4 db ff ff       	call   102bca <alloc_pages>
  105016:	85 c0                	test   %eax,%eax
  105018:	74 24                	je     10503e <default_check+0x32e>
  10501a:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  105021:	00 
  105022:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105029:	00 
  10502a:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
  105031:	00 
  105032:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105039:	e8 ab b3 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  10503e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105041:	83 c0 28             	add    $0x28,%eax
  105044:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  105047:	74 24                	je     10506d <default_check+0x35d>
  105049:	c7 44 24 0c 76 6e 10 	movl   $0x106e76,0xc(%esp)
  105050:	00 
  105051:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105058:	00 
  105059:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  105060:	00 
  105061:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105068:	e8 7c b3 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  10506d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105070:	83 c0 14             	add    $0x14,%eax
  105073:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
  105076:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10507d:	00 
  10507e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105081:	89 04 24             	mov    %eax,(%esp)
  105084:	e8 79 db ff ff       	call   102c02 <free_pages>
    free_pages(p1, 3);
  105089:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105090:	00 
  105091:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105094:	89 04 24             	mov    %eax,(%esp)
  105097:	e8 66 db ff ff       	call   102c02 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10509c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10509f:	83 c0 04             	add    $0x4,%eax
  1050a2:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  1050a9:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1050ac:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1050af:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1050b2:	0f a3 10             	bt     %edx,(%eax)
  1050b5:	19 c0                	sbb    %eax,%eax
  1050b7:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  1050ba:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  1050be:	0f 95 c0             	setne  %al
  1050c1:	0f b6 c0             	movzbl %al,%eax
  1050c4:	85 c0                	test   %eax,%eax
  1050c6:	74 0b                	je     1050d3 <default_check+0x3c3>
  1050c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1050cb:	8b 40 08             	mov    0x8(%eax),%eax
  1050ce:	83 f8 01             	cmp    $0x1,%eax
  1050d1:	74 24                	je     1050f7 <default_check+0x3e7>
  1050d3:	c7 44 24 0c 84 6e 10 	movl   $0x106e84,0xc(%esp)
  1050da:	00 
  1050db:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1050e2:	00 
  1050e3:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
  1050ea:	00 
  1050eb:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1050f2:	e8 f2 b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1050f7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1050fa:	83 c0 04             	add    $0x4,%eax
  1050fd:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  105104:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105107:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10510a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10510d:	0f a3 10             	bt     %edx,(%eax)
  105110:	19 c0                	sbb    %eax,%eax
  105112:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
  105115:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
  105119:	0f 95 c0             	setne  %al
  10511c:	0f b6 c0             	movzbl %al,%eax
  10511f:	85 c0                	test   %eax,%eax
  105121:	74 0b                	je     10512e <default_check+0x41e>
  105123:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105126:	8b 40 08             	mov    0x8(%eax),%eax
  105129:	83 f8 03             	cmp    $0x3,%eax
  10512c:	74 24                	je     105152 <default_check+0x442>
  10512e:	c7 44 24 0c ac 6e 10 	movl   $0x106eac,0xc(%esp)
  105135:	00 
  105136:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10513d:	00 
  10513e:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
  105145:	00 
  105146:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10514d:	e8 97 b2 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  105152:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105159:	e8 6c da ff ff       	call   102bca <alloc_pages>
  10515e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105161:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105164:	83 e8 14             	sub    $0x14,%eax
  105167:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10516a:	74 24                	je     105190 <default_check+0x480>
  10516c:	c7 44 24 0c d2 6e 10 	movl   $0x106ed2,0xc(%esp)
  105173:	00 
  105174:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10517b:	00 
  10517c:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
  105183:	00 
  105184:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10518b:	e8 59 b2 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  105190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105197:	00 
  105198:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10519b:	89 04 24             	mov    %eax,(%esp)
  10519e:	e8 5f da ff ff       	call   102c02 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1051a3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1051aa:	e8 1b da ff ff       	call   102bca <alloc_pages>
  1051af:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1051b2:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1051b5:	83 c0 14             	add    $0x14,%eax
  1051b8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1051bb:	74 24                	je     1051e1 <default_check+0x4d1>
  1051bd:	c7 44 24 0c f0 6e 10 	movl   $0x106ef0,0xc(%esp)
  1051c4:	00 
  1051c5:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1051cc:	00 
  1051cd:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
  1051d4:	00 
  1051d5:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1051dc:	e8 08 b2 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  1051e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1051e8:	00 
  1051e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051ec:	89 04 24             	mov    %eax,(%esp)
  1051ef:	e8 0e da ff ff       	call   102c02 <free_pages>
    free_page(p2);
  1051f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051fb:	00 
  1051fc:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1051ff:	89 04 24             	mov    %eax,(%esp)
  105202:	e8 fb d9 ff ff       	call   102c02 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105207:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10520e:	e8 b7 d9 ff ff       	call   102bca <alloc_pages>
  105213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105216:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10521a:	75 24                	jne    105240 <default_check+0x530>
  10521c:	c7 44 24 0c 10 6f 10 	movl   $0x106f10,0xc(%esp)
  105223:	00 
  105224:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10522b:	00 
  10522c:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
  105233:	00 
  105234:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10523b:	e8 a9 b1 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105240:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105247:	e8 7e d9 ff ff       	call   102bca <alloc_pages>
  10524c:	85 c0                	test   %eax,%eax
  10524e:	74 24                	je     105274 <default_check+0x564>
  105250:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  105257:	00 
  105258:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10525f:	00 
  105260:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
  105267:	00 
  105268:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10526f:	e8 75 b1 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  105274:	a1 24 af 11 00       	mov    0x11af24,%eax
  105279:	85 c0                	test   %eax,%eax
  10527b:	74 24                	je     1052a1 <default_check+0x591>
  10527d:	c7 44 24 0c c1 6d 10 	movl   $0x106dc1,0xc(%esp)
  105284:	00 
  105285:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10528c:	00 
  10528d:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
  105294:	00 
  105295:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10529c:	e8 48 b1 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  1052a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1052a4:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  1052a9:	8b 45 80             	mov    -0x80(%ebp),%eax
  1052ac:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1052af:	a3 1c af 11 00       	mov    %eax,0x11af1c
  1052b4:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  1052ba:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1052c1:	00 
  1052c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052c5:	89 04 24             	mov    %eax,(%esp)
  1052c8:	e8 35 d9 ff ff       	call   102c02 <free_pages>

    le = &free_list;
  1052cd:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1052d4:	eb 1c                	jmp    1052f2 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
  1052d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052d9:	83 e8 0c             	sub    $0xc,%eax
  1052dc:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
  1052df:	ff 4d f4             	decl   -0xc(%ebp)
  1052e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1052e5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1052e8:	8b 40 08             	mov    0x8(%eax),%eax
  1052eb:	29 c2                	sub    %eax,%edx
  1052ed:	89 d0                	mov    %edx,%eax
  1052ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1052f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052f5:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1052f8:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1052fb:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1052fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105301:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  105308:	75 cc                	jne    1052d6 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  10530a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10530e:	74 24                	je     105334 <default_check+0x624>
  105310:	c7 44 24 0c 2e 6f 10 	movl   $0x106f2e,0xc(%esp)
  105317:	00 
  105318:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10531f:	00 
  105320:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
  105327:	00 
  105328:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10532f:	e8 b5 b0 ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  105334:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105338:	74 24                	je     10535e <default_check+0x64e>
  10533a:	c7 44 24 0c 39 6f 10 	movl   $0x106f39,0xc(%esp)
  105341:	00 
  105342:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105349:	00 
  10534a:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
  105351:	00 
  105352:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105359:	e8 8b b0 ff ff       	call   1003e9 <__panic>
}
  10535e:	90                   	nop
  10535f:	c9                   	leave  
  105360:	c3                   	ret    

00105361 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105361:	55                   	push   %ebp
  105362:	89 e5                	mov    %esp,%ebp
  105364:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105367:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  10536e:	eb 03                	jmp    105373 <strlen+0x12>
        cnt ++;
  105370:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105373:	8b 45 08             	mov    0x8(%ebp),%eax
  105376:	8d 50 01             	lea    0x1(%eax),%edx
  105379:	89 55 08             	mov    %edx,0x8(%ebp)
  10537c:	0f b6 00             	movzbl (%eax),%eax
  10537f:	84 c0                	test   %al,%al
  105381:	75 ed                	jne    105370 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105386:	c9                   	leave  
  105387:	c3                   	ret    

00105388 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105388:	55                   	push   %ebp
  105389:	89 e5                	mov    %esp,%ebp
  10538b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10538e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105395:	eb 03                	jmp    10539a <strnlen+0x12>
        cnt ++;
  105397:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  10539a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10539d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053a0:	73 10                	jae    1053b2 <strnlen+0x2a>
  1053a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1053a5:	8d 50 01             	lea    0x1(%eax),%edx
  1053a8:	89 55 08             	mov    %edx,0x8(%ebp)
  1053ab:	0f b6 00             	movzbl (%eax),%eax
  1053ae:	84 c0                	test   %al,%al
  1053b0:	75 e5                	jne    105397 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  1053b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1053b5:	c9                   	leave  
  1053b6:	c3                   	ret    

001053b7 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1053b7:	55                   	push   %ebp
  1053b8:	89 e5                	mov    %esp,%ebp
  1053ba:	57                   	push   %edi
  1053bb:	56                   	push   %esi
  1053bc:	83 ec 20             	sub    $0x20,%esp
  1053bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1053c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1053c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1053cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053d1:	89 d1                	mov    %edx,%ecx
  1053d3:	89 c2                	mov    %eax,%edx
  1053d5:	89 ce                	mov    %ecx,%esi
  1053d7:	89 d7                	mov    %edx,%edi
  1053d9:	ac                   	lods   %ds:(%esi),%al
  1053da:	aa                   	stos   %al,%es:(%edi)
  1053db:	84 c0                	test   %al,%al
  1053dd:	75 fa                	jne    1053d9 <strcpy+0x22>
  1053df:	89 fa                	mov    %edi,%edx
  1053e1:	89 f1                	mov    %esi,%ecx
  1053e3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1053e6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1053e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1053ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1053ef:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1053f0:	83 c4 20             	add    $0x20,%esp
  1053f3:	5e                   	pop    %esi
  1053f4:	5f                   	pop    %edi
  1053f5:	5d                   	pop    %ebp
  1053f6:	c3                   	ret    

001053f7 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1053f7:	55                   	push   %ebp
  1053f8:	89 e5                	mov    %esp,%ebp
  1053fa:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1053fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105400:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105403:	eb 1e                	jmp    105423 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105405:	8b 45 0c             	mov    0xc(%ebp),%eax
  105408:	0f b6 10             	movzbl (%eax),%edx
  10540b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10540e:	88 10                	mov    %dl,(%eax)
  105410:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105413:	0f b6 00             	movzbl (%eax),%eax
  105416:	84 c0                	test   %al,%al
  105418:	74 03                	je     10541d <strncpy+0x26>
            src ++;
  10541a:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10541d:	ff 45 fc             	incl   -0x4(%ebp)
  105420:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105423:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105427:	75 dc                	jne    105405 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105429:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10542c:	c9                   	leave  
  10542d:	c3                   	ret    

0010542e <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10542e:	55                   	push   %ebp
  10542f:	89 e5                	mov    %esp,%ebp
  105431:	57                   	push   %edi
  105432:	56                   	push   %esi
  105433:	83 ec 20             	sub    $0x20,%esp
  105436:	8b 45 08             	mov    0x8(%ebp),%eax
  105439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10543c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10543f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105442:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105448:	89 d1                	mov    %edx,%ecx
  10544a:	89 c2                	mov    %eax,%edx
  10544c:	89 ce                	mov    %ecx,%esi
  10544e:	89 d7                	mov    %edx,%edi
  105450:	ac                   	lods   %ds:(%esi),%al
  105451:	ae                   	scas   %es:(%edi),%al
  105452:	75 08                	jne    10545c <strcmp+0x2e>
  105454:	84 c0                	test   %al,%al
  105456:	75 f8                	jne    105450 <strcmp+0x22>
  105458:	31 c0                	xor    %eax,%eax
  10545a:	eb 04                	jmp    105460 <strcmp+0x32>
  10545c:	19 c0                	sbb    %eax,%eax
  10545e:	0c 01                	or     $0x1,%al
  105460:	89 fa                	mov    %edi,%edx
  105462:	89 f1                	mov    %esi,%ecx
  105464:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105467:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10546a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  10546d:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  105470:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105471:	83 c4 20             	add    $0x20,%esp
  105474:	5e                   	pop    %esi
  105475:	5f                   	pop    %edi
  105476:	5d                   	pop    %ebp
  105477:	c3                   	ret    

00105478 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105478:	55                   	push   %ebp
  105479:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10547b:	eb 09                	jmp    105486 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  10547d:	ff 4d 10             	decl   0x10(%ebp)
  105480:	ff 45 08             	incl   0x8(%ebp)
  105483:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10548a:	74 1a                	je     1054a6 <strncmp+0x2e>
  10548c:	8b 45 08             	mov    0x8(%ebp),%eax
  10548f:	0f b6 00             	movzbl (%eax),%eax
  105492:	84 c0                	test   %al,%al
  105494:	74 10                	je     1054a6 <strncmp+0x2e>
  105496:	8b 45 08             	mov    0x8(%ebp),%eax
  105499:	0f b6 10             	movzbl (%eax),%edx
  10549c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10549f:	0f b6 00             	movzbl (%eax),%eax
  1054a2:	38 c2                	cmp    %al,%dl
  1054a4:	74 d7                	je     10547d <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1054a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054aa:	74 18                	je     1054c4 <strncmp+0x4c>
  1054ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1054af:	0f b6 00             	movzbl (%eax),%eax
  1054b2:	0f b6 d0             	movzbl %al,%edx
  1054b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054b8:	0f b6 00             	movzbl (%eax),%eax
  1054bb:	0f b6 c0             	movzbl %al,%eax
  1054be:	29 c2                	sub    %eax,%edx
  1054c0:	89 d0                	mov    %edx,%eax
  1054c2:	eb 05                	jmp    1054c9 <strncmp+0x51>
  1054c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1054c9:	5d                   	pop    %ebp
  1054ca:	c3                   	ret    

001054cb <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1054cb:	55                   	push   %ebp
  1054cc:	89 e5                	mov    %esp,%ebp
  1054ce:	83 ec 04             	sub    $0x4,%esp
  1054d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054d4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1054d7:	eb 13                	jmp    1054ec <strchr+0x21>
        if (*s == c) {
  1054d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054dc:	0f b6 00             	movzbl (%eax),%eax
  1054df:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1054e2:	75 05                	jne    1054e9 <strchr+0x1e>
            return (char *)s;
  1054e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1054e7:	eb 12                	jmp    1054fb <strchr+0x30>
        }
        s ++;
  1054e9:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  1054ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ef:	0f b6 00             	movzbl (%eax),%eax
  1054f2:	84 c0                	test   %al,%al
  1054f4:	75 e3                	jne    1054d9 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  1054f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1054fb:	c9                   	leave  
  1054fc:	c3                   	ret    

001054fd <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1054fd:	55                   	push   %ebp
  1054fe:	89 e5                	mov    %esp,%ebp
  105500:	83 ec 04             	sub    $0x4,%esp
  105503:	8b 45 0c             	mov    0xc(%ebp),%eax
  105506:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105509:	eb 0e                	jmp    105519 <strfind+0x1c>
        if (*s == c) {
  10550b:	8b 45 08             	mov    0x8(%ebp),%eax
  10550e:	0f b6 00             	movzbl (%eax),%eax
  105511:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105514:	74 0f                	je     105525 <strfind+0x28>
            break;
        }
        s ++;
  105516:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105519:	8b 45 08             	mov    0x8(%ebp),%eax
  10551c:	0f b6 00             	movzbl (%eax),%eax
  10551f:	84 c0                	test   %al,%al
  105521:	75 e8                	jne    10550b <strfind+0xe>
  105523:	eb 01                	jmp    105526 <strfind+0x29>
        if (*s == c) {
            break;
  105525:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  105526:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105529:	c9                   	leave  
  10552a:	c3                   	ret    

0010552b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10552b:	55                   	push   %ebp
  10552c:	89 e5                	mov    %esp,%ebp
  10552e:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105531:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105538:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10553f:	eb 03                	jmp    105544 <strtol+0x19>
        s ++;
  105541:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105544:	8b 45 08             	mov    0x8(%ebp),%eax
  105547:	0f b6 00             	movzbl (%eax),%eax
  10554a:	3c 20                	cmp    $0x20,%al
  10554c:	74 f3                	je     105541 <strtol+0x16>
  10554e:	8b 45 08             	mov    0x8(%ebp),%eax
  105551:	0f b6 00             	movzbl (%eax),%eax
  105554:	3c 09                	cmp    $0x9,%al
  105556:	74 e9                	je     105541 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105558:	8b 45 08             	mov    0x8(%ebp),%eax
  10555b:	0f b6 00             	movzbl (%eax),%eax
  10555e:	3c 2b                	cmp    $0x2b,%al
  105560:	75 05                	jne    105567 <strtol+0x3c>
        s ++;
  105562:	ff 45 08             	incl   0x8(%ebp)
  105565:	eb 14                	jmp    10557b <strtol+0x50>
    }
    else if (*s == '-') {
  105567:	8b 45 08             	mov    0x8(%ebp),%eax
  10556a:	0f b6 00             	movzbl (%eax),%eax
  10556d:	3c 2d                	cmp    $0x2d,%al
  10556f:	75 0a                	jne    10557b <strtol+0x50>
        s ++, neg = 1;
  105571:	ff 45 08             	incl   0x8(%ebp)
  105574:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  10557b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10557f:	74 06                	je     105587 <strtol+0x5c>
  105581:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105585:	75 22                	jne    1055a9 <strtol+0x7e>
  105587:	8b 45 08             	mov    0x8(%ebp),%eax
  10558a:	0f b6 00             	movzbl (%eax),%eax
  10558d:	3c 30                	cmp    $0x30,%al
  10558f:	75 18                	jne    1055a9 <strtol+0x7e>
  105591:	8b 45 08             	mov    0x8(%ebp),%eax
  105594:	40                   	inc    %eax
  105595:	0f b6 00             	movzbl (%eax),%eax
  105598:	3c 78                	cmp    $0x78,%al
  10559a:	75 0d                	jne    1055a9 <strtol+0x7e>
        s += 2, base = 16;
  10559c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1055a0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1055a7:	eb 29                	jmp    1055d2 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1055a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055ad:	75 16                	jne    1055c5 <strtol+0x9a>
  1055af:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b2:	0f b6 00             	movzbl (%eax),%eax
  1055b5:	3c 30                	cmp    $0x30,%al
  1055b7:	75 0c                	jne    1055c5 <strtol+0x9a>
        s ++, base = 8;
  1055b9:	ff 45 08             	incl   0x8(%ebp)
  1055bc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1055c3:	eb 0d                	jmp    1055d2 <strtol+0xa7>
    }
    else if (base == 0) {
  1055c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055c9:	75 07                	jne    1055d2 <strtol+0xa7>
        base = 10;
  1055cb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1055d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d5:	0f b6 00             	movzbl (%eax),%eax
  1055d8:	3c 2f                	cmp    $0x2f,%al
  1055da:	7e 1b                	jle    1055f7 <strtol+0xcc>
  1055dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1055df:	0f b6 00             	movzbl (%eax),%eax
  1055e2:	3c 39                	cmp    $0x39,%al
  1055e4:	7f 11                	jg     1055f7 <strtol+0xcc>
            dig = *s - '0';
  1055e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e9:	0f b6 00             	movzbl (%eax),%eax
  1055ec:	0f be c0             	movsbl %al,%eax
  1055ef:	83 e8 30             	sub    $0x30,%eax
  1055f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1055f5:	eb 48                	jmp    10563f <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1055f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055fa:	0f b6 00             	movzbl (%eax),%eax
  1055fd:	3c 60                	cmp    $0x60,%al
  1055ff:	7e 1b                	jle    10561c <strtol+0xf1>
  105601:	8b 45 08             	mov    0x8(%ebp),%eax
  105604:	0f b6 00             	movzbl (%eax),%eax
  105607:	3c 7a                	cmp    $0x7a,%al
  105609:	7f 11                	jg     10561c <strtol+0xf1>
            dig = *s - 'a' + 10;
  10560b:	8b 45 08             	mov    0x8(%ebp),%eax
  10560e:	0f b6 00             	movzbl (%eax),%eax
  105611:	0f be c0             	movsbl %al,%eax
  105614:	83 e8 57             	sub    $0x57,%eax
  105617:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10561a:	eb 23                	jmp    10563f <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10561c:	8b 45 08             	mov    0x8(%ebp),%eax
  10561f:	0f b6 00             	movzbl (%eax),%eax
  105622:	3c 40                	cmp    $0x40,%al
  105624:	7e 3b                	jle    105661 <strtol+0x136>
  105626:	8b 45 08             	mov    0x8(%ebp),%eax
  105629:	0f b6 00             	movzbl (%eax),%eax
  10562c:	3c 5a                	cmp    $0x5a,%al
  10562e:	7f 31                	jg     105661 <strtol+0x136>
            dig = *s - 'A' + 10;
  105630:	8b 45 08             	mov    0x8(%ebp),%eax
  105633:	0f b6 00             	movzbl (%eax),%eax
  105636:	0f be c0             	movsbl %al,%eax
  105639:	83 e8 37             	sub    $0x37,%eax
  10563c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105642:	3b 45 10             	cmp    0x10(%ebp),%eax
  105645:	7d 19                	jge    105660 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105647:	ff 45 08             	incl   0x8(%ebp)
  10564a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10564d:	0f af 45 10          	imul   0x10(%ebp),%eax
  105651:	89 c2                	mov    %eax,%edx
  105653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105656:	01 d0                	add    %edx,%eax
  105658:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  10565b:	e9 72 ff ff ff       	jmp    1055d2 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  105660:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  105661:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105665:	74 08                	je     10566f <strtol+0x144>
        *endptr = (char *) s;
  105667:	8b 45 0c             	mov    0xc(%ebp),%eax
  10566a:	8b 55 08             	mov    0x8(%ebp),%edx
  10566d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10566f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105673:	74 07                	je     10567c <strtol+0x151>
  105675:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105678:	f7 d8                	neg    %eax
  10567a:	eb 03                	jmp    10567f <strtol+0x154>
  10567c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10567f:	c9                   	leave  
  105680:	c3                   	ret    

00105681 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105681:	55                   	push   %ebp
  105682:	89 e5                	mov    %esp,%ebp
  105684:	57                   	push   %edi
  105685:	83 ec 24             	sub    $0x24,%esp
  105688:	8b 45 0c             	mov    0xc(%ebp),%eax
  10568b:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10568e:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105692:	8b 55 08             	mov    0x8(%ebp),%edx
  105695:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105698:	88 45 f7             	mov    %al,-0x9(%ebp)
  10569b:	8b 45 10             	mov    0x10(%ebp),%eax
  10569e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1056a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1056a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1056a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1056ab:	89 d7                	mov    %edx,%edi
  1056ad:	f3 aa                	rep stos %al,%es:(%edi)
  1056af:	89 fa                	mov    %edi,%edx
  1056b1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1056b4:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1056b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056ba:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1056bb:	83 c4 24             	add    $0x24,%esp
  1056be:	5f                   	pop    %edi
  1056bf:	5d                   	pop    %ebp
  1056c0:	c3                   	ret    

001056c1 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1056c1:	55                   	push   %ebp
  1056c2:	89 e5                	mov    %esp,%ebp
  1056c4:	57                   	push   %edi
  1056c5:	56                   	push   %esi
  1056c6:	53                   	push   %ebx
  1056c7:	83 ec 30             	sub    $0x30,%esp
  1056ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056d6:	8b 45 10             	mov    0x10(%ebp),%eax
  1056d9:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1056dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1056e2:	73 42                	jae    105726 <memmove+0x65>
  1056e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1056f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1056f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056f9:	c1 e8 02             	shr    $0x2,%eax
  1056fc:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1056fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105701:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105704:	89 d7                	mov    %edx,%edi
  105706:	89 c6                	mov    %eax,%esi
  105708:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10570a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10570d:	83 e1 03             	and    $0x3,%ecx
  105710:	74 02                	je     105714 <memmove+0x53>
  105712:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105714:	89 f0                	mov    %esi,%eax
  105716:	89 fa                	mov    %edi,%edx
  105718:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10571b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10571e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  105724:	eb 36                	jmp    10575c <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105726:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105729:	8d 50 ff             	lea    -0x1(%eax),%edx
  10572c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10572f:	01 c2                	add    %eax,%edx
  105731:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105734:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10573a:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  10573d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105740:	89 c1                	mov    %eax,%ecx
  105742:	89 d8                	mov    %ebx,%eax
  105744:	89 d6                	mov    %edx,%esi
  105746:	89 c7                	mov    %eax,%edi
  105748:	fd                   	std    
  105749:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10574b:	fc                   	cld    
  10574c:	89 f8                	mov    %edi,%eax
  10574e:	89 f2                	mov    %esi,%edx
  105750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105753:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105756:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105759:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10575c:	83 c4 30             	add    $0x30,%esp
  10575f:	5b                   	pop    %ebx
  105760:	5e                   	pop    %esi
  105761:	5f                   	pop    %edi
  105762:	5d                   	pop    %ebp
  105763:	c3                   	ret    

00105764 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105764:	55                   	push   %ebp
  105765:	89 e5                	mov    %esp,%ebp
  105767:	57                   	push   %edi
  105768:	56                   	push   %esi
  105769:	83 ec 20             	sub    $0x20,%esp
  10576c:	8b 45 08             	mov    0x8(%ebp),%eax
  10576f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105772:	8b 45 0c             	mov    0xc(%ebp),%eax
  105775:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105778:	8b 45 10             	mov    0x10(%ebp),%eax
  10577b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10577e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105781:	c1 e8 02             	shr    $0x2,%eax
  105784:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105786:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10578c:	89 d7                	mov    %edx,%edi
  10578e:	89 c6                	mov    %eax,%esi
  105790:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105792:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105795:	83 e1 03             	and    $0x3,%ecx
  105798:	74 02                	je     10579c <memcpy+0x38>
  10579a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10579c:	89 f0                	mov    %esi,%eax
  10579e:	89 fa                	mov    %edi,%edx
  1057a0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1057a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1057a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  1057a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1057ac:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1057ad:	83 c4 20             	add    $0x20,%esp
  1057b0:	5e                   	pop    %esi
  1057b1:	5f                   	pop    %edi
  1057b2:	5d                   	pop    %ebp
  1057b3:	c3                   	ret    

001057b4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1057b4:	55                   	push   %ebp
  1057b5:	89 e5                	mov    %esp,%ebp
  1057b7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1057ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1057bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1057c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1057c6:	eb 2e                	jmp    1057f6 <memcmp+0x42>
        if (*s1 != *s2) {
  1057c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1057cb:	0f b6 10             	movzbl (%eax),%edx
  1057ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057d1:	0f b6 00             	movzbl (%eax),%eax
  1057d4:	38 c2                	cmp    %al,%dl
  1057d6:	74 18                	je     1057f0 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1057d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1057db:	0f b6 00             	movzbl (%eax),%eax
  1057de:	0f b6 d0             	movzbl %al,%edx
  1057e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057e4:	0f b6 00             	movzbl (%eax),%eax
  1057e7:	0f b6 c0             	movzbl %al,%eax
  1057ea:	29 c2                	sub    %eax,%edx
  1057ec:	89 d0                	mov    %edx,%eax
  1057ee:	eb 18                	jmp    105808 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1057f0:	ff 45 fc             	incl   -0x4(%ebp)
  1057f3:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  1057f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1057f9:	8d 50 ff             	lea    -0x1(%eax),%edx
  1057fc:	89 55 10             	mov    %edx,0x10(%ebp)
  1057ff:	85 c0                	test   %eax,%eax
  105801:	75 c5                	jne    1057c8 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105803:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105808:	c9                   	leave  
  105809:	c3                   	ret    

0010580a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10580a:	55                   	push   %ebp
  10580b:	89 e5                	mov    %esp,%ebp
  10580d:	83 ec 58             	sub    $0x58,%esp
  105810:	8b 45 10             	mov    0x10(%ebp),%eax
  105813:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105816:	8b 45 14             	mov    0x14(%ebp),%eax
  105819:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10581c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10581f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105822:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105825:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105828:	8b 45 18             	mov    0x18(%ebp),%eax
  10582b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10582e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105831:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105834:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105837:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10583a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10583d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105844:	74 1c                	je     105862 <printnum+0x58>
  105846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105849:	ba 00 00 00 00       	mov    $0x0,%edx
  10584e:	f7 75 e4             	divl   -0x1c(%ebp)
  105851:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105857:	ba 00 00 00 00       	mov    $0x0,%edx
  10585c:	f7 75 e4             	divl   -0x1c(%ebp)
  10585f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105862:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105865:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105868:	f7 75 e4             	divl   -0x1c(%ebp)
  10586b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10586e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105871:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105874:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105877:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10587a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10587d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105880:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105883:	8b 45 18             	mov    0x18(%ebp),%eax
  105886:	ba 00 00 00 00       	mov    $0x0,%edx
  10588b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10588e:	77 56                	ja     1058e6 <printnum+0xdc>
  105890:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105893:	72 05                	jb     10589a <printnum+0x90>
  105895:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105898:	77 4c                	ja     1058e6 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  10589a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10589d:	8d 50 ff             	lea    -0x1(%eax),%edx
  1058a0:	8b 45 20             	mov    0x20(%ebp),%eax
  1058a3:	89 44 24 18          	mov    %eax,0x18(%esp)
  1058a7:	89 54 24 14          	mov    %edx,0x14(%esp)
  1058ab:	8b 45 18             	mov    0x18(%ebp),%eax
  1058ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  1058b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1058b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1058c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1058ca:	89 04 24             	mov    %eax,(%esp)
  1058cd:	e8 38 ff ff ff       	call   10580a <printnum>
  1058d2:	eb 1b                	jmp    1058ef <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1058d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058db:	8b 45 20             	mov    0x20(%ebp),%eax
  1058de:	89 04 24             	mov    %eax,(%esp)
  1058e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1058e4:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  1058e6:	ff 4d 1c             	decl   0x1c(%ebp)
  1058e9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1058ed:	7f e5                	jg     1058d4 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1058ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1058f2:	05 f4 6f 10 00       	add    $0x106ff4,%eax
  1058f7:	0f b6 00             	movzbl (%eax),%eax
  1058fa:	0f be c0             	movsbl %al,%eax
  1058fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  105900:	89 54 24 04          	mov    %edx,0x4(%esp)
  105904:	89 04 24             	mov    %eax,(%esp)
  105907:	8b 45 08             	mov    0x8(%ebp),%eax
  10590a:	ff d0                	call   *%eax
}
  10590c:	90                   	nop
  10590d:	c9                   	leave  
  10590e:	c3                   	ret    

0010590f <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  10590f:	55                   	push   %ebp
  105910:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105912:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105916:	7e 14                	jle    10592c <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105918:	8b 45 08             	mov    0x8(%ebp),%eax
  10591b:	8b 00                	mov    (%eax),%eax
  10591d:	8d 48 08             	lea    0x8(%eax),%ecx
  105920:	8b 55 08             	mov    0x8(%ebp),%edx
  105923:	89 0a                	mov    %ecx,(%edx)
  105925:	8b 50 04             	mov    0x4(%eax),%edx
  105928:	8b 00                	mov    (%eax),%eax
  10592a:	eb 30                	jmp    10595c <getuint+0x4d>
    }
    else if (lflag) {
  10592c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105930:	74 16                	je     105948 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105932:	8b 45 08             	mov    0x8(%ebp),%eax
  105935:	8b 00                	mov    (%eax),%eax
  105937:	8d 48 04             	lea    0x4(%eax),%ecx
  10593a:	8b 55 08             	mov    0x8(%ebp),%edx
  10593d:	89 0a                	mov    %ecx,(%edx)
  10593f:	8b 00                	mov    (%eax),%eax
  105941:	ba 00 00 00 00       	mov    $0x0,%edx
  105946:	eb 14                	jmp    10595c <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105948:	8b 45 08             	mov    0x8(%ebp),%eax
  10594b:	8b 00                	mov    (%eax),%eax
  10594d:	8d 48 04             	lea    0x4(%eax),%ecx
  105950:	8b 55 08             	mov    0x8(%ebp),%edx
  105953:	89 0a                	mov    %ecx,(%edx)
  105955:	8b 00                	mov    (%eax),%eax
  105957:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10595c:	5d                   	pop    %ebp
  10595d:	c3                   	ret    

0010595e <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10595e:	55                   	push   %ebp
  10595f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105961:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105965:	7e 14                	jle    10597b <getint+0x1d>
        return va_arg(*ap, long long);
  105967:	8b 45 08             	mov    0x8(%ebp),%eax
  10596a:	8b 00                	mov    (%eax),%eax
  10596c:	8d 48 08             	lea    0x8(%eax),%ecx
  10596f:	8b 55 08             	mov    0x8(%ebp),%edx
  105972:	89 0a                	mov    %ecx,(%edx)
  105974:	8b 50 04             	mov    0x4(%eax),%edx
  105977:	8b 00                	mov    (%eax),%eax
  105979:	eb 28                	jmp    1059a3 <getint+0x45>
    }
    else if (lflag) {
  10597b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10597f:	74 12                	je     105993 <getint+0x35>
        return va_arg(*ap, long);
  105981:	8b 45 08             	mov    0x8(%ebp),%eax
  105984:	8b 00                	mov    (%eax),%eax
  105986:	8d 48 04             	lea    0x4(%eax),%ecx
  105989:	8b 55 08             	mov    0x8(%ebp),%edx
  10598c:	89 0a                	mov    %ecx,(%edx)
  10598e:	8b 00                	mov    (%eax),%eax
  105990:	99                   	cltd   
  105991:	eb 10                	jmp    1059a3 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105993:	8b 45 08             	mov    0x8(%ebp),%eax
  105996:	8b 00                	mov    (%eax),%eax
  105998:	8d 48 04             	lea    0x4(%eax),%ecx
  10599b:	8b 55 08             	mov    0x8(%ebp),%edx
  10599e:	89 0a                	mov    %ecx,(%edx)
  1059a0:	8b 00                	mov    (%eax),%eax
  1059a2:	99                   	cltd   
    }
}
  1059a3:	5d                   	pop    %ebp
  1059a4:	c3                   	ret    

001059a5 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1059a5:	55                   	push   %ebp
  1059a6:	89 e5                	mov    %esp,%ebp
  1059a8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1059ab:	8d 45 14             	lea    0x14(%ebp),%eax
  1059ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1059b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1059bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1059c9:	89 04 24             	mov    %eax,(%esp)
  1059cc:	e8 03 00 00 00       	call   1059d4 <vprintfmt>
    va_end(ap);
}
  1059d1:	90                   	nop
  1059d2:	c9                   	leave  
  1059d3:	c3                   	ret    

001059d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1059d4:	55                   	push   %ebp
  1059d5:	89 e5                	mov    %esp,%ebp
  1059d7:	56                   	push   %esi
  1059d8:	53                   	push   %ebx
  1059d9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059dc:	eb 17                	jmp    1059f5 <vprintfmt+0x21>
            if (ch == '\0') {
  1059de:	85 db                	test   %ebx,%ebx
  1059e0:	0f 84 bf 03 00 00    	je     105da5 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1059e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059ed:	89 1c 24             	mov    %ebx,(%esp)
  1059f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1059f3:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1059f8:	8d 50 01             	lea    0x1(%eax),%edx
  1059fb:	89 55 10             	mov    %edx,0x10(%ebp)
  1059fe:	0f b6 00             	movzbl (%eax),%eax
  105a01:	0f b6 d8             	movzbl %al,%ebx
  105a04:	83 fb 25             	cmp    $0x25,%ebx
  105a07:	75 d5                	jne    1059de <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105a09:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105a0d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105a14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a17:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105a1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105a21:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105a24:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105a27:	8b 45 10             	mov    0x10(%ebp),%eax
  105a2a:	8d 50 01             	lea    0x1(%eax),%edx
  105a2d:	89 55 10             	mov    %edx,0x10(%ebp)
  105a30:	0f b6 00             	movzbl (%eax),%eax
  105a33:	0f b6 d8             	movzbl %al,%ebx
  105a36:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105a39:	83 f8 55             	cmp    $0x55,%eax
  105a3c:	0f 87 37 03 00 00    	ja     105d79 <vprintfmt+0x3a5>
  105a42:	8b 04 85 18 70 10 00 	mov    0x107018(,%eax,4),%eax
  105a49:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105a4b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105a4f:	eb d6                	jmp    105a27 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105a51:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105a55:	eb d0                	jmp    105a27 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105a57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105a5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105a61:	89 d0                	mov    %edx,%eax
  105a63:	c1 e0 02             	shl    $0x2,%eax
  105a66:	01 d0                	add    %edx,%eax
  105a68:	01 c0                	add    %eax,%eax
  105a6a:	01 d8                	add    %ebx,%eax
  105a6c:	83 e8 30             	sub    $0x30,%eax
  105a6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105a72:	8b 45 10             	mov    0x10(%ebp),%eax
  105a75:	0f b6 00             	movzbl (%eax),%eax
  105a78:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105a7b:	83 fb 2f             	cmp    $0x2f,%ebx
  105a7e:	7e 38                	jle    105ab8 <vprintfmt+0xe4>
  105a80:	83 fb 39             	cmp    $0x39,%ebx
  105a83:	7f 33                	jg     105ab8 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105a85:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  105a88:	eb d4                	jmp    105a5e <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  105a8d:	8d 50 04             	lea    0x4(%eax),%edx
  105a90:	89 55 14             	mov    %edx,0x14(%ebp)
  105a93:	8b 00                	mov    (%eax),%eax
  105a95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105a98:	eb 1f                	jmp    105ab9 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105a9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a9e:	79 87                	jns    105a27 <vprintfmt+0x53>
                width = 0;
  105aa0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105aa7:	e9 7b ff ff ff       	jmp    105a27 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105aac:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105ab3:	e9 6f ff ff ff       	jmp    105a27 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  105ab8:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  105ab9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105abd:	0f 89 64 ff ff ff    	jns    105a27 <vprintfmt+0x53>
                width = precision, precision = -1;
  105ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ac6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105ac9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105ad0:	e9 52 ff ff ff       	jmp    105a27 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105ad5:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105ad8:	e9 4a ff ff ff       	jmp    105a27 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105add:	8b 45 14             	mov    0x14(%ebp),%eax
  105ae0:	8d 50 04             	lea    0x4(%eax),%edx
  105ae3:	89 55 14             	mov    %edx,0x14(%ebp)
  105ae6:	8b 00                	mov    (%eax),%eax
  105ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
  105aeb:	89 54 24 04          	mov    %edx,0x4(%esp)
  105aef:	89 04 24             	mov    %eax,(%esp)
  105af2:	8b 45 08             	mov    0x8(%ebp),%eax
  105af5:	ff d0                	call   *%eax
            break;
  105af7:	e9 a4 02 00 00       	jmp    105da0 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105afc:	8b 45 14             	mov    0x14(%ebp),%eax
  105aff:	8d 50 04             	lea    0x4(%eax),%edx
  105b02:	89 55 14             	mov    %edx,0x14(%ebp)
  105b05:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105b07:	85 db                	test   %ebx,%ebx
  105b09:	79 02                	jns    105b0d <vprintfmt+0x139>
                err = -err;
  105b0b:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105b0d:	83 fb 06             	cmp    $0x6,%ebx
  105b10:	7f 0b                	jg     105b1d <vprintfmt+0x149>
  105b12:	8b 34 9d d8 6f 10 00 	mov    0x106fd8(,%ebx,4),%esi
  105b19:	85 f6                	test   %esi,%esi
  105b1b:	75 23                	jne    105b40 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105b1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105b21:	c7 44 24 08 05 70 10 	movl   $0x107005,0x8(%esp)
  105b28:	00 
  105b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b30:	8b 45 08             	mov    0x8(%ebp),%eax
  105b33:	89 04 24             	mov    %eax,(%esp)
  105b36:	e8 6a fe ff ff       	call   1059a5 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105b3b:	e9 60 02 00 00       	jmp    105da0 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105b40:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105b44:	c7 44 24 08 0e 70 10 	movl   $0x10700e,0x8(%esp)
  105b4b:	00 
  105b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b53:	8b 45 08             	mov    0x8(%ebp),%eax
  105b56:	89 04 24             	mov    %eax,(%esp)
  105b59:	e8 47 fe ff ff       	call   1059a5 <printfmt>
            }
            break;
  105b5e:	e9 3d 02 00 00       	jmp    105da0 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105b63:	8b 45 14             	mov    0x14(%ebp),%eax
  105b66:	8d 50 04             	lea    0x4(%eax),%edx
  105b69:	89 55 14             	mov    %edx,0x14(%ebp)
  105b6c:	8b 30                	mov    (%eax),%esi
  105b6e:	85 f6                	test   %esi,%esi
  105b70:	75 05                	jne    105b77 <vprintfmt+0x1a3>
                p = "(null)";
  105b72:	be 11 70 10 00       	mov    $0x107011,%esi
            }
            if (width > 0 && padc != '-') {
  105b77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b7b:	7e 76                	jle    105bf3 <vprintfmt+0x21f>
  105b7d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105b81:	74 70                	je     105bf3 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b8a:	89 34 24             	mov    %esi,(%esp)
  105b8d:	e8 f6 f7 ff ff       	call   105388 <strnlen>
  105b92:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105b95:	29 c2                	sub    %eax,%edx
  105b97:	89 d0                	mov    %edx,%eax
  105b99:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b9c:	eb 16                	jmp    105bb4 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105b9e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ba5:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ba9:	89 04 24             	mov    %eax,(%esp)
  105bac:	8b 45 08             	mov    0x8(%ebp),%eax
  105baf:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  105bb1:	ff 4d e8             	decl   -0x18(%ebp)
  105bb4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105bb8:	7f e4                	jg     105b9e <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105bba:	eb 37                	jmp    105bf3 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105bbc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105bc0:	74 1f                	je     105be1 <vprintfmt+0x20d>
  105bc2:	83 fb 1f             	cmp    $0x1f,%ebx
  105bc5:	7e 05                	jle    105bcc <vprintfmt+0x1f8>
  105bc7:	83 fb 7e             	cmp    $0x7e,%ebx
  105bca:	7e 15                	jle    105be1 <vprintfmt+0x20d>
                    putch('?', putdat);
  105bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105bda:	8b 45 08             	mov    0x8(%ebp),%eax
  105bdd:	ff d0                	call   *%eax
  105bdf:	eb 0f                	jmp    105bf0 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105be8:	89 1c 24             	mov    %ebx,(%esp)
  105beb:	8b 45 08             	mov    0x8(%ebp),%eax
  105bee:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105bf0:	ff 4d e8             	decl   -0x18(%ebp)
  105bf3:	89 f0                	mov    %esi,%eax
  105bf5:	8d 70 01             	lea    0x1(%eax),%esi
  105bf8:	0f b6 00             	movzbl (%eax),%eax
  105bfb:	0f be d8             	movsbl %al,%ebx
  105bfe:	85 db                	test   %ebx,%ebx
  105c00:	74 27                	je     105c29 <vprintfmt+0x255>
  105c02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105c06:	78 b4                	js     105bbc <vprintfmt+0x1e8>
  105c08:	ff 4d e4             	decl   -0x1c(%ebp)
  105c0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105c0f:	79 ab                	jns    105bbc <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105c11:	eb 16                	jmp    105c29 <vprintfmt+0x255>
                putch(' ', putdat);
  105c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c1a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105c21:	8b 45 08             	mov    0x8(%ebp),%eax
  105c24:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105c26:	ff 4d e8             	decl   -0x18(%ebp)
  105c29:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c2d:	7f e4                	jg     105c13 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  105c2f:	e9 6c 01 00 00       	jmp    105da0 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105c34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c3b:	8d 45 14             	lea    0x14(%ebp),%eax
  105c3e:	89 04 24             	mov    %eax,(%esp)
  105c41:	e8 18 fd ff ff       	call   10595e <getint>
  105c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c49:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c52:	85 d2                	test   %edx,%edx
  105c54:	79 26                	jns    105c7c <vprintfmt+0x2a8>
                putch('-', putdat);
  105c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c5d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105c64:	8b 45 08             	mov    0x8(%ebp),%eax
  105c67:	ff d0                	call   *%eax
                num = -(long long)num;
  105c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c6f:	f7 d8                	neg    %eax
  105c71:	83 d2 00             	adc    $0x0,%edx
  105c74:	f7 da                	neg    %edx
  105c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c79:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105c7c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105c83:	e9 a8 00 00 00       	jmp    105d30 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c8f:	8d 45 14             	lea    0x14(%ebp),%eax
  105c92:	89 04 24             	mov    %eax,(%esp)
  105c95:	e8 75 fc ff ff       	call   10590f <getuint>
  105c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c9d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105ca0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105ca7:	e9 84 00 00 00       	jmp    105d30 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cb3:	8d 45 14             	lea    0x14(%ebp),%eax
  105cb6:	89 04 24             	mov    %eax,(%esp)
  105cb9:	e8 51 fc ff ff       	call   10590f <getuint>
  105cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cc1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105cc4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105ccb:	eb 63                	jmp    105d30 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cd4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  105cde:	ff d0                	call   *%eax
            putch('x', putdat);
  105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ce7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105cee:	8b 45 08             	mov    0x8(%ebp),%eax
  105cf1:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105cf3:	8b 45 14             	mov    0x14(%ebp),%eax
  105cf6:	8d 50 04             	lea    0x4(%eax),%edx
  105cf9:	89 55 14             	mov    %edx,0x14(%ebp)
  105cfc:	8b 00                	mov    (%eax),%eax
  105cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105d08:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105d0f:	eb 1f                	jmp    105d30 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d14:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d18:	8d 45 14             	lea    0x14(%ebp),%eax
  105d1b:	89 04 24             	mov    %eax,(%esp)
  105d1e:	e8 ec fb ff ff       	call   10590f <getuint>
  105d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d26:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105d29:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105d30:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d37:	89 54 24 18          	mov    %edx,0x18(%esp)
  105d3b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105d3e:	89 54 24 14          	mov    %edx,0x14(%esp)
  105d42:	89 44 24 10          	mov    %eax,0x10(%esp)
  105d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5e:	89 04 24             	mov    %eax,(%esp)
  105d61:	e8 a4 fa ff ff       	call   10580a <printnum>
            break;
  105d66:	eb 38                	jmp    105da0 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d6f:	89 1c 24             	mov    %ebx,(%esp)
  105d72:	8b 45 08             	mov    0x8(%ebp),%eax
  105d75:	ff d0                	call   *%eax
            break;
  105d77:	eb 27                	jmp    105da0 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d80:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105d87:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8a:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105d8c:	ff 4d 10             	decl   0x10(%ebp)
  105d8f:	eb 03                	jmp    105d94 <vprintfmt+0x3c0>
  105d91:	ff 4d 10             	decl   0x10(%ebp)
  105d94:	8b 45 10             	mov    0x10(%ebp),%eax
  105d97:	48                   	dec    %eax
  105d98:	0f b6 00             	movzbl (%eax),%eax
  105d9b:	3c 25                	cmp    $0x25,%al
  105d9d:	75 f2                	jne    105d91 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105d9f:	90                   	nop
        }
    }
  105da0:	e9 37 fc ff ff       	jmp    1059dc <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  105da5:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105da6:	83 c4 40             	add    $0x40,%esp
  105da9:	5b                   	pop    %ebx
  105daa:	5e                   	pop    %esi
  105dab:	5d                   	pop    %ebp
  105dac:	c3                   	ret    

00105dad <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105dad:	55                   	push   %ebp
  105dae:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db3:	8b 40 08             	mov    0x8(%eax),%eax
  105db6:	8d 50 01             	lea    0x1(%eax),%edx
  105db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dbc:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc2:	8b 10                	mov    (%eax),%edx
  105dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc7:	8b 40 04             	mov    0x4(%eax),%eax
  105dca:	39 c2                	cmp    %eax,%edx
  105dcc:	73 12                	jae    105de0 <sprintputch+0x33>
        *b->buf ++ = ch;
  105dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dd1:	8b 00                	mov    (%eax),%eax
  105dd3:	8d 48 01             	lea    0x1(%eax),%ecx
  105dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dd9:	89 0a                	mov    %ecx,(%edx)
  105ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  105dde:	88 10                	mov    %dl,(%eax)
    }
}
  105de0:	90                   	nop
  105de1:	5d                   	pop    %ebp
  105de2:	c3                   	ret    

00105de3 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105de3:	55                   	push   %ebp
  105de4:	89 e5                	mov    %esp,%ebp
  105de6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105de9:	8d 45 14             	lea    0x14(%ebp),%eax
  105dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105df2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105df6:	8b 45 10             	mov    0x10(%ebp),%eax
  105df9:	89 44 24 08          	mov    %eax,0x8(%esp)
  105dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e04:	8b 45 08             	mov    0x8(%ebp),%eax
  105e07:	89 04 24             	mov    %eax,(%esp)
  105e0a:	e8 08 00 00 00       	call   105e17 <vsnprintf>
  105e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105e15:	c9                   	leave  
  105e16:	c3                   	ret    

00105e17 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105e17:	55                   	push   %ebp
  105e18:	89 e5                	mov    %esp,%ebp
  105e1a:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105e20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e26:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e29:	8b 45 08             	mov    0x8(%ebp),%eax
  105e2c:	01 d0                	add    %edx,%eax
  105e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105e38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105e3c:	74 0a                	je     105e48 <vsnprintf+0x31>
  105e3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e44:	39 c2                	cmp    %eax,%edx
  105e46:	76 07                	jbe    105e4f <vsnprintf+0x38>
        return -E_INVAL;
  105e48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105e4d:	eb 2a                	jmp    105e79 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105e4f:	8b 45 14             	mov    0x14(%ebp),%eax
  105e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105e56:	8b 45 10             	mov    0x10(%ebp),%eax
  105e59:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105e60:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e64:	c7 04 24 ad 5d 10 00 	movl   $0x105dad,(%esp)
  105e6b:	e8 64 fb ff ff       	call   1059d4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e73:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105e79:	c9                   	leave  
  105e7a:	c3                   	ret    
