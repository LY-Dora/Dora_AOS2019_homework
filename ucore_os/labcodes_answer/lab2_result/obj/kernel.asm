
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

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 a0 11 c0       	push   $0xc011a000
c0100055:	e8 78 52 00 00       	call   c01052d2 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 70 15 00 00       	call   c01015d2 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 80 5a 10 c0 	movl   $0xc0105a80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 9c 5a 10 c0       	push   $0xc0105a9c
c0100074:	e8 fa 01 00 00       	call   c0100273 <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 91 08 00 00       	call   c0100912 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 74 00 00 00       	call   c01000fa <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 59 30 00 00       	call   c01030e4 <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 b4 16 00 00       	call   c0101744 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 15 18 00 00       	call   c01018aa <idt_init>

    clock_init();               // init clock interrupt
c0100095:	e8 df 0c 00 00       	call   c0100d79 <clock_init>
    intr_enable();              // enable irq interrupt
c010009a:	e8 e2 17 00 00       	call   c0101881 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c010009f:	eb fe                	jmp    c010009f <kern_init+0x69>

c01000a1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a1:	55                   	push   %ebp
c01000a2:	89 e5                	mov    %esp,%ebp
c01000a4:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000a7:	83 ec 04             	sub    $0x4,%esp
c01000aa:	6a 00                	push   $0x0
c01000ac:	6a 00                	push   $0x0
c01000ae:	6a 00                	push   $0x0
c01000b0:	e8 b2 0c 00 00       	call   c0100d67 <mon_backtrace>
c01000b5:	83 c4 10             	add    $0x10,%esp
}
c01000b8:	90                   	nop
c01000b9:	c9                   	leave  
c01000ba:	c3                   	ret    

c01000bb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000bb:	55                   	push   %ebp
c01000bc:	89 e5                	mov    %esp,%ebp
c01000be:	53                   	push   %ebx
c01000bf:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000c2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000c8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ce:	51                   	push   %ecx
c01000cf:	52                   	push   %edx
c01000d0:	53                   	push   %ebx
c01000d1:	50                   	push   %eax
c01000d2:	e8 ca ff ff ff       	call   c01000a1 <grade_backtrace2>
c01000d7:	83 c4 10             	add    $0x10,%esp
}
c01000da:	90                   	nop
c01000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000de:	c9                   	leave  
c01000df:	c3                   	ret    

c01000e0 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000e0:	55                   	push   %ebp
c01000e1:	89 e5                	mov    %esp,%ebp
c01000e3:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000e6:	83 ec 08             	sub    $0x8,%esp
c01000e9:	ff 75 10             	pushl  0x10(%ebp)
c01000ec:	ff 75 08             	pushl  0x8(%ebp)
c01000ef:	e8 c7 ff ff ff       	call   c01000bb <grade_backtrace1>
c01000f4:	83 c4 10             	add    $0x10,%esp
}
c01000f7:	90                   	nop
c01000f8:	c9                   	leave  
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace>:

void
grade_backtrace(void) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100100:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100105:	83 ec 04             	sub    $0x4,%esp
c0100108:	68 00 00 ff ff       	push   $0xffff0000
c010010d:	50                   	push   %eax
c010010e:	6a 00                	push   $0x0
c0100110:	e8 cb ff ff ff       	call   c01000e0 <grade_backtrace0>
c0100115:	83 c4 10             	add    $0x10,%esp
}
c0100118:	90                   	nop
c0100119:	c9                   	leave  
c010011a:	c3                   	ret    

c010011b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010011b:	55                   	push   %ebp
c010011c:	89 e5                	mov    %esp,%ebp
c010011e:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100121:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100124:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100127:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010012a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010012d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100131:	0f b7 c0             	movzwl %ax,%eax
c0100134:	83 e0 03             	and    $0x3,%eax
c0100137:	89 c2                	mov    %eax,%edx
c0100139:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010013e:	83 ec 04             	sub    $0x4,%esp
c0100141:	52                   	push   %edx
c0100142:	50                   	push   %eax
c0100143:	68 a1 5a 10 c0       	push   $0xc0105aa1
c0100148:	e8 26 01 00 00       	call   c0100273 <cprintf>
c010014d:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c0100150:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100154:	0f b7 d0             	movzwl %ax,%edx
c0100157:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015c:	83 ec 04             	sub    $0x4,%esp
c010015f:	52                   	push   %edx
c0100160:	50                   	push   %eax
c0100161:	68 af 5a 10 c0       	push   $0xc0105aaf
c0100166:	e8 08 01 00 00       	call   c0100273 <cprintf>
c010016b:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c010016e:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100172:	0f b7 d0             	movzwl %ax,%edx
c0100175:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010017a:	83 ec 04             	sub    $0x4,%esp
c010017d:	52                   	push   %edx
c010017e:	50                   	push   %eax
c010017f:	68 bd 5a 10 c0       	push   $0xc0105abd
c0100184:	e8 ea 00 00 00       	call   c0100273 <cprintf>
c0100189:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c010018c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100190:	0f b7 d0             	movzwl %ax,%edx
c0100193:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100198:	83 ec 04             	sub    $0x4,%esp
c010019b:	52                   	push   %edx
c010019c:	50                   	push   %eax
c010019d:	68 cb 5a 10 c0       	push   $0xc0105acb
c01001a2:	e8 cc 00 00 00       	call   c0100273 <cprintf>
c01001a7:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001aa:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001ae:	0f b7 d0             	movzwl %ax,%edx
c01001b1:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b6:	83 ec 04             	sub    $0x4,%esp
c01001b9:	52                   	push   %edx
c01001ba:	50                   	push   %eax
c01001bb:	68 d9 5a 10 c0       	push   $0xc0105ad9
c01001c0:	e8 ae 00 00 00       	call   c0100273 <cprintf>
c01001c5:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001c8:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001cd:	83 c0 01             	add    $0x1,%eax
c01001d0:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001d5:	90                   	nop
c01001d6:	c9                   	leave  
c01001d7:	c3                   	ret    

c01001d8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001d8:	55                   	push   %ebp
c01001d9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001db:	90                   	nop
c01001dc:	5d                   	pop    %ebp
c01001dd:	c3                   	ret    

c01001de <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001de:	55                   	push   %ebp
c01001df:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001e1:	90                   	nop
c01001e2:	5d                   	pop    %ebp
c01001e3:	c3                   	ret    

c01001e4 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001e4:	55                   	push   %ebp
c01001e5:	89 e5                	mov    %esp,%ebp
c01001e7:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001ea:	e8 2c ff ff ff       	call   c010011b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c01001ef:	83 ec 0c             	sub    $0xc,%esp
c01001f2:	68 e8 5a 10 c0       	push   $0xc0105ae8
c01001f7:	e8 77 00 00 00       	call   c0100273 <cprintf>
c01001fc:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c01001ff:	e8 d4 ff ff ff       	call   c01001d8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100204:	e8 12 ff ff ff       	call   c010011b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100209:	83 ec 0c             	sub    $0xc,%esp
c010020c:	68 08 5b 10 c0       	push   $0xc0105b08
c0100211:	e8 5d 00 00 00       	call   c0100273 <cprintf>
c0100216:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100219:	e8 c0 ff ff ff       	call   c01001de <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010021e:	e8 f8 fe ff ff       	call   c010011b <lab1_print_cur_status>
}
c0100223:	90                   	nop
c0100224:	c9                   	leave  
c0100225:	c3                   	ret    

c0100226 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100226:	55                   	push   %ebp
c0100227:	89 e5                	mov    %esp,%ebp
c0100229:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010022c:	83 ec 0c             	sub    $0xc,%esp
c010022f:	ff 75 08             	pushl  0x8(%ebp)
c0100232:	e8 cc 13 00 00       	call   c0101603 <cons_putc>
c0100237:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c010023a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010023d:	8b 00                	mov    (%eax),%eax
c010023f:	8d 50 01             	lea    0x1(%eax),%edx
c0100242:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100245:	89 10                	mov    %edx,(%eax)
}
c0100247:	90                   	nop
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100257:	ff 75 0c             	pushl  0xc(%ebp)
c010025a:	ff 75 08             	pushl  0x8(%ebp)
c010025d:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100260:	50                   	push   %eax
c0100261:	68 26 02 10 c0       	push   $0xc0100226
c0100266:	e8 9d 53 00 00       	call   c0105608 <vprintfmt>
c010026b:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100271:	c9                   	leave  
c0100272:	c3                   	ret    

c0100273 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100273:	55                   	push   %ebp
c0100274:	89 e5                	mov    %esp,%ebp
c0100276:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100279:	8d 45 0c             	lea    0xc(%ebp),%eax
c010027c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010027f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100282:	83 ec 08             	sub    $0x8,%esp
c0100285:	50                   	push   %eax
c0100286:	ff 75 08             	pushl  0x8(%ebp)
c0100289:	e8 bc ff ff ff       	call   c010024a <vcprintf>
c010028e:	83 c4 10             	add    $0x10,%esp
c0100291:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100297:	c9                   	leave  
c0100298:	c3                   	ret    

c0100299 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100299:	55                   	push   %ebp
c010029a:	89 e5                	mov    %esp,%ebp
c010029c:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010029f:	83 ec 0c             	sub    $0xc,%esp
c01002a2:	ff 75 08             	pushl  0x8(%ebp)
c01002a5:	e8 59 13 00 00       	call   c0101603 <cons_putc>
c01002aa:	83 c4 10             	add    $0x10,%esp
}
c01002ad:	90                   	nop
c01002ae:	c9                   	leave  
c01002af:	c3                   	ret    

c01002b0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002b0:	55                   	push   %ebp
c01002b1:	89 e5                	mov    %esp,%ebp
c01002b3:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002bd:	eb 14                	jmp    c01002d3 <cputs+0x23>
        cputch(c, &cnt);
c01002bf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002c3:	83 ec 08             	sub    $0x8,%esp
c01002c6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002c9:	52                   	push   %edx
c01002ca:	50                   	push   %eax
c01002cb:	e8 56 ff ff ff       	call   c0100226 <cputch>
c01002d0:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d6:	8d 50 01             	lea    0x1(%eax),%edx
c01002d9:	89 55 08             	mov    %edx,0x8(%ebp)
c01002dc:	0f b6 00             	movzbl (%eax),%eax
c01002df:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002e2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002e6:	75 d7                	jne    c01002bf <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002e8:	83 ec 08             	sub    $0x8,%esp
c01002eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002ee:	50                   	push   %eax
c01002ef:	6a 0a                	push   $0xa
c01002f1:	e8 30 ff ff ff       	call   c0100226 <cputch>
c01002f6:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01002f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01002fc:	c9                   	leave  
c01002fd:	c3                   	ret    

c01002fe <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100304:	e8 43 13 00 00       	call   c010164c <cons_getc>
c0100309:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010030c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100310:	74 f2                	je     c0100304 <getchar+0x6>
        /* do nothing */;
    return c;
c0100312:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100315:	c9                   	leave  
c0100316:	c3                   	ret    

c0100317 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100317:	55                   	push   %ebp
c0100318:	89 e5                	mov    %esp,%ebp
c010031a:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c010031d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100321:	74 13                	je     c0100336 <readline+0x1f>
        cprintf("%s", prompt);
c0100323:	83 ec 08             	sub    $0x8,%esp
c0100326:	ff 75 08             	pushl  0x8(%ebp)
c0100329:	68 27 5b 10 c0       	push   $0xc0105b27
c010032e:	e8 40 ff ff ff       	call   c0100273 <cprintf>
c0100333:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010033d:	e8 bc ff ff ff       	call   c01002fe <getchar>
c0100342:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100349:	79 0a                	jns    c0100355 <readline+0x3e>
            return NULL;
c010034b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100350:	e9 82 00 00 00       	jmp    c01003d7 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100355:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100359:	7e 2b                	jle    c0100386 <readline+0x6f>
c010035b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100362:	7f 22                	jg     c0100386 <readline+0x6f>
            cputchar(c);
c0100364:	83 ec 0c             	sub    $0xc,%esp
c0100367:	ff 75 f0             	pushl  -0x10(%ebp)
c010036a:	e8 2a ff ff ff       	call   c0100299 <cputchar>
c010036f:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100375:	8d 50 01             	lea    0x1(%eax),%edx
c0100378:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010037b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010037e:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c0100384:	eb 4c                	jmp    c01003d2 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0100386:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010038a:	75 1a                	jne    c01003a6 <readline+0x8f>
c010038c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100390:	7e 14                	jle    c01003a6 <readline+0x8f>
            cputchar(c);
c0100392:	83 ec 0c             	sub    $0xc,%esp
c0100395:	ff 75 f0             	pushl  -0x10(%ebp)
c0100398:	e8 fc fe ff ff       	call   c0100299 <cputchar>
c010039d:	83 c4 10             	add    $0x10,%esp
            i --;
c01003a0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003a4:	eb 2c                	jmp    c01003d2 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01003a6:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003aa:	74 06                	je     c01003b2 <readline+0x9b>
c01003ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003b0:	75 8b                	jne    c010033d <readline+0x26>
            cputchar(c);
c01003b2:	83 ec 0c             	sub    $0xc,%esp
c01003b5:	ff 75 f0             	pushl  -0x10(%ebp)
c01003b8:	e8 dc fe ff ff       	call   c0100299 <cputchar>
c01003bd:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01003c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003c3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003c8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003cb:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01003d0:	eb 05                	jmp    c01003d7 <readline+0xc0>
        }
    }
c01003d2:	e9 66 ff ff ff       	jmp    c010033d <readline+0x26>
}
c01003d7:	c9                   	leave  
c01003d8:	c3                   	ret    

c01003d9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003d9:	55                   	push   %ebp
c01003da:	89 e5                	mov    %esp,%ebp
c01003dc:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01003df:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003e4:	85 c0                	test   %eax,%eax
c01003e6:	75 5f                	jne    c0100447 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c01003e8:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c01003ef:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c01003f2:	8d 45 14             	lea    0x14(%ebp),%eax
c01003f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c01003f8:	83 ec 04             	sub    $0x4,%esp
c01003fb:	ff 75 0c             	pushl  0xc(%ebp)
c01003fe:	ff 75 08             	pushl  0x8(%ebp)
c0100401:	68 2a 5b 10 c0       	push   $0xc0105b2a
c0100406:	e8 68 fe ff ff       	call   c0100273 <cprintf>
c010040b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010040e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100411:	83 ec 08             	sub    $0x8,%esp
c0100414:	50                   	push   %eax
c0100415:	ff 75 10             	pushl  0x10(%ebp)
c0100418:	e8 2d fe ff ff       	call   c010024a <vcprintf>
c010041d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100420:	83 ec 0c             	sub    $0xc,%esp
c0100423:	68 46 5b 10 c0       	push   $0xc0105b46
c0100428:	e8 46 fe ff ff       	call   c0100273 <cprintf>
c010042d:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c0100430:	83 ec 0c             	sub    $0xc,%esp
c0100433:	68 48 5b 10 c0       	push   $0xc0105b48
c0100438:	e8 36 fe ff ff       	call   c0100273 <cprintf>
c010043d:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c0100440:	e8 17 06 00 00       	call   c0100a5c <print_stackframe>
c0100445:	eb 01                	jmp    c0100448 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100447:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100448:	e8 3b 14 00 00       	call   c0101888 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010044d:	83 ec 0c             	sub    $0xc,%esp
c0100450:	6a 00                	push   $0x0
c0100452:	e8 36 08 00 00       	call   c0100c8d <kmonitor>
c0100457:	83 c4 10             	add    $0x10,%esp
    }
c010045a:	eb f1                	jmp    c010044d <__panic+0x74>

c010045c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010045c:	55                   	push   %ebp
c010045d:	89 e5                	mov    %esp,%ebp
c010045f:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100462:	8d 45 14             	lea    0x14(%ebp),%eax
c0100465:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100468:	83 ec 04             	sub    $0x4,%esp
c010046b:	ff 75 0c             	pushl  0xc(%ebp)
c010046e:	ff 75 08             	pushl  0x8(%ebp)
c0100471:	68 5a 5b 10 c0       	push   $0xc0105b5a
c0100476:	e8 f8 fd ff ff       	call   c0100273 <cprintf>
c010047b:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010047e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100481:	83 ec 08             	sub    $0x8,%esp
c0100484:	50                   	push   %eax
c0100485:	ff 75 10             	pushl  0x10(%ebp)
c0100488:	e8 bd fd ff ff       	call   c010024a <vcprintf>
c010048d:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100490:	83 ec 0c             	sub    $0xc,%esp
c0100493:	68 46 5b 10 c0       	push   $0xc0105b46
c0100498:	e8 d6 fd ff ff       	call   c0100273 <cprintf>
c010049d:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01004a0:	90                   	nop
c01004a1:	c9                   	leave  
c01004a2:	c3                   	ret    

c01004a3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004a3:	55                   	push   %ebp
c01004a4:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004a6:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c01004ab:	5d                   	pop    %ebp
c01004ac:	c3                   	ret    

c01004ad <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004ad:	55                   	push   %ebp
c01004ae:	89 e5                	mov    %esp,%ebp
c01004b0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004b6:	8b 00                	mov    (%eax),%eax
c01004b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	8b 00                	mov    (%eax),%eax
c01004c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ca:	e9 d2 00 00 00       	jmp    c01005a1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004d5:	01 d0                	add    %edx,%eax
c01004d7:	89 c2                	mov    %eax,%edx
c01004d9:	c1 ea 1f             	shr    $0x1f,%edx
c01004dc:	01 d0                	add    %edx,%eax
c01004de:	d1 f8                	sar    %eax
c01004e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004e6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004e9:	eb 04                	jmp    c01004ef <stab_binsearch+0x42>
            m --;
c01004eb:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004f5:	7c 1f                	jl     c0100516 <stab_binsearch+0x69>
c01004f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004fa:	89 d0                	mov    %edx,%eax
c01004fc:	01 c0                	add    %eax,%eax
c01004fe:	01 d0                	add    %edx,%eax
c0100500:	c1 e0 02             	shl    $0x2,%eax
c0100503:	89 c2                	mov    %eax,%edx
c0100505:	8b 45 08             	mov    0x8(%ebp),%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010050e:	0f b6 c0             	movzbl %al,%eax
c0100511:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100514:	75 d5                	jne    c01004eb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100516:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100519:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051c:	7d 0b                	jge    c0100529 <stab_binsearch+0x7c>
            l = true_m + 1;
c010051e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100521:	83 c0 01             	add    $0x1,%eax
c0100524:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100527:	eb 78                	jmp    c01005a1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100529:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100533:	89 d0                	mov    %edx,%eax
c0100535:	01 c0                	add    %eax,%eax
c0100537:	01 d0                	add    %edx,%eax
c0100539:	c1 e0 02             	shl    $0x2,%eax
c010053c:	89 c2                	mov    %eax,%edx
c010053e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100541:	01 d0                	add    %edx,%eax
c0100543:	8b 40 08             	mov    0x8(%eax),%eax
c0100546:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100549:	73 13                	jae    c010055e <stab_binsearch+0xb1>
            *region_left = m;
c010054b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100551:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100553:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100556:	83 c0 01             	add    $0x1,%eax
c0100559:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010055c:	eb 43                	jmp    c01005a1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100561:	89 d0                	mov    %edx,%eax
c0100563:	01 c0                	add    %eax,%eax
c0100565:	01 d0                	add    %edx,%eax
c0100567:	c1 e0 02             	shl    $0x2,%eax
c010056a:	89 c2                	mov    %eax,%edx
c010056c:	8b 45 08             	mov    0x8(%ebp),%eax
c010056f:	01 d0                	add    %edx,%eax
c0100571:	8b 40 08             	mov    0x8(%eax),%eax
c0100574:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100577:	76 16                	jbe    c010058f <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100579:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010057c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010057f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100582:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100587:	83 e8 01             	sub    $0x1,%eax
c010058a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010058d:	eb 12                	jmp    c01005a1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010058f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100592:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100595:	89 10                	mov    %edx,(%eax)
            l = m;
c0100597:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010059d:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005a7:	0f 8e 22 ff ff ff    	jle    c01004cf <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b1:	75 0f                	jne    c01005c2 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b6:	8b 00                	mov    (%eax),%eax
c01005b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01005be:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c0:	eb 3f                	jmp    c0100601 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c5:	8b 00                	mov    (%eax),%eax
c01005c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005ca:	eb 04                	jmp    c01005d0 <stab_binsearch+0x123>
c01005cc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d3:	8b 00                	mov    (%eax),%eax
c01005d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005d8:	7d 1f                	jge    c01005f9 <stab_binsearch+0x14c>
c01005da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005dd:	89 d0                	mov    %edx,%eax
c01005df:	01 c0                	add    %eax,%eax
c01005e1:	01 d0                	add    %edx,%eax
c01005e3:	c1 e0 02             	shl    $0x2,%eax
c01005e6:	89 c2                	mov    %eax,%edx
c01005e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01005eb:	01 d0                	add    %edx,%eax
c01005ed:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f1:	0f b6 c0             	movzbl %al,%eax
c01005f4:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005f7:	75 d3                	jne    c01005cc <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ff:	89 10                	mov    %edx,(%eax)
    }
}
c0100601:	90                   	nop
c0100602:	c9                   	leave  
c0100603:	c3                   	ret    

c0100604 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100604:	55                   	push   %ebp
c0100605:	89 e5                	mov    %esp,%ebp
c0100607:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060d:	c7 00 78 5b 10 c0    	movl   $0xc0105b78,(%eax)
    info->eip_line = 0;
c0100613:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100616:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100620:	c7 40 08 78 5b 10 c0 	movl   $0xc0105b78,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100627:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062a:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100631:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100634:	8b 55 08             	mov    0x8(%ebp),%edx
c0100637:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100644:	c7 45 f4 a0 6d 10 c0 	movl   $0xc0106da0,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064b:	c7 45 f0 b8 1b 11 c0 	movl   $0xc0111bb8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100652:	c7 45 ec b9 1b 11 c0 	movl   $0xc0111bb9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100659:	c7 45 e8 2a 46 11 c0 	movl   $0xc011462a,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100660:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100663:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100666:	76 0d                	jbe    c0100675 <debuginfo_eip+0x71>
c0100668:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066b:	83 e8 01             	sub    $0x1,%eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x7b>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 91 02 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>
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
c0100699:	83 e8 01             	sub    $0x1,%eax
c010069c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069f:	ff 75 08             	pushl  0x8(%ebp)
c01006a2:	6a 64                	push   $0x64
c01006a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006a7:	50                   	push   %eax
c01006a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006ab:	50                   	push   %eax
c01006ac:	ff 75 f4             	pushl  -0xc(%ebp)
c01006af:	e8 f9 fd ff ff       	call   c01004ad <stab_binsearch>
c01006b4:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c01006b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ba:	85 c0                	test   %eax,%eax
c01006bc:	75 0a                	jne    c01006c8 <debuginfo_eip+0xc4>
        return -1;
c01006be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006c3:	e9 48 02 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006d4:	ff 75 08             	pushl  0x8(%ebp)
c01006d7:	6a 24                	push   $0x24
c01006d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006dc:	50                   	push   %eax
c01006dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006e0:	50                   	push   %eax
c01006e1:	ff 75 f4             	pushl  -0xc(%ebp)
c01006e4:	e8 c4 fd ff ff       	call   c01004ad <stab_binsearch>
c01006e9:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c01006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006f2:	39 c2                	cmp    %eax,%edx
c01006f4:	7f 7c                	jg     c0100772 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01006f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006f9:	89 c2                	mov    %eax,%edx
c01006fb:	89 d0                	mov    %edx,%eax
c01006fd:	01 c0                	add    %eax,%eax
c01006ff:	01 d0                	add    %edx,%eax
c0100701:	c1 e0 02             	shl    $0x2,%eax
c0100704:	89 c2                	mov    %eax,%edx
c0100706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100709:	01 d0                	add    %edx,%eax
c010070b:	8b 00                	mov    (%eax),%eax
c010070d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100710:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100713:	29 d1                	sub    %edx,%ecx
c0100715:	89 ca                	mov    %ecx,%edx
c0100717:	39 d0                	cmp    %edx,%eax
c0100719:	73 22                	jae    c010073d <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010071b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010071e:	89 c2                	mov    %eax,%edx
c0100720:	89 d0                	mov    %edx,%eax
c0100722:	01 c0                	add    %eax,%eax
c0100724:	01 d0                	add    %edx,%eax
c0100726:	c1 e0 02             	shl    $0x2,%eax
c0100729:	89 c2                	mov    %eax,%edx
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	01 d0                	add    %edx,%eax
c0100730:	8b 10                	mov    (%eax),%edx
c0100732:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100735:	01 c2                	add    %eax,%edx
c0100737:	8b 45 0c             	mov    0xc(%ebp),%eax
c010073a:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010073d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100740:	89 c2                	mov    %eax,%edx
c0100742:	89 d0                	mov    %edx,%eax
c0100744:	01 c0                	add    %eax,%eax
c0100746:	01 d0                	add    %edx,%eax
c0100748:	c1 e0 02             	shl    $0x2,%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100750:	01 d0                	add    %edx,%eax
c0100752:	8b 50 08             	mov    0x8(%eax),%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	8b 40 10             	mov    0x10(%eax),%eax
c0100761:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100764:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100767:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010076d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100770:	eb 15                	jmp    c0100787 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100772:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100775:	8b 55 08             	mov    0x8(%ebp),%edx
c0100778:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010077b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100781:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100784:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100787:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078a:	8b 40 08             	mov    0x8(%eax),%eax
c010078d:	83 ec 08             	sub    $0x8,%esp
c0100790:	6a 3a                	push   $0x3a
c0100792:	50                   	push   %eax
c0100793:	e8 ae 49 00 00       	call   c0105146 <strfind>
c0100798:	83 c4 10             	add    $0x10,%esp
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a0:	8b 40 08             	mov    0x8(%eax),%eax
c01007a3:	29 c2                	sub    %eax,%edx
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007ab:	83 ec 0c             	sub    $0xc,%esp
c01007ae:	ff 75 08             	pushl  0x8(%ebp)
c01007b1:	6a 44                	push   $0x44
c01007b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007b6:	50                   	push   %eax
c01007b7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007ba:	50                   	push   %eax
c01007bb:	ff 75 f4             	pushl  -0xc(%ebp)
c01007be:	e8 ea fc ff ff       	call   c01004ad <stab_binsearch>
c01007c3:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007cc:	39 c2                	cmp    %eax,%edx
c01007ce:	7f 24                	jg     c01007f4 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007d3:	89 c2                	mov    %eax,%edx
c01007d5:	89 d0                	mov    %edx,%eax
c01007d7:	01 c0                	add    %eax,%eax
c01007d9:	01 d0                	add    %edx,%eax
c01007db:	c1 e0 02             	shl    $0x2,%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e3:	01 d0                	add    %edx,%eax
c01007e5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007e9:	0f b7 d0             	movzwl %ax,%edx
c01007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ef:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01007f2:	eb 13                	jmp    c0100807 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c01007f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007f9:	e9 12 01 00 00       	jmp    c0100910 <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01007fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100801:	83 e8 01             	sub    $0x1,%eax
c0100804:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010080a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010080d:	39 c2                	cmp    %eax,%edx
c010080f:	7c 56                	jl     c0100867 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0100811:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100814:	89 c2                	mov    %eax,%edx
c0100816:	89 d0                	mov    %edx,%eax
c0100818:	01 c0                	add    %eax,%eax
c010081a:	01 d0                	add    %edx,%eax
c010081c:	c1 e0 02             	shl    $0x2,%eax
c010081f:	89 c2                	mov    %eax,%edx
c0100821:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100824:	01 d0                	add    %edx,%eax
c0100826:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010082a:	3c 84                	cmp    $0x84,%al
c010082c:	74 39                	je     c0100867 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010082e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100831:	89 c2                	mov    %eax,%edx
c0100833:	89 d0                	mov    %edx,%eax
c0100835:	01 c0                	add    %eax,%eax
c0100837:	01 d0                	add    %edx,%eax
c0100839:	c1 e0 02             	shl    $0x2,%eax
c010083c:	89 c2                	mov    %eax,%edx
c010083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100841:	01 d0                	add    %edx,%eax
c0100843:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100847:	3c 64                	cmp    $0x64,%al
c0100849:	75 b3                	jne    c01007fe <debuginfo_eip+0x1fa>
c010084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084e:	89 c2                	mov    %eax,%edx
c0100850:	89 d0                	mov    %edx,%eax
c0100852:	01 c0                	add    %eax,%eax
c0100854:	01 d0                	add    %edx,%eax
c0100856:	c1 e0 02             	shl    $0x2,%eax
c0100859:	89 c2                	mov    %eax,%edx
c010085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	8b 40 08             	mov    0x8(%eax),%eax
c0100863:	85 c0                	test   %eax,%eax
c0100865:	74 97                	je     c01007fe <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100867:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010086a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010086d:	39 c2                	cmp    %eax,%edx
c010086f:	7c 46                	jl     c01008b7 <debuginfo_eip+0x2b3>
c0100871:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100874:	89 c2                	mov    %eax,%edx
c0100876:	89 d0                	mov    %edx,%eax
c0100878:	01 c0                	add    %eax,%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	c1 e0 02             	shl    $0x2,%eax
c010087f:	89 c2                	mov    %eax,%edx
c0100881:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100884:	01 d0                	add    %edx,%eax
c0100886:	8b 00                	mov    (%eax),%eax
c0100888:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010088b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010088e:	29 d1                	sub    %edx,%ecx
c0100890:	89 ca                	mov    %ecx,%edx
c0100892:	39 d0                	cmp    %edx,%eax
c0100894:	73 21                	jae    c01008b7 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100896:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100899:	89 c2                	mov    %eax,%edx
c010089b:	89 d0                	mov    %edx,%eax
c010089d:	01 c0                	add    %eax,%eax
c010089f:	01 d0                	add    %edx,%eax
c01008a1:	c1 e0 02             	shl    $0x2,%eax
c01008a4:	89 c2                	mov    %eax,%edx
c01008a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a9:	01 d0                	add    %edx,%eax
c01008ab:	8b 10                	mov    (%eax),%edx
c01008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008b0:	01 c2                	add    %eax,%edx
c01008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008b5:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008bd:	39 c2                	cmp    %eax,%edx
c01008bf:	7d 4a                	jge    c010090b <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c01008c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008c4:	83 c0 01             	add    $0x1,%eax
c01008c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008ca:	eb 18                	jmp    c01008e4 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008cf:	8b 40 14             	mov    0x14(%eax),%eax
c01008d2:	8d 50 01             	lea    0x1(%eax),%edx
c01008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d8:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01008db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008de:	83 c0 01             	add    $0x1,%eax
c01008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c01008ea:	39 c2                	cmp    %eax,%edx
c01008ec:	7d 1d                	jge    c010090b <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f1:	89 c2                	mov    %eax,%edx
c01008f3:	89 d0                	mov    %edx,%eax
c01008f5:	01 c0                	add    %eax,%eax
c01008f7:	01 d0                	add    %edx,%eax
c01008f9:	c1 e0 02             	shl    $0x2,%eax
c01008fc:	89 c2                	mov    %eax,%edx
c01008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100901:	01 d0                	add    %edx,%eax
c0100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100907:	3c a0                	cmp    $0xa0,%al
c0100909:	74 c1                	je     c01008cc <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100918:	83 ec 0c             	sub    $0xc,%esp
c010091b:	68 82 5b 10 c0       	push   $0xc0105b82
c0100920:	e8 4e f9 ff ff       	call   c0100273 <cprintf>
c0100925:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100928:	83 ec 08             	sub    $0x8,%esp
c010092b:	68 36 00 10 c0       	push   $0xc0100036
c0100930:	68 9b 5b 10 c0       	push   $0xc0105b9b
c0100935:	e8 39 f9 ff ff       	call   c0100273 <cprintf>
c010093a:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c010093d:	83 ec 08             	sub    $0x8,%esp
c0100940:	68 69 5a 10 c0       	push   $0xc0105a69
c0100945:	68 b3 5b 10 c0       	push   $0xc0105bb3
c010094a:	e8 24 f9 ff ff       	call   c0100273 <cprintf>
c010094f:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100952:	83 ec 08             	sub    $0x8,%esp
c0100955:	68 00 a0 11 c0       	push   $0xc011a000
c010095a:	68 cb 5b 10 c0       	push   $0xc0105bcb
c010095f:	e8 0f f9 ff ff       	call   c0100273 <cprintf>
c0100964:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0100967:	83 ec 08             	sub    $0x8,%esp
c010096a:	68 28 af 11 c0       	push   $0xc011af28
c010096f:	68 e3 5b 10 c0       	push   $0xc0105be3
c0100974:	e8 fa f8 ff ff       	call   c0100273 <cprintf>
c0100979:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010097c:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0100981:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100986:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c010098b:	29 d0                	sub    %edx,%eax
c010098d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100993:	85 c0                	test   %eax,%eax
c0100995:	0f 48 c2             	cmovs  %edx,%eax
c0100998:	c1 f8 0a             	sar    $0xa,%eax
c010099b:	83 ec 08             	sub    $0x8,%esp
c010099e:	50                   	push   %eax
c010099f:	68 fc 5b 10 c0       	push   $0xc0105bfc
c01009a4:	e8 ca f8 ff ff       	call   c0100273 <cprintf>
c01009a9:	83 c4 10             	add    $0x10,%esp
}
c01009ac:	90                   	nop
c01009ad:	c9                   	leave  
c01009ae:	c3                   	ret    

c01009af <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009af:	55                   	push   %ebp
c01009b0:	89 e5                	mov    %esp,%ebp
c01009b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009b8:	83 ec 08             	sub    $0x8,%esp
c01009bb:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009be:	50                   	push   %eax
c01009bf:	ff 75 08             	pushl  0x8(%ebp)
c01009c2:	e8 3d fc ff ff       	call   c0100604 <debuginfo_eip>
c01009c7:	83 c4 10             	add    $0x10,%esp
c01009ca:	85 c0                	test   %eax,%eax
c01009cc:	74 15                	je     c01009e3 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ce:	83 ec 08             	sub    $0x8,%esp
c01009d1:	ff 75 08             	pushl  0x8(%ebp)
c01009d4:	68 26 5c 10 c0       	push   $0xc0105c26
c01009d9:	e8 95 f8 ff ff       	call   c0100273 <cprintf>
c01009de:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009e1:	eb 65                	jmp    c0100a48 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009ea:	eb 1c                	jmp    c0100a08 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01009ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f2:	01 d0                	add    %edx,%eax
c01009f4:	0f b6 00             	movzbl (%eax),%eax
c01009f7:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a00:	01 ca                	add    %ecx,%edx
c0100a02:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a0b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a0e:	7f dc                	jg     c01009ec <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a10:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a19:	01 d0                	add    %edx,%eax
c0100a1b:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a21:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a24:	89 d1                	mov    %edx,%ecx
c0100a26:	29 c1                	sub    %eax,%ecx
c0100a28:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a2e:	83 ec 0c             	sub    $0xc,%esp
c0100a31:	51                   	push   %ecx
c0100a32:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a38:	51                   	push   %ecx
c0100a39:	52                   	push   %edx
c0100a3a:	50                   	push   %eax
c0100a3b:	68 42 5c 10 c0       	push   $0xc0105c42
c0100a40:	e8 2e f8 ff ff       	call   c0100273 <cprintf>
c0100a45:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a48:	90                   	nop
c0100a49:	c9                   	leave  
c0100a4a:	c3                   	ret    

c0100a4b <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a4b:	55                   	push   %ebp
c0100a4c:	89 e5                	mov    %esp,%ebp
c0100a4e:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a51:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a5a:	c9                   	leave  
c0100a5b:	c3                   	ret    

c0100a5c <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a5c:	55                   	push   %ebp
c0100a5d:	89 e5                	mov    %esp,%ebp
c0100a5f:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a62:	89 e8                	mov    %ebp,%eax
c0100a64:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a67:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a6d:	e8 d9 ff ff ff       	call   c0100a4b <read_eip>
c0100a72:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a75:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a7c:	e9 8d 00 00 00       	jmp    c0100b0e <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100a81:	83 ec 04             	sub    $0x4,%esp
c0100a84:	ff 75 f0             	pushl  -0x10(%ebp)
c0100a87:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a8a:	68 54 5c 10 c0       	push   $0xc0105c54
c0100a8f:	e8 df f7 ff ff       	call   c0100273 <cprintf>
c0100a94:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a9a:	83 c0 08             	add    $0x8,%eax
c0100a9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100aa0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100aa7:	eb 26                	jmp    c0100acf <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c0100aa9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ab3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ab6:	01 d0                	add    %edx,%eax
c0100ab8:	8b 00                	mov    (%eax),%eax
c0100aba:	83 ec 08             	sub    $0x8,%esp
c0100abd:	50                   	push   %eax
c0100abe:	68 70 5c 10 c0       	push   $0xc0105c70
c0100ac3:	e8 ab f7 ff ff       	call   c0100273 <cprintf>
c0100ac8:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100acb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100acf:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100ad3:	7e d4                	jle    c0100aa9 <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100ad5:	83 ec 0c             	sub    $0xc,%esp
c0100ad8:	68 78 5c 10 c0       	push   $0xc0105c78
c0100add:	e8 91 f7 ff ff       	call   c0100273 <cprintf>
c0100ae2:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0100ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ae8:	83 e8 01             	sub    $0x1,%eax
c0100aeb:	83 ec 0c             	sub    $0xc,%esp
c0100aee:	50                   	push   %eax
c0100aef:	e8 bb fe ff ff       	call   c01009af <print_debuginfo>
c0100af4:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0100af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afa:	83 c0 04             	add    $0x4,%eax
c0100afd:	8b 00                	mov    (%eax),%eax
c0100aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b05:	8b 00                	mov    (%eax),%eax
c0100b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b0a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b12:	74 0a                	je     c0100b1e <print_stackframe+0xc2>
c0100b14:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b18:	0f 8e 63 ff ff ff    	jle    c0100a81 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b1e:	90                   	nop
c0100b1f:	c9                   	leave  
c0100b20:	c3                   	ret    

c0100b21 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b21:	55                   	push   %ebp
c0100b22:	89 e5                	mov    %esp,%ebp
c0100b24:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b2e:	eb 0c                	jmp    c0100b3c <parse+0x1b>
            *buf ++ = '\0';
c0100b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b33:	8d 50 01             	lea    0x1(%eax),%edx
c0100b36:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b39:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3f:	0f b6 00             	movzbl (%eax),%eax
c0100b42:	84 c0                	test   %al,%al
c0100b44:	74 1e                	je     c0100b64 <parse+0x43>
c0100b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b49:	0f b6 00             	movzbl (%eax),%eax
c0100b4c:	0f be c0             	movsbl %al,%eax
c0100b4f:	83 ec 08             	sub    $0x8,%esp
c0100b52:	50                   	push   %eax
c0100b53:	68 fc 5c 10 c0       	push   $0xc0105cfc
c0100b58:	e8 b6 45 00 00       	call   c0105113 <strchr>
c0100b5d:	83 c4 10             	add    $0x10,%esp
c0100b60:	85 c0                	test   %eax,%eax
c0100b62:	75 cc                	jne    c0100b30 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b67:	0f b6 00             	movzbl (%eax),%eax
c0100b6a:	84 c0                	test   %al,%al
c0100b6c:	74 69                	je     c0100bd7 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b6e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b72:	75 12                	jne    c0100b86 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b74:	83 ec 08             	sub    $0x8,%esp
c0100b77:	6a 10                	push   $0x10
c0100b79:	68 01 5d 10 c0       	push   $0xc0105d01
c0100b7e:	e8 f0 f6 ff ff       	call   c0100273 <cprintf>
c0100b83:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b89:	8d 50 01             	lea    0x1(%eax),%edx
c0100b8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b99:	01 c2                	add    %eax,%edx
c0100b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9e:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100ba0:	eb 04                	jmp    c0100ba6 <parse+0x85>
            buf ++;
c0100ba2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba9:	0f b6 00             	movzbl (%eax),%eax
c0100bac:	84 c0                	test   %al,%al
c0100bae:	0f 84 7a ff ff ff    	je     c0100b2e <parse+0xd>
c0100bb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb7:	0f b6 00             	movzbl (%eax),%eax
c0100bba:	0f be c0             	movsbl %al,%eax
c0100bbd:	83 ec 08             	sub    $0x8,%esp
c0100bc0:	50                   	push   %eax
c0100bc1:	68 fc 5c 10 c0       	push   $0xc0105cfc
c0100bc6:	e8 48 45 00 00       	call   c0105113 <strchr>
c0100bcb:	83 c4 10             	add    $0x10,%esp
c0100bce:	85 c0                	test   %eax,%eax
c0100bd0:	74 d0                	je     c0100ba2 <parse+0x81>
            buf ++;
        }
    }
c0100bd2:	e9 57 ff ff ff       	jmp    c0100b2e <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100bd7:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bdb:	c9                   	leave  
c0100bdc:	c3                   	ret    

c0100bdd <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bdd:	55                   	push   %ebp
c0100bde:	89 e5                	mov    %esp,%ebp
c0100be0:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100be3:	83 ec 08             	sub    $0x8,%esp
c0100be6:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100be9:	50                   	push   %eax
c0100bea:	ff 75 08             	pushl  0x8(%ebp)
c0100bed:	e8 2f ff ff ff       	call   c0100b21 <parse>
c0100bf2:	83 c4 10             	add    $0x10,%esp
c0100bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100bf8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100bfc:	75 0a                	jne    c0100c08 <runcmd+0x2b>
        return 0;
c0100bfe:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c03:	e9 83 00 00 00       	jmp    c0100c8b <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c0f:	eb 59                	jmp    c0100c6a <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c11:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c17:	89 d0                	mov    %edx,%eax
c0100c19:	01 c0                	add    %eax,%eax
c0100c1b:	01 d0                	add    %edx,%eax
c0100c1d:	c1 e0 02             	shl    $0x2,%eax
c0100c20:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c25:	8b 00                	mov    (%eax),%eax
c0100c27:	83 ec 08             	sub    $0x8,%esp
c0100c2a:	51                   	push   %ecx
c0100c2b:	50                   	push   %eax
c0100c2c:	e8 42 44 00 00       	call   c0105073 <strcmp>
c0100c31:	83 c4 10             	add    $0x10,%esp
c0100c34:	85 c0                	test   %eax,%eax
c0100c36:	75 2e                	jne    c0100c66 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c3b:	89 d0                	mov    %edx,%eax
c0100c3d:	01 c0                	add    %eax,%eax
c0100c3f:	01 d0                	add    %edx,%eax
c0100c41:	c1 e0 02             	shl    $0x2,%eax
c0100c44:	05 08 70 11 c0       	add    $0xc0117008,%eax
c0100c49:	8b 10                	mov    (%eax),%edx
c0100c4b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c4e:	83 c0 04             	add    $0x4,%eax
c0100c51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c54:	83 e9 01             	sub    $0x1,%ecx
c0100c57:	83 ec 04             	sub    $0x4,%esp
c0100c5a:	ff 75 0c             	pushl  0xc(%ebp)
c0100c5d:	50                   	push   %eax
c0100c5e:	51                   	push   %ecx
c0100c5f:	ff d2                	call   *%edx
c0100c61:	83 c4 10             	add    $0x10,%esp
c0100c64:	eb 25                	jmp    c0100c8b <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c6d:	83 f8 02             	cmp    $0x2,%eax
c0100c70:	76 9f                	jbe    c0100c11 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c72:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c75:	83 ec 08             	sub    $0x8,%esp
c0100c78:	50                   	push   %eax
c0100c79:	68 1f 5d 10 c0       	push   $0xc0105d1f
c0100c7e:	e8 f0 f5 ff ff       	call   c0100273 <cprintf>
c0100c83:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c8b:	c9                   	leave  
c0100c8c:	c3                   	ret    

c0100c8d <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c8d:	55                   	push   %ebp
c0100c8e:	89 e5                	mov    %esp,%ebp
c0100c90:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c93:	83 ec 0c             	sub    $0xc,%esp
c0100c96:	68 38 5d 10 c0       	push   $0xc0105d38
c0100c9b:	e8 d3 f5 ff ff       	call   c0100273 <cprintf>
c0100ca0:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100ca3:	83 ec 0c             	sub    $0xc,%esp
c0100ca6:	68 60 5d 10 c0       	push   $0xc0105d60
c0100cab:	e8 c3 f5 ff ff       	call   c0100273 <cprintf>
c0100cb0:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100cb3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cb7:	74 0e                	je     c0100cc7 <kmonitor+0x3a>
        print_trapframe(tf);
c0100cb9:	83 ec 0c             	sub    $0xc,%esp
c0100cbc:	ff 75 08             	pushl  0x8(%ebp)
c0100cbf:	e8 20 0d 00 00       	call   c01019e4 <print_trapframe>
c0100cc4:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cc7:	83 ec 0c             	sub    $0xc,%esp
c0100cca:	68 85 5d 10 c0       	push   $0xc0105d85
c0100ccf:	e8 43 f6 ff ff       	call   c0100317 <readline>
c0100cd4:	83 c4 10             	add    $0x10,%esp
c0100cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cde:	74 e7                	je     c0100cc7 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100ce0:	83 ec 08             	sub    $0x8,%esp
c0100ce3:	ff 75 08             	pushl  0x8(%ebp)
c0100ce6:	ff 75 f4             	pushl  -0xc(%ebp)
c0100ce9:	e8 ef fe ff ff       	call   c0100bdd <runcmd>
c0100cee:	83 c4 10             	add    $0x10,%esp
c0100cf1:	85 c0                	test   %eax,%eax
c0100cf3:	78 02                	js     c0100cf7 <kmonitor+0x6a>
                break;
            }
        }
    }
c0100cf5:	eb d0                	jmp    c0100cc7 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100cf7:	90                   	nop
            }
        }
    }
}
c0100cf8:	90                   	nop
c0100cf9:	c9                   	leave  
c0100cfa:	c3                   	ret    

c0100cfb <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100cfb:	55                   	push   %ebp
c0100cfc:	89 e5                	mov    %esp,%ebp
c0100cfe:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d08:	eb 3c                	jmp    c0100d46 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d0d:	89 d0                	mov    %edx,%eax
c0100d0f:	01 c0                	add    %eax,%eax
c0100d11:	01 d0                	add    %edx,%eax
c0100d13:	c1 e0 02             	shl    $0x2,%eax
c0100d16:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d1b:	8b 08                	mov    (%eax),%ecx
c0100d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d20:	89 d0                	mov    %edx,%eax
c0100d22:	01 c0                	add    %eax,%eax
c0100d24:	01 d0                	add    %edx,%eax
c0100d26:	c1 e0 02             	shl    $0x2,%eax
c0100d29:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d2e:	8b 00                	mov    (%eax),%eax
c0100d30:	83 ec 04             	sub    $0x4,%esp
c0100d33:	51                   	push   %ecx
c0100d34:	50                   	push   %eax
c0100d35:	68 89 5d 10 c0       	push   $0xc0105d89
c0100d3a:	e8 34 f5 ff ff       	call   c0100273 <cprintf>
c0100d3f:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d49:	83 f8 02             	cmp    $0x2,%eax
c0100d4c:	76 bc                	jbe    c0100d0a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d53:	c9                   	leave  
c0100d54:	c3                   	ret    

c0100d55 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d55:	55                   	push   %ebp
c0100d56:	89 e5                	mov    %esp,%ebp
c0100d58:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d5b:	e8 b2 fb ff ff       	call   c0100912 <print_kerninfo>
    return 0;
c0100d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d65:	c9                   	leave  
c0100d66:	c3                   	ret    

c0100d67 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d67:	55                   	push   %ebp
c0100d68:	89 e5                	mov    %esp,%ebp
c0100d6a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d6d:	e8 ea fc ff ff       	call   c0100a5c <print_stackframe>
    return 0;
c0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d77:	c9                   	leave  
c0100d78:	c3                   	ret    

c0100d79 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d79:	55                   	push   %ebp
c0100d7a:	89 e5                	mov    %esp,%ebp
c0100d7c:	83 ec 18             	sub    $0x18,%esp
c0100d7f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d85:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d89:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100d8d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100d91:	ee                   	out    %al,(%dx)
c0100d92:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100d98:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100d9c:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100da0:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0100da4:	ee                   	out    %al,(%dx)
c0100da5:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dab:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100daf:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100db8:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dbf:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dc2:	83 ec 0c             	sub    $0xc,%esp
c0100dc5:	68 92 5d 10 c0       	push   $0xc0105d92
c0100dca:	e8 a4 f4 ff ff       	call   c0100273 <cprintf>
c0100dcf:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0100dd2:	83 ec 0c             	sub    $0xc,%esp
c0100dd5:	6a 00                	push   $0x0
c0100dd7:	e8 3b 09 00 00       	call   c0101717 <pic_enable>
c0100ddc:	83 c4 10             	add    $0x10,%esp
}
c0100ddf:	90                   	nop
c0100de0:	c9                   	leave  
c0100de1:	c3                   	ret    

c0100de2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100de2:	55                   	push   %ebp
c0100de3:	89 e5                	mov    %esp,%ebp
c0100de5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100de8:	9c                   	pushf  
c0100de9:	58                   	pop    %eax
c0100dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100df0:	25 00 02 00 00       	and    $0x200,%eax
c0100df5:	85 c0                	test   %eax,%eax
c0100df7:	74 0c                	je     c0100e05 <__intr_save+0x23>
        intr_disable();
c0100df9:	e8 8a 0a 00 00       	call   c0101888 <intr_disable>
        return 1;
c0100dfe:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e03:	eb 05                	jmp    c0100e0a <__intr_save+0x28>
    }
    return 0;
c0100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e0a:	c9                   	leave  
c0100e0b:	c3                   	ret    

c0100e0c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e0c:	55                   	push   %ebp
c0100e0d:	89 e5                	mov    %esp,%ebp
c0100e0f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e16:	74 05                	je     c0100e1d <__intr_restore+0x11>
        intr_enable();
c0100e18:	e8 64 0a 00 00       	call   c0101881 <intr_enable>
    }
}
c0100e1d:	90                   	nop
c0100e1e:	c9                   	leave  
c0100e1f:	c3                   	ret    

c0100e20 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e20:	55                   	push   %ebp
c0100e21:	89 e5                	mov    %esp,%ebp
c0100e23:	83 ec 10             	sub    $0x10,%esp
c0100e26:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e2c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e30:	89 c2                	mov    %eax,%edx
c0100e32:	ec                   	in     (%dx),%al
c0100e33:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e36:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e3c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0100e40:	89 c2                	mov    %eax,%edx
c0100e42:	ec                   	in     (%dx),%al
c0100e43:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e46:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e4c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e50:	89 c2                	mov    %eax,%edx
c0100e52:	ec                   	in     (%dx),%al
c0100e53:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e56:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e5c:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0100e60:	89 c2                	mov    %eax,%edx
c0100e62:	ec                   	in     (%dx),%al
c0100e63:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e66:	90                   	nop
c0100e67:	c9                   	leave  
c0100e68:	c3                   	ret    

c0100e69 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e69:	55                   	push   %ebp
c0100e6a:	89 e5                	mov    %esp,%ebp
c0100e6c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e6f:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e79:	0f b7 00             	movzwl (%eax),%eax
c0100e7c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e83:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8b:	0f b7 00             	movzwl (%eax),%eax
c0100e8e:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e92:	74 12                	je     c0100ea6 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100e94:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100e9b:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ea2:	b4 03 
c0100ea4:	eb 13                	jmp    c0100eb9 <cga_init+0x50>
    } else {
        *cp = was;
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ead:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eb0:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100eb7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eb9:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ec0:	0f b7 c0             	movzwl %ax,%eax
c0100ec3:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100ec7:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ecb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100ecf:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0100ed3:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ed4:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100edb:	83 c0 01             	add    $0x1,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ee5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ee9:	89 c2                	mov    %eax,%edx
c0100eeb:	ec                   	in     (%dx),%al
c0100eec:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100eef:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100ef3:	0f b6 c0             	movzbl %al,%eax
c0100ef6:	c1 e0 08             	shl    $0x8,%eax
c0100ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100efc:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f03:	0f b7 c0             	movzwl %ax,%eax
c0100f06:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f0a:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f0e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f12:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0100f16:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f17:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f1e:	83 c0 01             	add    $0x1,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f28:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f2c:	89 c2                	mov    %eax,%edx
c0100f2e:	ec                   	in     (%dx),%al
c0100f2f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f32:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f36:	0f b6 c0             	movzbl %al,%eax
c0100f39:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f3f:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f47:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f4d:	90                   	nop
c0100f4e:	c9                   	leave  
c0100f4f:	c3                   	ret    

c0100f50 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f50:	55                   	push   %ebp
c0100f51:	89 e5                	mov    %esp,%ebp
c0100f53:	83 ec 28             	sub    $0x28,%esp
c0100f56:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f5c:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f60:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f64:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f68:	ee                   	out    %al,(%dx)
c0100f69:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f6f:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f73:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100f77:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0100f7b:	ee                   	out    %al,(%dx)
c0100f7c:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100f82:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100f86:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100f8a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f8e:	ee                   	out    %al,(%dx)
c0100f8f:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100f95:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100f99:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100f9d:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0100fa1:	ee                   	out    %al,(%dx)
c0100fa2:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100fa8:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fac:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fb0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fb4:	ee                   	out    %al,(%dx)
c0100fb5:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fbb:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fbf:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100fc3:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0100fc7:	ee                   	out    %al,(%dx)
c0100fc8:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fce:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100fd2:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100fd6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fda:	ee                   	out    %al,(%dx)
c0100fdb:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe1:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0100fe5:	89 c2                	mov    %eax,%edx
c0100fe7:	ec                   	in     (%dx),%al
c0100fe8:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0100feb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100fef:	3c ff                	cmp    $0xff,%al
c0100ff1:	0f 95 c0             	setne  %al
c0100ff4:	0f b6 c0             	movzbl %al,%eax
c0100ff7:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0100ffc:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101002:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101006:	89 c2                	mov    %eax,%edx
c0101008:	ec                   	in     (%dx),%al
c0101009:	88 45 e2             	mov    %al,-0x1e(%ebp)
c010100c:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101012:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c0101016:	89 c2                	mov    %eax,%edx
c0101018:	ec                   	in     (%dx),%al
c0101019:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010101c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101021:	85 c0                	test   %eax,%eax
c0101023:	74 0d                	je     c0101032 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c0101025:	83 ec 0c             	sub    $0xc,%esp
c0101028:	6a 04                	push   $0x4
c010102a:	e8 e8 06 00 00       	call   c0101717 <pic_enable>
c010102f:	83 c4 10             	add    $0x10,%esp
    }
}
c0101032:	90                   	nop
c0101033:	c9                   	leave  
c0101034:	c3                   	ret    

c0101035 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101035:	55                   	push   %ebp
c0101036:	89 e5                	mov    %esp,%ebp
c0101038:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010103b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101042:	eb 09                	jmp    c010104d <lpt_putc_sub+0x18>
        delay();
c0101044:	e8 d7 fd ff ff       	call   c0100e20 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101049:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010104d:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101053:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0101057:	89 c2                	mov    %eax,%edx
c0101059:	ec                   	in     (%dx),%al
c010105a:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010105d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101061:	84 c0                	test   %al,%al
c0101063:	78 09                	js     c010106e <lpt_putc_sub+0x39>
c0101065:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010106c:	7e d6                	jle    c0101044 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010106e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101071:	0f b6 c0             	movzbl %al,%eax
c0101074:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010107a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010107d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101081:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
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
    if (c != '\b') {
c01010b2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010b6:	74 0d                	je     c01010c5 <lpt_putc+0x16>
        lpt_putc_sub(c);
c01010b8:	ff 75 08             	pushl  0x8(%ebp)
c01010bb:	e8 75 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010c0:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010c3:	eb 1e                	jmp    c01010e3 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010c5:	6a 08                	push   $0x8
c01010c7:	e8 69 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010cc:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c01010cf:	6a 20                	push   $0x20
c01010d1:	e8 5f ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010d6:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c01010d9:	6a 08                	push   $0x8
c01010db:	e8 55 ff ff ff       	call   c0101035 <lpt_putc_sub>
c01010e0:	83 c4 04             	add    $0x4,%esp
    }
}
c01010e3:	90                   	nop
c01010e4:	c9                   	leave  
c01010e5:	c3                   	ret    

c01010e6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010e6:	55                   	push   %ebp
c01010e7:	89 e5                	mov    %esp,%ebp
c01010e9:	53                   	push   %ebx
c01010ea:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f0:	b0 00                	mov    $0x0,%al
c01010f2:	85 c0                	test   %eax,%eax
c01010f4:	75 07                	jne    c01010fd <cga_putc+0x17>
        c |= 0x0700;
c01010f6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101100:	0f b6 c0             	movzbl %al,%eax
c0101103:	83 f8 0a             	cmp    $0xa,%eax
c0101106:	74 4e                	je     c0101156 <cga_putc+0x70>
c0101108:	83 f8 0d             	cmp    $0xd,%eax
c010110b:	74 59                	je     c0101166 <cga_putc+0x80>
c010110d:	83 f8 08             	cmp    $0x8,%eax
c0101110:	0f 85 8a 00 00 00    	jne    c01011a0 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c0101116:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010111d:	66 85 c0             	test   %ax,%ax
c0101120:	0f 84 a0 00 00 00    	je     c01011c6 <cga_putc+0xe0>
            crt_pos --;
c0101126:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010112d:	83 e8 01             	sub    $0x1,%eax
c0101130:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101136:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010113b:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101142:	0f b7 d2             	movzwl %dx,%edx
c0101145:	01 d2                	add    %edx,%edx
c0101147:	01 d0                	add    %edx,%eax
c0101149:	8b 55 08             	mov    0x8(%ebp),%edx
c010114c:	b2 00                	mov    $0x0,%dl
c010114e:	83 ca 20             	or     $0x20,%edx
c0101151:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0101154:	eb 70                	jmp    c01011c6 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c0101156:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010115d:	83 c0 50             	add    $0x50,%eax
c0101160:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101166:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010116d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101174:	0f b7 c1             	movzwl %cx,%eax
c0101177:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010117d:	c1 e8 10             	shr    $0x10,%eax
c0101180:	89 c2                	mov    %eax,%edx
c0101182:	66 c1 ea 06          	shr    $0x6,%dx
c0101186:	89 d0                	mov    %edx,%eax
c0101188:	c1 e0 02             	shl    $0x2,%eax
c010118b:	01 d0                	add    %edx,%eax
c010118d:	c1 e0 04             	shl    $0x4,%eax
c0101190:	29 c1                	sub    %eax,%ecx
c0101192:	89 ca                	mov    %ecx,%edx
c0101194:	89 d8                	mov    %ebx,%eax
c0101196:	29 d0                	sub    %edx,%eax
c0101198:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c010119e:	eb 27                	jmp    c01011c7 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011a0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011a6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ad:	8d 50 01             	lea    0x1(%eax),%edx
c01011b0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011b7:	0f b7 c0             	movzwl %ax,%eax
c01011ba:	01 c0                	add    %eax,%eax
c01011bc:	01 c8                	add    %ecx,%eax
c01011be:	8b 55 08             	mov    0x8(%ebp),%edx
c01011c1:	66 89 10             	mov    %dx,(%eax)
        break;
c01011c4:	eb 01                	jmp    c01011c7 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c01011c6:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011c7:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ce:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011d2:	76 59                	jbe    c010122d <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011d4:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011d9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011df:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011e4:	83 ec 04             	sub    $0x4,%esp
c01011e7:	68 00 0f 00 00       	push   $0xf00
c01011ec:	52                   	push   %edx
c01011ed:	50                   	push   %eax
c01011ee:	e8 1f 41 00 00       	call   c0105312 <memmove>
c01011f3:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01011f6:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01011fd:	eb 15                	jmp    c0101214 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c01011ff:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101204:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101207:	01 d2                	add    %edx,%edx
c0101209:	01 d0                	add    %edx,%eax
c010120b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101210:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101214:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010121b:	7e e2                	jle    c01011ff <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010121d:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101224:	83 e8 50             	sub    $0x50,%eax
c0101227:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010122d:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101234:	0f b7 c0             	movzwl %ax,%eax
c0101237:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010123b:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c010123f:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101243:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101247:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101248:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010124f:	66 c1 e8 08          	shr    $0x8,%ax
c0101253:	0f b6 c0             	movzbl %al,%eax
c0101256:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010125d:	83 c2 01             	add    $0x1,%edx
c0101260:	0f b7 d2             	movzwl %dx,%edx
c0101263:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101267:	88 45 e9             	mov    %al,-0x17(%ebp)
c010126a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010126e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101272:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101273:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010127a:	0f b7 c0             	movzwl %ax,%eax
c010127d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101281:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101285:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101289:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c010128e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101295:	0f b6 c0             	movzbl %al,%eax
c0101298:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010129f:	83 c2 01             	add    $0x1,%edx
c01012a2:	0f b7 d2             	movzwl %dx,%edx
c01012a5:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012a9:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012ac:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012b0:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01012b4:	ee                   	out    %al,(%dx)
}
c01012b5:	90                   	nop
c01012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01012b9:	c9                   	leave  
c01012ba:	c3                   	ret    

c01012bb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012bb:	55                   	push   %ebp
c01012bc:	89 e5                	mov    %esp,%ebp
c01012be:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012c8:	eb 09                	jmp    c01012d3 <serial_putc_sub+0x18>
        delay();
c01012ca:	e8 51 fb ff ff       	call   c0100e20 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012d3:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012d9:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01012dd:	89 c2                	mov    %eax,%edx
c01012df:	ec                   	in     (%dx),%al
c01012e0:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01012e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01012e7:	0f b6 c0             	movzbl %al,%eax
c01012ea:	83 e0 20             	and    $0x20,%eax
c01012ed:	85 c0                	test   %eax,%eax
c01012ef:	75 09                	jne    c01012fa <serial_putc_sub+0x3f>
c01012f1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01012f8:	7e d0                	jle    c01012ca <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c01012fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01012fd:	0f b6 c0             	movzbl %al,%eax
c0101300:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101306:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101309:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c010130d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101311:	ee                   	out    %al,(%dx)
}
c0101312:	90                   	nop
c0101313:	c9                   	leave  
c0101314:	c3                   	ret    

c0101315 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101315:	55                   	push   %ebp
c0101316:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0101318:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010131c:	74 0d                	je     c010132b <serial_putc+0x16>
        serial_putc_sub(c);
c010131e:	ff 75 08             	pushl  0x8(%ebp)
c0101321:	e8 95 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101326:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101329:	eb 1e                	jmp    c0101349 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c010132b:	6a 08                	push   $0x8
c010132d:	e8 89 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101332:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101335:	6a 20                	push   $0x20
c0101337:	e8 7f ff ff ff       	call   c01012bb <serial_putc_sub>
c010133c:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c010133f:	6a 08                	push   $0x8
c0101341:	e8 75 ff ff ff       	call   c01012bb <serial_putc_sub>
c0101346:	83 c4 04             	add    $0x4,%esp
    }
}
c0101349:	90                   	nop
c010134a:	c9                   	leave  
c010134b:	c3                   	ret    

c010134c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010134c:	55                   	push   %ebp
c010134d:	89 e5                	mov    %esp,%ebp
c010134f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101352:	eb 33                	jmp    c0101387 <cons_intr+0x3b>
        if (c != 0) {
c0101354:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101358:	74 2d                	je     c0101387 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010135a:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010135f:	8d 50 01             	lea    0x1(%eax),%edx
c0101362:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101368:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010136b:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101371:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101376:	3d 00 02 00 00       	cmp    $0x200,%eax
c010137b:	75 0a                	jne    c0101387 <cons_intr+0x3b>
                cons.wpos = 0;
c010137d:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c0101384:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101387:	8b 45 08             	mov    0x8(%ebp),%eax
c010138a:	ff d0                	call   *%eax
c010138c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010138f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101393:	75 bf                	jne    c0101354 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101395:	90                   	nop
c0101396:	c9                   	leave  
c0101397:	c3                   	ret    

c0101398 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101398:	55                   	push   %ebp
c0101399:	89 e5                	mov    %esp,%ebp
c010139b:	83 ec 10             	sub    $0x10,%esp
c010139e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013a4:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c01013a8:	89 c2                	mov    %eax,%edx
c01013aa:	ec                   	in     (%dx),%al
c01013ab:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013b2:	0f b6 c0             	movzbl %al,%eax
c01013b5:	83 e0 01             	and    $0x1,%eax
c01013b8:	85 c0                	test   %eax,%eax
c01013ba:	75 07                	jne    c01013c3 <serial_proc_data+0x2b>
        return -1;
c01013bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013c1:	eb 2a                	jmp    c01013ed <serial_proc_data+0x55>
c01013c3:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013c9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cd:	89 c2                	mov    %eax,%edx
c01013cf:	ec                   	in     (%dx),%al
c01013d0:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c01013d3:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013d7:	0f b6 c0             	movzbl %al,%eax
c01013da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013dd:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x52>
        c = '\b';
c01013e3:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01013ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01013ed:	c9                   	leave  
c01013ee:	c3                   	ret    

c01013ef <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01013ef:	55                   	push   %ebp
c01013f0:	89 e5                	mov    %esp,%ebp
c01013f2:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c01013f5:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01013fa:	85 c0                	test   %eax,%eax
c01013fc:	74 10                	je     c010140e <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c01013fe:	83 ec 0c             	sub    $0xc,%esp
c0101401:	68 98 13 10 c0       	push   $0xc0101398
c0101406:	e8 41 ff ff ff       	call   c010134c <cons_intr>
c010140b:	83 c4 10             	add    $0x10,%esp
    }
}
c010140e:	90                   	nop
c010140f:	c9                   	leave  
c0101410:	c3                   	ret    

c0101411 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101411:	55                   	push   %ebp
c0101412:	89 e5                	mov    %esp,%ebp
c0101414:	83 ec 18             	sub    $0x18,%esp
c0101417:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010141d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101421:	89 c2                	mov    %eax,%edx
c0101423:	ec                   	in     (%dx),%al
c0101424:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101427:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010142b:	0f b6 c0             	movzbl %al,%eax
c010142e:	83 e0 01             	and    $0x1,%eax
c0101431:	85 c0                	test   %eax,%eax
c0101433:	75 0a                	jne    c010143f <kbd_proc_data+0x2e>
        return -1;
c0101435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010143a:	e9 5d 01 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
c010143f:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101445:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101449:	89 c2                	mov    %eax,%edx
c010144b:	ec                   	in     (%dx),%al
c010144c:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c010144f:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101453:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101456:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010145a:	75 17                	jne    c0101473 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010145c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101461:	83 c8 40             	or     $0x40,%eax
c0101464:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101469:	b8 00 00 00 00       	mov    $0x0,%eax
c010146e:	e9 29 01 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0101473:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101477:	84 c0                	test   %al,%al
c0101479:	79 47                	jns    c01014c2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010147b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101480:	83 e0 40             	and    $0x40,%eax
c0101483:	85 c0                	test   %eax,%eax
c0101485:	75 09                	jne    c0101490 <kbd_proc_data+0x7f>
c0101487:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148b:	83 e0 7f             	and    $0x7f,%eax
c010148e:	eb 04                	jmp    c0101494 <kbd_proc_data+0x83>
c0101490:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101494:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101497:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149b:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014a2:	83 c8 40             	or     $0x40,%eax
c01014a5:	0f b6 c0             	movzbl %al,%eax
c01014a8:	f7 d0                	not    %eax
c01014aa:	89 c2                	mov    %eax,%edx
c01014ac:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014b1:	21 d0                	and    %edx,%eax
c01014b3:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014b8:	b8 00 00 00 00       	mov    $0x0,%eax
c01014bd:	e9 da 00 00 00       	jmp    c010159c <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c01014c2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014c7:	83 e0 40             	and    $0x40,%eax
c01014ca:	85 c0                	test   %eax,%eax
c01014cc:	74 11                	je     c01014df <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ce:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014d2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d7:	83 e0 bf             	and    $0xffffffbf,%eax
c01014da:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014df:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014e3:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014ea:	0f b6 d0             	movzbl %al,%edx
c01014ed:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f2:	09 d0                	or     %edx,%eax
c01014f4:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c01014f9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014fd:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101504:	0f b6 d0             	movzbl %al,%edx
c0101507:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010150c:	31 d0                	xor    %edx,%eax
c010150e:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101513:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101518:	83 e0 03             	and    $0x3,%eax
c010151b:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101526:	01 d0                	add    %edx,%eax
c0101528:	0f b6 00             	movzbl (%eax),%eax
c010152b:	0f b6 c0             	movzbl %al,%eax
c010152e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101531:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101536:	83 e0 08             	and    $0x8,%eax
c0101539:	85 c0                	test   %eax,%eax
c010153b:	74 22                	je     c010155f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010153d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101541:	7e 0c                	jle    c010154f <kbd_proc_data+0x13e>
c0101543:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101547:	7f 06                	jg     c010154f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101549:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010154d:	eb 10                	jmp    c010155f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010154f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101553:	7e 0a                	jle    c010155f <kbd_proc_data+0x14e>
c0101555:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101559:	7f 04                	jg     c010155f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010155b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010155f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101564:	f7 d0                	not    %eax
c0101566:	83 e0 06             	and    $0x6,%eax
c0101569:	85 c0                	test   %eax,%eax
c010156b:	75 2c                	jne    c0101599 <kbd_proc_data+0x188>
c010156d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101574:	75 23                	jne    c0101599 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0101576:	83 ec 0c             	sub    $0xc,%esp
c0101579:	68 ad 5d 10 c0       	push   $0xc0105dad
c010157e:	e8 f0 ec ff ff       	call   c0100273 <cprintf>
c0101583:	83 c4 10             	add    $0x10,%esp
c0101586:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010158c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101590:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101594:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101598:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010159c:	c9                   	leave  
c010159d:	c3                   	ret    

c010159e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010159e:	55                   	push   %ebp
c010159f:	89 e5                	mov    %esp,%ebp
c01015a1:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c01015a4:	83 ec 0c             	sub    $0xc,%esp
c01015a7:	68 11 14 10 c0       	push   $0xc0101411
c01015ac:	e8 9b fd ff ff       	call   c010134c <cons_intr>
c01015b1:	83 c4 10             	add    $0x10,%esp
}
c01015b4:	90                   	nop
c01015b5:	c9                   	leave  
c01015b6:	c3                   	ret    

c01015b7 <kbd_init>:

static void
kbd_init(void) {
c01015b7:	55                   	push   %ebp
c01015b8:	89 e5                	mov    %esp,%ebp
c01015ba:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c01015bd:	e8 dc ff ff ff       	call   c010159e <kbd_intr>
    pic_enable(IRQ_KBD);
c01015c2:	83 ec 0c             	sub    $0xc,%esp
c01015c5:	6a 01                	push   $0x1
c01015c7:	e8 4b 01 00 00       	call   c0101717 <pic_enable>
c01015cc:	83 c4 10             	add    $0x10,%esp
}
c01015cf:	90                   	nop
c01015d0:	c9                   	leave  
c01015d1:	c3                   	ret    

c01015d2 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015d2:	55                   	push   %ebp
c01015d3:	89 e5                	mov    %esp,%ebp
c01015d5:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c01015d8:	e8 8c f8 ff ff       	call   c0100e69 <cga_init>
    serial_init();
c01015dd:	e8 6e f9 ff ff       	call   c0100f50 <serial_init>
    kbd_init();
c01015e2:	e8 d0 ff ff ff       	call   c01015b7 <kbd_init>
    if (!serial_exists) {
c01015e7:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01015ec:	85 c0                	test   %eax,%eax
c01015ee:	75 10                	jne    c0101600 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01015f0:	83 ec 0c             	sub    $0xc,%esp
c01015f3:	68 b9 5d 10 c0       	push   $0xc0105db9
c01015f8:	e8 76 ec ff ff       	call   c0100273 <cprintf>
c01015fd:	83 c4 10             	add    $0x10,%esp
    }
}
c0101600:	90                   	nop
c0101601:	c9                   	leave  
c0101602:	c3                   	ret    

c0101603 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101603:	55                   	push   %ebp
c0101604:	89 e5                	mov    %esp,%ebp
c0101606:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101609:	e8 d4 f7 ff ff       	call   c0100de2 <__intr_save>
c010160e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101611:	83 ec 0c             	sub    $0xc,%esp
c0101614:	ff 75 08             	pushl  0x8(%ebp)
c0101617:	e8 93 fa ff ff       	call   c01010af <lpt_putc>
c010161c:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c010161f:	83 ec 0c             	sub    $0xc,%esp
c0101622:	ff 75 08             	pushl  0x8(%ebp)
c0101625:	e8 bc fa ff ff       	call   c01010e6 <cga_putc>
c010162a:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c010162d:	83 ec 0c             	sub    $0xc,%esp
c0101630:	ff 75 08             	pushl  0x8(%ebp)
c0101633:	e8 dd fc ff ff       	call   c0101315 <serial_putc>
c0101638:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c010163b:	83 ec 0c             	sub    $0xc,%esp
c010163e:	ff 75 f4             	pushl  -0xc(%ebp)
c0101641:	e8 c6 f7 ff ff       	call   c0100e0c <__intr_restore>
c0101646:	83 c4 10             	add    $0x10,%esp
}
c0101649:	90                   	nop
c010164a:	c9                   	leave  
c010164b:	c3                   	ret    

c010164c <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010164c:	55                   	push   %ebp
c010164d:	89 e5                	mov    %esp,%ebp
c010164f:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101659:	e8 84 f7 ff ff       	call   c0100de2 <__intr_save>
c010165e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101661:	e8 89 fd ff ff       	call   c01013ef <serial_intr>
        kbd_intr();
c0101666:	e8 33 ff ff ff       	call   c010159e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010166b:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101671:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101676:	39 c2                	cmp    %eax,%edx
c0101678:	74 31                	je     c01016ab <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010167f:	8d 50 01             	lea    0x1(%eax),%edx
c0101682:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101688:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c010168f:	0f b6 c0             	movzbl %al,%eax
c0101692:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101695:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169a:	3d 00 02 00 00       	cmp    $0x200,%eax
c010169f:	75 0a                	jne    c01016ab <cons_getc+0x5f>
                cons.rpos = 0;
c01016a1:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016a8:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016ab:	83 ec 0c             	sub    $0xc,%esp
c01016ae:	ff 75 f0             	pushl  -0x10(%ebp)
c01016b1:	e8 56 f7 ff ff       	call   c0100e0c <__intr_restore>
c01016b6:	83 c4 10             	add    $0x10,%esp
    return c;
c01016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016bc:	c9                   	leave  
c01016bd:	c3                   	ret    

c01016be <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016be:	55                   	push   %ebp
c01016bf:	89 e5                	mov    %esp,%ebp
c01016c1:	83 ec 14             	sub    $0x14,%esp
c01016c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016cf:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016d5:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016da:	85 c0                	test   %eax,%eax
c01016dc:	74 36                	je     c0101714 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016de:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016e2:	0f b6 c0             	movzbl %al,%eax
c01016e5:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016eb:	88 45 fa             	mov    %al,-0x6(%ebp)
c01016ee:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01016f2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016fb:	66 c1 e8 08          	shr    $0x8,%ax
c01016ff:	0f b6 c0             	movzbl %al,%eax
c0101702:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101708:	88 45 fb             	mov    %al,-0x5(%ebp)
c010170b:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c010170f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101713:	ee                   	out    %al,(%dx)
    }
}
c0101714:	90                   	nop
c0101715:	c9                   	leave  
c0101716:	c3                   	ret    

c0101717 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101717:	55                   	push   %ebp
c0101718:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c010171a:	8b 45 08             	mov    0x8(%ebp),%eax
c010171d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101722:	89 c1                	mov    %eax,%ecx
c0101724:	d3 e2                	shl    %cl,%edx
c0101726:	89 d0                	mov    %edx,%eax
c0101728:	f7 d0                	not    %eax
c010172a:	89 c2                	mov    %eax,%edx
c010172c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101733:	21 d0                	and    %edx,%eax
c0101735:	0f b7 c0             	movzwl %ax,%eax
c0101738:	50                   	push   %eax
c0101739:	e8 80 ff ff ff       	call   c01016be <pic_setmask>
c010173e:	83 c4 04             	add    $0x4,%esp
}
c0101741:	90                   	nop
c0101742:	c9                   	leave  
c0101743:	c3                   	ret    

c0101744 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101744:	55                   	push   %ebp
c0101745:	89 e5                	mov    %esp,%ebp
c0101747:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c010174a:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c0101751:	00 00 00 
c0101754:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010175a:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010175e:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101762:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101766:	ee                   	out    %al,(%dx)
c0101767:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010176d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101771:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101775:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101779:	ee                   	out    %al,(%dx)
c010177a:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101780:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101784:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101788:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010178c:	ee                   	out    %al,(%dx)
c010178d:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0101793:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101797:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010179b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010179f:	ee                   	out    %al,(%dx)
c01017a0:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c01017a6:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017aa:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b2:	ee                   	out    %al,(%dx)
c01017b3:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017b9:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017bd:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017c1:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c01017c5:	ee                   	out    %al,(%dx)
c01017c6:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017cc:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017d0:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017d4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017d8:	ee                   	out    %al,(%dx)
c01017d9:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017df:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017e3:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017e7:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01017eb:	ee                   	out    %al,(%dx)
c01017ec:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01017f2:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01017f6:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017fa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017fe:	ee                   	out    %al,(%dx)
c01017ff:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0101805:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101809:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010180d:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0101811:	ee                   	out    %al,(%dx)
c0101812:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0101818:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c010181c:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101820:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101824:	ee                   	out    %al,(%dx)
c0101825:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c010182b:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c010182f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101833:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101837:	ee                   	out    %al,(%dx)
c0101838:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010183e:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101842:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0101846:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010184a:	ee                   	out    %al,(%dx)
c010184b:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101851:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c0101855:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c0101859:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c010185d:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010185e:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101865:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101869:	74 13                	je     c010187e <pic_init+0x13a>
        pic_setmask(irq_mask);
c010186b:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101872:	0f b7 c0             	movzwl %ax,%eax
c0101875:	50                   	push   %eax
c0101876:	e8 43 fe ff ff       	call   c01016be <pic_setmask>
c010187b:	83 c4 04             	add    $0x4,%esp
    }
}
c010187e:	90                   	nop
c010187f:	c9                   	leave  
c0101880:	c3                   	ret    

c0101881 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101881:	55                   	push   %ebp
c0101882:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101884:	fb                   	sti    
    sti();
}
c0101885:	90                   	nop
c0101886:	5d                   	pop    %ebp
c0101887:	c3                   	ret    

c0101888 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101888:	55                   	push   %ebp
c0101889:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010188b:	fa                   	cli    
    cli();
}
c010188c:	90                   	nop
c010188d:	5d                   	pop    %ebp
c010188e:	c3                   	ret    

c010188f <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188f:	55                   	push   %ebp
c0101890:	89 e5                	mov    %esp,%ebp
c0101892:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101895:	83 ec 08             	sub    $0x8,%esp
c0101898:	6a 64                	push   $0x64
c010189a:	68 e0 5d 10 c0       	push   $0xc0105de0
c010189f:	e8 cf e9 ff ff       	call   c0100273 <cprintf>
c01018a4:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018a7:	90                   	nop
c01018a8:	c9                   	leave  
c01018a9:	c3                   	ret    

c01018aa <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018aa:	55                   	push   %ebp
c01018ab:	89 e5                	mov    %esp,%ebp
c01018ad:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b7:	e9 c3 00 00 00       	jmp    c010197f <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018bf:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c6:	89 c2                	mov    %eax,%edx
c01018c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018cb:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018d2:	c0 
c01018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d6:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018dd:	c0 08 00 
c01018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e3:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018ea:	c0 
c01018eb:	83 e2 e0             	and    $0xffffffe0,%edx
c01018ee:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f8:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018ff:	c0 
c0101900:	83 e2 1f             	and    $0x1f,%edx
c0101903:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010190a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190d:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101914:	c0 
c0101915:	83 e2 f0             	and    $0xfffffff0,%edx
c0101918:	83 ca 0e             	or     $0xe,%edx
c010191b:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101925:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010192c:	c0 
c010192d:	83 e2 ef             	and    $0xffffffef,%edx
c0101930:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101937:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101941:	c0 
c0101942:	83 e2 9f             	and    $0xffffff9f,%edx
c0101945:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010194c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194f:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101956:	c0 
c0101957:	83 ca 80             	or     $0xffffff80,%edx
c010195a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101964:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010196b:	c1 e8 10             	shr    $0x10,%eax
c010196e:	89 c2                	mov    %eax,%edx
c0101970:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101973:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c010197a:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010197b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010197f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101982:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101987:	0f 86 2f ff ff ff    	jbe    c01018bc <idt_init+0x12>
c010198d:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101994:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101997:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c010199a:	90                   	nop
c010199b:	c9                   	leave  
c010199c:	c3                   	ret    

c010199d <trapname>:

static const char *
trapname(int trapno) {
c010199d:	55                   	push   %ebp
c010199e:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a3:	83 f8 13             	cmp    $0x13,%eax
c01019a6:	77 0c                	ja     c01019b4 <trapname+0x17>
        return excnames[trapno];
c01019a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ab:	8b 04 85 40 61 10 c0 	mov    -0x3fef9ec0(,%eax,4),%eax
c01019b2:	eb 18                	jmp    c01019cc <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019b4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019b8:	7e 0d                	jle    c01019c7 <trapname+0x2a>
c01019ba:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019be:	7f 07                	jg     c01019c7 <trapname+0x2a>
        return "Hardware Interrupt";
c01019c0:	b8 ea 5d 10 c0       	mov    $0xc0105dea,%eax
c01019c5:	eb 05                	jmp    c01019cc <trapname+0x2f>
    }
    return "(unknown trap)";
c01019c7:	b8 fd 5d 10 c0       	mov    $0xc0105dfd,%eax
}
c01019cc:	5d                   	pop    %ebp
c01019cd:	c3                   	ret    

c01019ce <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019ce:	55                   	push   %ebp
c01019cf:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019d8:	66 83 f8 08          	cmp    $0x8,%ax
c01019dc:	0f 94 c0             	sete   %al
c01019df:	0f b6 c0             	movzbl %al,%eax
}
c01019e2:	5d                   	pop    %ebp
c01019e3:	c3                   	ret    

c01019e4 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01019e4:	55                   	push   %ebp
c01019e5:	89 e5                	mov    %esp,%ebp
c01019e7:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c01019ea:	83 ec 08             	sub    $0x8,%esp
c01019ed:	ff 75 08             	pushl  0x8(%ebp)
c01019f0:	68 3e 5e 10 c0       	push   $0xc0105e3e
c01019f5:	e8 79 e8 ff ff       	call   c0100273 <cprintf>
c01019fa:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c01019fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a00:	83 ec 0c             	sub    $0xc,%esp
c0101a03:	50                   	push   %eax
c0101a04:	e8 b8 01 00 00       	call   c0101bc1 <print_regs>
c0101a09:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a0f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a13:	0f b7 c0             	movzwl %ax,%eax
c0101a16:	83 ec 08             	sub    $0x8,%esp
c0101a19:	50                   	push   %eax
c0101a1a:	68 4f 5e 10 c0       	push   $0xc0105e4f
c0101a1f:	e8 4f e8 ff ff       	call   c0100273 <cprintf>
c0101a24:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a2a:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a2e:	0f b7 c0             	movzwl %ax,%eax
c0101a31:	83 ec 08             	sub    $0x8,%esp
c0101a34:	50                   	push   %eax
c0101a35:	68 62 5e 10 c0       	push   $0xc0105e62
c0101a3a:	e8 34 e8 ff ff       	call   c0100273 <cprintf>
c0101a3f:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a45:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a49:	0f b7 c0             	movzwl %ax,%eax
c0101a4c:	83 ec 08             	sub    $0x8,%esp
c0101a4f:	50                   	push   %eax
c0101a50:	68 75 5e 10 c0       	push   $0xc0105e75
c0101a55:	e8 19 e8 ff ff       	call   c0100273 <cprintf>
c0101a5a:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a60:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a64:	0f b7 c0             	movzwl %ax,%eax
c0101a67:	83 ec 08             	sub    $0x8,%esp
c0101a6a:	50                   	push   %eax
c0101a6b:	68 88 5e 10 c0       	push   $0xc0105e88
c0101a70:	e8 fe e7 ff ff       	call   c0100273 <cprintf>
c0101a75:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7b:	8b 40 30             	mov    0x30(%eax),%eax
c0101a7e:	83 ec 0c             	sub    $0xc,%esp
c0101a81:	50                   	push   %eax
c0101a82:	e8 16 ff ff ff       	call   c010199d <trapname>
c0101a87:	83 c4 10             	add    $0x10,%esp
c0101a8a:	89 c2                	mov    %eax,%edx
c0101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a8f:	8b 40 30             	mov    0x30(%eax),%eax
c0101a92:	83 ec 04             	sub    $0x4,%esp
c0101a95:	52                   	push   %edx
c0101a96:	50                   	push   %eax
c0101a97:	68 9b 5e 10 c0       	push   $0xc0105e9b
c0101a9c:	e8 d2 e7 ff ff       	call   c0100273 <cprintf>
c0101aa1:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa7:	8b 40 34             	mov    0x34(%eax),%eax
c0101aaa:	83 ec 08             	sub    $0x8,%esp
c0101aad:	50                   	push   %eax
c0101aae:	68 ad 5e 10 c0       	push   $0xc0105ead
c0101ab3:	e8 bb e7 ff ff       	call   c0100273 <cprintf>
c0101ab8:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abe:	8b 40 38             	mov    0x38(%eax),%eax
c0101ac1:	83 ec 08             	sub    $0x8,%esp
c0101ac4:	50                   	push   %eax
c0101ac5:	68 bc 5e 10 c0       	push   $0xc0105ebc
c0101aca:	e8 a4 e7 ff ff       	call   c0100273 <cprintf>
c0101acf:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ad9:	0f b7 c0             	movzwl %ax,%eax
c0101adc:	83 ec 08             	sub    $0x8,%esp
c0101adf:	50                   	push   %eax
c0101ae0:	68 cb 5e 10 c0       	push   $0xc0105ecb
c0101ae5:	e8 89 e7 ff ff       	call   c0100273 <cprintf>
c0101aea:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af0:	8b 40 40             	mov    0x40(%eax),%eax
c0101af3:	83 ec 08             	sub    $0x8,%esp
c0101af6:	50                   	push   %eax
c0101af7:	68 de 5e 10 c0       	push   $0xc0105ede
c0101afc:	e8 72 e7 ff ff       	call   c0100273 <cprintf>
c0101b01:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b0b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b12:	eb 3f                	jmp    c0101b53 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b17:	8b 50 40             	mov    0x40(%eax),%edx
c0101b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b1d:	21 d0                	and    %edx,%eax
c0101b1f:	85 c0                	test   %eax,%eax
c0101b21:	74 29                	je     c0101b4c <print_trapframe+0x168>
c0101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b26:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b2d:	85 c0                	test   %eax,%eax
c0101b2f:	74 1b                	je     c0101b4c <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c0101b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b34:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b3b:	83 ec 08             	sub    $0x8,%esp
c0101b3e:	50                   	push   %eax
c0101b3f:	68 ed 5e 10 c0       	push   $0xc0105eed
c0101b44:	e8 2a e7 ff ff       	call   c0100273 <cprintf>
c0101b49:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b4c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101b50:	d1 65 f0             	shll   -0x10(%ebp)
c0101b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b56:	83 f8 17             	cmp    $0x17,%eax
c0101b59:	76 b9                	jbe    c0101b14 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5e:	8b 40 40             	mov    0x40(%eax),%eax
c0101b61:	25 00 30 00 00       	and    $0x3000,%eax
c0101b66:	c1 e8 0c             	shr    $0xc,%eax
c0101b69:	83 ec 08             	sub    $0x8,%esp
c0101b6c:	50                   	push   %eax
c0101b6d:	68 f1 5e 10 c0       	push   $0xc0105ef1
c0101b72:	e8 fc e6 ff ff       	call   c0100273 <cprintf>
c0101b77:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0101b7a:	83 ec 0c             	sub    $0xc,%esp
c0101b7d:	ff 75 08             	pushl  0x8(%ebp)
c0101b80:	e8 49 fe ff ff       	call   c01019ce <trap_in_kernel>
c0101b85:	83 c4 10             	add    $0x10,%esp
c0101b88:	85 c0                	test   %eax,%eax
c0101b8a:	75 32                	jne    c0101bbe <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8f:	8b 40 44             	mov    0x44(%eax),%eax
c0101b92:	83 ec 08             	sub    $0x8,%esp
c0101b95:	50                   	push   %eax
c0101b96:	68 fa 5e 10 c0       	push   $0xc0105efa
c0101b9b:	e8 d3 e6 ff ff       	call   c0100273 <cprintf>
c0101ba0:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba6:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101baa:	0f b7 c0             	movzwl %ax,%eax
c0101bad:	83 ec 08             	sub    $0x8,%esp
c0101bb0:	50                   	push   %eax
c0101bb1:	68 09 5f 10 c0       	push   $0xc0105f09
c0101bb6:	e8 b8 e6 ff ff       	call   c0100273 <cprintf>
c0101bbb:	83 c4 10             	add    $0x10,%esp
    }
}
c0101bbe:	90                   	nop
c0101bbf:	c9                   	leave  
c0101bc0:	c3                   	ret    

c0101bc1 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101bc1:	55                   	push   %ebp
c0101bc2:	89 e5                	mov    %esp,%ebp
c0101bc4:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bca:	8b 00                	mov    (%eax),%eax
c0101bcc:	83 ec 08             	sub    $0x8,%esp
c0101bcf:	50                   	push   %eax
c0101bd0:	68 1c 5f 10 c0       	push   $0xc0105f1c
c0101bd5:	e8 99 e6 ff ff       	call   c0100273 <cprintf>
c0101bda:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be0:	8b 40 04             	mov    0x4(%eax),%eax
c0101be3:	83 ec 08             	sub    $0x8,%esp
c0101be6:	50                   	push   %eax
c0101be7:	68 2b 5f 10 c0       	push   $0xc0105f2b
c0101bec:	e8 82 e6 ff ff       	call   c0100273 <cprintf>
c0101bf1:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf7:	8b 40 08             	mov    0x8(%eax),%eax
c0101bfa:	83 ec 08             	sub    $0x8,%esp
c0101bfd:	50                   	push   %eax
c0101bfe:	68 3a 5f 10 c0       	push   $0xc0105f3a
c0101c03:	e8 6b e6 ff ff       	call   c0100273 <cprintf>
c0101c08:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0e:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c11:	83 ec 08             	sub    $0x8,%esp
c0101c14:	50                   	push   %eax
c0101c15:	68 49 5f 10 c0       	push   $0xc0105f49
c0101c1a:	e8 54 e6 ff ff       	call   c0100273 <cprintf>
c0101c1f:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c25:	8b 40 10             	mov    0x10(%eax),%eax
c0101c28:	83 ec 08             	sub    $0x8,%esp
c0101c2b:	50                   	push   %eax
c0101c2c:	68 58 5f 10 c0       	push   $0xc0105f58
c0101c31:	e8 3d e6 ff ff       	call   c0100273 <cprintf>
c0101c36:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3c:	8b 40 14             	mov    0x14(%eax),%eax
c0101c3f:	83 ec 08             	sub    $0x8,%esp
c0101c42:	50                   	push   %eax
c0101c43:	68 67 5f 10 c0       	push   $0xc0105f67
c0101c48:	e8 26 e6 ff ff       	call   c0100273 <cprintf>
c0101c4d:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c53:	8b 40 18             	mov    0x18(%eax),%eax
c0101c56:	83 ec 08             	sub    $0x8,%esp
c0101c59:	50                   	push   %eax
c0101c5a:	68 76 5f 10 c0       	push   $0xc0105f76
c0101c5f:	e8 0f e6 ff ff       	call   c0100273 <cprintf>
c0101c64:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c6d:	83 ec 08             	sub    $0x8,%esp
c0101c70:	50                   	push   %eax
c0101c71:	68 85 5f 10 c0       	push   $0xc0105f85
c0101c76:	e8 f8 e5 ff ff       	call   c0100273 <cprintf>
c0101c7b:	83 c4 10             	add    $0x10,%esp
}
c0101c7e:	90                   	nop
c0101c7f:	c9                   	leave  
c0101c80:	c3                   	ret    

c0101c81 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c81:	55                   	push   %ebp
c0101c82:	89 e5                	mov    %esp,%ebp
c0101c84:	83 ec 18             	sub    $0x18,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8a:	8b 40 30             	mov    0x30(%eax),%eax
c0101c8d:	83 f8 2f             	cmp    $0x2f,%eax
c0101c90:	77 1d                	ja     c0101caf <trap_dispatch+0x2e>
c0101c92:	83 f8 2e             	cmp    $0x2e,%eax
c0101c95:	0f 83 f4 00 00 00    	jae    c0101d8f <trap_dispatch+0x10e>
c0101c9b:	83 f8 21             	cmp    $0x21,%eax
c0101c9e:	74 7e                	je     c0101d1e <trap_dispatch+0x9d>
c0101ca0:	83 f8 24             	cmp    $0x24,%eax
c0101ca3:	74 55                	je     c0101cfa <trap_dispatch+0x79>
c0101ca5:	83 f8 20             	cmp    $0x20,%eax
c0101ca8:	74 16                	je     c0101cc0 <trap_dispatch+0x3f>
c0101caa:	e9 aa 00 00 00       	jmp    c0101d59 <trap_dispatch+0xd8>
c0101caf:	83 e8 78             	sub    $0x78,%eax
c0101cb2:	83 f8 01             	cmp    $0x1,%eax
c0101cb5:	0f 87 9e 00 00 00    	ja     c0101d59 <trap_dispatch+0xd8>
c0101cbb:	e9 82 00 00 00       	jmp    c0101d42 <trap_dispatch+0xc1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101cc0:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101cc5:	83 c0 01             	add    $0x1,%eax
c0101cc8:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101ccd:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101cd3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cd8:	89 c8                	mov    %ecx,%eax
c0101cda:	f7 e2                	mul    %edx
c0101cdc:	89 d0                	mov    %edx,%eax
c0101cde:	c1 e8 05             	shr    $0x5,%eax
c0101ce1:	6b c0 64             	imul   $0x64,%eax,%eax
c0101ce4:	29 c1                	sub    %eax,%ecx
c0101ce6:	89 c8                	mov    %ecx,%eax
c0101ce8:	85 c0                	test   %eax,%eax
c0101cea:	0f 85 a2 00 00 00    	jne    c0101d92 <trap_dispatch+0x111>
            print_ticks();
c0101cf0:	e8 9a fb ff ff       	call   c010188f <print_ticks>
        }
        break;
c0101cf5:	e9 98 00 00 00       	jmp    c0101d92 <trap_dispatch+0x111>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cfa:	e8 4d f9 ff ff       	call   c010164c <cons_getc>
c0101cff:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d02:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d06:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d0a:	83 ec 04             	sub    $0x4,%esp
c0101d0d:	52                   	push   %edx
c0101d0e:	50                   	push   %eax
c0101d0f:	68 94 5f 10 c0       	push   $0xc0105f94
c0101d14:	e8 5a e5 ff ff       	call   c0100273 <cprintf>
c0101d19:	83 c4 10             	add    $0x10,%esp
        break;
c0101d1c:	eb 75                	jmp    c0101d93 <trap_dispatch+0x112>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d1e:	e8 29 f9 ff ff       	call   c010164c <cons_getc>
c0101d23:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d26:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d2a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d2e:	83 ec 04             	sub    $0x4,%esp
c0101d31:	52                   	push   %edx
c0101d32:	50                   	push   %eax
c0101d33:	68 a6 5f 10 c0       	push   $0xc0105fa6
c0101d38:	e8 36 e5 ff ff       	call   c0100273 <cprintf>
c0101d3d:	83 c4 10             	add    $0x10,%esp
        break;
c0101d40:	eb 51                	jmp    c0101d93 <trap_dispatch+0x112>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d42:	83 ec 04             	sub    $0x4,%esp
c0101d45:	68 b5 5f 10 c0       	push   $0xc0105fb5
c0101d4a:	68 ac 00 00 00       	push   $0xac
c0101d4f:	68 c5 5f 10 c0       	push   $0xc0105fc5
c0101d54:	e8 80 e6 ff ff       	call   c01003d9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d5c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d60:	0f b7 c0             	movzwl %ax,%eax
c0101d63:	83 e0 03             	and    $0x3,%eax
c0101d66:	85 c0                	test   %eax,%eax
c0101d68:	75 29                	jne    c0101d93 <trap_dispatch+0x112>
            print_trapframe(tf);
c0101d6a:	83 ec 0c             	sub    $0xc,%esp
c0101d6d:	ff 75 08             	pushl  0x8(%ebp)
c0101d70:	e8 6f fc ff ff       	call   c01019e4 <print_trapframe>
c0101d75:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0101d78:	83 ec 04             	sub    $0x4,%esp
c0101d7b:	68 d6 5f 10 c0       	push   $0xc0105fd6
c0101d80:	68 b6 00 00 00       	push   $0xb6
c0101d85:	68 c5 5f 10 c0       	push   $0xc0105fc5
c0101d8a:	e8 4a e6 ff ff       	call   c01003d9 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101d8f:	90                   	nop
c0101d90:	eb 01                	jmp    c0101d93 <trap_dispatch+0x112>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0101d92:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101d93:	90                   	nop
c0101d94:	c9                   	leave  
c0101d95:	c3                   	ret    

c0101d96 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d96:	55                   	push   %ebp
c0101d97:	89 e5                	mov    %esp,%ebp
c0101d99:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d9c:	83 ec 0c             	sub    $0xc,%esp
c0101d9f:	ff 75 08             	pushl  0x8(%ebp)
c0101da2:	e8 da fe ff ff       	call   c0101c81 <trap_dispatch>
c0101da7:	83 c4 10             	add    $0x10,%esp
}
c0101daa:	90                   	nop
c0101dab:	c9                   	leave  
c0101dac:	c3                   	ret    

c0101dad <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101dad:	6a 00                	push   $0x0
  pushl $0
c0101daf:	6a 00                	push   $0x0
  jmp __alltraps
c0101db1:	e9 67 0a 00 00       	jmp    c010281d <__alltraps>

c0101db6 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101db6:	6a 00                	push   $0x0
  pushl $1
c0101db8:	6a 01                	push   $0x1
  jmp __alltraps
c0101dba:	e9 5e 0a 00 00       	jmp    c010281d <__alltraps>

c0101dbf <vector2>:
.globl vector2
vector2:
  pushl $0
c0101dbf:	6a 00                	push   $0x0
  pushl $2
c0101dc1:	6a 02                	push   $0x2
  jmp __alltraps
c0101dc3:	e9 55 0a 00 00       	jmp    c010281d <__alltraps>

c0101dc8 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101dc8:	6a 00                	push   $0x0
  pushl $3
c0101dca:	6a 03                	push   $0x3
  jmp __alltraps
c0101dcc:	e9 4c 0a 00 00       	jmp    c010281d <__alltraps>

c0101dd1 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dd1:	6a 00                	push   $0x0
  pushl $4
c0101dd3:	6a 04                	push   $0x4
  jmp __alltraps
c0101dd5:	e9 43 0a 00 00       	jmp    c010281d <__alltraps>

c0101dda <vector5>:
.globl vector5
vector5:
  pushl $0
c0101dda:	6a 00                	push   $0x0
  pushl $5
c0101ddc:	6a 05                	push   $0x5
  jmp __alltraps
c0101dde:	e9 3a 0a 00 00       	jmp    c010281d <__alltraps>

c0101de3 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101de3:	6a 00                	push   $0x0
  pushl $6
c0101de5:	6a 06                	push   $0x6
  jmp __alltraps
c0101de7:	e9 31 0a 00 00       	jmp    c010281d <__alltraps>

c0101dec <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dec:	6a 00                	push   $0x0
  pushl $7
c0101dee:	6a 07                	push   $0x7
  jmp __alltraps
c0101df0:	e9 28 0a 00 00       	jmp    c010281d <__alltraps>

c0101df5 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101df5:	6a 08                	push   $0x8
  jmp __alltraps
c0101df7:	e9 21 0a 00 00       	jmp    c010281d <__alltraps>

c0101dfc <vector9>:
.globl vector9
vector9:
  pushl $9
c0101dfc:	6a 09                	push   $0x9
  jmp __alltraps
c0101dfe:	e9 1a 0a 00 00       	jmp    c010281d <__alltraps>

c0101e03 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e03:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e05:	e9 13 0a 00 00       	jmp    c010281d <__alltraps>

c0101e0a <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e0a:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e0c:	e9 0c 0a 00 00       	jmp    c010281d <__alltraps>

c0101e11 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e11:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e13:	e9 05 0a 00 00       	jmp    c010281d <__alltraps>

c0101e18 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e18:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e1a:	e9 fe 09 00 00       	jmp    c010281d <__alltraps>

c0101e1f <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e1f:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e21:	e9 f7 09 00 00       	jmp    c010281d <__alltraps>

c0101e26 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e26:	6a 00                	push   $0x0
  pushl $15
c0101e28:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e2a:	e9 ee 09 00 00       	jmp    c010281d <__alltraps>

c0101e2f <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e2f:	6a 00                	push   $0x0
  pushl $16
c0101e31:	6a 10                	push   $0x10
  jmp __alltraps
c0101e33:	e9 e5 09 00 00       	jmp    c010281d <__alltraps>

c0101e38 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e38:	6a 11                	push   $0x11
  jmp __alltraps
c0101e3a:	e9 de 09 00 00       	jmp    c010281d <__alltraps>

c0101e3f <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e3f:	6a 00                	push   $0x0
  pushl $18
c0101e41:	6a 12                	push   $0x12
  jmp __alltraps
c0101e43:	e9 d5 09 00 00       	jmp    c010281d <__alltraps>

c0101e48 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e48:	6a 00                	push   $0x0
  pushl $19
c0101e4a:	6a 13                	push   $0x13
  jmp __alltraps
c0101e4c:	e9 cc 09 00 00       	jmp    c010281d <__alltraps>

c0101e51 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e51:	6a 00                	push   $0x0
  pushl $20
c0101e53:	6a 14                	push   $0x14
  jmp __alltraps
c0101e55:	e9 c3 09 00 00       	jmp    c010281d <__alltraps>

c0101e5a <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e5a:	6a 00                	push   $0x0
  pushl $21
c0101e5c:	6a 15                	push   $0x15
  jmp __alltraps
c0101e5e:	e9 ba 09 00 00       	jmp    c010281d <__alltraps>

c0101e63 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e63:	6a 00                	push   $0x0
  pushl $22
c0101e65:	6a 16                	push   $0x16
  jmp __alltraps
c0101e67:	e9 b1 09 00 00       	jmp    c010281d <__alltraps>

c0101e6c <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e6c:	6a 00                	push   $0x0
  pushl $23
c0101e6e:	6a 17                	push   $0x17
  jmp __alltraps
c0101e70:	e9 a8 09 00 00       	jmp    c010281d <__alltraps>

c0101e75 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e75:	6a 00                	push   $0x0
  pushl $24
c0101e77:	6a 18                	push   $0x18
  jmp __alltraps
c0101e79:	e9 9f 09 00 00       	jmp    c010281d <__alltraps>

c0101e7e <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e7e:	6a 00                	push   $0x0
  pushl $25
c0101e80:	6a 19                	push   $0x19
  jmp __alltraps
c0101e82:	e9 96 09 00 00       	jmp    c010281d <__alltraps>

c0101e87 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e87:	6a 00                	push   $0x0
  pushl $26
c0101e89:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e8b:	e9 8d 09 00 00       	jmp    c010281d <__alltraps>

c0101e90 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e90:	6a 00                	push   $0x0
  pushl $27
c0101e92:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e94:	e9 84 09 00 00       	jmp    c010281d <__alltraps>

c0101e99 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e99:	6a 00                	push   $0x0
  pushl $28
c0101e9b:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101e9d:	e9 7b 09 00 00       	jmp    c010281d <__alltraps>

c0101ea2 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101ea2:	6a 00                	push   $0x0
  pushl $29
c0101ea4:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101ea6:	e9 72 09 00 00       	jmp    c010281d <__alltraps>

c0101eab <vector30>:
.globl vector30
vector30:
  pushl $0
c0101eab:	6a 00                	push   $0x0
  pushl $30
c0101ead:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101eaf:	e9 69 09 00 00       	jmp    c010281d <__alltraps>

c0101eb4 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101eb4:	6a 00                	push   $0x0
  pushl $31
c0101eb6:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101eb8:	e9 60 09 00 00       	jmp    c010281d <__alltraps>

c0101ebd <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ebd:	6a 00                	push   $0x0
  pushl $32
c0101ebf:	6a 20                	push   $0x20
  jmp __alltraps
c0101ec1:	e9 57 09 00 00       	jmp    c010281d <__alltraps>

c0101ec6 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ec6:	6a 00                	push   $0x0
  pushl $33
c0101ec8:	6a 21                	push   $0x21
  jmp __alltraps
c0101eca:	e9 4e 09 00 00       	jmp    c010281d <__alltraps>

c0101ecf <vector34>:
.globl vector34
vector34:
  pushl $0
c0101ecf:	6a 00                	push   $0x0
  pushl $34
c0101ed1:	6a 22                	push   $0x22
  jmp __alltraps
c0101ed3:	e9 45 09 00 00       	jmp    c010281d <__alltraps>

c0101ed8 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ed8:	6a 00                	push   $0x0
  pushl $35
c0101eda:	6a 23                	push   $0x23
  jmp __alltraps
c0101edc:	e9 3c 09 00 00       	jmp    c010281d <__alltraps>

c0101ee1 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ee1:	6a 00                	push   $0x0
  pushl $36
c0101ee3:	6a 24                	push   $0x24
  jmp __alltraps
c0101ee5:	e9 33 09 00 00       	jmp    c010281d <__alltraps>

c0101eea <vector37>:
.globl vector37
vector37:
  pushl $0
c0101eea:	6a 00                	push   $0x0
  pushl $37
c0101eec:	6a 25                	push   $0x25
  jmp __alltraps
c0101eee:	e9 2a 09 00 00       	jmp    c010281d <__alltraps>

c0101ef3 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101ef3:	6a 00                	push   $0x0
  pushl $38
c0101ef5:	6a 26                	push   $0x26
  jmp __alltraps
c0101ef7:	e9 21 09 00 00       	jmp    c010281d <__alltraps>

c0101efc <vector39>:
.globl vector39
vector39:
  pushl $0
c0101efc:	6a 00                	push   $0x0
  pushl $39
c0101efe:	6a 27                	push   $0x27
  jmp __alltraps
c0101f00:	e9 18 09 00 00       	jmp    c010281d <__alltraps>

c0101f05 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f05:	6a 00                	push   $0x0
  pushl $40
c0101f07:	6a 28                	push   $0x28
  jmp __alltraps
c0101f09:	e9 0f 09 00 00       	jmp    c010281d <__alltraps>

c0101f0e <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f0e:	6a 00                	push   $0x0
  pushl $41
c0101f10:	6a 29                	push   $0x29
  jmp __alltraps
c0101f12:	e9 06 09 00 00       	jmp    c010281d <__alltraps>

c0101f17 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f17:	6a 00                	push   $0x0
  pushl $42
c0101f19:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f1b:	e9 fd 08 00 00       	jmp    c010281d <__alltraps>

c0101f20 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f20:	6a 00                	push   $0x0
  pushl $43
c0101f22:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f24:	e9 f4 08 00 00       	jmp    c010281d <__alltraps>

c0101f29 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f29:	6a 00                	push   $0x0
  pushl $44
c0101f2b:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f2d:	e9 eb 08 00 00       	jmp    c010281d <__alltraps>

c0101f32 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f32:	6a 00                	push   $0x0
  pushl $45
c0101f34:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f36:	e9 e2 08 00 00       	jmp    c010281d <__alltraps>

c0101f3b <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f3b:	6a 00                	push   $0x0
  pushl $46
c0101f3d:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f3f:	e9 d9 08 00 00       	jmp    c010281d <__alltraps>

c0101f44 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f44:	6a 00                	push   $0x0
  pushl $47
c0101f46:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f48:	e9 d0 08 00 00       	jmp    c010281d <__alltraps>

c0101f4d <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f4d:	6a 00                	push   $0x0
  pushl $48
c0101f4f:	6a 30                	push   $0x30
  jmp __alltraps
c0101f51:	e9 c7 08 00 00       	jmp    c010281d <__alltraps>

c0101f56 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f56:	6a 00                	push   $0x0
  pushl $49
c0101f58:	6a 31                	push   $0x31
  jmp __alltraps
c0101f5a:	e9 be 08 00 00       	jmp    c010281d <__alltraps>

c0101f5f <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f5f:	6a 00                	push   $0x0
  pushl $50
c0101f61:	6a 32                	push   $0x32
  jmp __alltraps
c0101f63:	e9 b5 08 00 00       	jmp    c010281d <__alltraps>

c0101f68 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f68:	6a 00                	push   $0x0
  pushl $51
c0101f6a:	6a 33                	push   $0x33
  jmp __alltraps
c0101f6c:	e9 ac 08 00 00       	jmp    c010281d <__alltraps>

c0101f71 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f71:	6a 00                	push   $0x0
  pushl $52
c0101f73:	6a 34                	push   $0x34
  jmp __alltraps
c0101f75:	e9 a3 08 00 00       	jmp    c010281d <__alltraps>

c0101f7a <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f7a:	6a 00                	push   $0x0
  pushl $53
c0101f7c:	6a 35                	push   $0x35
  jmp __alltraps
c0101f7e:	e9 9a 08 00 00       	jmp    c010281d <__alltraps>

c0101f83 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f83:	6a 00                	push   $0x0
  pushl $54
c0101f85:	6a 36                	push   $0x36
  jmp __alltraps
c0101f87:	e9 91 08 00 00       	jmp    c010281d <__alltraps>

c0101f8c <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f8c:	6a 00                	push   $0x0
  pushl $55
c0101f8e:	6a 37                	push   $0x37
  jmp __alltraps
c0101f90:	e9 88 08 00 00       	jmp    c010281d <__alltraps>

c0101f95 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f95:	6a 00                	push   $0x0
  pushl $56
c0101f97:	6a 38                	push   $0x38
  jmp __alltraps
c0101f99:	e9 7f 08 00 00       	jmp    c010281d <__alltraps>

c0101f9e <vector57>:
.globl vector57
vector57:
  pushl $0
c0101f9e:	6a 00                	push   $0x0
  pushl $57
c0101fa0:	6a 39                	push   $0x39
  jmp __alltraps
c0101fa2:	e9 76 08 00 00       	jmp    c010281d <__alltraps>

c0101fa7 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fa7:	6a 00                	push   $0x0
  pushl $58
c0101fa9:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fab:	e9 6d 08 00 00       	jmp    c010281d <__alltraps>

c0101fb0 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fb0:	6a 00                	push   $0x0
  pushl $59
c0101fb2:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fb4:	e9 64 08 00 00       	jmp    c010281d <__alltraps>

c0101fb9 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fb9:	6a 00                	push   $0x0
  pushl $60
c0101fbb:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fbd:	e9 5b 08 00 00       	jmp    c010281d <__alltraps>

c0101fc2 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fc2:	6a 00                	push   $0x0
  pushl $61
c0101fc4:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fc6:	e9 52 08 00 00       	jmp    c010281d <__alltraps>

c0101fcb <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fcb:	6a 00                	push   $0x0
  pushl $62
c0101fcd:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fcf:	e9 49 08 00 00       	jmp    c010281d <__alltraps>

c0101fd4 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fd4:	6a 00                	push   $0x0
  pushl $63
c0101fd6:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fd8:	e9 40 08 00 00       	jmp    c010281d <__alltraps>

c0101fdd <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fdd:	6a 00                	push   $0x0
  pushl $64
c0101fdf:	6a 40                	push   $0x40
  jmp __alltraps
c0101fe1:	e9 37 08 00 00       	jmp    c010281d <__alltraps>

c0101fe6 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fe6:	6a 00                	push   $0x0
  pushl $65
c0101fe8:	6a 41                	push   $0x41
  jmp __alltraps
c0101fea:	e9 2e 08 00 00       	jmp    c010281d <__alltraps>

c0101fef <vector66>:
.globl vector66
vector66:
  pushl $0
c0101fef:	6a 00                	push   $0x0
  pushl $66
c0101ff1:	6a 42                	push   $0x42
  jmp __alltraps
c0101ff3:	e9 25 08 00 00       	jmp    c010281d <__alltraps>

c0101ff8 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101ff8:	6a 00                	push   $0x0
  pushl $67
c0101ffa:	6a 43                	push   $0x43
  jmp __alltraps
c0101ffc:	e9 1c 08 00 00       	jmp    c010281d <__alltraps>

c0102001 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102001:	6a 00                	push   $0x0
  pushl $68
c0102003:	6a 44                	push   $0x44
  jmp __alltraps
c0102005:	e9 13 08 00 00       	jmp    c010281d <__alltraps>

c010200a <vector69>:
.globl vector69
vector69:
  pushl $0
c010200a:	6a 00                	push   $0x0
  pushl $69
c010200c:	6a 45                	push   $0x45
  jmp __alltraps
c010200e:	e9 0a 08 00 00       	jmp    c010281d <__alltraps>

c0102013 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102013:	6a 00                	push   $0x0
  pushl $70
c0102015:	6a 46                	push   $0x46
  jmp __alltraps
c0102017:	e9 01 08 00 00       	jmp    c010281d <__alltraps>

c010201c <vector71>:
.globl vector71
vector71:
  pushl $0
c010201c:	6a 00                	push   $0x0
  pushl $71
c010201e:	6a 47                	push   $0x47
  jmp __alltraps
c0102020:	e9 f8 07 00 00       	jmp    c010281d <__alltraps>

c0102025 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102025:	6a 00                	push   $0x0
  pushl $72
c0102027:	6a 48                	push   $0x48
  jmp __alltraps
c0102029:	e9 ef 07 00 00       	jmp    c010281d <__alltraps>

c010202e <vector73>:
.globl vector73
vector73:
  pushl $0
c010202e:	6a 00                	push   $0x0
  pushl $73
c0102030:	6a 49                	push   $0x49
  jmp __alltraps
c0102032:	e9 e6 07 00 00       	jmp    c010281d <__alltraps>

c0102037 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102037:	6a 00                	push   $0x0
  pushl $74
c0102039:	6a 4a                	push   $0x4a
  jmp __alltraps
c010203b:	e9 dd 07 00 00       	jmp    c010281d <__alltraps>

c0102040 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102040:	6a 00                	push   $0x0
  pushl $75
c0102042:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102044:	e9 d4 07 00 00       	jmp    c010281d <__alltraps>

c0102049 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $76
c010204b:	6a 4c                	push   $0x4c
  jmp __alltraps
c010204d:	e9 cb 07 00 00       	jmp    c010281d <__alltraps>

c0102052 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102052:	6a 00                	push   $0x0
  pushl $77
c0102054:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102056:	e9 c2 07 00 00       	jmp    c010281d <__alltraps>

c010205b <vector78>:
.globl vector78
vector78:
  pushl $0
c010205b:	6a 00                	push   $0x0
  pushl $78
c010205d:	6a 4e                	push   $0x4e
  jmp __alltraps
c010205f:	e9 b9 07 00 00       	jmp    c010281d <__alltraps>

c0102064 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102064:	6a 00                	push   $0x0
  pushl $79
c0102066:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102068:	e9 b0 07 00 00       	jmp    c010281d <__alltraps>

c010206d <vector80>:
.globl vector80
vector80:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $80
c010206f:	6a 50                	push   $0x50
  jmp __alltraps
c0102071:	e9 a7 07 00 00       	jmp    c010281d <__alltraps>

c0102076 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102076:	6a 00                	push   $0x0
  pushl $81
c0102078:	6a 51                	push   $0x51
  jmp __alltraps
c010207a:	e9 9e 07 00 00       	jmp    c010281d <__alltraps>

c010207f <vector82>:
.globl vector82
vector82:
  pushl $0
c010207f:	6a 00                	push   $0x0
  pushl $82
c0102081:	6a 52                	push   $0x52
  jmp __alltraps
c0102083:	e9 95 07 00 00       	jmp    c010281d <__alltraps>

c0102088 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102088:	6a 00                	push   $0x0
  pushl $83
c010208a:	6a 53                	push   $0x53
  jmp __alltraps
c010208c:	e9 8c 07 00 00       	jmp    c010281d <__alltraps>

c0102091 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $84
c0102093:	6a 54                	push   $0x54
  jmp __alltraps
c0102095:	e9 83 07 00 00       	jmp    c010281d <__alltraps>

c010209a <vector85>:
.globl vector85
vector85:
  pushl $0
c010209a:	6a 00                	push   $0x0
  pushl $85
c010209c:	6a 55                	push   $0x55
  jmp __alltraps
c010209e:	e9 7a 07 00 00       	jmp    c010281d <__alltraps>

c01020a3 <vector86>:
.globl vector86
vector86:
  pushl $0
c01020a3:	6a 00                	push   $0x0
  pushl $86
c01020a5:	6a 56                	push   $0x56
  jmp __alltraps
c01020a7:	e9 71 07 00 00       	jmp    c010281d <__alltraps>

c01020ac <vector87>:
.globl vector87
vector87:
  pushl $0
c01020ac:	6a 00                	push   $0x0
  pushl $87
c01020ae:	6a 57                	push   $0x57
  jmp __alltraps
c01020b0:	e9 68 07 00 00       	jmp    c010281d <__alltraps>

c01020b5 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $88
c01020b7:	6a 58                	push   $0x58
  jmp __alltraps
c01020b9:	e9 5f 07 00 00       	jmp    c010281d <__alltraps>

c01020be <vector89>:
.globl vector89
vector89:
  pushl $0
c01020be:	6a 00                	push   $0x0
  pushl $89
c01020c0:	6a 59                	push   $0x59
  jmp __alltraps
c01020c2:	e9 56 07 00 00       	jmp    c010281d <__alltraps>

c01020c7 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020c7:	6a 00                	push   $0x0
  pushl $90
c01020c9:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020cb:	e9 4d 07 00 00       	jmp    c010281d <__alltraps>

c01020d0 <vector91>:
.globl vector91
vector91:
  pushl $0
c01020d0:	6a 00                	push   $0x0
  pushl $91
c01020d2:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020d4:	e9 44 07 00 00       	jmp    c010281d <__alltraps>

c01020d9 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $92
c01020db:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020dd:	e9 3b 07 00 00       	jmp    c010281d <__alltraps>

c01020e2 <vector93>:
.globl vector93
vector93:
  pushl $0
c01020e2:	6a 00                	push   $0x0
  pushl $93
c01020e4:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020e6:	e9 32 07 00 00       	jmp    c010281d <__alltraps>

c01020eb <vector94>:
.globl vector94
vector94:
  pushl $0
c01020eb:	6a 00                	push   $0x0
  pushl $94
c01020ed:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020ef:	e9 29 07 00 00       	jmp    c010281d <__alltraps>

c01020f4 <vector95>:
.globl vector95
vector95:
  pushl $0
c01020f4:	6a 00                	push   $0x0
  pushl $95
c01020f6:	6a 5f                	push   $0x5f
  jmp __alltraps
c01020f8:	e9 20 07 00 00       	jmp    c010281d <__alltraps>

c01020fd <vector96>:
.globl vector96
vector96:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $96
c01020ff:	6a 60                	push   $0x60
  jmp __alltraps
c0102101:	e9 17 07 00 00       	jmp    c010281d <__alltraps>

c0102106 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102106:	6a 00                	push   $0x0
  pushl $97
c0102108:	6a 61                	push   $0x61
  jmp __alltraps
c010210a:	e9 0e 07 00 00       	jmp    c010281d <__alltraps>

c010210f <vector98>:
.globl vector98
vector98:
  pushl $0
c010210f:	6a 00                	push   $0x0
  pushl $98
c0102111:	6a 62                	push   $0x62
  jmp __alltraps
c0102113:	e9 05 07 00 00       	jmp    c010281d <__alltraps>

c0102118 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102118:	6a 00                	push   $0x0
  pushl $99
c010211a:	6a 63                	push   $0x63
  jmp __alltraps
c010211c:	e9 fc 06 00 00       	jmp    c010281d <__alltraps>

c0102121 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $100
c0102123:	6a 64                	push   $0x64
  jmp __alltraps
c0102125:	e9 f3 06 00 00       	jmp    c010281d <__alltraps>

c010212a <vector101>:
.globl vector101
vector101:
  pushl $0
c010212a:	6a 00                	push   $0x0
  pushl $101
c010212c:	6a 65                	push   $0x65
  jmp __alltraps
c010212e:	e9 ea 06 00 00       	jmp    c010281d <__alltraps>

c0102133 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102133:	6a 00                	push   $0x0
  pushl $102
c0102135:	6a 66                	push   $0x66
  jmp __alltraps
c0102137:	e9 e1 06 00 00       	jmp    c010281d <__alltraps>

c010213c <vector103>:
.globl vector103
vector103:
  pushl $0
c010213c:	6a 00                	push   $0x0
  pushl $103
c010213e:	6a 67                	push   $0x67
  jmp __alltraps
c0102140:	e9 d8 06 00 00       	jmp    c010281d <__alltraps>

c0102145 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $104
c0102147:	6a 68                	push   $0x68
  jmp __alltraps
c0102149:	e9 cf 06 00 00       	jmp    c010281d <__alltraps>

c010214e <vector105>:
.globl vector105
vector105:
  pushl $0
c010214e:	6a 00                	push   $0x0
  pushl $105
c0102150:	6a 69                	push   $0x69
  jmp __alltraps
c0102152:	e9 c6 06 00 00       	jmp    c010281d <__alltraps>

c0102157 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102157:	6a 00                	push   $0x0
  pushl $106
c0102159:	6a 6a                	push   $0x6a
  jmp __alltraps
c010215b:	e9 bd 06 00 00       	jmp    c010281d <__alltraps>

c0102160 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102160:	6a 00                	push   $0x0
  pushl $107
c0102162:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102164:	e9 b4 06 00 00       	jmp    c010281d <__alltraps>

c0102169 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $108
c010216b:	6a 6c                	push   $0x6c
  jmp __alltraps
c010216d:	e9 ab 06 00 00       	jmp    c010281d <__alltraps>

c0102172 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102172:	6a 00                	push   $0x0
  pushl $109
c0102174:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102176:	e9 a2 06 00 00       	jmp    c010281d <__alltraps>

c010217b <vector110>:
.globl vector110
vector110:
  pushl $0
c010217b:	6a 00                	push   $0x0
  pushl $110
c010217d:	6a 6e                	push   $0x6e
  jmp __alltraps
c010217f:	e9 99 06 00 00       	jmp    c010281d <__alltraps>

c0102184 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102184:	6a 00                	push   $0x0
  pushl $111
c0102186:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102188:	e9 90 06 00 00       	jmp    c010281d <__alltraps>

c010218d <vector112>:
.globl vector112
vector112:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $112
c010218f:	6a 70                	push   $0x70
  jmp __alltraps
c0102191:	e9 87 06 00 00       	jmp    c010281d <__alltraps>

c0102196 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102196:	6a 00                	push   $0x0
  pushl $113
c0102198:	6a 71                	push   $0x71
  jmp __alltraps
c010219a:	e9 7e 06 00 00       	jmp    c010281d <__alltraps>

c010219f <vector114>:
.globl vector114
vector114:
  pushl $0
c010219f:	6a 00                	push   $0x0
  pushl $114
c01021a1:	6a 72                	push   $0x72
  jmp __alltraps
c01021a3:	e9 75 06 00 00       	jmp    c010281d <__alltraps>

c01021a8 <vector115>:
.globl vector115
vector115:
  pushl $0
c01021a8:	6a 00                	push   $0x0
  pushl $115
c01021aa:	6a 73                	push   $0x73
  jmp __alltraps
c01021ac:	e9 6c 06 00 00       	jmp    c010281d <__alltraps>

c01021b1 <vector116>:
.globl vector116
vector116:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $116
c01021b3:	6a 74                	push   $0x74
  jmp __alltraps
c01021b5:	e9 63 06 00 00       	jmp    c010281d <__alltraps>

c01021ba <vector117>:
.globl vector117
vector117:
  pushl $0
c01021ba:	6a 00                	push   $0x0
  pushl $117
c01021bc:	6a 75                	push   $0x75
  jmp __alltraps
c01021be:	e9 5a 06 00 00       	jmp    c010281d <__alltraps>

c01021c3 <vector118>:
.globl vector118
vector118:
  pushl $0
c01021c3:	6a 00                	push   $0x0
  pushl $118
c01021c5:	6a 76                	push   $0x76
  jmp __alltraps
c01021c7:	e9 51 06 00 00       	jmp    c010281d <__alltraps>

c01021cc <vector119>:
.globl vector119
vector119:
  pushl $0
c01021cc:	6a 00                	push   $0x0
  pushl $119
c01021ce:	6a 77                	push   $0x77
  jmp __alltraps
c01021d0:	e9 48 06 00 00       	jmp    c010281d <__alltraps>

c01021d5 <vector120>:
.globl vector120
vector120:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $120
c01021d7:	6a 78                	push   $0x78
  jmp __alltraps
c01021d9:	e9 3f 06 00 00       	jmp    c010281d <__alltraps>

c01021de <vector121>:
.globl vector121
vector121:
  pushl $0
c01021de:	6a 00                	push   $0x0
  pushl $121
c01021e0:	6a 79                	push   $0x79
  jmp __alltraps
c01021e2:	e9 36 06 00 00       	jmp    c010281d <__alltraps>

c01021e7 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021e7:	6a 00                	push   $0x0
  pushl $122
c01021e9:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021eb:	e9 2d 06 00 00       	jmp    c010281d <__alltraps>

c01021f0 <vector123>:
.globl vector123
vector123:
  pushl $0
c01021f0:	6a 00                	push   $0x0
  pushl $123
c01021f2:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021f4:	e9 24 06 00 00       	jmp    c010281d <__alltraps>

c01021f9 <vector124>:
.globl vector124
vector124:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $124
c01021fb:	6a 7c                	push   $0x7c
  jmp __alltraps
c01021fd:	e9 1b 06 00 00       	jmp    c010281d <__alltraps>

c0102202 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102202:	6a 00                	push   $0x0
  pushl $125
c0102204:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102206:	e9 12 06 00 00       	jmp    c010281d <__alltraps>

c010220b <vector126>:
.globl vector126
vector126:
  pushl $0
c010220b:	6a 00                	push   $0x0
  pushl $126
c010220d:	6a 7e                	push   $0x7e
  jmp __alltraps
c010220f:	e9 09 06 00 00       	jmp    c010281d <__alltraps>

c0102214 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $127
c0102216:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102218:	e9 00 06 00 00       	jmp    c010281d <__alltraps>

c010221d <vector128>:
.globl vector128
vector128:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $128
c010221f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102224:	e9 f4 05 00 00       	jmp    c010281d <__alltraps>

c0102229 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102229:	6a 00                	push   $0x0
  pushl $129
c010222b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102230:	e9 e8 05 00 00       	jmp    c010281d <__alltraps>

c0102235 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $130
c0102237:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010223c:	e9 dc 05 00 00       	jmp    c010281d <__alltraps>

c0102241 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $131
c0102243:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102248:	e9 d0 05 00 00       	jmp    c010281d <__alltraps>

c010224d <vector132>:
.globl vector132
vector132:
  pushl $0
c010224d:	6a 00                	push   $0x0
  pushl $132
c010224f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102254:	e9 c4 05 00 00       	jmp    c010281d <__alltraps>

c0102259 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $133
c010225b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102260:	e9 b8 05 00 00       	jmp    c010281d <__alltraps>

c0102265 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $134
c0102267:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010226c:	e9 ac 05 00 00       	jmp    c010281d <__alltraps>

c0102271 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102271:	6a 00                	push   $0x0
  pushl $135
c0102273:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102278:	e9 a0 05 00 00       	jmp    c010281d <__alltraps>

c010227d <vector136>:
.globl vector136
vector136:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $136
c010227f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102284:	e9 94 05 00 00       	jmp    c010281d <__alltraps>

c0102289 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $137
c010228b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102290:	e9 88 05 00 00       	jmp    c010281d <__alltraps>

c0102295 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102295:	6a 00                	push   $0x0
  pushl $138
c0102297:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010229c:	e9 7c 05 00 00       	jmp    c010281d <__alltraps>

c01022a1 <vector139>:
.globl vector139
vector139:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $139
c01022a3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022a8:	e9 70 05 00 00       	jmp    c010281d <__alltraps>

c01022ad <vector140>:
.globl vector140
vector140:
  pushl $0
c01022ad:	6a 00                	push   $0x0
  pushl $140
c01022af:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022b4:	e9 64 05 00 00       	jmp    c010281d <__alltraps>

c01022b9 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022b9:	6a 00                	push   $0x0
  pushl $141
c01022bb:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022c0:	e9 58 05 00 00       	jmp    c010281d <__alltraps>

c01022c5 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $142
c01022c7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022cc:	e9 4c 05 00 00       	jmp    c010281d <__alltraps>

c01022d1 <vector143>:
.globl vector143
vector143:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $143
c01022d3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022d8:	e9 40 05 00 00       	jmp    c010281d <__alltraps>

c01022dd <vector144>:
.globl vector144
vector144:
  pushl $0
c01022dd:	6a 00                	push   $0x0
  pushl $144
c01022df:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022e4:	e9 34 05 00 00       	jmp    c010281d <__alltraps>

c01022e9 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $145
c01022eb:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022f0:	e9 28 05 00 00       	jmp    c010281d <__alltraps>

c01022f5 <vector146>:
.globl vector146
vector146:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $146
c01022f7:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01022fc:	e9 1c 05 00 00       	jmp    c010281d <__alltraps>

c0102301 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102301:	6a 00                	push   $0x0
  pushl $147
c0102303:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102308:	e9 10 05 00 00       	jmp    c010281d <__alltraps>

c010230d <vector148>:
.globl vector148
vector148:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $148
c010230f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102314:	e9 04 05 00 00       	jmp    c010281d <__alltraps>

c0102319 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $149
c010231b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102320:	e9 f8 04 00 00       	jmp    c010281d <__alltraps>

c0102325 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102325:	6a 00                	push   $0x0
  pushl $150
c0102327:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010232c:	e9 ec 04 00 00       	jmp    c010281d <__alltraps>

c0102331 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $151
c0102333:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102338:	e9 e0 04 00 00       	jmp    c010281d <__alltraps>

c010233d <vector152>:
.globl vector152
vector152:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $152
c010233f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102344:	e9 d4 04 00 00       	jmp    c010281d <__alltraps>

c0102349 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102349:	6a 00                	push   $0x0
  pushl $153
c010234b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102350:	e9 c8 04 00 00       	jmp    c010281d <__alltraps>

c0102355 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $154
c0102357:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010235c:	e9 bc 04 00 00       	jmp    c010281d <__alltraps>

c0102361 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $155
c0102363:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102368:	e9 b0 04 00 00       	jmp    c010281d <__alltraps>

c010236d <vector156>:
.globl vector156
vector156:
  pushl $0
c010236d:	6a 00                	push   $0x0
  pushl $156
c010236f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102374:	e9 a4 04 00 00       	jmp    c010281d <__alltraps>

c0102379 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $157
c010237b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102380:	e9 98 04 00 00       	jmp    c010281d <__alltraps>

c0102385 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $158
c0102387:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010238c:	e9 8c 04 00 00       	jmp    c010281d <__alltraps>

c0102391 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102391:	6a 00                	push   $0x0
  pushl $159
c0102393:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102398:	e9 80 04 00 00       	jmp    c010281d <__alltraps>

c010239d <vector160>:
.globl vector160
vector160:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $160
c010239f:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023a4:	e9 74 04 00 00       	jmp    c010281d <__alltraps>

c01023a9 <vector161>:
.globl vector161
vector161:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $161
c01023ab:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023b0:	e9 68 04 00 00       	jmp    c010281d <__alltraps>

c01023b5 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023b5:	6a 00                	push   $0x0
  pushl $162
c01023b7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023bc:	e9 5c 04 00 00       	jmp    c010281d <__alltraps>

c01023c1 <vector163>:
.globl vector163
vector163:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $163
c01023c3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023c8:	e9 50 04 00 00       	jmp    c010281d <__alltraps>

c01023cd <vector164>:
.globl vector164
vector164:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $164
c01023cf:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023d4:	e9 44 04 00 00       	jmp    c010281d <__alltraps>

c01023d9 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023d9:	6a 00                	push   $0x0
  pushl $165
c01023db:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023e0:	e9 38 04 00 00       	jmp    c010281d <__alltraps>

c01023e5 <vector166>:
.globl vector166
vector166:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $166
c01023e7:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023ec:	e9 2c 04 00 00       	jmp    c010281d <__alltraps>

c01023f1 <vector167>:
.globl vector167
vector167:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $167
c01023f3:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01023f8:	e9 20 04 00 00       	jmp    c010281d <__alltraps>

c01023fd <vector168>:
.globl vector168
vector168:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $168
c01023ff:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102404:	e9 14 04 00 00       	jmp    c010281d <__alltraps>

c0102409 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $169
c010240b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102410:	e9 08 04 00 00       	jmp    c010281d <__alltraps>

c0102415 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $170
c0102417:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010241c:	e9 fc 03 00 00       	jmp    c010281d <__alltraps>

c0102421 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $171
c0102423:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102428:	e9 f0 03 00 00       	jmp    c010281d <__alltraps>

c010242d <vector172>:
.globl vector172
vector172:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $172
c010242f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102434:	e9 e4 03 00 00       	jmp    c010281d <__alltraps>

c0102439 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $173
c010243b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102440:	e9 d8 03 00 00       	jmp    c010281d <__alltraps>

c0102445 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $174
c0102447:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010244c:	e9 cc 03 00 00       	jmp    c010281d <__alltraps>

c0102451 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $175
c0102453:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102458:	e9 c0 03 00 00       	jmp    c010281d <__alltraps>

c010245d <vector176>:
.globl vector176
vector176:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $176
c010245f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102464:	e9 b4 03 00 00       	jmp    c010281d <__alltraps>

c0102469 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $177
c010246b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102470:	e9 a8 03 00 00       	jmp    c010281d <__alltraps>

c0102475 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $178
c0102477:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010247c:	e9 9c 03 00 00       	jmp    c010281d <__alltraps>

c0102481 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $179
c0102483:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102488:	e9 90 03 00 00       	jmp    c010281d <__alltraps>

c010248d <vector180>:
.globl vector180
vector180:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $180
c010248f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102494:	e9 84 03 00 00       	jmp    c010281d <__alltraps>

c0102499 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $181
c010249b:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024a0:	e9 78 03 00 00       	jmp    c010281d <__alltraps>

c01024a5 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $182
c01024a7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024ac:	e9 6c 03 00 00       	jmp    c010281d <__alltraps>

c01024b1 <vector183>:
.globl vector183
vector183:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $183
c01024b3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024b8:	e9 60 03 00 00       	jmp    c010281d <__alltraps>

c01024bd <vector184>:
.globl vector184
vector184:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $184
c01024bf:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024c4:	e9 54 03 00 00       	jmp    c010281d <__alltraps>

c01024c9 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $185
c01024cb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024d0:	e9 48 03 00 00       	jmp    c010281d <__alltraps>

c01024d5 <vector186>:
.globl vector186
vector186:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $186
c01024d7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024dc:	e9 3c 03 00 00       	jmp    c010281d <__alltraps>

c01024e1 <vector187>:
.globl vector187
vector187:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $187
c01024e3:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024e8:	e9 30 03 00 00       	jmp    c010281d <__alltraps>

c01024ed <vector188>:
.globl vector188
vector188:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $188
c01024ef:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024f4:	e9 24 03 00 00       	jmp    c010281d <__alltraps>

c01024f9 <vector189>:
.globl vector189
vector189:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $189
c01024fb:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102500:	e9 18 03 00 00       	jmp    c010281d <__alltraps>

c0102505 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $190
c0102507:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010250c:	e9 0c 03 00 00       	jmp    c010281d <__alltraps>

c0102511 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $191
c0102513:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102518:	e9 00 03 00 00       	jmp    c010281d <__alltraps>

c010251d <vector192>:
.globl vector192
vector192:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $192
c010251f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102524:	e9 f4 02 00 00       	jmp    c010281d <__alltraps>

c0102529 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $193
c010252b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102530:	e9 e8 02 00 00       	jmp    c010281d <__alltraps>

c0102535 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $194
c0102537:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010253c:	e9 dc 02 00 00       	jmp    c010281d <__alltraps>

c0102541 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $195
c0102543:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102548:	e9 d0 02 00 00       	jmp    c010281d <__alltraps>

c010254d <vector196>:
.globl vector196
vector196:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $196
c010254f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102554:	e9 c4 02 00 00       	jmp    c010281d <__alltraps>

c0102559 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $197
c010255b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102560:	e9 b8 02 00 00       	jmp    c010281d <__alltraps>

c0102565 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $198
c0102567:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010256c:	e9 ac 02 00 00       	jmp    c010281d <__alltraps>

c0102571 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $199
c0102573:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102578:	e9 a0 02 00 00       	jmp    c010281d <__alltraps>

c010257d <vector200>:
.globl vector200
vector200:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $200
c010257f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102584:	e9 94 02 00 00       	jmp    c010281d <__alltraps>

c0102589 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $201
c010258b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102590:	e9 88 02 00 00       	jmp    c010281d <__alltraps>

c0102595 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $202
c0102597:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010259c:	e9 7c 02 00 00       	jmp    c010281d <__alltraps>

c01025a1 <vector203>:
.globl vector203
vector203:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $203
c01025a3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025a8:	e9 70 02 00 00       	jmp    c010281d <__alltraps>

c01025ad <vector204>:
.globl vector204
vector204:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $204
c01025af:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025b4:	e9 64 02 00 00       	jmp    c010281d <__alltraps>

c01025b9 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $205
c01025bb:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025c0:	e9 58 02 00 00       	jmp    c010281d <__alltraps>

c01025c5 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $206
c01025c7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025cc:	e9 4c 02 00 00       	jmp    c010281d <__alltraps>

c01025d1 <vector207>:
.globl vector207
vector207:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $207
c01025d3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025d8:	e9 40 02 00 00       	jmp    c010281d <__alltraps>

c01025dd <vector208>:
.globl vector208
vector208:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $208
c01025df:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025e4:	e9 34 02 00 00       	jmp    c010281d <__alltraps>

c01025e9 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $209
c01025eb:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025f0:	e9 28 02 00 00       	jmp    c010281d <__alltraps>

c01025f5 <vector210>:
.globl vector210
vector210:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $210
c01025f7:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01025fc:	e9 1c 02 00 00       	jmp    c010281d <__alltraps>

c0102601 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $211
c0102603:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102608:	e9 10 02 00 00       	jmp    c010281d <__alltraps>

c010260d <vector212>:
.globl vector212
vector212:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $212
c010260f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102614:	e9 04 02 00 00       	jmp    c010281d <__alltraps>

c0102619 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $213
c010261b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102620:	e9 f8 01 00 00       	jmp    c010281d <__alltraps>

c0102625 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $214
c0102627:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010262c:	e9 ec 01 00 00       	jmp    c010281d <__alltraps>

c0102631 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $215
c0102633:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102638:	e9 e0 01 00 00       	jmp    c010281d <__alltraps>

c010263d <vector216>:
.globl vector216
vector216:
  pushl $0
c010263d:	6a 00                	push   $0x0
  pushl $216
c010263f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102644:	e9 d4 01 00 00       	jmp    c010281d <__alltraps>

c0102649 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102649:	6a 00                	push   $0x0
  pushl $217
c010264b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102650:	e9 c8 01 00 00       	jmp    c010281d <__alltraps>

c0102655 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102655:	6a 00                	push   $0x0
  pushl $218
c0102657:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010265c:	e9 bc 01 00 00       	jmp    c010281d <__alltraps>

c0102661 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102661:	6a 00                	push   $0x0
  pushl $219
c0102663:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102668:	e9 b0 01 00 00       	jmp    c010281d <__alltraps>

c010266d <vector220>:
.globl vector220
vector220:
  pushl $0
c010266d:	6a 00                	push   $0x0
  pushl $220
c010266f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102674:	e9 a4 01 00 00       	jmp    c010281d <__alltraps>

c0102679 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102679:	6a 00                	push   $0x0
  pushl $221
c010267b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102680:	e9 98 01 00 00       	jmp    c010281d <__alltraps>

c0102685 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102685:	6a 00                	push   $0x0
  pushl $222
c0102687:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010268c:	e9 8c 01 00 00       	jmp    c010281d <__alltraps>

c0102691 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102691:	6a 00                	push   $0x0
  pushl $223
c0102693:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102698:	e9 80 01 00 00       	jmp    c010281d <__alltraps>

c010269d <vector224>:
.globl vector224
vector224:
  pushl $0
c010269d:	6a 00                	push   $0x0
  pushl $224
c010269f:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026a4:	e9 74 01 00 00       	jmp    c010281d <__alltraps>

c01026a9 <vector225>:
.globl vector225
vector225:
  pushl $0
c01026a9:	6a 00                	push   $0x0
  pushl $225
c01026ab:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026b0:	e9 68 01 00 00       	jmp    c010281d <__alltraps>

c01026b5 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026b5:	6a 00                	push   $0x0
  pushl $226
c01026b7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026bc:	e9 5c 01 00 00       	jmp    c010281d <__alltraps>

c01026c1 <vector227>:
.globl vector227
vector227:
  pushl $0
c01026c1:	6a 00                	push   $0x0
  pushl $227
c01026c3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026c8:	e9 50 01 00 00       	jmp    c010281d <__alltraps>

c01026cd <vector228>:
.globl vector228
vector228:
  pushl $0
c01026cd:	6a 00                	push   $0x0
  pushl $228
c01026cf:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026d4:	e9 44 01 00 00       	jmp    c010281d <__alltraps>

c01026d9 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026d9:	6a 00                	push   $0x0
  pushl $229
c01026db:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026e0:	e9 38 01 00 00       	jmp    c010281d <__alltraps>

c01026e5 <vector230>:
.globl vector230
vector230:
  pushl $0
c01026e5:	6a 00                	push   $0x0
  pushl $230
c01026e7:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026ec:	e9 2c 01 00 00       	jmp    c010281d <__alltraps>

c01026f1 <vector231>:
.globl vector231
vector231:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $231
c01026f3:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01026f8:	e9 20 01 00 00       	jmp    c010281d <__alltraps>

c01026fd <vector232>:
.globl vector232
vector232:
  pushl $0
c01026fd:	6a 00                	push   $0x0
  pushl $232
c01026ff:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102704:	e9 14 01 00 00       	jmp    c010281d <__alltraps>

c0102709 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102709:	6a 00                	push   $0x0
  pushl $233
c010270b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102710:	e9 08 01 00 00       	jmp    c010281d <__alltraps>

c0102715 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $234
c0102717:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010271c:	e9 fc 00 00 00       	jmp    c010281d <__alltraps>

c0102721 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102721:	6a 00                	push   $0x0
  pushl $235
c0102723:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102728:	e9 f0 00 00 00       	jmp    c010281d <__alltraps>

c010272d <vector236>:
.globl vector236
vector236:
  pushl $0
c010272d:	6a 00                	push   $0x0
  pushl $236
c010272f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102734:	e9 e4 00 00 00       	jmp    c010281d <__alltraps>

c0102739 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $237
c010273b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102740:	e9 d8 00 00 00       	jmp    c010281d <__alltraps>

c0102745 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $238
c0102747:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010274c:	e9 cc 00 00 00       	jmp    c010281d <__alltraps>

c0102751 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102751:	6a 00                	push   $0x0
  pushl $239
c0102753:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102758:	e9 c0 00 00 00       	jmp    c010281d <__alltraps>

c010275d <vector240>:
.globl vector240
vector240:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $240
c010275f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102764:	e9 b4 00 00 00       	jmp    c010281d <__alltraps>

c0102769 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $241
c010276b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102770:	e9 a8 00 00 00       	jmp    c010281d <__alltraps>

c0102775 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102775:	6a 00                	push   $0x0
  pushl $242
c0102777:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010277c:	e9 9c 00 00 00       	jmp    c010281d <__alltraps>

c0102781 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $243
c0102783:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102788:	e9 90 00 00 00       	jmp    c010281d <__alltraps>

c010278d <vector244>:
.globl vector244
vector244:
  pushl $0
c010278d:	6a 00                	push   $0x0
  pushl $244
c010278f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102794:	e9 84 00 00 00       	jmp    c010281d <__alltraps>

c0102799 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102799:	6a 00                	push   $0x0
  pushl $245
c010279b:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027a0:	e9 78 00 00 00       	jmp    c010281d <__alltraps>

c01027a5 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $246
c01027a7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027ac:	e9 6c 00 00 00       	jmp    c010281d <__alltraps>

c01027b1 <vector247>:
.globl vector247
vector247:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $247
c01027b3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027b8:	e9 60 00 00 00       	jmp    c010281d <__alltraps>

c01027bd <vector248>:
.globl vector248
vector248:
  pushl $0
c01027bd:	6a 00                	push   $0x0
  pushl $248
c01027bf:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027c4:	e9 54 00 00 00       	jmp    c010281d <__alltraps>

c01027c9 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $249
c01027cb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027d0:	e9 48 00 00 00       	jmp    c010281d <__alltraps>

c01027d5 <vector250>:
.globl vector250
vector250:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $250
c01027d7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027dc:	e9 3c 00 00 00       	jmp    c010281d <__alltraps>

c01027e1 <vector251>:
.globl vector251
vector251:
  pushl $0
c01027e1:	6a 00                	push   $0x0
  pushl $251
c01027e3:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027e8:	e9 30 00 00 00       	jmp    c010281d <__alltraps>

c01027ed <vector252>:
.globl vector252
vector252:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $252
c01027ef:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027f4:	e9 24 00 00 00       	jmp    c010281d <__alltraps>

c01027f9 <vector253>:
.globl vector253
vector253:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $253
c01027fb:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102800:	e9 18 00 00 00       	jmp    c010281d <__alltraps>

c0102805 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102805:	6a 00                	push   $0x0
  pushl $254
c0102807:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010280c:	e9 0c 00 00 00       	jmp    c010281d <__alltraps>

c0102811 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102811:	6a 00                	push   $0x0
  pushl $255
c0102813:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102818:	e9 00 00 00 00       	jmp    c010281d <__alltraps>

c010281d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010281d:	1e                   	push   %ds
    pushl %es
c010281e:	06                   	push   %es
    pushl %fs
c010281f:	0f a0                	push   %fs
    pushl %gs
c0102821:	0f a8                	push   %gs
    pushal
c0102823:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102824:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102829:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010282b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010282d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010282e:	e8 63 f5 ff ff       	call   c0101d96 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102833:	5c                   	pop    %esp

c0102834 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102834:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102835:	0f a9                	pop    %gs
    popl %fs
c0102837:	0f a1                	pop    %fs
    popl %es
c0102839:	07                   	pop    %es
    popl %ds
c010283a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010283b:	83 c4 08             	add    $0x8,%esp
    iret
c010283e:	cf                   	iret   

c010283f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010283f:	55                   	push   %ebp
c0102840:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102842:	8b 45 08             	mov    0x8(%ebp),%eax
c0102845:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c010284b:	29 d0                	sub    %edx,%eax
c010284d:	c1 f8 02             	sar    $0x2,%eax
c0102850:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102856:	5d                   	pop    %ebp
c0102857:	c3                   	ret    

c0102858 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102858:	55                   	push   %ebp
c0102859:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010285b:	ff 75 08             	pushl  0x8(%ebp)
c010285e:	e8 dc ff ff ff       	call   c010283f <page2ppn>
c0102863:	83 c4 04             	add    $0x4,%esp
c0102866:	c1 e0 0c             	shl    $0xc,%eax
}
c0102869:	c9                   	leave  
c010286a:	c3                   	ret    

c010286b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010286b:	55                   	push   %ebp
c010286c:	89 e5                	mov    %esp,%ebp
c010286e:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0102871:	8b 45 08             	mov    0x8(%ebp),%eax
c0102874:	c1 e8 0c             	shr    $0xc,%eax
c0102877:	89 c2                	mov    %eax,%edx
c0102879:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010287e:	39 c2                	cmp    %eax,%edx
c0102880:	72 14                	jb     c0102896 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0102882:	83 ec 04             	sub    $0x4,%esp
c0102885:	68 90 61 10 c0       	push   $0xc0106190
c010288a:	6a 5a                	push   $0x5a
c010288c:	68 af 61 10 c0       	push   $0xc01061af
c0102891:	e8 43 db ff ff       	call   c01003d9 <__panic>
    }
    return &pages[PPN(pa)];
c0102896:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c010289c:	8b 45 08             	mov    0x8(%ebp),%eax
c010289f:	c1 e8 0c             	shr    $0xc,%eax
c01028a2:	89 c2                	mov    %eax,%edx
c01028a4:	89 d0                	mov    %edx,%eax
c01028a6:	c1 e0 02             	shl    $0x2,%eax
c01028a9:	01 d0                	add    %edx,%eax
c01028ab:	c1 e0 02             	shl    $0x2,%eax
c01028ae:	01 c8                	add    %ecx,%eax
}
c01028b0:	c9                   	leave  
c01028b1:	c3                   	ret    

c01028b2 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01028b2:	55                   	push   %ebp
c01028b3:	89 e5                	mov    %esp,%ebp
c01028b5:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c01028b8:	ff 75 08             	pushl  0x8(%ebp)
c01028bb:	e8 98 ff ff ff       	call   c0102858 <page2pa>
c01028c0:	83 c4 04             	add    $0x4,%esp
c01028c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028c9:	c1 e8 0c             	shr    $0xc,%eax
c01028cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01028cf:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01028d4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01028d7:	72 14                	jb     c01028ed <page2kva+0x3b>
c01028d9:	ff 75 f4             	pushl  -0xc(%ebp)
c01028dc:	68 c0 61 10 c0       	push   $0xc01061c0
c01028e1:	6a 61                	push   $0x61
c01028e3:	68 af 61 10 c0       	push   $0xc01061af
c01028e8:	e8 ec da ff ff       	call   c01003d9 <__panic>
c01028ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028f0:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01028f5:	c9                   	leave  
c01028f6:	c3                   	ret    

c01028f7 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01028f7:	55                   	push   %ebp
c01028f8:	89 e5                	mov    %esp,%ebp
c01028fa:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c01028fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102900:	83 e0 01             	and    $0x1,%eax
c0102903:	85 c0                	test   %eax,%eax
c0102905:	75 14                	jne    c010291b <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0102907:	83 ec 04             	sub    $0x4,%esp
c010290a:	68 e4 61 10 c0       	push   $0xc01061e4
c010290f:	6a 6c                	push   $0x6c
c0102911:	68 af 61 10 c0       	push   $0xc01061af
c0102916:	e8 be da ff ff       	call   c01003d9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010291b:	8b 45 08             	mov    0x8(%ebp),%eax
c010291e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102923:	83 ec 0c             	sub    $0xc,%esp
c0102926:	50                   	push   %eax
c0102927:	e8 3f ff ff ff       	call   c010286b <pa2page>
c010292c:	83 c4 10             	add    $0x10,%esp
}
c010292f:	c9                   	leave  
c0102930:	c3                   	ret    

c0102931 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102931:	55                   	push   %ebp
c0102932:	89 e5                	mov    %esp,%ebp
c0102934:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0102937:	8b 45 08             	mov    0x8(%ebp),%eax
c010293a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010293f:	83 ec 0c             	sub    $0xc,%esp
c0102942:	50                   	push   %eax
c0102943:	e8 23 ff ff ff       	call   c010286b <pa2page>
c0102948:	83 c4 10             	add    $0x10,%esp
}
c010294b:	c9                   	leave  
c010294c:	c3                   	ret    

c010294d <page_ref>:

static inline int
page_ref(struct Page *page) {
c010294d:	55                   	push   %ebp
c010294e:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102950:	8b 45 08             	mov    0x8(%ebp),%eax
c0102953:	8b 00                	mov    (%eax),%eax
}
c0102955:	5d                   	pop    %ebp
c0102956:	c3                   	ret    

c0102957 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102957:	55                   	push   %ebp
c0102958:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010295a:	8b 45 08             	mov    0x8(%ebp),%eax
c010295d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102960:	89 10                	mov    %edx,(%eax)
}
c0102962:	90                   	nop
c0102963:	5d                   	pop    %ebp
c0102964:	c3                   	ret    

c0102965 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102965:	55                   	push   %ebp
c0102966:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102968:	8b 45 08             	mov    0x8(%ebp),%eax
c010296b:	8b 00                	mov    (%eax),%eax
c010296d:	8d 50 01             	lea    0x1(%eax),%edx
c0102970:	8b 45 08             	mov    0x8(%ebp),%eax
c0102973:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102975:	8b 45 08             	mov    0x8(%ebp),%eax
c0102978:	8b 00                	mov    (%eax),%eax
}
c010297a:	5d                   	pop    %ebp
c010297b:	c3                   	ret    

c010297c <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010297c:	55                   	push   %ebp
c010297d:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010297f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102982:	8b 00                	mov    (%eax),%eax
c0102984:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102987:	8b 45 08             	mov    0x8(%ebp),%eax
c010298a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010298c:	8b 45 08             	mov    0x8(%ebp),%eax
c010298f:	8b 00                	mov    (%eax),%eax
}
c0102991:	5d                   	pop    %ebp
c0102992:	c3                   	ret    

c0102993 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102993:	55                   	push   %ebp
c0102994:	89 e5                	mov    %esp,%ebp
c0102996:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102999:	9c                   	pushf  
c010299a:	58                   	pop    %eax
c010299b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01029a1:	25 00 02 00 00       	and    $0x200,%eax
c01029a6:	85 c0                	test   %eax,%eax
c01029a8:	74 0c                	je     c01029b6 <__intr_save+0x23>
        intr_disable();
c01029aa:	e8 d9 ee ff ff       	call   c0101888 <intr_disable>
        return 1;
c01029af:	b8 01 00 00 00       	mov    $0x1,%eax
c01029b4:	eb 05                	jmp    c01029bb <__intr_save+0x28>
    }
    return 0;
c01029b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029bb:	c9                   	leave  
c01029bc:	c3                   	ret    

c01029bd <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01029bd:	55                   	push   %ebp
c01029be:	89 e5                	mov    %esp,%ebp
c01029c0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029c7:	74 05                	je     c01029ce <__intr_restore+0x11>
        intr_enable();
c01029c9:	e8 b3 ee ff ff       	call   c0101881 <intr_enable>
    }
}
c01029ce:	90                   	nop
c01029cf:	c9                   	leave  
c01029d0:	c3                   	ret    

c01029d1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01029d1:	55                   	push   %ebp
c01029d2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01029d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01029da:	b8 23 00 00 00       	mov    $0x23,%eax
c01029df:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01029e1:	b8 23 00 00 00       	mov    $0x23,%eax
c01029e6:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01029e8:	b8 10 00 00 00       	mov    $0x10,%eax
c01029ed:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01029ef:	b8 10 00 00 00       	mov    $0x10,%eax
c01029f4:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01029f6:	b8 10 00 00 00       	mov    $0x10,%eax
c01029fb:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01029fd:	ea 04 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a04
}
c0102a04:	90                   	nop
c0102a05:	5d                   	pop    %ebp
c0102a06:	c3                   	ret    

c0102a07 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a07:	55                   	push   %ebp
c0102a08:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0d:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102a12:	90                   	nop
c0102a13:	5d                   	pop    %ebp
c0102a14:	c3                   	ret    

c0102a15 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a15:	55                   	push   %ebp
c0102a16:	89 e5                	mov    %esp,%ebp
c0102a18:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a1b:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102a20:	50                   	push   %eax
c0102a21:	e8 e1 ff ff ff       	call   c0102a07 <load_esp0>
c0102a26:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0102a29:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102a30:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a32:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102a39:	68 00 
c0102a3b:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102a40:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102a46:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102a4b:	c1 e8 10             	shr    $0x10,%eax
c0102a4e:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102a53:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102a5a:	83 e0 f0             	and    $0xfffffff0,%eax
c0102a5d:	83 c8 09             	or     $0x9,%eax
c0102a60:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102a65:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102a6c:	83 e0 ef             	and    $0xffffffef,%eax
c0102a6f:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102a74:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102a7b:	83 e0 9f             	and    $0xffffff9f,%eax
c0102a7e:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102a83:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102a8a:	83 c8 80             	or     $0xffffff80,%eax
c0102a8d:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102a92:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102a99:	83 e0 f0             	and    $0xfffffff0,%eax
c0102a9c:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102aa1:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102aa8:	83 e0 ef             	and    $0xffffffef,%eax
c0102aab:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102ab0:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102ab7:	83 e0 df             	and    $0xffffffdf,%eax
c0102aba:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102abf:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102ac6:	83 c8 40             	or     $0x40,%eax
c0102ac9:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102ace:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102ad5:	83 e0 7f             	and    $0x7f,%eax
c0102ad8:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102add:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102ae2:	c1 e8 18             	shr    $0x18,%eax
c0102ae5:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102aea:	68 30 7a 11 c0       	push   $0xc0117a30
c0102aef:	e8 dd fe ff ff       	call   c01029d1 <lgdt>
c0102af4:	83 c4 04             	add    $0x4,%esp
c0102af7:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102afd:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b01:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b04:	90                   	nop
c0102b05:	c9                   	leave  
c0102b06:	c3                   	ret    

c0102b07 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b07:	55                   	push   %ebp
c0102b08:	89 e5                	mov    %esp,%ebp
c0102b0a:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0102b0d:	c7 05 10 af 11 c0 88 	movl   $0xc0106b88,0xc011af10
c0102b14:	6b 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b17:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b1c:	8b 00                	mov    (%eax),%eax
c0102b1e:	83 ec 08             	sub    $0x8,%esp
c0102b21:	50                   	push   %eax
c0102b22:	68 10 62 10 c0       	push   $0xc0106210
c0102b27:	e8 47 d7 ff ff       	call   c0100273 <cprintf>
c0102b2c:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0102b2f:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b34:	8b 40 04             	mov    0x4(%eax),%eax
c0102b37:	ff d0                	call   *%eax
}
c0102b39:	90                   	nop
c0102b3a:	c9                   	leave  
c0102b3b:	c3                   	ret    

c0102b3c <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b3c:	55                   	push   %ebp
c0102b3d:	89 e5                	mov    %esp,%ebp
c0102b3f:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0102b42:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b47:	8b 40 08             	mov    0x8(%eax),%eax
c0102b4a:	83 ec 08             	sub    $0x8,%esp
c0102b4d:	ff 75 0c             	pushl  0xc(%ebp)
c0102b50:	ff 75 08             	pushl  0x8(%ebp)
c0102b53:	ff d0                	call   *%eax
c0102b55:	83 c4 10             	add    $0x10,%esp
}
c0102b58:	90                   	nop
c0102b59:	c9                   	leave  
c0102b5a:	c3                   	ret    

c0102b5b <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102b5b:	55                   	push   %ebp
c0102b5c:	89 e5                	mov    %esp,%ebp
c0102b5e:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c0102b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b68:	e8 26 fe ff ff       	call   c0102993 <__intr_save>
c0102b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102b70:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b75:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b78:	83 ec 0c             	sub    $0xc,%esp
c0102b7b:	ff 75 08             	pushl  0x8(%ebp)
c0102b7e:	ff d0                	call   *%eax
c0102b80:	83 c4 10             	add    $0x10,%esp
c0102b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102b86:	83 ec 0c             	sub    $0xc,%esp
c0102b89:	ff 75 f0             	pushl  -0x10(%ebp)
c0102b8c:	e8 2c fe ff ff       	call   c01029bd <__intr_restore>
c0102b91:	83 c4 10             	add    $0x10,%esp
    return page;
c0102b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b97:	c9                   	leave  
c0102b98:	c3                   	ret    

c0102b99 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102b99:	55                   	push   %ebp
c0102b9a:	89 e5                	mov    %esp,%ebp
c0102b9c:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b9f:	e8 ef fd ff ff       	call   c0102993 <__intr_save>
c0102ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102ba7:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bac:	8b 40 10             	mov    0x10(%eax),%eax
c0102baf:	83 ec 08             	sub    $0x8,%esp
c0102bb2:	ff 75 0c             	pushl  0xc(%ebp)
c0102bb5:	ff 75 08             	pushl  0x8(%ebp)
c0102bb8:	ff d0                	call   *%eax
c0102bba:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0102bbd:	83 ec 0c             	sub    $0xc,%esp
c0102bc0:	ff 75 f4             	pushl  -0xc(%ebp)
c0102bc3:	e8 f5 fd ff ff       	call   c01029bd <__intr_restore>
c0102bc8:	83 c4 10             	add    $0x10,%esp
}
c0102bcb:	90                   	nop
c0102bcc:	c9                   	leave  
c0102bcd:	c3                   	ret    

c0102bce <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102bce:	55                   	push   %ebp
c0102bcf:	89 e5                	mov    %esp,%ebp
c0102bd1:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bd4:	e8 ba fd ff ff       	call   c0102993 <__intr_save>
c0102bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102bdc:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102be1:	8b 40 14             	mov    0x14(%eax),%eax
c0102be4:	ff d0                	call   *%eax
c0102be6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102be9:	83 ec 0c             	sub    $0xc,%esp
c0102bec:	ff 75 f4             	pushl  -0xc(%ebp)
c0102bef:	e8 c9 fd ff ff       	call   c01029bd <__intr_restore>
c0102bf4:	83 c4 10             	add    $0x10,%esp
    return ret;
c0102bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102bfa:	c9                   	leave  
c0102bfb:	c3                   	ret    

c0102bfc <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102bfc:	55                   	push   %ebp
c0102bfd:	89 e5                	mov    %esp,%ebp
c0102bff:	57                   	push   %edi
c0102c00:	56                   	push   %esi
c0102c01:	53                   	push   %ebx
c0102c02:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c05:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c0c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c13:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c1a:	83 ec 0c             	sub    $0xc,%esp
c0102c1d:	68 27 62 10 c0       	push   $0xc0106227
c0102c22:	e8 4c d6 ff ff       	call   c0100273 <cprintf>
c0102c27:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c2a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c31:	e9 fc 00 00 00       	jmp    c0102d32 <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c36:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c39:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c3c:	89 d0                	mov    %edx,%eax
c0102c3e:	c1 e0 02             	shl    $0x2,%eax
c0102c41:	01 d0                	add    %edx,%eax
c0102c43:	c1 e0 02             	shl    $0x2,%eax
c0102c46:	01 c8                	add    %ecx,%eax
c0102c48:	8b 50 08             	mov    0x8(%eax),%edx
c0102c4b:	8b 40 04             	mov    0x4(%eax),%eax
c0102c4e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102c51:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102c54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c5a:	89 d0                	mov    %edx,%eax
c0102c5c:	c1 e0 02             	shl    $0x2,%eax
c0102c5f:	01 d0                	add    %edx,%eax
c0102c61:	c1 e0 02             	shl    $0x2,%eax
c0102c64:	01 c8                	add    %ecx,%eax
c0102c66:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102c69:	8b 58 10             	mov    0x10(%eax),%ebx
c0102c6c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102c6f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102c72:	01 c8                	add    %ecx,%eax
c0102c74:	11 da                	adc    %ebx,%edx
c0102c76:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102c79:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102c7c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c82:	89 d0                	mov    %edx,%eax
c0102c84:	c1 e0 02             	shl    $0x2,%eax
c0102c87:	01 d0                	add    %edx,%eax
c0102c89:	c1 e0 02             	shl    $0x2,%eax
c0102c8c:	01 c8                	add    %ecx,%eax
c0102c8e:	83 c0 14             	add    $0x14,%eax
c0102c91:	8b 00                	mov    (%eax),%eax
c0102c93:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102c96:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102c99:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102c9c:	83 c0 ff             	add    $0xffffffff,%eax
c0102c9f:	83 d2 ff             	adc    $0xffffffff,%edx
c0102ca2:	89 c1                	mov    %eax,%ecx
c0102ca4:	89 d3                	mov    %edx,%ebx
c0102ca6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102ca9:	89 55 80             	mov    %edx,-0x80(%ebp)
c0102cac:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102caf:	89 d0                	mov    %edx,%eax
c0102cb1:	c1 e0 02             	shl    $0x2,%eax
c0102cb4:	01 d0                	add    %edx,%eax
c0102cb6:	c1 e0 02             	shl    $0x2,%eax
c0102cb9:	03 45 80             	add    -0x80(%ebp),%eax
c0102cbc:	8b 50 10             	mov    0x10(%eax),%edx
c0102cbf:	8b 40 0c             	mov    0xc(%eax),%eax
c0102cc2:	ff 75 84             	pushl  -0x7c(%ebp)
c0102cc5:	53                   	push   %ebx
c0102cc6:	51                   	push   %ecx
c0102cc7:	ff 75 bc             	pushl  -0x44(%ebp)
c0102cca:	ff 75 b8             	pushl  -0x48(%ebp)
c0102ccd:	52                   	push   %edx
c0102cce:	50                   	push   %eax
c0102ccf:	68 34 62 10 c0       	push   $0xc0106234
c0102cd4:	e8 9a d5 ff ff       	call   c0100273 <cprintf>
c0102cd9:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102cdc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cdf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ce2:	89 d0                	mov    %edx,%eax
c0102ce4:	c1 e0 02             	shl    $0x2,%eax
c0102ce7:	01 d0                	add    %edx,%eax
c0102ce9:	c1 e0 02             	shl    $0x2,%eax
c0102cec:	01 c8                	add    %ecx,%eax
c0102cee:	83 c0 14             	add    $0x14,%eax
c0102cf1:	8b 00                	mov    (%eax),%eax
c0102cf3:	83 f8 01             	cmp    $0x1,%eax
c0102cf6:	75 36                	jne    c0102d2e <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0102cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102cfb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102cfe:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d01:	77 2b                	ja     c0102d2e <page_init+0x132>
c0102d03:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d06:	72 05                	jb     c0102d0d <page_init+0x111>
c0102d08:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102d0b:	73 21                	jae    c0102d2e <page_init+0x132>
c0102d0d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d11:	77 1b                	ja     c0102d2e <page_init+0x132>
c0102d13:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d17:	72 09                	jb     c0102d22 <page_init+0x126>
c0102d19:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102d20:	77 0c                	ja     c0102d2e <page_init+0x132>
                maxpa = end;
c0102d22:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d25:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d28:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d2e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102d32:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d35:	8b 00                	mov    (%eax),%eax
c0102d37:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102d3a:	0f 8f f6 fe ff ff    	jg     c0102c36 <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102d40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d44:	72 1d                	jb     c0102d63 <page_init+0x167>
c0102d46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d4a:	77 09                	ja     c0102d55 <page_init+0x159>
c0102d4c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102d53:	76 0e                	jbe    c0102d63 <page_init+0x167>
        maxpa = KMEMSIZE;
c0102d55:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102d5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102d63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d69:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102d6d:	c1 ea 0c             	shr    $0xc,%edx
c0102d70:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102d75:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102d7c:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102d81:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102d84:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102d87:	01 d0                	add    %edx,%eax
c0102d89:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102d8c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102d8f:	ba 00 00 00 00       	mov    $0x0,%edx
c0102d94:	f7 75 ac             	divl   -0x54(%ebp)
c0102d97:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102d9a:	29 d0                	sub    %edx,%eax
c0102d9c:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102da1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102da8:	eb 2f                	jmp    c0102dd9 <page_init+0x1dd>
        SetPageReserved(pages + i);
c0102daa:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102db0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102db3:	89 d0                	mov    %edx,%eax
c0102db5:	c1 e0 02             	shl    $0x2,%eax
c0102db8:	01 d0                	add    %edx,%eax
c0102dba:	c1 e0 02             	shl    $0x2,%eax
c0102dbd:	01 c8                	add    %ecx,%eax
c0102dbf:	83 c0 04             	add    $0x4,%eax
c0102dc2:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102dc9:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dcc:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102dcf:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102dd2:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0102dd5:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102dd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ddc:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102de1:	39 c2                	cmp    %eax,%edx
c0102de3:	72 c5                	jb     c0102daa <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102de5:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102deb:	89 d0                	mov    %edx,%eax
c0102ded:	c1 e0 02             	shl    $0x2,%eax
c0102df0:	01 d0                	add    %edx,%eax
c0102df2:	c1 e0 02             	shl    $0x2,%eax
c0102df5:	89 c2                	mov    %eax,%edx
c0102df7:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102dfc:	01 d0                	add    %edx,%eax
c0102dfe:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102e01:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102e08:	77 17                	ja     c0102e21 <page_init+0x225>
c0102e0a:	ff 75 a4             	pushl  -0x5c(%ebp)
c0102e0d:	68 64 62 10 c0       	push   $0xc0106264
c0102e12:	68 dc 00 00 00       	push   $0xdc
c0102e17:	68 88 62 10 c0       	push   $0xc0106288
c0102e1c:	e8 b8 d5 ff ff       	call   c01003d9 <__panic>
c0102e21:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e24:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e29:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102e2c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e33:	e9 69 01 00 00       	jmp    c0102fa1 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e38:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e3e:	89 d0                	mov    %edx,%eax
c0102e40:	c1 e0 02             	shl    $0x2,%eax
c0102e43:	01 d0                	add    %edx,%eax
c0102e45:	c1 e0 02             	shl    $0x2,%eax
c0102e48:	01 c8                	add    %ecx,%eax
c0102e4a:	8b 50 08             	mov    0x8(%eax),%edx
c0102e4d:	8b 40 04             	mov    0x4(%eax),%eax
c0102e50:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102e53:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102e56:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e59:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e5c:	89 d0                	mov    %edx,%eax
c0102e5e:	c1 e0 02             	shl    $0x2,%eax
c0102e61:	01 d0                	add    %edx,%eax
c0102e63:	c1 e0 02             	shl    $0x2,%eax
c0102e66:	01 c8                	add    %ecx,%eax
c0102e68:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e6b:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102e71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102e74:	01 c8                	add    %ecx,%eax
c0102e76:	11 da                	adc    %ebx,%edx
c0102e78:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102e7b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102e7e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e84:	89 d0                	mov    %edx,%eax
c0102e86:	c1 e0 02             	shl    $0x2,%eax
c0102e89:	01 d0                	add    %edx,%eax
c0102e8b:	c1 e0 02             	shl    $0x2,%eax
c0102e8e:	01 c8                	add    %ecx,%eax
c0102e90:	83 c0 14             	add    $0x14,%eax
c0102e93:	8b 00                	mov    (%eax),%eax
c0102e95:	83 f8 01             	cmp    $0x1,%eax
c0102e98:	0f 85 ff 00 00 00    	jne    c0102f9d <page_init+0x3a1>
            if (begin < freemem) {
c0102e9e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ea1:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ea6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102ea9:	72 17                	jb     c0102ec2 <page_init+0x2c6>
c0102eab:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102eae:	77 05                	ja     c0102eb5 <page_init+0x2b9>
c0102eb0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102eb3:	76 0d                	jbe    c0102ec2 <page_init+0x2c6>
                begin = freemem;
c0102eb5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102eb8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ebb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102ec2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102ec6:	72 1d                	jb     c0102ee5 <page_init+0x2e9>
c0102ec8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102ecc:	77 09                	ja     c0102ed7 <page_init+0x2db>
c0102ece:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102ed5:	76 0e                	jbe    c0102ee5 <page_init+0x2e9>
                end = KMEMSIZE;
c0102ed7:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102ede:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102ee5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ee8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102eeb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102eee:	0f 87 a9 00 00 00    	ja     c0102f9d <page_init+0x3a1>
c0102ef4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102ef7:	72 09                	jb     c0102f02 <page_init+0x306>
c0102ef9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102efc:	0f 83 9b 00 00 00    	jae    c0102f9d <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
c0102f02:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102f09:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f0c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f0f:	01 d0                	add    %edx,%eax
c0102f11:	83 e8 01             	sub    $0x1,%eax
c0102f14:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102f17:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f1a:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f1f:	f7 75 9c             	divl   -0x64(%ebp)
c0102f22:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f25:	29 d0                	sub    %edx,%eax
c0102f27:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f2f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102f32:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f35:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102f38:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102f3b:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f40:	89 c3                	mov    %eax,%ebx
c0102f42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102f48:	89 de                	mov    %ebx,%esi
c0102f4a:	89 d0                	mov    %edx,%eax
c0102f4c:	83 e0 00             	and    $0x0,%eax
c0102f4f:	89 c7                	mov    %eax,%edi
c0102f51:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102f54:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102f57:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f5d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f60:	77 3b                	ja     c0102f9d <page_init+0x3a1>
c0102f62:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f65:	72 05                	jb     c0102f6c <page_init+0x370>
c0102f67:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f6a:	73 31                	jae    c0102f9d <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102f6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f6f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102f72:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102f75:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102f78:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f7c:	c1 ea 0c             	shr    $0xc,%edx
c0102f7f:	89 c3                	mov    %eax,%ebx
c0102f81:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f84:	83 ec 0c             	sub    $0xc,%esp
c0102f87:	50                   	push   %eax
c0102f88:	e8 de f8 ff ff       	call   c010286b <pa2page>
c0102f8d:	83 c4 10             	add    $0x10,%esp
c0102f90:	83 ec 08             	sub    $0x8,%esp
c0102f93:	53                   	push   %ebx
c0102f94:	50                   	push   %eax
c0102f95:	e8 a2 fb ff ff       	call   c0102b3c <init_memmap>
c0102f9a:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0102f9d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102fa1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fa4:	8b 00                	mov    (%eax),%eax
c0102fa6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102fa9:	0f 8f 89 fe ff ff    	jg     c0102e38 <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0102faf:	90                   	nop
c0102fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102fb3:	5b                   	pop    %ebx
c0102fb4:	5e                   	pop    %esi
c0102fb5:	5f                   	pop    %edi
c0102fb6:	5d                   	pop    %ebp
c0102fb7:	c3                   	ret    

c0102fb8 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0102fb8:	55                   	push   %ebp
c0102fb9:	89 e5                	mov    %esp,%ebp
c0102fbb:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0102fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102fc1:	33 45 14             	xor    0x14(%ebp),%eax
c0102fc4:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102fc9:	85 c0                	test   %eax,%eax
c0102fcb:	74 19                	je     c0102fe6 <boot_map_segment+0x2e>
c0102fcd:	68 96 62 10 c0       	push   $0xc0106296
c0102fd2:	68 ad 62 10 c0       	push   $0xc01062ad
c0102fd7:	68 fa 00 00 00       	push   $0xfa
c0102fdc:	68 88 62 10 c0       	push   $0xc0106288
c0102fe1:	e8 f3 d3 ff ff       	call   c01003d9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0102fe6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0102fed:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ff0:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102ff5:	89 c2                	mov    %eax,%edx
c0102ff7:	8b 45 10             	mov    0x10(%ebp),%eax
c0102ffa:	01 c2                	add    %eax,%edx
c0102ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fff:	01 d0                	add    %edx,%eax
c0103001:	83 e8 01             	sub    $0x1,%eax
c0103004:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103007:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010300a:	ba 00 00 00 00       	mov    $0x0,%edx
c010300f:	f7 75 f0             	divl   -0x10(%ebp)
c0103012:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103015:	29 d0                	sub    %edx,%eax
c0103017:	c1 e8 0c             	shr    $0xc,%eax
c010301a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010301d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103020:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103023:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103026:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010302b:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010302e:	8b 45 14             	mov    0x14(%ebp),%eax
c0103031:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103037:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010303c:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010303f:	eb 57                	jmp    c0103098 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103041:	83 ec 04             	sub    $0x4,%esp
c0103044:	6a 01                	push   $0x1
c0103046:	ff 75 0c             	pushl  0xc(%ebp)
c0103049:	ff 75 08             	pushl  0x8(%ebp)
c010304c:	e8 53 01 00 00       	call   c01031a4 <get_pte>
c0103051:	83 c4 10             	add    $0x10,%esp
c0103054:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103057:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010305b:	75 19                	jne    c0103076 <boot_map_segment+0xbe>
c010305d:	68 c2 62 10 c0       	push   $0xc01062c2
c0103062:	68 ad 62 10 c0       	push   $0xc01062ad
c0103067:	68 00 01 00 00       	push   $0x100
c010306c:	68 88 62 10 c0       	push   $0xc0106288
c0103071:	e8 63 d3 ff ff       	call   c01003d9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103076:	8b 45 14             	mov    0x14(%ebp),%eax
c0103079:	0b 45 18             	or     0x18(%ebp),%eax
c010307c:	83 c8 01             	or     $0x1,%eax
c010307f:	89 c2                	mov    %eax,%edx
c0103081:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103084:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103086:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010308a:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103091:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103098:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010309c:	75 a3                	jne    c0103041 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010309e:	90                   	nop
c010309f:	c9                   	leave  
c01030a0:	c3                   	ret    

c01030a1 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01030a1:	55                   	push   %ebp
c01030a2:	89 e5                	mov    %esp,%ebp
c01030a4:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c01030a7:	83 ec 0c             	sub    $0xc,%esp
c01030aa:	6a 01                	push   $0x1
c01030ac:	e8 aa fa ff ff       	call   c0102b5b <alloc_pages>
c01030b1:	83 c4 10             	add    $0x10,%esp
c01030b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01030b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030bb:	75 17                	jne    c01030d4 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c01030bd:	83 ec 04             	sub    $0x4,%esp
c01030c0:	68 cf 62 10 c0       	push   $0xc01062cf
c01030c5:	68 0c 01 00 00       	push   $0x10c
c01030ca:	68 88 62 10 c0       	push   $0xc0106288
c01030cf:	e8 05 d3 ff ff       	call   c01003d9 <__panic>
    }
    return page2kva(p);
c01030d4:	83 ec 0c             	sub    $0xc,%esp
c01030d7:	ff 75 f4             	pushl  -0xc(%ebp)
c01030da:	e8 d3 f7 ff ff       	call   c01028b2 <page2kva>
c01030df:	83 c4 10             	add    $0x10,%esp
}
c01030e2:	c9                   	leave  
c01030e3:	c3                   	ret    

c01030e4 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01030e4:	55                   	push   %ebp
c01030e5:	89 e5                	mov    %esp,%ebp
c01030e7:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01030ea:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01030ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01030f2:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01030f9:	77 17                	ja     c0103112 <pmm_init+0x2e>
c01030fb:	ff 75 f4             	pushl  -0xc(%ebp)
c01030fe:	68 64 62 10 c0       	push   $0xc0106264
c0103103:	68 16 01 00 00       	push   $0x116
c0103108:	68 88 62 10 c0       	push   $0xc0106288
c010310d:	e8 c7 d2 ff ff       	call   c01003d9 <__panic>
c0103112:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103115:	05 00 00 00 40       	add    $0x40000000,%eax
c010311a:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010311f:	e8 e3 f9 ff ff       	call   c0102b07 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103124:	e8 d3 fa ff ff       	call   c0102bfc <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103129:	e8 90 03 00 00       	call   c01034be <check_alloc_page>

    check_pgdir();
c010312e:	e8 ae 03 00 00       	call   c01034e1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103133:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103138:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010313e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103143:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103146:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010314d:	77 17                	ja     c0103166 <pmm_init+0x82>
c010314f:	ff 75 f0             	pushl  -0x10(%ebp)
c0103152:	68 64 62 10 c0       	push   $0xc0106264
c0103157:	68 2c 01 00 00       	push   $0x12c
c010315c:	68 88 62 10 c0       	push   $0xc0106288
c0103161:	e8 73 d2 ff ff       	call   c01003d9 <__panic>
c0103166:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103169:	05 00 00 00 40       	add    $0x40000000,%eax
c010316e:	83 c8 03             	or     $0x3,%eax
c0103171:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103173:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103178:	83 ec 0c             	sub    $0xc,%esp
c010317b:	6a 02                	push   $0x2
c010317d:	6a 00                	push   $0x0
c010317f:	68 00 00 00 38       	push   $0x38000000
c0103184:	68 00 00 00 c0       	push   $0xc0000000
c0103189:	50                   	push   %eax
c010318a:	e8 29 fe ff ff       	call   c0102fb8 <boot_map_segment>
c010318f:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103192:	e8 7e f8 ff ff       	call   c0102a15 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103197:	e8 ab 08 00 00       	call   c0103a47 <check_boot_pgdir>

    print_pgdir();
c010319c:	e8 a1 0c 00 00       	call   c0103e42 <print_pgdir>

}
c01031a1:	90                   	nop
c01031a2:	c9                   	leave  
c01031a3:	c3                   	ret    

c01031a4 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01031a4:	55                   	push   %ebp
c01031a5:	89 e5                	mov    %esp,%ebp
c01031a7:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01031aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031ad:	c1 e8 16             	shr    $0x16,%eax
c01031b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01031b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01031ba:	01 d0                	add    %edx,%eax
c01031bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031c2:	8b 00                	mov    (%eax),%eax
c01031c4:	83 e0 01             	and    $0x1,%eax
c01031c7:	85 c0                	test   %eax,%eax
c01031c9:	0f 85 9f 00 00 00    	jne    c010326e <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01031cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01031d3:	74 16                	je     c01031eb <get_pte+0x47>
c01031d5:	83 ec 0c             	sub    $0xc,%esp
c01031d8:	6a 01                	push   $0x1
c01031da:	e8 7c f9 ff ff       	call   c0102b5b <alloc_pages>
c01031df:	83 c4 10             	add    $0x10,%esp
c01031e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01031e9:	75 0a                	jne    c01031f5 <get_pte+0x51>
            return NULL;
c01031eb:	b8 00 00 00 00       	mov    $0x0,%eax
c01031f0:	e9 ca 00 00 00       	jmp    c01032bf <get_pte+0x11b>
        }
        set_page_ref(page, 1);
c01031f5:	83 ec 08             	sub    $0x8,%esp
c01031f8:	6a 01                	push   $0x1
c01031fa:	ff 75 f0             	pushl  -0x10(%ebp)
c01031fd:	e8 55 f7 ff ff       	call   c0102957 <set_page_ref>
c0103202:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c0103205:	83 ec 0c             	sub    $0xc,%esp
c0103208:	ff 75 f0             	pushl  -0x10(%ebp)
c010320b:	e8 48 f6 ff ff       	call   c0102858 <page2pa>
c0103210:	83 c4 10             	add    $0x10,%esp
c0103213:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0103216:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103219:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010321c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010321f:	c1 e8 0c             	shr    $0xc,%eax
c0103222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103225:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010322a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010322d:	72 17                	jb     c0103246 <get_pte+0xa2>
c010322f:	ff 75 e8             	pushl  -0x18(%ebp)
c0103232:	68 c0 61 10 c0       	push   $0xc01061c0
c0103237:	68 72 01 00 00       	push   $0x172
c010323c:	68 88 62 10 c0       	push   $0xc0106288
c0103241:	e8 93 d1 ff ff       	call   c01003d9 <__panic>
c0103246:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103249:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010324e:	83 ec 04             	sub    $0x4,%esp
c0103251:	68 00 10 00 00       	push   $0x1000
c0103256:	6a 00                	push   $0x0
c0103258:	50                   	push   %eax
c0103259:	e8 74 20 00 00       	call   c01052d2 <memset>
c010325e:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103261:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103264:	83 c8 07             	or     $0x7,%eax
c0103267:	89 c2                	mov    %eax,%edx
c0103269:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010326c:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010326e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103271:	8b 00                	mov    (%eax),%eax
c0103273:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103278:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010327b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010327e:	c1 e8 0c             	shr    $0xc,%eax
c0103281:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103284:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103289:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010328c:	72 17                	jb     c01032a5 <get_pte+0x101>
c010328e:	ff 75 e0             	pushl  -0x20(%ebp)
c0103291:	68 c0 61 10 c0       	push   $0xc01061c0
c0103296:	68 75 01 00 00       	push   $0x175
c010329b:	68 88 62 10 c0       	push   $0xc0106288
c01032a0:	e8 34 d1 ff ff       	call   c01003d9 <__panic>
c01032a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032a8:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01032ad:	89 c2                	mov    %eax,%edx
c01032af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032b2:	c1 e8 0c             	shr    $0xc,%eax
c01032b5:	25 ff 03 00 00       	and    $0x3ff,%eax
c01032ba:	c1 e0 02             	shl    $0x2,%eax
c01032bd:	01 d0                	add    %edx,%eax
}
c01032bf:	c9                   	leave  
c01032c0:	c3                   	ret    

c01032c1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01032c1:	55                   	push   %ebp
c01032c2:	89 e5                	mov    %esp,%ebp
c01032c4:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01032c7:	83 ec 04             	sub    $0x4,%esp
c01032ca:	6a 00                	push   $0x0
c01032cc:	ff 75 0c             	pushl  0xc(%ebp)
c01032cf:	ff 75 08             	pushl  0x8(%ebp)
c01032d2:	e8 cd fe ff ff       	call   c01031a4 <get_pte>
c01032d7:	83 c4 10             	add    $0x10,%esp
c01032da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01032dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01032e1:	74 08                	je     c01032eb <get_page+0x2a>
        *ptep_store = ptep;
c01032e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01032e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01032e9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01032eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032ef:	74 1f                	je     c0103310 <get_page+0x4f>
c01032f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f4:	8b 00                	mov    (%eax),%eax
c01032f6:	83 e0 01             	and    $0x1,%eax
c01032f9:	85 c0                	test   %eax,%eax
c01032fb:	74 13                	je     c0103310 <get_page+0x4f>
        return pte2page(*ptep);
c01032fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103300:	8b 00                	mov    (%eax),%eax
c0103302:	83 ec 0c             	sub    $0xc,%esp
c0103305:	50                   	push   %eax
c0103306:	e8 ec f5 ff ff       	call   c01028f7 <pte2page>
c010330b:	83 c4 10             	add    $0x10,%esp
c010330e:	eb 05                	jmp    c0103315 <get_page+0x54>
    }
    return NULL;
c0103310:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103315:	c9                   	leave  
c0103316:	c3                   	ret    

c0103317 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103317:	55                   	push   %ebp
c0103318:	89 e5                	mov    %esp,%ebp
c010331a:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010331d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103320:	8b 00                	mov    (%eax),%eax
c0103322:	83 e0 01             	and    $0x1,%eax
c0103325:	85 c0                	test   %eax,%eax
c0103327:	74 50                	je     c0103379 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0103329:	8b 45 10             	mov    0x10(%ebp),%eax
c010332c:	8b 00                	mov    (%eax),%eax
c010332e:	83 ec 0c             	sub    $0xc,%esp
c0103331:	50                   	push   %eax
c0103332:	e8 c0 f5 ff ff       	call   c01028f7 <pte2page>
c0103337:	83 c4 10             	add    $0x10,%esp
c010333a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010333d:	83 ec 0c             	sub    $0xc,%esp
c0103340:	ff 75 f4             	pushl  -0xc(%ebp)
c0103343:	e8 34 f6 ff ff       	call   c010297c <page_ref_dec>
c0103348:	83 c4 10             	add    $0x10,%esp
c010334b:	85 c0                	test   %eax,%eax
c010334d:	75 10                	jne    c010335f <page_remove_pte+0x48>
            free_page(page);
c010334f:	83 ec 08             	sub    $0x8,%esp
c0103352:	6a 01                	push   $0x1
c0103354:	ff 75 f4             	pushl  -0xc(%ebp)
c0103357:	e8 3d f8 ff ff       	call   c0102b99 <free_pages>
c010335c:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c010335f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103362:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0103368:	83 ec 08             	sub    $0x8,%esp
c010336b:	ff 75 0c             	pushl  0xc(%ebp)
c010336e:	ff 75 08             	pushl  0x8(%ebp)
c0103371:	e8 f8 00 00 00       	call   c010346e <tlb_invalidate>
c0103376:	83 c4 10             	add    $0x10,%esp
    }
}
c0103379:	90                   	nop
c010337a:	c9                   	leave  
c010337b:	c3                   	ret    

c010337c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010337c:	55                   	push   %ebp
c010337d:	89 e5                	mov    %esp,%ebp
c010337f:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103382:	83 ec 04             	sub    $0x4,%esp
c0103385:	6a 00                	push   $0x0
c0103387:	ff 75 0c             	pushl  0xc(%ebp)
c010338a:	ff 75 08             	pushl  0x8(%ebp)
c010338d:	e8 12 fe ff ff       	call   c01031a4 <get_pte>
c0103392:	83 c4 10             	add    $0x10,%esp
c0103395:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0103398:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010339c:	74 14                	je     c01033b2 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c010339e:	83 ec 04             	sub    $0x4,%esp
c01033a1:	ff 75 f4             	pushl  -0xc(%ebp)
c01033a4:	ff 75 0c             	pushl  0xc(%ebp)
c01033a7:	ff 75 08             	pushl  0x8(%ebp)
c01033aa:	e8 68 ff ff ff       	call   c0103317 <page_remove_pte>
c01033af:	83 c4 10             	add    $0x10,%esp
    }
}
c01033b2:	90                   	nop
c01033b3:	c9                   	leave  
c01033b4:	c3                   	ret    

c01033b5 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01033b5:	55                   	push   %ebp
c01033b6:	89 e5                	mov    %esp,%ebp
c01033b8:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01033bb:	83 ec 04             	sub    $0x4,%esp
c01033be:	6a 01                	push   $0x1
c01033c0:	ff 75 10             	pushl  0x10(%ebp)
c01033c3:	ff 75 08             	pushl  0x8(%ebp)
c01033c6:	e8 d9 fd ff ff       	call   c01031a4 <get_pte>
c01033cb:	83 c4 10             	add    $0x10,%esp
c01033ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01033d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033d5:	75 0a                	jne    c01033e1 <page_insert+0x2c>
        return -E_NO_MEM;
c01033d7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01033dc:	e9 8b 00 00 00       	jmp    c010346c <page_insert+0xb7>
    }
    page_ref_inc(page);
c01033e1:	83 ec 0c             	sub    $0xc,%esp
c01033e4:	ff 75 0c             	pushl  0xc(%ebp)
c01033e7:	e8 79 f5 ff ff       	call   c0102965 <page_ref_inc>
c01033ec:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c01033ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f2:	8b 00                	mov    (%eax),%eax
c01033f4:	83 e0 01             	and    $0x1,%eax
c01033f7:	85 c0                	test   %eax,%eax
c01033f9:	74 40                	je     c010343b <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c01033fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033fe:	8b 00                	mov    (%eax),%eax
c0103400:	83 ec 0c             	sub    $0xc,%esp
c0103403:	50                   	push   %eax
c0103404:	e8 ee f4 ff ff       	call   c01028f7 <pte2page>
c0103409:	83 c4 10             	add    $0x10,%esp
c010340c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010340f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103412:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103415:	75 10                	jne    c0103427 <page_insert+0x72>
            page_ref_dec(page);
c0103417:	83 ec 0c             	sub    $0xc,%esp
c010341a:	ff 75 0c             	pushl  0xc(%ebp)
c010341d:	e8 5a f5 ff ff       	call   c010297c <page_ref_dec>
c0103422:	83 c4 10             	add    $0x10,%esp
c0103425:	eb 14                	jmp    c010343b <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103427:	83 ec 04             	sub    $0x4,%esp
c010342a:	ff 75 f4             	pushl  -0xc(%ebp)
c010342d:	ff 75 10             	pushl  0x10(%ebp)
c0103430:	ff 75 08             	pushl  0x8(%ebp)
c0103433:	e8 df fe ff ff       	call   c0103317 <page_remove_pte>
c0103438:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010343b:	83 ec 0c             	sub    $0xc,%esp
c010343e:	ff 75 0c             	pushl  0xc(%ebp)
c0103441:	e8 12 f4 ff ff       	call   c0102858 <page2pa>
c0103446:	83 c4 10             	add    $0x10,%esp
c0103449:	0b 45 14             	or     0x14(%ebp),%eax
c010344c:	83 c8 01             	or     $0x1,%eax
c010344f:	89 c2                	mov    %eax,%edx
c0103451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103454:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103456:	83 ec 08             	sub    $0x8,%esp
c0103459:	ff 75 10             	pushl  0x10(%ebp)
c010345c:	ff 75 08             	pushl  0x8(%ebp)
c010345f:	e8 0a 00 00 00       	call   c010346e <tlb_invalidate>
c0103464:	83 c4 10             	add    $0x10,%esp
    return 0;
c0103467:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010346c:	c9                   	leave  
c010346d:	c3                   	ret    

c010346e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010346e:	55                   	push   %ebp
c010346f:	89 e5                	mov    %esp,%ebp
c0103471:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103474:	0f 20 d8             	mov    %cr3,%eax
c0103477:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c010347a:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010347d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103480:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103483:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010348a:	77 17                	ja     c01034a3 <tlb_invalidate+0x35>
c010348c:	ff 75 f0             	pushl  -0x10(%ebp)
c010348f:	68 64 62 10 c0       	push   $0xc0106264
c0103494:	68 d7 01 00 00       	push   $0x1d7
c0103499:	68 88 62 10 c0       	push   $0xc0106288
c010349e:	e8 36 cf ff ff       	call   c01003d9 <__panic>
c01034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034a6:	05 00 00 00 40       	add    $0x40000000,%eax
c01034ab:	39 c2                	cmp    %eax,%edx
c01034ad:	75 0c                	jne    c01034bb <tlb_invalidate+0x4d>
        invlpg((void *)la);
c01034af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01034b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b8:	0f 01 38             	invlpg (%eax)
    }
}
c01034bb:	90                   	nop
c01034bc:	c9                   	leave  
c01034bd:	c3                   	ret    

c01034be <check_alloc_page>:

static void
check_alloc_page(void) {
c01034be:	55                   	push   %ebp
c01034bf:	89 e5                	mov    %esp,%ebp
c01034c1:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c01034c4:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01034c9:	8b 40 18             	mov    0x18(%eax),%eax
c01034cc:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01034ce:	83 ec 0c             	sub    $0xc,%esp
c01034d1:	68 e8 62 10 c0       	push   $0xc01062e8
c01034d6:	e8 98 cd ff ff       	call   c0100273 <cprintf>
c01034db:	83 c4 10             	add    $0x10,%esp
}
c01034de:	90                   	nop
c01034df:	c9                   	leave  
c01034e0:	c3                   	ret    

c01034e1 <check_pgdir>:

static void
check_pgdir(void) {
c01034e1:	55                   	push   %ebp
c01034e2:	89 e5                	mov    %esp,%ebp
c01034e4:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01034e7:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01034ec:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01034f1:	76 19                	jbe    c010350c <check_pgdir+0x2b>
c01034f3:	68 07 63 10 c0       	push   $0xc0106307
c01034f8:	68 ad 62 10 c0       	push   $0xc01062ad
c01034fd:	68 e4 01 00 00       	push   $0x1e4
c0103502:	68 88 62 10 c0       	push   $0xc0106288
c0103507:	e8 cd ce ff ff       	call   c01003d9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010350c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103511:	85 c0                	test   %eax,%eax
c0103513:	74 0e                	je     c0103523 <check_pgdir+0x42>
c0103515:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010351a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010351f:	85 c0                	test   %eax,%eax
c0103521:	74 19                	je     c010353c <check_pgdir+0x5b>
c0103523:	68 24 63 10 c0       	push   $0xc0106324
c0103528:	68 ad 62 10 c0       	push   $0xc01062ad
c010352d:	68 e5 01 00 00       	push   $0x1e5
c0103532:	68 88 62 10 c0       	push   $0xc0106288
c0103537:	e8 9d ce ff ff       	call   c01003d9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010353c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103541:	83 ec 04             	sub    $0x4,%esp
c0103544:	6a 00                	push   $0x0
c0103546:	6a 00                	push   $0x0
c0103548:	50                   	push   %eax
c0103549:	e8 73 fd ff ff       	call   c01032c1 <get_page>
c010354e:	83 c4 10             	add    $0x10,%esp
c0103551:	85 c0                	test   %eax,%eax
c0103553:	74 19                	je     c010356e <check_pgdir+0x8d>
c0103555:	68 5c 63 10 c0       	push   $0xc010635c
c010355a:	68 ad 62 10 c0       	push   $0xc01062ad
c010355f:	68 e6 01 00 00       	push   $0x1e6
c0103564:	68 88 62 10 c0       	push   $0xc0106288
c0103569:	e8 6b ce ff ff       	call   c01003d9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010356e:	83 ec 0c             	sub    $0xc,%esp
c0103571:	6a 01                	push   $0x1
c0103573:	e8 e3 f5 ff ff       	call   c0102b5b <alloc_pages>
c0103578:	83 c4 10             	add    $0x10,%esp
c010357b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010357e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103583:	6a 00                	push   $0x0
c0103585:	6a 00                	push   $0x0
c0103587:	ff 75 f4             	pushl  -0xc(%ebp)
c010358a:	50                   	push   %eax
c010358b:	e8 25 fe ff ff       	call   c01033b5 <page_insert>
c0103590:	83 c4 10             	add    $0x10,%esp
c0103593:	85 c0                	test   %eax,%eax
c0103595:	74 19                	je     c01035b0 <check_pgdir+0xcf>
c0103597:	68 84 63 10 c0       	push   $0xc0106384
c010359c:	68 ad 62 10 c0       	push   $0xc01062ad
c01035a1:	68 ea 01 00 00       	push   $0x1ea
c01035a6:	68 88 62 10 c0       	push   $0xc0106288
c01035ab:	e8 29 ce ff ff       	call   c01003d9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01035b0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01035b5:	83 ec 04             	sub    $0x4,%esp
c01035b8:	6a 00                	push   $0x0
c01035ba:	6a 00                	push   $0x0
c01035bc:	50                   	push   %eax
c01035bd:	e8 e2 fb ff ff       	call   c01031a4 <get_pte>
c01035c2:	83 c4 10             	add    $0x10,%esp
c01035c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01035c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01035cc:	75 19                	jne    c01035e7 <check_pgdir+0x106>
c01035ce:	68 b0 63 10 c0       	push   $0xc01063b0
c01035d3:	68 ad 62 10 c0       	push   $0xc01062ad
c01035d8:	68 ed 01 00 00       	push   $0x1ed
c01035dd:	68 88 62 10 c0       	push   $0xc0106288
c01035e2:	e8 f2 cd ff ff       	call   c01003d9 <__panic>
    assert(pte2page(*ptep) == p1);
c01035e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035ea:	8b 00                	mov    (%eax),%eax
c01035ec:	83 ec 0c             	sub    $0xc,%esp
c01035ef:	50                   	push   %eax
c01035f0:	e8 02 f3 ff ff       	call   c01028f7 <pte2page>
c01035f5:	83 c4 10             	add    $0x10,%esp
c01035f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01035fb:	74 19                	je     c0103616 <check_pgdir+0x135>
c01035fd:	68 dd 63 10 c0       	push   $0xc01063dd
c0103602:	68 ad 62 10 c0       	push   $0xc01062ad
c0103607:	68 ee 01 00 00       	push   $0x1ee
c010360c:	68 88 62 10 c0       	push   $0xc0106288
c0103611:	e8 c3 cd ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p1) == 1);
c0103616:	83 ec 0c             	sub    $0xc,%esp
c0103619:	ff 75 f4             	pushl  -0xc(%ebp)
c010361c:	e8 2c f3 ff ff       	call   c010294d <page_ref>
c0103621:	83 c4 10             	add    $0x10,%esp
c0103624:	83 f8 01             	cmp    $0x1,%eax
c0103627:	74 19                	je     c0103642 <check_pgdir+0x161>
c0103629:	68 f3 63 10 c0       	push   $0xc01063f3
c010362e:	68 ad 62 10 c0       	push   $0xc01062ad
c0103633:	68 ef 01 00 00       	push   $0x1ef
c0103638:	68 88 62 10 c0       	push   $0xc0106288
c010363d:	e8 97 cd ff ff       	call   c01003d9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103642:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103647:	8b 00                	mov    (%eax),%eax
c0103649:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010364e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103651:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103654:	c1 e8 0c             	shr    $0xc,%eax
c0103657:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010365a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010365f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103662:	72 17                	jb     c010367b <check_pgdir+0x19a>
c0103664:	ff 75 ec             	pushl  -0x14(%ebp)
c0103667:	68 c0 61 10 c0       	push   $0xc01061c0
c010366c:	68 f1 01 00 00       	push   $0x1f1
c0103671:	68 88 62 10 c0       	push   $0xc0106288
c0103676:	e8 5e cd ff ff       	call   c01003d9 <__panic>
c010367b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010367e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103683:	83 c0 04             	add    $0x4,%eax
c0103686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103689:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010368e:	83 ec 04             	sub    $0x4,%esp
c0103691:	6a 00                	push   $0x0
c0103693:	68 00 10 00 00       	push   $0x1000
c0103698:	50                   	push   %eax
c0103699:	e8 06 fb ff ff       	call   c01031a4 <get_pte>
c010369e:	83 c4 10             	add    $0x10,%esp
c01036a1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01036a4:	74 19                	je     c01036bf <check_pgdir+0x1de>
c01036a6:	68 08 64 10 c0       	push   $0xc0106408
c01036ab:	68 ad 62 10 c0       	push   $0xc01062ad
c01036b0:	68 f2 01 00 00       	push   $0x1f2
c01036b5:	68 88 62 10 c0       	push   $0xc0106288
c01036ba:	e8 1a cd ff ff       	call   c01003d9 <__panic>

    p2 = alloc_page();
c01036bf:	83 ec 0c             	sub    $0xc,%esp
c01036c2:	6a 01                	push   $0x1
c01036c4:	e8 92 f4 ff ff       	call   c0102b5b <alloc_pages>
c01036c9:	83 c4 10             	add    $0x10,%esp
c01036cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01036cf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036d4:	6a 06                	push   $0x6
c01036d6:	68 00 10 00 00       	push   $0x1000
c01036db:	ff 75 e4             	pushl  -0x1c(%ebp)
c01036de:	50                   	push   %eax
c01036df:	e8 d1 fc ff ff       	call   c01033b5 <page_insert>
c01036e4:	83 c4 10             	add    $0x10,%esp
c01036e7:	85 c0                	test   %eax,%eax
c01036e9:	74 19                	je     c0103704 <check_pgdir+0x223>
c01036eb:	68 30 64 10 c0       	push   $0xc0106430
c01036f0:	68 ad 62 10 c0       	push   $0xc01062ad
c01036f5:	68 f5 01 00 00       	push   $0x1f5
c01036fa:	68 88 62 10 c0       	push   $0xc0106288
c01036ff:	e8 d5 cc ff ff       	call   c01003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103704:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103709:	83 ec 04             	sub    $0x4,%esp
c010370c:	6a 00                	push   $0x0
c010370e:	68 00 10 00 00       	push   $0x1000
c0103713:	50                   	push   %eax
c0103714:	e8 8b fa ff ff       	call   c01031a4 <get_pte>
c0103719:	83 c4 10             	add    $0x10,%esp
c010371c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010371f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103723:	75 19                	jne    c010373e <check_pgdir+0x25d>
c0103725:	68 68 64 10 c0       	push   $0xc0106468
c010372a:	68 ad 62 10 c0       	push   $0xc01062ad
c010372f:	68 f6 01 00 00       	push   $0x1f6
c0103734:	68 88 62 10 c0       	push   $0xc0106288
c0103739:	e8 9b cc ff ff       	call   c01003d9 <__panic>
    assert(*ptep & PTE_U);
c010373e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103741:	8b 00                	mov    (%eax),%eax
c0103743:	83 e0 04             	and    $0x4,%eax
c0103746:	85 c0                	test   %eax,%eax
c0103748:	75 19                	jne    c0103763 <check_pgdir+0x282>
c010374a:	68 98 64 10 c0       	push   $0xc0106498
c010374f:	68 ad 62 10 c0       	push   $0xc01062ad
c0103754:	68 f7 01 00 00       	push   $0x1f7
c0103759:	68 88 62 10 c0       	push   $0xc0106288
c010375e:	e8 76 cc ff ff       	call   c01003d9 <__panic>
    assert(*ptep & PTE_W);
c0103763:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103766:	8b 00                	mov    (%eax),%eax
c0103768:	83 e0 02             	and    $0x2,%eax
c010376b:	85 c0                	test   %eax,%eax
c010376d:	75 19                	jne    c0103788 <check_pgdir+0x2a7>
c010376f:	68 a6 64 10 c0       	push   $0xc01064a6
c0103774:	68 ad 62 10 c0       	push   $0xc01062ad
c0103779:	68 f8 01 00 00       	push   $0x1f8
c010377e:	68 88 62 10 c0       	push   $0xc0106288
c0103783:	e8 51 cc ff ff       	call   c01003d9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103788:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010378d:	8b 00                	mov    (%eax),%eax
c010378f:	83 e0 04             	and    $0x4,%eax
c0103792:	85 c0                	test   %eax,%eax
c0103794:	75 19                	jne    c01037af <check_pgdir+0x2ce>
c0103796:	68 b4 64 10 c0       	push   $0xc01064b4
c010379b:	68 ad 62 10 c0       	push   $0xc01062ad
c01037a0:	68 f9 01 00 00       	push   $0x1f9
c01037a5:	68 88 62 10 c0       	push   $0xc0106288
c01037aa:	e8 2a cc ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 1);
c01037af:	83 ec 0c             	sub    $0xc,%esp
c01037b2:	ff 75 e4             	pushl  -0x1c(%ebp)
c01037b5:	e8 93 f1 ff ff       	call   c010294d <page_ref>
c01037ba:	83 c4 10             	add    $0x10,%esp
c01037bd:	83 f8 01             	cmp    $0x1,%eax
c01037c0:	74 19                	je     c01037db <check_pgdir+0x2fa>
c01037c2:	68 ca 64 10 c0       	push   $0xc01064ca
c01037c7:	68 ad 62 10 c0       	push   $0xc01062ad
c01037cc:	68 fa 01 00 00       	push   $0x1fa
c01037d1:	68 88 62 10 c0       	push   $0xc0106288
c01037d6:	e8 fe cb ff ff       	call   c01003d9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01037db:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037e0:	6a 00                	push   $0x0
c01037e2:	68 00 10 00 00       	push   $0x1000
c01037e7:	ff 75 f4             	pushl  -0xc(%ebp)
c01037ea:	50                   	push   %eax
c01037eb:	e8 c5 fb ff ff       	call   c01033b5 <page_insert>
c01037f0:	83 c4 10             	add    $0x10,%esp
c01037f3:	85 c0                	test   %eax,%eax
c01037f5:	74 19                	je     c0103810 <check_pgdir+0x32f>
c01037f7:	68 dc 64 10 c0       	push   $0xc01064dc
c01037fc:	68 ad 62 10 c0       	push   $0xc01062ad
c0103801:	68 fc 01 00 00       	push   $0x1fc
c0103806:	68 88 62 10 c0       	push   $0xc0106288
c010380b:	e8 c9 cb ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p1) == 2);
c0103810:	83 ec 0c             	sub    $0xc,%esp
c0103813:	ff 75 f4             	pushl  -0xc(%ebp)
c0103816:	e8 32 f1 ff ff       	call   c010294d <page_ref>
c010381b:	83 c4 10             	add    $0x10,%esp
c010381e:	83 f8 02             	cmp    $0x2,%eax
c0103821:	74 19                	je     c010383c <check_pgdir+0x35b>
c0103823:	68 08 65 10 c0       	push   $0xc0106508
c0103828:	68 ad 62 10 c0       	push   $0xc01062ad
c010382d:	68 fd 01 00 00       	push   $0x1fd
c0103832:	68 88 62 10 c0       	push   $0xc0106288
c0103837:	e8 9d cb ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c010383c:	83 ec 0c             	sub    $0xc,%esp
c010383f:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103842:	e8 06 f1 ff ff       	call   c010294d <page_ref>
c0103847:	83 c4 10             	add    $0x10,%esp
c010384a:	85 c0                	test   %eax,%eax
c010384c:	74 19                	je     c0103867 <check_pgdir+0x386>
c010384e:	68 1a 65 10 c0       	push   $0xc010651a
c0103853:	68 ad 62 10 c0       	push   $0xc01062ad
c0103858:	68 fe 01 00 00       	push   $0x1fe
c010385d:	68 88 62 10 c0       	push   $0xc0106288
c0103862:	e8 72 cb ff ff       	call   c01003d9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103867:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010386c:	83 ec 04             	sub    $0x4,%esp
c010386f:	6a 00                	push   $0x0
c0103871:	68 00 10 00 00       	push   $0x1000
c0103876:	50                   	push   %eax
c0103877:	e8 28 f9 ff ff       	call   c01031a4 <get_pte>
c010387c:	83 c4 10             	add    $0x10,%esp
c010387f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103886:	75 19                	jne    c01038a1 <check_pgdir+0x3c0>
c0103888:	68 68 64 10 c0       	push   $0xc0106468
c010388d:	68 ad 62 10 c0       	push   $0xc01062ad
c0103892:	68 ff 01 00 00       	push   $0x1ff
c0103897:	68 88 62 10 c0       	push   $0xc0106288
c010389c:	e8 38 cb ff ff       	call   c01003d9 <__panic>
    assert(pte2page(*ptep) == p1);
c01038a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038a4:	8b 00                	mov    (%eax),%eax
c01038a6:	83 ec 0c             	sub    $0xc,%esp
c01038a9:	50                   	push   %eax
c01038aa:	e8 48 f0 ff ff       	call   c01028f7 <pte2page>
c01038af:	83 c4 10             	add    $0x10,%esp
c01038b2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01038b5:	74 19                	je     c01038d0 <check_pgdir+0x3ef>
c01038b7:	68 dd 63 10 c0       	push   $0xc01063dd
c01038bc:	68 ad 62 10 c0       	push   $0xc01062ad
c01038c1:	68 00 02 00 00       	push   $0x200
c01038c6:	68 88 62 10 c0       	push   $0xc0106288
c01038cb:	e8 09 cb ff ff       	call   c01003d9 <__panic>
    assert((*ptep & PTE_U) == 0);
c01038d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038d3:	8b 00                	mov    (%eax),%eax
c01038d5:	83 e0 04             	and    $0x4,%eax
c01038d8:	85 c0                	test   %eax,%eax
c01038da:	74 19                	je     c01038f5 <check_pgdir+0x414>
c01038dc:	68 2c 65 10 c0       	push   $0xc010652c
c01038e1:	68 ad 62 10 c0       	push   $0xc01062ad
c01038e6:	68 01 02 00 00       	push   $0x201
c01038eb:	68 88 62 10 c0       	push   $0xc0106288
c01038f0:	e8 e4 ca ff ff       	call   c01003d9 <__panic>

    page_remove(boot_pgdir, 0x0);
c01038f5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01038fa:	83 ec 08             	sub    $0x8,%esp
c01038fd:	6a 00                	push   $0x0
c01038ff:	50                   	push   %eax
c0103900:	e8 77 fa ff ff       	call   c010337c <page_remove>
c0103905:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0103908:	83 ec 0c             	sub    $0xc,%esp
c010390b:	ff 75 f4             	pushl  -0xc(%ebp)
c010390e:	e8 3a f0 ff ff       	call   c010294d <page_ref>
c0103913:	83 c4 10             	add    $0x10,%esp
c0103916:	83 f8 01             	cmp    $0x1,%eax
c0103919:	74 19                	je     c0103934 <check_pgdir+0x453>
c010391b:	68 f3 63 10 c0       	push   $0xc01063f3
c0103920:	68 ad 62 10 c0       	push   $0xc01062ad
c0103925:	68 04 02 00 00       	push   $0x204
c010392a:	68 88 62 10 c0       	push   $0xc0106288
c010392f:	e8 a5 ca ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c0103934:	83 ec 0c             	sub    $0xc,%esp
c0103937:	ff 75 e4             	pushl  -0x1c(%ebp)
c010393a:	e8 0e f0 ff ff       	call   c010294d <page_ref>
c010393f:	83 c4 10             	add    $0x10,%esp
c0103942:	85 c0                	test   %eax,%eax
c0103944:	74 19                	je     c010395f <check_pgdir+0x47e>
c0103946:	68 1a 65 10 c0       	push   $0xc010651a
c010394b:	68 ad 62 10 c0       	push   $0xc01062ad
c0103950:	68 05 02 00 00       	push   $0x205
c0103955:	68 88 62 10 c0       	push   $0xc0106288
c010395a:	e8 7a ca ff ff       	call   c01003d9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010395f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103964:	83 ec 08             	sub    $0x8,%esp
c0103967:	68 00 10 00 00       	push   $0x1000
c010396c:	50                   	push   %eax
c010396d:	e8 0a fa ff ff       	call   c010337c <page_remove>
c0103972:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0103975:	83 ec 0c             	sub    $0xc,%esp
c0103978:	ff 75 f4             	pushl  -0xc(%ebp)
c010397b:	e8 cd ef ff ff       	call   c010294d <page_ref>
c0103980:	83 c4 10             	add    $0x10,%esp
c0103983:	85 c0                	test   %eax,%eax
c0103985:	74 19                	je     c01039a0 <check_pgdir+0x4bf>
c0103987:	68 41 65 10 c0       	push   $0xc0106541
c010398c:	68 ad 62 10 c0       	push   $0xc01062ad
c0103991:	68 08 02 00 00       	push   $0x208
c0103996:	68 88 62 10 c0       	push   $0xc0106288
c010399b:	e8 39 ca ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p2) == 0);
c01039a0:	83 ec 0c             	sub    $0xc,%esp
c01039a3:	ff 75 e4             	pushl  -0x1c(%ebp)
c01039a6:	e8 a2 ef ff ff       	call   c010294d <page_ref>
c01039ab:	83 c4 10             	add    $0x10,%esp
c01039ae:	85 c0                	test   %eax,%eax
c01039b0:	74 19                	je     c01039cb <check_pgdir+0x4ea>
c01039b2:	68 1a 65 10 c0       	push   $0xc010651a
c01039b7:	68 ad 62 10 c0       	push   $0xc01062ad
c01039bc:	68 09 02 00 00       	push   $0x209
c01039c1:	68 88 62 10 c0       	push   $0xc0106288
c01039c6:	e8 0e ca ff ff       	call   c01003d9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01039cb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01039d0:	8b 00                	mov    (%eax),%eax
c01039d2:	83 ec 0c             	sub    $0xc,%esp
c01039d5:	50                   	push   %eax
c01039d6:	e8 56 ef ff ff       	call   c0102931 <pde2page>
c01039db:	83 c4 10             	add    $0x10,%esp
c01039de:	83 ec 0c             	sub    $0xc,%esp
c01039e1:	50                   	push   %eax
c01039e2:	e8 66 ef ff ff       	call   c010294d <page_ref>
c01039e7:	83 c4 10             	add    $0x10,%esp
c01039ea:	83 f8 01             	cmp    $0x1,%eax
c01039ed:	74 19                	je     c0103a08 <check_pgdir+0x527>
c01039ef:	68 54 65 10 c0       	push   $0xc0106554
c01039f4:	68 ad 62 10 c0       	push   $0xc01062ad
c01039f9:	68 0b 02 00 00       	push   $0x20b
c01039fe:	68 88 62 10 c0       	push   $0xc0106288
c0103a03:	e8 d1 c9 ff ff       	call   c01003d9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103a08:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a0d:	8b 00                	mov    (%eax),%eax
c0103a0f:	83 ec 0c             	sub    $0xc,%esp
c0103a12:	50                   	push   %eax
c0103a13:	e8 19 ef ff ff       	call   c0102931 <pde2page>
c0103a18:	83 c4 10             	add    $0x10,%esp
c0103a1b:	83 ec 08             	sub    $0x8,%esp
c0103a1e:	6a 01                	push   $0x1
c0103a20:	50                   	push   %eax
c0103a21:	e8 73 f1 ff ff       	call   c0102b99 <free_pages>
c0103a26:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0103a29:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103a34:	83 ec 0c             	sub    $0xc,%esp
c0103a37:	68 7b 65 10 c0       	push   $0xc010657b
c0103a3c:	e8 32 c8 ff ff       	call   c0100273 <cprintf>
c0103a41:	83 c4 10             	add    $0x10,%esp
}
c0103a44:	90                   	nop
c0103a45:	c9                   	leave  
c0103a46:	c3                   	ret    

c0103a47 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103a47:	55                   	push   %ebp
c0103a48:	89 e5                	mov    %esp,%ebp
c0103a4a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a54:	e9 a3 00 00 00       	jmp    c0103afc <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a62:	c1 e8 0c             	shr    $0xc,%eax
c0103a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a68:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103a6d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103a70:	72 17                	jb     c0103a89 <check_boot_pgdir+0x42>
c0103a72:	ff 75 f0             	pushl  -0x10(%ebp)
c0103a75:	68 c0 61 10 c0       	push   $0xc01061c0
c0103a7a:	68 17 02 00 00       	push   $0x217
c0103a7f:	68 88 62 10 c0       	push   $0xc0106288
c0103a84:	e8 50 c9 ff ff       	call   c01003d9 <__panic>
c0103a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a8c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103a91:	89 c2                	mov    %eax,%edx
c0103a93:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a98:	83 ec 04             	sub    $0x4,%esp
c0103a9b:	6a 00                	push   $0x0
c0103a9d:	52                   	push   %edx
c0103a9e:	50                   	push   %eax
c0103a9f:	e8 00 f7 ff ff       	call   c01031a4 <get_pte>
c0103aa4:	83 c4 10             	add    $0x10,%esp
c0103aa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103aaa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103aae:	75 19                	jne    c0103ac9 <check_boot_pgdir+0x82>
c0103ab0:	68 98 65 10 c0       	push   $0xc0106598
c0103ab5:	68 ad 62 10 c0       	push   $0xc01062ad
c0103aba:	68 17 02 00 00       	push   $0x217
c0103abf:	68 88 62 10 c0       	push   $0xc0106288
c0103ac4:	e8 10 c9 ff ff       	call   c01003d9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103ac9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103acc:	8b 00                	mov    (%eax),%eax
c0103ace:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ad3:	89 c2                	mov    %eax,%edx
c0103ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad8:	39 c2                	cmp    %eax,%edx
c0103ada:	74 19                	je     c0103af5 <check_boot_pgdir+0xae>
c0103adc:	68 d5 65 10 c0       	push   $0xc01065d5
c0103ae1:	68 ad 62 10 c0       	push   $0xc01062ad
c0103ae6:	68 18 02 00 00       	push   $0x218
c0103aeb:	68 88 62 10 c0       	push   $0xc0106288
c0103af0:	e8 e4 c8 ff ff       	call   c01003d9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103af5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103afc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103aff:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b04:	39 c2                	cmp    %eax,%edx
c0103b06:	0f 82 4d ff ff ff    	jb     c0103a59 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103b0c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b11:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103b16:	8b 00                	mov    (%eax),%eax
c0103b18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b1d:	89 c2                	mov    %eax,%edx
c0103b1f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103b27:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103b2e:	77 17                	ja     c0103b47 <check_boot_pgdir+0x100>
c0103b30:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103b33:	68 64 62 10 c0       	push   $0xc0106264
c0103b38:	68 1b 02 00 00       	push   $0x21b
c0103b3d:	68 88 62 10 c0       	push   $0xc0106288
c0103b42:	e8 92 c8 ff ff       	call   c01003d9 <__panic>
c0103b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b4a:	05 00 00 00 40       	add    $0x40000000,%eax
c0103b4f:	39 c2                	cmp    %eax,%edx
c0103b51:	74 19                	je     c0103b6c <check_boot_pgdir+0x125>
c0103b53:	68 ec 65 10 c0       	push   $0xc01065ec
c0103b58:	68 ad 62 10 c0       	push   $0xc01062ad
c0103b5d:	68 1b 02 00 00       	push   $0x21b
c0103b62:	68 88 62 10 c0       	push   $0xc0106288
c0103b67:	e8 6d c8 ff ff       	call   c01003d9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103b6c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b71:	8b 00                	mov    (%eax),%eax
c0103b73:	85 c0                	test   %eax,%eax
c0103b75:	74 19                	je     c0103b90 <check_boot_pgdir+0x149>
c0103b77:	68 20 66 10 c0       	push   $0xc0106620
c0103b7c:	68 ad 62 10 c0       	push   $0xc01062ad
c0103b81:	68 1d 02 00 00       	push   $0x21d
c0103b86:	68 88 62 10 c0       	push   $0xc0106288
c0103b8b:	e8 49 c8 ff ff       	call   c01003d9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103b90:	83 ec 0c             	sub    $0xc,%esp
c0103b93:	6a 01                	push   $0x1
c0103b95:	e8 c1 ef ff ff       	call   c0102b5b <alloc_pages>
c0103b9a:	83 c4 10             	add    $0x10,%esp
c0103b9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103ba0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ba5:	6a 02                	push   $0x2
c0103ba7:	68 00 01 00 00       	push   $0x100
c0103bac:	ff 75 e0             	pushl  -0x20(%ebp)
c0103baf:	50                   	push   %eax
c0103bb0:	e8 00 f8 ff ff       	call   c01033b5 <page_insert>
c0103bb5:	83 c4 10             	add    $0x10,%esp
c0103bb8:	85 c0                	test   %eax,%eax
c0103bba:	74 19                	je     c0103bd5 <check_boot_pgdir+0x18e>
c0103bbc:	68 34 66 10 c0       	push   $0xc0106634
c0103bc1:	68 ad 62 10 c0       	push   $0xc01062ad
c0103bc6:	68 21 02 00 00       	push   $0x221
c0103bcb:	68 88 62 10 c0       	push   $0xc0106288
c0103bd0:	e8 04 c8 ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p) == 1);
c0103bd5:	83 ec 0c             	sub    $0xc,%esp
c0103bd8:	ff 75 e0             	pushl  -0x20(%ebp)
c0103bdb:	e8 6d ed ff ff       	call   c010294d <page_ref>
c0103be0:	83 c4 10             	add    $0x10,%esp
c0103be3:	83 f8 01             	cmp    $0x1,%eax
c0103be6:	74 19                	je     c0103c01 <check_boot_pgdir+0x1ba>
c0103be8:	68 62 66 10 c0       	push   $0xc0106662
c0103bed:	68 ad 62 10 c0       	push   $0xc01062ad
c0103bf2:	68 22 02 00 00       	push   $0x222
c0103bf7:	68 88 62 10 c0       	push   $0xc0106288
c0103bfc:	e8 d8 c7 ff ff       	call   c01003d9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103c01:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c06:	6a 02                	push   $0x2
c0103c08:	68 00 11 00 00       	push   $0x1100
c0103c0d:	ff 75 e0             	pushl  -0x20(%ebp)
c0103c10:	50                   	push   %eax
c0103c11:	e8 9f f7 ff ff       	call   c01033b5 <page_insert>
c0103c16:	83 c4 10             	add    $0x10,%esp
c0103c19:	85 c0                	test   %eax,%eax
c0103c1b:	74 19                	je     c0103c36 <check_boot_pgdir+0x1ef>
c0103c1d:	68 74 66 10 c0       	push   $0xc0106674
c0103c22:	68 ad 62 10 c0       	push   $0xc01062ad
c0103c27:	68 23 02 00 00       	push   $0x223
c0103c2c:	68 88 62 10 c0       	push   $0xc0106288
c0103c31:	e8 a3 c7 ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p) == 2);
c0103c36:	83 ec 0c             	sub    $0xc,%esp
c0103c39:	ff 75 e0             	pushl  -0x20(%ebp)
c0103c3c:	e8 0c ed ff ff       	call   c010294d <page_ref>
c0103c41:	83 c4 10             	add    $0x10,%esp
c0103c44:	83 f8 02             	cmp    $0x2,%eax
c0103c47:	74 19                	je     c0103c62 <check_boot_pgdir+0x21b>
c0103c49:	68 ab 66 10 c0       	push   $0xc01066ab
c0103c4e:	68 ad 62 10 c0       	push   $0xc01062ad
c0103c53:	68 24 02 00 00       	push   $0x224
c0103c58:	68 88 62 10 c0       	push   $0xc0106288
c0103c5d:	e8 77 c7 ff ff       	call   c01003d9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103c62:	c7 45 dc bc 66 10 c0 	movl   $0xc01066bc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103c69:	83 ec 08             	sub    $0x8,%esp
c0103c6c:	ff 75 dc             	pushl  -0x24(%ebp)
c0103c6f:	68 00 01 00 00       	push   $0x100
c0103c74:	e8 80 13 00 00       	call   c0104ff9 <strcpy>
c0103c79:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103c7c:	83 ec 08             	sub    $0x8,%esp
c0103c7f:	68 00 11 00 00       	push   $0x1100
c0103c84:	68 00 01 00 00       	push   $0x100
c0103c89:	e8 e5 13 00 00       	call   c0105073 <strcmp>
c0103c8e:	83 c4 10             	add    $0x10,%esp
c0103c91:	85 c0                	test   %eax,%eax
c0103c93:	74 19                	je     c0103cae <check_boot_pgdir+0x267>
c0103c95:	68 d4 66 10 c0       	push   $0xc01066d4
c0103c9a:	68 ad 62 10 c0       	push   $0xc01062ad
c0103c9f:	68 28 02 00 00       	push   $0x228
c0103ca4:	68 88 62 10 c0       	push   $0xc0106288
c0103ca9:	e8 2b c7 ff ff       	call   c01003d9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103cae:	83 ec 0c             	sub    $0xc,%esp
c0103cb1:	ff 75 e0             	pushl  -0x20(%ebp)
c0103cb4:	e8 f9 eb ff ff       	call   c01028b2 <page2kva>
c0103cb9:	83 c4 10             	add    $0x10,%esp
c0103cbc:	05 00 01 00 00       	add    $0x100,%eax
c0103cc1:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103cc4:	83 ec 0c             	sub    $0xc,%esp
c0103cc7:	68 00 01 00 00       	push   $0x100
c0103ccc:	e8 d0 12 00 00       	call   c0104fa1 <strlen>
c0103cd1:	83 c4 10             	add    $0x10,%esp
c0103cd4:	85 c0                	test   %eax,%eax
c0103cd6:	74 19                	je     c0103cf1 <check_boot_pgdir+0x2aa>
c0103cd8:	68 0c 67 10 c0       	push   $0xc010670c
c0103cdd:	68 ad 62 10 c0       	push   $0xc01062ad
c0103ce2:	68 2b 02 00 00       	push   $0x22b
c0103ce7:	68 88 62 10 c0       	push   $0xc0106288
c0103cec:	e8 e8 c6 ff ff       	call   c01003d9 <__panic>

    free_page(p);
c0103cf1:	83 ec 08             	sub    $0x8,%esp
c0103cf4:	6a 01                	push   $0x1
c0103cf6:	ff 75 e0             	pushl  -0x20(%ebp)
c0103cf9:	e8 9b ee ff ff       	call   c0102b99 <free_pages>
c0103cfe:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c0103d01:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d06:	8b 00                	mov    (%eax),%eax
c0103d08:	83 ec 0c             	sub    $0xc,%esp
c0103d0b:	50                   	push   %eax
c0103d0c:	e8 20 ec ff ff       	call   c0102931 <pde2page>
c0103d11:	83 c4 10             	add    $0x10,%esp
c0103d14:	83 ec 08             	sub    $0x8,%esp
c0103d17:	6a 01                	push   $0x1
c0103d19:	50                   	push   %eax
c0103d1a:	e8 7a ee ff ff       	call   c0102b99 <free_pages>
c0103d1f:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0103d22:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103d2d:	83 ec 0c             	sub    $0xc,%esp
c0103d30:	68 30 67 10 c0       	push   $0xc0106730
c0103d35:	e8 39 c5 ff ff       	call   c0100273 <cprintf>
c0103d3a:	83 c4 10             	add    $0x10,%esp
}
c0103d3d:	90                   	nop
c0103d3e:	c9                   	leave  
c0103d3f:	c3                   	ret    

c0103d40 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103d40:	55                   	push   %ebp
c0103d41:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103d43:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d46:	83 e0 04             	and    $0x4,%eax
c0103d49:	85 c0                	test   %eax,%eax
c0103d4b:	74 07                	je     c0103d54 <perm2str+0x14>
c0103d4d:	b8 75 00 00 00       	mov    $0x75,%eax
c0103d52:	eb 05                	jmp    c0103d59 <perm2str+0x19>
c0103d54:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103d59:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0103d5e:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103d65:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d68:	83 e0 02             	and    $0x2,%eax
c0103d6b:	85 c0                	test   %eax,%eax
c0103d6d:	74 07                	je     c0103d76 <perm2str+0x36>
c0103d6f:	b8 77 00 00 00       	mov    $0x77,%eax
c0103d74:	eb 05                	jmp    c0103d7b <perm2str+0x3b>
c0103d76:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103d7b:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0103d80:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0103d87:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0103d8c:	5d                   	pop    %ebp
c0103d8d:	c3                   	ret    

c0103d8e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103d8e:	55                   	push   %ebp
c0103d8f:	89 e5                	mov    %esp,%ebp
c0103d91:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103d94:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d97:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103d9a:	72 0e                	jb     c0103daa <get_pgtable_items+0x1c>
        return 0;
c0103d9c:	b8 00 00 00 00       	mov    $0x0,%eax
c0103da1:	e9 9a 00 00 00       	jmp    c0103e40 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103da6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0103daa:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dad:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103db0:	73 18                	jae    c0103dca <get_pgtable_items+0x3c>
c0103db2:	8b 45 10             	mov    0x10(%ebp),%eax
c0103db5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103dbc:	8b 45 14             	mov    0x14(%ebp),%eax
c0103dbf:	01 d0                	add    %edx,%eax
c0103dc1:	8b 00                	mov    (%eax),%eax
c0103dc3:	83 e0 01             	and    $0x1,%eax
c0103dc6:	85 c0                	test   %eax,%eax
c0103dc8:	74 dc                	je     c0103da6 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0103dca:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dcd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103dd0:	73 69                	jae    c0103e3b <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0103dd2:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103dd6:	74 08                	je     c0103de0 <get_pgtable_items+0x52>
            *left_store = start;
c0103dd8:	8b 45 18             	mov    0x18(%ebp),%eax
c0103ddb:	8b 55 10             	mov    0x10(%ebp),%edx
c0103dde:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103de0:	8b 45 10             	mov    0x10(%ebp),%eax
c0103de3:	8d 50 01             	lea    0x1(%eax),%edx
c0103de6:	89 55 10             	mov    %edx,0x10(%ebp)
c0103de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103df0:	8b 45 14             	mov    0x14(%ebp),%eax
c0103df3:	01 d0                	add    %edx,%eax
c0103df5:	8b 00                	mov    (%eax),%eax
c0103df7:	83 e0 07             	and    $0x7,%eax
c0103dfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103dfd:	eb 04                	jmp    c0103e03 <get_pgtable_items+0x75>
            start ++;
c0103dff:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103e03:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e06:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e09:	73 1d                	jae    c0103e28 <get_pgtable_items+0x9a>
c0103e0b:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103e15:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e18:	01 d0                	add    %edx,%eax
c0103e1a:	8b 00                	mov    (%eax),%eax
c0103e1c:	83 e0 07             	and    $0x7,%eax
c0103e1f:	89 c2                	mov    %eax,%edx
c0103e21:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103e24:	39 c2                	cmp    %eax,%edx
c0103e26:	74 d7                	je     c0103dff <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c0103e28:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103e2c:	74 08                	je     c0103e36 <get_pgtable_items+0xa8>
            *right_store = start;
c0103e2e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103e31:	8b 55 10             	mov    0x10(%ebp),%edx
c0103e34:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103e39:	eb 05                	jmp    c0103e40 <get_pgtable_items+0xb2>
    }
    return 0;
c0103e3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103e40:	c9                   	leave  
c0103e41:	c3                   	ret    

c0103e42 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103e42:	55                   	push   %ebp
c0103e43:	89 e5                	mov    %esp,%ebp
c0103e45:	57                   	push   %edi
c0103e46:	56                   	push   %esi
c0103e47:	53                   	push   %ebx
c0103e48:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103e4b:	83 ec 0c             	sub    $0xc,%esp
c0103e4e:	68 50 67 10 c0       	push   $0xc0106750
c0103e53:	e8 1b c4 ff ff       	call   c0100273 <cprintf>
c0103e58:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0103e5b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103e62:	e9 e5 00 00 00       	jmp    c0103f4c <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e6a:	83 ec 0c             	sub    $0xc,%esp
c0103e6d:	50                   	push   %eax
c0103e6e:	e8 cd fe ff ff       	call   c0103d40 <perm2str>
c0103e73:	83 c4 10             	add    $0x10,%esp
c0103e76:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0103e78:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e7e:	29 c2                	sub    %eax,%edx
c0103e80:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103e82:	c1 e0 16             	shl    $0x16,%eax
c0103e85:	89 c3                	mov    %eax,%ebx
c0103e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e8a:	c1 e0 16             	shl    $0x16,%eax
c0103e8d:	89 c1                	mov    %eax,%ecx
c0103e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e92:	c1 e0 16             	shl    $0x16,%eax
c0103e95:	89 c2                	mov    %eax,%edx
c0103e97:	8b 75 dc             	mov    -0x24(%ebp),%esi
c0103e9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e9d:	29 c6                	sub    %eax,%esi
c0103e9f:	89 f0                	mov    %esi,%eax
c0103ea1:	83 ec 08             	sub    $0x8,%esp
c0103ea4:	57                   	push   %edi
c0103ea5:	53                   	push   %ebx
c0103ea6:	51                   	push   %ecx
c0103ea7:	52                   	push   %edx
c0103ea8:	50                   	push   %eax
c0103ea9:	68 81 67 10 c0       	push   $0xc0106781
c0103eae:	e8 c0 c3 ff ff       	call   c0100273 <cprintf>
c0103eb3:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0103eb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eb9:	c1 e0 0a             	shl    $0xa,%eax
c0103ebc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103ebf:	eb 4f                	jmp    c0103f10 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec4:	83 ec 0c             	sub    $0xc,%esp
c0103ec7:	50                   	push   %eax
c0103ec8:	e8 73 fe ff ff       	call   c0103d40 <perm2str>
c0103ecd:	83 c4 10             	add    $0x10,%esp
c0103ed0:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0103ed2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103ed5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103ed8:	29 c2                	sub    %eax,%edx
c0103eda:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103edc:	c1 e0 0c             	shl    $0xc,%eax
c0103edf:	89 c3                	mov    %eax,%ebx
c0103ee1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103ee4:	c1 e0 0c             	shl    $0xc,%eax
c0103ee7:	89 c1                	mov    %eax,%ecx
c0103ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103eec:	c1 e0 0c             	shl    $0xc,%eax
c0103eef:	89 c2                	mov    %eax,%edx
c0103ef1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c0103ef4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103ef7:	29 c6                	sub    %eax,%esi
c0103ef9:	89 f0                	mov    %esi,%eax
c0103efb:	83 ec 08             	sub    $0x8,%esp
c0103efe:	57                   	push   %edi
c0103eff:	53                   	push   %ebx
c0103f00:	51                   	push   %ecx
c0103f01:	52                   	push   %edx
c0103f02:	50                   	push   %eax
c0103f03:	68 a0 67 10 c0       	push   $0xc01067a0
c0103f08:	e8 66 c3 ff ff       	call   c0100273 <cprintf>
c0103f0d:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103f10:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0103f15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f18:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f1b:	89 d3                	mov    %edx,%ebx
c0103f1d:	c1 e3 0a             	shl    $0xa,%ebx
c0103f20:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f23:	89 d1                	mov    %edx,%ecx
c0103f25:	c1 e1 0a             	shl    $0xa,%ecx
c0103f28:	83 ec 08             	sub    $0x8,%esp
c0103f2b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0103f2e:	52                   	push   %edx
c0103f2f:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0103f32:	52                   	push   %edx
c0103f33:	56                   	push   %esi
c0103f34:	50                   	push   %eax
c0103f35:	53                   	push   %ebx
c0103f36:	51                   	push   %ecx
c0103f37:	e8 52 fe ff ff       	call   c0103d8e <get_pgtable_items>
c0103f3c:	83 c4 20             	add    $0x20,%esp
c0103f3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f46:	0f 85 75 ff ff ff    	jne    c0103ec1 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103f4c:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0103f51:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f54:	83 ec 08             	sub    $0x8,%esp
c0103f57:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0103f5a:	52                   	push   %edx
c0103f5b:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0103f5e:	52                   	push   %edx
c0103f5f:	51                   	push   %ecx
c0103f60:	50                   	push   %eax
c0103f61:	68 00 04 00 00       	push   $0x400
c0103f66:	6a 00                	push   $0x0
c0103f68:	e8 21 fe ff ff       	call   c0103d8e <get_pgtable_items>
c0103f6d:	83 c4 20             	add    $0x20,%esp
c0103f70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f77:	0f 85 ea fe ff ff    	jne    c0103e67 <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0103f7d:	83 ec 0c             	sub    $0xc,%esp
c0103f80:	68 c4 67 10 c0       	push   $0xc01067c4
c0103f85:	e8 e9 c2 ff ff       	call   c0100273 <cprintf>
c0103f8a:	83 c4 10             	add    $0x10,%esp
}
c0103f8d:	90                   	nop
c0103f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103f91:	5b                   	pop    %ebx
c0103f92:	5e                   	pop    %esi
c0103f93:	5f                   	pop    %edi
c0103f94:	5d                   	pop    %ebp
c0103f95:	c3                   	ret    

c0103f96 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103f96:	55                   	push   %ebp
c0103f97:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103f99:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f9c:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0103fa2:	29 d0                	sub    %edx,%eax
c0103fa4:	c1 f8 02             	sar    $0x2,%eax
c0103fa7:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103fad:	5d                   	pop    %ebp
c0103fae:	c3                   	ret    

c0103faf <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103faf:	55                   	push   %ebp
c0103fb0:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0103fb2:	ff 75 08             	pushl  0x8(%ebp)
c0103fb5:	e8 dc ff ff ff       	call   c0103f96 <page2ppn>
c0103fba:	83 c4 04             	add    $0x4,%esp
c0103fbd:	c1 e0 0c             	shl    $0xc,%eax
}
c0103fc0:	c9                   	leave  
c0103fc1:	c3                   	ret    

c0103fc2 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103fc2:	55                   	push   %ebp
c0103fc3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103fc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fc8:	8b 00                	mov    (%eax),%eax
}
c0103fca:	5d                   	pop    %ebp
c0103fcb:	c3                   	ret    

c0103fcc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103fcc:	55                   	push   %ebp
c0103fcd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103fcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fd5:	89 10                	mov    %edx,(%eax)
}
c0103fd7:	90                   	nop
c0103fd8:	5d                   	pop    %ebp
c0103fd9:	c3                   	ret    

c0103fda <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103fda:	55                   	push   %ebp
c0103fdb:	89 e5                	mov    %esp,%ebp
c0103fdd:	83 ec 10             	sub    $0x10,%esp
c0103fe0:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103fe7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fea:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103fed:	89 50 04             	mov    %edx,0x4(%eax)
c0103ff0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103ff3:	8b 50 04             	mov    0x4(%eax),%edx
c0103ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103ff9:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0103ffb:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104002:	00 00 00 
}
c0104005:	90                   	nop
c0104006:	c9                   	leave  
c0104007:	c3                   	ret    

c0104008 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104008:	55                   	push   %ebp
c0104009:	89 e5                	mov    %esp,%ebp
c010400b:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c010400e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104012:	75 16                	jne    c010402a <default_init_memmap+0x22>
c0104014:	68 f8 67 10 c0       	push   $0xc01067f8
c0104019:	68 fe 67 10 c0       	push   $0xc01067fe
c010401e:	6a 6d                	push   $0x6d
c0104020:	68 13 68 10 c0       	push   $0xc0106813
c0104025:	e8 af c3 ff ff       	call   c01003d9 <__panic>
    struct Page *p = base;
c010402a:	8b 45 08             	mov    0x8(%ebp),%eax
c010402d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104030:	eb 6c                	jmp    c010409e <default_init_memmap+0x96>
        assert(PageReserved(p));
c0104032:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104035:	83 c0 04             	add    $0x4,%eax
c0104038:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010403f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104045:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104048:	0f a3 10             	bt     %edx,(%eax)
c010404b:	19 c0                	sbb    %eax,%eax
c010404d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0104050:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104054:	0f 95 c0             	setne  %al
c0104057:	0f b6 c0             	movzbl %al,%eax
c010405a:	85 c0                	test   %eax,%eax
c010405c:	75 16                	jne    c0104074 <default_init_memmap+0x6c>
c010405e:	68 29 68 10 c0       	push   $0xc0106829
c0104063:	68 fe 67 10 c0       	push   $0xc01067fe
c0104068:	6a 70                	push   $0x70
c010406a:	68 13 68 10 c0       	push   $0xc0106813
c010406f:	e8 65 c3 ff ff       	call   c01003d9 <__panic>
        p->flags = p->property = 0;
c0104074:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104077:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104081:	8b 50 08             	mov    0x8(%eax),%edx
c0104084:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104087:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010408a:	83 ec 08             	sub    $0x8,%esp
c010408d:	6a 00                	push   $0x0
c010408f:	ff 75 f4             	pushl  -0xc(%ebp)
c0104092:	e8 35 ff ff ff       	call   c0103fcc <set_page_ref>
c0104097:	83 c4 10             	add    $0x10,%esp

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010409a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010409e:	8b 55 0c             	mov    0xc(%ebp),%edx
c01040a1:	89 d0                	mov    %edx,%eax
c01040a3:	c1 e0 02             	shl    $0x2,%eax
c01040a6:	01 d0                	add    %edx,%eax
c01040a8:	c1 e0 02             	shl    $0x2,%eax
c01040ab:	89 c2                	mov    %eax,%edx
c01040ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01040b0:	01 d0                	add    %edx,%eax
c01040b2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01040b5:	0f 85 77 ff ff ff    	jne    c0104032 <default_init_memmap+0x2a>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01040bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01040be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01040c1:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01040c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01040c7:	83 c0 04             	add    $0x4,%eax
c01040ca:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c01040d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01040d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01040d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01040da:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01040dd:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01040e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01040e6:	01 d0                	add    %edx,%eax
c01040e8:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    list_add_before(&free_list, &(base->page_link));
c01040ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01040f0:	83 c0 0c             	add    $0xc,%eax
c01040f3:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
c01040fa:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01040fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104100:	8b 00                	mov    (%eax),%eax
c0104102:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104105:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104108:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010410b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010410e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104111:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104114:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104117:	89 10                	mov    %edx,(%eax)
c0104119:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010411c:	8b 10                	mov    (%eax),%edx
c010411e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104121:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104124:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104127:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010412a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010412d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104130:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104133:	89 10                	mov    %edx,(%eax)
}
c0104135:	90                   	nop
c0104136:	c9                   	leave  
c0104137:	c3                   	ret    

c0104138 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104138:	55                   	push   %ebp
c0104139:	89 e5                	mov    %esp,%ebp
c010413b:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010413e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104142:	75 16                	jne    c010415a <default_alloc_pages+0x22>
c0104144:	68 f8 67 10 c0       	push   $0xc01067f8
c0104149:	68 fe 67 10 c0       	push   $0xc01067fe
c010414e:	6a 7c                	push   $0x7c
c0104150:	68 13 68 10 c0       	push   $0xc0106813
c0104155:	e8 7f c2 ff ff       	call   c01003d9 <__panic>
    if (n > nr_free) {
c010415a:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010415f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104162:	73 0a                	jae    c010416e <default_alloc_pages+0x36>
        return NULL;
c0104164:	b8 00 00 00 00       	mov    $0x0,%eax
c0104169:	e9 3d 01 00 00       	jmp    c01042ab <default_alloc_pages+0x173>
    }
    struct Page *page = NULL;
c010416e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104175:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c010417c:	eb 1c                	jmp    c010419a <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c010417e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104181:	83 e8 0c             	sub    $0xc,%eax
c0104184:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0104187:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010418a:	8b 40 08             	mov    0x8(%eax),%eax
c010418d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104190:	72 08                	jb     c010419a <default_alloc_pages+0x62>
            page = p;
c0104192:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104195:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104198:	eb 18                	jmp    c01041b2 <default_alloc_pages+0x7a>
c010419a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010419d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01041a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041a3:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01041a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01041a9:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c01041b0:	75 cc                	jne    c010417e <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01041b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01041b6:	0f 84 ec 00 00 00    	je     c01042a8 <default_alloc_pages+0x170>
        if (page->property > n) {
c01041bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041bf:	8b 40 08             	mov    0x8(%eax),%eax
c01041c2:	3b 45 08             	cmp    0x8(%ebp),%eax
c01041c5:	0f 86 8c 00 00 00    	jbe    c0104257 <default_alloc_pages+0x11f>
            struct Page *p = page + n;
c01041cb:	8b 55 08             	mov    0x8(%ebp),%edx
c01041ce:	89 d0                	mov    %edx,%eax
c01041d0:	c1 e0 02             	shl    $0x2,%eax
c01041d3:	01 d0                	add    %edx,%eax
c01041d5:	c1 e0 02             	shl    $0x2,%eax
c01041d8:	89 c2                	mov    %eax,%edx
c01041da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041dd:	01 d0                	add    %edx,%eax
c01041df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c01041e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041e5:	8b 40 08             	mov    0x8(%eax),%eax
c01041e8:	2b 45 08             	sub    0x8(%ebp),%eax
c01041eb:	89 c2                	mov    %eax,%edx
c01041ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041f0:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01041f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041f6:	83 c0 04             	add    $0x4,%eax
c01041f9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0104200:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104203:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104206:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104209:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c010420c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010420f:	83 c0 0c             	add    $0xc,%eax
c0104212:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104215:	83 c2 0c             	add    $0xc,%edx
c0104218:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010421b:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010421e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104221:	8b 40 04             	mov    0x4(%eax),%eax
c0104224:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104227:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010422a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010422d:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0104230:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104233:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104236:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104239:	89 10                	mov    %edx,(%eax)
c010423b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010423e:	8b 10                	mov    (%eax),%edx
c0104240:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104243:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104246:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104249:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010424c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010424f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104252:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104255:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0104257:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010425a:	83 c0 0c             	add    $0xc,%eax
c010425d:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104260:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104263:	8b 40 04             	mov    0x4(%eax),%eax
c0104266:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104269:	8b 12                	mov    (%edx),%edx
c010426b:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010426e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104271:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104274:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104277:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010427a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010427d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104280:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0104282:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104287:	2b 45 08             	sub    0x8(%ebp),%eax
c010428a:	a3 24 af 11 c0       	mov    %eax,0xc011af24
        ClearPageProperty(page);
c010428f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104292:	83 c0 04             	add    $0x4,%eax
c0104295:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010429c:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010429f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042a5:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01042a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01042ab:	c9                   	leave  
c01042ac:	c3                   	ret    

c01042ad <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01042ad:	55                   	push   %ebp
c01042ae:	89 e5                	mov    %esp,%ebp
c01042b0:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c01042b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01042ba:	75 19                	jne    c01042d5 <default_free_pages+0x28>
c01042bc:	68 f8 67 10 c0       	push   $0xc01067f8
c01042c1:	68 fe 67 10 c0       	push   $0xc01067fe
c01042c6:	68 9a 00 00 00       	push   $0x9a
c01042cb:	68 13 68 10 c0       	push   $0xc0106813
c01042d0:	e8 04 c1 ff ff       	call   c01003d9 <__panic>
    struct Page *p = base;
c01042d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01042d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01042db:	e9 8f 00 00 00       	jmp    c010436f <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c01042e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042e3:	83 c0 04             	add    $0x4,%eax
c01042e6:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c01042ed:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042f0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042f3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042f6:	0f a3 10             	bt     %edx,(%eax)
c01042f9:	19 c0                	sbb    %eax,%eax
c01042fb:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01042fe:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104302:	0f 95 c0             	setne  %al
c0104305:	0f b6 c0             	movzbl %al,%eax
c0104308:	85 c0                	test   %eax,%eax
c010430a:	75 2c                	jne    c0104338 <default_free_pages+0x8b>
c010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010430f:	83 c0 04             	add    $0x4,%eax
c0104312:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104319:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010431c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010431f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104322:	0f a3 10             	bt     %edx,(%eax)
c0104325:	19 c0                	sbb    %eax,%eax
c0104327:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c010432a:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c010432e:	0f 95 c0             	setne  %al
c0104331:	0f b6 c0             	movzbl %al,%eax
c0104334:	85 c0                	test   %eax,%eax
c0104336:	74 19                	je     c0104351 <default_free_pages+0xa4>
c0104338:	68 3c 68 10 c0       	push   $0xc010683c
c010433d:	68 fe 67 10 c0       	push   $0xc01067fe
c0104342:	68 9d 00 00 00       	push   $0x9d
c0104347:	68 13 68 10 c0       	push   $0xc0106813
c010434c:	e8 88 c0 ff ff       	call   c01003d9 <__panic>
        p->flags = 0;
c0104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104354:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010435b:	83 ec 08             	sub    $0x8,%esp
c010435e:	6a 00                	push   $0x0
c0104360:	ff 75 f4             	pushl  -0xc(%ebp)
c0104363:	e8 64 fc ff ff       	call   c0103fcc <set_page_ref>
c0104368:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010436b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010436f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104372:	89 d0                	mov    %edx,%eax
c0104374:	c1 e0 02             	shl    $0x2,%eax
c0104377:	01 d0                	add    %edx,%eax
c0104379:	c1 e0 02             	shl    $0x2,%eax
c010437c:	89 c2                	mov    %eax,%edx
c010437e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104381:	01 d0                	add    %edx,%eax
c0104383:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104386:	0f 85 54 ff ff ff    	jne    c01042e0 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010438c:	8b 45 08             	mov    0x8(%ebp),%eax
c010438f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104392:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104395:	8b 45 08             	mov    0x8(%ebp),%eax
c0104398:	83 c0 04             	add    $0x4,%eax
c010439b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01043a2:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043a5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01043a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01043ab:	0f ab 10             	bts    %edx,(%eax)
c01043ae:	c7 45 e8 1c af 11 c0 	movl   $0xc011af1c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01043b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043b8:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01043bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01043be:	e9 08 01 00 00       	jmp    c01044cb <default_free_pages+0x21e>
        p = le2page(le, page_link);
c01043c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043c6:	83 e8 0c             	sub    $0xc,%eax
c01043c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043d5:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01043d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01043db:	8b 45 08             	mov    0x8(%ebp),%eax
c01043de:	8b 50 08             	mov    0x8(%eax),%edx
c01043e1:	89 d0                	mov    %edx,%eax
c01043e3:	c1 e0 02             	shl    $0x2,%eax
c01043e6:	01 d0                	add    %edx,%eax
c01043e8:	c1 e0 02             	shl    $0x2,%eax
c01043eb:	89 c2                	mov    %eax,%edx
c01043ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f0:	01 d0                	add    %edx,%eax
c01043f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01043f5:	75 5a                	jne    c0104451 <default_free_pages+0x1a4>
            base->property += p->property;
c01043f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01043fa:	8b 50 08             	mov    0x8(%eax),%edx
c01043fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104400:	8b 40 08             	mov    0x8(%eax),%eax
c0104403:	01 c2                	add    %eax,%edx
c0104405:	8b 45 08             	mov    0x8(%ebp),%eax
c0104408:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010440e:	83 c0 04             	add    $0x4,%eax
c0104411:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104418:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010441b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010441e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104421:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0104424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104427:	83 c0 0c             	add    $0xc,%eax
c010442a:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010442d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104430:	8b 40 04             	mov    0x4(%eax),%eax
c0104433:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104436:	8b 12                	mov    (%edx),%edx
c0104438:	89 55 a8             	mov    %edx,-0x58(%ebp)
c010443b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010443e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104441:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104444:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104447:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010444a:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010444d:	89 10                	mov    %edx,(%eax)
c010444f:	eb 7a                	jmp    c01044cb <default_free_pages+0x21e>
        }
        else if (p + p->property == base) {
c0104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104454:	8b 50 08             	mov    0x8(%eax),%edx
c0104457:	89 d0                	mov    %edx,%eax
c0104459:	c1 e0 02             	shl    $0x2,%eax
c010445c:	01 d0                	add    %edx,%eax
c010445e:	c1 e0 02             	shl    $0x2,%eax
c0104461:	89 c2                	mov    %eax,%edx
c0104463:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104466:	01 d0                	add    %edx,%eax
c0104468:	3b 45 08             	cmp    0x8(%ebp),%eax
c010446b:	75 5e                	jne    c01044cb <default_free_pages+0x21e>
            p->property += base->property;
c010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104470:	8b 50 08             	mov    0x8(%eax),%edx
c0104473:	8b 45 08             	mov    0x8(%ebp),%eax
c0104476:	8b 40 08             	mov    0x8(%eax),%eax
c0104479:	01 c2                	add    %eax,%edx
c010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010447e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104481:	8b 45 08             	mov    0x8(%ebp),%eax
c0104484:	83 c0 04             	add    $0x4,%eax
c0104487:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c010448e:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104491:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104494:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104497:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010449a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010449d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a3:	83 c0 0c             	add    $0xc,%eax
c01044a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01044a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044ac:	8b 40 04             	mov    0x4(%eax),%eax
c01044af:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01044b2:	8b 12                	mov    (%edx),%edx
c01044b4:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01044b7:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01044ba:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01044bd:	8b 55 98             	mov    -0x68(%ebp),%edx
c01044c0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01044c3:	8b 45 98             	mov    -0x68(%ebp),%eax
c01044c6:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01044c9:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c01044cb:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c01044d2:	0f 85 eb fe ff ff    	jne    c01043c3 <default_free_pages+0x116>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01044d8:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01044de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044e1:	01 d0                	add    %edx,%eax
c01044e3:	a3 24 af 11 c0       	mov    %eax,0xc011af24
c01044e8:	c7 45 d0 1c af 11 c0 	movl   $0xc011af1c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01044ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01044f2:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01044f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01044f8:	eb 69                	jmp    c0104563 <default_free_pages+0x2b6>
        p = le2page(le, page_link);
c01044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fd:	83 e8 0c             	sub    $0xc,%eax
c0104500:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0104503:	8b 45 08             	mov    0x8(%ebp),%eax
c0104506:	8b 50 08             	mov    0x8(%eax),%edx
c0104509:	89 d0                	mov    %edx,%eax
c010450b:	c1 e0 02             	shl    $0x2,%eax
c010450e:	01 d0                	add    %edx,%eax
c0104510:	c1 e0 02             	shl    $0x2,%eax
c0104513:	89 c2                	mov    %eax,%edx
c0104515:	8b 45 08             	mov    0x8(%ebp),%eax
c0104518:	01 d0                	add    %edx,%eax
c010451a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010451d:	77 35                	ja     c0104554 <default_free_pages+0x2a7>
            assert(base + base->property != p);
c010451f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104522:	8b 50 08             	mov    0x8(%eax),%edx
c0104525:	89 d0                	mov    %edx,%eax
c0104527:	c1 e0 02             	shl    $0x2,%eax
c010452a:	01 d0                	add    %edx,%eax
c010452c:	c1 e0 02             	shl    $0x2,%eax
c010452f:	89 c2                	mov    %eax,%edx
c0104531:	8b 45 08             	mov    0x8(%ebp),%eax
c0104534:	01 d0                	add    %edx,%eax
c0104536:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104539:	75 33                	jne    c010456e <default_free_pages+0x2c1>
c010453b:	68 61 68 10 c0       	push   $0xc0106861
c0104540:	68 fe 67 10 c0       	push   $0xc01067fe
c0104545:	68 b9 00 00 00       	push   $0xb9
c010454a:	68 13 68 10 c0       	push   $0xc0106813
c010454f:	e8 85 be ff ff       	call   c01003d9 <__panic>
c0104554:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104557:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010455a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010455d:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0104560:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0104563:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c010456a:	75 8e                	jne    c01044fa <default_free_pages+0x24d>
c010456c:	eb 01                	jmp    c010456f <default_free_pages+0x2c2>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c010456e:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c010456f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104572:	8d 50 0c             	lea    0xc(%eax),%edx
c0104575:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104578:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010457b:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010457e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104581:	8b 00                	mov    (%eax),%eax
c0104583:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104586:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104589:	89 45 88             	mov    %eax,-0x78(%ebp)
c010458c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010458f:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104592:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104595:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104598:	89 10                	mov    %edx,(%eax)
c010459a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010459d:	8b 10                	mov    (%eax),%edx
c010459f:	8b 45 88             	mov    -0x78(%ebp),%eax
c01045a2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01045a5:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01045a8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01045ab:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01045ae:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01045b1:	8b 55 88             	mov    -0x78(%ebp),%edx
c01045b4:	89 10                	mov    %edx,(%eax)
}
c01045b6:	90                   	nop
c01045b7:	c9                   	leave  
c01045b8:	c3                   	ret    

c01045b9 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01045b9:	55                   	push   %ebp
c01045ba:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01045bc:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c01045c1:	5d                   	pop    %ebp
c01045c2:	c3                   	ret    

c01045c3 <basic_check>:

static void
basic_check(void) {
c01045c3:	55                   	push   %ebp
c01045c4:	89 e5                	mov    %esp,%ebp
c01045c6:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01045c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01045d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01045dc:	83 ec 0c             	sub    $0xc,%esp
c01045df:	6a 01                	push   $0x1
c01045e1:	e8 75 e5 ff ff       	call   c0102b5b <alloc_pages>
c01045e6:	83 c4 10             	add    $0x10,%esp
c01045e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01045ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01045f0:	75 19                	jne    c010460b <basic_check+0x48>
c01045f2:	68 7c 68 10 c0       	push   $0xc010687c
c01045f7:	68 fe 67 10 c0       	push   $0xc01067fe
c01045fc:	68 ca 00 00 00       	push   $0xca
c0104601:	68 13 68 10 c0       	push   $0xc0106813
c0104606:	e8 ce bd ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010460b:	83 ec 0c             	sub    $0xc,%esp
c010460e:	6a 01                	push   $0x1
c0104610:	e8 46 e5 ff ff       	call   c0102b5b <alloc_pages>
c0104615:	83 c4 10             	add    $0x10,%esp
c0104618:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010461b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010461f:	75 19                	jne    c010463a <basic_check+0x77>
c0104621:	68 98 68 10 c0       	push   $0xc0106898
c0104626:	68 fe 67 10 c0       	push   $0xc01067fe
c010462b:	68 cb 00 00 00       	push   $0xcb
c0104630:	68 13 68 10 c0       	push   $0xc0106813
c0104635:	e8 9f bd ff ff       	call   c01003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010463a:	83 ec 0c             	sub    $0xc,%esp
c010463d:	6a 01                	push   $0x1
c010463f:	e8 17 e5 ff ff       	call   c0102b5b <alloc_pages>
c0104644:	83 c4 10             	add    $0x10,%esp
c0104647:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010464a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010464e:	75 19                	jne    c0104669 <basic_check+0xa6>
c0104650:	68 b4 68 10 c0       	push   $0xc01068b4
c0104655:	68 fe 67 10 c0       	push   $0xc01067fe
c010465a:	68 cc 00 00 00       	push   $0xcc
c010465f:	68 13 68 10 c0       	push   $0xc0106813
c0104664:	e8 70 bd ff ff       	call   c01003d9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104669:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010466c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010466f:	74 10                	je     c0104681 <basic_check+0xbe>
c0104671:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104674:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104677:	74 08                	je     c0104681 <basic_check+0xbe>
c0104679:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010467c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010467f:	75 19                	jne    c010469a <basic_check+0xd7>
c0104681:	68 d0 68 10 c0       	push   $0xc01068d0
c0104686:	68 fe 67 10 c0       	push   $0xc01067fe
c010468b:	68 ce 00 00 00       	push   $0xce
c0104690:	68 13 68 10 c0       	push   $0xc0106813
c0104695:	e8 3f bd ff ff       	call   c01003d9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010469a:	83 ec 0c             	sub    $0xc,%esp
c010469d:	ff 75 ec             	pushl  -0x14(%ebp)
c01046a0:	e8 1d f9 ff ff       	call   c0103fc2 <page_ref>
c01046a5:	83 c4 10             	add    $0x10,%esp
c01046a8:	85 c0                	test   %eax,%eax
c01046aa:	75 24                	jne    c01046d0 <basic_check+0x10d>
c01046ac:	83 ec 0c             	sub    $0xc,%esp
c01046af:	ff 75 f0             	pushl  -0x10(%ebp)
c01046b2:	e8 0b f9 ff ff       	call   c0103fc2 <page_ref>
c01046b7:	83 c4 10             	add    $0x10,%esp
c01046ba:	85 c0                	test   %eax,%eax
c01046bc:	75 12                	jne    c01046d0 <basic_check+0x10d>
c01046be:	83 ec 0c             	sub    $0xc,%esp
c01046c1:	ff 75 f4             	pushl  -0xc(%ebp)
c01046c4:	e8 f9 f8 ff ff       	call   c0103fc2 <page_ref>
c01046c9:	83 c4 10             	add    $0x10,%esp
c01046cc:	85 c0                	test   %eax,%eax
c01046ce:	74 19                	je     c01046e9 <basic_check+0x126>
c01046d0:	68 f4 68 10 c0       	push   $0xc01068f4
c01046d5:	68 fe 67 10 c0       	push   $0xc01067fe
c01046da:	68 cf 00 00 00       	push   $0xcf
c01046df:	68 13 68 10 c0       	push   $0xc0106813
c01046e4:	e8 f0 bc ff ff       	call   c01003d9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01046e9:	83 ec 0c             	sub    $0xc,%esp
c01046ec:	ff 75 ec             	pushl  -0x14(%ebp)
c01046ef:	e8 bb f8 ff ff       	call   c0103faf <page2pa>
c01046f4:	83 c4 10             	add    $0x10,%esp
c01046f7:	89 c2                	mov    %eax,%edx
c01046f9:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01046fe:	c1 e0 0c             	shl    $0xc,%eax
c0104701:	39 c2                	cmp    %eax,%edx
c0104703:	72 19                	jb     c010471e <basic_check+0x15b>
c0104705:	68 30 69 10 c0       	push   $0xc0106930
c010470a:	68 fe 67 10 c0       	push   $0xc01067fe
c010470f:	68 d1 00 00 00       	push   $0xd1
c0104714:	68 13 68 10 c0       	push   $0xc0106813
c0104719:	e8 bb bc ff ff       	call   c01003d9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010471e:	83 ec 0c             	sub    $0xc,%esp
c0104721:	ff 75 f0             	pushl  -0x10(%ebp)
c0104724:	e8 86 f8 ff ff       	call   c0103faf <page2pa>
c0104729:	83 c4 10             	add    $0x10,%esp
c010472c:	89 c2                	mov    %eax,%edx
c010472e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104733:	c1 e0 0c             	shl    $0xc,%eax
c0104736:	39 c2                	cmp    %eax,%edx
c0104738:	72 19                	jb     c0104753 <basic_check+0x190>
c010473a:	68 4d 69 10 c0       	push   $0xc010694d
c010473f:	68 fe 67 10 c0       	push   $0xc01067fe
c0104744:	68 d2 00 00 00       	push   $0xd2
c0104749:	68 13 68 10 c0       	push   $0xc0106813
c010474e:	e8 86 bc ff ff       	call   c01003d9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104753:	83 ec 0c             	sub    $0xc,%esp
c0104756:	ff 75 f4             	pushl  -0xc(%ebp)
c0104759:	e8 51 f8 ff ff       	call   c0103faf <page2pa>
c010475e:	83 c4 10             	add    $0x10,%esp
c0104761:	89 c2                	mov    %eax,%edx
c0104763:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104768:	c1 e0 0c             	shl    $0xc,%eax
c010476b:	39 c2                	cmp    %eax,%edx
c010476d:	72 19                	jb     c0104788 <basic_check+0x1c5>
c010476f:	68 6a 69 10 c0       	push   $0xc010696a
c0104774:	68 fe 67 10 c0       	push   $0xc01067fe
c0104779:	68 d3 00 00 00       	push   $0xd3
c010477e:	68 13 68 10 c0       	push   $0xc0106813
c0104783:	e8 51 bc ff ff       	call   c01003d9 <__panic>

    list_entry_t free_list_store = free_list;
c0104788:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c010478d:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104793:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104796:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104799:	c7 45 e4 1c af 11 c0 	movl   $0xc011af1c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01047a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047a6:	89 50 04             	mov    %edx,0x4(%eax)
c01047a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047ac:	8b 50 04             	mov    0x4(%eax),%edx
c01047af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047b2:	89 10                	mov    %edx,(%eax)
c01047b4:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01047bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047be:	8b 40 04             	mov    0x4(%eax),%eax
c01047c1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01047c4:	0f 94 c0             	sete   %al
c01047c7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01047ca:	85 c0                	test   %eax,%eax
c01047cc:	75 19                	jne    c01047e7 <basic_check+0x224>
c01047ce:	68 87 69 10 c0       	push   $0xc0106987
c01047d3:	68 fe 67 10 c0       	push   $0xc01067fe
c01047d8:	68 d7 00 00 00       	push   $0xd7
c01047dd:	68 13 68 10 c0       	push   $0xc0106813
c01047e2:	e8 f2 bb ff ff       	call   c01003d9 <__panic>

    unsigned int nr_free_store = nr_free;
c01047e7:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01047ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01047ef:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c01047f6:	00 00 00 

    assert(alloc_page() == NULL);
c01047f9:	83 ec 0c             	sub    $0xc,%esp
c01047fc:	6a 01                	push   $0x1
c01047fe:	e8 58 e3 ff ff       	call   c0102b5b <alloc_pages>
c0104803:	83 c4 10             	add    $0x10,%esp
c0104806:	85 c0                	test   %eax,%eax
c0104808:	74 19                	je     c0104823 <basic_check+0x260>
c010480a:	68 9e 69 10 c0       	push   $0xc010699e
c010480f:	68 fe 67 10 c0       	push   $0xc01067fe
c0104814:	68 dc 00 00 00       	push   $0xdc
c0104819:	68 13 68 10 c0       	push   $0xc0106813
c010481e:	e8 b6 bb ff ff       	call   c01003d9 <__panic>

    free_page(p0);
c0104823:	83 ec 08             	sub    $0x8,%esp
c0104826:	6a 01                	push   $0x1
c0104828:	ff 75 ec             	pushl  -0x14(%ebp)
c010482b:	e8 69 e3 ff ff       	call   c0102b99 <free_pages>
c0104830:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0104833:	83 ec 08             	sub    $0x8,%esp
c0104836:	6a 01                	push   $0x1
c0104838:	ff 75 f0             	pushl  -0x10(%ebp)
c010483b:	e8 59 e3 ff ff       	call   c0102b99 <free_pages>
c0104840:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0104843:	83 ec 08             	sub    $0x8,%esp
c0104846:	6a 01                	push   $0x1
c0104848:	ff 75 f4             	pushl  -0xc(%ebp)
c010484b:	e8 49 e3 ff ff       	call   c0102b99 <free_pages>
c0104850:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c0104853:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104858:	83 f8 03             	cmp    $0x3,%eax
c010485b:	74 19                	je     c0104876 <basic_check+0x2b3>
c010485d:	68 b3 69 10 c0       	push   $0xc01069b3
c0104862:	68 fe 67 10 c0       	push   $0xc01067fe
c0104867:	68 e1 00 00 00       	push   $0xe1
c010486c:	68 13 68 10 c0       	push   $0xc0106813
c0104871:	e8 63 bb ff ff       	call   c01003d9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104876:	83 ec 0c             	sub    $0xc,%esp
c0104879:	6a 01                	push   $0x1
c010487b:	e8 db e2 ff ff       	call   c0102b5b <alloc_pages>
c0104880:	83 c4 10             	add    $0x10,%esp
c0104883:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104886:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010488a:	75 19                	jne    c01048a5 <basic_check+0x2e2>
c010488c:	68 7c 68 10 c0       	push   $0xc010687c
c0104891:	68 fe 67 10 c0       	push   $0xc01067fe
c0104896:	68 e3 00 00 00       	push   $0xe3
c010489b:	68 13 68 10 c0       	push   $0xc0106813
c01048a0:	e8 34 bb ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01048a5:	83 ec 0c             	sub    $0xc,%esp
c01048a8:	6a 01                	push   $0x1
c01048aa:	e8 ac e2 ff ff       	call   c0102b5b <alloc_pages>
c01048af:	83 c4 10             	add    $0x10,%esp
c01048b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048b9:	75 19                	jne    c01048d4 <basic_check+0x311>
c01048bb:	68 98 68 10 c0       	push   $0xc0106898
c01048c0:	68 fe 67 10 c0       	push   $0xc01067fe
c01048c5:	68 e4 00 00 00       	push   $0xe4
c01048ca:	68 13 68 10 c0       	push   $0xc0106813
c01048cf:	e8 05 bb ff ff       	call   c01003d9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01048d4:	83 ec 0c             	sub    $0xc,%esp
c01048d7:	6a 01                	push   $0x1
c01048d9:	e8 7d e2 ff ff       	call   c0102b5b <alloc_pages>
c01048de:	83 c4 10             	add    $0x10,%esp
c01048e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048e8:	75 19                	jne    c0104903 <basic_check+0x340>
c01048ea:	68 b4 68 10 c0       	push   $0xc01068b4
c01048ef:	68 fe 67 10 c0       	push   $0xc01067fe
c01048f4:	68 e5 00 00 00       	push   $0xe5
c01048f9:	68 13 68 10 c0       	push   $0xc0106813
c01048fe:	e8 d6 ba ff ff       	call   c01003d9 <__panic>

    assert(alloc_page() == NULL);
c0104903:	83 ec 0c             	sub    $0xc,%esp
c0104906:	6a 01                	push   $0x1
c0104908:	e8 4e e2 ff ff       	call   c0102b5b <alloc_pages>
c010490d:	83 c4 10             	add    $0x10,%esp
c0104910:	85 c0                	test   %eax,%eax
c0104912:	74 19                	je     c010492d <basic_check+0x36a>
c0104914:	68 9e 69 10 c0       	push   $0xc010699e
c0104919:	68 fe 67 10 c0       	push   $0xc01067fe
c010491e:	68 e7 00 00 00       	push   $0xe7
c0104923:	68 13 68 10 c0       	push   $0xc0106813
c0104928:	e8 ac ba ff ff       	call   c01003d9 <__panic>

    free_page(p0);
c010492d:	83 ec 08             	sub    $0x8,%esp
c0104930:	6a 01                	push   $0x1
c0104932:	ff 75 ec             	pushl  -0x14(%ebp)
c0104935:	e8 5f e2 ff ff       	call   c0102b99 <free_pages>
c010493a:	83 c4 10             	add    $0x10,%esp
c010493d:	c7 45 e8 1c af 11 c0 	movl   $0xc011af1c,-0x18(%ebp)
c0104944:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104947:	8b 40 04             	mov    0x4(%eax),%eax
c010494a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010494d:	0f 94 c0             	sete   %al
c0104950:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104953:	85 c0                	test   %eax,%eax
c0104955:	74 19                	je     c0104970 <basic_check+0x3ad>
c0104957:	68 c0 69 10 c0       	push   $0xc01069c0
c010495c:	68 fe 67 10 c0       	push   $0xc01067fe
c0104961:	68 ea 00 00 00       	push   $0xea
c0104966:	68 13 68 10 c0       	push   $0xc0106813
c010496b:	e8 69 ba ff ff       	call   c01003d9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104970:	83 ec 0c             	sub    $0xc,%esp
c0104973:	6a 01                	push   $0x1
c0104975:	e8 e1 e1 ff ff       	call   c0102b5b <alloc_pages>
c010497a:	83 c4 10             	add    $0x10,%esp
c010497d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104980:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104983:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104986:	74 19                	je     c01049a1 <basic_check+0x3de>
c0104988:	68 d8 69 10 c0       	push   $0xc01069d8
c010498d:	68 fe 67 10 c0       	push   $0xc01067fe
c0104992:	68 ed 00 00 00       	push   $0xed
c0104997:	68 13 68 10 c0       	push   $0xc0106813
c010499c:	e8 38 ba ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c01049a1:	83 ec 0c             	sub    $0xc,%esp
c01049a4:	6a 01                	push   $0x1
c01049a6:	e8 b0 e1 ff ff       	call   c0102b5b <alloc_pages>
c01049ab:	83 c4 10             	add    $0x10,%esp
c01049ae:	85 c0                	test   %eax,%eax
c01049b0:	74 19                	je     c01049cb <basic_check+0x408>
c01049b2:	68 9e 69 10 c0       	push   $0xc010699e
c01049b7:	68 fe 67 10 c0       	push   $0xc01067fe
c01049bc:	68 ee 00 00 00       	push   $0xee
c01049c1:	68 13 68 10 c0       	push   $0xc0106813
c01049c6:	e8 0e ba ff ff       	call   c01003d9 <__panic>

    assert(nr_free == 0);
c01049cb:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01049d0:	85 c0                	test   %eax,%eax
c01049d2:	74 19                	je     c01049ed <basic_check+0x42a>
c01049d4:	68 f1 69 10 c0       	push   $0xc01069f1
c01049d9:	68 fe 67 10 c0       	push   $0xc01067fe
c01049de:	68 f0 00 00 00       	push   $0xf0
c01049e3:	68 13 68 10 c0       	push   $0xc0106813
c01049e8:	e8 ec b9 ff ff       	call   c01003d9 <__panic>
    free_list = free_list_store;
c01049ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01049f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01049f3:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c01049f8:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c01049fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a01:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104a06:	83 ec 08             	sub    $0x8,%esp
c0104a09:	6a 01                	push   $0x1
c0104a0b:	ff 75 dc             	pushl  -0x24(%ebp)
c0104a0e:	e8 86 e1 ff ff       	call   c0102b99 <free_pages>
c0104a13:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0104a16:	83 ec 08             	sub    $0x8,%esp
c0104a19:	6a 01                	push   $0x1
c0104a1b:	ff 75 f0             	pushl  -0x10(%ebp)
c0104a1e:	e8 76 e1 ff ff       	call   c0102b99 <free_pages>
c0104a23:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0104a26:	83 ec 08             	sub    $0x8,%esp
c0104a29:	6a 01                	push   $0x1
c0104a2b:	ff 75 f4             	pushl  -0xc(%ebp)
c0104a2e:	e8 66 e1 ff ff       	call   c0102b99 <free_pages>
c0104a33:	83 c4 10             	add    $0x10,%esp
}
c0104a36:	90                   	nop
c0104a37:	c9                   	leave  
c0104a38:	c3                   	ret    

c0104a39 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104a39:	55                   	push   %ebp
c0104a3a:	89 e5                	mov    %esp,%ebp
c0104a3c:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0104a42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104a50:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104a57:	eb 60                	jmp    c0104ab9 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c0104a59:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a5c:	83 e8 0c             	sub    $0xc,%eax
c0104a5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0104a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a65:	83 c0 04             	add    $0x4,%eax
c0104a68:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104a6f:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104a72:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104a75:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104a78:	0f a3 10             	bt     %edx,(%eax)
c0104a7b:	19 c0                	sbb    %eax,%eax
c0104a7d:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104a80:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104a84:	0f 95 c0             	setne  %al
c0104a87:	0f b6 c0             	movzbl %al,%eax
c0104a8a:	85 c0                	test   %eax,%eax
c0104a8c:	75 19                	jne    c0104aa7 <default_check+0x6e>
c0104a8e:	68 fe 69 10 c0       	push   $0xc01069fe
c0104a93:	68 fe 67 10 c0       	push   $0xc01067fe
c0104a98:	68 01 01 00 00       	push   $0x101
c0104a9d:	68 13 68 10 c0       	push   $0xc0106813
c0104aa2:	e8 32 b9 ff ff       	call   c01003d9 <__panic>
        count ++, total += p->property;
c0104aa7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104aab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104aae:	8b 50 08             	mov    0x8(%eax),%edx
c0104ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab4:	01 d0                	add    %edx,%eax
c0104ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ab9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104abc:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104abf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ac2:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ac8:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104acf:	75 88                	jne    c0104a59 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104ad1:	e8 f8 e0 ff ff       	call   c0102bce <nr_free_pages>
c0104ad6:	89 c2                	mov    %eax,%edx
c0104ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104adb:	39 c2                	cmp    %eax,%edx
c0104add:	74 19                	je     c0104af8 <default_check+0xbf>
c0104adf:	68 0e 6a 10 c0       	push   $0xc0106a0e
c0104ae4:	68 fe 67 10 c0       	push   $0xc01067fe
c0104ae9:	68 04 01 00 00       	push   $0x104
c0104aee:	68 13 68 10 c0       	push   $0xc0106813
c0104af3:	e8 e1 b8 ff ff       	call   c01003d9 <__panic>

    basic_check();
c0104af8:	e8 c6 fa ff ff       	call   c01045c3 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104afd:	83 ec 0c             	sub    $0xc,%esp
c0104b00:	6a 05                	push   $0x5
c0104b02:	e8 54 e0 ff ff       	call   c0102b5b <alloc_pages>
c0104b07:	83 c4 10             	add    $0x10,%esp
c0104b0a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0104b0d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104b11:	75 19                	jne    c0104b2c <default_check+0xf3>
c0104b13:	68 27 6a 10 c0       	push   $0xc0106a27
c0104b18:	68 fe 67 10 c0       	push   $0xc01067fe
c0104b1d:	68 09 01 00 00       	push   $0x109
c0104b22:	68 13 68 10 c0       	push   $0xc0106813
c0104b27:	e8 ad b8 ff ff       	call   c01003d9 <__panic>
    assert(!PageProperty(p0));
c0104b2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b2f:	83 c0 04             	add    $0x4,%eax
c0104b32:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0104b39:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104b3c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b3f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104b42:	0f a3 10             	bt     %edx,(%eax)
c0104b45:	19 c0                	sbb    %eax,%eax
c0104b47:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104b4a:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104b4e:	0f 95 c0             	setne  %al
c0104b51:	0f b6 c0             	movzbl %al,%eax
c0104b54:	85 c0                	test   %eax,%eax
c0104b56:	74 19                	je     c0104b71 <default_check+0x138>
c0104b58:	68 32 6a 10 c0       	push   $0xc0106a32
c0104b5d:	68 fe 67 10 c0       	push   $0xc01067fe
c0104b62:	68 0a 01 00 00       	push   $0x10a
c0104b67:	68 13 68 10 c0       	push   $0xc0106813
c0104b6c:	e8 68 b8 ff ff       	call   c01003d9 <__panic>

    list_entry_t free_list_store = free_list;
c0104b71:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104b76:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104b7c:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104b7f:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104b82:	c7 45 d0 1c af 11 c0 	movl   $0xc011af1c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104b89:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b8c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104b8f:	89 50 04             	mov    %edx,0x4(%eax)
c0104b92:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b95:	8b 50 04             	mov    0x4(%eax),%edx
c0104b98:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b9b:	89 10                	mov    %edx,(%eax)
c0104b9d:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104ba4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ba7:	8b 40 04             	mov    0x4(%eax),%eax
c0104baa:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104bad:	0f 94 c0             	sete   %al
c0104bb0:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104bb3:	85 c0                	test   %eax,%eax
c0104bb5:	75 19                	jne    c0104bd0 <default_check+0x197>
c0104bb7:	68 87 69 10 c0       	push   $0xc0106987
c0104bbc:	68 fe 67 10 c0       	push   $0xc01067fe
c0104bc1:	68 0e 01 00 00       	push   $0x10e
c0104bc6:	68 13 68 10 c0       	push   $0xc0106813
c0104bcb:	e8 09 b8 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104bd0:	83 ec 0c             	sub    $0xc,%esp
c0104bd3:	6a 01                	push   $0x1
c0104bd5:	e8 81 df ff ff       	call   c0102b5b <alloc_pages>
c0104bda:	83 c4 10             	add    $0x10,%esp
c0104bdd:	85 c0                	test   %eax,%eax
c0104bdf:	74 19                	je     c0104bfa <default_check+0x1c1>
c0104be1:	68 9e 69 10 c0       	push   $0xc010699e
c0104be6:	68 fe 67 10 c0       	push   $0xc01067fe
c0104beb:	68 0f 01 00 00       	push   $0x10f
c0104bf0:	68 13 68 10 c0       	push   $0xc0106813
c0104bf5:	e8 df b7 ff ff       	call   c01003d9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104bfa:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104bff:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0104c02:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104c09:	00 00 00 

    free_pages(p0 + 2, 3);
c0104c0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c0f:	83 c0 28             	add    $0x28,%eax
c0104c12:	83 ec 08             	sub    $0x8,%esp
c0104c15:	6a 03                	push   $0x3
c0104c17:	50                   	push   %eax
c0104c18:	e8 7c df ff ff       	call   c0102b99 <free_pages>
c0104c1d:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0104c20:	83 ec 0c             	sub    $0xc,%esp
c0104c23:	6a 04                	push   $0x4
c0104c25:	e8 31 df ff ff       	call   c0102b5b <alloc_pages>
c0104c2a:	83 c4 10             	add    $0x10,%esp
c0104c2d:	85 c0                	test   %eax,%eax
c0104c2f:	74 19                	je     c0104c4a <default_check+0x211>
c0104c31:	68 44 6a 10 c0       	push   $0xc0106a44
c0104c36:	68 fe 67 10 c0       	push   $0xc01067fe
c0104c3b:	68 15 01 00 00       	push   $0x115
c0104c40:	68 13 68 10 c0       	push   $0xc0106813
c0104c45:	e8 8f b7 ff ff       	call   c01003d9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104c4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c4d:	83 c0 28             	add    $0x28,%eax
c0104c50:	83 c0 04             	add    $0x4,%eax
c0104c53:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104c5a:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104c5d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c60:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c63:	0f a3 10             	bt     %edx,(%eax)
c0104c66:	19 c0                	sbb    %eax,%eax
c0104c68:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104c6b:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104c6f:	0f 95 c0             	setne  %al
c0104c72:	0f b6 c0             	movzbl %al,%eax
c0104c75:	85 c0                	test   %eax,%eax
c0104c77:	74 0e                	je     c0104c87 <default_check+0x24e>
c0104c79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c7c:	83 c0 28             	add    $0x28,%eax
c0104c7f:	8b 40 08             	mov    0x8(%eax),%eax
c0104c82:	83 f8 03             	cmp    $0x3,%eax
c0104c85:	74 19                	je     c0104ca0 <default_check+0x267>
c0104c87:	68 5c 6a 10 c0       	push   $0xc0106a5c
c0104c8c:	68 fe 67 10 c0       	push   $0xc01067fe
c0104c91:	68 16 01 00 00       	push   $0x116
c0104c96:	68 13 68 10 c0       	push   $0xc0106813
c0104c9b:	e8 39 b7 ff ff       	call   c01003d9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104ca0:	83 ec 0c             	sub    $0xc,%esp
c0104ca3:	6a 03                	push   $0x3
c0104ca5:	e8 b1 de ff ff       	call   c0102b5b <alloc_pages>
c0104caa:	83 c4 10             	add    $0x10,%esp
c0104cad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104cb0:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0104cb4:	75 19                	jne    c0104ccf <default_check+0x296>
c0104cb6:	68 88 6a 10 c0       	push   $0xc0106a88
c0104cbb:	68 fe 67 10 c0       	push   $0xc01067fe
c0104cc0:	68 17 01 00 00       	push   $0x117
c0104cc5:	68 13 68 10 c0       	push   $0xc0106813
c0104cca:	e8 0a b7 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104ccf:	83 ec 0c             	sub    $0xc,%esp
c0104cd2:	6a 01                	push   $0x1
c0104cd4:	e8 82 de ff ff       	call   c0102b5b <alloc_pages>
c0104cd9:	83 c4 10             	add    $0x10,%esp
c0104cdc:	85 c0                	test   %eax,%eax
c0104cde:	74 19                	je     c0104cf9 <default_check+0x2c0>
c0104ce0:	68 9e 69 10 c0       	push   $0xc010699e
c0104ce5:	68 fe 67 10 c0       	push   $0xc01067fe
c0104cea:	68 18 01 00 00       	push   $0x118
c0104cef:	68 13 68 10 c0       	push   $0xc0106813
c0104cf4:	e8 e0 b6 ff ff       	call   c01003d9 <__panic>
    assert(p0 + 2 == p1);
c0104cf9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104cfc:	83 c0 28             	add    $0x28,%eax
c0104cff:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0104d02:	74 19                	je     c0104d1d <default_check+0x2e4>
c0104d04:	68 a6 6a 10 c0       	push   $0xc0106aa6
c0104d09:	68 fe 67 10 c0       	push   $0xc01067fe
c0104d0e:	68 19 01 00 00       	push   $0x119
c0104d13:	68 13 68 10 c0       	push   $0xc0106813
c0104d18:	e8 bc b6 ff ff       	call   c01003d9 <__panic>

    p2 = p0 + 1;
c0104d1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d20:	83 c0 14             	add    $0x14,%eax
c0104d23:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0104d26:	83 ec 08             	sub    $0x8,%esp
c0104d29:	6a 01                	push   $0x1
c0104d2b:	ff 75 dc             	pushl  -0x24(%ebp)
c0104d2e:	e8 66 de ff ff       	call   c0102b99 <free_pages>
c0104d33:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0104d36:	83 ec 08             	sub    $0x8,%esp
c0104d39:	6a 03                	push   $0x3
c0104d3b:	ff 75 c4             	pushl  -0x3c(%ebp)
c0104d3e:	e8 56 de ff ff       	call   c0102b99 <free_pages>
c0104d43:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0104d46:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d49:	83 c0 04             	add    $0x4,%eax
c0104d4c:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104d53:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d56:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104d59:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104d5c:	0f a3 10             	bt     %edx,(%eax)
c0104d5f:	19 c0                	sbb    %eax,%eax
c0104d61:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0104d64:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0104d68:	0f 95 c0             	setne  %al
c0104d6b:	0f b6 c0             	movzbl %al,%eax
c0104d6e:	85 c0                	test   %eax,%eax
c0104d70:	74 0b                	je     c0104d7d <default_check+0x344>
c0104d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d75:	8b 40 08             	mov    0x8(%eax),%eax
c0104d78:	83 f8 01             	cmp    $0x1,%eax
c0104d7b:	74 19                	je     c0104d96 <default_check+0x35d>
c0104d7d:	68 b4 6a 10 c0       	push   $0xc0106ab4
c0104d82:	68 fe 67 10 c0       	push   $0xc01067fe
c0104d87:	68 1e 01 00 00       	push   $0x11e
c0104d8c:	68 13 68 10 c0       	push   $0xc0106813
c0104d91:	e8 43 b6 ff ff       	call   c01003d9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104d96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d99:	83 c0 04             	add    $0x4,%eax
c0104d9c:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104da3:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104da6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104da9:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104dac:	0f a3 10             	bt     %edx,(%eax)
c0104daf:	19 c0                	sbb    %eax,%eax
c0104db1:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0104db4:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0104db8:	0f 95 c0             	setne  %al
c0104dbb:	0f b6 c0             	movzbl %al,%eax
c0104dbe:	85 c0                	test   %eax,%eax
c0104dc0:	74 0b                	je     c0104dcd <default_check+0x394>
c0104dc2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104dc5:	8b 40 08             	mov    0x8(%eax),%eax
c0104dc8:	83 f8 03             	cmp    $0x3,%eax
c0104dcb:	74 19                	je     c0104de6 <default_check+0x3ad>
c0104dcd:	68 dc 6a 10 c0       	push   $0xc0106adc
c0104dd2:	68 fe 67 10 c0       	push   $0xc01067fe
c0104dd7:	68 1f 01 00 00       	push   $0x11f
c0104ddc:	68 13 68 10 c0       	push   $0xc0106813
c0104de1:	e8 f3 b5 ff ff       	call   c01003d9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104de6:	83 ec 0c             	sub    $0xc,%esp
c0104de9:	6a 01                	push   $0x1
c0104deb:	e8 6b dd ff ff       	call   c0102b5b <alloc_pages>
c0104df0:	83 c4 10             	add    $0x10,%esp
c0104df3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104df6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104df9:	83 e8 14             	sub    $0x14,%eax
c0104dfc:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104dff:	74 19                	je     c0104e1a <default_check+0x3e1>
c0104e01:	68 02 6b 10 c0       	push   $0xc0106b02
c0104e06:	68 fe 67 10 c0       	push   $0xc01067fe
c0104e0b:	68 21 01 00 00       	push   $0x121
c0104e10:	68 13 68 10 c0       	push   $0xc0106813
c0104e15:	e8 bf b5 ff ff       	call   c01003d9 <__panic>
    free_page(p0);
c0104e1a:	83 ec 08             	sub    $0x8,%esp
c0104e1d:	6a 01                	push   $0x1
c0104e1f:	ff 75 dc             	pushl  -0x24(%ebp)
c0104e22:	e8 72 dd ff ff       	call   c0102b99 <free_pages>
c0104e27:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104e2a:	83 ec 0c             	sub    $0xc,%esp
c0104e2d:	6a 02                	push   $0x2
c0104e2f:	e8 27 dd ff ff       	call   c0102b5b <alloc_pages>
c0104e34:	83 c4 10             	add    $0x10,%esp
c0104e37:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e3a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104e3d:	83 c0 14             	add    $0x14,%eax
c0104e40:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104e43:	74 19                	je     c0104e5e <default_check+0x425>
c0104e45:	68 20 6b 10 c0       	push   $0xc0106b20
c0104e4a:	68 fe 67 10 c0       	push   $0xc01067fe
c0104e4f:	68 23 01 00 00       	push   $0x123
c0104e54:	68 13 68 10 c0       	push   $0xc0106813
c0104e59:	e8 7b b5 ff ff       	call   c01003d9 <__panic>

    free_pages(p0, 2);
c0104e5e:	83 ec 08             	sub    $0x8,%esp
c0104e61:	6a 02                	push   $0x2
c0104e63:	ff 75 dc             	pushl  -0x24(%ebp)
c0104e66:	e8 2e dd ff ff       	call   c0102b99 <free_pages>
c0104e6b:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0104e6e:	83 ec 08             	sub    $0x8,%esp
c0104e71:	6a 01                	push   $0x1
c0104e73:	ff 75 c0             	pushl  -0x40(%ebp)
c0104e76:	e8 1e dd ff ff       	call   c0102b99 <free_pages>
c0104e7b:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c0104e7e:	83 ec 0c             	sub    $0xc,%esp
c0104e81:	6a 05                	push   $0x5
c0104e83:	e8 d3 dc ff ff       	call   c0102b5b <alloc_pages>
c0104e88:	83 c4 10             	add    $0x10,%esp
c0104e8b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e8e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104e92:	75 19                	jne    c0104ead <default_check+0x474>
c0104e94:	68 40 6b 10 c0       	push   $0xc0106b40
c0104e99:	68 fe 67 10 c0       	push   $0xc01067fe
c0104e9e:	68 28 01 00 00       	push   $0x128
c0104ea3:	68 13 68 10 c0       	push   $0xc0106813
c0104ea8:	e8 2c b5 ff ff       	call   c01003d9 <__panic>
    assert(alloc_page() == NULL);
c0104ead:	83 ec 0c             	sub    $0xc,%esp
c0104eb0:	6a 01                	push   $0x1
c0104eb2:	e8 a4 dc ff ff       	call   c0102b5b <alloc_pages>
c0104eb7:	83 c4 10             	add    $0x10,%esp
c0104eba:	85 c0                	test   %eax,%eax
c0104ebc:	74 19                	je     c0104ed7 <default_check+0x49e>
c0104ebe:	68 9e 69 10 c0       	push   $0xc010699e
c0104ec3:	68 fe 67 10 c0       	push   $0xc01067fe
c0104ec8:	68 29 01 00 00       	push   $0x129
c0104ecd:	68 13 68 10 c0       	push   $0xc0106813
c0104ed2:	e8 02 b5 ff ff       	call   c01003d9 <__panic>

    assert(nr_free == 0);
c0104ed7:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104edc:	85 c0                	test   %eax,%eax
c0104ede:	74 19                	je     c0104ef9 <default_check+0x4c0>
c0104ee0:	68 f1 69 10 c0       	push   $0xc01069f1
c0104ee5:	68 fe 67 10 c0       	push   $0xc01067fe
c0104eea:	68 2b 01 00 00       	push   $0x12b
c0104eef:	68 13 68 10 c0       	push   $0xc0106813
c0104ef4:	e8 e0 b4 ff ff       	call   c01003d9 <__panic>
    nr_free = nr_free_store;
c0104ef9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104efc:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c0104f01:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104f04:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104f07:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104f0c:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c0104f12:	83 ec 08             	sub    $0x8,%esp
c0104f15:	6a 05                	push   $0x5
c0104f17:	ff 75 dc             	pushl  -0x24(%ebp)
c0104f1a:	e8 7a dc ff ff       	call   c0102b99 <free_pages>
c0104f1f:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0104f22:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104f29:	eb 1d                	jmp    c0104f48 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0104f2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f2e:	83 e8 0c             	sub    $0xc,%eax
c0104f31:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0104f34:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104f38:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104f3b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f3e:	8b 40 08             	mov    0x8(%eax),%eax
c0104f41:	29 c2                	sub    %eax,%edx
c0104f43:	89 d0                	mov    %edx,%eax
c0104f45:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f4b:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104f4e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104f51:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104f54:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104f57:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104f5e:	75 cb                	jne    c0104f2b <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0104f60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f64:	74 19                	je     c0104f7f <default_check+0x546>
c0104f66:	68 5e 6b 10 c0       	push   $0xc0106b5e
c0104f6b:	68 fe 67 10 c0       	push   $0xc01067fe
c0104f70:	68 36 01 00 00       	push   $0x136
c0104f75:	68 13 68 10 c0       	push   $0xc0106813
c0104f7a:	e8 5a b4 ff ff       	call   c01003d9 <__panic>
    assert(total == 0);
c0104f7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f83:	74 19                	je     c0104f9e <default_check+0x565>
c0104f85:	68 69 6b 10 c0       	push   $0xc0106b69
c0104f8a:	68 fe 67 10 c0       	push   $0xc01067fe
c0104f8f:	68 37 01 00 00       	push   $0x137
c0104f94:	68 13 68 10 c0       	push   $0xc0106813
c0104f99:	e8 3b b4 ff ff       	call   c01003d9 <__panic>
}
c0104f9e:	90                   	nop
c0104f9f:	c9                   	leave  
c0104fa0:	c3                   	ret    

c0104fa1 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0104fa1:	55                   	push   %ebp
c0104fa2:	89 e5                	mov    %esp,%ebp
c0104fa4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0104fa7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0104fae:	eb 04                	jmp    c0104fb4 <strlen+0x13>
        cnt ++;
c0104fb0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0104fb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fb7:	8d 50 01             	lea    0x1(%eax),%edx
c0104fba:	89 55 08             	mov    %edx,0x8(%ebp)
c0104fbd:	0f b6 00             	movzbl (%eax),%eax
c0104fc0:	84 c0                	test   %al,%al
c0104fc2:	75 ec                	jne    c0104fb0 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0104fc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104fc7:	c9                   	leave  
c0104fc8:	c3                   	ret    

c0104fc9 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0104fc9:	55                   	push   %ebp
c0104fca:	89 e5                	mov    %esp,%ebp
c0104fcc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0104fcf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0104fd6:	eb 04                	jmp    c0104fdc <strnlen+0x13>
        cnt ++;
c0104fd8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0104fdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104fdf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104fe2:	73 10                	jae    c0104ff4 <strnlen+0x2b>
c0104fe4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fe7:	8d 50 01             	lea    0x1(%eax),%edx
c0104fea:	89 55 08             	mov    %edx,0x8(%ebp)
c0104fed:	0f b6 00             	movzbl (%eax),%eax
c0104ff0:	84 c0                	test   %al,%al
c0104ff2:	75 e4                	jne    c0104fd8 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0104ff4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104ff7:	c9                   	leave  
c0104ff8:	c3                   	ret    

c0104ff9 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0104ff9:	55                   	push   %ebp
c0104ffa:	89 e5                	mov    %esp,%ebp
c0104ffc:	57                   	push   %edi
c0104ffd:	56                   	push   %esi
c0104ffe:	83 ec 20             	sub    $0x20,%esp
c0105001:	8b 45 08             	mov    0x8(%ebp),%eax
c0105004:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105007:	8b 45 0c             	mov    0xc(%ebp),%eax
c010500a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010500d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105010:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105013:	89 d1                	mov    %edx,%ecx
c0105015:	89 c2                	mov    %eax,%edx
c0105017:	89 ce                	mov    %ecx,%esi
c0105019:	89 d7                	mov    %edx,%edi
c010501b:	ac                   	lods   %ds:(%esi),%al
c010501c:	aa                   	stos   %al,%es:(%edi)
c010501d:	84 c0                	test   %al,%al
c010501f:	75 fa                	jne    c010501b <strcpy+0x22>
c0105021:	89 fa                	mov    %edi,%edx
c0105023:	89 f1                	mov    %esi,%ecx
c0105025:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105028:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010502b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010502e:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105031:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105032:	83 c4 20             	add    $0x20,%esp
c0105035:	5e                   	pop    %esi
c0105036:	5f                   	pop    %edi
c0105037:	5d                   	pop    %ebp
c0105038:	c3                   	ret    

c0105039 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105039:	55                   	push   %ebp
c010503a:	89 e5                	mov    %esp,%ebp
c010503c:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010503f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105042:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105045:	eb 21                	jmp    c0105068 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105047:	8b 45 0c             	mov    0xc(%ebp),%eax
c010504a:	0f b6 10             	movzbl (%eax),%edx
c010504d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105050:	88 10                	mov    %dl,(%eax)
c0105052:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105055:	0f b6 00             	movzbl (%eax),%eax
c0105058:	84 c0                	test   %al,%al
c010505a:	74 04                	je     c0105060 <strncpy+0x27>
            src ++;
c010505c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105060:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105064:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105068:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010506c:	75 d9                	jne    c0105047 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010506e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105071:	c9                   	leave  
c0105072:	c3                   	ret    

c0105073 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105073:	55                   	push   %ebp
c0105074:	89 e5                	mov    %esp,%ebp
c0105076:	57                   	push   %edi
c0105077:	56                   	push   %esi
c0105078:	83 ec 20             	sub    $0x20,%esp
c010507b:	8b 45 08             	mov    0x8(%ebp),%eax
c010507e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105081:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105084:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105087:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010508a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010508d:	89 d1                	mov    %edx,%ecx
c010508f:	89 c2                	mov    %eax,%edx
c0105091:	89 ce                	mov    %ecx,%esi
c0105093:	89 d7                	mov    %edx,%edi
c0105095:	ac                   	lods   %ds:(%esi),%al
c0105096:	ae                   	scas   %es:(%edi),%al
c0105097:	75 08                	jne    c01050a1 <strcmp+0x2e>
c0105099:	84 c0                	test   %al,%al
c010509b:	75 f8                	jne    c0105095 <strcmp+0x22>
c010509d:	31 c0                	xor    %eax,%eax
c010509f:	eb 04                	jmp    c01050a5 <strcmp+0x32>
c01050a1:	19 c0                	sbb    %eax,%eax
c01050a3:	0c 01                	or     $0x1,%al
c01050a5:	89 fa                	mov    %edi,%edx
c01050a7:	89 f1                	mov    %esi,%ecx
c01050a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01050ac:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01050af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01050b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01050b5:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01050b6:	83 c4 20             	add    $0x20,%esp
c01050b9:	5e                   	pop    %esi
c01050ba:	5f                   	pop    %edi
c01050bb:	5d                   	pop    %ebp
c01050bc:	c3                   	ret    

c01050bd <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01050bd:	55                   	push   %ebp
c01050be:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01050c0:	eb 0c                	jmp    c01050ce <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01050c2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01050c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01050ca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01050ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050d2:	74 1a                	je     c01050ee <strncmp+0x31>
c01050d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01050d7:	0f b6 00             	movzbl (%eax),%eax
c01050da:	84 c0                	test   %al,%al
c01050dc:	74 10                	je     c01050ee <strncmp+0x31>
c01050de:	8b 45 08             	mov    0x8(%ebp),%eax
c01050e1:	0f b6 10             	movzbl (%eax),%edx
c01050e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050e7:	0f b6 00             	movzbl (%eax),%eax
c01050ea:	38 c2                	cmp    %al,%dl
c01050ec:	74 d4                	je     c01050c2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01050ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050f2:	74 18                	je     c010510c <strncmp+0x4f>
c01050f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f7:	0f b6 00             	movzbl (%eax),%eax
c01050fa:	0f b6 d0             	movzbl %al,%edx
c01050fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105100:	0f b6 00             	movzbl (%eax),%eax
c0105103:	0f b6 c0             	movzbl %al,%eax
c0105106:	29 c2                	sub    %eax,%edx
c0105108:	89 d0                	mov    %edx,%eax
c010510a:	eb 05                	jmp    c0105111 <strncmp+0x54>
c010510c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105111:	5d                   	pop    %ebp
c0105112:	c3                   	ret    

c0105113 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105113:	55                   	push   %ebp
c0105114:	89 e5                	mov    %esp,%ebp
c0105116:	83 ec 04             	sub    $0x4,%esp
c0105119:	8b 45 0c             	mov    0xc(%ebp),%eax
c010511c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010511f:	eb 14                	jmp    c0105135 <strchr+0x22>
        if (*s == c) {
c0105121:	8b 45 08             	mov    0x8(%ebp),%eax
c0105124:	0f b6 00             	movzbl (%eax),%eax
c0105127:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010512a:	75 05                	jne    c0105131 <strchr+0x1e>
            return (char *)s;
c010512c:	8b 45 08             	mov    0x8(%ebp),%eax
c010512f:	eb 13                	jmp    c0105144 <strchr+0x31>
        }
        s ++;
c0105131:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105135:	8b 45 08             	mov    0x8(%ebp),%eax
c0105138:	0f b6 00             	movzbl (%eax),%eax
c010513b:	84 c0                	test   %al,%al
c010513d:	75 e2                	jne    c0105121 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010513f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105144:	c9                   	leave  
c0105145:	c3                   	ret    

c0105146 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105146:	55                   	push   %ebp
c0105147:	89 e5                	mov    %esp,%ebp
c0105149:	83 ec 04             	sub    $0x4,%esp
c010514c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010514f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105152:	eb 0f                	jmp    c0105163 <strfind+0x1d>
        if (*s == c) {
c0105154:	8b 45 08             	mov    0x8(%ebp),%eax
c0105157:	0f b6 00             	movzbl (%eax),%eax
c010515a:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010515d:	74 10                	je     c010516f <strfind+0x29>
            break;
        }
        s ++;
c010515f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105163:	8b 45 08             	mov    0x8(%ebp),%eax
c0105166:	0f b6 00             	movzbl (%eax),%eax
c0105169:	84 c0                	test   %al,%al
c010516b:	75 e7                	jne    c0105154 <strfind+0xe>
c010516d:	eb 01                	jmp    c0105170 <strfind+0x2a>
        if (*s == c) {
            break;
c010516f:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0105170:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105173:	c9                   	leave  
c0105174:	c3                   	ret    

c0105175 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105175:	55                   	push   %ebp
c0105176:	89 e5                	mov    %esp,%ebp
c0105178:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010517b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105182:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105189:	eb 04                	jmp    c010518f <strtol+0x1a>
        s ++;
c010518b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010518f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105192:	0f b6 00             	movzbl (%eax),%eax
c0105195:	3c 20                	cmp    $0x20,%al
c0105197:	74 f2                	je     c010518b <strtol+0x16>
c0105199:	8b 45 08             	mov    0x8(%ebp),%eax
c010519c:	0f b6 00             	movzbl (%eax),%eax
c010519f:	3c 09                	cmp    $0x9,%al
c01051a1:	74 e8                	je     c010518b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01051a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a6:	0f b6 00             	movzbl (%eax),%eax
c01051a9:	3c 2b                	cmp    $0x2b,%al
c01051ab:	75 06                	jne    c01051b3 <strtol+0x3e>
        s ++;
c01051ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01051b1:	eb 15                	jmp    c01051c8 <strtol+0x53>
    }
    else if (*s == '-') {
c01051b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01051b6:	0f b6 00             	movzbl (%eax),%eax
c01051b9:	3c 2d                	cmp    $0x2d,%al
c01051bb:	75 0b                	jne    c01051c8 <strtol+0x53>
        s ++, neg = 1;
c01051bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01051c1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01051c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01051cc:	74 06                	je     c01051d4 <strtol+0x5f>
c01051ce:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01051d2:	75 24                	jne    c01051f8 <strtol+0x83>
c01051d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01051d7:	0f b6 00             	movzbl (%eax),%eax
c01051da:	3c 30                	cmp    $0x30,%al
c01051dc:	75 1a                	jne    c01051f8 <strtol+0x83>
c01051de:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e1:	83 c0 01             	add    $0x1,%eax
c01051e4:	0f b6 00             	movzbl (%eax),%eax
c01051e7:	3c 78                	cmp    $0x78,%al
c01051e9:	75 0d                	jne    c01051f8 <strtol+0x83>
        s += 2, base = 16;
c01051eb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01051ef:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01051f6:	eb 2a                	jmp    c0105222 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c01051f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01051fc:	75 17                	jne    c0105215 <strtol+0xa0>
c01051fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105201:	0f b6 00             	movzbl (%eax),%eax
c0105204:	3c 30                	cmp    $0x30,%al
c0105206:	75 0d                	jne    c0105215 <strtol+0xa0>
        s ++, base = 8;
c0105208:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010520c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105213:	eb 0d                	jmp    c0105222 <strtol+0xad>
    }
    else if (base == 0) {
c0105215:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105219:	75 07                	jne    c0105222 <strtol+0xad>
        base = 10;
c010521b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105222:	8b 45 08             	mov    0x8(%ebp),%eax
c0105225:	0f b6 00             	movzbl (%eax),%eax
c0105228:	3c 2f                	cmp    $0x2f,%al
c010522a:	7e 1b                	jle    c0105247 <strtol+0xd2>
c010522c:	8b 45 08             	mov    0x8(%ebp),%eax
c010522f:	0f b6 00             	movzbl (%eax),%eax
c0105232:	3c 39                	cmp    $0x39,%al
c0105234:	7f 11                	jg     c0105247 <strtol+0xd2>
            dig = *s - '0';
c0105236:	8b 45 08             	mov    0x8(%ebp),%eax
c0105239:	0f b6 00             	movzbl (%eax),%eax
c010523c:	0f be c0             	movsbl %al,%eax
c010523f:	83 e8 30             	sub    $0x30,%eax
c0105242:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105245:	eb 48                	jmp    c010528f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105247:	8b 45 08             	mov    0x8(%ebp),%eax
c010524a:	0f b6 00             	movzbl (%eax),%eax
c010524d:	3c 60                	cmp    $0x60,%al
c010524f:	7e 1b                	jle    c010526c <strtol+0xf7>
c0105251:	8b 45 08             	mov    0x8(%ebp),%eax
c0105254:	0f b6 00             	movzbl (%eax),%eax
c0105257:	3c 7a                	cmp    $0x7a,%al
c0105259:	7f 11                	jg     c010526c <strtol+0xf7>
            dig = *s - 'a' + 10;
c010525b:	8b 45 08             	mov    0x8(%ebp),%eax
c010525e:	0f b6 00             	movzbl (%eax),%eax
c0105261:	0f be c0             	movsbl %al,%eax
c0105264:	83 e8 57             	sub    $0x57,%eax
c0105267:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010526a:	eb 23                	jmp    c010528f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010526c:	8b 45 08             	mov    0x8(%ebp),%eax
c010526f:	0f b6 00             	movzbl (%eax),%eax
c0105272:	3c 40                	cmp    $0x40,%al
c0105274:	7e 3c                	jle    c01052b2 <strtol+0x13d>
c0105276:	8b 45 08             	mov    0x8(%ebp),%eax
c0105279:	0f b6 00             	movzbl (%eax),%eax
c010527c:	3c 5a                	cmp    $0x5a,%al
c010527e:	7f 32                	jg     c01052b2 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0105280:	8b 45 08             	mov    0x8(%ebp),%eax
c0105283:	0f b6 00             	movzbl (%eax),%eax
c0105286:	0f be c0             	movsbl %al,%eax
c0105289:	83 e8 37             	sub    $0x37,%eax
c010528c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010528f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105292:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105295:	7d 1a                	jge    c01052b1 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c0105297:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010529b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010529e:	0f af 45 10          	imul   0x10(%ebp),%eax
c01052a2:	89 c2                	mov    %eax,%edx
c01052a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052a7:	01 d0                	add    %edx,%eax
c01052a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01052ac:	e9 71 ff ff ff       	jmp    c0105222 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c01052b1:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c01052b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01052b6:	74 08                	je     c01052c0 <strtol+0x14b>
        *endptr = (char *) s;
c01052b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01052be:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01052c0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01052c4:	74 07                	je     c01052cd <strtol+0x158>
c01052c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01052c9:	f7 d8                	neg    %eax
c01052cb:	eb 03                	jmp    c01052d0 <strtol+0x15b>
c01052cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01052d0:	c9                   	leave  
c01052d1:	c3                   	ret    

c01052d2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01052d2:	55                   	push   %ebp
c01052d3:	89 e5                	mov    %esp,%ebp
c01052d5:	57                   	push   %edi
c01052d6:	83 ec 24             	sub    $0x24,%esp
c01052d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052dc:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01052df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01052e3:	8b 55 08             	mov    0x8(%ebp),%edx
c01052e6:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01052e9:	88 45 f7             	mov    %al,-0x9(%ebp)
c01052ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01052ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01052f2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01052f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01052f9:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01052fc:	89 d7                	mov    %edx,%edi
c01052fe:	f3 aa                	rep stos %al,%es:(%edi)
c0105300:	89 fa                	mov    %edi,%edx
c0105302:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105305:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105308:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010530b:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010530c:	83 c4 24             	add    $0x24,%esp
c010530f:	5f                   	pop    %edi
c0105310:	5d                   	pop    %ebp
c0105311:	c3                   	ret    

c0105312 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105312:	55                   	push   %ebp
c0105313:	89 e5                	mov    %esp,%ebp
c0105315:	57                   	push   %edi
c0105316:	56                   	push   %esi
c0105317:	53                   	push   %ebx
c0105318:	83 ec 30             	sub    $0x30,%esp
c010531b:	8b 45 08             	mov    0x8(%ebp),%eax
c010531e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105321:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105324:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105327:	8b 45 10             	mov    0x10(%ebp),%eax
c010532a:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010532d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105330:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105333:	73 42                	jae    c0105377 <memmove+0x65>
c0105335:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010533b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010533e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105341:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105344:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105347:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010534a:	c1 e8 02             	shr    $0x2,%eax
c010534d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010534f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105352:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105355:	89 d7                	mov    %edx,%edi
c0105357:	89 c6                	mov    %eax,%esi
c0105359:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010535b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010535e:	83 e1 03             	and    $0x3,%ecx
c0105361:	74 02                	je     c0105365 <memmove+0x53>
c0105363:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105365:	89 f0                	mov    %esi,%eax
c0105367:	89 fa                	mov    %edi,%edx
c0105369:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010536c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010536f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0105375:	eb 36                	jmp    c01053ad <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105377:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010537a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010537d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105380:	01 c2                	add    %eax,%edx
c0105382:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105385:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105388:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010538b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010538e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105391:	89 c1                	mov    %eax,%ecx
c0105393:	89 d8                	mov    %ebx,%eax
c0105395:	89 d6                	mov    %edx,%esi
c0105397:	89 c7                	mov    %eax,%edi
c0105399:	fd                   	std    
c010539a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010539c:	fc                   	cld    
c010539d:	89 f8                	mov    %edi,%eax
c010539f:	89 f2                	mov    %esi,%edx
c01053a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01053a4:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01053a7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01053aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01053ad:	83 c4 30             	add    $0x30,%esp
c01053b0:	5b                   	pop    %ebx
c01053b1:	5e                   	pop    %esi
c01053b2:	5f                   	pop    %edi
c01053b3:	5d                   	pop    %ebp
c01053b4:	c3                   	ret    

c01053b5 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01053b5:	55                   	push   %ebp
c01053b6:	89 e5                	mov    %esp,%ebp
c01053b8:	57                   	push   %edi
c01053b9:	56                   	push   %esi
c01053ba:	83 ec 20             	sub    $0x20,%esp
c01053bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01053cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01053cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053d2:	c1 e8 02             	shr    $0x2,%eax
c01053d5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01053d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053dd:	89 d7                	mov    %edx,%edi
c01053df:	89 c6                	mov    %eax,%esi
c01053e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01053e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01053e6:	83 e1 03             	and    $0x3,%ecx
c01053e9:	74 02                	je     c01053ed <memcpy+0x38>
c01053eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01053ed:	89 f0                	mov    %esi,%eax
c01053ef:	89 fa                	mov    %edi,%edx
c01053f1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01053f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01053f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01053fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c01053fd:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01053fe:	83 c4 20             	add    $0x20,%esp
c0105401:	5e                   	pop    %esi
c0105402:	5f                   	pop    %edi
c0105403:	5d                   	pop    %ebp
c0105404:	c3                   	ret    

c0105405 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105405:	55                   	push   %ebp
c0105406:	89 e5                	mov    %esp,%ebp
c0105408:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010540b:	8b 45 08             	mov    0x8(%ebp),%eax
c010540e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105411:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105414:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105417:	eb 30                	jmp    c0105449 <memcmp+0x44>
        if (*s1 != *s2) {
c0105419:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010541c:	0f b6 10             	movzbl (%eax),%edx
c010541f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105422:	0f b6 00             	movzbl (%eax),%eax
c0105425:	38 c2                	cmp    %al,%dl
c0105427:	74 18                	je     c0105441 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105429:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010542c:	0f b6 00             	movzbl (%eax),%eax
c010542f:	0f b6 d0             	movzbl %al,%edx
c0105432:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105435:	0f b6 00             	movzbl (%eax),%eax
c0105438:	0f b6 c0             	movzbl %al,%eax
c010543b:	29 c2                	sub    %eax,%edx
c010543d:	89 d0                	mov    %edx,%eax
c010543f:	eb 1a                	jmp    c010545b <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105441:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105445:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105449:	8b 45 10             	mov    0x10(%ebp),%eax
c010544c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010544f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105452:	85 c0                	test   %eax,%eax
c0105454:	75 c3                	jne    c0105419 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105456:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010545b:	c9                   	leave  
c010545c:	c3                   	ret    

c010545d <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010545d:	55                   	push   %ebp
c010545e:	89 e5                	mov    %esp,%ebp
c0105460:	83 ec 38             	sub    $0x38,%esp
c0105463:	8b 45 10             	mov    0x10(%ebp),%eax
c0105466:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105469:	8b 45 14             	mov    0x14(%ebp),%eax
c010546c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010546f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105472:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105475:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105478:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010547b:	8b 45 18             	mov    0x18(%ebp),%eax
c010547e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105481:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105484:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105487:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010548a:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010548d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105490:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105497:	74 1c                	je     c01054b5 <printnum+0x58>
c0105499:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010549c:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a1:	f7 75 e4             	divl   -0x1c(%ebp)
c01054a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01054a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054aa:	ba 00 00 00 00       	mov    $0x0,%edx
c01054af:	f7 75 e4             	divl   -0x1c(%ebp)
c01054b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054bb:	f7 75 e4             	divl   -0x1c(%ebp)
c01054be:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01054c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01054ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054cd:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01054d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054d3:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01054d6:	8b 45 18             	mov    0x18(%ebp),%eax
c01054d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01054de:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054e1:	77 41                	ja     c0105524 <printnum+0xc7>
c01054e3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054e6:	72 05                	jb     c01054ed <printnum+0x90>
c01054e8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01054eb:	77 37                	ja     c0105524 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01054ed:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01054f0:	83 e8 01             	sub    $0x1,%eax
c01054f3:	83 ec 04             	sub    $0x4,%esp
c01054f6:	ff 75 20             	pushl  0x20(%ebp)
c01054f9:	50                   	push   %eax
c01054fa:	ff 75 18             	pushl  0x18(%ebp)
c01054fd:	ff 75 ec             	pushl  -0x14(%ebp)
c0105500:	ff 75 e8             	pushl  -0x18(%ebp)
c0105503:	ff 75 0c             	pushl  0xc(%ebp)
c0105506:	ff 75 08             	pushl  0x8(%ebp)
c0105509:	e8 4f ff ff ff       	call   c010545d <printnum>
c010550e:	83 c4 20             	add    $0x20,%esp
c0105511:	eb 1b                	jmp    c010552e <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105513:	83 ec 08             	sub    $0x8,%esp
c0105516:	ff 75 0c             	pushl  0xc(%ebp)
c0105519:	ff 75 20             	pushl  0x20(%ebp)
c010551c:	8b 45 08             	mov    0x8(%ebp),%eax
c010551f:	ff d0                	call   *%eax
c0105521:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105524:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0105528:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010552c:	7f e5                	jg     c0105513 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010552e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105531:	05 24 6c 10 c0       	add    $0xc0106c24,%eax
c0105536:	0f b6 00             	movzbl (%eax),%eax
c0105539:	0f be c0             	movsbl %al,%eax
c010553c:	83 ec 08             	sub    $0x8,%esp
c010553f:	ff 75 0c             	pushl  0xc(%ebp)
c0105542:	50                   	push   %eax
c0105543:	8b 45 08             	mov    0x8(%ebp),%eax
c0105546:	ff d0                	call   *%eax
c0105548:	83 c4 10             	add    $0x10,%esp
}
c010554b:	90                   	nop
c010554c:	c9                   	leave  
c010554d:	c3                   	ret    

c010554e <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010554e:	55                   	push   %ebp
c010554f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105551:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105555:	7e 14                	jle    c010556b <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105557:	8b 45 08             	mov    0x8(%ebp),%eax
c010555a:	8b 00                	mov    (%eax),%eax
c010555c:	8d 48 08             	lea    0x8(%eax),%ecx
c010555f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105562:	89 0a                	mov    %ecx,(%edx)
c0105564:	8b 50 04             	mov    0x4(%eax),%edx
c0105567:	8b 00                	mov    (%eax),%eax
c0105569:	eb 30                	jmp    c010559b <getuint+0x4d>
    }
    else if (lflag) {
c010556b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010556f:	74 16                	je     c0105587 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105571:	8b 45 08             	mov    0x8(%ebp),%eax
c0105574:	8b 00                	mov    (%eax),%eax
c0105576:	8d 48 04             	lea    0x4(%eax),%ecx
c0105579:	8b 55 08             	mov    0x8(%ebp),%edx
c010557c:	89 0a                	mov    %ecx,(%edx)
c010557e:	8b 00                	mov    (%eax),%eax
c0105580:	ba 00 00 00 00       	mov    $0x0,%edx
c0105585:	eb 14                	jmp    c010559b <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105587:	8b 45 08             	mov    0x8(%ebp),%eax
c010558a:	8b 00                	mov    (%eax),%eax
c010558c:	8d 48 04             	lea    0x4(%eax),%ecx
c010558f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105592:	89 0a                	mov    %ecx,(%edx)
c0105594:	8b 00                	mov    (%eax),%eax
c0105596:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010559b:	5d                   	pop    %ebp
c010559c:	c3                   	ret    

c010559d <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010559d:	55                   	push   %ebp
c010559e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055a0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055a4:	7e 14                	jle    c01055ba <getint+0x1d>
        return va_arg(*ap, long long);
c01055a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01055a9:	8b 00                	mov    (%eax),%eax
c01055ab:	8d 48 08             	lea    0x8(%eax),%ecx
c01055ae:	8b 55 08             	mov    0x8(%ebp),%edx
c01055b1:	89 0a                	mov    %ecx,(%edx)
c01055b3:	8b 50 04             	mov    0x4(%eax),%edx
c01055b6:	8b 00                	mov    (%eax),%eax
c01055b8:	eb 28                	jmp    c01055e2 <getint+0x45>
    }
    else if (lflag) {
c01055ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055be:	74 12                	je     c01055d2 <getint+0x35>
        return va_arg(*ap, long);
c01055c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c3:	8b 00                	mov    (%eax),%eax
c01055c5:	8d 48 04             	lea    0x4(%eax),%ecx
c01055c8:	8b 55 08             	mov    0x8(%ebp),%edx
c01055cb:	89 0a                	mov    %ecx,(%edx)
c01055cd:	8b 00                	mov    (%eax),%eax
c01055cf:	99                   	cltd   
c01055d0:	eb 10                	jmp    c01055e2 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01055d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d5:	8b 00                	mov    (%eax),%eax
c01055d7:	8d 48 04             	lea    0x4(%eax),%ecx
c01055da:	8b 55 08             	mov    0x8(%ebp),%edx
c01055dd:	89 0a                	mov    %ecx,(%edx)
c01055df:	8b 00                	mov    (%eax),%eax
c01055e1:	99                   	cltd   
    }
}
c01055e2:	5d                   	pop    %ebp
c01055e3:	c3                   	ret    

c01055e4 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01055e4:	55                   	push   %ebp
c01055e5:	89 e5                	mov    %esp,%ebp
c01055e7:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c01055ea:	8d 45 14             	lea    0x14(%ebp),%eax
c01055ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01055f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055f3:	50                   	push   %eax
c01055f4:	ff 75 10             	pushl  0x10(%ebp)
c01055f7:	ff 75 0c             	pushl  0xc(%ebp)
c01055fa:	ff 75 08             	pushl  0x8(%ebp)
c01055fd:	e8 06 00 00 00       	call   c0105608 <vprintfmt>
c0105602:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0105605:	90                   	nop
c0105606:	c9                   	leave  
c0105607:	c3                   	ret    

c0105608 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105608:	55                   	push   %ebp
c0105609:	89 e5                	mov    %esp,%ebp
c010560b:	56                   	push   %esi
c010560c:	53                   	push   %ebx
c010560d:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105610:	eb 17                	jmp    c0105629 <vprintfmt+0x21>
            if (ch == '\0') {
c0105612:	85 db                	test   %ebx,%ebx
c0105614:	0f 84 8e 03 00 00    	je     c01059a8 <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c010561a:	83 ec 08             	sub    $0x8,%esp
c010561d:	ff 75 0c             	pushl  0xc(%ebp)
c0105620:	53                   	push   %ebx
c0105621:	8b 45 08             	mov    0x8(%ebp),%eax
c0105624:	ff d0                	call   *%eax
c0105626:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105629:	8b 45 10             	mov    0x10(%ebp),%eax
c010562c:	8d 50 01             	lea    0x1(%eax),%edx
c010562f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105632:	0f b6 00             	movzbl (%eax),%eax
c0105635:	0f b6 d8             	movzbl %al,%ebx
c0105638:	83 fb 25             	cmp    $0x25,%ebx
c010563b:	75 d5                	jne    c0105612 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010563d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105641:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010564b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010564e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105655:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105658:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010565b:	8b 45 10             	mov    0x10(%ebp),%eax
c010565e:	8d 50 01             	lea    0x1(%eax),%edx
c0105661:	89 55 10             	mov    %edx,0x10(%ebp)
c0105664:	0f b6 00             	movzbl (%eax),%eax
c0105667:	0f b6 d8             	movzbl %al,%ebx
c010566a:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010566d:	83 f8 55             	cmp    $0x55,%eax
c0105670:	0f 87 05 03 00 00    	ja     c010597b <vprintfmt+0x373>
c0105676:	8b 04 85 48 6c 10 c0 	mov    -0x3fef93b8(,%eax,4),%eax
c010567d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010567f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105683:	eb d6                	jmp    c010565b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105685:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105689:	eb d0                	jmp    c010565b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010568b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105692:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105695:	89 d0                	mov    %edx,%eax
c0105697:	c1 e0 02             	shl    $0x2,%eax
c010569a:	01 d0                	add    %edx,%eax
c010569c:	01 c0                	add    %eax,%eax
c010569e:	01 d8                	add    %ebx,%eax
c01056a0:	83 e8 30             	sub    $0x30,%eax
c01056a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01056a6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056a9:	0f b6 00             	movzbl (%eax),%eax
c01056ac:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01056af:	83 fb 2f             	cmp    $0x2f,%ebx
c01056b2:	7e 39                	jle    c01056ed <vprintfmt+0xe5>
c01056b4:	83 fb 39             	cmp    $0x39,%ebx
c01056b7:	7f 34                	jg     c01056ed <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056b9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01056bd:	eb d3                	jmp    c0105692 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01056bf:	8b 45 14             	mov    0x14(%ebp),%eax
c01056c2:	8d 50 04             	lea    0x4(%eax),%edx
c01056c5:	89 55 14             	mov    %edx,0x14(%ebp)
c01056c8:	8b 00                	mov    (%eax),%eax
c01056ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01056cd:	eb 1f                	jmp    c01056ee <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c01056cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056d3:	79 86                	jns    c010565b <vprintfmt+0x53>
                width = 0;
c01056d5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01056dc:	e9 7a ff ff ff       	jmp    c010565b <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01056e1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01056e8:	e9 6e ff ff ff       	jmp    c010565b <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c01056ed:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c01056ee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f2:	0f 89 63 ff ff ff    	jns    c010565b <vprintfmt+0x53>
                width = precision, precision = -1;
c01056f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105705:	e9 51 ff ff ff       	jmp    c010565b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010570a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010570e:	e9 48 ff ff ff       	jmp    c010565b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105713:	8b 45 14             	mov    0x14(%ebp),%eax
c0105716:	8d 50 04             	lea    0x4(%eax),%edx
c0105719:	89 55 14             	mov    %edx,0x14(%ebp)
c010571c:	8b 00                	mov    (%eax),%eax
c010571e:	83 ec 08             	sub    $0x8,%esp
c0105721:	ff 75 0c             	pushl  0xc(%ebp)
c0105724:	50                   	push   %eax
c0105725:	8b 45 08             	mov    0x8(%ebp),%eax
c0105728:	ff d0                	call   *%eax
c010572a:	83 c4 10             	add    $0x10,%esp
            break;
c010572d:	e9 71 02 00 00       	jmp    c01059a3 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105732:	8b 45 14             	mov    0x14(%ebp),%eax
c0105735:	8d 50 04             	lea    0x4(%eax),%edx
c0105738:	89 55 14             	mov    %edx,0x14(%ebp)
c010573b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010573d:	85 db                	test   %ebx,%ebx
c010573f:	79 02                	jns    c0105743 <vprintfmt+0x13b>
                err = -err;
c0105741:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105743:	83 fb 06             	cmp    $0x6,%ebx
c0105746:	7f 0b                	jg     c0105753 <vprintfmt+0x14b>
c0105748:	8b 34 9d 08 6c 10 c0 	mov    -0x3fef93f8(,%ebx,4),%esi
c010574f:	85 f6                	test   %esi,%esi
c0105751:	75 19                	jne    c010576c <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c0105753:	53                   	push   %ebx
c0105754:	68 35 6c 10 c0       	push   $0xc0106c35
c0105759:	ff 75 0c             	pushl  0xc(%ebp)
c010575c:	ff 75 08             	pushl  0x8(%ebp)
c010575f:	e8 80 fe ff ff       	call   c01055e4 <printfmt>
c0105764:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105767:	e9 37 02 00 00       	jmp    c01059a3 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010576c:	56                   	push   %esi
c010576d:	68 3e 6c 10 c0       	push   $0xc0106c3e
c0105772:	ff 75 0c             	pushl  0xc(%ebp)
c0105775:	ff 75 08             	pushl  0x8(%ebp)
c0105778:	e8 67 fe ff ff       	call   c01055e4 <printfmt>
c010577d:	83 c4 10             	add    $0x10,%esp
            }
            break;
c0105780:	e9 1e 02 00 00       	jmp    c01059a3 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105785:	8b 45 14             	mov    0x14(%ebp),%eax
c0105788:	8d 50 04             	lea    0x4(%eax),%edx
c010578b:	89 55 14             	mov    %edx,0x14(%ebp)
c010578e:	8b 30                	mov    (%eax),%esi
c0105790:	85 f6                	test   %esi,%esi
c0105792:	75 05                	jne    c0105799 <vprintfmt+0x191>
                p = "(null)";
c0105794:	be 41 6c 10 c0       	mov    $0xc0106c41,%esi
            }
            if (width > 0 && padc != '-') {
c0105799:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010579d:	7e 76                	jle    c0105815 <vprintfmt+0x20d>
c010579f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01057a3:	74 70                	je     c0105815 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057a8:	83 ec 08             	sub    $0x8,%esp
c01057ab:	50                   	push   %eax
c01057ac:	56                   	push   %esi
c01057ad:	e8 17 f8 ff ff       	call   c0104fc9 <strnlen>
c01057b2:	83 c4 10             	add    $0x10,%esp
c01057b5:	89 c2                	mov    %eax,%edx
c01057b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057ba:	29 d0                	sub    %edx,%eax
c01057bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057bf:	eb 17                	jmp    c01057d8 <vprintfmt+0x1d0>
                    putch(padc, putdat);
c01057c1:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01057c5:	83 ec 08             	sub    $0x8,%esp
c01057c8:	ff 75 0c             	pushl  0xc(%ebp)
c01057cb:	50                   	push   %eax
c01057cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01057cf:	ff d0                	call   *%eax
c01057d1:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057d4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01057d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057dc:	7f e3                	jg     c01057c1 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01057de:	eb 35                	jmp    c0105815 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c01057e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01057e4:	74 1c                	je     c0105802 <vprintfmt+0x1fa>
c01057e6:	83 fb 1f             	cmp    $0x1f,%ebx
c01057e9:	7e 05                	jle    c01057f0 <vprintfmt+0x1e8>
c01057eb:	83 fb 7e             	cmp    $0x7e,%ebx
c01057ee:	7e 12                	jle    c0105802 <vprintfmt+0x1fa>
                    putch('?', putdat);
c01057f0:	83 ec 08             	sub    $0x8,%esp
c01057f3:	ff 75 0c             	pushl  0xc(%ebp)
c01057f6:	6a 3f                	push   $0x3f
c01057f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057fb:	ff d0                	call   *%eax
c01057fd:	83 c4 10             	add    $0x10,%esp
c0105800:	eb 0f                	jmp    c0105811 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0105802:	83 ec 08             	sub    $0x8,%esp
c0105805:	ff 75 0c             	pushl  0xc(%ebp)
c0105808:	53                   	push   %ebx
c0105809:	8b 45 08             	mov    0x8(%ebp),%eax
c010580c:	ff d0                	call   *%eax
c010580e:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105811:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105815:	89 f0                	mov    %esi,%eax
c0105817:	8d 70 01             	lea    0x1(%eax),%esi
c010581a:	0f b6 00             	movzbl (%eax),%eax
c010581d:	0f be d8             	movsbl %al,%ebx
c0105820:	85 db                	test   %ebx,%ebx
c0105822:	74 26                	je     c010584a <vprintfmt+0x242>
c0105824:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105828:	78 b6                	js     c01057e0 <vprintfmt+0x1d8>
c010582a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010582e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105832:	79 ac                	jns    c01057e0 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105834:	eb 14                	jmp    c010584a <vprintfmt+0x242>
                putch(' ', putdat);
c0105836:	83 ec 08             	sub    $0x8,%esp
c0105839:	ff 75 0c             	pushl  0xc(%ebp)
c010583c:	6a 20                	push   $0x20
c010583e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105841:	ff d0                	call   *%eax
c0105843:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105846:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010584a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010584e:	7f e6                	jg     c0105836 <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c0105850:	e9 4e 01 00 00       	jmp    c01059a3 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105855:	83 ec 08             	sub    $0x8,%esp
c0105858:	ff 75 e0             	pushl  -0x20(%ebp)
c010585b:	8d 45 14             	lea    0x14(%ebp),%eax
c010585e:	50                   	push   %eax
c010585f:	e8 39 fd ff ff       	call   c010559d <getint>
c0105864:	83 c4 10             	add    $0x10,%esp
c0105867:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010586a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010586d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105870:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105873:	85 d2                	test   %edx,%edx
c0105875:	79 23                	jns    c010589a <vprintfmt+0x292>
                putch('-', putdat);
c0105877:	83 ec 08             	sub    $0x8,%esp
c010587a:	ff 75 0c             	pushl  0xc(%ebp)
c010587d:	6a 2d                	push   $0x2d
c010587f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105882:	ff d0                	call   *%eax
c0105884:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c0105887:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010588a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010588d:	f7 d8                	neg    %eax
c010588f:	83 d2 00             	adc    $0x0,%edx
c0105892:	f7 da                	neg    %edx
c0105894:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105897:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010589a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058a1:	e9 9f 00 00 00       	jmp    c0105945 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01058a6:	83 ec 08             	sub    $0x8,%esp
c01058a9:	ff 75 e0             	pushl  -0x20(%ebp)
c01058ac:	8d 45 14             	lea    0x14(%ebp),%eax
c01058af:	50                   	push   %eax
c01058b0:	e8 99 fc ff ff       	call   c010554e <getuint>
c01058b5:	83 c4 10             	add    $0x10,%esp
c01058b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01058be:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058c5:	eb 7e                	jmp    c0105945 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01058c7:	83 ec 08             	sub    $0x8,%esp
c01058ca:	ff 75 e0             	pushl  -0x20(%ebp)
c01058cd:	8d 45 14             	lea    0x14(%ebp),%eax
c01058d0:	50                   	push   %eax
c01058d1:	e8 78 fc ff ff       	call   c010554e <getuint>
c01058d6:	83 c4 10             	add    $0x10,%esp
c01058d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01058df:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01058e6:	eb 5d                	jmp    c0105945 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c01058e8:	83 ec 08             	sub    $0x8,%esp
c01058eb:	ff 75 0c             	pushl  0xc(%ebp)
c01058ee:	6a 30                	push   $0x30
c01058f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01058f3:	ff d0                	call   *%eax
c01058f5:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c01058f8:	83 ec 08             	sub    $0x8,%esp
c01058fb:	ff 75 0c             	pushl  0xc(%ebp)
c01058fe:	6a 78                	push   $0x78
c0105900:	8b 45 08             	mov    0x8(%ebp),%eax
c0105903:	ff d0                	call   *%eax
c0105905:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105908:	8b 45 14             	mov    0x14(%ebp),%eax
c010590b:	8d 50 04             	lea    0x4(%eax),%edx
c010590e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105911:	8b 00                	mov    (%eax),%eax
c0105913:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105916:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010591d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105924:	eb 1f                	jmp    c0105945 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105926:	83 ec 08             	sub    $0x8,%esp
c0105929:	ff 75 e0             	pushl  -0x20(%ebp)
c010592c:	8d 45 14             	lea    0x14(%ebp),%eax
c010592f:	50                   	push   %eax
c0105930:	e8 19 fc ff ff       	call   c010554e <getuint>
c0105935:	83 c4 10             	add    $0x10,%esp
c0105938:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010593b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010593e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105945:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105949:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010594c:	83 ec 04             	sub    $0x4,%esp
c010594f:	52                   	push   %edx
c0105950:	ff 75 e8             	pushl  -0x18(%ebp)
c0105953:	50                   	push   %eax
c0105954:	ff 75 f4             	pushl  -0xc(%ebp)
c0105957:	ff 75 f0             	pushl  -0x10(%ebp)
c010595a:	ff 75 0c             	pushl  0xc(%ebp)
c010595d:	ff 75 08             	pushl  0x8(%ebp)
c0105960:	e8 f8 fa ff ff       	call   c010545d <printnum>
c0105965:	83 c4 20             	add    $0x20,%esp
            break;
c0105968:	eb 39                	jmp    c01059a3 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010596a:	83 ec 08             	sub    $0x8,%esp
c010596d:	ff 75 0c             	pushl  0xc(%ebp)
c0105970:	53                   	push   %ebx
c0105971:	8b 45 08             	mov    0x8(%ebp),%eax
c0105974:	ff d0                	call   *%eax
c0105976:	83 c4 10             	add    $0x10,%esp
            break;
c0105979:	eb 28                	jmp    c01059a3 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010597b:	83 ec 08             	sub    $0x8,%esp
c010597e:	ff 75 0c             	pushl  0xc(%ebp)
c0105981:	6a 25                	push   $0x25
c0105983:	8b 45 08             	mov    0x8(%ebp),%eax
c0105986:	ff d0                	call   *%eax
c0105988:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010598b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010598f:	eb 04                	jmp    c0105995 <vprintfmt+0x38d>
c0105991:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105995:	8b 45 10             	mov    0x10(%ebp),%eax
c0105998:	83 e8 01             	sub    $0x1,%eax
c010599b:	0f b6 00             	movzbl (%eax),%eax
c010599e:	3c 25                	cmp    $0x25,%al
c01059a0:	75 ef                	jne    c0105991 <vprintfmt+0x389>
                /* do nothing */;
            break;
c01059a2:	90                   	nop
        }
    }
c01059a3:	e9 68 fc ff ff       	jmp    c0105610 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c01059a8:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01059a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01059ac:	5b                   	pop    %ebx
c01059ad:	5e                   	pop    %esi
c01059ae:	5d                   	pop    %ebp
c01059af:	c3                   	ret    

c01059b0 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01059b0:	55                   	push   %ebp
c01059b1:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01059b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b6:	8b 40 08             	mov    0x8(%eax),%eax
c01059b9:	8d 50 01             	lea    0x1(%eax),%edx
c01059bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059bf:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01059c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c5:	8b 10                	mov    (%eax),%edx
c01059c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ca:	8b 40 04             	mov    0x4(%eax),%eax
c01059cd:	39 c2                	cmp    %eax,%edx
c01059cf:	73 12                	jae    c01059e3 <sprintputch+0x33>
        *b->buf ++ = ch;
c01059d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d4:	8b 00                	mov    (%eax),%eax
c01059d6:	8d 48 01             	lea    0x1(%eax),%ecx
c01059d9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059dc:	89 0a                	mov    %ecx,(%edx)
c01059de:	8b 55 08             	mov    0x8(%ebp),%edx
c01059e1:	88 10                	mov    %dl,(%eax)
    }
}
c01059e3:	90                   	nop
c01059e4:	5d                   	pop    %ebp
c01059e5:	c3                   	ret    

c01059e6 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01059e6:	55                   	push   %ebp
c01059e7:	89 e5                	mov    %esp,%ebp
c01059e9:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01059ec:	8d 45 14             	lea    0x14(%ebp),%eax
c01059ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01059f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059f5:	50                   	push   %eax
c01059f6:	ff 75 10             	pushl  0x10(%ebp)
c01059f9:	ff 75 0c             	pushl  0xc(%ebp)
c01059fc:	ff 75 08             	pushl  0x8(%ebp)
c01059ff:	e8 0b 00 00 00       	call   c0105a0f <vsnprintf>
c0105a04:	83 c4 10             	add    $0x10,%esp
c0105a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a0d:	c9                   	leave  
c0105a0e:	c3                   	ret    

c0105a0f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105a0f:	55                   	push   %ebp
c0105a10:	89 e5                	mov    %esp,%ebp
c0105a12:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a18:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a21:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a24:	01 d0                	add    %edx,%eax
c0105a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105a30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a34:	74 0a                	je     c0105a40 <vsnprintf+0x31>
c0105a36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a3c:	39 c2                	cmp    %eax,%edx
c0105a3e:	76 07                	jbe    c0105a47 <vsnprintf+0x38>
        return -E_INVAL;
c0105a40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105a45:	eb 20                	jmp    c0105a67 <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105a47:	ff 75 14             	pushl  0x14(%ebp)
c0105a4a:	ff 75 10             	pushl  0x10(%ebp)
c0105a4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105a50:	50                   	push   %eax
c0105a51:	68 b0 59 10 c0       	push   $0xc01059b0
c0105a56:	e8 ad fb ff ff       	call   c0105608 <vprintfmt>
c0105a5b:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c0105a5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a61:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a67:	c9                   	leave  
c0105a68:	c3                   	ret    
